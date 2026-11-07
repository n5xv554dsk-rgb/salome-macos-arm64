#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
#
# Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
# CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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
# See https://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#

from SalomeOnDemandTK.extension_remover import remove_salomex, AtRemoveAskerAbstract

class AtRemoveAskerGui( AtRemoveAskerAbstract ):
    def __init__(self, guiexe):
        self._gui_exe = guiexe

    def askFor(self, extToAsk : str ):
        import subprocess as sp
        out = sp.check_output( [ self._gui_exe , str(extToAsk)] )
        if out.decode('utf-8').strip() == "ok":
            return True
        elif out.decode('utf-8').strip() == "not ok":
            return False
        else:
            raise Exception("Do not understand the response")

def remove_salomex_withgui(install_dir, salomex_name,  force = False):

    module_list = remove_salomex(install_dir, salomex_name, AtRemoveAskerGui("RemoveAsker"), force = force)
    return module_list