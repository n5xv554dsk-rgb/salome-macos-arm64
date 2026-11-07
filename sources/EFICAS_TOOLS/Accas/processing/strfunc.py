# coding=utf-8
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

"""Module rassemblant des fonctions utilitaires de manipulations
de chaines de caractères
"""


import locale

_encoding = None


def getEncoding():
    """Return local encoding"""
    global _encoding
    if _encoding is None:
        try:
            _encoding = locale.getpreferredencoding() or "ascii"
        except locale.Error:
            _encoding = "ascii"
    return _encoding


def toUnicode(string):
    """Try to convert string into a unicode string."""
    if type(string) in (str,) :
        return string
    elif type(string) is dict:
        new = {}
        for k, v in list(string.items()):
            new[k] = toUnicode(v)
        return new
    elif type(string) is list:
        return [toUnicode(elt) for elt in string]
    elif type(string) is tuple:
        return tuple(toUnicode(list(string)))
    elif type(string) is not str:
        return string
    assert type(string) is str, "unsupported object: %s" % string
    for encoding in ("utf-8", "iso-8859-15", "cp1252"):
        try:
            s = string.encode(encoding)
            return s
        except UnicodeDecodeError:
            return string
