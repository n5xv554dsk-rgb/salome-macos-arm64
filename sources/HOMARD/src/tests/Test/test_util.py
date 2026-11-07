# -*- coding: utf-8 -*-
# Copyright (C) 2011-2026  CEA, EDF
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
"""Python script for HOMARD

Utilitaires pour les tests
"""
__revision__ = "V4.06"

import os
import sys
import tempfile
import MEDLoader as ml
import shutil
from decimal import Decimal
#========================================================================
#========================================================================
def get_dir(path_homard, test_name, debug=False) :
  """
Get directories for the test.
Copyright EDF 2018
  """
#
# Répertoire des données du test
  rep_data = os.path.join(path_homard, "share", "salome", "homardsamples")
  rep_data = os.path.normpath(rep_data)
#
# Répertoire des résultats
  if debug :
    dircase = os.path.join("/tmp", test_name)
    if ( os.path.isdir(dircase) ) :
      remove_dir(dircase)
    os.mkdir(dircase)
  else :
    dircase = tempfile.mkdtemp(prefix=test_name+"_")
#
  return rep_data, dircase
#
#========================================================================
#========================================================================
def remove_dir(directory) :
  """
Empties, then removes a directory.
Copyright EDF-R&D 2013
  """
#
  l_aux = os.listdir(directory)
  for fic in l_aux :
    fic_a = os.path.join(directory, fic)
    if os.path.isdir(fic_a) :
      remove_dir(fic_a)
    else :
      os.remove(fic_a)
  os.rmdir(directory)
#
  return
#
#========================================================================
#========================================================================
def test_results(rep_test, test_name, dircase, n_iter_test_file, n_rep_test_file, destroy_dir = True) :
  """
Test of the result
rep_test: repertoire des tests
test_name: nom du test
dircase: repertoire des resultats du test
n_iter_test_file: numero de l'iteration a tester
n_rep_test_file: numero du repertoire de l'iteration a tester
destroy_dir: destruction du repertoire de calcul
Copyright EDF-R&D 2014
  """
  #
  test_file_suff = "apad.%02d.bilan" % n_iter_test_file
  rep_test_file = "I%02d" % n_rep_test_file
#
# Existence du fichier de référence
  #
  test_file = os.path.join(rep_test, test_name + "." + test_file_suff)
  mess_error_ref = "\nReference file: " + test_file
  #print ("test_file = %s" % test_file)
  try :
    with open (test_file, "r") as fichier :
      les_lignes_ref = fichier.readlines()
  except :
    mess_error = mess_error_ref + "\nThis file does not exist.\n"
    destroy_dir = False
    raise Exception(mess_error)
#
# Existence du fichier de l'exécution courante
#
  test_file = os.path.join(dircase, rep_test_file, test_file_suff)
  if os.path.isfile (test_file) :
    with open (test_file, "r") as fichier :
      les_lignes = fichier.readlines()
  else :
    mess_error  = "\nResult file: " + test_file
    mess_error += "\nThis file does not exist.\n"
    destroy_dir = False
    raise Exception(mess_error)
#
# Nombre de lignes identiques
#
  nblign = len(les_lignes_ref)
  if ( len(les_lignes) != nblign ):
    mess_error = mess_error_ref +  "\nResult file: " + test_file
    mess_error += "\nThe number of lines of the files are not the same.\n"
    destroy_dir = False
    raise Exception(mess_error)
#
# Comparaison des lignes, à l'esception de la date
#
  for num in range(nblign) :
    if ( "creation" not in les_lignes_ref[num] ) :
      if ( les_lignes_ref[num] != les_lignes[num] ) :
        message_erreur = "\nRefe : " + les_lignes_ref[num]
        message_erreur += "Test : " + les_lignes[num][:-1]
        message_erreur += "\nThe test is different from the reference."
        destroy_dir = False
        raise Exception(message_erreur)
#
# Destruction éventuelle du répertoire du calcul
#
  if destroy_dir:
    remove_dir(dircase)
#
  return
