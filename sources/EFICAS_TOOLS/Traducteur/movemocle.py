# -*- coding: iso-8859-1 -*-
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
from Traducteur import removemocle
from Traducteur import inseremocle
from Traducteur.parseur import lastParen
from Traducteur.load import jdcSet

debug = 0


# -----------------------------------------------------
def moveMotCleFromFactToFather(jdc, command, fact, mocle):
    # -----------------------------------------------------
    # exemple type : IMPR_GENE

    if command not in jdcSet:
        return
    boolChange = 0
    commands = jdc.root.childNodes[:]
    commands.reverse()
    for c in commands:
        if c.name != command:
            continue
        boolchange_c = 0
        for mc in c.childNodes:
            if mc.name != fact:
                continue
            l = mc.childNodes[:]
            for ll in l:
                for n in ll.childNodes:
                    if n.name != mocle:
                        continue
                    # test boolchange_c :il faut le faire une seule fois par commande sinon duplication du mot clé
                    if boolchange_c != 0:
                        continue
                    if debug:
                        print("Changement de place :", n.name, n.lineno, n.colno)
                    MonTexte = n.getText(jdc)
                    boolChange = 1
                    boolchange_c = 1
                    inseremocle.insereMotCle(jdc, c, MonTexte)
                    logging.info("Changement de place  %s ligne %s ", n.name, n.lineno)

    if boolChange:
        jdc.reset(jdc.getSource())
    removemocle.removeMotCleInFact(jdc, command, fact, mocle)


# ----------------------------------------------------------------------------
def moveMotCleFromFactToFactMulti(jdc, oper, factsource, mocle, liste_factcible):
    # ----------------------------------------------------------------------------
    # exemple type STAT_NON_LINE et RESI_INTER_RELA
    for factcible in liste_factcible:
        moveMotCleFromFactToFact(jdc, oper, factsource, mocle, factcible)
    removemocle.removeMotCleInFact(jdc, oper, factsource, mocle)


# ----------------------------------------------------------------------------
def moveMotCleFromFactToFact(jdc, oper, factsource, mocle, factcible):
    # ----------------------------------------------------------------------------
    if oper not in jdcSet:
        return
    if debug:
        print("moveMotCleFromFactToFact pour ", oper, factsource, mocle, factcible)
    boolChange = 0
    commands = jdc.root.childNodes[:]
    commands.reverse()
    for c in commands:
        if c.name != oper:
            continue
        cible = None
        for mc in c.childNodes:
            if mc.name != factcible:
                continue
            else:
                cible = mc
                break
        if cible == None:
            if debug:
                print(
                    "Pas de changement pour ",
                    oper,
                    " ",
                    factsource,
                    " ",
                    mocle,
                    "cible non trouvée",
                )
            continue

        for mc in c.childNodes:
            source = None
            if mc.name != factsource:
                continue
            else:
                source = mc
                break
        if source == None:
            if debug:
                print(
                    "Pas de changement pour ",
                    oper,
                    " ",
                    factsource,
                    " ",
                    mocle,
                    "source non trouvée",
                )
            continue

        if debug:
            print(
                "Changement pour ",
                oper,
                " ",
                factsource,
                " ",
                mocle,
                "cible et source trouvées",
            )
        l = source.childNodes[:]
        for ll in l:
            for n in ll.childNodes:
                if n.name != mocle:
                    continue
                MonTexte = n.getText(jdc)
                inseremocle.insereMotCleDansFacteur(jdc, cible, MonTexte)
                boolChange = 1
                logging.info(
                    "Changement de place   %s ligne %s vers %s",
                    n.name,
                    n.lineno,
                    cible.name,
                )
    if boolChange:
        jdc.reset(jdc.getSource())
    removemocle.removeMotCleInFact(jdc, oper, factsource, mocle)


