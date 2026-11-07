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
    Ce module realise toutes les mises a jour du chemin pour
    les imports de modules Python
"""
from __future__ import absolute_import
import sys
import os

import prefs
name='prefs_'+prefs.code
prefs_Code=__import__(name)
INSTALLDIR=prefs_Code.INSTALLDIR

# Ce chemin permet d'importer les modules Noyau et Validation
# representant le code utilise (si fourni)
# Ensuite on utilise les packages de l'intallation
if hasattr(prefs_Code,'CODE_PATH'):
    if prefs_Code.CODE_PATH:
        sys.path[:0]=[prefs_Code.CODE_PATH]
        import Noyau,Validation
        del sys.path[0]
sys.path[:0]=[prefs_Code.INSTALLDIR]

import Accas
