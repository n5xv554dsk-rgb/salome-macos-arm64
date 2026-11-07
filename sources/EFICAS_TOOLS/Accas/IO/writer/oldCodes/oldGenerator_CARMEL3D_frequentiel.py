# -*- coding: utf-8 -*-
# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
"""Ce module contient le plugin generateur de fichier au format  Code_Carmel3D pour EFICAS.
"""

import traceback
import types,string,re,os
from Accas.extensions.eficas_translation import tr
from generator_python import PythonGenerator

# Groupes de mailles dont les types sont definis par des prefixes dans leur nom
usePrefix = False # les noms ont des prefixes (True) ou non (False)
# liste des prefixes des groupes de mailles, sans le caractere _ separant le prefixe du reste du nom
# Ce prefixe (et caractere _) doivent etre supprimes dans le fichier .phys
listePrefixesGroupeMaille = ("DIEL","NOCOND","COND","CURRENT","EPORT","HPORT","TOPO","PB_MOBILE","NILMAT",
                         "VCUT","VCUTN","EWALL","HWALL","GAMMAJ","PERIODIC","APERIODIC",
                         "HPROBE","EPROBE","BFLUX","BFLUXN","JFLUX","JFLUXN",
                         "PORT_OMEGA","POST_PHI","PB_GRID",
                         "SCUTE","SCUTN","ZS","ZJ","ZT")
# liste des prefixes des groupes de mailles, sans le separateur, par type de bloc du fichier PHYS sous la forme d'un dictionnaire
dictPrefixesGroupeMaille = {'DIELECTRIC':('DIEL','NOCOND'), 
                                             'CONDUCTOR':('COND',), 
                                             'STRANDED_INDUCTOR':('CURRENT', ), 
                                             'EPORT':('EPORT', ), 
                                             'HPORT':('HPORT', ), 
                                             'ZSURFACIC':('ZS', ), 
                                             'ZINSULATOR':('ZJ', ), 
                                             'NILMAT':('NILMAT', )}
# separateur entre le prefixe et le reste du nom du groupe de maille
sepNomGroupeMaille = '_'


# types de problemes
HARMONIC = 'HARMONIC' # probleme frequentiel
TIME_DOMAIN = 'TIME_DOMAIN' # probleme temporel

# nom du plugin, utilisé dans entryPoint et generMACRO_ETAPE()
nomPlugin = 'CARMEL3DFV0'

def entryPoint():
   """
      Retourne les informations necessaires pour le chargeur de plugins
      Ces informations sont retournees dans un dictionnaire
   """
   return {
        # Le nom du plugin
          'name' : nomPlugin,
        # La factory pour creer une instance du plugin
          'factory' : CARMEL3DFV0Generator,
          }



class CARMEL3DFV0Generator(PythonGenerator):
   """
      Ce generateur parcourt un objet de type JDC et produit
      un texte au format eficas et 
      un texte au format attendu par le code Code_Carmel3D (fichier '.PHYS') 

   """
   # Les extensions de fichier permis?
   extensions=('.comm',)

#----------------------------------------------------------------------------------------
   def gener(self,obj,format='brut',config=None):
       
      self.initDico()
      
      #self.debug = True
      
      # Cette instruction genere le contenu du fichier de commandes (persistance)
      self.text=PythonGenerator.gener(self,obj,format)

      if self.debug:
         print "self.text = %s" % self.text

      # Cette instruction genere le contenu du fichier de parametres pour le code Carmel3D
      # si le jdc est valide (sinon cela n a pas de sens)
      if obj.isValid() : 
           try :
             # constitution du bloc VERSION du fichier PHYS (existe toujours)
             self.generBLOC_VERSION(obj)
             # constitution du bloc MATERIALS du fichier PHYS (existe toujours)
             self.generBLOC_MATERIALS()
             # constitution du bloc SOURCES du fichier PHYS (existe toujours)
             self.generBLOC_SOURCES()
             
           except ValueError, err:
             raise ValueError(str(err))

#      print "texte carmel3d :\n",self.texteCarmel3D
#      print "dictMaterDielectric : ",self.dictMaterDielectric
      if self.debug:
         print "dictMaterDielectric : %s" % repr(self.dictMaterDielectric)
         print "dictMaterConductor : %s" % repr(self.dictMaterConductor)
      
      return self.text




#----------------------------------------------------------------------------------------
# initialisations
#----------------------------------------------------------------------------------------
   
   def initDico(self) :
      self.texteCarmel3D=""
      self.texteCarmel3D_PARAM=""
      self.texteCarmel3D_PARAM_SOLV=""
      self.texteCarmel3D_SH=""      
      self.texteCarmel3D_INFC=""
      self.texteCarmel3D_CMD=""
      self.texteCarmel3D_INGEND1=""
      self.texteCarmel3D_INGEND2=""
      self.texteCarmel3D_INGEND3=""
      self.texteCarmel3D_INPOST=""
      self.debug = True # affichage de messages pour deboguage (.true.) ou non
      self.dicoEtapeCourant=None
      self.dicoMCFACTCourant=None
      self.dicoCourant=None
      self.dictGroupes = {'ordreMateriauxJdC':[], 'ordreSourcesJdC':[], 'ordreStrandJdC':[], 'ordreListeJdC':[], 'ordreDomaineJdC':[]} # association des noms de groupes de maillage avec les noms de materiaux ou de sources, en sauvegardant l'ordre du JdC en separant les groupes associes a des materiaux de ceux associes a des sources
      self.dictMaterConductor={}
      self.dictMaterDielectric={}
      self.dictMaterZsurfacic={}
      self.dictMaterEmIso={}
      self.dictMaterEmAnIso={}
      self.dictMaterNilmat={}
      self.dictMaterZinsulator={}
      self.dictSourceStInd={}
      self.dictSourceEport={}
      self.dictSourceHport={}
      self.dictStrand={}
      self.dictDomaine={}
      self.dictPort={}
      self.cutlineValeur=[]
      self.cutplaneValeur=[]
      self.visu3dValeur=[]
      self.fieldmapValeur=[]
      self.fielddumpValeur=[]
      self.repertory=""
      self.frequency=""
      self.domaine=""
      self.direction=""
      self.section=""
      self.forme=""
      self.centre=""
      self.echelle=""
      self.visu=False
      self.post_global=False
      self.visu_format=""
      self.visu_type=""
      self.gendof=""
      self.fcarmel=""
      self.postprocess=""
      self.formulation=""
      # on force le probleme a etre frequentiel, seul possible en l'etat des choses
      self.problem = HARMONIC
      self.fichierMaillage = "" # chemin absolu ou relatif  du fichier contenant le maillage, défini dans PARAMETERS.Fichier_maillage.
      self.nomFichierMaillage = "" # nom du fichier de maillage, sans le chemin
      self.projet = "" # nom du projet, utilisé un peu partout, i.e., nom du fichier de maillage sans l'extension
      self.materiauxGroupesTousHomogenes = True # Tous les groupes sont associés a priori à des matériaux tous homogènes mais pas forcément isotropes. On le vérifie ou modifie ci-dessous. 
      self.materiauxGroupesTousIsotropes = True # Tous les groupes sont associés a priori à des matériaux tous isotropes mais pas forcément homogènes. On le vérifie ou modifie ci-dessous. 

#----------------------------------------------------------------------------------------
# ecriture
#----------------------------------------------------------------------------------------

   def writeDefault(self,fn) :
        """Ecrit les fichiers de parametres et le fichier d'execution pour le code Carmel3D"""
        
        # fn est le chemin complet du fichier de l'étude, e.g., /home/toto/foo.comm
        #file =  fn[:fn.rfind(".")]  # chemin complet du fichier de l'étude sans l'extension, e.g., /home/toto/foo
        repertory=os.path.dirname(fn)  # répertoire de l'étude, e.g., /home/toto/
        file = os.path.join(repertory, self.projet) # on crée le chemin complet des fichiers de configuration sans extension, à partir du nom du projet.
        namefile=os.path.basename(file) # nom du projet e.g., foo
            
        
        if self.debug: 
            print "ecriture du fichier de parametres (PHYS)"
        filePHYS = file + '.phys'
        typeBloc = 'PHYS_FILES'
        f = open( str(filePHYS), 'w')
        f.write( self.texteCarmel3D)
        f.close()
        

        if self.debug: 
            print "ecriture du fichier de parametres (PARAM)"
        filePARAM = file + '.param'
        f = open( str(filePARAM), 'w')
        f.write('[VERSION \n'
                    '   NUM     1\n'
                    '   FILETYPE PARAM\n]\n'
                    '[PROBLEM\n'
                    '   NAME HARMONIC\n]\n'
                )                
        typeBloc = 'CAR_FILES'
        self.texteCarmel3D_PARAM+="["+typeBloc+"\n" # debut de bloc
        self.texteCarmel3D_PARAM+="    NAME "+self.projet+".car"
        self.texteCarmel3D_PARAM+="\n]\n" # fin de bloc
        typeBloc = 'PHYS_FILES'
        self.texteCarmel3D_PARAM+="["+typeBloc+"\n" # debut de bloc
        self.texteCarmel3D_PARAM+="    NAME "+self.projet+".phys" 
        self.texteCarmel3D_PARAM+="\n]\n" # fin de bloc
        self.texteCarmel3D_PARAM+="[FREQUENCY\n"
        self.texteCarmel3D_PARAM+="   SINGLE %g \n" % (self.frequency )
        self.texteCarmel3D_PARAM+="] \n"
        f.write( self.texteCarmel3D_PARAM)
        f.write(self.texteCarmel3D_PARAM_SOLV)
        f.close()
 
        # ecriture du fichier de commandes du post-traitement (.cmd), à partir du texte self.textCarmel3D défini dans la routine generPOST_COMMANDS
        if self.debug: 
            print "ecriture du fichier de parametres (CMD)"
        fileCMD =file + '.cmd'
        f = open( str(fileCMD), 'w')
        f.write(self.texteCarmel3D_CMD)
        f.close()


        if self.debug: 
            print "ecriture du fichier de parametres (INGENDOF)"
        fileINGEND = file + '.ingendof'
        f = open(fileINGEND, 'w')
        self.texteCarmel3D_INGEND1+=""+self.nomFichierMaillage # nom du fichier de maillage (chemin relatif)
        
        nomsGroupes = self.dictGroupes['ordreStrandJdC'][:] 
        nomsGroupes.sort()

        #if self.dictDomaine !={}:
        try:
            self.creaBLOC_STRANDED_INDUCTOR_GEOMETRY(nomsGroupes)
        except ValueError, err:
            raise ValueError(str(err))
        if self.dictPort != {} :
            self.creaBLOC_PORTS_GEOMETRY(nomsGroupes)
        if self.formulation=="APHI": self.texteCarmel3D_INGEND3+="\n1"
        if self.formulation=="TOMEGA": self.texteCarmel3D_INGEND3+="\n2"
        f.write(self.texteCarmel3D_INGEND1)
        f.write(self.texteCarmel3D_INGEND2)  
        f.write(self.texteCarmel3D_INGEND3)
        f.close()     

        if self.debug: 
            print "ecriture du fichier de parametres (INFCARMEL) "
        fileINFC = file + '.infcarmel'
        f = open(fileINFC, 'w')
        self.texteCarmel3D_INFC+= self.projet+".param"
        f.write(self.texteCarmel3D_INFC)
        f.close()      
        
        if self.debug: 
            print "ecriture du fichier de parametres (INPOSTPROCESS) "
        fileINPOST = file + '.inpostprocess'
        f = open(fileINPOST, 'w')
        self.texteCarmel3D_INPOST+= self.projet+".param"
        self.texteCarmel3D_INPOST+="\n"+self.projet+".xmat"
        self.texteCarmel3D_INPOST+="\n"+self.projet+".cmd"
        f.write(self.texteCarmel3D_INPOST)
        f.close()            

        print "dictionnaire complet=%s" %self.dictGroupes
        print "dictionnaire des ports =%s"  %self.dictPort
        if self.debug: 
            print "ecriture du fichier d'execution (SH)"
            print"LISTE DES DOMAINES=%s" %(self.dictGroupes['ordreDomaineJdC'])
        RepCarmel= os.path.join(repertory,"lancer.sh")
        f = open( str(RepCarmel), 'wb')
        self.texteCarmel3D_SH+='cd ' + repertory + ' \n'
        if self.gendof=="TRUE":
            self.texteCarmel3D_SH+='echo "Debut execution gendof" \n'
            if self.echelle=="Millimetre":
                self.texteCarmel3D_SH+=self.repertory+"/gendof.exe -scale 0.001 < " + self.projet + ".ingendof\n"
            else:
                self.texteCarmel3D_SH+=self.repertory+"/gendof.exe < " + self.projet + ".ingendof\n"
        if self.fcarmel=="TRUE": 
            self.texteCarmel3D_SH+='echo "Debut execution fcarmel" \n'
            self.texteCarmel3D_SH+=self.repertory+"/fcarmel.exe <  " + self.projet + ".infcarmel\n"
        if self.postprocess=="TRUE":
            self.texteCarmel3D_SH+= 'echo "Debut execution postprocess" \n'
            self.texteCarmel3D_SH+= self.repertory+"/postprocess.exe < " + self.projet + ".inpostprocess\n"
        f.write(self.texteCarmel3D_SH)
        f.close()      
        
