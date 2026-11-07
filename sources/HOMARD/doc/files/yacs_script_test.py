#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (C) 2013-2026  CEA, EDF
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
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
Pseudo-lancement d'un calcul pour valider les tests
"""
__revision__ = "V2.2"
#
import sys
import os
#
class Script :
#
  """
Mode d'emploi :
==============
yacs_script_test --rep_calc=rep_calc --mesh_file=mesh_file --num=nro [-h|-help] [-v] [-v_max]

Arguments obligatoires :
------------------------
--rep_calc=rep_calc : le repertoire du calcul.
--mesh_file=mesh_file : le fichier contenant le maillage sur lequel on veut calculer. Le nom est absolu ou relatif par rapport au repertoire de calcul ou a $HOME.
--num=nro : le numero du calcul, depuis 0.

Exemples :
----------
./yacs_script_test.py --rep_calc=`pwd` --mesh_file=maill.00.med --num=0
  """
#
#====
# 0. Les defauts
#====
#
  affiche_aide_globale = 0
  verbose = 0
  verbose_max = 0
#
  message_info = "\n"
#
#
#========================= Debut de la fonction ==================================
#
  def __init__ ( self, liste_arg ) :
#
    """
Le constructeur de la classe Script
    """
#
# 1. Decodage des arguments
#
    self.rep_calc = None
    self.numero = None
    self.mesh_file = None
#
    for argu in liste_arg :
#
      #print argu
      l_aux = argu.split("=")
      #print l_aux
      if len(l_aux) == 2 :
        #print l_aux[0]
        #print l_aux[1]
        if l_aux[0] == "--rep_calc" :
          self.rep_calc = l_aux[1]
        elif l_aux[0] == "--num" :
          self.numero = int(l_aux[1])
        elif l_aux[0] == "--mesh_file" :
          self.mesh_file = l_aux[1]
      else :
        saux = argu.upper()
        if saux in ( "-H", "-HELP" ) :
          self.affiche_aide_globale = 1
        elif saux == "-V" :
          self.verbose = 1
        elif saux in ( "-V_MAX", "-VMAX" ) :
          self.verbose = 1
          self.verbose_max = 1
#
# 2. Les paramètres de base
#
    self.dico = {}
#
    if self.verbose_max :
      nom_fonction = __name__ + "/__init__"
      print("\nDans " + nom_fonction + ",")
      print(". rep_calc       :", self.rep_calc)
      print(". mesh_file      :", self.mesh_file)
      print(". numero         :", self.numero)
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
  def compute ( self ) :
#
    """
Lancement d'un calcul
    """
#
    nom_fonction = __name__ + "/compute"
    blabla = "\nDans " + nom_fonction + ","
#
    erreur = 0
    message_erreur = " "
#
    dico_resu = {}
#
    while not erreur :
#
# 1. Controles des arguments
#
      #print "\n==== self.controle_argument () ===="
      erreur, message_erreur = self.controle_argument()
      if erreur :
        break
#
# 2. Pseudo-Calcul
#
      #print "\n==== self.calcul () ===="
      dico_resu["FileName"] = self.mesh_file
      dico_resu["V_TEST"] = 1./float(self.numero+1)
#
      break
#
    if self.verbose_max :
      print(blabla)
      print(". erreur :", erreur)
#
    return erreur, message_erreur, dico_resu
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
  def controle_argument ( self ) :
#
    """
Controle les arguments et stockage de quelques informations
    """
#
    messages_erreur = { 0 : None,
                       -1 : "Quel repertoire de calcul ?",
                       -3 : "Quel fichier de maillage ?",
                       -4 : "Ce repertoire est inconnu.",
                       -5 : "Ce fichier est inconnu.",
                       -9 : "Quel numero de calcul ?" }
#
    nom_fonction = __name__ + "/controle_argument"
    blabla = "\nDans " + nom_fonction + ","
#
    erreur = 0
    message_erreur = " "
#
    if self.verbose_max :
      print(blabla)
      print(". rep_calc       :", self.rep_calc)
      print(". mesh_file      :", self.mesh_file)
      print(". numero         :", self.numero)
#
    while not erreur :
#
# 1. Les repertoire et fichier
# 1.1. Il y a bien eu une donnee
#
      if self.rep_calc == None :
        erreur = -1
      elif self.mesh_file == None :
        erreur = -3
      if erreur < 0 :
        self.message_info += "Relancer avec -h pour avoir le mode d'emploi."
        break
#
# 1.2. Le repertoire de calcul
#
      self.rep_calc = os.path.expanduser(self.rep_calc)
      if not os.path.isdir(self.rep_calc) :
        self.message_info += "Repertoire " + self.rep_calc
        erreur = -4
        break
      else :
        aux = os.path.join(os.getcwd(), self.rep_calc)
        self.rep_calc = os.path.normpath(aux)
#
# 1.3. Les fichiers
#
      fic = self.mesh_file
#
      fic = os.path.expanduser(fic)
      if not os.path.isfile(fic) :
        aux = os.path.join(self.rep_calc, fic)
        if not os.path.isfile(aux) :
          self.message_info += "Fichier : " + fic
          erreur = -5
          break
        else :
          fic = os.path.normpath(aux)
      aux = os.path.join(os.getcwd(), fic)
#
      self.mesh_file = os.path.normpath(aux)
#
# 2. Le numero du calcul
#
      if self.numero == None :
        erreur = -9
#
      break
#
    if erreur :
      message_erreur = messages_erreur[erreur]
#
    if self.verbose_max :
      print(". rep_calc  :", self.rep_calc)
      print(". mesh_file :", self.mesh_file)
#
    return erreur, message_erreur
#
#=========================  Fin de la fonction ===================================
#
#
if __name__ == "__main__" :
#
  #print "Arguments a l'entree de",  sys.argv[0], ":", sys.argv[1:], "\n"
#
  Script_A = Script(sys.argv[1:])
#
  if Script_A.affiche_aide_globale :
    Script_A.message_info = Script_A.__doc__
    erreur_m = 0
    message_erreur_m = ""
  else :
    dico_resu_m = {}
    erreur_m, message_erreur_m, dico_resu_m = Script_A.compute ()
#
  sys.stdout.write(Script_A.message_info+"\n")
  sys.stderr.write(message_erreur_m+"\n")
  sys.exit(erreur_m)
