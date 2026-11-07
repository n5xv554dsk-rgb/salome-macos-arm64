# -*- coding: utf-8 -*-
# copyright 2012 LOGILAB S.A. (Paris, FRANCE), all rights reserved.
# contact http://www.logilab.fr -- mailto:contact@logilab.fr
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 2.1 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
"""
eficas_translation  is used for internationalizing strings via the Qt
mechanism. 
Handles unformatted and formatted strings, according to all formatting schemes: 
via dictionaries, tuples, or atoms.
revoir la fonction tr pour avoir un tr sans qt

"""
import re
from Accas.extensions.eficas_exception import EficasException

regex = re.compile(r"% *[0-9]+")

def _reformat_qstring_from_tuple(qstring, params):
    """
    _reformat_qstring_from_tuple(string, tuple) -> string

    Module-internal method.
    Returns a formatted string from an unformatted string
    and a tuple specifying the parameters of the string.
    """
    from PyQt5.QtCore import QRegExp

    reg = QRegExp("\%\.[1-9]{1,2}f")
    for p, j in zip(params, list(range(len(params)))):
        try:
            i += 1 + qstring[i + 1 :].indexOf("%")
        except NameError:
            i = qstring.indexOf("%")
        if i == reg.indexIn(qstring):
            precision = reg.cap(0).split(".")[1].split("f")[0]
            qstring = (
                qstring[: i + 2 + len(precision)].replace(
                    "%." + precision, "%" + str(1 + j)
                )
                + qstring[i + 3 + len(precision) :]
            )
            qstring = regex.sub("{}", qstring)
            # qstring = qstring.format(QString.number(float(params[j]), 'f', int(precision)))
            qstring = qstring.format(float(params[j]))
        else:
            qstring = (
                qstring[: i + 1].replace("%", "%" + str(1 + j))
                + qstring[i + 2 :]
            )
            if isinstance(params[j], str):
                qstring = regex.sub("{}", qstring)
                qstring = qstring.format(params[j])
            elif isinstance(params[j], float):
                qstring = regex.sub("{}", qstring)
                # qstring = qstring.format(QString.number(params[j], 'f',\ len(unicode(params[j]).\
                #                                         split('.')[1])))
                qstring = qstring.format(params[j])
            elif isinstance(params[j], int):
                qstring = regex.sub("{}", qstring)
                # qstring = qstring.format(QString.number(params[j], 10))
                qstring = qstring.format(params[j])
            elif isinstance(params[j], list):
                qstring = regex.sub("{}", qstring)
                qstring = qstring.format(repr(params[j]))
            else:
                raise EficasException(
                    "TypeError: eficas_translation.translation: \
                                      Unicode, list or number expected!"
                )
    return qstring


def _reformat_qstring_from_dict(qstring, params):
    """
    _reformat_qstring_from_dict(string, dict) -> string

    Module-internal method.
    Returns a formatted string from an unformatted string
    and a dictionary specifying the parameters of the string.
    """
    from PyQt5.QtCore import QRegExp

    for p, j in zip(params, list(range(len(params)))):
        p_reg = QRegExp("\%\(" + p + "\)\.[1-9]{1,2}f")
        p_index = p_reg.indexIn(qstring)
        if p_index != -1:
            precision = p_reg.cap(0).split(".")[1].split("f")[0]
            # qstring = qstring.replace("%(" + p + ")." + precision + "f",\
            #                          "%" + unicode(1 + j)).\
            #                          arg(QString.number(float(params[p]), \
            #                                             'f', \
            #                                             int(precision)))
            qstring = qstring.replace(
                "%(" + p + ")." + precision + "f", "%" + str(1 + j)
            )
            qstring = regex.sub("{}", qstring)
            qstring = qstring.format(float(params[p]))
        else:
            qstring.remove(QRegExp("\\)[sdf]{1}"))
            qstring = qstring.replace("%(" + p, "%" + str(1 + j))
            if isinstance(params[p], str):
                qstring = regex.sub("{}", qstring)
                qstring = qstring.format(params[p])
            elif isinstance(params[p], float):
                qstring = regex.sub("{}", qstring)
                qstring = qstring.format(params[p])
                # qstring = qstring.format(QString.number(params[p], 'f', \
                #          len(unicode(params[p]).split('.')[1])))
            elif isinstance(params[p], int):
                qstring = regex.sub("{}", qstring)
                qstring = qstring.format(params[p])
            elif isinstance(params[p], list):
                qstring = regex.sub("{}", qstring)
                qstring = qstring.format(repr(params[p]))
            else:
                raise EficasException(
                    "TypeError: eficas_translation.translation: \
                                      Improper string parameter type."
                )
    return qstring


