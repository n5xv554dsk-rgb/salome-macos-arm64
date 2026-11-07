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
"""
Python script for HOMARD
Copyright EDF 2014, 2018
"""
__revision__ = "V2.02"

import os
import sys

PATH_HOMARD = os.getenv('HOMARD_ROOT_DIR')
# Repertoire des scripts utilitaires
REP_PYTHON = os.path.join(PATH_HOMARD, "bin", "salome", "test", "HOMARD")
REP_PYTHON = os.path.normpath(REP_PYTHON)
sys.path.append(REP_PYTHON)
from test_util import remove_dir

#
#========================= Debut de la fonction ==================================
#
def gzip_gunzip(data_dir, num_tuto, option) :
  """
Compression/Uncompression of the med(or xao) files of a directory such as tutorial_x.nn.med (or tutorial_x.nn.xao)
data_dir: directory
num_tuto: number of the tutorial
option  : 1: compression, -1: uncompression
Copyright EDF-R&D 2014
  """
#
  ficloc_basis = "tutorial_%d" % num_tuto
#
  erreur = 0
  num = -1
#
# Uncompression
#
  if ( option == -1 ) :
#
    while not erreur :
      num += 1
      ficloc = ficloc_basis + ".%02d.med" % num
      nomfic = os.path.join(data_dir, ficloc)
      if not os.path.isfile(nomfic) :
        ficloc += ".gz"
        nomfic = os.path.join(data_dir, ficloc)
        if os.path.isfile(nomfic) :
          os.system("gunzip "+nomfic)
        else :
          erreur = 1
          break
#
    for suffixe in ( "xao", "fr.med" ) :
      ficloc = ficloc_basis + "." + suffixe
      nomfic = os.path.join(data_dir, ficloc)
      if not os.path.isfile(nomfic) :
        ficloc += ".gz"
        nomfic = os.path.join(data_dir, ficloc)
        if os.path.isfile(nomfic) :
          os.system("gunzip "+nomfic)
#
# Compression
#
  elif ( option == 1 ) :
#
    while not erreur :
      num += 1
      ficloc = ficloc_basis + ".%02d.med.gz" % num
      nomfic = os.path.join(data_dir, ficloc)
      if not os.path.isfile(nomfic) :
        ficloc = ficloc_basis + ".%02d.med" % num
        nomfic = os.path.join(data_dir, ficloc)
        if os.path.isfile(nomfic) :
          os.system("gzip "+nomfic)
        else :
          erreur = 2
          break
#
    for suffixe in ( "xao", "fr.med" ) :
      ficloc = ficloc_basis + "." + suffixe + ".gz"
      nomfic = os.path.join(data_dir, ficloc)
      if not os.path.isfile(nomfic) :
        ficloc = ficloc_basis + ".fr.med"
        nomfic = os.path.join(data_dir, ficloc)
        if os.path.isfile(nomfic) :
          os.system("gzip "+nomfic)
#
  return
#
#==========================  Fin de la fonction ==================================
#
#========================= Debut de la fonction ==================================
#
def creation_dircase(num_tuto) :
  """
Creation of a directory for the results of tutorial_x
num_tuto: number of the tutorial
Copyright EDF-R&D 2014
  """
#
  if "LOGNAME" in os.environ :
    user = os.environ ["LOGNAME"]
  else :
    user = "anonymous"
  dircase = os.path.join( os.sep, "tmp", "HOMARD_"+user)
  if not os.path.isdir(dircase) :
    os.mkdir (dircase)
  dirtuto_basis = "tutorial_%d" % num_tuto
  dircase = os.path.join( dircase, dirtuto_basis )
  if os.path.isdir(dircase) :
    remove_dir(dircase)
  os.mkdir (dircase)
#
  return dircase
#
#==========================  Fin de la fonction ==================================
#
