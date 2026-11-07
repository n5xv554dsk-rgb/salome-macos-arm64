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
    Ce module contient le plugin generateur de fichier
    au format ini pour EFICAS.
"""
from __future__ import absolute_import
try :
   from builtins import str
   from builtins import object
except : pass

import traceback
import types
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException


from Accas.processing import P_CR
from Accas import MCSIMP,MCFACT,MCList

def entryPoint():
   """
       Retourne les informations necessaires pour le chargeur de plugins
       Ces informations sont retournees dans un dictionnaire
   """
   return {
        # Le nom du plugin
          'name' : 'ini',
        # La factory pour creer une instance du plugin
          'factory' : IniGenerator,
          }


class IniGenerator(object):
   """
       Ce generateur parcourt un objet de type MCFACT et produit
       un fichier au format ini 
       L'acquisition et le parcours sont realises par le methode
       generator.gener(objet_mcfact)
       L'ecriture du fichier au format ini par appel de la methode
       generator.writefile(nom_fichier)

       Ses caracteristiques principales sont exposees dans des attributs 
       de classe :
         - extensions : qui donne une liste d'extensions de fichier preconisees

   """
   # Les extensions de fichier preconisees
   extensions=('.ini','.conf')

   def __init__(self,cr=None):
      # Si l'objet compte-rendu n'est pas fourni, on utilise le compte-rendu standard
      if cr :
         self.cr=cr
      else:
         self.cr=P_CR.CR(debut='CR generateur format ini',
                         fin='fin CR format ini')
      # Le texte au format ini est stocke dans l'attribut text
      self.text=''

   def writefile(self,filename):
      fp=open(filename,'w')
      fp.write(self.text)
      fp.close()

   def gener(self,obj,config=None):
      """
         Tous les mots-cles simples du niveau haut sont mis dans la section DEFAUT
         Tous les mots-cles facteurs sont convertis en sections
         Un mot-cle facteur ne peut contenir que des mots-cles simples. Sinon => erreur
      """
      listeMcFact=[]
      sect_defaut=''
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
            listeMcFact.append(self.generMCFACT(mocle.data[0]))
        elif isinstance(mocle,MCFACT):
          listeMcFact.append(self.generMCFACT(mocle))
        elif isinstance(mocle,MCSIMP):
          sect_defaut=sect_defaut+self.generMCSIMP(mocle)
        else:
          self.cr.fatal(tr("Entite inconnue ou interdite :%s",repr(mocle)))

      self.text=''
      if sect_defaut != '':
         self.text="[DEFAULT]\n"+sect_defaut
      self.text=self.text + ''.join(listeMcFact,'\n')
      return self.text

   def generMCFACT(self,obj):
      """
         Cette methode convertit un mot-cle facteur ne contenant que des mots-cles
         simples en une chaine de caracteres
      """
      sect_text='[%s]\n' % obj.nom
      for mocle in obj.mc_liste:
         if isinstance(mocle,MCSIMP):
            sect_text=sect_text+self.generMCSIMP(mocle)
         else:
            self.cr.fatal(tr("Entite inconnue ou interdite :%s. Elle est ignoree",repr(mocle)))
      return sect_text

   def generMCSIMP(self,obj):
      """
         Cette methode convertit un mot-cle simple en une chaine de caracteres
         au format ini
      """
      s=''
      if type(obj.valeur) == tuple :
         self.cr.fatal(tr("Les tuples ne sont pas supportes pour le format ini :%s ", obj.nom))
         s="%s = %s\n" % (obj.nom,"ERREUR")
      else :
         try:
            s="%s = %s\n" % (obj.nom,obj.valeur)
         except Exception as e :
            self.cr.fatal(tr("Type de valeur non supportee par le format ini :%(nom)s\n%(exception)s", \
                                         {'nom': obj.nom, 'exception': str(e)}))
      return s

