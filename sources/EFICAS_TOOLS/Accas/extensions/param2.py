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

# Classe qui permet d entrer des formules comme
# comme a=3cos(30) sans qu elles soient caculees a l exec
# attention toutes les fonctions mathematiques ne sont pas surchargées

def mkf(value):
    if type(value) in (type(1), type(1), type(1.5), type(1j), type("hh")):
        return Constant(value)
    elif isinstance(value, Formula):
        return value
    elif type(value) == type([]):
        return Constant(value)
    else:
        #        return Constant(value)
        raise TypeError("Can't make formula from", value)


class Formula(object):
    def __len__(self):
        val = self.eval()
        if val is None:
            return 0
        try:
            return len(val)
        except:
            return 1

    def __complex__(self):
        return complex(self.eval())

    def __int__(self):
        return int(self.eval())

    def __long__(self):
        return int(self.eval())

    def __float__(self):
        return float(self.eval())

    def __pos__(self):
        return self  # positive

    def __neg__(self):
        return Unop("-", self)

    def __abs__(self):
        return Unop("abs", self)

    def __add__(self, other):
        return Binop("+", self, other)

    def __radd__(self, other):
        return Binop("+", other, self)

    def __sub__(self, other):
        return Binop("-", self, other)

    def __rsub__(self, other):
        return Binop("-", other, self)

    def __mul__(self, other):
        return Binop("*", self, other)

    def __rmul__(self, other):
        return Binop("*", other, self)

    def __div__(self, other):
        return Binop("/", self, other)

    def __rdiv__(self, other):
        return Binop("/", other, self)

    def __truediv__(self, other):
        return Binop("/", self, other)

    def __rtruediv__(self, other):
        return Binop("/", other, self)

    def __floordiv__(self, other):
        return Binop("//", self, other)

    def __rfloordiv__(self, other):
        return Binop("//", other, self)

    def __pow__(self, other):
        return Binop("**", self, other)

    def __rpow__(self, other):
        return Binop("**", other, self)

    def __getitem__(self, i):
        if i > len(self):
            raise StopIteration
        return Binop("[]", self, i)

    def __cmp__(self, other):
        return self.eval().__cmp__(other)

    def __eq__(self, other):
        return self.eval() == other

    def __ne__(self, other):
        return self.eval() != other

    def __lt__(self, other):
        return self.eval() < other

    def __le__(self, other):
        return self.eval() <= other

    def __gt__(self, other):
        return self.eval() > other

    def __ge__(self, other):
        return self.eval() >= other

    def __hash__(self):
        return id(self)


def _div(a, b):
    import types
    if isinstance(a, str) and isinstance(b, int):
        if a % b:
            return a / b
        else:
            return a // b
    else:
        return a / b


class Binop(Formula):
    opmap = {
        "+": lambda a, b: a + b,
        "*": lambda a, b: a * b,
        "-": lambda a, b: a - b,
        "/": _div,
        "//": lambda a, b: a // b,
        "**": lambda a, b: a**b,
        "[]": lambda a, b: a[b],
    }

    def __init__(self, op, value1, value2):
        self.op = op
        self.values = mkf(value1), mkf(value2)

    def __str__(self):
        if self.op == "[]":
            return "%s[%s]" % (self.values[0], self.values[1])
        else:
            return "(%s %s %s)" % (self.values[0], self.op, self.values[1])

    def __repr__(self):
        if self.op == "[]":
            return "%s[%s]" % (self.values[0], self.values[1])
        else:
            return "(%s %s %s)" % (self.values[0], self.op, self.values[1])

    def eval(self):
        result = self.opmap[self.op](self.values[0].eval(), self.values[1].eval())
        while isinstance(result, Formula):
            result = result.eval()
        return result

    def __adapt__(self, validator):
        return validator.adapt(self.eval())


class Unop(Formula):
    opmap = {
        "-": lambda x: -x,
        "abs": lambda x: abs(x),
    }

    def __init__(self, op, arg):
        self._op = op
        self._arg = mkf(arg)

    def __str__(self):
        return "%s(%s)" % (self._op, self._arg)

    def __repr__(self):
        return "%s(%s)" % (self._op, self._arg)

    def eval(self):
        return self.opmap[self._op](self._arg.eval())

    def __adapt__(self, validator):
        return validator.adapt(self.eval())


