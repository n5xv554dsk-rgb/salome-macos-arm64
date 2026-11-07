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

import xml.etree.cElementTree as ET
import traceback
import types,string,re,os
from Accas.extensions.eficas_translation import tr
from generator_python import PythonGenerator

# types de problemes
HARMONIC = 'HARMONIC' # probleme frequentiel
TIME_DOMAIN = 'TIME_DOMAIN' # probleme temporel

# nom du plugin, utilisé dans entryPoint et generMACRO_ETAPE()
nomPlugin = 'CARMEL3DTV0'

def entryPoint():
   """
      Retourne les informations necessaires pour le chargeur de plugins
      Ces informations sont retournees dans un dictionnaire
   """
   return {
        # Le nom du plugin
          'name' : nomPlugin,
        # La factory pour creer une instance du plugin
          'factory' : CARMEL3DTV0Generator,
          }



class CARMEL3DTV0Generator(PythonGenerator):
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

           except ValueError, err:
             raise ValueError(str(err))

      return self.text




#----------------------------------------------------------------------------------------
# initialisations
#----------------------------------------------------------------------------------------

   def initDico(self) :
      self.texteCarmel3D=""
      self.texteCarmel3D_SH=""      
      self.debug = True # affichage de messages pour deboguage (.true.) ou non
      self.dicoEtapeCourant=None
      self.dicoMCFACTCourant=None
      self.dicoCourant=None
      self.dictGroupes = {} # association des noms de groupes de maillage avec les noms de materiaux ou de sources, en sauvegardant l'ordre du JdC en separant les groupes associes a des materiaux de ceux associes a des sources
      self.dictMacroGroupes = {} # macro-groupe et leurs propriétés
      self.listSymetrie=[]   
      self.dictMouvement= {'ordre':[]} # dictionnaire contenant les mouvements, avec liste incluse pour l'ordre
      self.nombreMouvements = 0 # nombre de mouvements définis, servant de compteur aussi
      self.dictMaterial={}
      self.dictSource={}
      self.dictStrand={}
      self.dictGroupeMilieux={"ordreSource":[], "ordreId":[]}
      self.dictDomaine={}
      # Parametre du maillage
      self.identification = ""
      self.fichierMaillage = ""
      self.echelleMaillage = ""
      # Parametre de Precision      
      self.precond=""  
      self.precisionLineaire=""
      self.kEpsilonDistance=""
      self.kdistanceRef=""  
      self.nbIterationMax=""
      self.methodeNonLineaire = ""
      self.kEpsilonNonLinearite=""
      self.kCoefficientRelaxation=""
      self.jauge=""
      self.NBoucleTemps=""
      self.dt=""
      # Paramètres divers
      self.typeSolveur = "" # type de solveur, linéaire (Solveur_lineaire) ou non-linéaire (Solveur_non_lineaire)
      #Post traitement
      self.carteChamp="" # liste des pas de temps demandés lors du post-traitement des cartes de champ
      self.carteCourantInduit="" # liste des pas de temps demandés lors du post-traitement des cartes de courants induits
      self.carteForce="" # liste des pas de temps demandés lors du post-traitement des cartes de force
      self.post_global = [] # liste des grandeurs globales demandées lors du post-traitement

      # on force le probleme a etre frequentiel, seul possible en l'etat des choses
      self.problem = HARMONIC

   def indent(self, elem, level=0, more_sibs=False, espace=4*' '):
        """Transformation du XML créé par le module interne xml.etree.ElementTree afin d'écrire les indentations et retours à la ligne corrects.
        D'après un script original de Fredrik Lundh en 2004 (http://effbot.org/zone/element-lib.htm#prettyprint),
        modifié par Joshua Richardson en 2012 (http://stackoverflow.com/questions/749796/pretty-printing-xml-in-python)
        et par Loic Chevallier en 2014 (ajout du reglage de l'indentation).
        L'indentation est de 4 espaces par défaut (cf. argument optionel : espace)
        Utilisation : self.indent(root), avant écriture dans un fichier de root = ET.Element("configuration") ou de tree = ET.ElementTree(root)
        où ET = xml.etree.ElementTree
        """
        i = "\n"
        if level:
            i += (level-1) * espace
        num_kids = len(elem)
        if num_kids:
            if not elem.text or not elem.text.strip():
                elem.text = i + espace
                if level:
                    elem.text += espace
            count = 0
            for kid in elem:
                self.indent(kid, level+1, count < num_kids - 1)
                count += 1
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
                if more_sibs:
                    elem.tail += espace
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = i
                if more_sibs:
                    elem.tail += espace

