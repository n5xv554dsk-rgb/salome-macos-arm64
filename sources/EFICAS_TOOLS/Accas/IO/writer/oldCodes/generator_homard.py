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
"""
    Ce module contient le plugin generateur de fichier au format 
    homard pour EFICAS.

"""
import traceback
import types,string,re

from Accas.processing import P_CR
from Accas.processing.P_utils import repr_float
from Accas import ETAPE,PROC_ETAPE,MACRO_ETAPE,ETAPE_NIVEAU,JDC,FORM_ETAPE
from Accas import MCSIMP,MCFACT,MCBLOC,MCList,EVAL
from Accas import GEOM,ASSD,MCNUPLET
from Accas import COMMENTAIRE,PARAMETRE, PARAMETRE_EVAL,COMMANDE_COMM
from formatage import formatage
from generator_python import PythonGenerator

def entryPoint():
   """
       Retourne les informations necessaires pour le chargeur de plugins

       Ces informations sont retournees dans un dictionnaire
   """
   return {
        # Le nom du plugin
          'name' : 'homard',
        # La factory pour creer une instance du plugin
          'factory' : HomardGenerator,
          }


class HomardGenerator(PythonGenerator):
   """
       Ce generateur parcourt un objet de type JDC et produit
       un texte au format eficas et 
       un texte au format homard 

   """
   # Les extensions de fichier preconis�es
   extensions=('.comm',)

   def __init__(self,cr=None):
      # Si l'objet compte-rendu n'est pas fourni, on utilise le compte-rendu standard
      if cr :
         self.cr=cr
      else:
         self.cr=P_CR.CR(debut='CR generateur format homard pour homard',
                         fin='fin CR format homard pour homard')
      # Le texte au format homard est stock� dans l'attribut text
      self.dico_mot_clef={}
      self.assoc={}
      self.init_assoc()
      self.text=''
      self.textehomard=[]

   def init_assoc(self):
      self.lmots_clef_calcules = ('SuivFron','TypeBila','ModeHOMA','CCAssoci', 'CCNoChaI','HOMaiN__','HOMaiNP1','CCNumOrI', 'CCNumPTI')
      self.lmot_clef  = ('CCMaiN__', 'CCNoMN__', 'CCIndica', 'CCSolN__', 'CCFronti', 'CCNoMFro', 'CCMaiNP1', 
                         'CCNoMNP1', 'CCSolNP1', 'TypeRaff', 'TypeDera', 'NiveauMa', 'SeuilHau', 'SeuilHRe', 
                         'SeuilHPE', 'NiveauMi', 'SeuilBas', 'SeuilBRe', 'SeuilBPE', 'ListeStd', 'NumeIter', 
                         'Langue  ', 'CCGroFro', 'CCNoChaI', 'CCNumOrI', 'CCNumPTI', 'SuivFron', 'TypeBila', 
                         'ModeHOMA', 'HOMaiN__', 'HOMaiNP1','CCCoChaI')

# Bizarre demander a Gerald : 
#                CVSolNP1
      self.assoc['CCMaiN__']='FICHIER_MED_MAILLAGE_N'
      self.assoc['CCNoMN__']='NOM_MED_MAILLAGE_N'
      self.assoc['CCIndica']='FICHIER_MED_MAILLAGE_N'
      self.assoc['CCSolN__']='FICHIER_MED_MAILLAGE_N'
      self.assoc['CCFronti']='FIC_FRON'
      self.assoc['CCNoMFro']='NOM_MED_MAILLAGE_FRONTIERE'
      self.assoc['CCMaiNP1']='FICHIER_MED_MAILLAGE_NP1'
      self.assoc['CCNoMNP1']='NOM_MED_MAILLAGE_NP1'
      self.assoc['CCSolNP1']='FICHIER_MED_MAILLAGE_NP1'
      self.assoc['TypeRaff']='RAFFINEMENT'
      self.assoc['TypeDera']='DERAFFINEMENT'
      self.assoc['NiveauMa']='NIVE_MAX'
      self.assoc['SeuilHau']='CRIT_RAFF_ABS'
      self.assoc['SeuilHRe']='CRIT_RAFF_REL'
      self.assoc['SeuilHPE']='CRIT_RAFF_PE'
      self.assoc['NiveauMi']='NIVE_MIN'
      self.assoc['SeuilBas']='CRIT_DERA_ABS'
      self.assoc['SeuilBRe']='CRIT_DERA_REL'
      self.assoc['SeuilBPE']='CRIT_DERA_PE'
      self.assoc['ListeStd']='MESSAGES'
      self.assoc['NumeIter']='NITER'
      self.assoc['Langue  ']='LANGUE'
      self.assoc['CCGroFro']='GROUP_MA'