#----------------------------------------------------------------------------------------
#  analyse de chaque noeud de l'arbre 
#----------------------------------------------------------------------------------------

   def generMCSIMP(self,obj) :
        """recuperation de l objet MCSIMP"""
        if self.debug: 
            print "MCSIMP %(v_1)s  %(v_2)s" % {'v_1': obj.nom, "v_2": obj.valeur}
        s=PythonGenerator.generMCSIMP(self,obj)
        try:
            self.dicoCourant[obj.nom]=obj.valeurFormatee
        except:
            print "Oubli des messages texte homo='information'"
        return s

  
#----------------------------------------------------------------------------------------
   def generMCFACT(self,obj) :
        """recuperation de l objet MCFACT"""
        if self.debug:
            print "MCFACT debut %(v_1)s  %(v_2)s" % {'v_1': unicode(obj.nom), "v_2": unicode(obj.valeur)}
        dico={}
        self.dicoMCFACTCourant=dico
        self.dicoCourant=self.dicoMCFACTCourant
        s=PythonGenerator.generMCFACT(self,obj)
        # sauvegarde, dans self.dicoEtapeCourant, de la valeur du FACT courant, pour utilisation ultérieure dans generETAPE et generPROC_ETAPE
        # traitement des FACT CUTLINE et CUTPLANE multiples (max='**' dans le catalogue)
        # Ce traitement spécial est nécessaire pour le moment car le générateur bogue sinon au niveau des matériaux (non-linéaires ?)
        if obj.nom in ('FIELDDUMP','CUTLINE', 'CUTPLANE', 'FIELDMAP', 'VISU3D' ): 
            # Remplissage se self.dicoEtapeCourant pour le nom du FACT courant
            # Il ne contient qu'une seule valeur (un dictionnaire) par défaut lorsque le FACT est unique (max=1 dans le catalogue),
            # mais il peut aussi contenir plusieurs valeurs (tableau) dans le cas contraire, e.g., max='**' dans le catalogue
            if self.dicoEtapeCourant.has_key(obj.nom): # plusieurs valeurs
                print "self.dicoEtapeCourant= %s"%self.dicoEtapeCourant
                if type(self.dicoEtapeCourant[obj.nom]) == types.DictType: # une seule valeur entrée jusqu'à présent
                    dicoMCFACTprecedent = self.dicoEtapeCourant[obj.nom] # sauvegarde de la valeur précédente
                    print "dicoMCFACTpreceden= %s self.dicoEtapeCourant= %s"%(dicoMCFACTprecedent,self.dicoEtapeCourant) 
                    self.dicoEtapeCourant[obj.nom] = [ dicoMCFACTprecedent, self.dicoMCFACTCourant ] # restructuration en liste et insertion de la valeur précédente et de la valeur courant
                    print "self.dicoEtapeCourant[obj.nom]= %s"%self.dicoEtapeCourant[obj.nom]
                else: # plusieurs valeurs entrées jusqu'à présent, sous la forme d'une liste de dictionnaires
                    self.dicoEtapeCourant[obj.nom].append(self.dicoMCFACTCourant) # extension de la liste avec cette valeur, placée en dernier
            else: # une seule valeur ou première valeur
                self.dicoEtapeCourant[obj.nom]=self.dicoMCFACTCourant
        else: # traitement usuel des FACT uniques, pour ignorer le bogue décrit plus haut
            self.dicoEtapeCourant[obj.nom]=self.dicoMCFACTCourant
        self.dicoMCFACTCourant=None
        self.dicoCourant=self.dicoEtapeCourant
        if self.debug:
            print "MCFACT fin %(v_1)s  %(v_2)s" % {'v_1': unicode(obj.nom), "v_2": unicode(obj.valeur)}
        return s


#----------------------------------------------------------------------------------------
   def generPROC_ETAPE(self,obj):
        """analyse des PROC du catalogue  ( VERSION )"""
        if self.debug: 
            print "PROC_ETAPE initial: %(v_1)s  %(v_2)s" % {'v_1': unicode(obj.nom), "v_2": unicode(obj.valeur)}
        dico={}
        self.dicoEtapeCourant=dico
        self.dicoCourant=self.dicoEtapeCourant
        s=PythonGenerator.generPROC_ETAPE(self,obj)
        obj.valeur=self.dicoEtapeCourant # on passe à obj la bonne structure générée par PythonGenerator.generPROC_ETAPE, pour le traitement de chaque partie ci-dessous
        if self.debug: 
            print "PROC_ETAPE mis a jour: %(v_1)s  %(v_2)s" % {'v_1': unicode(obj.nom), "v_2": unicode(obj.valeur)}
        if obj.nom=="PARAMETERS" : self.generBLOC_PARAMETERS(obj)
        if obj.nom=="SOLVEUR" : self.generSOLVEUR(obj)
        if obj.nom=="POST_COMMANDS" : self.generPOST_COMMANDS(obj)
        s=PythonGenerator.generPROC_ETAPE(self,obj) # obj.valeur a été modifiée pour le traitement ci-dessus, alors il faut tout remettre en ordre en appelant de nouveau PythonGenerator.generPROC_ETAPE
        return s



#----------------------------------------------------------------------------------------
   def generETAPE(self,obj):
        """analyse des OPER du catalogue"""
        if self.debug: 
            print "ETAPE mis a jour: obj.nom = %(v_1)s , obj.valeur= %(v_2)s" % {'v_1': obj.nom, 'v_2': obj.valeur}
        dico={}
        self.dicoEtapeCourant=dico
        self.dicoCourant=self.dicoEtapeCourant
        s=PythonGenerator.generETAPE(self,obj)
        obj.valeur=self.dicoEtapeCourant # cf. generPROC_ETAPE
        if self.debug: 
            print "ETAPE mis a jour: obj.nom = %(v_1)s , obj.valeur= %(v_2)s" % {'v_1': obj.nom, 'v_2': obj.valeur}
        if obj.nom=="MESHGROUP" : self.generMESHGROUP(obj)
        if obj.nom=="MATERIAL" : self.generMATERIAL(obj)
        if obj.nom=="SOURCE" : self.generSOURCE(obj)
        if obj.nom=="STRANDED_INDUCTOR_GEOMETRY" : self.generSTRANDED_INDUCTOR_GEOMETRY(obj)
        if obj.nom=="MACRO_GROUPE": self.generMACRO_GROUPE(obj)
        s=PythonGenerator.generETAPE(self,obj) # cf. generPROC_ETAPE
        return s

#----------------------------------------------------------------------------------------
   def generMACRO_ETAPE(self,obj):
        dico={}
        self.dicoEtapeCourant=dico
        self.dicoCourant=self.dicoEtapeCourant
        import generator
        monGenerateur=generator.plugins[nomPlugin]()
        jdc_aux_texte=monGenerateur.gener(obj.jdc_aux)
        if self.debug: 
            print "jdc_aux_texte : %s" % jdc_aux_texte

        for cle in monGenerateur.dictMaterConductor:
            self.dictMaterConductor[cle] = monGenerateur.dictMaterConductor[cle]
        for cle in monGenerateur.dictMaterDielectric:
            self.dictMaterDielectric[cle] = monGenerateur.dictMaterDielectric[cle]
        for cle in monGenerateur.dictMaterZsurfacic:
            self.dictMaterZsurfacic[cle] = monGenerateur.dictMaterZsurfacic[cle]
        for cle in monGenerateur.dictMaterEmIso:
            self.dictMaterEmIso[cle] = monGenerateur.dictMaterEmIso[cle]
        for cle in monGenerateur.dictMaterEmAnIso:
            self.dictMaterEmAnIso[cle] = monGenerateur.dictMaterEmAnIso[cle]
        for cle in monGenerateur.dictMaterNilmat:
            self.dictMaterNilMat[cle] = monGenerateur.dictMaterNilMat[cle]
        for cle in monGenerateur.dictMaterZinsulator:
            self.dictMaterZinsulator[cle] = monGenerateur.dictMaterZinsulator[cle]
              
        print "________FIN MACRO______________________________________"
        s=PythonGenerator.generMACRO_ETAPE(self,obj)
        return s

#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------
   def generMESHGROUP(self,obj):
        """preparation de la ligne NAME referencant le groupe de mailles 
            associe le groupe de mailles au materiau ou a la source utilisateur
            on sauvegarde aussi les noms des groupes de maillage
        """
        try:
            if usePrefix:
                nomGroupe = self.nomReelGroupe(obj.getSdname()) # nom du groupe de maillage, i.e. nom du concept, avec prefixes enleves
                print "liste des noms sans prefixes %s" %(nomGroupe)
            else:
                nomGroupe = obj.getSdname() # nom du groupe de maillage, i.e. nom du concept
                print "liste des noms sans prefixes %s" %(nomGroupe)

            # test: un et un seul nom de materiau ou source doit etre associe a ce groupe de maillage, via les cles MATERIAL et SOURCE, respectivement.
            # test sur un seul attribut, non pertinent car il peut y en avoir plusieurs.
            #assert len(obj.valeur.keys())==1,"Un et un seul nom de materiau ou source doit etre associe a ce groupe du maillage :"+nomGroupe
            #
            # on utilise le fait que obj.valeur est un dictionnaire
            self.dictGroupes[nomGroupe] = {}   