#----------------------------------------------------------------------------------------
# ecriture
#----------------------------------------------------------------------------------------

   def writeDefault(self,fn) :
        """Ecrit les fichiers de parametres et le fichier d'execution pour le code Carmel3D"""

        file =  fn[:fn.rfind(".")]  # emplacement du ficher .comm (chemin complet)
        namefile=os.path.basename(file) # nom du fichier.comm 
        repertory=os.path.dirname(file) # répertoire contenant le fichier .comm (emplacement absolu)

        # correspondances globales
        correspondance_booleen = {'oui':'true', 'non':'false'}
        
        fileXML = os.path.join(repertory, 'configuration.xml') # nom du fichier de configuration XML (chemin complet)
        if self.debug: 
            print "\necriture du fichier XML : ", fileXML
            print "self.dictMaterial = ",self.dictMaterial
            print "self.dictSource = ",self.dictSource
            print "self.dictGroupes = ",self.dictGroupes
            print "self.dictMacroGroupes = ",self.dictMacroGroupes

        root = ET.Element("configuration")

        #Bloc <Maillage></Maillage>    
        Maillage = ET.SubElement(root, "Maillage")
        identification = ET.SubElement(Maillage, "identification")
        identification.text = self.identification
        fichierMaillage = ET.SubElement(Maillage, "fichierMaillage")
        fichierMaillage.text = self.fichierMaillage
        echelleMaillage = ET.SubElement(Maillage, "echelleMaillage")
        correspondance_echelleMaillage = {"Metre":1.0, "Millimetre":1.0e-3}
        echelleMaillage.text = "%f" % (correspondance_echelleMaillage[self.echelleMaillage], )

        #Bloc <ParametrePrecision></ParametrePrecision>    
        ParametrePrecision = ET.SubElement(root, "ParametrePrecision")
        TypeSolveurLineaire = ET.SubElement(ParametrePrecision, "TypeSolveurLineaire")
        if self.precond=="Crout":
            TypeSolveurLineaire.text = "1" 
        if self.precond=="Jacobi":
            TypeSolveurLineaire.text = "2" 
        if self.precond=="MUMPS":
            TypeSolveurLineaire.text = "3"
        kEpsilonGCP = ET.SubElement(ParametrePrecision, "kEpsilonGCP")
        kEpsilonGCP.text = "%s" %(self.kEpsilonGCP)
        nbIterationMax = ET.SubElement(ParametrePrecision, "nbIterationMax")
        nbIterationMax.text = "%s" %(self.nbIterationMax)        
        if self.typeSolveur == 'Solveur_non_lineaire': # écriture des paramètres du solveur non-linéaire seulement si défini dans l'étude
            methodeNonLineaire = ET.SubElement(ParametrePrecision, "methodeNonLineaire")
            methodeNonLineaire.text = "%s" %(self.methodeNonLineaire)
            kEpsilonNonLinearite = ET.SubElement(ParametrePrecision, "kEpsilonNonLinearite")        
            kEpsilonNonLinearite.text = "%s" %(self.kEpsilonNonLinearite)
            kCoefficientRelaxation = ET.SubElement(ParametrePrecision, "kCoefficientRelaxation")
            kCoefficientRelaxation.text = "%s" %(self.kCoefficientRelaxation)
        kEpsilonDistance = ET.SubElement(ParametrePrecision, "kEpsilonDistance")
        kEpsilonDistance.text = "%s" %(self.kEpsilonDistance)
        kdistanceRef = ET.SubElement(ParametrePrecision, "kdistanceRef")
        kdistanceRef.text = "%s" %(self.kdistanceRef)
        jauge = ET.SubElement(ParametrePrecision, "jauge")
        jauge.text = "%s" %(correspondance_booleen[self.jauge], )
        NBoucleTemps = ET.SubElement(ParametrePrecision, "NBoucleTemps")
        NBoucleTemps.text = "%s" %(self.NBoucleTemps)  
        dt = ET.SubElement(ParametrePrecision, "dt")
        dt.text = "%s" %(self.dt)

        #Bloc <Milieux></Milieux>
        i=0
        j=0
        p=0
        k=0
        listeMilieux = [] # liste des milieux,  dans l'ordre de création
        Milieux=ET.SubElement(root, "Milieux") # création du bloc <Milieux>...</Milieux>
        for nom in self.dictGroupes:  # on parcoure tous les groupes MESHGROUP
            if self.dictGroupes[nom].has_key('MATERIAL') \
                or self.dictGroupes[nom].has_key('SOURCE') \
                or self.dictGroupes[nom].has_key('AIMANT') \
                or self.dictGroupes[nom].has_key('STRANDED_INDUCTOR_GEOMETRY') : # si MESHGROUP ou MACRO_GROUPE associé à au moins un matériau, source ou géométrie d'inducteur bobiné, c'est un milieu
                milieu=ET.SubElement(Milieux,"milieu" ) # création d'un nouveau milieu
                listeMilieux.append(nom) # mise à jour de la liste des milieux
                i = i+1 # incrément du  numéro de milieu
                self.dictGroupes[nom]['idMilieu'] = i # affectation de l'id à ce groupe
                milieu.set("id", "%g" % (i, ) ) # ajout de l'attribut id, inutilisé
                milieu.set("name", "%s" % (nom, ) ) # ajout de l'attribut name, inutilisé         
                nomGroupeMaillage = ET.SubElement(milieu, "nomGroupeMaillage") # nom du groupe de maillage
                nomGroupeMaillage.text = nom
                if self.dictGroupes[nom].has_key('MATERIAL'): # matériau trouvé pour ce milieu
                    material = self.dictGroupes[nom]['MATERIAL'] # on récupère le nom de la propriété du matériau, clé de self.dictMaterial
                    permeabiliteLineaire=ET.SubElement(milieu, "permeabiliteLineaire")
                    permeabiliteLineaire.text="%s"%(self.dictMaterial[material]["PERMEABILITY"]["VALUE"])
                    if self.dictMaterial[material]["PERMEABILITY"]["LAW"]=="NONLINEAR":
                        coefficientsMarrocco=ET.SubElement(milieu, "coefficientsMarrocco")
                        epsilon = self.dictMaterial[material]["PERMEABILITY"]["EPSILON"]
                        c = self.dictMaterial[material]["PERMEABILITY"]["C"]
                        alpha = self.dictMaterial[material]["PERMEABILITY"]["ALPHA"]
                        tau = self.dictMaterial[material]["PERMEABILITY"]["TAU"]
                        coefficientsMarrocco.text = '%g, %g, %g, %g' % (epsilon,  c,  alpha,  tau)
                    if self.dictMaterial[material].has_key('CONDUCTIVITY'):
                        conductivite=ET.SubElement(milieu, "conductivite")
                        conductivite.text="%s" %(self.dictMaterial[material]["CONDUCTIVITY"]["VALUE"])
                    if self.dictMaterial[material].has_key('AIMANT'):
                        norme=ET.SubElement(milieu, "norme")
                        norme.text="%s" %(self.dictMaterial[material]["AIMANT"]["VALUE"])
                if self.dictGroupes[nom].has_key('STRANDED_INDUCTOR_GEOMETRY'): # géométrie d'inducteur bobiné trouvée pour ce milieu
                    strand=self.dictGroupes[nom]['STRANDED_INDUCTOR_GEOMETRY'] # on récupère le nom de la géométrie d'inducteur bobiné, clé de self.dictStrand
                    axe = ET.SubElement(milieu, "axe")
                    axe.text= "%s" % ','.join(map(str,self.dictStrand[strand]["Direction"]))
                    if self.dictStrand[strand]["Forme"]=="Circulaire":
                        coordonneesPolaires=ET.SubElement(milieu, "coordonneesPolaires")
                        coordonneesPolaires.text="true"                        
                        origineReperePolaire=ET.SubElement(milieu, "origineReperePolaire")
                        origineReperePolaire.text= "%s" % ','.join(map(str,self.dictStrand[strand]["Centre"]))
                    section=ET.SubElement(milieu, "section")
                    section.text="%g" %(self.dictStrand[strand]["Section"], )
                if self.dictGroupes[nom].has_key('SOURCE'): # source trouvée pour ce milieu
                        Source = self.dictGroupes[nom]['SOURCE'] # on récupère le nom de la source, clé de self.dictSource
                        self.dictSource[Source]['milieux'].append(nom) # ajout du nom du groupe à cette source
                        if self.dictSource[Source].has_key('STRANDED_INDUCTOR'):
                            nbSpires=ET.SubElement(milieu, "nbSpires")
                            nbSpires.text="%g" %(self.dictSource[Source]["STRANDED_INDUCTOR"]["NTURNS"])
                    
        #Bloc <ConditionsLimitesChamps>...</ConditionsLimitesChamps>
        ConditionsLimitesChamps = ET.SubElement(root, "ConditionsLimitesChamps")
        for nomCondition in self.dictGroupes:
            if self.dictGroupes[nomCondition].has_key('CONDITION_LIMITE'): # condition aux limites associée à ce groupe, hors symétrie et mouvement
                if self.dictGroupes[nomCondition].has_key('LISTE'): # MACRO_GROUPE
                    for i in range(len(self.dictGroupes[nomCondition]['LISTE'])):
                        conditionLimite = ET.SubElement(ConditionsLimitesChamps, "conditionLimitesChamps")
                        Type=ET.SubElement(conditionLimite,"type" )
                        Type.text=self.dictGroupes[nomCondition]["CONDITION_LIMITE"]
                        GroupeNoeud=ET.SubElement(conditionLimite, "groupeNoeud")
                        GroupeNoeud.text="%s" %(self.dictGroupes[nomCondition]['LISTE'][i])                       
                else: # MESHGROUP
                        conditionLimite = ET.SubElement(ConditionsLimitesChamps, "conditionLimitesChamps")
                        Type=ET.SubElement(conditionLimite,"type" )
                        Type.text=self.dictGroupes[nomCondition]["CONDITION_LIMITE"]
                        GroupeNoeud=ET.SubElement(conditionLimite, "groupeNoeud")
                        GroupeNoeud.text="%s" %(nomCondition)                          
                
        for i in range(len(self.listSymetrie)): # symétries, définies dans le bloc des conditions aux limites
            conditionLimite = ET.SubElement(ConditionsLimitesChamps, "conditionLimitesChamp")
            Type=ET.SubElement(conditionLimite,"type" )
            Type.text="%s" %(self.listSymetrie[i]["Type"])
            GroupeNoeud=ET.SubElement(conditionLimite, "groupeNoeud")
            GroupeNoeud.text="%s" %(self.listSymetrie[i]["Face1"]) 
            if 'Face2' in self.listSymetrie[i] :
                GroupeNoeud2=ET.SubElement(conditionLimite, "groupeNoeud2")
                GroupeNoeud2.text="%s" %(self.listSymetrie[i]["Face2"])                
            if 'Mouvement_associe' in self.listSymetrie[i]:    
                    MouvementAssocie=ET.SubElement(conditionLimite, "mouvementAssocie")
                    nomMouvementAssocie = self.listSymetrie[i]['Mouvement_associe'].nom # on récupère le nom du mouvement associé, car on a stocké le concept tout entier
                    MouvementAssocie.text="%i"%(self.dictMouvement[nomMouvementAssocie]['ordre'], )
            if 'Groupe_Points' in self.listSymetrie[i] :
                    GroupePoints=ET.SubElement(conditionLimite, "groupePoints")
                    GroupePoints.text="%s" %(self.listSymetrie[i]['Groupe_Points'])

        #Bloc <TermeSourceElectrique>...</TermeSourceElectrique>
        TermeSourceElectrique=ET.SubElement(root, "TermeSourceElectrique")
        i=0 # ?
        if self.debug: print 'self.dictSource = ',  self.dictSource
        for source in self.dictSource.keys(): # parcours des sources
            if len(self.dictSource[source]['milieux']) > 0: # on continue si au moins un groupe de maillage, i.e., milieux est associé à cette source
                if self.dictSource[source].has_key('STRANDED_INDUCTOR'): # inducteur bobiné
                    inducteur=ET.SubElement(TermeSourceElectrique, "inducteur")
                    listeMilieux=ET.SubElement(inducteur, "listeMilieux") # création de la liste des milieux
                    idListeMilieux = [] # indices des milieux concernés
                    for milieu in self.dictSource[source]['milieux']: # construction de la liste des milieux
                        idListeMilieux.append(self.dictGroupes[milieu]['idMilieu'])
                    listeMilieux.text = "%s" % ','.join(map(str,idListeMilieux))
                    if self.dictSource[source]["STRANDED_INDUCTOR"]["TYPE"]=="CURRENT": # source de type courant imposé
                        couplageTension=ET.SubElement(inducteur, "couplageTension")
                        couplageTension.text = "false"
                        courant=ET.SubElement(inducteur, "courant")
                        if self.dictSource[source]["Signal"]=="WAVEFORM_CONSTANT":
                            courant.text="%g" %(self.dictSource[source]["WAVEFORM_CONSTANT"]["AMPLITUDE"])
                        if self.dictSource[source]["Signal"]=="WAVEFORM_SINUS": # écriture des 3 paramètres avec attribut spécial
                            amplitude = self.dictSource[source]["WAVEFORM_SINUS"]["AMPLITUDE"]
                            frequence = self.dictSource[source]["WAVEFORM_SINUS"]["FREQUENCY"]
                            phase = self.dictSource[source]["WAVEFORM_SINUS"]["PHASE"]
                            courant.text="%g, %g, %g" % (amplitude,  frequence,  phase)
                            courant.set('forme', 'sinus') # attribut forme="sinus"
                    if self.dictSource[source]["STRANDED_INDUCTOR"]["TYPE"]=="VOLTAGE": # source de type tension imposée
                        couplageTension=ET.SubElement(inducteur, "couplageTension")
                        couplageTension.text = "true"
                        tension=ET.SubElement(inducteur, "tension")
                        if self.dictSource[source]["Signal"]=="WAVEFORM_CONSTANT":
                            tension.text="%g" %(self.dictSource[source]["WAVEFORM_CONSTANT"]["AMPLITUDE"])
                        if self.dictSource[source]["Signal"]=="WAVEFORM_SINUS": # écriture des 3 paramètres avec attribut spécial
                            amplitude = self.dictSource[source]["WAVEFORM_SINUS"]["AMPLITUDE"]
                            frequence = self.dictSource[source]["WAVEFORM_SINUS"]["FREQUENCY"]
                            phase = self.dictSource[source]["WAVEFORM_SINUS"]["PHASE"]
                            tension.text="%g, %g, %g" % (amplitude,  frequence,  phase)
                            tension.set('forme', 'sinus') # attribut forme="sinus"
                        if self.dictSource[source]["STRANDED_INDUCTOR"].has_key('Resistance'):
                            resistance=ET.SubElement(inducteur, "resistance")
                            resistance.text="%g" %(self.dictSource[source]["STRANDED_INDUCTOR"]['Resistance'])

        #definir Terme Source Magnetique
        #definirTermeSourceMagnetique=ET.SubElement(root, "definirTermeSourceMagnetique")
        #nombreTermeSourceMagnetique=ET.SubElement(definirTermeSourceMagnetique, "nombreTermeSourceMagnetique")
        #nombreTermeSourceMagnetique.text="0"
        
        #definir Aimants
        #definirAimants=ET.SubElement(root, "definirAimants")
        #nombreAimants=ET.SubElement(definirAimants, "nombreAimants")
        #nombreAimants.text="0"
        
        #Bloc <Mouvements>...</Mouvements>
        i = 0
        Mouvements=ET.SubElement(root, "Mouvements")
        for nom in self.dictMouvement['ordre']: # parcours de la liste des noms de mouvement définis, dans l'ordre
            i = i+1
            mouvement = ET.SubElement(Mouvements, "mouvement") # création de ce mouvement
            mouvement.set("id", "%g" % (i, ) ) # ajout de l'attribut id, inutilisé
            mouvement.set("name", nom ) # ajout de l'attribut name, inutilisé
            milieuGlissement = ET.SubElement(mouvement, "milieuGlissement")
            nomMilieuGlissement = self.dictMouvement[nom]['valeurs']['Milieu_glissement'].nom  # concept stocké -> nom du concept
            milieuGlissement.text="%i" % (self.dictGroupes[nomMilieuGlissement]['idMilieu'], ) # numéro du milieu défini par son nom, selon tableaux remplis précédemment
            surfaceGlissement = ET.SubElement(mouvement, "surfaceGlissement")
            surfaceGlissement.text= self.dictMouvement[nom]['valeurs']['Surface_glissement'].nom # concept stocké -> nom du concept
            deltaMaillage = ET.SubElement(mouvement, "deltaMaillage")
            deltaMaillage.text="%g" % (self.dictMouvement[nom]['valeurs']['Delta_maillage'], )
            nbPermutPas = ET.SubElement(mouvement, "nbPermutPas")
            nbPermutPas.text="%i" % (self.dictMouvement[nom]['valeurs']['Nombre_pas_permutation'], )
            axeRotation = ET.SubElement(mouvement, "axeRotation")
            axeRotation.text= self.dictMouvement[nom]['valeurs']['Axe_rotation']

        #definir Force Couple
        #definirForceCouple=ET.SubElement(root, "definirForceCouple")
        #nombreForceCouple=ET.SubElement(definirForceCouple, "nombreForceCouple")
        #nombreForceCouple.text="0"
        
        #bloc <SpiresExploratrices></SpiresExploratrices>
        i = 0 # compteur de spires
        spiresExploratrices = False # pas de spires exploratrices a priori
        for nom in self.dictGroupes.keys(): # recherche des spires exploratrices définies dans les MESHGROUP
            if self.dictGroupes[nom].has_key('Spire_Exploratrice'):
                spiresExploratrices  = True
        if spiresExploratrices: # on a trouvé au moins une spire exploratrice
            SpiresExploratrices=ET.SubElement(root, "SpiresExploratrices") # création du bloc XML adéquat
        for nom in self.dictGroupes.keys(): # recherche des spires exploratrices définies dans les MESHGROUP
            if self.dictGroupes[nom].has_key('Spire_Exploratrice'):
                spire = ET.SubElement(SpiresExploratrices, "spireExploratrice") # création du bloc XML pour cette spire
                spire.text = nom # le nom du groupe de noeud est directement écrit
                i = i+1 # incrément du  numéro de spire
                spire.set("id", "%g" % (i, ) ) # ajout de l'attribut id, inutilisé
                spire.set("name", "%s" % (nom, ) ) # ajout de l'attribut name, inutilisé         

        #bloc <PotentielsFlottants></PotentielsFlottants>
        i = 0 # compteur de potentiels flottants
        potentielsFlottants = False # pas de potentiel flottant a priori
        for nom in self.dictGroupes.keys(): # recherche des potentiels flottants définis dans les MESHGROUP
            if self.dictGroupes[nom].has_key('Potentiel_Flottant'):
                potentielsFlottants  = True
        if potentielsFlottants: # on a trouvé au moins un potentiel flottant
            PotentielsFlottants=ET.SubElement(root, "PotentielsFlottants") # création du bloc XML adéquat
        for nom in self.dictGroupes.keys(): # recherche des potentiels flottants définis dans les MESHGROUP
            if self.dictGroupes[nom].has_key('Potentiel_Flottant'):
                potentielFlottant = ET.SubElement(PotentielsFlottants, "potentielFlottant") # création du bloc XML pour ce potentiel flottant
                potentielFlottant.text = nom # le nom du groupe de noeud est directement écrit
                i = i+1 # incrément du  numéro de spire
                potentielFlottant.set("id", "%g" % (i, ) ) # ajout de l'attribut id, inutilisé
                potentielFlottant.set("name", "%s" % (nom, ) ) # ajout de l'attribut name, inutilisé         
                

        #Definir Post traitement
        postraitement=ET.SubElement(root, "postraitement")
        # Ecriture des cartes de champ
        carteChamp=ET.SubElement(postraitement, "carteChamp")
        if type(self.carteChamp)==float:
            carteChamp.text="%s" %(self.carteChamp)
        else:
            carteChamp.text="%s" % ','.join(map(str,self.carteChamp))
        # Ecriture des cartes de courants induits
        carteCourantInduit=ET.SubElement(postraitement, "carteCourantInduit")
        if type(self.carteCourantInduit)==float:
            carteCourantInduit.text="%s" %(self.carteCourantInduit)        
        else:
            carteCourantInduit.text="%s" % ','.join(map(str,self.carteCourantInduit))
        # Ecriture des cartes de force
        carteForce=ET.SubElement(postraitement, "carteForce")
        if type(self.carteForce)==float:
            carteForce.text="%s" %(self.carteForce)            
        else:
            carteForce.text="%s" % ','.join(map(str,self.carteForce))
        # Sortie des grandeurs globales, enregistrées dans self.post_global
        # liste de correspondance entre la valeur du catalogue et le nom de la balise XML
        # sous forme ordonnée (nomXML, valeur catalogue) 
        correspondance_global = (('energie',  "Energie"),\
                                                   ('perteJoule', "Pertes Joules"),\
                                                   ('fluxInducteur', "Flux par inducteur"),\
                                                   ('courantInducteur', "Courants par inducteur"),\
                                                   ('tensionInducteur', "Tensions par inducteur"), \
                                                   ('forceCouple', "Force et couple"),\
                                                   ('fluxSpire', "Flux par spire exploratrice"),\
                                                   ('fluxGroupe', "Flux par groupe"),\
                                                   ('ddpElect', "Tensions electriques"),\
                                                   ('ddpMagn', "DDP magnetiques"), \
                                                   ('fluxMagn', "Flux magnetiques"),\
                                                   ('fluxJinduitTotal', "Flux J induit"),\
                                                   ('potFlottant', "Potentiel flottant"))
        # Sortie des grandeurs demandées seulement (true)
        for table in correspondance_global:
            if table[1] in self.post_global:
                post_global_item=ET.SubElement(postraitement, table[0])
                post_global_item.text = "true"
