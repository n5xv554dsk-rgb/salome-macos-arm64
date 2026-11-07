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
Lancement d'un calcul ASTER
"""
__revision__ = "V5.11"
#
import sys
import os
import tempfile
import time
#
# ==== Debut de personnalisation ====
#
# opt1_defaut, opt2_defaut : les valeurs par defaut de ces options, selon les cas
opt1_defaut = {}
opt2_defaut = {}
#
# ==== Fin de personnalisation ====
#
class Script :
#
  """
Mode d'emploi :
==============

Cette procedure lance un calcul Aster. Avant de lancer ce script, il faut avoir cree un repertoire pour le calcul. Apres un premier calcul, qui aura ete lance traditionnellement, on aura copie le fichier '*export' sous le nom 'calcul.ref.export' dans ce repertoire.

Le mode de lancement est le suivant :

ScriptAster --rep_calc=rep_calc --mesh_file=mesh_file --num=nro [-dump] [-tr [--opt1=inst_deb] [--opt2=inst_fin]] [-h|-help] [-v] [-v_max]

Arguments obligatoires :
------------------------
--rep_calc=rep_calc : le repertoire du calcul.
--mesh_file=mesh_file : le fichier contenant le maillage sur lequel on veut calculer. Le nom est absolu ou relatif par rapport au repertoire de calcul ou a $HOME.
--num=nro : le numero du calcul, depuis 0.

Options supplementaires, selon les cas :
----------------------------------------
. Pour un cas transitoire avec changement des instants de debut et fin :
On doit faire le choix -tr
Les numeros des instants varient de 0 a N. On fournit le numero ou l'instant selon les commandes.
--opt1=inst_deb : le numero ou l'instant initial ; si absent, on prend 0.
--opt2=inst_fin : le numero ou l'instant final ; si absent, on va jusqu'au bout du transitoire.
. Pour l'excavation :
--opt1=nro_couche : le numero de la couche ; si absent, on prend 1.
--opt2=nro_adap : le nombre d'adaptations deja realisees pour la couche ; si absent, on prend 0.
. Pour les autres cas :
Aucune option supplementaire.

Arguments optionnels :
----------------------
--tr=1 : le calcul est transitoire et on change les instants ; par defaut, pas de changement.
--wait=wait : temps d'attente en secondes entre deux examens de l'etat d'un calcul batch ; si absent, on prend 10.
-dump : produit le fichier dump du fichier med de resultats ; par defaut, pas de dump.

-h|-help : produit l'aide, quels que soient les autres arguments
-v : mode verbeux simple
-v_max : mode verbeux intensif

Exemples :
----------
./ScriptAster.py --rep_calc=`pwd` --mesh_file=maill.00.med --num=0 -dump
./ScriptAster.py --rep_calc=/scratch/D68518/HOMARD_SVN/trunk/training/tet_aster_ther --mesh_file=/scratch/D68518/Salome/Adapt/resu/maill.02.med --num=2
  """
#
#====
# 0. Les defauts
#====
# 0.1. ==> Les constantes de la machine
#
  info_gene = os.uname()
  #print info_gene
#
  machine = info_gene[1]
  serveur = machine
  mclient = machine
#
# 0.2. ==> Le user
#
  if "LOGNAME" in os.environ :
    user = os.environ ["LOGNAME"]
  else :
    user = "salome"
  username = user
  uclient = user
#
# 0.3. ==> Le lancement d'Aster
#
  aster_root = None
#
  nomjob = None
  mode = None
# Attente en secondes entre deux controles du job
  attente = "10"
#
# 0.4. ==> Information
#
  affiche_aide_globale = 0
  verbose = 0
  verbose_max = 0
  dump = 0
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
    self.opt1 = None
    self.opt2 = None
    self.version = None
    self.tr = 0
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
        elif l_aux[0] == "--tr" :
          self.tr = l_aux[1]
        elif l_aux[0] == "--opt1" :
          self.opt1 = l_aux[1]
        elif l_aux[0] == "--opt2" :
          self.opt2 = l_aux[1]
        elif l_aux[0] == "--wait" :
          self.attente = l_aux[1]
        elif l_aux[0] == "--version" :
          self.version = l_aux[1]
      else :
        saux = argu.upper()
        if saux in ( "-H", "-HELP" ) :
          self.affiche_aide_globale = 1
        elif saux == "-V" :
          self.verbose = 1
        elif saux in ( "-V_MAX", "-VMAX" ) :
          self.verbose = 1
          self.verbose_max = 1
        elif saux == "-DUMP" :
          self.dump = 1
#
# 2. Les paramètres de base
#
    self.dico = {}
    self.nomfic_export = None
    self.nomcas = ""
    self.numero_str = None
#
    if self.verbose_max :
      nom_fonction = __name__ + "/__init__"
      print("\nDans " + nom_fonction + ",")
      print(". rep_calc       :", self.rep_calc)
      print(". mesh_file      :", self.mesh_file)
      print(". numero         :", self.numero)
      print(". opt1           :", self.opt1)
      print(". opt2           :", self.opt2)
      print(". attente        :", self.attente)
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
# 1. Preparation du calcul
#
      #print "\n==== self.prepa_calcul () ===="
      erreur, message_erreur = self.prepa_calcul ()
      if erreur :
        break
#
# 2. Calcul
#
      #print "\n==== self.calcul () ===="
      erreur, message_erreur, fic_caract, fic_caract_2 = self.calcul ()
      #print "erreur en sortie de self.calcul :", erreur
      if erreur :
        break
#
# 3. Attente
#
      #print "\n==== calcul_aster_attente.calcul (",fic_caract,") ===="
      erreur, message_erreur = self.calcul_aster_attente (fic_caract)
      if erreur :
        break
      os.remove(fic_caract)
      os.remove(fic_caract_2)
#
# 4. Gestion du resultat
#
      #print "\n==== self.post_aster (dico_resu) ===="
      erreur, message_erreur, dico_resu = self.post_aster (dico_resu)
      if erreur :
        break
#
# 5. Dump eventuel
#
      if self.dump :
        #print "\n==== self.dump_resultat() ===="
        erreur, message_erreur = self.dump_resultat ()
        if erreur :
          break
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
  def prepa_calcul ( self ) :
#
    """
