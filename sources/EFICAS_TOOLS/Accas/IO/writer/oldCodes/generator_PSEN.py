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

from __future__ import absolute_import
try :
    from builtins import str
except : pass

texte_debut="int main() \n{ \n   init_var();\n"
texte_debut+='   format="med";\n'
import traceback
import types,re,os
from Accas.extensions.eficas_translation import tr
from .generator_dicoImbrique import DicoImbriqueGenerator

def entryPoint():
    """
       Retourne les informations necessaires pour le chargeur de plugins
       Ces informations sont retournees dans un dictionnaire
    """
    return {
         # Le nom du plugin
           'name' : 'PSEN',
         # La factory pour creer une instance du plugin
           'factory' : PSENGenerator,
           }


class PSENGenerator(DicoImbriqueGenerator):
    """
       Ce generateur parcourt un objet de type JDC et produit
       un texte au format eficas et
       un texte au format dictionnaire

    """
    # Les extensions de fichier permis?
    extensions=('.comm',)

#----------------------------------------------------------------------------------------
    def gener(self,obj,format='brut',config=None, appliEficas=None):

        try :
            self.MachineDico = obj.MachineDico
            self.LoadDico = obj.LoadDico
            self.LineDico = obj.LineDico
            self.TransfoDico = obj.TransfoDico
            self.MotorDico = obj.MotorDico
        except :
            self.MachineDico = None
            self.LoadDico = None
            self.LineDico = None
            self.TransfoDico = None
            self.MotorDico = None

        self.initDico()
        # Cette instruction genere le contenu du fichier de commandes (persistance)
        self.text=DicoImbriqueGenerator.gener(self,obj,format)
        return self.text


#----------------------------------------------------------------------------------------
# initialisations
#----------------------------------------------------------------------------------------

    def initDico(self) :
        DicoImbriqueGenerator.initDico(self)
        self.Entete = 'MachineDico = ' + str(self.MachineDico) +'\n'
        self.Entete += 'LoadDico = ' + str(self.LoadDico) +'\n'
        self.Entete += 'LineDico = ' + str(self.LineDico) +'\n'
        self.Entete += 'TransfoDico = ' + str(self.TransfoDico) +'\n'
        self.Entete += 'MotorDico = ' + str(self.MotorDico) + '\n'
        self.Entete +='\n'


#----------------------------------------------------------------------------------------
# ecriture
#----------------------------------------------------------------------------------------

    def writeDefault(self,fn) :
        fileDico=os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','PSEN_Eficas','PSEN','PSENconfig.py'))
        f = open( str(fileDico), 'wb')
        f.write( self.Entete + "Dico =" + str(self.Dico) )
        f.close()



#----------------------------------------------------------------------------------------
#  analyse de chaque noeud de l'arbre
#----------------------------------------------------------------------------------------

##   def generMCSIMP(self,obj) :
##        """recuperation de l objet MCSIMP"""
##        #print dir(obj)
##        self.dicoMCSIMP[obj.nom]=obj.val
##        self.dicoTemp[obj.nom]=obj.val
##        s=DicoImbriqueGenerator.generMCSIMP(self,obj)
##        return s
##
##   def generETAPE(self,obj):
##        self.dicoTemp={}
##        s=DicoImbriqueGenerator.generETAPE(self,obj)
##        if obj.nom=="DISTRIBUTION" : self.dicoLois[obj.sd.nom]=self.dicoTemp
##        self.dicoTemp={}
##        return s


# si repertoire on change tous les noms de fichier
