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
# Management of EFICAS version numbering.
# A version has at least major and minor numbers, for easier comparison.

__version = {"major": 10, "minor": 0}


def getEficasVersion():
    """
    Return the EFICAS current version number.
    """
    return "%s.%s" % (getMajor(), getMinor())

def getSalomeVersion():
    """
    Return the SALOME version number to which current EFICAS version is related.
    """
    return getEficasVersion()

def getMajor():
    return __version["major"]

def getMinor():
    return __version["minor"]

def getBaseVersion():
    """
    Returns [ major, minor ] array of integers.
    """
    return [getMajor(), getMinor()]