#        # Sortie de toutes les grandeurs possibles, avec la valeur true pour celles demandées et false sinon
#        for table in correspondance_global:
#            post_global_item=ET.SubElement(postraitement, table[0])
#            if table[1] in self.post_global:
#                post_global_item.text = "true"
#            else:
#                post_global_item.text = "false"

        self.indent(root) # indentations et retours à la ligne, à l'aide d'une fonction maison, car xml.etree.ElementTree ne sait pas faire et le module lxml n'est pas disponible dans Salomé

        tree = ET.ElementTree(root)

        tree.write(fileXML, encoding="UTF-8")

       # print "le dico complet=%s" %(self.dictGroupes)

        if self.debug: 
            print "ecriture du fichier d'execution (SH)"
        RepCarmel=os.path.join(repertory,"lancer.sh")
        f = open( RepCarmel, 'wb')
        self.texteCarmel3D_SH+='cd ' + repertory + ' \n'
        self.texteCarmel3D_SH+='./carmel << FIN\n'
        correspondance_resolution = {"(T-)Omega seulement":"1\n","A(-Phi) seulement":"2\n", "(T-)Omega puis A(-Phi)":"1\n2\n", "A(-Phi) puis (T-)Omega":"2\n1\n"}
        self.texteCarmel3D_SH+= correspondance_resolution[self.formulation]
        self.texteCarmel3D_SH+='0\nFIN\n'
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
        dico={}
        self.dicoMCFACTCourant=dico
        self.dicoCourant=self.dicoMCFACTCourant
        s=PythonGenerator.generMCFACT(self,obj)
        self.dicoEtapeCourant[obj.nom]=self.dicoMCFACTCourant
        self.dicoMCFACTCourant=None
        self.dicoCourant=self.dicoEtapeCourant
        return s


