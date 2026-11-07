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
   CARMEL3D pour EFICAS.

"""
from __future__ import print_function
from __future__ import absolute_import
try :
    from builtins import str
except : pass

import traceback
import types,re,os
import Accas

from .generator_python import PythonGenerator

def entryPoint():
    """
       Retourne les informations necessaires pour le chargeur de plugins

       Ces informations sont retournees dans un dictionnaire
    """
    return {
         # Le nom du plugin
           'name' : 'MAP',
         # La factory pour creer une instance du plugin
           'factory' : MapGenerator,
           }


class MapGenerator(PythonGenerator):
    """
       Ce generateur parcourt un objet de type JDC et produit
       un texte au format eficas et
       un texte au format py

    """

    def gener(self,obj,format='brut',config=None,appliEficas=None):
        self.initDico()
        self.text=PythonGenerator.gener(self,obj,format)
        if obj.isValid() :self.genereExeMap()
        return self.text


    def genereExeMap(self) :
        '''
        Prepare le contenu du fichier de parametres python
        peut ensuite etre obtenu au moyen de la fonction getTubePy().
        '''
        nomSpec="spec_"+self.schema
        self.texteEXE="from map.spec import %s;\n"%nomSpec
        self.texteEXE+="node=%s.new();\n"%nomSpec
        self.texteEXE+="node.getInputData();\n"
        self.texteEXE+="node.setInputData(%s);\n"%self.dictValeur
        self.texteEXE+="node.execute();\n"
        self.texteEXE+="res=node.getOutputData();\n"


    def initDico(self) :
        if not hasattr(self,'schema') : self.schema=""
        self.dictParam={}
        self.dictValeur={}

    def writeDefault(self, fn):
        fileEXE = fn[:fn.rfind(".")] + '.py'
        f = open( str(fileEXE), 'wb')
        f.write( self.texteEXE )
        f.close()

    def generMCSIMP(self,obj) :
        """
        Convertit un objet MCSIMP en texte python
        Remplit le dictionnaire des MCSIMP
        """

        if obj.getGenealogie()[0][-6:-1]=="_PARA":
            self.dictParam[obj.nom]=obj.valeur
        else :
            self.dictValeur[obj.nom]=obj.valeur
        s=PythonGenerator.generMCSIMP(self,obj)
        return s


    def generRUN(self,obj,schema):
        if not(obj.isValid()) :
            print ("TODO TODO TODO")
        self.texteEXE=""
        self.schema=schema
        textComm=self.gener(obj)
        return self.texteEXE