#            nomGroupe={'SOURCE':[], 'MATERIAL':[], 'LISTE':[], 'STRAND':[], }   
            if self.debug: 
                print "obj.valeur.keys()= %s" % obj.valeur.keys()
            if 'MATERIAL' in obj.valeur.keys() and 'SOURCE' in obj.valeur.keys(): # test d'erreur lors de presence de materiau et source a la fois
                raise ValueError, nomGroupe + tr(" : ce groupe de maillage ne peut pas etre associe a un materiau et une source a la fois.")
            # association a un materiau
            if 'MATERIAL' in obj.valeur.keys():
                self.dictGroupes[nomGroupe]['MATERIAL'] = obj.valeur['MATERIAL'].nom # sauvegarde de l'association entre ce groupe de maillage et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
                self.dictGroupes['ordreMateriauxJdC'].append(nomGroupe) # sauvegarde du nom du groupe de maillage associe a un materiau, dans l'ordre du JdC
            # association a une source
            if 'SOURCE' in obj.valeur.keys():
                self.dictGroupes[nomGroupe]['SOURCE'] = obj.valeur['SOURCE'].nom # sauvegarde de l'association entre ce groupe de maillage et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
                self.dictGroupes['ordreSourcesJdC'].append(nomGroupe) # sauvegarde du nom du groupe de maillage associe a une source, dans l'ordre du JdC
            # erreur ni materiau ni source associee
            if 'STRANDED_INDUCTOR_GEOMETRY' in obj.valeur.keys():
                    self.dictGroupes[nomGroupe]['STRAND'] = obj.valeur['STRANDED_INDUCTOR_GEOMETRY'].nom # sauvegarde de l'association entre ce groupe de maillage et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
                    self.dictGroupes['ordreStrandJdC'].append(nomGroupe) # sauvegarde du nom du groupe de maillage associe a une source, dans l'ordre du JdC
            if 'Domaine' in obj.valeur.keys():
                self.dictGroupes[nomGroupe]['DOMAINE'] = obj.valeur['Domaine']
                self.dictGroupes['ordreDomaineJdC'].append(nomGroupe)
                texte=""
                texte+="%s"%(obj.valeur['Domaine'])
                print"le texte=%s" %(texte)
                self.dictDomaine[obj.getSdname()]=texte  
                print "liste des domaines =%s" %(self.dictGroupes[nomGroupe]['DOMAINE'])
                    