#----------------------------------------------------------------------------------------
   def generPROC_ETAPE(self,obj):
        """analyse des PROC du catalogue  ( VERSION )"""
        dico={}
        self.dicoEtapeCourant=dico
        self.dicoCourant=self.dicoEtapeCourant
        s=PythonGenerator.generPROC_ETAPE(self,obj)
        obj.valeur=self.dicoEtapeCourant

        if self.debug: 
            print "PROC_ETAPE %(v_1)s  %(v_2)s" % {'v_1': unicode(obj.nom), "v_2": unicode(obj.valeur)}
        s=PythonGenerator.generPROC_ETAPE(self,obj)
        if obj.nom=="PARAMETERS" : self.generBLOC_PARAMETERS(obj)
        if obj.nom=="SOLVEUR" : self.generSOLVEUR(obj)
        if obj.nom=="SYMETRIE" : self.generBLOC_SYMETRIE(obj)
        if obj.nom=="POST_TRAITEMENT" : self.generPOST_TRAITEMENT(obj)
        return s



#----------------------------------------------------------------------------------------
   def generETAPE(self,obj):
        """analyse des OPER du catalogue"""
        dico={}
        self.dicoEtapeCourant=dico
        self.dicoCourant=self.dicoEtapeCourant
        s=PythonGenerator.generETAPE(self,obj)
        obj.valeur=self.dicoEtapeCourant
        if self.debug: 
            print "ETAPE : obj.nom = %(v_1)s , obj.valeur= %(v_2)s" % {'v_1': obj.nom, 'v_2': obj.valeur}
        if obj.nom=="MESHGROUP" : self.generMESHGROUP(obj)
        if obj.nom=="MATERIAL" : self.generMATERIAL(obj)
        if obj.nom=="SOURCE" : self.generSOURCE(obj)
        if obj.nom=="STRANDED_INDUCTOR_GEOMETRY" : self.generSTRANDED_INDUCTOR_GEOMETRY(obj)
        if obj.nom=="MACRO_GROUPE": self.generMACRO_GROUPE(obj)
        if obj.nom=="MOUVEMENT" : self.generMOUVEMENT(obj)
        s=PythonGenerator.generETAPE(self,obj)
        return s

