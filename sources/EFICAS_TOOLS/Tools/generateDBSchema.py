#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (C) 2007 - 2026   EDF R&D
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
  cree un debut de schema de base associe au .py
  generateDBSchema.py -n leNomDeLaDatabase
"""
# Modules Python
# Modules Eficas
import sys
import os
sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'..'))

from Editeur import eficas_go
print (eficas_go.genereDBSchema(code='NonConnu'))