Preparation d'un calcul
    """
#
    nom_fonction = __name__ + "/prepa_calcul"
    blabla = "\nDans " + nom_fonction + ","
#
    erreur = 0
    message_erreur = " "
#
    if self.verbose_max :
      print(blabla)
      print(". rep_calc       :", self.rep_calc)
      print(". mesh_file      :", self.mesh_file)
      print(". tr             :", self.tr)
#
    while not erreur :
#
# 1. Controles des arguments
#
      erreur, message_erreur = self.controle_argument()
      if erreur :
        break
#
# 2. Modification du fichier export
#
      erreur, message_erreur = self.modif_export()
      if erreur :
        break
#
# 3. Modifications du fichier de commandes
# 3.1. Pour un cas transitoire
#
      if self.tr :
        erreur, message_erreur = self.modif_cas_transitoire()
        if erreur :
          break
#
# 3.2. Pour l'excavation
#
      elif self.nomcas[:6] == "couche" :
        erreur, message_erreur = self.modif_cas_excavation()
        if erreur :
          break
#
      break
#
    if self.verbose_max :
      print(blabla, "a la fin")
      print(". erreur :", erreur)
#
    return erreur, message_erreur
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
                       -8 : "Quel temps d'attente ?",
                       -9 : "Quel numero de calcul ?",
                      -20 : "Numeros de pas de temps invalides.",
                      -30 : "Numero de couche invalide.",
                      -31 : "Numero d'adaptation invalide." }
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
      print(". tr             :", self.tr)
      print(". opt1           :", self.opt1)
      print(". opt2           :", self.opt2)
      print(". attente        :", self.attente)
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
# 2. On en deduit le cas
#
      self.nomcas = os.path.basename(self.rep_calc)
      if self.verbose_max :
        print(". Cas :", self.nomcas)
#
# 3. Le temps d'attente
#
      iaux = None
      try :
        iaux = int(self.attente)
      except :
        erreur = -8
        break
      self.attente = iaux
#
# 4. Le numero du calcul
#
      if self.numero == None :
        erreur = -9
#
      if ( self.numero < 100 ) :
        self.numero_str = "%02d" % self.numero
      elif ( self.numero < 1000 ) :
        self.numero_str = "%03d" % self.numero
      elif ( self.numero < 10000 ) :
        self.numero_str = "%04d" % self.numero
      else :
        self.numero_str = "%d" % self.numero
#
# 5. Options speciales pour les cas transitoires et pour l'excavation
#
      if ( self.tr or ( self.nomcas[:6] == "couche" ) ) :
#
        if self.opt1 == None :
          self.opt1 = opt1_defaut[self.nomcas]
          #print ". opt1 defaut :", self.opt1
#
        if self.opt2 == None :
          self.opt2 = opt2_defaut[self.nomcas]
          #print ". opt2 defaut :", self.opt2
#
# 5.1. Pour un cas transitoire
#
      if self.tr :
#
        iaux1 = None
        daux1 = None
        try :
          iaux1 = int(self.opt1)
        except :
          daux1 = float(self.opt1)
        if ( iaux1 == 0 ) :
          daux1 = 0.
#
        iaux2 = None
        daux2 = None
        try :
          iaux2 = int(self.opt2)
        except :
          daux2 = float(self.opt2)
#
        if ( ( daux1 == None ) or  ( daux2 == None ) ) :
          #print "------------ ( daux1 == None ) or  ( daux2 == None ) ------------"
          #print "iaux1, iaux2 =", iaux1, iaux2
          if iaux2 < iaux1 :
            erreur = -20
        elif ( ( iaux1 == None ) or  ( iaux2 == None ) ) :
          #print "------------ ( iaux1 == None ) or  ( iaux2 == None ) ------------"
          #print "daux1, daux2 =", daux1, daux2
          if daux2 < daux1 :
            erreur = -20
        else :
          erreur = -20
#
        if erreur :
          self.message_info += "opt1 = " + self.opt1
          self.message_info += "\nopt2 = " + self.opt2
#
# 5.2. Pour l'excavation
#
      elif self.nomcas[:6] == "couche" :
#
        iaux1 = None
        try :
          iaux1 = int(self.opt1)
        except :
          erreur = -30
#
        if ( ( iaux1 < 1 ) or ( iaux1 > 20 ) ) :
          #print "iaux1 =", iaux1
          erreur = -30
#
        iaux2 = None
        try :
          iaux2 = int(self.opt2)
        except :
          erreur = -31
#
        if ( iaux2 < 0 ) :
          #print "iaux1 =", iaux1
          erreur = -31
#
        if erreur :
          self.message_info += "nro_mail = " + self.numero
          self.message_info += "\nopt1 = " + self.opt1
          self.message_info += "\nopt2 = " + self.opt2
          break
#
        self.nro_couche = iaux1
        self.nro_adap = iaux2
#
      break
#
    if erreur :
      message_erreur = messages_erreur[erreur]
#
    if self.verbose_max :
      print(". rep_calc  :", self.rep_calc)
      print(". mesh_file :", self.mesh_file)
      print(". opt1      :", self.opt1)
      print(". opt2      :", self.opt2)
#
    return erreur, message_erreur
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
  def modif_export ( self ) :
#
    """
