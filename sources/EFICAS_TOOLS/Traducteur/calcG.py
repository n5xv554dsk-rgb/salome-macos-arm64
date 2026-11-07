#### -*- coding: utf-8 -*-
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
from Traducteur.parseur import FactNode
from Traducteur.load import jdcSet
import logging

dict_commande={}
dict_contexte={}
dict_contexte_option={}

import sys
#--------------------------------------------------------------------------
def traitementRayon(jdc):
#--------------------------------------------------------------------------

    if "DEFI_FONCTION" not in jdcSet : return
    for c in jdc.root.childNodes:
        if c.name != "DEFI_FONCTION" : continue
        monTexte=jdc.getLines()[c.lineno-1]
        monNomVariable=monTexte.split("=")[0]
        aExecuter=monNomVariable+'=0'
        dict_commande[monNomVariable]=c
        exec aExecuter in dict_contexte
    liste_MC=(("CALC_G","R_INF_FO"),("CALC_G","R_SUP_FO"),("CALC_G","MODULE_FO"))
    liste_achanger = chercheValeurSelonGenea2 (jdc,liste_MC)
    liste_MC=(("CALC_THETA","THETA_3D","R_INF_FO"),("CALC_THETA","THETA_3D","R_SUP_FO"),("CALC_THETA","THETA_3D","MODULE_FO"))
    liste_achanger2 = chercheValeurSelonGenea3 (jdc,liste_MC)
    liste_achanger=liste_achanger+liste_achanger2
    for item in liste_achanger :
        commande=dict_commande[item]
        changeValeurABSCNiveau1(commande,jdc)

#----------------------------------
def changeValeurABSCNiveau1(c,jdc):
#----------------------------------
    for child in c.childNodes:
        if child.name != "NOM_PARA":continue
        MonTexte=child.getText(jdc)
        if len(MonTexte.splitlines()) > 1 :
            print "Le Traducteur ne sait pas gerer"
            assert(0)
        MonTexte=jdc.getLines()[child.lineno-1]
        debut=MonTexte.find("NOM_PARA")
        debChaine=MonTexte[0:debut+8]
        ancien=MonTexte[debut+8:]
        egal,nomval,fin=ancien.split("'",2)
        nouvelleLigne=debChaine+egal+"'ABSC'"+fin
        jdc.getLines()[child.lineno-1]=nouvelleLigne
        logging.info("renommage parametre ABSC ligne %d",child.lineno-1)
    return

#--------------------------------------------------------------------------
def chercheValeurSelonGenea2(jdc,liste_cherche_valeur):
#
#--------------------------------------------------------------------------
    liste_valeurs=[]
    for genea in liste_cherche_valeur:
        profondeur=len(genea)
        if profondeur > 2 :
            print "la methode chercheValeurSelonGenea ne convient"
            print "pas pour cette genealogie"
            assert(0)
        command=genea[0]
        fact=genea[1]

        for c in jdc.root.childNodes:
            if c.name != command:continue
            for mc in c.childNodes:
                if mc.name != fact:continue
                MonTexte=mc.getText(jdc)
                try :
                #if ( 1) :
                    exec MonTexte in dict_contexte
                    monNomVar=MonTexte.split("=")[1]
                    monNomVarOk=monNomVar
                    i=-1
                    while (monNomVar[i] == "," or  monNomVar[i] == " ") :
                        monNomVarOk=monNomVar[0:i]
                        i=i-1
                    monNomVar=monNomVarOk
                    i=0
                    while (monNomVar[i] == " ") :
                        monNomVarOk=monNomVar[1:]
                        i=i+1
                    monNomVar=monNomVarOk
                    if monNomVar not in liste_valeurs : liste_valeurs.append(monNomVar)
                except :
                #else :
                    logging.error("Pb pour renommer le parametre ABSC dans defi_fonctions selon calcg")
                    pass
    return liste_valeurs


#--------------------------------------------------------------------------
def chercheValeurSelonGenea3(jdc,liste_cherche_valeur):
#--------------------------------------------------------------------------
    liste_valeurs=[]
    for genea in liste_cherche_valeur:
        profondeur=len(genea)
        if profondeur > 3 :
            print "la methode chercheValeurSelonGenea ne convient"
            print "pas pour cette genealogie"
            assert(0)
        command=genea[0]
        fact=genea[1]
        mc=genea[2]

        for c in jdc.root.childNodes:
            if c.name != command : continue
            for mcf in c.childNodes:
                if mcf.name != fact : continue
                l=mcf.childNodes[:]
                for ll in l:
                    for lc in ll.childNodes:
                        if lc.name !=mc : continue
                        MonTexte=lc.getText(jdc)
                        try :
                        #if ( 1) :
                            exec MonTexte in dict_contexte
                            #monNomVar=MonTexte.split("=")[1][0:-1]
                            monNomVar=MonTexte.split("=")[1]
                            monNomVarOk=monNomVar
                            i=-1
                            while (monNomVar[i] == "," or  monNomVar[i] == " ") :
                                monNomVarOk=monNomVar[0:i]
                                i=i-1
                            monNomVar=monNomVarOk
                            i=0
                            while (monNomVar[i] == " ") :
                                monNomVarOk=monNomVar[1:]
                                i=i+1
                            monNomVar=monNomVarOk
                            if monNomVar not in liste_valeurs : liste_valeurs.append(monNomVar)
                        except :
                        #else :
                            logging.error("Pb pour renommer le parametre ABSC dans defi_fonctions selon calcg")
                            pass
    return liste_valeurs