#
#========================================================================
#========================================================================
#
def saveGeometry( xao_file, name, author="" ):
  """
  Save the geometry in a XAO file
  """
  from salome.kernel import salome
  from salome.geom import geomBuilder
  geompy = geomBuilder.New()
  error = 0

  # find an object having groups in GEOM component
  component = salome.myStudy.FindObjectByPath("/Geometry")
  it = salome.myStudy.NewChildIterator( component )
  geomObj = None
  l_groups = list()
  while it.More():
    so = it.Value()
    it.Next()
    go = so.GetObject()
    #
    if go:
      if ( go.GetName() == name ) :
        subIt = salome.myStudy.NewChildIterator( so )
        while subIt.More():
          subSO = subIt.Value()
          subIt.Next()
          if not subSO.GetName(): continue # a reference
          gr = subSO.GetObject()
          if gr and geompy.ShapeIdToType( gr.GetType() ) == "GROUP":
            l_groups.append( gr )
        geomObj = go
        break

  if not geomObj:
    raise RuntimeError("Cant find a geometry object in the SALOME study with name = '%s'" % name)

  # save the geom object in a XAO file
  l_fields = list()
  ok = geompy.ExportXAO( geomObj, l_groups, l_fields, author, xao_file, "" )
  error = not ok

  return error
#
#========================================================================
#========================================================================
#
def repositionnement (rep_calc, fic_med_brut, fic_med_new, xao_file, menage=True, verbose=False) :
#
  """
Pilote le repositionnement des noeuds qui ont bougé
Entrées :
  rep_calc : répertoire du calcul HOMARD qui est à traiter
  fic_med_brut : fichier MED du calcul avec les coordonnées avant projection
  fic_med_new  : fichier MED du calcul avec les coordonnées après projection
  xao_file : fichier XAO de la géométrie
  menage : Suppression du fichier fic_med_brut
  """
  if verbose :
    ligne =    "rep_calc     = %s" % rep_calc
    ligne += "\nfic_med_brut = %s" % fic_med_brut
    ligne += "\nfic_med_new  = %s" % fic_med_new
    ligne += "\nxao_file     = %s" % xao_file
    ligne += "\nmenage       = %d" % menage
    print(ligne)

  message = ""
  erreur = 0
  while not erreur :
#
# 1. l_fr = liste des fichiers des lignes/surfaces a suivre
#
    fic_hom_med = None
    laux = os.listdir(rep_calc)
    #print laux
    l_fr = list()
    icpt_1D = 0
    icpt_2D = 0
    for fic in laux :
      #print "\t" + fic
      if ( fic[:2] == 'fr' ) :
        l_fr.append(os.path.join(rep_calc, fic))
      elif ( fic[-4:] == '.med' ) :
        fic_hom_med = os.path.join(rep_calc, fic)
        #print "\t\treperage de fic_hom_med =", fic_hom_med
#
# 2. Lancement du post-traitement si des noeuds sont concernés
#
    if l_fr :
#
      if verbose :
        print("l_fr =", l_fr)
        print("fic_hom_med =", fic_hom_med)
#
# 2.1.  La fonction :
#    . prend le maillage brut dans le fichier fic_med_brut
#    . prend la liste des noeuds à bouger pour chaque groupe concerné
#    . prend la géométrie dans le fichier xao_file
#    . retourne le maillage transformé dans le fichier fic_med_new
#
      from FrontTrack import FrontTrack
      ft = FrontTrack()
      ft.track( fic_med_brut, fic_med_new, l_fr, xao_file )
#
# 2.2. Transfert des coordonnées dans le fichier HOMARD MED
#
      #if not fic_hom_med :
        #message = "Impossible de trouver le fichier HOMARD MED dans %s" % rep_calc
        #erreur = 12
        #break
##
      #fic_coords = os.path.join(rep_calc, "coords")
      #erreur, message = change_coords (fic_med_new, fic_coords, verbose)
      ##erreur, message = change_coords_0 (fic_med_new, fic_hom_med, verbose)
      #if erreur :
        #break
#
# 2.3. Ménage éventuel de l'ancien fichier MED
#
      if menage :
#
        if ( fic_med_brut != fic_med_new ) :
          if verbose :
            print("Suppression du fichier %s" % fic_med_brut)
          os.remove(fic_med_brut)
#
# 3. Renommage du fichier si aucun noeud n'est concerné
#
    else :
#
      if ( fic_med_brut != fic_med_new ) :
        os.rename(fic_med_brut, fic_med_new)