Modification du fichier export et reperage de quelques informations
    """
#
    messages_erreur = { 0 : None }
#
    nom_fonction = __name__ + "/modif_export"
    blabla = "\nDans " + nom_fonction + ","
#
    erreur = 0
    message_erreur = " "
#
    if self.verbose_max :
      print(blabla)
      print(". numero     :", self.numero)
      print(". mesh_file  :", self.mesh_file)
#
    while not erreur :
#
# 1. Lecture du fichier export original
#
      fic_export_ref = os.path.join(self.rep_calc, "calcul.ref.export")
      fic = open (fic_export_ref, "r")
      les_lignes = fic.readlines()
      fic.close()
#
# 2. Ouverture du nouveau fichier export
#
      nomfic = "calcul"
      if self.nomcas[:6] == "couche" :
        nomfic += ".%02d" % self.nro_couche
      nomfic += "." + self.numero_str + ".export"
      self.nomfic_export = os.path.join(self.rep_calc, nomfic)
      if self.verbose_max :
        print(". nouveau fic_export :", self.nomfic_export)
      fic = open (self.nomfic_export, "w")
#
# 3. Exploration des lignes
#
      for ligne in les_lignes :
#
# 3.1. Pas de modification, a priori
#
        ligne_bis = ligne
        saux = ""
#
# 3.2. Decodage des composants de la ligne pour un fichier
#
        if ligne[0:2] == "F " :
#
          chgt = False
#
          laux = ligne.split()
          #print laux
          typfic = laux[1]
          statut = laux[3]
          #print typfic
#
          nomfic_0 = laux[2]
          if ( ":" in nomfic_0 ) :
            laux1 = nomfic_0.split(":")
            saux = laux1[0] + ":"
            nomfic_0 = laux1[1]
#
# 3.2.1. Si c'est le fichier de commandes, mise a jour du nom du repertoire
#
          if ( typfic == "comm" ) :
#
            if self.verbose_max :
              print(". Commandes : mise a jour du nom du repertoire")
            chgt = True
            nomfic_l_0 = os.path.basename(nomfic_0)
            nomfic = os.path.join(self.rep_calc, nomfic_l_0)
#
# 3.2.2. Si c'est un fichier de resultats ou le fichier de maillage, mise a jour du nom
#
          elif ( ( statut == "R" ) or ( typfic == "mmed" ) ) :
            if self.verbose_max :
              print(". Mise a jour du nom")
            chgt = True
#
# 3.2.2.1. Le fichier de maillage est celui passe en argument
#
            if typfic == "mmed" :
              nomfic = self.mesh_file
#
# 3.2.2.2. Pour les autres fichiers, on recupère le nom initial
#
            else :
              nomfic_l_0 = os.path.basename(nomfic_0)
              laux1 = nomfic_l_0.split(".")
              #print "laux1 =", laux1
#
# 3.2.2.2.1. Base des noms de fichiers si excavation
#
              if laux1[0] == "couche_n" :
                saux0 = "couche_%02d" % self.nro_couche
              else :
                iaux = len(laux1[-1]) + 1
                saux0 = nomfic_l_0[:-iaux]
              #print "saux0 =", saux0
#
# 3.2.2.2.2. Indicage des fichiers
#
              nomfic_l = saux0 + "." + self.numero_str + "." + laux1[-1]
              nomfic_l_1 = os.path.dirname(nomfic_0)
              nomfic = os.path.join(nomfic_l_1, nomfic_l)
            #print "   ==> ", nomfic
#
          if chgt :
            ligne_bis  = laux[0] + " " + laux[1] + " " + saux
            ligne_bis += nomfic + " "
            ligne_bis += laux[3] + " " + laux[4] + "\n"
#
# 3.2.2.3. On detruit preventivement les fichiers des resultats
#
          if ( statut == "R" ) :
            if ( self.nomcas[:6] != "couche" ) :
              if os.path.isfile(nomfic) :
                os.remove(nomfic)
#
# 3.2.3. Memorisation des noms
#
          self.dico[typfic] = nomfic
#
# 3.3. Decodage des composants de la ligne pour la base
#
        elif ligne[0:2] == "R " :
#
          laux = ligne.split()
          #print laux
          typfic = laux[1]
          #print typfic
#
# 3.3.1. Si c'est le fichier de la base, on recupere le nom initial, en ajustant l'indice
#
          if typfic in ( "base", "bhdf" ) :
#
            nomfic_0 = laux[2]
            if ( ":" in nomfic_0 ) :
              laux1 = nomfic_0.split(":")
              saux = laux1[0] + ":"
              nomfic_0 = laux1[1]
            nomfic_l_0 = os.path.basename(nomfic_0)
            laux1 = nomfic_l_0.split(".")
            if len(laux1) >= 3 :
              nomfic_l = laux1[0] + "." + self.numero_str + "." + laux1[2]
            elif len(laux1) >= 2 :
              if laux1[0] == "couche_nm1" :
                saux0 = "couche_%02d" % (self.nro_couche-1)
              elif laux1[0] == "couche_n" :
                saux0 = "couche_%02d" % self.nro_couche
              else :
                saux0 = laux1[0]
              nomfic_l = saux0 + "." + laux1[1]
            else :
              nomfic_l = nomfic_l_0
            nomfic_l_1 = os.path.dirname(nomfic_0)
            nomfic = os.path.join(nomfic_l_1, nomfic_l)
#
            ligne_bis  = laux[0] + " " + laux[1] + " " + saux
            ligne_bis += nomfic + " "
            ligne_bis += laux[3] + " " + laux[4] + "\n"
#
# 3.4. Decodage des composants de la ligne pour un parametre
#
        elif ligne[0:2] == "P " :
#
          laux = ligne.split()
          #print laux
          if ( len(laux) == 3 ) :
            aux = laux[2]
            if laux[1] in ( "username" ) :
              self.username = aux
            elif laux[1] in ( "uclient" ) :
              self.uclient = aux
            elif laux[1] in ( "aster_root" ) :
              self.aster_root = aux
            elif laux[1] in ( "serveur" ) :
              self.serveur = aux
            elif laux[1] in ( "mclient" ) :
              self.mclient = aux
            #elif laux[1] in ( "display" ) :
              #aux = self.machine+":0.0"
            elif laux[1] in ( "nomjob" ) :
              self.nomjob = aux
            elif laux[1] in ( "mode" ) :
              self.mode = aux
            ligne_bis  = laux[0] + " " + laux[1] + " " + aux  + "\n"
#
# 3.5. Ecriture de la ligne
#
        fic.write(ligne_bis)
#
      fic.close()
#
      break
#
    if erreur :
      message_erreur = messages_erreur[erreur]
#
    if self.verbose_max :
      print(". mclient    ", self.mclient)
      print(". uclient    ", self.uclient)
      print(". serveur    ", self.serveur)
      print(". username   ", self.username)
      print(". aster_root ", self.aster_root)
      print(". nomjob     ", self.nomjob)
      print(". mode       ", self.mode)
#
    return erreur, message_erreur
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
  def modif_cas_transitoire ( self ) :
#
    """