class Unop2(Unop):
    def __init__(self, nom, op, arg):
        self._nom = nom
        self._op = op
        self._arg = []
        for a in arg:
            self._arg.append(mkf(a))

    def __str__(self):
        s = "%s(" % self._nom
        for a in self._arg:
            s = s + str(a) + ","
        s = s + ")"
        return s

    def __repr__(self):
        s = "%s(" % self._nom
        for a in self._arg:
            s = s + str(a) + ","
        s = s + ")"
        return s

    def eval(self):
        l = []
        for a in self._arg:
            l.append(a.eval())
        return self._op(*l)


class Constant(Formula):
    def __init__(self, value):
        self._value = value

    def eval(self):
        return self._value

    def __str__(self):
        return str(self._value)

    def __adapt__(self, validator):
        return validator.adapt(self._value)


class Variable(Formula):
    def __init__(self, name, value):
        self._name = name
        self._value = value

    def eval(self):
        return self._value

    def __repr__(self):
        return "Variable('%s',%s)" % (self._name, self._value)

    def __str__(self):
        return self._name

    def __adapt__(self, validator):
        return validator.adapt(self._value)


def Eval(f):
    if isinstance(f, Formula):
        f = f.eval()
    elif type(f) in (list,):
        f = [Eval(i) for i in f]
    elif type(f) in (tuple,):
        f = tuple([Eval(i) for i in f])
    return f


def cos(f):
    return Unop("ncos", f)


def sin(f):
    return Unop("nsin", f)


def array(f, *tup, **args):
    """array de numpy met en defaut la mecanique des parametres
    on la supprime dans ce cas. Il faut que la valeur du parametre soit bien definie
    """
    originalMath = OriginalMath()
    original_narray = originalMath.original_narray
    return original_narray(Eval(f), *tup, **args)


def sin(f):
    return Unop("sin", f)


def cos(f):
    return Unop("cos", f)


def ceil(f):
    return Unop("ceil", f)


def sqrt(f):
    return Unop("sqrt", f)


def pi2():
    return Unop("pi")


class OriginalMath(object):
    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(OriginalMath, cls).__new__(cls, *args, **kwargs)

        return cls._instance

    def __init__(self):
        if hasattr(self, "pi"):
            return
        self.toSurcharge()

    def toSurcharge(self):
        import math
        import numpy
        self.numeric_ncos = numpy.cos
        self.numeric_nsin = numpy.sin
        self.numeric_narray = numpy.array
        self.sin = math.sin
        self.cos = math.cos
        self.sqrt = math.sqrt
        self.ceil = math.ceil
        self.pi = math.pi

        # surcharge de la fonction cos de numpy pour les parametres
        original_ncos = numpy.cos
        Unop.opmap["ncos"] = lambda x: original_ncos(x)
        numpy.cos = cos

        # surcharge de la fonction sin de numpy pour les parametres
        original_nsin = numpy.sin
        Unop.opmap["nsin"] = lambda x: original_nsin(x)
        numpy.sin = sin

        # surcharge de la fonction array de numpy pour les parametres
        original_narray = numpy.array
        self.original_narray = numpy.array
        numpy.array = array

        # surcharge de la fonction sin de math pour les parametres
        original_sin = math.sin
        Unop.opmap["sin"] = lambda x: original_sin(x)
        math.sin = sin

        # surcharge de la fonction cos de math pour les parametres
        original_cos = math.cos
        Unop.opmap["cos"] = lambda x: original_cos(x)
        math.cos = cos

        # surcharge de la fonction sqrt de math pour les parametres
        original_sqrt = math.sqrt
        Unop.opmap["sqrt"] = lambda x: original_sqrt(x)
        math.sqrt = sqrt

        # surcharge de la fonction ceil de math pour les parametres
        original_ceil = math.ceil
        Unop.opmap["ceil"] = lambda x: original_ceil(x)
        math.ceil = ceil

        original_pi = math.pi
        Unop.opmap["pi"] = lambda x: original_pi
        pi = Variable("pi", pi2)
        math.pi = pi

    def toOriginal(self):
        import math
        import numpy
        try:
            numpy.cos = originalMath.numeric_ncos
            numpy.sin = originalMath.numeric_nsin
            numpy.array = originalMath.numeric_narray
        except:
            pass
        math.sin = originalMath.sin
        math.cos = originalMath.cos
        math.sqrt = originalMath.sqrt
        math.ceil = originalMath.ceil
        math.pi = originalMath.pi


originalMath = OriginalMath()