#
# 4. Mise à jour des coordonnées dans le fichier historique HOMARD/MED si des noeuds sont concernés
#
    if l_fr :
#
      erreur, message = maj_coords (rep_calc, fic_med_new, verbose)
#
    break
#
  return erreur, message
#
#========================================================================
#========================================================================
#
def maj_coords (rep_calc, fic_med_calc, verbose=False) :
#
  """
Met à jour les coordonnées du fichier de calcul vers le fichier HOMARD
Entrées :
  rep_calc : répertoire du calcul HOMARD qui est à traiter
  fic_med_calc  : fichier MED du calcul avec les coordonnées après projection
  xao_file : fichier XAO de la géométrie
  """
  if verbose :
    ligne =    "rep_calc     = %s" % rep_calc
    ligne += "\nfic_med_calc = %s" % fic_med_calc
    print(ligne)

  message = ""
  erreur = 0
  while not erreur :
#
# 1. Recherche des inforamtions permanentes dans le fichier de configuration
#
    fic_conf = os.path.join(rep_calc, "HOMARD.Configuration")
    with open (fic_conf, "r") as fichier :
      les_lignes = fichier.readlines()
#
    ligne0 = ""
    icpt = 0
    for ligne in les_lignes :
      #print "\t" + ligne
      for saux in ( "HOMai", "CCNoM" ) :
        if ( saux+"NP1" in ligne ) :
          iaux = ligne.index(saux)
          ligne0 += saux + "N__" + ligne[iaux+8:]
          icpt += 1
      if ( "NumeIter" in ligne ) :
        iaux = ligne.index("NumeIter")
        saux = ligne[iaux+8:-1]
        iaux = int(saux) + 1
        s_iter = "%02d" % iaux
        ligne0 += "NumeIter %s\n" % s_iter
        icpt += 1
#
    if ( icpt != 3 ) :
      message = "Erreur dans le décodage de %s\n" % fic_conf
      message+= ligne0
      erreur = 1
      break
#
# 2. Création du fichier de configuration
#
    fic_conf_sv = os.path.join(rep_calc, "HOMARD.Configuration.majc")
#
    with open (fic_conf_sv, "w") as fichier :
#
      ligne = ligne0
      ligne += "ModeHOMA 5\n"
      fic = os.path.join(rep_calc, "Liste.%s.maj_coords.log" % s_iter)
      ligne += "ListeStd %s\n" % fic
      ligne += "CCMaiN__ %s\n" % fic_med_calc
      ligne += "RepeTrav %s\n" % rep_calc
      ligne += "RepeInfo %s\n" % rep_calc
      ligne += "Action   homa\n"
      ligne += "CCAssoci med\n"
      ligne += "EcriFiHO N_SANS_FRONTIERE\n"
      ligne += "MessInfo 10\n"
#
      fichier.write(ligne)
#
# 3. Mise à jour
# 3.1. Détermination de l'exécutable
#
    if "HOMARD_REP_EXE_PRIVATE" in os.environ :
      HOMARD_REP_EXE  = os.environ["HOMARD_REP_EXE_PRIVATE"]
    else :
      HOMARD_REP_EXE  = os.environ["HOMARD_REP_EXE"]
#
    if "HOMARD_EXE_PRIVATE" in os.environ :
      HOMARD_EXE  = os.environ["HOMARD_EXE_PRIVATE"]
    else :
      HOMARD_EXE  = os.environ["HOMARD_EXE"]
#
    homard_exe = os.path.join(HOMARD_REP_EXE, HOMARD_EXE)
    if verbose :
      ligne = "homard_exe = %s" % homard_exe
      print(ligne)
#
    if not os.path.isfile(homard_exe) :
      message = "homard_exe = %s" % homard_exe
      message += "\nCe fichier executable n'existe pas."
      erreur = 31
      break
#
# 3.2. Lancement
#
    fic_conf = os.path.join(rep_calc, "HOMARD.Configuration")
    shutil.copyfile(fic_conf_sv, fic_conf)
#
    os.chdir(rep_calc)
    erreur = os.system (homard_exe)
#
    break
#
  return erreur, message
