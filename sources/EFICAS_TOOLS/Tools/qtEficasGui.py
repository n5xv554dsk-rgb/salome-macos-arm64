#!/usr/bin/env python3
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
   Ce module sert a lancer EFICAS  contre l avis de Pascale sans directory associee
   Dans ce cas on peut taper
   a) de n importe ou sans avoir rien positionne :
           /leCheminVersTools/qtEficasGui.py -c leFichierCatalogueAvecSonPathComplet
   b) En ayant positionne le PYTHONPATH avec la directory qui contient ce qu il faut
      c est a dire le prefs.py et prefs_leCode.py
      exemple pour Adao
          /leCheminVersTools/qtEficasGui.py -k Adao
          /leCheminVersTools/qtEficasGui.py -k Adao -v V95
   version du 23 avril

"""
# Modules Python
# Modules Eficas

import sys
import os

repIni=os.path.dirname(os.path.abspath(__file__))
INSTALLDIR=os.path.join(repIni,'..')
sys.path[:0]=[INSTALLDIR]
#sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'../..'))

from Editeur import eficas_go
eficas_go.lanceQtEficas(code='NonConnu')
