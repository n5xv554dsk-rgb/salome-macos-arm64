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
          'name' : 'openturns_wrapper',
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
       self.dictVariables={}
       self.listeFichiers=[]
       self.dictTempo={}
       self.traiteMCSIMP=1
       self.numOrdre=0
       self.texteSTD="""#!/usr/bin/env python
       import sys
       print "Invalid file. Check build process."
       sys.exit(1)
       """
       self.wrapperXML=None

   def gener(self,obj,format='brut',config=None):
       #print "IDM: gener dans generator_openturns_wrapper.py"
       self.initDico()
       self.text=PythonGenerator.gener(self,obj,format)
       self.genereXML()
       #self.genereSTD()
       return self.text

   def generMCSIMP(self,obj) :
       """
       Convertit un objet MCSIMP en texte python
       Remplit le dictionnaire des MCSIMP si nous ne sommes ni dans une loi, ni dans une variable
       """
       s=PythonGenerator.generMCSIMP(self,obj)
       if not( type(obj.valeur) in (list, tuple)) and (obj.getMinMax()[1] != 1):
          valeur=(obj.valeur,)
       else :
          valeur=obj.valeur
       if self.traiteMCSIMP == 1 : 
          self.dictMCVal[obj.nom]=valeur
       else :
          self.dictTempo[obj.nom]=valeur
       return s

   def generETAPE(self,obj):
       #print "generETAPE" , obj.nom
       if obj.nom == "VARIABLE" :
          self.traiteMCSIMP=0
          self.dictTempo={}
       s=PythonGenerator.generETAPE(self,obj)
       if obj.nom == "VARIABLE" :
          self.dictTempo["numOrdre"]=self.numOrdre
          self.numOrdre = self.numOrdre +1
          if obj.sd == None :
             self.dictVariables["SansNom"]=self.dictTempo
          else :
             self.dictVariables[obj.sd.nom]=self.dictTempo
          self.dictTempo={}
       self.traiteMCSIMP=1
       return s

   def generMCFACT(self,obj):
       # Il n est pas possible d utiliser obj.valeur qui n est pas 
       # a jour pour les nouvelles variables ou les modifications 
       if obj.nom in ( "Files", ) :
          self.traiteMCSIMP=0
	  self.dictTempo={}
       s=PythonGenerator.generMCFACT(self,obj)
       self.listeFichiers.append(self.dictTempo)
       self.traiteMCSIMP=1
       return s

   def genereXML(self):
       print "IDM: genereXML dans generator_openturns_wrapper.py"
       #print "appli.maConfiguration=",self.appli.maConfiguration.__dict__
       if self.listeFichiers != [] :
          self.dictMCVal["Files"]=self.listeFichiers
       print "dictMCVal", self.dictMCVal, "dictVariables", self.dictVariables
       MonBaseGenerateur=Generateur(self.appli,self.dictMCVal, [], {} ,self.dictVariables)
       MonGenerateur=MonBaseGenerateur.getXMLGenerateur()
       try :
       #if 1== 1 :
          self.wrapperXML=MonGenerateur.CreeXML()
       except :
       #else :
	  self.wrapperXML=None

   def writeDefault(self, filename):
      fileXML = filename[:filename.rfind(".")] + '.xml'
      self.wrapperXML.writeFile( str(fileXML) )
