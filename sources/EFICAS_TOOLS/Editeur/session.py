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
Ce module centralise les informations issues de la ligne de commande.

"""

# Version qui explique l utilisation de poursuite et include
# Obsolete mais pourrait etre un jour utile
#La ligne de commande est parsee avec l'aide du module python optparse.
#Les options possibles sont : -l, -j, -p, -d, -i, -f comme definies ci-dessous.
#
#Un exemple typique d'utilisation est :
#>>> ./appli.py -v V7.3 -d 1 -j aa -i 11 iii -p ppp -i 22 ii -j bb -f ff
#qui demande a l'application d'ouvrir trois jeux de commandes.
#Le premier (aa) a un include (11,iii) et est la suite du fichier poursuite ppp
#qui a lui meme un include (22,ii).
#
#Le deuxieme bb est un jeu de commandes simple.
#Le troisieme est decrit dans le fichier ff de type .ini
#qui est parse par le module Configparser.
#Chaque section du fichier decrit un jeu de commandes.
#Un include est specifie par: numero logique=nom du fichier
#Une poursuite est specifiee par: poursuite=reference a un jeu de commande
#Cette reference correspond a un nom de section decrivant le jeu de commandes.
#Le jeu de commandes maitre est donne par l'entree globale jdc dans la section jdc.


from builtins import str

import optparse
from optparse import OptionValueError

import os, traceback
import re

from Accas.extensions.eficas_translation import tr

# Les valeurs decodees par optparse sont mises dans un objet dictionnaire-like.
# On l'utilise comme environnement de session.
d_env = {}
#
# L'attribut "studies" de d_env est une liste dans laquelle on range les etudes de niveau global.
# Une etude est stockee dans un dictionnaire.
# La cle "comm" du dictionnaire donne le nom du fichier de commandes principal
# La cle (optionnelle) "pours" du dictionnaire donne les informations pour une poursuite
# La valeur associee a la cle est un dictionnaire qui contient les informations sur
# le nom du fichier de commandes de la poursuite (cle "comm"), une eventuelle poursuite
# (cle "pours") et les includes (cles entieres associees a des noms de fichier).
#
#
#
# Les informations (dictionnaire) associees au fichier de commandes en cours de traitement
# sont stockees dans parser.values.current
# En general, il faut utiliser current et pas parser.values.studies car les informations
# sont stockees hierarchiquement
#


def checkComm(option, opt_str, value, parser):
    if not hasattr(parser.values, "studies"):
        parser.values.studies = []
        parser.values.comm = []
    if not os.path.isfile(value):
        raise OptionValueError(tr("le fichier de commandes %s n'existe pas", value))
    parser.values.comm.append(value)
    d_study = {"comm": value}
    parser.values.current = d_study
    parser.values.studies.append(d_study)


def checkPoursuite(option, opt_str, value, parser):
    if parser.values.comm is None:
        raise OptionValueError(
            tr("un fichier de commandes doit etre defini avant une poursuite %s", value)
        )
    if not os.path.isfile(value):
        raise OptionValueError(tr("le fichier poursuite %s n'existe pas", value))
    # current : fichier de commandes en cours de traitement (dictionnaire des infos)
    comm = parser.values.current
    d_study = {"comm": value}
    comm["pours"] = d_study
    parser.values.current = d_study


def checkInclude(option, opt_str, value, parser):
    try:
        args = [int(parser.rargs[0]), parser.rargs[1]]
    except:
        raise OptionValueError(tr("include mal defini %s", parser.rargs[0:2]))

    del parser.rargs[0]
    del parser.rargs[0]

    if parser.values.comm is None:
        raise OptionValueError(
            tr("un fichier de commandes doit etre defini avant un include %s", args)
        )
    if not os.path.isfile(args[1]):
        raise OptionValueError(tr("le fichier include %s n'existe pas", args[1]))

    comm = parser.values.current
    comm[args[0]] = args[1]


def checkJdc(config, jdc, parser, fich):
    """
    Fonction : analyse une section de fichier .ini pour en extraire
    les informations sur les fichiers poursuite et includes
    definis dans cette section

    parser : objet analyseur de la ligne de commande
    fich : nom du fichier .ini en cours d'analyse
    config : objet de la classe Configparser permettant de parser le fichier fich
    jdc : nom de la section du fichier fich a analyser
    """
    d_study = {}

    for o in config.options(jdc):
        if o == "poursuite":
            p = config.get(jdc, "poursuite")

            if not config.has_option(p, "comm"):
                raise OptionValueError(
                    tr(
                        " jdc %(v_1)s manque \
                                         fichier comm dans section %(v_2)s",
                        {"v_1": fich, "v_2": p},
                    )
                )
            comm = config.get(p, "comm")
            if not os.path.isfile(comm):
                raise OptionValueError(
                    tr(
                        "jdc %(v_1)s, le fichier\
                                         de commandes %(v_2)s n'existe pas",
                        {"v_1": fich, "v_2": comm},
                    )
                )

            pours = checkJdc(config, p, parser, fich)
            pours["comm"] = comm
            d_study["pours"] = pours
            continue

        try:
            unit = int(o)
            # si le parametre est un entier, il s'agit d'un include
            inc = config.get(jdc, o)
        except EficasException:
            continue
        if not os.path.isfile(inc):
            raise OptionValueError(
                tr(
                    " jdc %(v_1)s \
                                     fichier include %(v_2)s, %(v_3)s \
                                     n'existe pas",
                    {"v_1": fich, "v_2": unit, "v_3": inc},
                )
            )
        d_study[unit] = inc

    return d_study


def checkFich(option, opt_str, fich, parser):
    """
    Fonction : parse le fichier fich (format .ini)

    option : option en cours de traitement
    opt_str : chaine de caracteres utilisee par l'utilisateur
    fich : nom du fichier .ini donne par l'utilisateur
    parser : objet parseur des options de la ligne de commande
    """
    if not os.path.isfile(fich):
        raise OptionValueError(tr(" le fichier jdc %s n'existe pas", str(fich)))
    if parser.values.fich is None:
        parser.values.fich = []
    parser.values.fich.append(fich)
    if not hasattr(parser.values, "studies"):
        parser.values.studies = []
        parser.values.comm = []
    import configparser

    config = configparser.configparser()
    config.read([fich])
    if not config.has_option("jdc", "jdc"):
        raise OptionValueError(
            tr(" jdc %s manque option jdc dans section jdc", str(fich))
        )
    jdc = config.get("jdc", "jdc")

    if not config.has_option(jdc, "comm"):
        raise OptionValueError(
            tr(
                " jdc %(v_1)s manque fichier comm \
                                 dans section %(v_2)s",
                {"v_1": fich, "v_2": jdc},
            )
        )
    comm = config.get(jdc, "comm")
    if not os.path.isfile(comm):
        raise OptionValueError(
            tr(
                "jdc %(v_1)s, le fichier de commandes \
                                 %(v_2)s n'existe pas",
                {"v_1": fich, "v_2": comm},
            )
        )
    parser.values.comm.append(comm)

    d_study = checkJdc(config, jdc, parser, fich)
    d_study["comm"] = comm
    parser.values.studies.append(d_study)


def printPours(d_pours, dec=""):
    # Les fichiers includes d'abord
    for k, v in list(d_pours.items()):
        if k in ("pours", "comm"): continue
        print( ( tr( "%(v_1)s include %(v_2)s : %(v_3)s", {"v_1": str(dec), "v_2": str(k), "v_3": str(v)},)))

    if "pours" in d_pours:
        # Description de la poursuite
        print( ( tr( "%(v_1)s fichier poursuite: %(v_2)s", {"v_1": dec, "v_2": d_pours["pours"]["comm"]},)))
        printPours(d_pours["pours"], dec=dec + "++")


def printDEnv():
    if d_env.studies is None:
        return
    for study in d_env.studies:
        print((tr("nom etude : %s", study["comm"])))
        printPours(study, dec="++")


def createParser():
    # creation du parser des options de la ligne de commande
    # import prefs
    parser = optparse.OptionParser(
        usage=tr("utilisation : %prog [options]"), version="%prog 9.5"
    )

    parser.add_option(
        "-j",
        "--jdc",
        dest="comm",
        type="string",
        action="callback",
        callback=checkComm,
        help=tr("nom du fichier de commandes"),
    )

    parser.add_option(
        "-P",
        "--poursuite",
        type="string",
        dest="pours",
        action="callback",
        callback=checkPoursuite,
        help=tr("nom du fichier poursuite"),
    )

    parser.add_option(
        "-i",
        "--include",
        action="callback",
        callback=checkInclude,
        nargs=2,
        help=tr("numero d'unite suivi du nom du fichier include"),
    )

    # parser.add_option(u"-f","--fich", type="string",dest="fich",
    #              action="callback", callback=checkFich,
    #              help=tr("fichier decrivant une etude"))

    parser.add_option(
        "-c",
        "--cata",
        action="store",
        type="string",
        dest="cataFile",
        default=None,
        help=tr("catalogue a utiliser"),
    )

    parser.add_option(
        "-o",
        "--fichierOut",
        action="store",
        type="string",
        dest="fichierOut",
        default=None,
        help=tr("nom du fichier xml genere"),
    )

    parser.add_option(
        "-v",
        "--label",
        action="store",
        type="string",
        dest="versionCode",
        default=None,
        help=tr("version de catalogue a utiliser"),
    )

    parser.add_option(
        "-k",
        "--kode",
        action="store",
        type="string",
        dest="code",
        help=tr("nom du code a utiliser"),
    )

    parser.add_option(
        "-d",
        "--debug",
        action="store",
        type="int",
        dest="debug",
        help=tr("niveau de debug"),
    )

    parser.add_option(
        "-x",
        "--withXSD",
        action="store_true",
        dest="withXSD",
        default=False,
        help=tr("construit le .xml en meme temps que le .comm"),
    )

    parser.add_option(
        "-a",
        "--withAbstractElt",
        action="store_true",
        dest="withAbstractElt",
        default=False,
        help=tr("construit des elements abstraits dans le XSD pour gerer le cascading"),
    )

    parser.add_option(
        "-u",
        "--withUnitAsAttribute",
        action="store_true",
        dest="withUnitAsAttribute",
        default=False,
        help=tr("les unites deviennent des attibuts dans le XSD "),
    )
    parser.add_option(
        "-s",
        "--schema",
        action="store",
        type="string",
        dest="ssCode",
        help=tr("schema"),
    )
    parser.add_option(
        "-n",
        "--databaseName", 
        action="store", 
        default=None,
        type="string",
        dest="databaseName",
        help=tr("nom de la dataBase a Creer  lors du dump"),
    )
    parser.add_option(
        "-p",
        "--prefsFile", 
        action="store", 
        default=None,
        type="string",
        dest="prefsFile",
        help=tr("nom du fichier de preference à utiliser"),
    )


    # To handle locale information
    # parser.add_option("-l", "--locale", action="store", type="string", dest="locale",
    #              help=tr("localisation de l'application, pour la traduction"))

    return parser


def parse(args):
    parser = createParser()
    code=args[0]
    (options, args) = parser.parse_args(args[1:])
    if not hasattr(options, "studies"):
        options.studies = []
        options.comm = []
    if options.withXSD:
        try:
            import pyxb
        except:
            print("Please, source pyxb environment")
            exit()
    if 'generateXSD' not in code:
       if options.withUnitAsAttribute :
            print("withUnitAsAtttibute option is only valid for XSD generation")
            exit()
       if options.withAbstractElt :
            print("withEltAbstrait option is only valid for XSD generation")
            exit()
    #try:
    #    del parser.values.current
    #except:
    #    pass

    for file in args:
        if os.path.isfile(file):
            options.comm.append(file)
            options.studies.append({"comm": file})
            # print options.studies
        elif len(args) == 1 and (
            re.search(".comm", file)
            or re.search(".map", file)
            or re.search(".cas", file)
            or re.search(".xml", file)
        ):
            try:
                f = open(file, "w")
                f.close()
            except:
                parser.error(tr("Nombre incorrect d'arguments"))
            options.comm.append(file)
            options.studies.append({"comm": file})
        elif len(args) == 2:
            if options.locale:
                print((tr("Localisation specifiee pour l'application.")))
            else:
                parser.error(tr("Nombre incorrect d'arguments"))
        else:
            parser.error(tr("Nombre incorrect d'arguments"))

    global d_env
    d_env = options
    # printDEnv()
    # print (options)
    return options


def getUnit(d_study, appliEficas):
    """
    Fonction : construit et retourne un dictionnaire contenant les informations
    sur les fichiers poursuite et includes sous la forme adaptee
    pour EFICAS ::

               [None : nom_fichier, texte_source, unites_associees,           # poursuite
                numero_include : nom_fichier, texte_source, unites_associees, # include
                 ...]

    d_study : dictionnaire de l'etude
    appliEficas : objet application EFICAS (permet d'acceder aux services comme getSource)
    """
    return getDunit(d_study, appliEficas)


def getDunit(d_unit, appliEficas):
    d = {}
    if "pours" in d_unit:
        # on a une poursuite
        comm = d_unit["pours"]["comm"]
        g = getDunit(d_unit["pours"], appliEficas)
        text = appliEficas.getSource(comm)
        d[None] = comm, text, g

    for k, v in list(d_unit.items()):
        if k in ("pours", "comm"):
            continue
        text = appliEficas.getSource(v)
        d[k] = v, text, d

    return d