Modification du fichier de commandes lie au cas transitoire
    """
#
    messages_erreur = { 0 : None,
                        2 : "Mot_cle inconnu dans les commandes." }
#
    nom_fonction = __name__ + "/modif_cas_transitoire"
    blabla = "\nDans " + nom_fonction + ","
#
    erreur = 0
    message_erreur = " "
#
    if self.verbose_max :
      print(blabla)
      print(". opt1 :", self.opt1)
      print(". opt2 :", self.opt2)
#
    while not erreur :
#
# 1. Lecture du fichier de commandes
#
      nomfic = os.path.join(self.rep_calc, self.dico["comm"])
      fic = open (nomfic, "r")
      les_lignes = fic.readlines()
      fic.close()
#
# 2. Ouverture du nouveau fichier de commandes
#
      fic = open (nomfic, "w")
#
# 3. Exploration des lignes
#
# 3.0. Reperage de la zone a modifier
#
      A_modifier = 0
#
      for ligne in les_lignes :
#
        if self.verbose_max :
          print("ligne =", ligne[:-1])
#
# 3.1. Pas de modification, a priori
#
        ligne_bis = ligne
#
# 3.2. Reperage de la zone a modifier
#
        if ( "A PERSONNALISER - DEBUT" in ligne ) :
          A_modifier = 1
        elif ( "A PERSONNALISER - FIN" in ligne ) :
          A_modifier = 0
#
# 3.3. Modification
#
        #print "A_modifier =", A_modifier
        if A_modifier :
#
          #print "ligne =", ligne[:-1]
          for iaux in range(2) :
            if iaux == 0 :
              mot_cle_ref = "NUME_INST_"
              lg_mot_cle = 10
            else :
              mot_cle_ref = "INST_"
              lg_mot_cle = 5
            #print "mot_cle_ref =", mot_cle_ref
#
            if ligne[0:lg_mot_cle] == mot_cle_ref :
#
              if ligne[lg_mot_cle:lg_mot_cle+4] == "INIT" :
                aux = self.opt1
                motcle = ligne[0:lg_mot_cle+4]
              elif ligne[lg_mot_cle:lg_mot_cle+3] == "FIN" :
                aux = self.opt2
                motcle = ligne[0:lg_mot_cle+3]
              else :
                self.message_info += ligne
                erreur = 2
                break
#
              ligne_bis = motcle + " = " + str(aux) +"\n"
#
          if erreur :
            break
#
# 3.4. Ecriture de la ligne
#
        fic.write(ligne_bis)
#
      fic.close()
#
      break
#
# 4. Gestion des erreurs
#
    if erreur :
      message_erreur = messages_erreur[erreur]
#
    return erreur, message_erreur
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
  def modif_cas_excavation ( self ) :
#
    """