#
#========================================================================
#========================================================================
# Pour Windows, la compilation exige l'utlisation d'une option "debug" qui
# ajoute un ligne dans le fichier de resultats .bilan . 
# La ligne suplemnentaire de ce fichier est identife pour les tests
# auto , elle est donc supprimer temporairement pour faire 
# la comparaison avec les ref qui ont été établi sans cette option de compilation . 
def update_test_win(DIR_TMP, N_ITER_TEST,N_TEST,phrase):
  """
 Mise à jour du fichier .bilan generé sous windows 
 Entrées :
    DIR_TMP:  repertoire temporaire des tests
    N_ITER_TEST: numero du repertoire de l'iteration a tester
    N_TEST: numero de l'iteration a tester
    phrase: ligne suplementaire dans le fichier genere sous Windows
  """
  test_file = DIR_TMP + "\\I0" +str(N_ITER_TEST)+ "\\"+ "apad.0"+str(N_TEST)+".bilan"
  try:
    with open(test_file, 'r') as f:
        lignes = f.readlines()
    test_file_orig=test_file+".orig"
    shutil.copyfile(test_file,test_file_orig)
    os.remove(test_file)
    fichier = open(test_file, "w")
    for ligne in lignes:
      if not phrase in ligne:
        fichier.write(ligne)
    fichier.close()
  except FileNotFoundError:
    print("The file .bilan does not exist: ", test_file)

    #========================================================================
#========================================================================
def test_tutorial4_results(rep_test, test_name, dircase, n_iter_test_file, n_rep_test_file, destroy_dir = True) :
  """
Test of the result for tutorial_4 on Wiindows
rep_test: repertoire des tests
test_name: nom du test
dircase: repertoire des resultats du test
n_iter_test_file: numero de l'iteration a tester
n_rep_test_file: numero du repertoire de l'iteration a tester
destroy_dir: destruction du repertoire de calcul
  """
  #
  test_file_suff = "apad.%02d.bilan" % n_iter_test_file
  rep_test_file = "I%02d" % n_rep_test_file
#
# Existence du fichier de référence
  #
  test_file = os.path.join(rep_test, test_name + "." + test_file_suff)
  mess_error_ref = "\nReference file: " + test_file
  #print ("test_file = %s" % test_file)
  try :
    with open (test_file, "r") as fichier :
      les_lignes_ref = fichier.readlines()
  except :
    mess_error = mess_error_ref + "\nThis file does not exist.\n"
    destroy_dir = False
    raise Exception(mess_error)
#
# Existence du fichier de l'exécution courante
#
  test_file = os.path.join(dircase, rep_test_file, test_file_suff)
  if os.path.isfile (test_file) :
    with open (test_file, "r") as fichier :
      les_lignes = fichier.readlines()
  else :
    mess_error  = "\nResult file: " + test_file
    mess_error += "\nThis file does not exist.\n"
    destroy_dir = False
    raise Exception(mess_error)
#
# Nombre de lignes identiques
#
  nblign = len(les_lignes_ref)
  if ( len(les_lignes) != nblign ):
    mess_error = mess_error_ref +  "\nResult file: " + test_file
    mess_error += "\nThe number of lines of the files are not the same.\n"
    destroy_dir = False
    raise Exception(mess_error)
#
# Comparaison des lignes, à l'esception de la date
#
  indice = 0
  epsilon = Decimal("5")
  for num in range(nblign) :
    if ( "creation" not in les_lignes_ref[num] ) :
      if ("Direction" in les_lignes[num]):
        indice=num
      if ( les_lignes_ref[num] != les_lignes[num] ) :
        equality = False
        if (indice +1 < num  < indice + 5):
          valeurs = [Decimal(element.strip()) for element in les_lignes[num].split("|") if element.strip()!=""]
          valeurs_ref= [Decimal(element.strip()) for element in les_lignes_ref[num].split("|") if element.strip()!=""]

          if len(valeurs) != len(valeurs_ref):
            equality = False
          else:
            equality = all([abs(valeurs[i]-valeurs_ref[i]) <= epsilon for i in range(len(valeurs))])
          
        if not equality:
          message_erreur = "\nRefe : " + les_lignes_ref[num]
          message_erreur += "Test : " + les_lignes[num][:-1]
          message_erreur += "\nThe test is different from the reference."
          destroy_dir = False
          raise Exception(message_erreur)
#
# Destruction éventuelle du répertoire du calcul
#
  if destroy_dir:
    remove_dir(dircase)
#
  return
    