# -----------------------------------------------------------------------
def moveMotClefInOperToFact(jdc, oper, mocle, factcible, plusieursFois=True):
    # -----------------------------------------------------------------------
    # Attention le cas type est THETA_OLD dans calc_G

    if oper not in jdcSet:
        return
    if debug:
        print("movemocleinoper pour ", oper, mocle, factcible)
    boolChange = 9
    commands = jdc.root.childNodes[:]
    commands.reverse()
    for c in commands:
        if c.name != oper:
            continue
        cible = None
        for mc in c.childNodes:
            if mc.name != factcible:
                continue
            else:
                cible = mc
                break
        if cible == None:
            if debug:
                print(
                    "Pas de changement pour ",
                    oper,
                    " ",
                    factcible,
                    " ",
                    "cible non trouvée",
                )
            continue

        source = None
        for mc in c.childNodes:
            if mc.name != mocle:
                continue
            else:
                source = mc
                break
        if source == None:
            if debug:
                print(
                    "Pas de changement pour ", oper, " ", mocle, " source non trouvée"
                )
            continue
        MonTexte = source.getText(jdc)
        boolChange = 1
        inseremocle.insereMotCleDansFacteur(jdc, cible, MonTexte, plusieursFois)
    if boolChange:
        jdc.reset(jdc.getSource())
    removemocle.removeMotCle(jdc, oper, mocle)


# ------------------------------------------------------
def copyMotClefInOperToFact(jdc, oper, mocle, factcible):
    # ------------------------------------------------------

    if oper not in jdcSet:
        return
    if debug:
        print("movemocleinoper pour ", oper, mocle, factcible)
    boolChange = 9
    commands = jdc.root.childNodes[:]
    commands.reverse()
    for c in commands:
        if c.name != oper:
            continue
        cible = None
        for mc in c.childNodes:
            if mc.name != factcible:
                continue
            else:
                cible = mc
                break
        if cible == None:
            if debug:
                print(
                    "Pas de changement pour ",
                    oper,
                    " ",
                    factcible,
                    " ",
                    "cible non trouvée",
                )
            continue

        source = None
        for mc in c.childNodes:
            if mc.name != mocle:
                continue
            else:
                source = mc
                break
        if source == None:
            if debug:
                print(
                    "Pas de changement pour ", oper, " ", mocle, " source non trouvée"
                )
            continue
        MonTexte = source.getText(jdc)
        boolChange = 1
        inseremocle.insereMotCleDansFacteur(jdc, cible, MonTexte)
    if boolChange:
        jdc.reset(jdc.getSource())


# ----------------------------------------------------------------------
def moveMCFToCommand(jdc, command, factsource, commandcible, factcible):
    # ----------------------------------------------------------------------
    # exemple CONTACT en 10
    # CONTACT devient commande DEFI_CONTACT/ZONE
    #
    if command not in jdcSet:
        return
    boolChange = 0
    commands = jdc.root.childNodes[:]
    commands.reverse()
    for c in commands:
        if c.name != command:
            continue
        for mcF in c.childNodes:
            if mcF.name != factsource:
                continue
            l = mcF.getText(jdc)
            texte = l.replace(factsource, factcible)
            texte = "xxxx=" + commandcible + "(" + texte + ")\n"
            jdc.splitLine(c.lineno, 0)
            jdc.addLine(texte, c.lineno)
            logging.info(
                "Deplacement de %s dans %s ligne %s", factsource, commandcible, c.lineno
            )
            boolChange = 1
    if boolChange:
        jdc.reset(jdc.getSource())
        jdcSet.add(commandcible)


# -----------------------------------------------------
def fusionMotCleToFact(jdc, command, listeMc, factcible, defaut=0):
    # -----------------------------------------------------
    if command not in jdcSet:
        return
    boolChange = 0
    commands = jdc.root.childNodes[:]
    commands.reverse()
    for c in commands:
        if c.name != command:
            continue
        list_val = []
        trouveUnMC = 0
        for mc in c.childNodes:
            if mc.name not in listeMc:
                continue
            val = mc.getText(jdc).split("=")[1].split(",")[0]
            list_val.append(val)
            trouveUnMC = 1
        if trouveUnMC:
            TexteMC = factcible + "=("
            for val in list_val:
                TexteMC = TexteMC + val + ","
            TexteMC = TexteMC[:-1] + "),"
            inseremocle.insereMotCle(jdc, c, TexteMC)
            jdc.reset(jdc.getSource())
            boolChange = 1
    if boolChange:
        jdc.reset(jdc.getSource())
        for mc in listeMc:
            removemocle.removeMotCle(jdc, command, mc)
            jdc.reset(jdc.getSource())


