#!/usr/bin/env python
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
   Ce module sert à lancer EFICAS configuré pour Code_Aster
"""
# Modules Python

# Modules Eficas
import prefs
name='prefs_'+prefs.code
__import__(name)

from InterfaceQT4 import eficas_go

dico=eficas_go.lanceQtEficas_param(code=prefs.code,fichier="/local00/home/A96028/GitEficas/eficas/Adao/exemple01.comm",version="V760",macro="ASSIMILATION_STUDY")
#print dico

import pprint
pprint.pprint(dico)