#            else:
#                raise ValueError, tr("ce groupe de maillage %s n'est associe a aucun materiau, source ou stranded_inductor_geometry." % nomGroupe)
            if self.debug:
                print "self.dictGroupes= %s" % repr(self.dictGroupes)
        except ValueError, err:
            raise ValueError, str(err)
            
   def generMACRO_GROUPE(self, obj):
        """preparation de la ligne NAME referencant le groupe de mailles 
            associe le groupe de mailles au materiau ou a la source utilisateur
            on sauvegarde aussi les noms des macros groupes
        """
        try:
            #nomGroupe={'SOURCE':[], 'MATERIAL':[], 'LISTE':[], 'STRAND':[], }   
            if usePrefix:
                nomGroupe = self.nomReelGroupe(obj.getSdname()) # nom du groupe de maillage, i.e. nom du concept, avec prefixes enleves
                print "liste des noms sans prefixes %s" %(nomGroupe)
            else:
                nomGroupe = obj.getSdname() # nom du macro groupe
                print "liste des noms sans prefixes %s" %(nomGroupe)
            self.dictGroupes[nomGroupe] = {}   
                
            # test: un et un seul nom de materiau ou source doit etre associe a ce groupe de maillage, via les cles MATERIAL et SOURCE, respectivement.
            # test sur un seul attribut, non pertinent car il peut y en avoir plusieurs.
            #assert len(obj.valeur.keys())==1,"Un et un seul nom de materiau ou source doit etre associe a ce groupe du maillage :"+nomGroupe
            #
            # on utilise le fait que obj.valeur est un dictionnaire
            if self.debug: 
                print "obj.valeur.keys()= %s" % obj.valeur.keys()
            if 'MATERIAL' in obj.valeur.keys() and 'SOURCE' in obj.valeur.keys(): # test d'erreur lors de presence de materiau et source a la fois
                raise ValueError, nomgroupe + tr(" : ce MACRO_GROUPE ne peut pas contenir a la fois un MATERIAL et une SOURCE.")
            # association a une source
            if 'SOURCE' in obj.valeur.keys():
                self.dictGroupes[nomGroupe]['SOURCE'] = obj.valeur['SOURCE'].nom # sauvegarde de l'association entre ce macro groupe et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
                self.dictGroupes['ordreSourcesJdC'].append(nomGroupe) # sauvegarde du nom du groupe de maillage associe a une source, dans l'ordre du JdC
            # erreur ni materiau ni source associee
            if 'LISTE_MESHGROUP' in obj.valeur.keys():
                listeStrandedInductorGeometry = True # indicateur du fait que tous les groupes de la liste sont des inducteurs bobinés ou topologiques, en morceaux ou entier (True), ou non (False). Utilisé pour savoir si le Domaine est nécessaire ou non.
                listeGroupesMauvaisFormat = obj.valeur['LISTE_MESHGROUP'] # sauvegarde de l'association entre ce macro groupe et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
                self.dictGroupes[nomGroupe]['LISTE'] = [] # sauvegarde de l'association entre ce macro groupe et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
                for groupe in listeGroupesMauvaisFormat: # sauvegarde de la liste au format correct
                    groupe = groupe.replace("'", "") # suppression des guillement simpes
                    groupe = groupe.replace('"', "") # suppression des guillement doubles
                    self.dictGroupes[nomGroupe]['LISTE'].append(groupe) # sauvegarde du nom au formatage correct
                    if not self.dictGroupes[groupe].has_key('STRAND'): listeStrandedInductorGeometry = False # au moins un groupe de la liste n'est pas un inducteur bobiné ou topologique (morceau ou entier).
                self.dictGroupes['ordreListeJdC'].append(nomGroupe) # sauvegarde du nom du macro groupe associe a une source, dans l'ordre du JdC
                if not listeStrandedInductorGeometry: # Erreur en cas de liste ne définissant pas que des inducteurs bobinés ou topologiques en morceaux
                    raise ValueError, nomGroupe + tr(" : ce MACRO_GROUPE ne doit contenir, dans LISTE_MESHGROUP, que des morceaux d'inducteurs bobines ou topologiques.")
                # test de présence du domaine pour les cas appropriés d'inducteur bobiné ou topologique en morceau.
                if 'Domaine' in obj.valeur.keys():
                    if listeStrandedInductorGeometry: # Domaine seulement  en cas de liste définissant des inducteurs bobinés ou topologiques en morceaux
                        self.dictGroupes[nomGroupe]['DOMAINE'] = obj.valeur['Domaine']
                        self.dictGroupes['ordreDomaineJdC'].append(nomGroupe)
                        texte=""
                        texte+="%s"%(obj.valeur['Domaine'])
                        print"le texte=%s" %(texte)
                        self.dictDomaine[obj.getSdname()]=texte                  
                    else: # Erreur si Domaine et macro-groupe pas complètement inducteur
                        raise ValueError, nomGroupe + tr(" : ce MACRO_GROUPE ne doit pas contenir de Domaine car il contient, dans LISTE_MESHGROUP, des groupes qui ne sont pas que des morceaux d'inducteurs bobines ou topologiques.")
                else: # Domaine manquant
                    if listeStrandedInductorGeometry: # Erreur en cas de liste définissant des inducteurs bobinés ou topologiques en morceaux
                        raise ValueError, nomGroupe + tr(" : ce MACRO_GROUPE de morceaux d'inducteurs bobines ou topologiques doit contenir aussi un Domaine.")
            else:
                raise ValueError, nomGroupe + tr(" : ce MACRO_GROUPE doit contenir une liste de groupes LISTE_MESHGROUP.")
            if self.debug:
                print "self.dictGroupes= %s" % repr(self.dictGroupes)
                print "self.dictDomaine=%s" %(self.dictDomaine)
        except ValueError, err:
            raise ValueError, str(err)


   def generSOLVEUR(self, obj):
        if self.debug:
            print "generation material obj.valeur = %s" % obj.valeur
        try :
            nature = obj.valeur['Type']
            if nature == "Solveur_lineaire" : self.generSOLVEUR_LINEAIRE(obj)
        except ValueError,  err:
            raise ValueError,  str(err)
            
   def generSOLVEUR_LINEAIRE(self, obj):
        if self.debug:
            print "generation material obj.valeur = %s" % obj.valeur    
        try :
            nature = obj.valeur['Methode_lineaire']
            if nature =="Methode iterative BICGCR" : self.generMETHODE_ITERATIVE_BICGCR(obj)
            if nature  =="Methode directe MUMPS" : self.generMETHODE_DIRECTE_MUMPS(obj)
        except ValueError,  err:
            raise ValueError,  str(err)
            
   def generMETHODE_ITERATIVE_BICGCR(self, obj):
        texte=""
        if self.debug:
            print "_____________iter_____________"

            self.texteCarmel3D_PARAM_SOLV+="[SOLVER \n"
            self.texteCarmel3D_PARAM_SOLV+="    NAME BICGCR\n"      
            self.texteCarmel3D_PARAM_SOLV+="    [ITERATIVE_PARAM \n"                         
            self.texteCarmel3D_PARAM_SOLV+="        NITERMAX   "+str(obj.valeur["Nombre_iterations_max"])+"\n"
            self.texteCarmel3D_PARAM_SOLV+="        EPSILON  "+str(obj.valeur["Precision"])+"\n"
            self.texteCarmel3D_PARAM_SOLV+="    ]\n] \n"
        if self.debug: 
           print "texte = %s", texte

       
   def generMETHODE_DIRECTE_MUMPS(self, obj):
        texte=""
        if self.debug:
            print "_____________directe_____________"

            self.texteCarmel3D_PARAM_SOLV+="[SOLVER \n"
            self.texteCarmel3D_PARAM_SOLV+="    NAME MUMPS\n"              
            self.texteCarmel3D_PARAM_SOLV+="    [MUMPS_PARAMETER \n"
            self.texteCarmel3D_PARAM_SOLV+="         SYM   "+str(obj.valeur["Type_de_matrice"])+"\n"
            self.texteCarmel3D_PARAM_SOLV+="       ICNTL   "+str(obj.valeur["ICNTL_Control_Parameters"])+"     "+str(obj.valeur["CNTL_Control_Parameters"])+"\n"
            self.texteCarmel3D_PARAM_SOLV+="    ]\n] \n"
        if self.debug: 
           print "texte = %s", texte
        
             

   def generMATERIAL(self,obj):
        """preparation du bloc correspondant a un materiau du fichier PHYS"""
        texte=""
        if self.debug: 
            print "generation material obj.valeur = %s" % obj.valeur
        try :
            nature = obj.valeur['TYPE'] # la nature est le parametre TYPE du MATERIAL
            if nature=="CONDUCTOR" : self.generMATERIAL_CONDUCTOR(obj)
            if nature=="DIELECTRIC" : self.generMATERIAL_DIELECTRIC(obj)
            if nature=="ZSURFACIC" : self.generMATERIAL_ZSURFACIC(obj)
            if nature=="EM_ISOTROPIC" : self.generMATERIAL_EMISO(obj)
            if nature=="EM_ANISOTROPIC" : self.generMATERIAL_EMANISO(obj)
            if nature=="NILMAT" : self.generMATERIAL_NILMAT(obj)
            if nature=="ZINSULATOR" : self.generMATERIAL_ZINSULATOR(obj)
        except ValueError, err:
            raise ValueError, str(err)

   def generMATERIAL_CONDUCTOR(self,obj):
       """preparation du sous bloc CONDUCTOR"""
       texte=""
       if self.debug: 
           print "_____________cond_____________"
       # verification des proprietes du sous bloc CONDUCTOR (PERMEABILITY, CONDUCTIVITY)
       if 'PERMEABILITY' not in obj.valeur or 'CONDUCTIVITY' not in obj.valeur:
            print "ERREUR! Le matériau conducteur (CONDUCTOR) de nom %s doit contenir les propriétés PERMEABILITY et CONDUCTIVITY." % obj.getSdname()
            raise ValueError,  obj.getSdname() + tr(" : ce materiau conducteur (CONDUCTOR) doit contenir les proprietes PERMEABILITY et CONDUCTIVITY.")
       else:
          # parcours des proprietes du sous bloc CONDUCTOR (PERMEABILITY, CONDUCTIVITY)
          for keyN1 in ('PERMEABILITY','CONDUCTIVITY') :
             # debut du sous bloc de propriete du DIELECTRIC
             texte+="         ["+keyN1+"\n"
             texte+="            HOMOGENEOUS "+str(obj.valeur[keyN1]["HOMOGENEOUS"])+"\n"
             texte+="            ISOTROPIC "+str(obj.valeur[keyN1]["ISOTROPIC"])+"\n"
             # Ecriture des valeurs seulement pour un materiau homogene et isotrope,
             # car sinon ces valeurs sont definies dans des fichiers annexes
             homogeneous = str(obj.valeur[keyN1]["HOMOGENEOUS"]) == 'TRUE'
             isotropic = str(obj.valeur[keyN1]["ISOTROPIC"]) == 'TRUE'
             if homogeneous and isotropic:
                # loi (lineaire ou non)
                texte+="            LAW "+str(obj.valeur[keyN1]["LAW"])+"\n"
                # valeur de la loi lineaire
                texte+="            VALUE "+self.formateCOMPLEX(obj.valeur[keyN1]["VALUE"])+"\n"
                # loi non lineaire de nature spline, Marrocco ou Marrocco et Saturation
                #  seuls les reels sont pris en compte
                if obj.valeur[keyN1]['LAW']=='NONLINEAR' :
                   texte+="            [NONLINEAR \n"
                   texte+="                ISOTROPY TRUE\n"
                   texte+="                NATURE "+str(obj.valeur[keyN1]['NATURE'])+"\n"
                   # ajout des autres parametres autres que ISOTROPY, NATURE, VALUE, LAW, HOMOGENEOUS, ISOTROPIC
                   for keyN2 in obj.valeur[keyN1] :
                      if keyN2 not in ('ISOTROPY','NATURE','VALUE','LAW','HOMOGENEOUS','ISOTROPIC') :
                          texte+="                "+keyN2+" "+str(obj.valeur[keyN1][keyN2])+"\n"
                   # fin du sous-bloc NONLINEAR
                   texte+="            ]"+"\n"
             # fin du sous bloc de propriete
             texte+="         ]"+"\n"
       if self.debug: 
           print "texte = %s", texte
       self.dictMaterConductor[obj.getSdname()]={'texte':  texte,  'valeur': obj.valeur} # sauvegarde du texte pour ce bloc, ainsi que de toutes les valeurs pour analyse ultérieure

   def generMATERIAL_DIELECTRIC(self,obj):
        """preparation du sous bloc DIELECTRIC"""
        texte=""
        if self.debug: 
           print "______________nocond_____________"
           # verification des proprietes du sous bloc DIELECTRIC (PERMEABILITY, PERMITTIVITY)
        if 'PERMITTIVITY' not in obj.valeur:
            print "obj.valeur=%s" %obj.valeur
            obj.valeur["PERMITTIVITY"]={'HOMOGENEOUS': 'TRUE', 'LAW': 'LINEAR', 'ISOTROPIC': 'TRUE', 'VALUE': 1}
    
        # parcours des proprietes du sous bloc DIELECTRIC (PERMEABILITY, PERMITTIVITY)
        for keyN1 in ('PERMEABILITY','PERMITTIVITY') :
         # debut du sous bloc de propriete du DIELECTRIC
         texte+="         ["+keyN1+"\n"
         texte+="            HOMOGENEOUS "+str(obj.valeur[keyN1]["HOMOGENEOUS"])+"\n"
         texte+="            ISOTROPIC "+str(obj.valeur[keyN1]["ISOTROPIC"])+"\n"
         # Ecriture des valeurs seulement pour un materiau homogene et isotrope,
         # car sinon ces valeurs sont definies dans des fichiers annexes
         homogeneous = str(obj.valeur[keyN1]["HOMOGENEOUS"]) == 'TRUE'
         isotropic = str(obj.valeur[keyN1]["ISOTROPIC"]) == 'TRUE'
         if homogeneous and isotropic:
            # loi (lineaire ou non)
            texte+="            LAW "+str(obj.valeur[keyN1]["LAW"])+"\n"
            # valeur de la loi lineaire
            texte+="            VALUE "+self.formateCOMPLEX(obj.valeur[keyN1]["VALUE"])+"\n"   
            # loi non lineaire de nature spline, Marrocco ou Marrocco et Saturation
            #  seuls les reels sont pris en compte
            if obj.valeur[keyN1]['LAW']=='NONLINEAR' :
               texte+="            [NONLINEAR \n"
               texte+="                ISOTROPY TRUE\n"
               texte+="                NATURE "+str(obj.valeur[keyN1]['NATURE'])+"\n"
               # ajout des autres parametres autres que ISOTROPY, NATURE, VALUE, LAW, HOMOGENEOUS, ISOTROPIC
               for keyN2 in obj.valeur[keyN1] :
                  if keyN2 not in ('ISOTROPY','NATURE','VALUE','LAW','HOMOGENEOUS','ISOTROPIC') :
                      texte+="                "+keyN2+" "+str(obj.valeur[keyN1][keyN2])+"\n"
               # fin du sous-bloc NONLINEAR
               texte+="            ]"+"\n"
         # fin du sous bloc de propriete
         texte+="         ]"+"\n"
        if self.debug: 
           print "texte = %s" % texte
        self.dictMaterDielectric[obj.getSdname()]={'texte':  texte,  'valeur': obj.valeur} # sauvegarde du texte pour ce bloc, ainsi que de toutes les valeurs pour analyse ultérieure

   def generMATERIAL_ZSURFACIC(self,obj):
       """preparation du sous bloc ZSURFACIC"""
       texte=""
       if self.debug: 
           print "______________zsurf_____________"
       # verification des proprietes du sous bloc ZSURFACIC (PERMEABILITY, CONDUCTIVITY)
       if 'PERMEABILITY' not in obj.valeur or 'CONDUCTIVITY' not in obj.valeur:
            print "ERREUR! Le matériau impedance de surface (ZSURFACIC) de nom %s doit contenir les propriétés PERMEABILITY et CONDUCTIVITY." % obj.getSdname()
            raise ValueError, obj.getSdname() + tr(" : ce materiau impedance de surface (ZSURFACIC) doit contenir les proprietes PERMEABILITY et CONDUCTIVITY.")
       else:
          # parcours des proprietes du sous bloc ZSURFACIC (PERMEABILITY, CONDUCTIVITY)
          for keyN1 in obj.valeur :
             if keyN1=='TYPE': continue
             # print "type loi = ", obj.valeur[keyN1]['LAW']
             # debut du sous bloc de propriete du DIELECTRIC
             texte+="         ["+keyN1+"\n"
             texte+="            HOMOGENEOUS "+str(obj.valeur[keyN1]["HOMOGENEOUS"])+"\n"
             texte+="            ISOTROPIC "+str(obj.valeur[keyN1]["ISOTROPIC"])+"\n"
             # Ecriture des valeurs seulement pour un materiau homogene et isotrope,
             # car sinon ces valeurs sont definies dans des fichiers annexes
             homogeneous = str(obj.valeur[keyN1]["HOMOGENEOUS"]) == 'TRUE'
             isotropic = str(obj.valeur[keyN1]["ISOTROPIC"]) == 'TRUE'
             if homogeneous and isotropic:
                # loi (lineaire ou non)
                texte+="            LAW "+str(obj.valeur[keyN1]["LAW"])+"\n"
                # valeur de la loi lineaire
                texte+="            VALUE "+self.formateCOMPLEX(obj.valeur[keyN1]["VALUE"])+"\n"
             # fin du sous bloc de propriete
             texte+="         ]"+"\n"
       if self.debug: 
           print "texte = %s", texte
       self.dictMaterZsurfacic[obj.getSdname()]=texte # sauvegarde du texte pour ce bloc

   def generMATERIAL_EMISO(self,obj):
       """preparation du sous bloc EM_ISOTROPIC_FILES.
       Les fichiers sont indiques par le chemin absolu, i.e. le nom complet du JdC,
        ce qui permet de deplacer les dossiers contenant le modele complet puisque le JdC permet les chemins relatifs.
       """
       if "CONDUCTIVITY_File" in obj.valeur:
            texte ="        CONDUCTIVITY MED "+str(obj.valeur["CONDUCTIVITY_File"])+"\n"
       if "PERMEABILITY_File" in obj.valeur:
            texte+="        PERMEABILITY MED "+str(obj.valeur["PERMEABILITY_File"])+"\n"
       # Possibilite de forcer le chemin relatif (nom de fichier seulement) plutot que le chemin absolu par defaut
       #from os.path import basename
       #texte ="        CONDUCTIVITY MED "+basename(str(obj.valeur["CONDUCTIVITY_File"]))+"\n"
       #texte+="        PERMEABILITY MED "+basename(str(obj.valeur["PERMEABILITY_File"]))+"\n"
       #      print "obj get sdname= ", obj.getSdname()
       #   if obj.getSdname() in self.dictMaterEmIso.keys() :
       #    self.dictMaterEmIso[obj.getSdname()].append(texte) 
       # else :
       self.dictMaterEmIso[obj.getSdname()]=texte
  
   def generMATERIAL_EMANISO(self,obj):
        """preparation du sous bloc EM_ANISOTROPIC_FILES.
        Les fichiers sont indiques par le chemin absolu, i.e. le nom complet du JdC,
            ce qui permet de deplacer les dossiers contenant le modele complet puisque le JdC permet les chemins relatifs.
        """
        if "CONDUCTIVITY_File" in obj.valeur: 
            texte ="        CONDUCTIVITY MATER "+str(obj.valeur["CONDUCTIVITY_File"])+"\n"
        if "PERMEABILITY_File" in obj.valeur:
            texte+="        PERMEABILITY MATER "+str(obj.valeur["PERMEABILITY_File"])+"\n"
       #  print "obj get sdname= ", obj.getSdname()
       #  if obj.getSdname() in self.dictMaterEmAnIso.keys() :
       #    self.dictMaterEmAnIso[obj.getSdname()].append(texte) 
       #  else :
        self.dictMaterEmAnIso[obj.getSdname()]=texte
   
   def generMATERIAL_NILMAT(self,obj):
       """preparation du sous bloc NILMAT"""
       texte=""
       self.dictMaterNilmat[obj.getSdname()]=texte
   
   def generMATERIAL_ZINSULATOR(self,obj):
       """"preparation du sous bloc ZINSULATOR"""
       texte=""
       self.dictMaterZinsulator[obj.getSdname()]=texte

