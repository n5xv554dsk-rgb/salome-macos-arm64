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
   Ce module contient des fonctions utilitaires
"""

# Modules Python


from builtins import str
from builtins import object
import sys

# Modules EFICAS
from Accas.processing.P_Exception import AsException
from Accas.processing.P_types import isInt, isFloat, isComplex, isStr, isSequence, isASSD
from Accas.processing.strfunc import getEncoding

SEP = "_"

try:
    cur_frame = sys._getframe
except:
    print("pb avec la version de python pour cur_frame = sys._getframe")


def calleeWhere(niveau=4):
    """
    recupere la position de l appel
    """
    frame = sys._getframe(niveau)
    if frame == None:
        return 0, "inconnu", 0, {}
    try:
        filename = str(frame.f_code.co_filename, getEncoding())
        return frame.fLineNo, filename, frame.f_code.co_firstlineno, frame.f_locals
    except:
        return 0, "inconnu", 0, {}


def AsType(a):
    """
    Retourne le type d'un concept (a) à partir
    des caractéristiques de l'objet Python
    """
    if isSequence(a):
        return AsType(a[0])
    if isASSD(a):
        return type(a)
    if isFloat(a):
        return "R"
    if isInt(a):
        return "I"
    if isStr(a):
        return "TXM"
    if a == None:
        return None
    raise AsException("type inconnu: %r %s" % (a, type(a)))


def prbanner(s):
    print(("*" * (len(s) + 10)))
    print(("*" * 5 + s + "*" * 5))
    print(("*" * (len(s) + 10)))


def repr_float(valeur):
    """
    Cette fonction représente le réel valeur comme une chaine de caractères
    sous forme mantisse exposant si nécessaire cad si le nombre contient plus de
    5 caractères
    NB : valeur est un réel au format Python ou une chaine de caractères représentant un réel
    """
    if type(valeur) == str:
        valeur = eval(valeur)
    if valeur == 0.0:
        return "0.0"
    if abs(valeur) > 1.0:
        if abs(valeur) < 10000.0:
            return repr(valeur)
    else:
        if abs(valeur) > 0.01:
            return repr(valeur)
    t = repr(valeur)
    if t.find("e") != -1 or t.find("E") != -1:
        # le réel est déjà sous forme mantisse exposant !
        # --> on remplace e par E
        t = t.replace("e", "E")
        # --> on doit encore vérifier que la mantisse contient bien un '.'
        if t.find(".") != -1:
            return t
        else:
            # -->il faut rajouter le point avant le E
            t = t.replace("E", ".E")
            return t
    s = ""
    neg = 0
    if t[0] == "-":
        s = s + t[0]
        t = t[1:]
    cpt = 0
    if t[0].atof() == 0.0:
        # réel plus petit que 1
        neg = 1
        t = t[2:]
        cpt = 1
        while t[0].atof() == 0.0:
            cpt = cpt + 1
            t = t[1:]
        s = s + t[0] + "."
        for c in t[1:]:
            s = s + c
    else:
        # réel plus grand que 1
        s = s + t[0] + "."
        if t[1:].atof() == 0.0:
            l = t[1:].split(".")
            cpt = len(l[0])
        else:
            r = 0
            pt = 0
            for c in t[1:]:
                r = r + 1
                if c != ".":
                    if pt != 1:
                        cpt = cpt + 1
                    s = s + c
                else:
                    pt = 1
                    if r + 1 == len(t) or t[r + 1 :].atof() == 0.0:
                        break
    s = s + "E" + neg * "-" + repr(cpt)
    return s


def importObject(uri):
    """Load and return a python object (class, function...).
    Its `uri` looks like "mainpkg.subpkg.module.object", this means
    that "mainpkg.subpkg.module" is imported and "object" is
    the object to return.
    """
    path = uri.split(".")
    modname = ".".join(path[:-1])
    if len(modname) == 0:
        raise ImportError("invalid uri: %s" % uri)
    mod = object = "?"
    objname = path[-1]
    try:
        __import__(modname)
        mod = sys.modules[modname]
    except ImportError as err:
        raise ImportError("can not import module : %s (%s)" % (modname, str(err)))
    try:
        object = getattr(mod, objname)
    except AttributeError as err:
        raise AttributeError(
            "object (%s) not found in module '%s'. "
            "Module content is: %s" % (objname, modname, tuple(dir(mod)))
        )
    return object


class Singleton(object):

    """Singleton implementation in python."""

    # add _singleton_id attribute to the class to be independant of import
    # path used
    __inst = {}

    def __new__(cls, *args, **kargs):
        cls_id = getattr(cls, "_singleton_id", cls)
        if Singleton.__inst.get(cls_id) is None:
            Singleton.__inst[cls_id] = object.__new__(cls)
        return Singleton.__inst[cls_id]


class Enum(object):

    """
    This class emulates a C-like enum for python. It is initialized with a list
    of strings to be used as the enum symbolic keys. The enum values are automatically
    generated as sequencing integer starting at 0.
    """

    def __init__(self, *keys):
        """Constructor"""
        self._dict_keys = {}
        for inum, key in enumerate(keys):
            setattr(self, key, 2**inum)
            self._dict_keys[2**inum] = key

    def exists(self, value):
        """Tell if value is in the enumeration"""
        return self.getId(value) is not None

    def getId(self, value):
        """Return the key associated to the given value"""
        return self._dict_keys.get(value, None)