Modification du fichier de commandes lie au cas de l'excavation
    """
#
    messages_erreur = { 0 : None }
#
    nom_fonction = __name__ + "/modif_cas_excavation"
    blabla = "\nDans " + nom_fonction + ","
#
    erreur = 0
    message_erreur = " "
#
    if self.verbose_max :
      print(blabla)
      print(". numero     :", self.numero)
      print(". nro_couche :", self.nro_couche)
      print(". nro_adap   :", self.nro_adap)
#
    while not erreur :
#
# 1. Lecture du fichier de commandes
#
      nomfic = os.path.join(self.rep_calc, self.dico["comm"])
      fic = open (nomfic, "r")
      les_lignes = fic.readlines()
      fic.close()
#
# 2. Ouverture du nouveau fichier de commandes
#
      fic = open (nomfic, "w")
#
# 3. Exploration des lignes
#
# 3.0. Reperage de la zone a modifier
#
      A_modifier = 0
#
      for ligne in les_lignes :
#
        if self.verbose_max :
          print("ligne =", ligne[:-1])
#
# 3.1. Pas de modification, a priori
#
        ligne_bis = ligne
#
# 3.2. Reperage de la zone a modifier
#
        if ( "A PERSONNALISER - DEBUT" in ligne ) :
          A_modifier = 1
        elif ( "A PERSONNALISER - FIN" in ligne ) :
          A_modifier = 0
#
# 3.3. Modification
#
        #print "A_modifier =", A_modifier
        if A_modifier :
#
          #print "ligne =", ligne[:-1]
          for iaux in range(3) :
            if iaux == 0 :
              mot_cle_ref = "nro_mail"
              lg_mot_cle = 8
              aux = self.numero
            elif iaux == 1 :
              mot_cle_ref = "nro_couche"
              lg_mot_cle = 10
              aux = self.nro_couche
            elif iaux == 2 :
              mot_cle_ref = "nro_adap"
              lg_mot_cle = 8
              aux = self.nro_adap
            #print "mot_cle_ref =", mot_cle_ref
#
            if ligne[0:lg_mot_cle] == mot_cle_ref :
              #print "==> aux =", aux, type(aux)
              ligne_bis = mot_cle_ref + " = " + str(aux) +"\n"
#
# 3.4. Ecriture de la ligne
#
        fic.write(ligne_bis)
#
      fic.close()
#
      break
#
# 4. Gestion des erreurs
#
    if erreur :
      message_erreur = messages_erreur[erreur]
#
    return erreur, message_erreur
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
  def calcul ( self ) :
#
    """