#-------------------------------------------------------------------

   def generSOURCE(self,obj):
        """preparation du bloc correspondant a une source du fichier PHYS"""
        if self.debug: 
            print "generation source obj valeur = %s" % obj.valeur
        texte=""
        try :
            # test de la presence des types de sources reconnus
            # commes ces sources sont des mot-cles facteurs, i.e. une cle de dictionnaire,
            # la source ne peut contenir au plus qu'un type de source.
            if "STRANDED_INDUCTOR" in obj.valeur:
               self.generSOURCE_STRANDED_INDUCTOR(obj)
            elif "HPORT" in obj.valeur:
               self.generSOURCE_HPORT(obj)
            elif "EPORT" in obj.valeur:
               self.generSOURCE_EPORT(obj)
            else:
               print "ERREUR! Une source du type STRANDED_INDUCTOR, HPORT ou EPORT est attendue."
        except ValueError, err:
            raise ValueError, str(err)

   def generSOURCE_STRANDED_INDUCTOR(self,obj):
        """preparation du sous bloc STRANDED_INDUCTOR"""
        texte=""
        sdict = obj.valeur['STRANDED_INDUCTOR'] # dictionnaire contenant les parametres de la source, outre la forme de la source
        try :
            texte+="        NTURNS %s\n" % str(sdict['NTURNS'])  
            self.nturns=sdict['NTURNS']
            # test de la presence d'une forme de source reconnue
            # commes ces formes sont des mot-cles facteurs, i.e. une cle de dictionnaire,
            # la source ne peut contenir au plus qu'un type de source.
            if "WAVEFORM_CONSTANT" in obj.valeur:
               wdict = obj.valeur['WAVEFORM_CONSTANT'] # dictionnaire contenant les parametres de la forme de la source
               if self.problem == HARMONIC:
                  texte+="        CURJ POLAR %s 0\n" % str(wdict['AMPLITUDE'])
            elif "WAVEFORM_SINUS" in obj.valeur:
               wdict = obj.valeur['WAVEFORM_SINUS'] # dictionnaire contenant les parametres de la forme de la source
               if self.problem == HARMONIC:
                  texte+="        CURJ POLAR %(ampli)s %(phase)s\n" \
                         % {'ampli': str(wdict['AMPLITUDE']), 'phase': str(wdict['PHASE'])}
            self.dictSourceStInd[obj.getSdname()]=texte
            if self.debug: 
                print texte
        except ValueError, err:
            raise ValueError, str(err)

   def generSOURCE_HPORT(self,obj):
        """preparation du sous bloc HPORT"""
        texte=""
        sdict = obj.valeur['HPORT'] # dictionnaire contenant les parametres de la source, outre la forme de la source
        nomPort = obj.getSdname()
        self.dictPort[nomPort] = {} 
        self.dictPort[nomPort]['HPORT']=str(sdict['TYPE'])
        try :
            texte+="        TYPE %s\n" % str(sdict['TYPE'])
            # test de la presence d'une forme de source reconnue
            # commes ces formes sont des mot-cles facteurs, i.e. une cle de dictionnaire,
            # la source ne peut contenir au plus qu'un type de source.
            if "WAVEFORM_CONSTANT" in obj.valeur:
               wdict = obj.valeur['WAVEFORM_CONSTANT'] # dictionnaire contenant les parametres de la forme de la source
               if self.problem == HARMONIC:
                  texte+="        AMP POLAR %s 0\n" % str(wdict['AMPLITUDE'])
            elif "WAVEFORM_SINUS" in obj.valeur:
               wdict = obj.valeur['WAVEFORM_SINUS'] # dictionnaire contenant les parametres de la forme de la source
               if self.problem == HARMONIC:
                  texte+="        AMP POLAR %(ampli)s %(phase)s\n" \
                         % {'ampli': str(wdict['AMPLITUDE']), 'phase': str(wdict['PHASE'])}
            self.dictSourceHport[obj.getSdname()]=texte
            if self.debug: 
                print texte
        except ValueError, err:
            raise ValueError, str(err)

   def generSOURCE_EPORT(self,obj):
       

        """preparation du sous bloc EPORT"""
        texte=""
        sdict = obj.valeur['EPORT'] # dictionnaire contenant les parametres de la source, outre la forme de la source
        nomPort = obj.getSdname()
        self.dictPort[nomPort] = {} 
        self.dictPort[nomPort]['EPORT']=str(sdict['TYPE'])
        print "sdict=%s" %(sdict)
        try :
            texte+="        TYPE %s\n" % str(sdict['TYPE'])
            # test de la presence d'une forme de source reconnue
            # commes ces formes sont des mot-cles facteurs, i.e. une cle de dictionnaire,
            # la source ne peut contenir au plus qu'un type de source.
            if "WAVEFORM_CONSTANT" in obj.valeur:
               wdict = obj.valeur['WAVEFORM_CONSTANT'] # dictionnaire contenant les parametres de la forme de la source
               if self.problem == HARMONIC:
                  texte+="        AMP POLAR %s 0\n" % str(wdict['AMPLITUDE'])
            elif "WAVEFORM_SINUS" in obj.valeur:
               wdict = obj.valeur['WAVEFORM_SINUS'] # dictionnaire contenant les parametres de la forme de la source
               if self.problem == HARMONIC:
                  texte+="        AMP POLAR %(ampli)s %(phase)s\n" \
                         % {'ampli': str(wdict['AMPLITUDE']), 'phase': str(wdict['PHASE'])}
            self.dictSourceEport[obj.getSdname()]=texte
            if self.debug: 
                print texte
        except ValueError, err:
            raise ValueError, str(err)
    
#      
   def generPARAM_CIRCULAIRE(self, obj):
        if self.debug: 
            print "generation stranded inductor geometry obj.valeur = %s" % obj.valeur     
        self.centre=obj.valeur["Centre"]  
          
   def generPOST_COMMANDS(self, obj):
        """Création du texte de commandes de post-traitement toto.cmd"""
        if self.debug: 
            print "generation POST_COMMANDS obj.valeur = %s" % obj.valeur     
            
        if obj.valeur.has_key('GLOBAL'):
            self.texteCarmel3D_CMD+="[\nGLOBAL\n]\n"
            
        if obj.valeur.has_key('DUMP'):
            champsFieldkind={'total':'TOTAL', 'reaction':'REACTION', 'diffracted':'DIFFRACTED'}
            self.texteCarmel3D_CMD+="[\nDUMP"
            self.texteCarmel3D_CMD+="\n"+self.projet +  '_postgroups.txt'
            self.texteCarmel3D_CMD+="\n"+champsFieldkind[obj.valeur["DUMP"]["fieldkind"]]+"\n]\n"
            
        if obj.valeur.has_key('FIELDDUMP'):
            champs = {'T':'TFIELD','H':'HFIELD', 'B':'BFIELD', 'J':'JFIELD', 'E':'EFIELD', 'pertesJoule':'OHMLOSS_DENSITY', 'champSource':'SOURCEFIELD', 'A':'AFIELD', 'Phi':'PHIFIELD', 'Omega':'OMEGAFIELD'}
            champsFieldkind={'total':'TOTAL', 'reaction':'REACTION', 'diffracted':'DIFFRACTED'}
            self.texteCarmel3D_CMD+="[\nFIELDDUMP"
            if type(obj.valeur["FIELDDUMP"]) == types.DictType: # correspondance sur une 'Fielddump'
                self.fielddumpValeur.append(obj.valeur["FIELDDUMP"]) 
            else:
                self.fielddumpValeur=obj.valeur["FIELDDUMP"] # correspondance sur plusieurs 'Fielddump'
            for indexFielddump in self.fielddumpValeur:
                self.texteCarmel3D_CMD+="\n  [\n" +"   "+ champs[indexFielddump["field"]]
                self.texteCarmel3D_CMD+="\n" + "   " + champsFieldkind[indexFielddump["fieldkind"]] + "\n  ]"
            self.texteCarmel3D_CMD+="\n]\n"    
            
        
        if obj.valeur.has_key('VISU'):
            self.texteCarmel3D_CMD+="[\nVISU"
            # test de fichier de maillage bien lu
            if self.fichierMaillage == "":  raise ValueError, tr("Le fichier de maillage n'existe pas. Le bloc PARAMETERS doit etre defini au-dessus du bloc POST_COMMANDS.")
            self.texteCarmel3D_CMD+="\n"+self.projet+"\n"
            self.texteCarmel3D_CMD+=obj.valeur["VISU"]["visu_format"]+"\n"
            self.texteCarmel3D_CMD+=obj.valeur["VISU"]["visu_type"]+"\n]\n"
    
        if obj.valeur.has_key('VISU3D'):
            champsField = {'T':'TFIELD','H':'HFIELD', 'B':'BFIELD', 'J':'JFIELD', 'E':'EFIELD', 'pertesJoule':'OHMLOSS_DENSITY', 'champSource':'SOURCEFIELD', 'A':'AFIELD', 'Phi':'PHIFIELD', 'Omega':'OMEGAFIELD'} # correspondance sur le nom du champ entre le catalogue (clé) et le fichier de configuration de Code_Carmel3D (valeur)
            champsFieldkind={'total':'TOTAL', 'reaction':'REACTION', 'diffracted':'DIFFRACTED'}
            if type(obj.valeur["VISU3D"])==types.DictType:  # correspondance sur une 'VISU3D'
                self.visu3dValeur.append(obj.valeur["VISU3D"])
            else:
                self.visu3dValeur=obj.valeur["VISU3D"] # correspondance sur plusieurs 'VISU3D'
            self.texteCarmel3D_CMD+="[\nVISU3D"
            if self.fichierMaillage == "":  raise ValueError, tr("Le fichier de maillage n'existe pas. Le bloc PARAMETERS doit etre defini au-dessus du bloc POST_COMMANDS.")
            self.texteCarmel3D_CMD+="\n"+ self.projet
            self.texteCarmel3D_CMD+="\n" + self.visu3dValeur[0]["visu_format"]
            for indexVisu3d in self.visu3dValeur:
                if indexVisu3d["visu_format"]!=self.visu3dValeur[0]["visu_format"]:
                    print "ERREUR! Dans les multiples VISU3D du bloc POST_COMMANDS, le parametre visu_format doit prendre la meme valeur."
                    raise ValueError, tr("Dans les multiples VISU3D du bloc POST_COMMANDS, le parametre visu_format doit prendre la meme valeur.")
                self.texteCarmel3D_CMD+="\n   [\n   " + champsField[indexVisu3d["field"]]
                self.texteCarmel3D_CMD+="\n   "+ champsFieldkind[indexVisu3d["fieldkind"]]
                self.texteCarmel3D_CMD+="\n   "+ indexVisu3d["visu_type"]+"\n   ]"
            self.texteCarmel3D_CMD+="\n]\n" 
            
        if obj.valeur.has_key('ASTER_RMS_LOSSES'):
              self.texteCarmel3D_CMD+="[\nASTER_RMS_LOSSES"  
              if self.fichierMaillage == "":  raise ValueError, tr("Le fichier de maillage n'existe pas. Le bloc PARAMETERS doit etre defini au-dessus du bloc POST_COMMANDS.")
              self.texteCarmel3D_CMD+="\n"+self.projet+"\n"  
              self.texteCarmel3D_CMD+= obj.valeur["ASTER_RMS_LOSSES"]["rms_losses_format"] +"\n]\n"
              
        if obj.valeur.has_key('CUTLINE'):
            # création du champ, renommé par rapport à l'interface
            champsField = {'H':'HFIELD', 'B':'BFIELD', 'J':'JFIELD', 'E':'EFIELD', 'pertesJoule':'OHMLOSS_DENSITY', 'champSource':'SOURCEFIELD', 'A':'AFIELD', 'Phi':'PHIFIELD', 'Omega':'OMEGAFIELD', 'T':'TFIELD'} # correspondance sur le nom du champ entre le catalogue (clé) et le fichier de configuration de Code_Carmel3D (valeur)
            champsFieldkind={'total':'TOTAL', 'reaction':'REACTION', 'diffracted':'DIFFRACTED'}
            champsOutput={'xgraphic':'XGRAPHIC', 'gnuplot':'GNUPLOT', 'gmsh':'GMSH'}
            champsLissage={'aucun':'NONE', 'un seul point par element':'1PTELT'}
            if type(obj.valeur["CUTLINE"]) == types.DictType: # correspondance sur une 'Cutline'
                self.cutlineValeur.append(obj.valeur["CUTLINE"])  # transfert d'une dictionnaire à une liste
            else:
                self.cutlineValeur=obj.valeur["CUTLINE"] # correspondance sur plusieurs 'Cutline'
            for indexCutline in self.cutlineValeur: 
                self.texteCarmel3D_CMD+="[\nCUTLINE"
                self.texteCarmel3D_CMD+="\n%s" % ' '.join(map(str,indexCutline["first_point"]), )
                self.texteCarmel3D_CMD+="\n%s" % ' '.join(map(str,indexCutline["last_point"]), )
                self.texteCarmel3D_CMD+="\n%d" % (indexCutline["number_of_points"], )
                self.texteCarmel3D_CMD+="\n" +indexCutline["name"]
                self.texteCarmel3D_CMD+="\n" + champsField[indexCutline["field"]]
                if indexCutline.has_key('fieldkind'):
                    self.texteCarmel3D_CMD+="\nFIELDKIND " + champsFieldkind[indexCutline["fieldkind"]]
                if indexCutline.has_key('output'):
                    self.texteCarmel3D_CMD+="\nOUTPUT " +champsOutput[indexCutline["output"]]
                if indexCutline.has_key('lissage'):
                    self.texteCarmel3D_CMD+="\nSMOOTHLEVEL " +champsLissage[indexCutline["lissage"]]
                self.texteCarmel3D_CMD+="\n]\n"
                
        if obj.valeur.has_key('CUTPLANE'):
            champs = {'T':'TFIELD','H':'HFIELD', 'B':'BFIELD', 'J':'JFIELD', 'E':'EFIELD','pertesJoule':'OHMLOSS_DENSITY', 'champSource':'SOURCEFIELD', 'A':'AFIELD', 'Phi':'PHIFIELD', 'Omega':'OMEGAFIELD'} # correspondance sur le nom du champ entre le catalogue (clé) et le fichier de configuration de Code_Carmel3D (valeur)
            champsFieldkind= {'total':'TOTAL', 'reaction':'REACTION', 'diffracted':'DIFFRACTED'}
            champsOutput={'xgraphic':'XGRAPHIC', 'gnuplot':'GNUPLOT', 'gmsh':'GMSH'}
            champsLissage={'aucun':'NONE', 'un seul point par element':'1PTELT'}
            axes = {'Ox':1, 'Oy':2, 'Oz':3} # correspondance de l'axe normal entre le catalogue (clé) et le fichier de configuration Code_Carmel3D (valeur)
            if type(obj.valeur["CUTPLANE"]) == types.DictType:
                self.cutplaneValeur.append(obj.valeur["CUTPLANE"]) # correspondance sur une 'Cutplane'
            else:
                self.cutplaneValeur=obj.valeur["CUTPLANE"] # correspondance sur plusieurs 'Cutplane'
            for indexCutplane in self.cutplaneValeur:
                self.texteCarmel3D_CMD+="[\nCUTPLANE" 
                self.texteCarmel3D_CMD+="\n%d" % (axes[indexCutplane["normal_vector"]], )
                self.texteCarmel3D_CMD+="\n%f" % (indexCutplane["plane_position"], )
                self.texteCarmel3D_CMD+="\n%s" % ' '.join(map(str,indexCutplane["number_of_points"]))
                self.texteCarmel3D_CMD+="\n" + indexCutplane["name"]
                self.texteCarmel3D_CMD+="\n" + champs[indexCutplane["field"]]
                if indexCutplane.has_key('fieldkind'):
                    self.texteCarmel3D_CMD+="\nFIELDKIND " + champsFieldkind[indexCutplane["fieldkind"]]
                if indexCutplane.has_key('output'):
                    self.texteCarmel3D_CMD+="\nOUTPUT " +champsOutput[indexCutplane["output"]]
                if indexCutplane.has_key('lissage'):
                    self.texteCarmel3D_CMD+="\nSMOOTHLEVEL " +champsLissage[indexCutplane["lissage"]]
                self.texteCarmel3D_CMD+="\n]\n"
                
        if obj.valeur.has_key('FIELDMAP'):
            champs = {'T':'TFIELD','H':'HFIELD', 'B':'BFIELD', 'J':'JFIELD', 'E':'EFIELD','pertesJoule':'OHMLOSS_DENSITY', 'champSource':'SOURCEFIELD', 'A':'AFIELD', 'Phi':'PHIFIELD', 'Omega':'OMEGAFIELD'} # correspondance sur le nom du champ entre le catalogue (clé) et le fichier de configuration de Code_Carmel3D (valeur)
            champsFieldkind= {'total':'TOTAL', 'reaction':'REACTION', 'diffracted':'DIFFRACTED'}
            champsOutput={'xgraphic':'XGRAPHIC', 'gnuplot':'GNUPLOT', 'gmsh':'GMSH'}
            champsFieldmap_type={'equation':'EQUATION', 'fichier':'FILE'}
            champsType={'plane':'PLANE', 'line':'LINE'}
            axes = {'Ox':1, 'Oy':2, 'Oz':3} # correspondance de l'axe normal entre le catalogue (clé) et le fichier de configuration Code_Carmel3D (valeur)
            if type(obj.valeur["FIELDMAP"]) == types.DictType: 
                self.fieldmapValeur.append(obj.valeur["FIELDMAP"]) # correspondance sur une 'Fieldmap'
            else:
                self.fieldmapValeur=obj.valeur["FIELDMAP"]# correspondance sur plusieurs 'Fieldmap'
            for indexFieldmap in self.fieldmapValeur:
                self.texteCarmel3D_CMD+="[\nFIELDMAP"
                self.texteCarmel3D_CMD+="\n" + champsFieldmap_type[indexFieldmap["fieldmap_type"]]
                if indexFieldmap["fieldmap_type"]=="equation":
                    self.texteCarmel3D_CMD+="\n" + champsType[indexFieldmap["type"]]
                    if indexFieldmap["type"]=="line":
                        self.texteCarmel3D_CMD+="\n%s" % ' '.join(map(str,indexFieldmap["first_point"]), )
                        self.texteCarmel3D_CMD+="\n%s" % ' '.join(map(str,indexFieldmap["last_point"]), )
                        self.texteCarmel3D_CMD+="\n%d" % (indexFieldmap["number_of_points"], )
                    if indexFieldmap["type"]=="plane":
                        self.texteCarmel3D_CMD+="\n%d" % (axes[indexFieldmap["normal_vector"]], )
                        self.texteCarmel3D_CMD+="\n%f" % (indexFieldmap["plane_position"], )
                        self.texteCarmel3D_CMD+="\n%s" % ' '.join(map(str,indexFieldmap["number_of_points"]))
                if indexFieldmap["fieldmap_type"]=="fichier":
                        self.fichierFieldmap=indexFieldmap["filename"]
                        self.nomFichierFieldmap = os.path.basename(self.fichierFieldmap) # nom du fichier de fieldmap, sans le chemin
                        self.texteCarmel3D_CMD+="\n" + self.nomFichierFieldmap
                self.texteCarmel3D_CMD+="\n" + champs[indexFieldmap["field"]]
                self.texteCarmel3D_CMD+="\n" + champsFieldkind[indexFieldmap["fieldkind"]]
                self.texteCarmel3D_CMD+="\n" +indexFieldmap["name"] # nom systématique, quel que soit le fieldmap_type, placé entre fieldkind et output
                self.texteCarmel3D_CMD+="\n" +champsOutput[indexFieldmap["output"]]
                self.texteCarmel3D_CMD+="\n]\n"
                        
                