#     self.assoc['CCNoChaI']='NOM_MED' (on doit aussi ajouter 'COMPOSANTE')
      self.assoc['CCNumOrI']='NUME_ORDRE'
      self.assoc['CCNumPTI']='NUME_PAS_TEMPS'
      self.assoc['CCCoChaI']='COMPOSANTE'
     
      self.dico_mot_depend={}
     
      # Attention a la synthaxe
      self.dico_mot_depend['CCIndica'] ='self.dico_mot_clef["RAFFINEMENT"] == "LIBRE" or self.dico_mot_clef["DERAFFINEMENT"] == "LIBRE"'
      self.dico_mot_depend['CCSolN__'] ='self.dico_mot_clef.has_key("NITER")'
      self.dico_mot_depend['CCSolNP1'] ='self.dico_mot_clef.has_key("NITER")'

   def gener(self,obj,format='brut',config=None):
      self.text=PythonGenerator.gener(self,obj,format)
      self.genereConfiguration()
      return self.text

   def generMCSIMP(self,obj) :
      """
          Convertit un objet MCSIMP en une liste de chaines de caract�res � la
          syntaxe homard
      """
      s=PythonGenerator.generMCSIMP(self,obj)
      clef=obj.nom
      self.dico_mot_clef[clef]=obj.val
      return s

   def cherche_dependance(self,mot):
       b_eval = 0
       a_eval=self.dico_mot_depend[mot]
       try :
          b_eval=eval(self.dico_mot_depend[mot])
       except :
          for l in a_eval.split(" or "):
              try:
                 b_eval=eval(l)
                 if not (b_eval == 0 ):
                     break
              except :
                 pass
       return b_eval


   def genereConfiguration(self):
      ligbla=31*' '
      self.textehomard=[]
      for mot in self.lmot_clef:

#          on verifie d'abord que le mot clef doit bien etre calcule
          if self.dico_mot_depend.has_key(mot) :
             if self.cherche_dependance(mot) == 0 :
                      continue

          if mot not in self.lmots_clef_calcules :
             clef_eficas=self.assoc[mot]
             if self.dico_mot_clef.has_key(clef_eficas):
                val=self.dico_mot_clef[clef_eficas]
                if val != None:
                   try :
                    ligne=mot+' '+val
                   except:
                    ligne=mot+' '+repr(val)
                   ligne.rjust(32)
                   self.textehomard.append(ligne)
          else:
             val=apply(HomardGenerator.__dict__[mot],(self,))
             if val != None:
                mot.rjust(8)
                ligne=mot+' '+val
                ligne.rjust(32)
                self.textehomard.append(ligne)

   def get_homard(self):
       return self.textehomard

   def SuivFron(self):
        val="non"
        if self.dico_mot_clef.has_key('NOM_MED_MAILLAGE_FRONTIERE'):
           if self.dico_mot_clef['NOM_MED_MAILLAGE_FRONTIERE'] != None:
                val="oui"
        return val

   def TypeBila(self):
        inttypeBilan = 1
        retour=None
        dict_val={'NOMBRE':7,'INTERPENETRATION':3,'QUALITE':5,'CONNEXITE':11,'TAILLE':13}
        for mot in ('NOMBRE','QUALITE','INTERPENETRATION','CONNEXITE','TAILLE'):
            if self.dico_mot_clef.has_key(mot):
               if (self.dico_mot_clef[mot] == "OUI"):
                  inttypeBilan=inttypeBilan*dict_val[mot]
                  retour = repr(inttypeBilan)
        return retour


   def ModeHOMA(self):
        intModeHOMA=1
        if self.dico_mot_clef.has_key('INFORMATION'):
           if self.dico_mot_clef['INFORMATION'] == "OUI":
              intModeHOMA=2
        return repr(intModeHOMA)
           
   def CCAssoci(self):
        return 'MED' 

   def CCNoChaI(self):
        if not (self.dico_mot_clef.has_key('NOM_MED')):
           return None
        if (self.dico_mot_clef['NOM_MED']== None):
           return None
        if not (self.dico_mot_clef.has_key('COMPOSANTE')):
           return None
        if (self.dico_mot_clef['COMPOSANTE']== None):
           return None
        chaine=self.dico_mot_clef['COMPOSANTE']+' '+self.dico_mot_clef['NOM_MED']
        return chaine

   def HOMaiN__(self):
       chaine=None
       if self.dico_mot_clef.has_key('NITER'):
          if self.dico_mot_clef['NITER'] != None :
             num="M"+repr(self.dico_mot_clef['NITER'])
             chaine=num+" "+num+".hom"
       return chaine

   def HOMaiNP1(self):
       chaine=None
       if self.dico_mot_clef.has_key('NITER'):
          if self.dico_mot_clef['NITER'] != None :
             num="M"+repr(self.dico_mot_clef['NITER']+1)
             chaine=num+" "+num+".hom"
       return chaine

   def CCNumOrI(self):
       chaine=repr(1)
       if self.dico_mot_clef.has_key('NUME_ORDRE'):
          if self.dico_mot_clef['NUME_ORDRE'] != None :
             chaine=repr(self.dico_mot_clef['NUME_ORDRE'])
       return chaine

   def CCNumPTI(self):
       chaine=repr(1)
       if self.dico_mot_clef.has_key('NUME_PAS_TEMPS'):
          if self.dico_mot_clef['NUME_PAS_TEMPS'] != None :
             chaine=repr(self.dico_mot_clef['NUME_PAS_TEMPS'])
       return chaine