Lancement d'un calcul
    """
#
    messages_erreur = { 0 : None }
#
    nom_fonction = __name__ + "/calcul"
    blabla = "\nDans " + nom_fonction + ","
#
    erreur = 0
    message_erreur = " "
#
    if self.verbose_max :
      print(". mclient    ", self.mclient)
      print(". serveur    ", self.serveur)
#
# 1. Copie du fichier export sur le serveur de calcul
#
    if ( self.mclient != self.serveur ) :
#
      nomfic_export_dist = self.nomjob + ".export"
      commande = "scp " + self.nomfic_export + " " + self.username + "@" + self.serveur + ":" + nomfic_export_dist
      if self.verbose_max :
        print("Copie du fichier export vers", self.serveur, ":")
        print(commande)
      erreur = os.system(commande)
#
# 2. Commande du lancement
#
    commande_base  = os.path.join(self.aster_root, "bin", "as_run")
    commande_base += " "
    if self.mode == "batch" :
      commande_base += "--serv "
    commande_base += self.username + "@" + self.serveur + ":"
    #if self.verbose_max :
      #print commande_base
#
    t_aux = tempfile.mkstemp()
    fic_caract   = t_aux[1]
    t_aux = tempfile.mkstemp()
    fic_caract_2 = t_aux[1]
#
# 3. Lancement
# 3.1. Commande finale
#
    if ( self.mclient == self.serveur ) :
      commande  = commande_base
      commande += commande_base + self.nomfic_export
    else :
      commande  = "ssh " + self.username + "@" + self.serveur
      commande += " \"" + commande_base + nomfic_export_dist + "\""
    commande += " 1>" + fic_caract
    commande += " 2>" + fic_caract_2
    if self.verbose_max :
      print("Lancement sur", self.serveur, ":")
      print(commande)
#
# 3.2. Lancement vrai
#
    erreur = os.system(commande)
    if erreur :
      messages_erreur[erreur] = "erreur de calcul numero %d" % erreur
    else :
      self.message_info += "resultat dans le fichier :\n"
      #print self.dico
      self.message_info += self.dico["rmed"]+"\n"
#
    if self.verbose_max :
      print(blabla)
      print(". erreur     :", erreur)
      print(". self.mode  :", self.mode)
      print(". fic_caract :", fic_caract)
#
    if erreur :
      message_erreur = messages_erreur[erreur]
#
    return erreur, message_erreur, fic_caract, fic_caract_2
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
  def calcul_aster_attente ( self, fic_caract ) :
#
    """
