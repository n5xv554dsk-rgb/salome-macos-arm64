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
from Traducteur.utils import lineToDict
import logging
from Traducteur.dictErreurs import ecritErreur
from Traducteur.load import jdcSet
from Traducteur.renamemocle import decaleLignesdeNBlancs
from Traducteur.removemocle import removeMotCleInFact
from Traducteur import regles


# --------------------------------------------------------------------------
def changementValeur(jdc, command, motcle, DictNouvVal, liste=(), defaut=0):
    # --------------------------------------------------------------------------
    if command not in jdcSet:
        return
    boolChange = 0
    for c in jdc.root.childNodes:
        if c.name != command:
            continue
        trouveUnMC = 0
        for mc in c.childNodes:
            if mc.name != motcle:
                continue
            trouveUnMC = 1
            TexteMC = mc.getText(jdc)
            liste_ligne_MC = TexteMC.splitlines()
            indexLigneGlob = mc.lineno - 1
            indexTexteMC = 0
            while indexLigneGlob < mc.endline:
                if indexTexteMC > len(liste_ligne_MC) - 1:
                    break
                MaLigneGlob = jdc.getLines()[indexLigneGlob]
                MaLigneTexte = liste_ligne_MC[indexTexteMC]
                for Valeur in DictNouvVal:
                    MaLigneTexteDict = lineToDict(MaLigneTexte)
                    trouvecol = MaLigneTexte.find(Valeur)
                    if trouvecol > -1:
                        trouve = Valeur == MaLigneTexteDict[trouvecol]
                    else:
                        trouve = False
                    if trouve:
                        debut = MaLigneGlob.find(motcle)
                        if debut == -1:
                            debut = 0
                        Nouveau = MaLigneGlob[debut:].replace(
                            Valeur, DictNouvVal[Valeur]
                        )
                        Nouveau = MaLigneGlob[0:debut] + Nouveau
                        jdc.getLines()[indexLigneGlob] = Nouveau
                        MaLigneTexte = Nouveau  # raccourci honteux mais ...
                        MaLigneGlob = Nouveau
                        if Valeur in liste:
                            ecritErreur((command, motcle, Valeur), indexLigneGlob)
                        else:
                            logging.info(
                                "Changement de %s par %s dans %s ligne %d",
                                Valeur,
                                DictNouvVal[Valeur],
                                command,
                                indexLigneGlob,
                            )
                        boolChange = 1
                indexLigneGlob = indexLigneGlob + 1
                indexTexteMC = indexTexteMC + 1
        if (trouveUnMC == 0) and (defaut == 1):
            ecritErreur((command, motcle, "DEFAUT"), c.lineno)
    if boolChange:
        jdc.reset(jdc.getSource())


# --------------------------------------------------------------------------------
def changementValeurDsMCF(
    jdc,
    command,
    fact,
    motcle,
    DictNouvVal,
    liste=(),
    ensemble=regles.SansRegle,
    defaut=0,
):
    # --------------------------------------------------------------------------------

    if command not in jdcSet:
        return
    boolChange = 0
    for c in jdc.root.childNodes:
        if c.name != command:
            continue
        for mcF in c.childNodes:
            if mcF.name != fact:
                continue
            l = mcF.childNodes[:]
            l.reverse()
            for ll in l:
                trouveUnMC = 0
                for mc in ll.childNodes:
                    if mc.name != motcle:
                        continue
                    if ensemble.verif(c) == 0:
                        continue
                    trouveUnMC = 1
                    TexteMC = mc.getText(jdc)
                    liste_ligne_MC = TexteMC.splitlines()
                    indexLigneGlob = mc.lineno - 1
                    indexTexteMC = 0
                    while indexLigneGlob < mc.endline:
                        if indexTexteMC > len(liste_ligne_MC) - 1:
                            break
                        MaLigneGlob = jdc.getLines()[indexLigneGlob]
                        MaLigneTexte = liste_ligne_MC[indexTexteMC]
                        for Valeur in DictNouvVal:
                            MaLigneTexteDict = lineToDict(MaLigneTexte)
                            trouvecol = MaLigneTexte.find(Valeur)
                            if trouvecol > -1:
                                trouve = Valeur == MaLigneTexteDict[trouvecol]
                            else:
                                trouve = False
                            if trouve:
                                debut = MaLigneGlob.find(motcle)
                                if debut == -1:
                                    debut = 0
                                Nouveau = MaLigneGlob[debut:].replace(
                                    Valeur, DictNouvVal[Valeur]
                                )
                                Nouveau = MaLigneGlob[0:debut] + Nouveau
                                jdc.getLines()[indexLigneGlob] = Nouveau
                                MaLigneTexte = Nouveau  # raccourci honteux mais ...
                                MaLigneGlob = Nouveau
                                if Valeur in liste:
                                    ecritErreur(
                                        (command, fact, motcle, Valeur), indexLigneGlob
                                    )
                                else:
                                    logging.info(
                                        "Changement de %s par %s dans %s ligne %d",
                                        Valeur,
                                        DictNouvVal[Valeur],
                                        command,
                                        indexLigneGlob,
                                    )
                        boolChange = 1
                        indexLigneGlob = indexLigneGlob + 1
                        indexTexteMC = indexTexteMC + 1
                if (trouveUnMC == 0) and (defaut == 1):
                    logging.warning(
                        "OPTION  (defaut) de CALCG a verifier ligne %s", c.lineno
                    )
                    ecritErreur((command, fact, motcle, "DEFAUT"), c.lineno)
    if boolChange:
        jdc.reset(jdc.getSource())