#----------------------------------------------------------------------------------------
   def generMACRO_ETAPE(self,obj):
        """Utilisé par INCLUDE"""
        dico={}
        self.dicoEtapeCourant=dico
        self.dicoCourant=self.dicoEtapeCourant
        import generator
        monGenerateur=generator.plugins[nomPlugin]()
        jdc_aux_texte=monGenerateur.gener(obj.jdc_aux)
        if self.debug: 
            print "jdc_aux_texte : %s" % jdc_aux_texte

        # sauvegarde de tous les matériaux trouvés dans les bibliothèques INCLUDE
        for cle in monGenerateur.dictMaterial:
            self.dictMaterial[cle] = monGenerateur.dictMaterial[cle]
        # sauvegarde de toutes les sources trouvées dans les bibliothèques INCLUDE
        for cle in monGenerateur.dictSource:
            self.dictSource[cle] = monGenerateur.dictSource[cle]

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
            nomGroupe = obj.getSdname() # nom du groupe de maillage, i.e. nom du concept
            print "liste des noms sans prefixes %s" %(nomGroupe)

            # test: un et un seul nom de materiau ou source doit etre associe a ce groupe de maillage, via les cles MATERIAL et SOURCE, respectivement.
            # test sur un seul attribut, non pertinent car il peut y en avoir plusieurs.
            #assert len(obj.valeur.keys())==1,"Un et un seul nom de materiau ou source doit etre associe a ce groupe du maillage :"+nomGroupe

            # on utilise le fait que obj.valeur est un dictionnaire
            self.dictGroupes[nomGroupe] = {}   
            if self.debug: 
                print "obj.valeur.keys()= %s" % obj.valeur.keys()
            #if 'MATERIAL' in obj.valeur.keys() and 'SOURCE' in obj.valeur.keys(): # test d'erreur lors de presence de materiau et source a la fois
            #    raise ValueError,tr(" ce groupe de maillage %s est associe a au moins un materiau  et au moins une source." % nomGroupe)
            # association a un materiau
            if 'MATERIAL' in obj.valeur.keys():
                self.dictGroupes[nomGroupe]['MATERIAL'] = obj.valeur['MATERIAL'].nom # sauvegarde de l'association entre ce groupe de maillage et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
           #     self.dictGroupes['ordreMateriauxJdC'].append(nomGroupe) # sauvegarde du nom du groupe de maillage associe a un materiau, dans l'ordre du JdC
            # association a une source
            if 'SOURCE' in obj.valeur.keys():
                self.dictGroupes[nomGroupe]['SOURCE'] = obj.valeur['SOURCE'].nom # sauvegarde de l'association entre ce groupe de maillage et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
            #    self.dictGroupes['ordreSourcesJdC'].append(nomGroupe) # sauvegarde du nom du groupe de maillage associe a une source, dans l'ordre du JdC
            # erreur ni materiau ni source associee
            if 'STRANDED_INDUCTOR_GEOMETRY' in obj.valeur.keys():
                    self.dictGroupes[nomGroupe]['STRANDED_INDUCTOR_GEOMETRY'] = obj.valeur['STRANDED_INDUCTOR_GEOMETRY'].nom # sauvegarde de l'association entre ce groupe de maillage et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
             #       self.dictGroupes['ordreStrandJdC'].append(nomGroupe) # sauvegarde du nom du groupe de maillage associe a une source, dans l'ordre du JdC
            if 'CONDITION_LIMITE' in obj.valeur.keys():
                    self.dictGroupes[nomGroupe]['CONDITION_LIMITE'] = obj.valeur['CONDITION_LIMITE']
             #       self.dictGroupes['ordreConditionJdC'].append(nomGroupe) 
            if 'Domaine' in obj.valeur.keys():
                self.dictGroupes[nomGroupe]['DOMAINE'] = obj.valeur['Domaine']
            #    self.dictGroupes['ordreDomaineJdC'].append(nomGroupe)
                texte=""
                texte+="%s"%(obj.valeur['Domaine'])
                print"le texte=%s" %(texte)
                self.dictDomaine[obj.getSdname()]=texte  
                print "liste des domaines =%s" %(self.dictGroupes[nomGroupe]['DOMAINE'])
            if 'Potentiel_Flottant' in obj.valeur.keys():
                self.dictGroupes[nomGroupe]['Potentiel_Flottant'] = True
            if 'Spire_Exploratrice' in obj.valeur.keys():
                self.dictGroupes[nomGroupe]['Spire_Exploratrice'] = True

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
            nomMacroGroupe = obj.getSdname() # nom du macro groupe
            print "liste des noms sans prefixes %s" %(nomMacroGroupe)
            self.dictMacroGroupes[nomMacroGroupe] = obj.valeur # sauvegarde des propriétés du macro-groupe

            if self.debug: 
                print "obj.valeur.keys()= %s" % obj.valeur.keys()
            # association a une source
            if 'LISTE_MESHGROUP' in obj.valeur.keys(): # test de liste définie dans la macro-groupe, sinon erreur
                listeGroupesMauvaisFormat = obj.valeur['LISTE_MESHGROUP'] # sauvegarde de l'association entre ce macro groupe et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
                self.dictMacroGroupes[nomMacroGroupe]['LISTE'] = [] # sauvegarde de l'association entre ce macro groupe et un materiau ou source, par son nom, i.e. nom du concept du materiau ou de la source
                for groupe in listeGroupesMauvaisFormat: # sauvegarde de la liste au format correct
                    groupe = groupe.replace("'", "") # suppression des guillement simples
                    groupe = groupe.replace('"', "") # suppression des guillement doubles
                    self.dictMacroGroupes[nomMacroGroupe]['LISTE'].append(groupe) # sauvegarde du nom au formatage correct
            else:
                raise ValueError, nomMacroGroupe + tr(" : ce MACRO_GROUPE doit contenir une liste de groupes LISTE_MESHGROUP.")

            for nomGroupe in self.dictMacroGroupes[nomMacroGroupe]['LISTE']: # liste des groupes MESHGROUP de ce macro-groupe. On leur associe les propriétés du MACRO_GROUPE
                for propriete in ('SOURCE', 'MATERIAL',  'STRANDED_INDUCTOR_GEOMETRY'): # liste des propriétés automatiques à copier du MACRO_GROUPE à chaque MESHGROUP de la liste
                    if  propriete in obj.valeur.keys(): # ce macro-groupe est associé à cette propriété
                        if self.dictGroupes[nomGroupe].has_key(propriete) and self.dictGroupes[nomGroupe][propriete] != self.dictGroupes[nomGroupe][propriete].nom: # erreur, ce meshgroup a déjà une telle propriéte définie, différente
                            print u"ERREUR! Conflit entre la %s : %s du MACRO_GROUPE %s et celle : %s du MESHGROUP %s associé à ce macro-groupe." % \
                             ( propriete, obj.valeur[propriete].nom,  nomMacroGroupe, self.dictGroupes[nomGroupe][propriete],  nomGroupe )
                            raise ValueError, propriete + ',' + obj.valeur[propriete].nom + ',' + nomMacroGroupe + ',' + self.dictGroupes[nomGroupe][propriete] + ',' +  nomGroupe\
                            + tr(" : conflit entre la propriete (#1:#2) du MACRO_GROUPE (de nom #3) et celle (#4) du MESHGROUP (#5) associe a ce macro-groupe.")
                        else : # pas de conflit de cette propriété, alors copie, meme si les propriétés sont les memes pour simplifier
                            self.dictGroupes[nomGroupe][propriete] = obj.valeur[propriete].nom # sauvegarde du nom de la propriété du macro-groupe dans le meshgroup
                for propriete in ('CONDITION_LIMITE', ): # liste des propriétés définies à l'avance automatiques à copier du MACRO_GROUPE à chaque MESHGROUP de la liste
                    if  propriete in obj.valeur.keys(): # ce macro-groupe est associé à cette propriété
                        if self.dictGroupes[nomGroupe].has_key(propriete) and self.dictGroupes[nomGroupe][propriete] != self.dictGroupes[nomGroupe][propriete]: # erreur, ce meshgroup a déjà une telle propriéte définie, différente
                            print u"ERREUR! Conflit entre la %s : %s du MACRO_GROUPE %s et celle : %s du MESHGROUP %s associé à ce macro-groupe." % \
                             ( propriete, obj.valeur[propriete],  nomMacroGroupe, self.dictGroupes[nomGroupe][propriete],  nomGroupe )
                            raise ValueError, propriete + ',' + obj.valeur[propriete].nom + ',' + nomMacroGroupe + ',' + self.dictGroupes[nomGroupe][propriete] + ',' +  nomGroupe\
                            + tr(" : conflit entre la propriete (#1:#2) du MACRO_GROUPE (de nom #3) et celle (#4) du MESHGROUP (#5) associe a ce macro-groupe.")
                        else : # pas de conflit de cette propriété, alors copie, meme si les propriétés sont les memes pour simplifier
                            self.dictGroupes[nomGroupe][propriete] = obj.valeur[propriete] # sauvegarde du nom de la propriété du macro-groupe dans le meshgroup
        except ValueError, err:
            raise ValueError, str(err)


   def generSOLVEUR(self, obj):
        if self.debug:
            print "generation solveur obj.valeur = %s" % obj.valeur
        try :
            self.typeSolveur = obj.valeur['Type']
            if self.typeSolveur == "Solveur_lineaire" : self.generSOLVEUR_LINEAIRE(obj)
            if self.typeSolveur == "Solveur_non_lineaire" :
                self.generSOLVEUR_LINEAIRE(obj)
                self.generSOLVEUR_NON_LINEAIRE(obj)
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
        if self.debug: 
            print "generation methode iterative BICGCR obj.valeur = %s" % obj.valeur
        self.kEpsilonGCP =  obj.valeur["Precision"]   
        self.precond=obj.valeur["Preconditionneur"]
        self.nbIterationMax=obj.valeur["Nombre_iterations_max"]


   def generMETHODE_DIRECTE_MUMPS(self, obj):
        texte=""
        if self.debug:
            print "_____________directe_____________"

   def generSOLVEUR_NON_LINEAIRE(self, obj):
        if self.debug: 
            print "generation solveur_non_lineaire obj.valeur = %s" % obj.valeur
        correspondance_methodeNonLineaire = {"Methode de Newton":2,"Methode de substitution":1} # correspondance sur la méthode non-linéaire entre le catalogue et le XML    
        self.methodeNonLineaire = correspondance_methodeNonLineaire[obj.valeur["Methode_non_lineaire"]]
        self.kEpsilonNonLinearite=obj.valeur["PrecisionNonLineaire"]
        self.kCoefficientRelaxation=obj.valeur["Coefficient_de_Relaxation"]

   def generMATERIAL(self,obj):
        """preparation du bloc correspondant a un materiau du fichier PHYS"""
        texte=""
        if self.debug: 
            print "generation material obj.valeur = %s" % obj.valeur
        try :
            nomMaterial = obj.getSdname() 
            self.dictMaterial[nomMaterial]=obj.valeur
            print"self.dictMaterial=%s" %(self.dictMaterial)
        except ValueError, err:
            raise ValueError, str(err)