Bilan du calcul Aster
fic_caract : fichier caracteristique du job
    """
#
    nom_fonction = __name__ + "/calcul_aster_attente"
    blabla = "\nDans " + nom_fonction + ","
#
    erreur = 0
    message_erreur = " "
#
    if self.verbose_max :
      print(". fic_caract :", fic_caract)
      print(". nomjob     :", self.nomjob)
      print(". rep_calc   :", self.rep_calc)
      print(". mode       :", self.mode)
      print(". attente    :", self.attente)
#
    if ( self.mode != "interactif" ) :
#
# 1. Recuperation du numero de job
#
      fic = open (fic_caract, "r")
      les_lignes = fic.readlines()
      fic.close()
  #
      for ligne in les_lignes :
        #print ligne
        if ( len(ligne)>0 ) :
          # en batch :
          if "JOBID" in ligne :
            #print ligne
            laux = ligne.split()
            laux1 = laux[0].split("=")
            numjob = laux1[1]
          # en interactif :
          elif "num_job" in ligne :
            #print ligne
            laux = ligne.split("num_job")
            laux1 = laux[1].split()
            numjob = laux1[0]
  #
      if self.verbose :
        print(". numjob :", numjob)
#
# 2. Commande de l'examen de l'etat du job,
#
      fic_etat = os.path.join(self.rep_calc, self.nomjob+".etat")
      t_aux = tempfile.mkstemp()
      fic_etat_2   = t_aux[1]
      commande_base  = os.path.join(self.aster_root, "bin", "as_run")
      commande_base += " --actu " + numjob + " " + self.nomjob + " " + self.mode
      if self.verbose_max :
        print("commande_base =", commande_base)
      if ( self.mclient == self.serveur ) :
        commande  = commande_base
      else :
        commande  = "ssh " + self.username + "@" + self.serveur
        commande += " \"" + commande_base + "\""
      commande += " 1>" + fic_etat
      commande += " 2>" + fic_etat_2
      if self.verbose_max :
        print("Examen sur", self.serveur, ":")
        print(commande)
#
# 3. Examen de l'etat du job, jusqu'a la fin
#
      encore = 1
      while encore :
  #
        if encore % 4 == 0 :
          aux = ((encore-1)*self.attente) / 60
          print("..", aux, "mn")
          #print diag
  #
        time.sleep(self.attente)
        erreur = os.system(commande)
  #
        if erreur :
          erreur = -1
          break
        elif os.path.isfile(fic_etat) :
          fic = open (fic_etat, "r")
          les_lignes = fic.readlines()
          fic.close()
          if len(les_lignes) > 0 :
            if len(les_lignes[0]) > 0 :
              laux = les_lignes[0].split()
              laux1 = laux[0].split("=")
              etat = laux1[1]
              laux1 = laux[1].split("=")
              diag = laux1[1]
              if self.verbose_max :
                print(etat, diag)
              if etat in ( "RUN", "PEND" ) :
                encore += 1
              else :
                if etat != "ENDED" :
                  self.message_info += "Etat du job : " + etat
                  erreur = -2
                else :
                  if diag[:3] in ( "<S>", "<F>" ) :
                    erreur = -3
                if erreur :
                  self.message_info = "Diagnostic du job : " + diag + "\n"
                encore = 0
                break
            else :
              encore += 1
          else :
            encore += 1
        else :
          erreur = -4
          break
#
      os.remove(fic_etat_2)
#
    if self.verbose_max :
      print(blabla)
      print(". erreur :", erreur)
#
    if erreur :
      message_erreur = "Erreur dans le calcul"
#
    return erreur, message_erreur
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
  def post_aster ( self, dico_resu_init ) :
#
    """
Affichage de resultats selon les cas
    """
#
    messages_erreur = { 0 : None,
                        1 : "Ce fichier est inconnu." }
#
    nom_fonction = __name__ + "/post_aster"
    blabla = "\nDans " + nom_fonction + ","
#
    erreur = 0
    message_erreur = " "
#
    dico_resu = {}
    dico_resu.update(dico_resu_init)
#
    while not erreur :
#
# 1. Exploration du fichier resu
#
# 1.1. Recuperation du contenu
#
      nomfic = self.dico["resu"]
      chaine = "V_TEST"
      nuocc = 1
      erreur, message_erreur, info = self.post_aster_1 ( nomfic, chaine, nuocc )
      if ( erreur > 0 ) :
        break
#
# 1.2. Details
#
      if ( erreur == 0 ) :
        self.message_info += info[:-1]
        info = info.replace(chaine, " ")
        laux = info[:-1].split()
        aux = laux[0]
        if ( "D" in aux ) :
          aux = aux.replace("D", "E")
        dico_resu[chaine] = float(aux)
      else :
        erreur = 0
        message_erreur = " "
#
# 2. Exploration du fichier mess
# 2.1. Que chercher ?
#
      for chaine in ( "INSTANT", "NOMBRE DE NOEUDS", "NOMBRE DE MAILLES" ) :
#
# 2.2. Recuperation du contenu
#
        nomfic = self.dico["mess"]
        if chaine == "INSTANT" :
          nuocc = 0
        else :
          nuocc = 1
        erreur, message_erreur, info = self.post_aster_1 ( nomfic, chaine, nuocc )
        if ( erreur > 0 ) :
          break
#
# 2.3. Details
#
        if ( erreur == 0 ) :
          self.message_info += info[:-1]
          if chaine == "INSTANT" :
            l_aux = info[:-1].split()
            lg_aux = len(l_aux)
            for iaux in range(lg_aux) :
              if ( "ORDRE" in l_aux[iaux] ) :
                if l_aux[iaux+1] == ":" :
                  jaux = iaux+2
                else :
                  jaux = iaux+1
                ordre = int(l_aux[jaux])
                dico_resu["ORDRE"] = ordre
                dico_resu["PAS_DE_TEMPS"] = ordre
          elif chaine in ( "NOMBRE DE NOEUDS", "NOMBRE DE MAILLES" ) :
            l_aux = info[:-1].split(chaine)
            dico_resu[chaine] = int(l_aux[1])
        else :
          erreur = 0
          message_erreur = " "
#
      if erreur :
        break
#
# 3. Fichier de resultats au format med
#
      dico_resu["FileName"] = self.dico["rmed"]
#
      break
#
    if self.verbose :
      print(blabla)
      print(". erreur :", erreur)
      print(". dico_resu :", dico_resu)
#
    if erreur :
      message_erreur = messages_erreur[erreur]
#
    return erreur, message_erreur, dico_resu
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
  def post_aster_1 ( self, nomfic, chaine, nuocc ) :
#
    """
