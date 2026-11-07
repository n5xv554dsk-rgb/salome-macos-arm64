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
    Ce module contient le plugin generateur de fichier au format pyth pour EFICAS.


"""
try :
   from builtins import str
   from builtins import object
except : pass

import traceback
import types

from Accas.processing import P_CR
from Accas import MCSIMP,MCFACT,MCList
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException


def entryPoint():
   """
       Retourne les informations necessaires pour le chargeur de plugins

       Ces informations sont retournees dans un dictionnaire
   """
   return {
        # Le nom du plugin
          'name' : 'pyth',
        # La factory pour creer une instance du plugin
          'factory' : PythGenerator,
          }


class PythGenerator(object):
   """
       Ce generateur parcourt un objet de type MCFACT et produit
       un fichier au format pyth

       L'acquisition et le parcours sont realises par la methode
       generator.gener(objet_mcfact)

       L'ecriture du fichier au format ini par appel de la methode
       generator.writefile(nom_fichier)

       Ses caracteristiques principales sont exposees dans des attributs 
       de classe :
          - extensions : qui donne une liste d'extensions de fichier preconisees

   """
   # Les extensions de fichier preconisees
   extensions=('.py','.comm')

   def __init__(self,cr=None):
      # Si l'objet compte-rendu n'est pas fourni, on utilise le compte-rendu standard
      if cr :
         self.cr=cr
      else:
         self.cr=P_CR.CR(debut='CR generateur format ini',
                         fin='fin CR format ini')
      # Le texte au format pyth est stocke dans l'attribut text
      self.text=''

   def writefile(self,filename):
      fp=open(filename,'w')
      fp.write(self.text)
      fp.close()

   def gener(self,obj,format='standard',config=None):
      """
         Tous les mots-cles simples du niveau haut sont transformes en variables 

         Tous les mots-cles facteurs sont convertis en dictionnaires

         Les mots-cles multiples ne sont pas traites
      """
      s=''
      if isinstance(obj,MCList):
        if len(obj.data) > 1:
          raise EficasException(tr("Pas supporte"))
        else:
          obj=obj.data[0]

      for mocle in obj.mc_liste:
        if isinstance(mocle,MCList):
          if len(mocle.data) > 1:
            raise EficasException(tr("Pas supporte"))
          else:
            valeur=self.generMCFACT(mocle.data[0])
            s=s+"%s = %s\n" % (mocle.nom,valeur)
        elif isinstance(mocle,MCFACT):
          valeur=self.generMCFACT(mocle)
          s=s+"%s = %s\n" % (mocle.nom,valeur)
        elif isinstance(v,MCSIMP):
          valeur = self.generMCSIMP(mocle)
          s=s+"%s = %s\n" % (mocle.nom,valeur)
        else:
          self.cr.fatal("Entite inconnue ou interdite : "+repr(mocle))

      self.text=s
      return self.text

   def generMCFACT(self,obj):
      """
         Cette methode convertit un mot-cle facteur 
         en une chaine de caracteres representative d'un dictionnaire
      """
      s = '{'
      for mocle in obj.mc_liste:
         if isinstance(mocle,MCSIMP):
            valeur = self.generMCSIMP(mocle)
            s=s+"'%s' : %s,\n" % (mocle.nom,valeur)
         elif isinstance(mocle,MCFACT):
            valeur=self.generMCFACT(mocle)
            s=s+"'%s' : %s,\n" % (mocle.nom,valeur)
         else:
            self.cr.fatal(tr("Entite inconnue ou interdite : %s. Elle est ignoree", repr(mocle)))

      s=s+'}'
      return s

   def generMCSIMP(self,obj):
      """
         Cette methode convertit un mot-cle simple en une chaine de caracteres
         au format pyth
      """
      try:
         s="%s" % obj.valeur
      except Exception as e :
         self.cr.fatal(tr("Type de valeur non supporte par le format pyth : n %(exception)s", \
                           {'nom': obj.nom, 'exception': str(e)}))


         s="ERREUR"
      return s