#-------------------------------------------------------------------

   def generSOURCE(self,obj):
        """preparation du bloc correspondant a une source du fichier PHYS"""
        if self.debug: 
            print "generation source obj valeur = %s" % obj.valeur
        texte=""
        try :
            nomSource = obj.getSdname() 
            self.dictSource[nomSource]=obj.valeur # dictionnaire
            self.dictSource[nomSource]['milieux'] = [] # liste ordonnée des groupes associés à cette source
            print"mon dico des sources=%s" %(self.dictSource)
        except ValueError, err:
            raise ValueError, str(err)

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

        self.identification = obj.valeur["Identification_du_Modele"]
        self.fichierMaillage = obj.valeur["Fichier_maillage"]
        self.echelleMaillage = obj.valeur["Echelle_du_maillage"]
        
        self.kEpsilonDistance=obj.valeur["kEpsilonDistance"] 
        self.kdistanceRef=obj.valeur["kdistanceRef"] 
        self.jauge=obj.valeur["Jauge"]
        self.NBoucleTemps=obj.valeur["Nb_pas_de_temps"]
        self.dt=obj.valeur["Pas_de_temps"]

        self.repertory=obj.valeur["RepCarmel"]
        self.fcarmel=obj.valeur["Resoudre_probleme"]
        self.postprocess=obj.valeur["Realiser_post_traitement_aposteriori"]
        self.formulation=obj.valeur["Formulation"]

   def generBLOC_SYMETRIE(self, obj): 
        if self.debug: 
            print "generation de la symetrie obj.valeur = %s" % obj.valeur  

        try:
            self.listSymetrie.append(obj.valeur)
            print"ma liste symetrie =%s" %(self.listSymetrie)
        except ValueError, err:
            raise ValueError, str(err)
