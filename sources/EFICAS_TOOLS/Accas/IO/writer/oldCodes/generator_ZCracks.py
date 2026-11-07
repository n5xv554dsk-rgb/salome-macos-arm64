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
from __future__ import print_function
try :
   from builtins import str
except : pass

import pickle
texte_debut="#include <Zcracks_base.z7p> \n int main() \n{ \n   init_var();\n"
texte_debut+='   format="med";\n'
import traceback
import types,re,os
from Accas.extensions.eficas_translation import tr
from .generator_python import PythonGenerator
#ListeConcatene=('ridge_names','topo_names','geom_names','elsetNames','fasetNames','lisetNames','nsetNames','center','normal','dir')
ListeConcatene=('ridge_names','topo_names','geom_names','elsetNames','fasetNames','lisetNames','nsetNames')
ListeConcatene2=('center','normal','dir')
ListeConcatene3=('ra','rb')
if_ellipse=False

def entryPoint():
   """
      Retourne les informations necessaires pour le chargeur de plugins
      Ces informations sont retournees dans un dictionnaire
   """
   return {
        # Le nom du plugin
          'name' : 'ZCRACKS',
        # La factory pour creer une instance du plugin
          'factory' : ZCrackGenerator,
          }


class ZCrackGenerator(PythonGenerator):
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
      return self.text


#----------------------------------------------------------------------------------------
# initialisations
#----------------------------------------------------------------------------------------
   
   def initDico(self) :
      self.textePourRun = texte_debut


#----------------------------------------------------------------------------------------
# ecriture
#----------------------------------------------------------------------------------------

   def writeDefault(self,fn) :
        fileZcrack = fn[:fn.rfind(".")] + '.z7p'
        f = open( str(fileZcrack), 'wb')
        print((self.textePourRun))
      
        self.ajoutRun()
        self.textePourRunAvecDouble=self.textePourRun.replace("'",'"')
        f.write( self.textePourRunAvecDouble)
        f.close()

   def ajoutRun(self) :
        self.textePourRun+="   write_mesh_crack();\n"
        self.textePourRun+="   do_mesh_crack(0);\n"
        self.textePourRun+="   write_refine_mesh();\n"
        self.textePourRun+="   do_refine_mesh(0);\n"
        self.textePourRun+="   write_cut_mesh();\n"
        self.textePourRun+="   do_cut_mesh(0);\n"
#        self.textePourRun+="   nice_cut("+str(self.maximum_aspect_ratio)+");\n"
        self.textePourRun+='   export_mesh("'+self.cracked_name+'","med");\n'
        self.textePourRun+="}"

#----------------------------------------------------------------------------------------
#  analyse de chaque noeud de l'arbre 
#----------------------------------------------------------------------------------------

   def generMCSIMP(self,obj) :
        """recuperation de l objet MCSIMP"""
        #print dir(obj)
        s=PythonGenerator.generMCSIMP(self,obj)
        if obj.nom=="sane_name" :
           self.textePourRun+='   import_mesh("'+obj.val+'", "med");\n'
        if obj.nom in ListeConcatene :
#           obj.val=obj.val+" "
           stringListe=""
           for val in obj.val:
               stringListe+=val+""
#           pickle.dump( stringListe, open( "/home/H60874/test.pickle", "wb" ) )
#           self.textePourRun+="   "+obj.nom+ "='"+ stringListe[0:-1]+ "';\n"
#           self.textePourRun+="   "+obj.nom+ "='"+ stringListe+ "';\n"
           return s
        if obj.nom in ListeConcatene3 :
           if (obj.nom=="ra") :
              self.textePourRun+="   "+"if_ellipse=1;\n" 
           self.textePourRun+="   "+obj.nom+ "="+str(obj.val)+";\n"
           if_ellipse_ellipse=True
           return s

        if obj.nom in ListeConcatene2 : 
           stringListe=""
#           self.textePourRun+="GGGGGGG%"+obj.nom+"\n"
#           if (len(val)>1) :
           for val in obj.val:
               stringListe+=str(val)+","
           self.textePourRun+="   "+obj.nom+ "=set_vector3("+ stringListe[0:-1]+ ");\n"
#           else :
#             self.textePourRun+="   "+obj.nom+ str(obj.val+ ";\n"
#               stringListe+=str(val)+" "
#           self.textePourRun+="   "+obj.nom+ "=set_vector3("+stringListe[0]+","+stringListe[1]+","+stringListe[2]+");\n"
#           self.textePourRun+="   "+obj.nom+ "=set_vector3("+obj.val+","+");\n"
           return s
#        if obj.nom=="center" :
#           self.textePourRun+="   set_vector3("+obj.val+'");\n"
#        if obj.nom=="center" :
#           self.textePourRun+="   set_vector3("+obj.val+'");\n"
#        if obj.nom=="normal" :
#           self.textePourRun+="   set_vector3("+obj.val+'");\n"
#        if obj.nom=="dir" :
#           self.textePourRun+="   set_vector3("+obj.val+'");\n"
        if obj.nom=="elset_radius" :
           self.textePourRun+="   if_must_define_elset=1;\n"


        if obj.nom=="cracked_name" : self.cracked_name=obj.val
        if obj.nom=="maximum_aspect_ratio" : self.maximum_aspect_ratio=obj.val
        if obj.nom=="repertoire" : 
           print ("PNPNPN a traiter")
           return s
        self.textePourRun+="   "+obj.nom+ "=" + s[0:-1]+ ";\n"
        return s

  
# si repertoire on change tous les noms de fichier
# exple repertoire='/home' __> fichier='/home/crack.med