# -----------------------------------------------------
def fusionMotCleInFact(jdc, command, fact, listeMc, new_name, defaut=0):
    # -----------------------------------------------------
    if command not in jdcSet:
        return
    boolChange = 0
    commands = jdc.root.childNodes[:]
    commands.reverse()
    for c in commands:
        if c.name != command:
            continue
        list_val = []
        trouveUnMC = 0
        for mcF in c.childNodes:
            if mcF.name != fact:
                continue
            for ll in mcF.childNodes[:]:
                for mc in ll.childNodes:
                    if mc.name not in listeMc:
                        continue
                    val = mc.getText(jdc).split("=")[1].split(",")[0]
                    list_val.append(val)
                    trouveUnMC = 1
                if trouveUnMC:
                    TexteMC = new_name + "=(" + ",".join(list_val) + "),"
                    inseremocle.insereMotCleDansFacteur(jdc, mcF, TexteMC)
                    jdc.reset(jdc.getSource())
                    boolChange = 1
    if boolChange:
        jdc.reset(jdc.getSource())
        for mc in listeMc:
            removemocle.removeMotCleInFact(jdc, command, fact, mc)
            jdc.reset(jdc.getSource())


# -----------------------------------------------------
def fusionMCFToMCF(jdc, command, listeMcF, factcible, defaut=0):
    # -----------------------------------------------------
    if command not in jdcSet:
        return
    boolChange = 0
    commands = jdc.root.childNodes[:]
    commands.reverse()
    for c in commands:
        if c.name != command:
            continue
        list_val = []
        trouveUnMC = 0
        TexteMC = factcible + "=("
        esp1 = " " * len(TexteMC)
        pp = 0
        for mcF in c.childNodes:
            if mcF.name not in listeMcF:
                continue
            trouveUnMC = 1
            val = mcF.getText(jdc)
            # esp=esp1+(inseremocle.chercheDebutFacteur(jdc,mcF)-len(mcF.name))*' '
            esp = esp1 + inseremocle.chercheAlignement(jdc, c)
            # print len(esp)
            for ll in mcF.childNodes[:]:
                # if(pp>0): TexteMC+=esp
                TexteMC += "_F("
                for mc in ll.childNodes:
                    val = mc.getText(jdc)
                    TexteMC += val + "\n   " + esp
                    # if('#' in val.split('\n')[-1]): TexteMC+='\n'+esp+'  '
                lastkey = "".join(val.split("=")[-1].split(" "))
                if (len(lastkey.split("(")) - len(lastkey.split(")"))) >= 0:
                    TexteMC += "),\n" + esp
            # TexteMC+='),'
        TexteMC += "),"
        # print TexteMC
        if trouveUnMC:
            inseremocle.insereMotCle(jdc, c, TexteMC)
            jdc.reset(jdc.getSource())
            boolChange = 1
    if boolChange:
        jdc.reset(jdc.getSource())
        for mcF in listeMcF:
            removemocle.removeMotCle(jdc, command, mcF)
            jdc.reset(jdc.getSource())


# --------------------------------------------------------------------
def eclaMotCleToFact(jdc, command, motcle, mot1, mot2, defaut=0):
    # --------------------------------------------------------------------------
    #  exemple STA10 pesanteur devient MCF avec eclatement des valeurs dans les MC
    # On suppose que le MC est sur une seule ligne
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
            indexLigneGlob = mc.lineno - 1
            MaLigneGlob = jdc.getLines()[indexLigneGlob]
            Ligne = TexteMC.split("(")[1].split(")")[0].split(",")
            motcle1 = mot1 + "=" + Ligne[0]
            motcle2 = mot2 + "=(" + Ligne[1] + "," + Ligne[2] + "," + Ligne[3] + ")"
            texte = motcle + "=_F(" + motcle1 + "," + motcle2 + ")"
            num = lastParen(TexteMC)
            Nouveau = MaLigneGlob.replace(TexteMC[0:num], texte)
            jdc.getLines()[indexLigneGlob] = Nouveau
            logging.info(
                "Transformation de %s dans %s ligne %s", motcle, command, c.lineno
            )
            boolChange = 1
    if boolChange:
        jdc.reset(jdc.getSource())