# --------------------------------------------------------------------------------
def changementValeurDsMCFSiRegle(
    jdc, command, fact, motcle, DictNouvVal, liste_regles, defaut=0
):
    # --------------------------------------------------------------------------------
    if command not in jdcSet:
        return
    mesRegles = regles.ensembleRegles(liste_regles)
    liste = ()
    changementValeurDsMCF(
        jdc, command, fact, motcle, DictNouvVal, liste, mesRegles, defaut
    )


# ---------------------------------------------------------------------------------------
def changementValeurDsMCFAvecAvertissement(
    jdc, command, fact, motcle, DictNouvVal, liste
):
    # ---------------------------------------------------------------------------------------
    if command not in jdcSet:
        return
    defaut = 0
    if liste[-1] == "defaut":
        defaut = 1
    changementValeurDsMCF(jdc, command, fact, motcle, DictNouvVal, liste, defaut)


# --------------------------------------------------------------------------
def changementValeurAvecAvertissement(jdc, command, motcle, DictNouvVal, liste):
    # --------------------------------------------------------------------------
    if command not in jdcSet:
        return
    defaut = 0
    if liste[-1] == "defaut":
        defaut = 1
    changementValeur(jdc, command, motcle, DictNouvVal, liste, defaut)


# --------------------------------------------------------------------------
def suppressionValeurs(jdc, command, motcle, liste):
    # --------------------------------------------------------------------------

    if command not in jdcSet:
        return
    boolChange = 0
    for c in jdc.root.childNodes:
        if c.name != command:
            continue
        for mc in c.childNodes:
            if mc.name != motcle:
                continue
            indexLigneGlob = mc.lineno - 1
            while indexLigneGlob < mc.endline - 1:
                MaLigneTexte = jdc.getLines()[indexLigneGlob]
                MaLigne = MaLigneTexte
                for Valeur in liste:
                    debutMC = MaLigne.find(motcle)
                    if debutMC == -1:
                        debutMC = 0
                    debut1 = MaLigne[0:debutMC]
                    chercheLigne = MaLigne[debutMC:]
                    trouve = chercheLigne.find(Valeur)
                    premier = 0
                    if trouve > 1:  # on a au moins une quote
                        debut = debut1 + chercheLigne[0 : trouve - 1]
                        index = -1
                        while (-1 * index) < len(debut):
                            if debut[index] == "(":
                                premier = 1
                                if index == -1:
                                    index = len(debut)
                                else:
                                    index = index + 1
                                break
                            if debut[index] == ",":
                                break
                            if debut[index] != " ":
                                assert 0
                            index = index - 1
                        debLigne = debut[0:index]
                        fin = trouve + len(Valeur) + 1
                        if premier == 1 and chercheLigne[fin] == ",":
                            fin = fin + 1  # on supprime la ,
                        finLigne = chercheLigne[fin:]
                        MaLigne_tmp = debLigne + finLigne
                        # traitement ligne commancant par ,
                        if len(MaLigne_tmp.strip()) > 0:
                            if MaLigne_tmp.strip()[0] == ",":
                                MaLigne = MaLigne_tmp.strip()[1:]
                            else:
                                MaLigne = MaLigne_tmp[0:]
                        else:
                            MaLigne = MaLigne_tmp[0:]
                        boolChange = 1
                    jdc.getLines()[indexLigneGlob] = MaLigne
                indexLigneGlob = indexLigneGlob + 1
    if boolChange:
        jdc.reset(jdc.getSource())