def _reformat_qstring_from_atom(qstring, params):
    """
    _reformat_qstring_from_atom(string, int-or-float) -> string

    Module-internal method.
    Returns a formatted string from an unformatted string
    and an integer or a float specifying the parameter of
    the string.
    """
    from PyQt5.QtCore import QRegExp

    reg = QRegExp("\%\.[1-9]{1,2}f")
    if qstring.count("%") == 0:
        qstring.append("%1")
        try:
            qstring = regex.sub("{}", qstring)
            qstring = qstring.format(str(params))
        except AttributeError:
            qstring = regex.sub("{}", qstring)
            qstring = qstring.format(params)
    elif qstring.count("%") == 1:
        i = qstring.indexOf("%")
        if i == reg.indexIn(qstring):
            precision = reg.cap(0).split(".")[1].split("f")[0]
            qstring = (
                qstring[: i + 2 + len(precision)].replace("%." + precision, "%1")
                + qstring[i + 3 + len(precision) :]
            )
            qstring = regex.sub("{}", qstring)
            qstring = qstring.format((params))
            # qstring = qstring.format(QString.number(float(params), 'f',\
            #                                     int(precision)))
        else:
            qstring = qstring[: i + 1].replace("%", "%1") + qstring[i + 2 :]
            if isinstance(params, (str, str)):
                qstring = qstring.format(_preprocess_atom(params))
            elif isinstance(params, float):
                # qstring = qstring.format(QString.number(params, 'f', \
                #                                     len(unicode(params).\
                #                                         split('.')[1])))
                qstring = qstring.format(params)
            elif isinstance(params, int):
                qstring = regex.sub("{}", qstring)
                # qstring = qstring.format(QString.number(params, 10))
                qstring = qstring.format(params)
            else:
                raise EficasException(
                    "TypeError: eficas_translation.translation: Unicode, \
                                      string or number expected!"
                )
    return qstring


def _reformat_qstring_from_list(qstring, params):
    """
    _reformat_qstring_from_list(string, tuple) -> string

    Module-internal method.
    Returns a formatted string from an unformatted string
    and a list whose concatenation specifies the parameter
    of the string.
    """
    # XXX to add further functionality, e.g. list processing
    # when ``%`` not at the end.
    if qstring.count("%") == 1 and str(qstring).strip()[:-1].endswith("%"):
        qstring = qstring[: qstring.indexOf("%") + 1].append("1")
        qstring = regex.sub("{}", qstring)
        qstring = qstring.format(" ".join(map(str, params)))
    elif qstring.count("%") == 0:
        qstring.append("%1")
        qstring = regex.sub("{}", qstring)
        qstring = qstring.format(" ".join(map(str, params)))
    else:
        raise EficasException(
            "ValueError: eficas_translation.translation: \
                              At most one '%' expected!"
        )
    return qstring


def _preprocess_atom(string):
    """
    _preprocess_atom(string-or-number-or-unicode) -> unicode
    Test if input is a Unicode object or a number; if so, then return it;
    otherwise, test if the input is a string; if so, then try to create
    a Unicode object out of it. To this end, assume the string is encoded
    in utf-8; if this fails, then assume the string is encoded in Latin-9.
    """
    if isinstance(string, (str, int, float, complex)):
        return string
    elif isinstance(string, str):
        return _str_toUnicode(string)
    else:
        raise EficasException(
            "TypeError: Expected number, string or\
                              Unicode object!"
        )


def _str_toUnicode(string):
    """
    _str_toUnicode(string) -> unicode
    Tries to create a Unicode object out of the input string; assumes
    the string is UTF-8 encoded; if not, then assume the string is
    Latin-9 encoded.
    """
    try:
        string = str(string, "utf-8")
    except UnicodeDecodeError:
        try:
            string = str(string, "iso-8859-15")
        except UnicodeDecodeError:
            raise EficasException(
                "UnicodeDecodeError: UTF-8, Latin-1 \
                                  or Latin-9 expected"
            )
    return string


