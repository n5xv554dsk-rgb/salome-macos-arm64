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

import logging
from Traducteur.load import jdcSet


def ecritErreur(listeGena, ligne=None):
    from sys import dict_erreurs

    maCle = ""
    for Mot in listeGena:
        maCle = maCle + "_" + Mot
    # try :
    if 1 == 1:
        maClef = maCle[1:]
        if maClef in dict_erreurs:
            if ligne != None:
                logging.warning("ligne %d : %s ", ligne, dict_erreurs[maClef])
            else:
                logging.warning("%s", dict_erreurs[maClef])
        else:
            maCle = ""
            for Mot in listeGena[:-1]:
                maCle = maCle + "_" + Mot
            maClef = maCle[1:]
            maClef = maCle + "_" + "VALEUR"
            if maClef in dict_erreurs:
                if ligne != None:
                    logging.warning("ligne %d : %s ", ligne, dict_erreurs[maClef])
                else:
                    logging.warning("%s", dict_erreurs[maClef])
    # except :
    #    pass


def genereErreurPourCommande(jdc, listeCommande):
    commands = jdc.root.childNodes[:]
    commands.reverse()
    for c in commands:
        if type(listeCommande) == list:
            for Mot in listeCommande:
                if c.name != Mot:
                    continue
                ecritErreur((Mot,), c.lineno)
        else:
            if c.name != listeCommande:
                continue
            ecritErreur((listeCommande,), c.lineno)


def genereErreurMotCleInFact(jdc, command, fact, mocle):
    for c in jdc.root.childNodes:
        if c.name != command:
            continue
        for mc in c.childNodes:
            if mc.name != fact:
                continue
            l = mc.childNodes[:]
            for ll in l:
                for n in ll.childNodes:
                    if n.name != mocle:
                        continue
                    else:
                        ecritErreur(
                            (
                                command,
                                fact,
                                mocle,
                            ),
                            c.lineno,
                        )


def genereErreurMCF(jdc, command, fact):
    for c in jdc.root.childNodes:
        if c.name != command:
            continue
        for mc in c.childNodes:
            if mc.name != fact:
                continue
            else:
                ecritErreur(
                    (
                        command,
                        fact,
                    ),
                    c.lineno,
                )


def genereErreurValeur(jdc, command, fact, list_valeur):
    for c in jdc.root.childNodes:
        if c.name != command:
            continue
        for mc in c.childNodes:
            if mc.name != fact:
                continue
            texte = mc.getText(jdc)
            for valeur in list_valeur:
                trouve = texte.find(valeur)
                if trouve > -1:
                    logging.warning(
                        "%s doit etre supprimee ou modifiee dans %s : ligne %d",
                        valeur,
                        c.name,
                        mc.lineno,
                    )


def genereErreurValeurDsMCF(jdc, command, fact, mocle, list_valeur):
    for c in jdc.root.childNodes:
        if c.name != command:
            continue
        for mc in c.childNodes:
            if mc.name != fact:
                continue
            l = mc.childNodes[:]
            for ll in l:
                for n in ll.childNodes:
                    if n.name != mocle:
                        continue
                    texte = n.getText(jdc)
                    for valeur in list_valeur:
                        trouve = texte.find(valeur)
                        if trouve > -1:
                            logging.warning(
                                "%s doit etre supprimee ou modifiee dans %s : ligne %d",
                                valeur,
                                c.name,
                                n.lineno,
                            )
