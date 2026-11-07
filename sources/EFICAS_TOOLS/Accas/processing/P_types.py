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

"""
   Ce module contient des fonctions utilitaires pour tester les types
"""

# use isinstance() instead of type() because objects returned from numpy arrays
# inherit from python scalars but are numpy.float64 or numpy.int32...


def isInt(obj):
    return isinstance(obj, int) or type(obj) is int


def isFloat(obj):
    return isinstance(obj, float)


def isComplex(obj):
    return isinstance(obj, complex)


from decimal import Decimal


def isFloat_or_int(obj):
    return isFloat(obj) or isInt(obj) or isinstance(obj, Decimal)


def isNumber(obj):
    return isFloat_or_int(obj) or isComplex(obj)


def isStr(obj):
    return isinstance(obj, str)

def isList(obj):
    return type(obj) is list


def isTuple(obj):
    return type(obj) is tuple


def isArray(obj):
    """a numpy array ?"""
    import numpy as NP
    _np_arr = NP.ndarray
    return type(obj) is _np_arr


def isSequence(obj):
    """a sequence (allow iteration, not a string) ?"""
    return isList(obj) or isTuple(obj) or isArray(obj)


def isASSD(obj):
    from .P_ASSD import ASSD

    return isinstance(obj, ASSD)


def forceList(obj):
    """Retourne `obj` si c'est une liste ou un tuple,
    sinon retourne [obj,] (en tant que list).
    """
    if not isSequence(obj):
        obj = [
            obj,
        ]
    return list(obj)


def forceTuple(obj):
    """Return `obj` as a tuple."""
    return tuple(forceList(obj))


# backward compatibility
from warnings import warn


def isEnum(obj):
    """same as isSequence"""
    warn("'isEnum' is deprecated, use 'isSequence'", DeprecationWarning, stacklevel=2)
    return isSequence(obj)