#---------------------------------------------------------------------------------------
# traitement fichier PHYS
#---------------------------------------------------------------------------------------
   def generBLOC_VERSION(self,obj) :
      # constitution du bloc VERSION du fichier PHYS
      # creation d une entite  VERSION ; elle sera du type PROC car decrit ainsi
      # dans le du catalogue
      version=obj.addEntite('VERSION',pos=None)
      self.generPROC_ETAPE(obj.etapes[0])
      self.texteCarmel3D+="["+obj.etapes[0].nom+"\n"
      for cle in obj.etapes[0].valeur :
          self.texteCarmel3D+="   "+cle+" "+str(obj.etapes[0].valeur[cle])+"\n"
      self.texteCarmel3D+="]\n"
      # destruction de l entite creee 
      obj.suppEntite(version)
      #print 'ERREUR : test erreur boite graphique BLOC_VERSION'
      #raise ValueError, 'test erreur boite graphique BLOC_VERSION'


   def generBLOC_PARAMETERS(self,obj):
        if self.debug: 
            print "generation parameters obj.valeur = %s" % obj.valeur    

        self.frequency=obj.valeur["FREQUENCY"]
        self.repertory=obj.valeur["RepCarmel"]
        self.fichierMaillage=obj.valeur["Fichier_maillage"]
        self.nomFichierMaillage = os.path.basename(self.fichierMaillage) # nom du fichier de maillage, sans le chemin
        self.projet = self.nomFichierMaillage.split(".")[0] # nom du projet, utilisé un peu partout, équivalent au nom du fichier de maillage sans l'extension
        self.echelle=obj.valeur["Echelle_du_maillage"]
        self.gendof=obj.valeur["Realiser_topologie_gendof"]
        self.fcarmel=obj.valeur["Resoudre_probleme"]
        self.postprocess=obj.valeur["Realiser_post_traitement_aposteriori"]
        self.formulation=obj.valeur["Formulation"]
