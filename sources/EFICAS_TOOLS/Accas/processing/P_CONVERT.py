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
   Module de conversion des valeurs saisies par l'utilisateur après vérification.
"""
from Accas.processing.P_types import isInt, isFloat, isSequence


def hasIntValue(real):
    """Est-ce que 'real' a une valeur entière ?"""
    return abs(int(real) - real) < 1.0e-12


class Conversion(object):

    """Conversion de type."""

    def __init__(self, name, typeACreer):
        self.name = name
        self.typeACreer = typeACreer

    def convert(self, obj):
        """Filtre liste"""
        in_as_seq = isSequence(obj)
        if not in_as_seq:
            obj = (obj,)

        result = []
        for o in obj:
            result.append(self.function(o))

        if not in_as_seq:
            return result[0]
        else:
            # ne marche pas avec MACR_RECAL qui attend une liste et non un
            # tuple
            return tuple(result)

    def function(self, o):
        raise NotImplementedError("cette classe doit être dérivée")


class TypeConversion(Conversion):

    """Conversion de typeACreer"""

    def __init__(self, typeACreer):
        Conversion.__init__(self, "type", typeACreer)


class IntConversion(TypeConversion):

    """Conversion en entier"""

    def __init__(self):
        TypeConversion.__init__(self, "I")

    def function(self, o):
        if isFloat(o) and hasIntValue(o):
            o = int(o)
        return o


class FloatConversion(TypeConversion):

    """Conversion de type"""

    def __init__(self):
        TypeConversion.__init__(self, "R")

    def function(self, o):
        if isFloat(o):
            o = float(o)
        return o


class UserASSDConversion(TypeConversion):
    def __init__(self, classUser):
        TypeConversion.__init__(self, classUser)

    def function(self, o):
        # print ('je convertis : ', o, 'en ', self.typeACreer )
        # import traceback
        # traceback.print_stack()
        if o == None:
            return None
        # print ('je cree UserASSDConversion', o, ' ', self.typeACreer)
        nouvelObj = self.typeACreer(o)
        return nouvelObj


class UserASSDMultipleConversion(TypeConversion):
    def __init__(self, classUser):
        TypeConversion.__init__(self, classUser)

    def function(self, o):
        if o == None:
            return None
        # print ('je cree dans UserASSDMultipleConversion', o, ' ', self.typeACreer)
        nouvelObj = self.typeACreer(o)
        return nouvelObj


_convertI = IntConversion()
_convertR = FloatConversion()


def ConversionFactory(name, typ):
    if name == "type":
        if "I" in typ:
            return _convertI
        elif "R" in typ:
            return _convertR
    if name == "UserASSD":
        # print(typ)
        return UserASSDConversion(typ)
    if name == "UserASSDMultiple":
        return UserASSDMultipleConversion(typ)
    return None