#----------------------------------------------------------------------------------------

   def generMOUVEMENT(self, obj):
        if self.debug:
            print "generation du mouvement obj.valeur = %s" % obj.valeur
        
        try:
            nom = obj.getSdname()
            self.nombreMouvements = self.nombreMouvements+1
            self.dictMouvement[nom] = {'ordre': self.nombreMouvements, 'valeurs': obj.valeur}
            self.dictMouvement['ordre'].append(nom)
            if self.debug:
                print "self.dictMouvement =%s" %(self.dictMouvement)
                print "self.nombreMouvements =%i" %(self.nombreMouvements)
        except ValueError,  err:
            raise valueError,  str(err)
#----------------------------------------------------------------------------------------
   def generSTRANDED_INDUCTOR_GEOMETRY(self, obj):
        """preparation du bloc STRANDED_INDUCTOR_GEOMETRY"""
        if self.debug: 
            print "generation strand obj valeur = %s" % obj.valeur
        try :
            nomStrand = obj.getSdname() 
            self.dictStrand[nomStrand]=obj.valeur
            print"mon dico des stranded inductor geometry=%s" %(self.dictStrand)

        except ValueError, err:
            raise ValueError, str(err)

   def generPOST_TRAITEMENT(self, obj):
        if self.debug: 
            print "generation post traitement obj.valeur = %s" % obj.valeur    
        self.carteChamp=obj.valeur["Cartes_des_champs"]
        self.carteCourantInduit=obj.valeur["Cartes_des_courants_induits"]
        self.carteForce=obj.valeur["Cartes_des_forces"]
        if obj.valeur.has_key('GLOBAL'):
            self.post_global = obj.valeur['GLOBAL']
            # sauvegarde de la liste au format correct, en supprimant les guillemets simples et doubles extra générés par Eficas
            # car Eficas génère une liste ["'Energie'","'Flux par inducteur'","'Force et couple'"] enrichie
            # à partir de l'instruction .comm correctement formatée : GLOBAL=('Energie','Flux par inducteur','Force et couple',)
            for i in range(len(self.post_global)): 
                self.post_global[i] = self.post_global[i].replace("'", "") # suppression des guillement simples
                self.post_global[i] = self.post_global[i].replace('"', "") # suppression des guillement doubles

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


