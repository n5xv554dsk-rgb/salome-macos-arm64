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
import Accas




#keys = ['Carmel3D_StudyDirectory','Syrthes_StudyDirectory']


def entryPoint():
   """
      Retourne les informations necessaires pour le chargeur de plugins
      Ces informations sont retournees dans un dictionnaire
   """
   return {
        # Le nom du plugin
          'name' : 'CARMELCS',
        # La factory pour creer une instance du plugin
          'factory' : CARMELCSGenerator,
          }


class CARMELCSGenerator(PythonGenerator):
   """
      Ce generateur parcourt un objet de type JDC et produit
      un texte au format eficas et 
      un texte au format dictionnaire

   """
   # Les extensions de fichier permis?
   extensions=('.comm',)

#----------------------------------------------------------------------------------------
   def gener(self,obj,format='brut',config=None):
       
      self.initDico()
      
      # Cette instruction genere le contenu du fichier de commandes (persistance)
      self.text=PythonGenerator.gener(self,obj,format)
      self.racine=obj
      return self.text

   def generxml(self,obj,format='brut',config=None):

      texte = self.gener(obj,format,config)
#      print 'self.dictMCVal = ',self.dictMCVal
      textePourRun = self.update_XMLYacsSchemaForRunning()
      return textePourRun
      
#----------------------------------------------------------------------------------------
# initialisations
#----------------------------------------------------------------------------------------
   
   def initDico(self) :
 
      self.texteDico = ""
      self.dictMCVal={}
      self.dicoCS={}
      self.debutKey = '__PARAM_CS__'

#----------------------------------------------------------------------------------------
# ecriture
#----------------------------------------------------------------------------------------

   def getdico(self) :
      #print 'getdico : self.dictMCVal.keys() = ',self.dictMCVal.keys()
      for k in self.dictMCVal.keys():
          if k.find (self.debutKey) > -1 :
            a,kproperty=k.split(self.debutKey)   
            self.dicoCS[kproperty] = self.dictMCVal[k]
      #print "self.dicoCS = ",self.dicoCS
      return self.dicoCS

   def getXMLYacsSchemaFileTemplate(self) :

      for k in self.dictMCVal.keys():
          if k.find (self.debutKey) > -1 :
            a,kproperty=k.split(self.debutKey)   
            if kproperty  ==   'XMLYacsFile' :
               return  self.dictMCVal[k]

   def getXMLYacsSchemaFileRun(self) :
       xmlYacsSchemaFilePath = self.getXMLYacsSchemaFileTemplate()
       filename = os.path.basename(xmlYacsSchemaFilePath)
       dirname  = os.path.dirname(xmlYacsSchemaFilePath)
       prefix = '_run_'
       runxmlfile = os.path.join(dirname,prefix+filename)
       return xmlYacsSchemaFilePath,runxmlfile

   def update_XMLYacsSchemaForRunning(self) :
       """
       Creation du fichier _run_XXX.xml, a partir des elements donnes par l'utilisateur dans l'interface :
       Carmel3D_StudyDirectory : YYY (path du repertoire de l'etude CARMEL3D de couplage)
       Syrthes_StudyDirectory : YYY/THERMIQUE (path du repertoire de l'etude SYRTHES de couplage)
       XMLYacsFile : PATH du fichier template du schema yacs d'execution du couplage
       """
       xmlYacsSchemaFilePath,runxmlfile = self.getXMLYacsSchemaFileRun()
       f_xml = open( str(xmlYacsSchemaFilePath), 'r')
       texte_template_xml = f_xml.read()
       f_xml.close()
       dicoCS = self.getdico()
       print "dicoCS = ",dicoCS
       # ajout dans dicoCS des elements pour SYRTHES qui sont deja sous cette forme la dans le fichier xml sinon ca pose pb
       dicoCS['DEB']='%(DEB)s'
       dicoCS['FIN']='%(FIN)s'
       newTexteXml = texte_template_xml%dicoCS
       f = open(runxmlfile,'w')
       f.write(newTexteXml)
       f.close()
       return runxmlfile

   def writeDefault(self,fn) :
       fileDico = fn[:fn.rfind(".")] + '.py'
       f = open( str(fileDico), 'wb')
       f.write( self.texteDico )
       f.close()
       runxmlfile = self.update_XMLYacsSchemaForRunning()

#----------------------------------------------------------------------------------------
#  analyse de chaque noeud de l'arbre 
#----------------------------------------------------------------------------------------

   def generMCSIMP(self,obj) :
        """recuperation de l objet MCSIMP"""
        s=PythonGenerator.generMCSIMP(self,obj)
        self.texteDico+=obj.nom+ "=" + s[0:-1]+ "\n"
#        print 'generMCSIMP self.texteDico = ',self.texteDico
        if hasattr(obj.etape,'sdnom'): clef=obj.etape.sdnom+"____"
        else: clef=""
        for i in obj.getGenealogie() :
            clef=clef+"__"+i
        self.dictMCVal[clef]=obj.valeur

        return s

  