#----------------------------------------------------------------------------------------
   def generBLOC_MATERIALS(self) :
        """Prepare une partie du contenu du fichier de parametres (PHYS) pour le code Carmel3D (bloc MATERIALS).
        Le bloc MATERIALS existe toujours ! 
        """
        if self.debug:
            print "cle dictionnaire materconductor : %s" % self.dictMaterConductor.keys()
            print "cle dictionnaire materdielectric : %s" % self.dictMaterDielectric.keys()
        # constitution du bloc MATERIALS du fichier PHYS
        self.texteCarmel3D+="[MATERIALS\n"
        # tri alphabetique de tous les groupes de maillage associes a des sources (plus necessaire Code_Carmel3D V_2_3_1 et +, mais avant oui)
        nomsGroupes = self.dictGroupes['ordreMateriauxJdC'][:] # copie de l'original, qui est une liste
        nomsGroupes.sort() # tri alphabetique, avec les prefixes eventuels
        if self.debug:
            print "noms groupes de mailles associes a des materiaux \
                            (ordre JdC puis tri)= %(v_1)s %(v_2)s" % \
                            {'v_1': self.dictGroupes['ordreMateriauxJdC'], \
                             'v_2': nomsGroupes}
        try:  # mise à jour du fichier .phys selon les matériaux trouvés                  
            # constitution du bloc CONDUCTOR du fichier PHYS si existe
            if self.dictMaterConductor != {} : self.creaBLOC_CONDUCTOR(nomsGroupes)            
            # constitution du bloc DIELECTRIC du fichier PHYS si exixte
            if self.dictMaterDielectric != {} : self.creaBLOC_DIELECTRIC(nomsGroupes)            
            # constitution du bloc ZSURFACIC du fichier PHYS si exixte
            if self.dictMaterZsurfacic != {} : self.creaBLOC_ZSURFACIC(nomsGroupes)
            # constitution du bloc NILMAT du fichier PHYS si exixte
            if self.dictMaterNilmat != {} : self.creaBLOC_NILMAT(nomsGroupes)
            # constitution du bloc ZINSULATOR du fichier PHYS si exixte
            if self.dictMaterZinsulator != {} : self.creaBLOC_ZINSULATOR(nomsGroupes)
            # Les blocs EM_ISOTROPIC_FILES et EM_ANISOTROPIC_FILES sont places en dernier dans le fichier PHYS
            # constitution du bloc EM_ISOTROPIC_FILES du fichier PHYS si exixte
            if self.dictMaterEmIso != {} and self.materiauxGroupesTousIsotropes and not self.materiauxGroupesTousHomogenes : self.creaBLOC_EMISO() # bloc isotrope si au moins un matériau isotrope et non homogene
            # constitution du bloc EM_ANISOTROPIC_FILES du fichier PHYS si exixte
            if self.dictMaterEmAnIso != {} and not self.materiauxGroupesTousIsotropes : self.creaBLOC_EMANISO() # bloc non isotrope si au moins un matériau non isotrope
        except ValueError, err:
            raise ValueError(str(err))
            

        # fin du bloc MATERIALS du fichier PHYS
        self.texteCarmel3D+="]\n"  

       
       
   def creaBLOC_CONDUCTOR(self, nomsGroupes) :
        """Constitution du bloc CONDUCTOR du fichier PHYS"""
        typeBloc = 'CONDUCTOR' # initialisation du type de bloc
        dictProprietes = self.dictMaterConductor # initialisation du dictionnaire des proprietes du bloc
        if self.debug: 
            print 'cles materiaux de type %(type_bloc)s = %(cle_bloc)s' % {'type_bloc': typeBloc, 'cle_bloc': dictProprietes.keys()}
        for nom in nomsGroupes: # parcours des noms des groupes de maillage
            if self.dictGroupes[nom]['MATERIAL'][:]  in dictProprietes.keys(): # test si le nom du materiau associe est du bon type
                if dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]]['valeur']['PERMEABILITY']['LAW'] == 'NONLINEAR': # Erreur si ce matériau est non-linéaire
                    print u"ERREUR! Le matériau de nom %s associé au groupe %s doit avoir sa perméabilité (PERMEABILITY) linéaire (LINEAR) seulement." % (self.dictGroupes[nom]['MATERIAL'][:],  nom)
                    raise ValueError, self.dictGroupes[nom]['MATERIAL'][:] + ',' +  nom + tr(" : ce materiau (nom, groupe associe) doit avoir sa permeabilite (PERMEABILITY) lineaire (LINEAR) seulement.")
                if dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]]['valeur']['PERMEABILITY']['HOMOGENEOUS'] == 'FALSE' \
                 or dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]]['valeur']['CONDUCTIVITY']['HOMOGENEOUS'] == 'FALSE': # recherche si matériau non-homogène
                    self.materiauxGroupesTousHomogenes = False # alors tous les matériaux ne sont pas homogènes
                if dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]]['valeur']['PERMEABILITY']['ISOTROPIC'] == 'FALSE' \
                 or dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]]['valeur']['CONDUCTIVITY']['ISOTROPIC'] == 'FALSE': # recherche si matériau non-homogène
                    self.materiauxGroupesTousIsotropes = False # alors tous les matériaux ne sont pas isotropes
                # ecriture du bloc complet
                self.texteCarmel3D+="     ["+typeBloc+"\n" # debut de bloc
                if usePrefix:
                    nomReel = self.nomReelGroupe(nom, typeBloc)
                else:
                    nomReel = nom
                self.texteCarmel3D+="        NAME "+nomReel+"\n" # ecriture du nom (reel) du groupe du maillage
                self.texteCarmel3D+=  dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]]['texte'] # ecriture des proprietes du type associe
                self.texteCarmel3D+="     ]\n" # fin de bloc

   def creaBLOC_DIELECTRIC(self, nomsGroupes) :
        """Constitution du bloc DIELECTRIC du fichier PHYS"""
        typeBloc = 'DIELECTRIC' # initialisation du type de bloc
        dictProprietes = self.dictMaterDielectric # initialisation du dictionnaire des proprietes du bloc
        if self.debug: 
            print 'cles materiaux de type %(type_bloc)s=%(cle_bloc)s' % {'type_bloc': typeBloc, 'cle_bloc': dictProprietes.keys()}
        for nom in nomsGroupes: # parcours des noms des groupes de maillage
            print "jdc materiaux= %s" %(self.dictGroupes['ordreMateriauxJdC'])
            if self.dictGroupes[nom]['MATERIAL'][:] in dictProprietes.keys(): # test si le nom du materiau associe est du bon type
                if dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]]['valeur']['PERMEABILITY']['LAW'] == 'NONLINEAR': # Erreur si ce matériau est non-linéaire
                    print u"ERREUR! Le matériau de nom %s associé au groupe %s doit avoir sa perméabilité (PERMEABILITY) linéaire (LINEAR) seulement." % (self.dictGroupes[nom]['MATERIAL'][:],  nom)
                    raise ValueError, self.dictGroupes[nom]['MATERIAL'][:] + ',' +  nom + tr(" : ce materiau (nom, groupe associe) doit avoir sa permeabilite (PERMEABILITY) lineaire (LINEAR) seulement.")
                if dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]]['valeur']['PERMEABILITY']['HOMOGENEOUS'] == 'FALSE': # recherche si matériau non-homogène
                    self.materiauxGroupesTousHomogenes = False # alors tous les matériaux ne sont pas homogènes
                if dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]]['valeur']['PERMEABILITY']['ISOTROPIC'] == 'FALSE': # recherche si matériau non-homogène
                    self.materiauxGroupesTousIsotropes = False # alors tous les matériaux ne sont pas isotropes
                 # ecriture du bloc complet
                self.texteCarmel3D+="     ["+typeBloc+"\n" # debut de bloc
                self.texteCarmel3D+="        NAME "+nom+"\n" # ecriture du nom (reel) du groupe du maillage
                self.texteCarmel3D+=  dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]]['texte'] # ecriture des proprietes du type associe
                self.texteCarmel3D+="     ]\n" # fin de bloc
    
   def creaBLOC_ZSURFACIC(self, nomsGroupes) :
        """Constitution du bloc ZSURFACIC du fichier PHYS"""
        typeBloc = 'ZSURFACIC' # initialisation du type de bloc
        dictProprietes = self.dictMaterZsurfacic # initialisation du dictionnaire des proprietes du bloc
        if self.debug: 
            print 'cles materiaux de type %(type_bloc)s=%(cle_bloc)s' % {'type_bloc': typeBloc, 'cle_bloc': dictProprietes.keys()}
        for nom in nomsGroupes: # parcours des noms des groupes de maillage
            if self.dictGroupes[nom]['MATERIAL'][:]  in dictProprietes.keys(): # test si le nom du materiau associe est du bon type
                # ecriture du bloc complet
                self.texteCarmel3D+="     ["+typeBloc+"\n" # debut de bloc
                if usePrefix:
                    nomReel = self.nomReelGroupe(nom, typeBloc)
                else:
                    nomReel = nom
                self.texteCarmel3D+="        NAME "+nomReel+"\n" # ecriture du nom (reel) du groupe du maillage
                self.texteCarmel3D+=  dictProprietes[self.dictGroupes[nom]['MATERIAL'][:] ] # ecriture des proprietes du type associe
                self.texteCarmel3D+="     ]\n" # fin de bloc

   def creaBLOC_EMISO(self) :
        """constitution du bloc EM_ISOTROPIC_FILES du fichier PHYS"""
        for cle in self.dictMaterEmIso.keys():
            self.texteCarmel3D+="     [EM_ISOTROPIC_FILES\n"
            self.texteCarmel3D+= self.dictMaterEmIso[cle] 
            self.texteCarmel3D+="     ]\n"

   def creaBLOC_EMANISO(self) :
        """constitution du bloc EM_ANISOTROPIC_FILES du fichier PHYS"""
        for cle in self.dictMaterEmAnIso.keys():
            self.texteCarmel3D+="     [EM_ANISOTROPIC_FILES\n"
            self.texteCarmel3D+=  self.dictMaterEmAnIso[cle] 
            self.texteCarmel3D+="     ]\n"

   def creaBLOC_ZINSULATOR(self, nomsGroupes) :
        """Constitution du bloc ZINSULATOR du fichier PHYS"""
        typeBloc = 'ZINSULATOR' # initialisation du type de bloc
        dictProprietes = self.dictMaterZinsulator # initialisation du dictionnaire des proprietes du bloc
        if self.debug: print 'cles materiaux de type '+typeBloc+'=', dictProprietes.keys()
        for nom in nomsGroupes: # parcours des noms des groupes de maillage
            if self.dictGroupes[nom]['MATERIAL'][:]  in dictProprietes.keys(): # test si le nom du materiau associe est du bon type
                # ecriture du bloc complet
                self.texteCarmel3D+="     ["+typeBloc+"\n" # debut de bloc
                if usePrefix:
                    nomReel = self.nomReelGroupe(nom, typeBloc)
                else:
                    nomReel = nom
                self.texteCarmel3D+="        NAME "+nomReel+"\n" # ecriture du nom (reel) du groupe du maillage
                self.texteCarmel3D+=  dictProprietes[self.dictGroupes[nom]['MATERIAL'][:] ] # ecriture des proprietes du type associe
                self.texteCarmel3D+="     ]\n" # fin de bloc

   def creaBLOC_NILMAT(self, nomsGroupes) :
        """Constitution du bloc NILMAT du fichier PHYS"""
        typeBloc = 'NILMAT' # initialisation du type de bloc
        dictProprietes = self.dictMaterNilmat # initialisation du dictionnaire des proprietes du bloc
        if self.debug: 
            print 'cles materiaux de type %(type_bloc)s=%(cle_bloc)s' % {'type_bloc': typeBloc, 'cle_bloc': dictProprietes.keys()}
        for nom in nomsGroupes: # parcours des noms des groupes de maillage
            if self.dictGroupes[nom]['MATERIAL'][:]  in dictProprietes.keys(): # test si le nom du materiau associe est du bon type
                # ecriture du bloc complet
                self.texteCarmel3D+="     ["+typeBloc+"\n" # debut de bloc
                if usePrefix:
                    nomReel = self.nomReelGroupe(nom, typeBloc)
                else:
                    nomReel = nom
                self.texteCarmel3D+="        NAME "+nomReel+"\n" # ecriture du nom (reel) du groupe du maillage
                self.texteCarmel3D+=  dictProprietes[self.dictGroupes[nom]['MATERIAL'][:]] # ecriture des proprietes du type associe
                self.texteCarmel3D+="     ]\n" # fin de bloc

#----------------------------------------------------------------------------------------
   def generBLOC_SOURCES(self):
        """constitution du bloc SOURCES du fichier PHYS"""
        self.texteCarmel3D+="[SOURCES\n"
#        # tri alphabetique de tous les groupes de maillage associes a des sources
        nomsGroupes = self.dictGroupes['ordreSourcesJdC'][:] 
        nomsGroupes.sort() 
     #   print "RESULTAT APRES FUSION  self.dictGroupes= %s" %(self.dictGroupesnomsGroupes)
        
        if self.debug:
            print 'noms groupes de mailles associes a des sources \
                            (ordre JdC puis tri)=%(g_maillage_orig)s %(g_maillage_trie)s' % \
                            {'g_maillage_orig': self.dictGroupes['ordreSourcesJdC'], \
                             'g_maillage_trie': nomsGroupes}
        if self.dictSourceStInd != {}: self.creaBLOC_STRANDED_INDUCTOR(nomsGroupes)
        if self.dictSourceEport != {}: self.creaBLOC_EPORT(nomsGroupes)
        if self.dictSourceHport != {}: self.creaBLOC_HPORT(nomsGroupes)
        # fin du bloc SOURCES du fichier PHYS
        self.texteCarmel3D+="]\n"


   def creaBLOC_STRANDED_INDUCTOR(self, nomsGroupes) :
        """constitution du bloc STRANDED_INDUCTOR du fichier PHYS"""
        if self.debug: 
            print 'cles sources STRANDED_INDUCTOR= %s' % self.dictSourceStInd.keys()
        typeBloc = 'STRANDED_INDUCTOR'
