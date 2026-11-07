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
    python pour EFICAS.

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

import generator_python

def entryPoint():
   """
       Retourne les informations nécessaires pour le chargeur de plugins

       Ces informations sont retournées dans un dictionnaire
   """
   return {
        # Le nom du plugin
          'name' : 'python6',
        # La factory pour créer une instance du plugin
          'factory' : PythonGenerator,
          }


class PythonGenerator(generator_python.PythonGenerator):
   """
       Ce generateur parcourt un objet de type JDC et produit
       un fichier au format python6

       L'acquisition et le parcours sont réalisés par la méthode
       generator.gener(objet_jdc,format)

       L'écriture du fichier au format python6 par appel de la méthode
       generator.writefile(nom_fichier)

       Ses caractéristiques principales sont exposées dans des attributs 
       de classe :
         - extensions : qui donne une liste d'extensions de fichier préconisées

   """
   # Les extensions de fichier préconisées
   extensions=('.comm',)

   def generFORM_ETAPE(self,obj):
        """
            Méthode particulière pour les objets de type FORMULE
        """
        l=[]
        nom = obj.getNom()
        if nom == '' : nom = 'sansnom'
        l.append(nom + ' = FORMULE(')
        for v in obj.mc_liste:
            text=self.generator(v)
            l.append(v.nom+'='+text)
        l.append(');')
        return l

   def gen_formule(self,obj):
      """
           Méthode particuliere aux objets de type FORMULE
      """
      try:
        if obj.sd == None:
          sdname=''
        else:
          sdname= self.generator(obj.sd)
      except:
        sdname='sansnom'
      l=[]
      label=sdname + ' = FORMULE('
      l.append(label)
      for v in obj.mc_liste:
        s=''
        s= v.nom+':'+sdname+'('+v.valeur+')'
        l.append(s)
      if len(l) == 1:
        l[0]=label+');'
      else :
        l.append(');')
      return l