def tr(string, *args):
    """tr(string-or-unicode, iterable-or-float-or-int) -> unicode
    tr(string-or-unicode) -> unicode

    Returns a formatted Unicode object from an unformatted
    string or Unicode object with formatting specifications, and,
    optionally, an iterable or an int or float.
    Lets Python do the string formatting.
    revoir le else pour avoir un tr sans qt
    """
    try:
        from PyQt5.QtWidgets import QApplication
    except:
        return string

    string = _preprocess_atom(string)
    if len(args) == 0:
        r = str(QApplication.translate("@default", string))
    elif len(args) == 1:
        if isinstance(args[0], (dict, tuple)):
            if string.count("%") == len(args[0]):
                r = str(QApplication.translate("@default", string)) % args[0]
            elif string.count("%") == 1 and string.count("%(") == 0:
                r = str(
                    QApplication.translate("@default", string)
                ) % _preprocess_atom(repr(args[0]))
            elif string.count("%") == 0:
                r = (str(QApplication.translate("@default", string)), args[0])
            else:
                raise EficasException(
                    "ValueError: eficas_translation.translate.tr: \
                                      Improper input string formatting"
                )
        elif isinstance(args[0], (str, str, int, float, complex)):
            if string.count("%") == 1:
                r = str(
                    QApplication.translate("@default", string)
                ) % _preprocess_atom(args[0])
            else:
                r = str(
                    QApplication.translate("@default", string)
                ) + str(_preprocess_atom(args[0]))
        elif isinstance(args[0], list) or args[0] is None:
            if string.count("%") == 1:
                r = str(
                    QApplication.translate("@default", string)
                ) % _preprocess_atom(repr(args[0]))
            else:
                r = (str(QApplication.translate("@default", string)), args[0])

        else:
            raise EficasException(
                "ValueError: eficas_translation.translation.tr: \
                                  Wrong type for formatted string \
                                  arguments: %s"
                % type(args[0])
            )
    else:
        raise EficasException(
            "ValueError: eficas_translation.translation.tr: \
                              Wrong formatted string arguments"
        )
    return r


def tr_qt(string, *args):
    """tr_qt(string, iterable-or-float-or-int) -> unicode
    t_qtr(string) -> unicode

    Returns a formatted string from an unformatted
    Unicode string with formatting specifications, and,
    optionally, an iterable or an int or float.
    Lets PyQt do the string formatting. To this end,
    a conversion from Python to Qt string formatting
    syntax is performed."""
    string = _preprocess_atom(string)
    from PyQt5.QtWidgets import QApplication

    if len(args) == 0:
        r = QApplication.translate("@default", string)
    elif len(args) == 1:
        r = QApplication.translate("@default", string)
        if isinstance(args[0], (dict, tuple)):
            if r.count("%") == len(args[0]):
                if isinstance(args[0], dict):
                    r = _reformat_qstring_from_dict(r, args[0])
                elif isinstance(args[0], tuple):
                    r = _reformat_qstring_from_tuple(r, args[0])
            # XXX Pay attention to this: distinguish between tuple,
            # dict and dict with key given in string.
            elif r.count("%") in range(2) and r.count("%(") == 0:
                r = _reformat_qstring_from_atom(r, _preproces_atom(repr(args[0])))
            else:
                raise EficasException(
                    "ValueError: eficas_translation.translation.tr_qt: \
                                      Improper formatting string parameters"
                )
        elif isinstance(args[0], (str, str, int, float, complex)):
            r = _reformat_qstring_from_atom(r, args[0])
        elif isinstance(args[0], list):
            r = _reformat_qstring_from_list(r, args[0])
        elif args[0] is None:
            r = _reformat_qstring_from_atom(
                r, _preprocess_string_from_atom(repr(args[0]))
            )
        else:
            raise EficasException(
                "ValueError: eficas_translation.translation.tr_qt: \
                                  Wrong string formatting parameter types"
            )
    else:
        raise EficasException(
            "ValueError: eficas_translation.translation.tr_qt: \
                              Improper formatted string parameter set"
        )
    return str(r)


if __name__ == "__main__":
    import sys

    tr(sys.argv[1], *args)
    tr_qt(sys.argv[1], *args)
