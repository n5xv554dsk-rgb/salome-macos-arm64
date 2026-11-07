# -*- coding: iso-8859-1 -*-
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

#from ExtractGeneratorLoadLineandTransfoDico import ExtractGeneratorLoadLineandTransfoDico
from ExtractGeneratorLoadLineandTransfoDico import ExtractGeneratorLoadLineandTransfoDico2

def INCLUDE(self,PSSE_path,sav_file,**args):
   """ 
       Fonction sd_prod pour la macro INCLUDE
   """
   
   if sav_file==None: return
   reevalue=0
   listeADeTruire=[]
   listeNouveau=[]
   toClean=False
   if hasattr(self,'fichier_ini'):
       reevalue=1
       if self.fichier_ini == sav_file : return
       self.fichier_ini=sav_file
       if hasattr(self,'old_context_fichier_init' ):
         toClean=True
         for concept in self.old_context_fichier_init.values():
             #self.jdc.delete_concept(concept)
             listeADeTruire.append(concept)
         self.jdc_aux=None
         self.contexte_fichier_init={}
         #self.reevalue_sd_jdc()
         self.jdc.reset_context()

   self.fichier_ini=sav_file
   self.contexte_fichier_init = {}
   self.fichier_unite = 999
   self.fichier_err = None
   self.fichier_text=""
    
   unite = 999

   #try :
   if 1:
     MachineDico,LoadDico,LineDico,TransfoDico, MotorDico = ExtractGeneratorLoadLineandTransfoDico2(sav_file,PSSE_path)
   else :
   #except :
     if self.jdc.appli is not None:
        self.jdc.appli.affiche_alerte("Error", 'An error happened in ExtractGeneratorandLoadList execution ')
        self.g_context = {}
        self.etapes = []
        self.jdc_aux = None
        self.fichier_err = str(exc)
        self.contexte_fichier_init = {}

   
   for nom in MachineDico.keys():
      self.fichier_text += "%s=MONGENER(ID='%s',);\n" % (nom, 'a')
      listeNouveau.append(nom)

   for nom in LoadDico.keys():
      self.fichier_text += "%s=MACHARGE(ID='%s',);\n" % (nom, 'a')
      listeNouveau.append(nom)
      
   for nom in LineDico.keys():
      self.fichier_text += "%s=MALIGNE(ID='%s',);\n" % (nom,'a')
      listeNouveau.append(nom)

   for nom in TransfoDico.keys():
      self.fichier_text += "%s=MONTRANSFO(ID='%s',);\n" % (nom,'a')
      listeNouveau.append(nom)

   for nom in MotorDico.keys():
      self.fichier_text += "%s=MONMOTEUR(ID='%s',);\n" % (nom,'a')
      listeNouveau.append(nom)

   import Accas.extensions.jdc_include
   self.JdC_aux = extensions.jdc_include.JDC_CATA_INCLUDE(code='PSEN', execmodul=None)
   self.make_contexte_include(None, self.fichier_text)
   self.old_context_fichier_init = self.contexte_fichier_init
   self.parent.record_unit(unite, self)

   self.jdc.MachineDico=MachineDico
   self.jdc.LoadDico=LoadDico
   self.jdc.LineDico=LineDico
   self.jdc.TransfoDico=TransfoDico
   self.jdc.MotorDico = MotorDico

   if toClean:
    for concept in listeADeTruire :
      if concept.nom not in listeNouveau: self.jdc.delete_concept(concept)
    self.reevalue_sd_jdc()

def INCLUDE_context(self,d):
   """ 
       Fonction op_init pour macro INCLUDE
   """
   for k,v in self.g_context.items():
      d[k]=v