Decodage de fichier
nomfic = nom du fichier a decoder
chaine = chaine a chercher
nuocc = numero de l'occurence a chercher, 0 si toutes
Retour :
codret = 0 : tout va bien
         1 : le fichier de resultats est absent
        -1 : la chaine est absente
message_erreur = "" : tout va bien
               != "" si probleme
info = la ou les lignes recherchees
    """
#
    messages_erreur = { 0 : None,
                       -1 : "La chaine est absente.",
                        1 : "Ce fichier est inconnu." }
#
    nom_fonction = __name__ + "/post_aster_1"
    blabla = "\nDans " + nom_fonction + " :"
    if self.verbose_max :
      print(blabla, "nomfic =", nomfic, "chaine =", chaine, ", nuocc =", nuocc)
#
    trouve = False
    erreur = 0
    message_erreur = " "
    info = ""
#
    while not erreur :
#
# 1. Lecture du fichier
#
      if not os.path.isfile(nomfic) :
        self.message_info += "\nFichier "+nomfic+"\n"
        erreur = 1
        break
      fic = open (nomfic, "r")
      les_lignes = fic.readlines()
      fic.close()
#
# 2. Exploration des lignes
# 2.1. On recupere tout
#
      if chaine == None :
#
        for ligne in les_lignes :
          info += ligne
#
# 2.2. On cible
#
      else :
#
        iaux = 0
        for ligne in les_lignes :
          if chaine in ligne :
            iaux += 1
            if ( ( nuocc == 0 ) or ( iaux == nuocc ) ) :
              info += ligne
              if ( not trouve ) :
                self.message_info += "\n"
                trouve = True
#
      break
#
    if ( not trouve ) :
      erreur = -1
#
    if ( self.verbose_max or ( erreur>0 ) ) :
      print(blabla, "nomfic =", nomfic, "chaine =", chaine, ", nuocc =", nuocc)
      print(". erreur =", erreur)
#
    if erreur :
      message_erreur = messages_erreur[erreur]
#
    return erreur, message_erreur, info
#
#=========================  Fin de la fonction ===================================
#
#========================= Debut de la fonction ==================================
#
  def dump_resultat ( self ) :
#
    """
Dump du resultat du calcul
    """
#
    messages_erreur = { 0 : None }
#
    nom_fonction = __name__ + "/dump_resultat"
    blabla = "\nDans " + nom_fonction + ","
#
    erreur = 0
    message_erreur = " "
#
# 1. Lancement
#
    nomfic_donn = os.path.join(self.rep_calc, "donn")
    fic = open (nomfic_donn, "w")
    fic.write("1\n1\n1\n")
    fic.close()
    fic_dump = self.dico["rmed"]+".dump"
    commande = "mdump " + self.dico["rmed"] + "<" + nomfic_donn + ">" + fic_dump
    #print commande
    erreur = os.system(commande)
    if erreur :
      messages_erreur[erreur] = "Erreur de dump numero %d" % erreur
    else :
      self.message_info += "\nDump dans le fichier :\n"
      self.message_info += fic_dump+"\n"
#
    if self.verbose_max :
      print(blabla)
      print(". erreur :", erreur)
#
    os.remove(nomfic_donn)
#
    if erreur :
      message_erreur = messages_erreur[erreur]
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
