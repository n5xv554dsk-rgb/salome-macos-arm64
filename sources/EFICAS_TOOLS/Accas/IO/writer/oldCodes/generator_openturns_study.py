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
   openturns pour EFICAS.

"""
import traceback
import types,string,re
from Accas.extensions.eficas_translation import tr


from generator_python import PythonGenerator
from OpenturnsBase import Generateur 
#from OpenturnsXML import XMLGenerateur 
#from OpenturnsSTD import STDGenerateur 

def entryPoint():
   """
      Retourne les informations necessaires pour le chargeur de plugins

      Ces informations sont retournees dans un dictionnaire
   """
   return {
        # Le nom du plugin
          'name' : 'openturns_study',
        # La factory pour creer une instance du plugin
          'factory' : OpenturnsGenerator,
          }


class OpenturnsGenerator(PythonGenerator):
   """
      Ce generateur parcourt un objet de type JDC et produit
      un texte au format eficas et 
      un texte au format xml 

   """
   # Les extensions de fichier permis?
   extensions=('.comm',)

   def initDico(self):
      self.dictMCVal={}
      self.listeVariables=[]
      self.listeFichiers=[]
      self.dictMCLois={}
      self.dictTempo={}
      self.TraiteMCSIMP=1
      self.texteSTD="""#!/usr/bin/env python
      import sys
      print "Invalid file. Check build process."
      sys.exit(1)
      """

   def gener(self,obj,format='brut',config=None):
      print "IDM: gener dans generator_openturns_study.py"
      self.initDico()
      self.text=PythonGenerator.gener(self,obj,format)
      self.genereSTD()
      return self.text

   def generMCSIMP(self,obj) :
      """
      Convertit un objet MCSIMP en texte python
      Remplit le dictionnaire des MCSIMP si nous ne sommes ni dans une loi, ni dans une variable
      """
      s=PythonGenerator.generMCSIMP(self,obj)
      if self.TraiteMCSIMP == 1 : 
         self.dictMCVal[obj.nom]=obj.valeur
      else :
         self.dictTempo[obj.nom]=obj.valeur
      return s


   def generETAPE(self,obj):
      print "IDM: generETAPE dans generator_openturns_study.py"
      print "IDM: obj.nom=", obj.nom
      if obj.nom in ( "DISTRIBUTION", ) :
         self.TraiteMCSIMP=0
         self.dictTempo={}
      s=PythonGenerator.generETAPE(self,obj)
      if obj.nom in ( "DISTRIBUTION", ) :
         self.dictMCLois[obj.sd]=self.dictTempo
         self.dictTempo={}
      self.TraiteMCSIMP=1
      return s

   def generPROC_ETAPE(self,obj):
      print "IDM: generPROC_ETAPE dans generator_openturns_study.py"
      print "IDM: obj.nom=", obj.nom
      if obj.nom in ( "VARIABLE",  ) :
         self.TraiteMCSIMP=0
         self.dictTempo={}
      s=PythonGenerator.generPROC_ETAPE(self,obj)
      if obj.nom in ( "VARIABLE", ) :
         self.listeVariables.append(self.dictTempo)
         self.dictTempo={}
      self.TraiteMCSIMP=1
      return s

   def genereSTD(self):
      print "IDM: genereSTD dans generator_openturns_study.py"
      print "IDM: self.listeVariables=", self.listeVariables
      MonGenerateur=self.getGenerateur()
      #try :
      if 1== 1 :
         self.texteSTD=MonGenerateur.CreeSTD()
      #except :
      else :
         self.texteSTD=tr("Il y a un pb a la Creation du STD")

   def writeDefault(self, fn):
      fileSTD = fn[:fn.rfind(".")] + '.py'
      with open(fileSTD, 'w') as f:
        f.write(self.texteSTD)

   def getGenerateur (self):
      print "IDM: getGenerateur dans generator_openturns_study.py"
      print "IDM: self.dictMCVal=", self.dictMCVal
      print "IDM: self.listeVariables=", self.listeVariables
      print "IDM: self.dictMCLois=", self.dictMCLois
      MonBaseGenerateur=Generateur(self.appli,self.dictMCVal, self.listeVariables, self.dictMCLois)
      MonGenerateur=MonBaseGenerateur.getSTDGenerateur()
      return MonGenerateur