#        print "liste des NOM=%s" %(nom)
        for nom in nomsGroupes: # parcours des noms des groupes de maillage
            if self.dictGroupes[nom]['SOURCE'][:]  in self.dictSourceStInd.keys(): # test si le nom de la source associee est un inducteur bobine
                # ecriture du bloc de l'inducteur bobine
                self.texteCarmel3D+="     [STRANDED_INDUCTOR\n" # debut de bloc
                self.texteCarmel3D+="        NAME "+nom+"\n" # ecriture du nom (reel) du groupe du maillage
                self.texteCarmel3D+=  self.dictSourceStInd[self.dictGroupes[nom]['SOURCE'][:] ] # ecriture des proprietes de l'inducteur bobine
                self.texteCarmel3D+="     ]\n" # fin de bloc

   def creaBLOC_EPORT(self, nomsGroupes) :
        """constitution du bloc EPORT du fichier PHYS"""
        if self.debug: 
            print 'cles sources EPORT= %s' % self.dictSourceEport.keys()
        typeBloc = 'EPORT'
        for nom in nomsGroupes: # parcours des noms des groupes de maillage
            if self.dictGroupes[nom]['SOURCE'][:]  in self.dictSourceEport.keys(): # test si le nom de la source associee est un port electrique
                # ecriture du bloc du port electrique
                self.texteCarmel3D+="     [EPORT\n" # debut de bloc
                if usePrefix:
                    nomReel = self.nomReelGroupe(nom, typeBloc)
                else:
                    nomReel = nom
                self.texteCarmel3D+="        NAME "+nomReel+"\n" # ecriture du nom (reel) du groupe du maillage
                self.texteCarmel3D+=  self.dictSourceEport[self.dictGroupes[nom]['SOURCE'][:] ] # ecriture des proprietes du port electrique
                self.texteCarmel3D+="     ]\n" # fin de bloc

   def creaBLOC_HPORT(self, nomsGroupes) :
        """constitution du bloc HPORT du fichier PHYS"""
        if self.debug: 
            print 'cles sources HPORT= %s' % self.dictSourceHport.keys()
        typeBloc = 'HPORT'
        for nom in nomsGroupes: # parcours des noms des groupes de maillage
            if self.dictGroupes[nom]['SOURCE'][:] in self.dictSourceHport.keys(): # test si le nom de la source associee est un port magnetique
                # ecriture du bloc du port magnetique
                self.texteCarmel3D+="     [HPORT\n" # debut de bloc
                if usePrefix:
                    nomReel = self.nomReelGroupe(nom, typeBloc)
                else:
                    nomReel = nom
                self.texteCarmel3D+="        NAME "+nomReel+"\n" # ecriture du nom (reel) du groupe du maillage
                self.texteCarmel3D+=  self.dictSourceHport[self.dictGroupes[nom]['SOURCE'][:]] # ecriture des proprietes du port magnetique
                self.texteCarmel3D+="     ]\n" # fin de bloc
                
   def generSTRANDED_INDUCTOR_GEOMETRY(self, obj):
        """preparation du bloc STRANDED_INDUCTOR_GEOMETRY"""

        texte=""
        self.direction=obj.valeur["Direction"]
        self.section=obj.valeur["Section"]
        self.forme=obj.valeur["Forme"]
#        texte+="\n%s" %(self.domaine)

        if self.forme=="Circulaire" : self.generCIRCULAR_STRANDED_INDUCTOR_GEOMETRY(obj)
        else: 
            texte+="\n1"
            texte+="\n%s" % ' '.join(map(str, self.direction))
            texte+="\n%g" % (self.section)
            self.dictStrand[obj.getSdname()]=texte  
        if self.debug: 
            print texte 

   def generCIRCULAR_STRANDED_INDUCTOR_GEOMETRY(self, obj):
            texte=""
            self.centre=obj.valeur["Centre"]
            texte+="\n2"
            texte+="\n%s" % ' '.join(map(str,self.direction))
            texte+="\n%s" % ' '.join(map(str, self.centre))
            texte+="\n%g" % (self.section)
            self.dictStrand[obj.getSdname()]=texte  
            if self.debug: 
                print texte


   def creaBLOC_STRANDED_INDUCTOR_GEOMETRY(self, nomsGroupes):  
        """Ecriture de chaque inducteur bobiné dans le in.gendof. Gestion des inducteurs en un ou plusieurs morceaux, avec le domaine.
        Attention! L'argument nomSGroupes n'est pas utile ici. A supprimer. Routine à renommer aussi.
        """
        if self.debug: 
            print 'dictGroupes=', self.dictGroupes
            print 'cles sources STRANDED_INDUCTOR_GEOMETRY= %s' % self.dictStrand.keys()
            print "nomsGroupes=%s" %(nomsGroupes)
        nomsSources=self.dictGroupes['ordreDomaineJdC']
        nomsSources.sort() # tri alphabétique des inducteurs, réclamé par gendof.exe
        if self.debug: print"nomsSources=%s" %nomsSources
        for nom in nomsSources:  
            if self.debug: print "nomSource courant=",nom
            if self.dictGroupes[nom].has_key('SOURCE'):
                if self.dictGroupes[nom]['SOURCE'] not in self.dictPort :
                    if not self.dictGroupes[nom].has_key('DOMAINE'): raise ValueError, nom + tr(" : il manque un Domaine a cet inducteur.")
                    self.texteCarmel3D_INGEND2+="\n%s" %(self.dictGroupes[nom]['DOMAINE']) # écriture du nom de domaine
            else:
                    if not self.dictGroupes[nom].has_key('DOMAINE'): raise ValueError,  nom + tr(" : il manque un Domaine a cet inducteur.")
                    self.texteCarmel3D_INGEND2+="\n%s" %(self.dictGroupes[nom]['DOMAINE']) # écriture du nom de domaine                
            if self.dictGroupes[nom].has_key('STRAND'): # inducteur en un seul morceau
                if not self.dictGroupes[nom].has_key('DOMAINE'): raise ValueError,  nom + tr(" : il manque un Domaine a cet inducteur.")
                strand = self.dictGroupes[nom]['STRAND'] 
                if self.debug: print "un seul morceau : nomStrand courant=", strand
                self.texteCarmel3D_INGEND2+=  self.dictStrand[strand]
            if self.dictGroupes[nom].has_key('LISTE'): # inducteur en plusieurs morceaux
                listeStrand = self.dictGroupes[nom]['LISTE'] # liste des groupes de maillage composant l'inducteur, ou groupe tout seul si inducteur en un seul morceau
                for strand in listeStrand: 
                    #strand = strand.replace("'", "") # suppression des guillemets simples
                    if self.debug: print "plusieurs morceaux : nomStrand courant=",strand
                    if self.debug: print "self.dictGroupes[strand]=", self.dictGroupes[strand]
                    self.texteCarmel3D_INGEND2+=  self.dictStrand[self.dictGroupes[strand]['STRAND'] ]
                                                                    
   def creaBLOC_PORTS_GEOMETRY(self, nomsGroupes):  
        if self.debug:
           print "self.dictSourceEport=",  self.dictSourceEport
           print "self.dictSourceHport=",  self.dictSourceHport
        nomsSources=self.dictGroupes['ordreDomaineJdC']
        nomsSources.sort() # tri alphabétique des inducteurs, réclamé par gendof.exe

        for nom in nomsSources: 
            port=self.dictGroupes[nom]['SOURCE']
            if self.dictGroupes[nom]['SOURCE'] in self.dictPort :
                self.texteCarmel3D_INGEND2+="\n%s" %(self.dictGroupes[nom]['DOMAINE']) # écriture du nom de domaine
                port=self.dictGroupes[nom]['SOURCE']

                if self.dictPort[port].has_key('EPORT'):# inducteur en un seul morceau   
                    if self.dictPort[port]['EPORT']=="VOLTAGE":
                        self.texteCarmel3D_INGEND2+= "\n1"
                    else:
                        self.texteCarmel3D_INGEND2+= "\n2"
                if self.dictPort[port].has_key('HPORT'):# inducteur en un seul morceau   
                    if self.dictPort[port]['HPORT']=="VOLTAGE":
                        self.texteCarmel3D_INGEND2+= "\n1"
                    else:
                        self.texteCarmel3D_INGEND2+= "\n2"  

#-------------------------------------
# Methodes utilitaires
# ------------------------------------
   def formateCOMPLEX(self,nbC):
        """prise en compte des differentes formes de description d un nombre complexe
        3 formats possibles : 2 listes (anciennement tuples?)  et 1 nombre complexe
        """
        if self.debug:
            print "formatage"
            print "type : %(type_nb_c)s pour %(nb_c)s" % {'type_nb_c': type(nbC), 'nb_c': nbC}
        nbformate =""
        if isinstance(nbC,(tuple,list)):
            if nbC[0] == "'RI'" :
                nbformate = "COMPLEX " + str(nbC[1])+" "+str(nbC[2])            
            if nbC[0] == "'MP'" :
                nbformate = "POLAR " + str(nbC[1])+" "+str(nbC[2])            
        else:
            nbformate = "COMPLEX " + str(nbC.real)+" "+str(nbC.imag)
        if self.debug: 
            print "nbformate : %s" % nbformate
        return nbformate
   
   def nomReelGroupe(self, nom, typeBloc=None):
        """Calcule et retourne le nom reel du groupe de maillage donne en entree,
        en tenant compte de l'utilisation de prefixes ou pas, et cela pour le type
        de bloc du fichier PHYS specifie.
        Cette routine verifie aussi, en cas d'utilisation de prefixes, si le prefixe est en adequation avec le type du bloc.
        """
        from string import join
        if self.debug: 
            print "nom groupe original : %(nom)s avec usePrefix=%(use_prefix)s devient...", \
                            {'nom': nom, 'use_prefix': str(usePrefix)}
        nomReel= None # nom affiche dans le fichier PHYS, sans prefixe a priori
        if usePrefix:
            # suppression du prefixe si present
            partiesNom = nom.split(sepNomGroupeMaille) # separation du nom du groupe en parties
            # les tests suivants ne generent une erreur que si le prefixe est obligatoire
            if len(partiesNom) < 2: # test d'erreur, pas de separateur donc nom incorrect, i.e. sans prefixe c'est sur
                print "ERREUR! ce groupe de maille (%s) n'a pas de prefixe \
                                indiquant le type de materiau ou de source associee" % (nom, )
            elif partiesNom[0] not in listePrefixesGroupeMaille: # prefixe non defini
                print "ERREUR! ce groupe de maille (%s) n'a pas de prefixe valable" %  (nom, )
            else:   
                # verification de l'adequation du prefixe avec le type de bloc demande, si fourni    
                if typeBloc is not None:
                    if typeBloc not in dictPrefixesGroupeMaille: # test validite de typeBloc, devant etre une cle du dictionnaire
                        print "ERREUR! ce type de bloc (%s) n'est pas valable" % (str(typeBloc), )
                    elif partiesNom[0] not in dictPrefixesGroupeMaille[typeBloc]: # pas de prefixe correct pour ce type de bloc
                        print "ERREUR! ce groupe de maille (%(nom)s) n'a pas \
                                        le prefixe correct pour etre associe a un type %(type_bloc)s", \
                                         {'nom': nom, 'type_bloc': str(typeBloc)}
                    else: # c'est bon
                        nomReel = join(partiesNom[1:], sepNomGroupeMaille) # reconstruction du nom du groupe sans prefixe complet
                        if self.debug: 
                            print "ce groupe de maille (%(nom)s) a un prefixe qui \
                                            est supprime automatiquement pour devenir : %(nom_reel)s", \
                                            {'nom': nom, 'nom_reel': nomReel}
                else: # c'est bon
                    nomReel = join(partiesNom[1:], sepNomGroupeMaille) # reconstruction du nom du groupe sans prefixe complet
                    if self.debug: 
                        print "ce groupe de maille (%(nom)s) a un prefixe qui \
                                        est supprime automatiquement pour devenir : %(nom_reel)s", \
                                        {'nom': nom, 'nom_reel': nomReel}
        if self.debug: 
            print "... %s", nomReel
        return nomReel