# ----------------------------------------------
def appelleMacroSelonValeurConcept(jdc, macro, genea):
    # ----------------------------------------------
    if macro not in jdcSet:
        return
    boolChange = 0
    fact = genea[0]
    motcle = genea[1]
    chaine = "CO"
    for c in jdc.root.childNodes:
        if c.name != macro:
            continue
        for mcF in c.childNodes:
            if mcF.name != fact:
                continue
            l = mcF.childNodes[:]
            l.reverse()
            for ll in l:
                trouveValeur = 0
                for mc in ll.childNodes:
                    if mc.name != motcle:
                        continue
                    TexteMC = mc.getText(jdc)
                    liste_ligne_MC = TexteMC.splitlines()
                    indexLigneGlob = mc.lineno - 2
                    trouveTexteMC = 0
                    trouveegal = 0
                    trouvechaine = 0
                    trouveparent = 0
                    trouvequote = 0
                    while indexLigneGlob < mc.endline:
                        indexLigneGlob = indexLigneGlob + 1
                        MaLigneTexte = jdc.getLines()[indexLigneGlob]

                        # on commence par chercher TABLE par exemple
                        # si on ne trouve pas on passe a la ligne suivante
                        if trouveTexteMC == 0:
                            indice = MaLigneTexte.find(motcle)
                            if indice < 0:
                                continue
                            trouveTexteMC = 1
                        else:
                            indice = 0

                        # on cherche =
                        aChercher = MaLigneTexte[indice:]
                        if trouveegal == 0:
                            indice = aChercher.find("=")
                            if indice < 0:
                                continue
                            trouveegal = 1
                        else:
                            indice = 0

                        # on cherche CO
                        aChercher2 = aChercher[indice:]
                        if trouvechaine == 0:
                            indice = aChercher2.find(chaine)
                            if indice < 0:
                                continue
                            trouvechaine = 1
                        else:
                            indice = 0

                        # on cherche (
                        aChercher3 = aChercher2[indice:]
                        if trouveparent == 0:
                            indice = aChercher3.find("(")
                            if indice < 0:
                                continue
                            trouveparent = 1
                        else:
                            indice = 0

                        # on cherche la '
                        aChercher4 = aChercher3[indice:]
                        if trouvequote == 0:
                            indice = aChercher4.find("'")
                            indice2 = aChercher4.find('"')
                            if (indice < 0) and (indice2 < 0):
                                continue
                            if indice < 0:
                                indice = indice2
                            trouvequote = 1
                        else:
                            indice = 0

                        trouveValeur = 1
                        aChercher5 = aChercher4[indice + 1 :]
                        indice = aChercher5.find("'")
                        if indice < 0:
                            indice = aChercher5.find('"')
                        valeur = aChercher5[:indice]
                        break

                if trouveValeur == 0:
                    logging.error(
                        "Pb de traduction pour MACR_LIGNE_COUPE : Pas de nom de Concept identifiable"
                    )
                    return

                if boolChange:
                    jdc.reset(jdc.getSource())
                    logging.error(
                        "Pb du traduction pour MACR_LIGNE_COUPE : Deux noms de Concept possibles"
                    )
                    return

                boolChange = 1
                ligneaTraiter = jdc.getLines()[c.lineno - 1]
                debut = ligneaTraiter[0 : c.colno]
                suite = valeur + "="
                fin = ligneaTraiter[c.colno :]
                ligne = debut + suite + fin
                jdc.getLines()[c.lineno - 1] = ligne
                nbBlanc = len(valeur) + 1
                if c.lineno < c.endline:
                    decaleLignesdeNBlancs(jdc, c.lineno, c.endline - 1, nbBlanc)
    if boolChange:
        jdc.reset(jdc.getSource())


# ----------------------------------------------
def changeTouteValeur(jdc, command, motcle, DictNouvVal, liste=(), defaut=0):
    # ----------------------------------------------
    if macro not in jdcSet:
        return
    boolChange = 0
