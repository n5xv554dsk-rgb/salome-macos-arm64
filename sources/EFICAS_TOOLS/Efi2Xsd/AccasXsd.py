#!/usr/bin/env python3
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


import sys, os
import types
import Accas
import imp
from copy import deepcopy, copy
import traceback

# import raw.efficas as efficas
sys.path.insert(0, os.path.abspath(os.path.join(os.getcwd(), "..")))

# ds l init du SIMP il manque siValide et fenetreIhm

from .mapDesTypes import dictSIMPEficasXML, dictSIMPXMLEficas
from .mapDesTypes import dictFACTEficasXML, dictFACTXMLEficas
from .mapDesTypes import dictPROCEficasXML, dictPROCXMLEficas
from .mapDesTypes import dictOPEREficasXML, dictOPERXMLEficas
from .mapDesTypes import dictBLOCEficasXML, dictBLOCXMLEficas
from .mapDesTypes import dictPourCast, dictNomsDesTypes
from .mapDesTypes import listeParamDeTypeTypeAttendu, listeParamDeTypeStr, dictPourCast
from .mapDesTypes import listeParamTjsSequence, listeParamSelonType
from .mapDesTypes import Tuple

PourTraduction = False

from .balisesXSD import *


# -----------------
class X_definition:
# -----------------
    def adjoint(self, liste1, liste2):
        # print ('adjoint', liste1, liste2)
        l = []
        for elt1 in liste1:
            for elt2 in liste2:
                newListe = deepcopy(elt1)
                if elt2 != []:
                    newListe.append(elt2)
                l.append(newListe)
        return l

    def adjointUnMot(self, liste1, mot):
        l = []
        for elt1 in liste1:
            newListe = deepcopy(elt1)
            newListe.append(mot)
            l.append(newListe)
        return l

    def remplaceListeParContenuEtVide(self, liste1, liste2):
        listeFinale = []
        for elt1 in liste1:
            for eltListe in liste2:
                newListe = deepcopy(elt1)
                if eltListe != []:
                    newListe += eltListe
                if newListe not in listeFinale:
                    listeFinale.append(newListe)
        return listeFinale

    def fusionne2Listes(self, liste1, liste2, debug=False):
        if debug: print("fusionne2Liste", liste1, liste2)
        listeFinale = []
        for elt1 in liste1:
            for eltListe in liste2:
                newListe = deepcopy(elt1)
                # newListe=elt1
                if eltListe != []:
                    newListe.append(eltListe)
                listeFinale.append(newListe)
        # if debug : print (listeFinale)
        return listeFinale

    def getNomDuCodeDumpe(self):
        if hasattr(self, "nomDuCodeDumpe"):
            return
        obj = self
        while not hasattr(obj, "nomDuCodeDumpe"):
            obj = obj.pere
        self.nomDuCodeDumpe = obj.nomDuCodeDumpe
        self.code = obj.code

    def getXPathComplet(self):
        obj = self
        textePath = "/" + self.code + ":" + self.nom
        while hasattr(obj, "pere"):
            obj = obj.pere
            if isinstance(obj, X_BLOC):
                continue
            textePath = "/" + self.code + ":" + obj.nom + textePath
        textePath = "." + textePath
        return textePath

    def getXPathSansSelf(self):
        obj = self
        textePath = ""
        while hasattr(obj, "pere"):
            obj = obj.pere
            if isinstance(obj, X_BLOC):
                continue
            textePath = self.code + ":" + obj.nom + "/" + textePath
        textePath = "./" + self.code + ":" + textePath
        return textePath

    def getNomCompletAvecBloc(self):
        obj = self
        texteNom = self.nom
        while hasattr(obj, "pere"):
            texteNom = obj.pere.nom + "_" + texteNom
            obj = obj.pere
        return texteNom

    def metAJourPyxb(self, nomDuTypePyxb, debug=False):
        # if self.nom == 'A' : debug = True
        self.aCreer = False
        self.nomDuTypePyxb = nomDuTypePyxb
        cata = CONTEXT.getCurrentCata()
        nom = "T_" + self.nom
        if (hasattr(self, "nomXSD")) and self.nomXSD != None:
            nom = "T_" + self.nomXSD
        if not (nom in cata.dictTypesXSD.keys()):
            cata.dictTypesXSD[nom] = [ self, ]
            if debug:
                print( "creation de cata.dictTypesXSD ", nom, self.getNomCompletAvecBloc())
        else:
            if not self in cata.dictTypesXSD[nom]:
                cata.dictTypesXSD[nom].append(self)
            if debug: print( " ajout de cata.dictTypesXSD ", nom, self.getNomCompletAvecBloc())

    def definitNomDuTypePyxb(self, forceACreer=False, debug=False):
        if debug: 
            print ("***************************************************")
            print ( " Traitement definitNomDuTypePyxb", self, self.nom, self.nomComplet(), forceACreer,)
            print (self.getNomCompletAvecBloc())
            print ("***************************************************")
        if hasattr(self, "nomDuTypePyxb"):
            self.aCreer = False
            return self.nomDuTypePyxb
        if debug:
            print ("definitNomDuTypePyxb traitement pour ", self.nom)
            print (self.getNomCompletAvecBloc())
        # if debug : traceback.print_stack()
        self.aCreer = True
        cata = CONTEXT.getCurrentCata()
        nom = "T_" + self.nom
        if (hasattr(self, "nomXSD")) and self.nomXSD != None:
            nom = "T_" + self.nomXSD
        if debug: print("nom in cata.dictTypesXSD.keys", nom in cata.dictTypesXSD.keys())
        # if debug and  (nom in cata.dictTypesXSD.keys()) : print ( cata.dictTypesXSD[nom])
        if not (nom in cata.dictTypesXSD.keys()) or cata.dictTypesXSD[nom] == []:
            # il faut tenir compte des re céations des types qui appartenaient a un compo ambigu qu on refusionne
            if debug:
                print( "definitNomDuTypePyxb encore jamais traite ", self.nom, " a pour type", nom,)
            cata.dictTypesXSD[nom] = [ self, ]
            self.nomDuTypePyxb = nom
            self.indiceDuTypePyxb = 0
            if debug:
                print( "************ indiceDuTypePyxb pour", self.getNomCompletAvecBloc(), " mis a ", 0,)
            if debug:
                print("indice a ", 0, "pour", self.getNomCompletAvecBloc())
            return nom
        if debug:
            print( " ----------- definitNomDuTypePyxb deja traite ", self.nom, " suite de l algo",)
        if nom == "T_Consigne":
            return nom

        # print ('***************************************************', self.getNomCompletAvecBloc())
        if debug:
            print("forceACreer : ", forceACreer)
        # if self.nom == 'A' : debug = True
        indice = 0
        if nom in cata.dictTypesXSD.keys():
            if debug:
                print("traitement comparaison indice de ", self.getNomCompletAvecBloc())
            for objAComparer in cata.dictTypesXSD[nom]:
                if objAComparer == self:
                    continue
                # debug=1
                if debug:
                    print("objAComparer", objAComparer.getNomCompletAvecBloc())
                    print("obj", self.getNomCompletAvecBloc())
                # debug=0
                # on peut ne pas avoir de type pyxb
                # si on reconstruit l arbre aprs des fusions de compo ambigus
                if not (hasattr(objAComparer, "indiceDuTypePyxb")):
                    continue
                if objAComparer.indiceDuTypePyxb >= indice:
                    indice = objAComparer.indiceDuTypePyxb + 1
                    if debug: print( "objAComparer.indiceDuTypePyxb", objAComparer.indiceDuTypePyxb,)
        if not forceACreer:
            self.aCreer = False
            listePossible = cata.dictTypesXSD[nom]
            if debug: print("listePossible : ", listePossible, "pour ", nom, self)
            for objAComparer in listePossible:
                if debug: print("comparaison entre ", objAComparer, "et ", self)
                if objAComparer == self:
                    continue
                # on peut ne pas avoir de type pyxb
                # si on reconstruit l arbre aprs des fusions de compo ambigus
                if not (hasattr(objAComparer, "nomDuTypePyxb")):
                    continue
                if debug: print(self.compare(objAComparer))
                if self.compare(objAComparer):
                    self.nomDuTypePyxb = objAComparer.nomDuTypePyxb
                    self.indiceDuTypePyxb = objAComparer.indiceDuTypePyxb
                    if debug:
                        print(self, objAComparer)
                        print(type(self), type(objAComparer))
                        print( "definitNomDuTypePyxb", self.nom, "type identique", objAComparer.nomDuTypePyxb,)
                        print( "indice a ", objAComparer.nomDuTypePyxb, "pour", self.getNomCompletAvecBloc(),)
                    if self not in cata.dictTypesXSD[nom]:
                        cata.dictTypesXSD[nom].append(self)
                    if debug and self not in cata.dictTypesXSD[nom]:
                        print( "ajout ds cata.dictTypesXS", nom, self.getNomCompletAvecBloc(),)
                    if self.label != "SIMP":
                        if objAComparer not in list(cata.dictTypesXSDJumeaux.keys()):
                            cata.dictTypesXSDJumeaux[objAComparer] = [ self, ]
                        else:
                            cata.dictTypesXSDJumeaux[objAComparer].append(self)
                    return objAComparer.nomDuTypePyxb
                # if debug : print ('self', self.getNomCompletAvecBloc())
                # if debug : print ('objAComparer',objAComparer.getNomCompletAvecBloc())
                # if debug : print ('objAComparer.indiceDuTypePyxb', objAComparer.indiceDuTypePyxb)
                # if debug : print ('indice', indice )
                #####if objAComparer.indiceDuTypePyxb >= indice : indice += 1objAComparer.indiceDuTypePyxb
        if debug:
            print(" ----------- definitNomDuTypePyxb pas de type identique trouve")
        self.aCreer = True
        if self not in cata.dictTypesXSD[nom]:
            cata.dictTypesXSD[nom].append(self)
        if debug and self not in cata.dictTypesXSD[nom]:
            print("ajout ds cata.dictTypesXS", nom, self.getNomCompletAvecBloc())
        if indice != 0:
            nomAlter = "T_" + self.nom + "_" + str(indice)
        else:
            nomAlter = "T_" + self.nom
        self.indiceDuTypePyxb = indice
        if debug:
            print( "************ indiceDuTypePyxb pour", self.getNomCompletAvecBloc(), " mis a ", indice,)
        if (hasattr(self, "nomXSD")) and self.nomXSD != None:
            nomAlter = "T_" + self.nomXSD + "_" + str(indice)
        self.nomDuTypePyxb = nomAlter
        if debug:
            print("self.nomDuTypePyxb : ", nomAlter)
        return nomAlter


# ----------------------------------------
class X_compoFactoriseAmbigu(X_definition):
# ----------------------------------------

    def __init__(self, nom, listeDeCreation, pere, typeXSD = None, debug = False):
        #if pere.nom == 'AlgorithmParameters' or pere.nom  == "LeProc": 
        #   debug   = True
        #   typeXSD = 'Fusion'
        self.label = "BlocAmbigu"
        self.nom = nom
        self.pere = pere
        self.statut = "f"
        self.entites = {}
        self.mcXSD = []
        self.typesXSDDejaDumpes = []
        self.ordreMC = []
        self.lesConditions = "  Possible Conditions : "
        self.typeXSD = typeXSD
       
        #debug=1
        if debug:
            print ("___________________________________________________________________")
            print ("je suis dans compoFactoriseAmbigu pour", self.pere, self.pere.nom, "avec typeXSD", typeXSD)
            for i in listeDeCreation:
                print (i.nom)
                print (i, type(i))
                print (i.possedeDejaUnMCFactorise)
            print ("___________________________________________________________________")
        debug=0
        if hasattr(pere, "listeDesCompoAmbigus"):
            pere.listeDesCompoAmbigus.append(self)
        else:
            pere.listeDesCompoAmbigus = [self,]
        doitReecrireLesTypes = False
        for mc in listeDeCreation:
            if hasattr(mc, "condition"):
                self.lesConditions += "\n\t" + mc.condition
            if self.lesConditions.find ('>') > 0: 
               self.lesConditions=self.lesConditions.replace ('>', 'superieur')
            if self.lesConditions.find ('<') > 0: 
               self.lesConditions=self.lesConditions.replace ('<', 'inferieur')
            doitReecrireLesTypes += mc.possedeDejaUnMCFactorise
            self.mcXSD.append(mc)
            self.ordreMC.append(mc.nom)
        # if self.nom == 'B1_B2' : debug = True
        if debug and doitReecrireLesTypes: print("je dois reecrire pour", self.nom)
        if debug: print ("doitReecrireLesTypes", doitReecrireLesTypes)
        if debug: print ("self.mcXSD", self.mcXSD)
        if debug: print ("self.ordreMC", self.ordreMC)
        self.construitEntites(self.mcXSD, debug=debug)
        if debug: print("apres  de self.construitEntites")
        if self.typeXSD == 'Fusion' : self.fusionneLesBlocs()
        else : self.constructionArbrePossibles(debug=debug)
        # self.constructionArbrePossibles2(debug=debug)

        lesPossibles = deepcopy(self.arbrePossibles)
        if debug: print("lesPossibles ", lesPossibles)

        self.getNomDuCodeDumpe()
        self.nomDuTypePyxb = self.definitNomDuTypePyxb()
        if debug: print("CompoAmbigu : ", self.nomDuTypePyxb)
        self.texteSimple = ""
        self.texteComplexeVenantDesFils = ""
        self.texteComplexe = debutTypeSubstDsBlocFactorise.format(self.nomDuTypePyxb)
        # on enleve [] des possibles puisque l elt sera optionnel
        lesPossibles.remove([])
        # if self.nom == 'B1_B2' : debug = True
        if debug: print("________________ init de compoAmbigu", self.nom, lesPossibles)
        # if debug : print ('self.entites', self.entites)
        cata = CONTEXT.getCurrentCata()
        if doitReecrireLesTypes:
            if debug: print("cata.dictTypesXSD avant la boucle", cata.dictTypesXSD["T_A"])
            # on n enleve pas de cata.dictTypesXSD les blocs ambigus qui ne servent plus
            # il faudrait peut-etre gerer la liste de ces blocs et les nettoyer aussi
            # Oui mais comment faire
            #
            if debug: print("doit reecrire les textes pour ", self.nom)
            for nom in self.entites.keys():
                if debug: print("dans for pour enlever les nomDuTypePyxb", nom)
                for mc in self.entites[nom]:
                    if debug: print("traitement de ", nom, "mot clef", mc)
                    if hasattr(mc, "nomDuTypePyxb"):
                        clef = mc.nomDuTypePyxb
                        # if debug : print ('avec la clef  ', clef)
                        # PN : comprendre pourquoi certains MC sont en double ???
                        try:
                            if debug: print( "remove ds cata.dictTypesXSD", clef, mc.getNomCompletAvecBloc(),)
                            while mc in cata.dictTypesXSD[clef]:
                                cata.dictTypesXSD[clef].remove(mc)
                        except:
                            print("ds le except pour dicTypeXSD", nom)
                    if hasattr(mc, "nomDuTypePyxb"): delattr(mc, "nomDuTypePyxb")
                    if hasattr(mc, "aDejaEteDumpe"): delattr(mc, "aDejaEteDumpe")
                    if hasattr(mc, "entites"): self.remetSousArbreAVide(mc)
                    if hasattr(mc, "indiceDuTypePyxb"): delattr(mc, "indiceDuTypePyxb")
                    if debug:
                        print( "************ indiceDuTypePyxb pour", self.getNomCompletAvecBloc(), " mis a  0",)
                    # if mc in cata.dictTypesXSDJumeaux.keys() : print (mc.nom, cata.dictTypesXSDJumeaux[mc][0].nom)

            if debug:
                print("cata.dictTypesXSD apres la boucle", cata.dictTypesXSD["T_A"])
            if debug:
                for mc in cata.dictTypesXSD["T_A"]:
                    print(mc.getNomCompletAvecBloc())
            # if debug : print ('cata.dictTypesXSD apres la boucle', cata.dictTypesXSD)
        debug = False
        self.mcXSD = self.factoriseEtCreeDump( lesPossibles, nomAppel=self.nom, debug=debug)
        if debug:
            print("self.mcXSD", self.mcXSD)
        self.texteComplexe += finTypeSubstDsBlocFactorise
        self.texteComplexe += self.texteComplexeVenantDesFils
        # print ('fin pour prepareDumpXSD pour', self.nom)


    def compare(self, autreMC):
        if self.label != autreMC.label:
            return False
        # PN : le bug est la
        # arbre des possibles identiques mais les types different
        # comment faire ?
        # print (self.arbrePossibles)
        # print (autreMC.arbrePossibles)
        # if self.arbrePossibles== autreMC.arbrePossibles : return True
        return False

    def construitEntites(self, laListe, debug=False):
        # debug = False
        for mc in laListe:
            if mc.nom in self.entites.keys():
                self.entites[mc.nom].append(mc)
            else:
                self.entites[mc.nom] = [
                    mc,
                ]
            if debug: print("mc.nom", mc.nom, hasattr(mc, "nomDuTypePyxb"))
            if mc.label == "BLOC" or mc.label == "BlocAmbigu":
                self.ajouteLesMCFilsAEntite(mc)
                if debug:
                    print(mc.nom, " a pour entites ", mc.entites)
                    print(self.nom, " a pour entites ", self.entites)

    def ajouteLesMCFilsAEntite(self, blocMc):
        for mcFilsNom in blocMc.entites.keys():
            if mcFilsNom == "Consigne" or mcFilsNom == "blocConsigne":
                continue
            if mcFilsNom not in self.entites.keys():
                self.entites[mcFilsNom] = []
            if blocMc.label == "BlocAmbigu":
                for mc in blocMc.entites[mcFilsNom]:
                    self.entites[mcFilsNom].append(mc)
                    if mc.label == "BLOC" or mc.label == "BlocAmbigu":
                        self.ajouteLesMCFilsAEntite(mc)
            else:
                self.entites[mcFilsNom].append(blocMc.entites[mcFilsNom])
                if (
                    blocMc.entites[mcFilsNom].label == "BLOC"
                    or blocMc.entites[mcFilsNom].label == "BlocAmbigu"
                ):
                    self.ajouteLesMCFilsAEntite(blocMc.entites[mcFilsNom])

    def fusionneLesBlocs(self, debug=False):
        if debug: print("construction pour FACT ambigu _______________", self.nom)
        self.arbrePossibles = []
        self.a = []
        for child in self.mcXSD:
            if debug : print( "appel construitTousLesFils pour", child.nom, " à partir de ", self.nom,)
            child.tousLesFils = []
            child.construitTousLesFils()
            for fils in child.tousLesFils :
                #if fils not in self.arbrePossibles : self.arbrePossibles.append(fils)
                if fils not in self.a : self.a.append(fils)
        self.arbrePossibles.append(self.a)
        self.arbrePossibles.append([])

    def constructionArbrePossibles(self, debug=False):
        if debug:
            print("______________________________________")
        if debug:
            print("construction pour FACT ambigu _______________", self.nom)
        toutesLesLignes = [[]]
        for child in self.mcXSD:
            if debug and not hasattr(child, "arbrePossibles"):
                print( "appel construitArbrePossibles pour", child.nom, " à partir de ", self.nom,)
            if not hasattr(child, "arbrePossibles"):
                child.construitArbrePossibles()
            if debug:
                print("_____________________________")
                print(child, child.arbrePossibles)
                print(child, len(child.arbrePossibles))
            if child.label != "BLOC":
                toutesLesLignes = deepcopy(
                    self.fusionne2Listes(toutesLesLignes, child.arbrePossibles)
                )
            else:
                toutesLesLignes = deepcopy(
                    self.fusionne2Listes(toutesLesLignes, [child.nom, []])
                )
            if debug:
                print(len(toutesLesLignes))
                # print (toutesLesLignes)
                print("_____________________________")
            if debug:
                print("apres  construitArbrePossibles pour", child.nom)
            # print (self.nom, len(child.arbrePossibles))

        lignesAGarder = []
        for ligne in toutesLesLignes:
            blocContenus = []
            aAjouter = True
            for mc in ligne:
                objMC = self.entites[mc][0]
                if objMC.label == "BLOC":
                    blocContenus.append(objMC)
            for b in blocContenus:
                for frere in blocContenus[blocContenus.index(b) + 1 :]:
                    if b.isDisjoint(frere):
                        continue
                    aAjouter = False
                    break
                if not aAjouter:
                    break
            if aAjouter and ligne not in lignesAGarder:
                lignesAGarder.append(ligne)

        if debug:
            print("\t les lignes à garder")
            for l in lignesAGarder:
                print("\t", l)
        self.arbrePossibles = []
        for ligne in lignesAGarder:
            for newLigne in self.deploye(ligne):
                if newLigne not in self.arbrePossibles:
                    self.arbrePossibles.append(newLigne)
        if debug:
            print("\n\t l arbre des possibles")
            for l in self.arbrePossibles:
                print("\t", l)
            print("fin pour ______________________________________", self.nom)

    def remetSousArbreAVide(self, mc, debug=False):
        # if mc.nom=='F1' : debug=True;
        if debug:
            print("remetSousArbreAVide de ", mc.nom, mc.entites)
        for mcFilsNom in mc.entites:
            mcFils = mc.entites[mcFilsNom]
            if debug:
                print(mcFils)
            if hasattr(mcFils, "nomDuTypePyxb"):
                clef = mcFils.nomDuTypePyxb
                if debug:
                    print("remetSousArbreAVide clef ", mcFils.nomDuTypePyxb)
                try:
                    if debug:
                        print(
                            "remove ds cata.dictTypesXSD",
                            clef,
                            mcFils.getNomCompletAvecBloc(),
                        )
                    while mcFils in cata.dictTypesXSD[clef]:
                        cata.dictTypesXSD[clef].remove(mcFils)
                except:
                    pass
            if hasattr(mcFils, "nomDuTypePyxb"):
                delattr(mcFils, "nomDuTypePyxb")
            if hasattr(mcFils, "aDejaEteDumpe"):
                delattr(mcFils, "aDejaEteDumpe")
            if hasattr(mcFils, "entites"):
                self.remetSousArbreAVide(mcFils, debug=debug)

    def deploye(self, ligne):
        toutesLesLignes = [[]]
        for mc in ligne:
            # print ( 'mc in deploye', mc)
            objMC = self.entites[mc][0]
            # print ( 'nom', objMC.nom, objMC.label)
            if objMC.label == "BLOC" or objMC.label == "BlocAmbigu":
                toutesLesLignes = deepcopy(
                    self.remplaceListeParContenuEtVide(
                        toutesLesLignes, objMC.arbrePossibles
                    )
                )
            else:
                toutesLesLignesRetour = deepcopy(self.adjointUnMot(toutesLesLignes, mc))
        return toutesLesLignes

    def construitArbrePossibles(self):
        # inutile car on a deja l arbre mais appele parfois
        # print ('dans X_factCompoAmbigu ne fait rien', self.nom, self.arbrePossibles)
        pass

    def dumpXsd(self, dansFactorisation=False, multiple=False, first=False):
        self.fr=""
        self.ang=""
        # on ne fait rien, tout a ete fait dans le init
        self.lesConditions += '\n'
        self.texteElt = substDsSequence.format( self.code, self.nomDuTypePyxb, 0, 1, self.lesConditions)

    def nomComplet(self):
        print("dans nomComplet pourquoi ?", self, self.nom)

    def factoriseEtCreeDump(self, laListe,  nomAppel=None, debug=False):
        if debug : print('______________ debut factoriseetCreeDump',self.nom, laListe,  nomAppel)
        if debug : print('______________ ',  nomAppel)
        debug=False
        maListeRetour = []
        aReduire = {}

        if [] in laListe:
            declencheChoiceAvecSeqVid = True
            while [] in laListe:
                laListe.remove([])
        else:
            declencheChoiceAvecSeqVid = False

        for ligne in laListe:
            if ligne[0] in aReduire.keys():
                if len(ligne) == 1:
                    aReduire[ligne[0]].append([])
                else:
                    aReduire[ligne[0]].append(ligne[1:])
            else:
                if len(ligne) == 1:
                    aReduire[ligne[0]] = [[]]
                else:
                    aReduire[ligne[0]] = [ ligne[1:], ]

        if debug: print( "la Liste", laListe, "declencheChoiceAvecSeqVid : ", declencheChoiceAvecSeqVid,)
        if debug: print("aReduire", aReduire, "keys", aReduire.keys())
        if len(aReduire.keys()) == 1:
            if self.typeXSD == 'Fusion' :
                creeChoice = False
                creeSequence = False
                self.texteComplexe += debutChoiceMultiple
            elif declencheChoiceAvecSeqVid == False:
                creeChoice = False
                creeSequence = True
                self.texteComplexe += debSequenceDsBloc
            else:
                creeChoice = True
                creeSequence = False
                # pour regler le souci du 1er Niveau
                self.texteComplexe +=  debutChoiceDsBloc
        else:
            # self.texteComplexe +=  debutChoiceDsBlocAvecMin.format(min); 
            self.texteComplexe +=  debutChoiceDsBloc
            creeChoice = True
            creeSequence = False

        if debug:
            print("creeSequence", creeSequence, "creechoice", creeChoice)
        # print (aReduire)
        for nomMC in aReduire.keys():
            if debug:
                print( "--------------------------------------------- boucle for", nomMC, aReduire[nomMC],)
            listeSuivante = aReduire[nomMC]
            if creeChoice and listeSuivante != [[]]:
                self.texteComplexe +=  debSequenceDsBloc
            if debug:
                print("ajouteAuxTextes de ", nomMC)
            self.ajouteAuxTextes(nomMC)
            if listeSuivante == [[]]:
                continue  # Est-ce toujours vrai ?
            if debug:
                print("listeSuivante", listeSuivante)
            aTraiter = listeSuivante
            if debug:
                print("aTraiter", aTraiter)
            if len(listeSuivante) == 1:
                self.ajouteAuxTextes(listeSuivante[0])
            else:
                self.factoriseEtCreeDump( listeSuivante, nomMC)
            # if len(aTraiter) == 1 :
            #     if not(isinstance(aTraiter[0],list)) : self.ajouteAuxTextes(aTraiter[0])
            #     while len(aTraiter) == 1 and isinstance(aTraiter[0],list):  aTraiter=aTraiter[0]
            #     for mc in aTraiter : self.ajouteAuxTextes(mc)
            # else :
            #    self.factoriseEtCreeDump(aTraiter, nomMC)

            if creeChoice:
                self.texteComplexe +=  finSequenceDsBloc
            if debug: print( "--------------------------------------------- fin boucle for", nomMC,)

        if declencheChoiceAvecSeqVid:
            self.texteComplexe +=  debSequenceDsBloc
            self.texteComplexe +=  finSequenceDsBloc
        if creeChoice or  self.typeXSD == 'Fusion' :
            self.texteComplexe +=  finChoiceDsBloc
        if creeSequence:
            self.texteComplexe +=  finSequenceDsBloc

        ##if debug : print (self.texteSimple)
        if debug: print("______", " self.texteComplexe")
        if debug: print(self.texteComplexe)
        # if debug : print ('_____', 'self.texteComplexeVenantDesFils')
        # if self.nom=='B1_B2' : print ('___________________')
        # if self.nom=='B1_B2' : print (self.texteComplexeVenantDesFils)
        if debug: print("ma Liste Retour", maListeRetour)
        if debug: print("fin pour _______________________________", self.nom)
        return maListeRetour

    def ajouteAuxTextes(self, nomMC, debug=False):
        # PNPNPN
        # debug = True
        if debug and nomMC != []:
            print("______________________________________________________")
            print( "ajouteAuxTextes", nomMC, self.nom,)
        debug = False

        #  for i in self.entites.keys() : print (self.entites[i][0].nom)

        # PN change le 17 fevrier . Est-ce normal  d arriver la ?
        # if faut traiter les Blocs exclusifs qui donnent des choices de sequences
        # mais celles-ci risquent d etre ambigues

        if nomMC == []:
            return
        # on a un niveau de liste par niveau de bloc imbrique
        # voir cata_UQ
        while isinstance(nomMC, list):
            if nomMC == []: return
            if len(nomMC) == 1: nomMC = nomMC[0]
            elif isinstance(nomMC[0], list): nomMC = nomMC[0]
            else:
                for mc in nomMC: self.ajouteAuxTextes(mc, debug)
                return

        while isinstance(nomMC, list):
            if nomMC == []: return  # on garde les [] dans les choix sinon souci sur les sequences/choix
            nomMC = nomMC[0]

        if debug: print("ajouteAuxTextes apresWhile", nomMC)
        if nomMC == "Consigne" or nomMC == "blocConsigne": return
        # if debug : print (nomMC, 'dans ajoute vraiment aux textes', self.entites )
        if debug: print(nomMC, "dans ajoute vraiment aux textes")
        if debug: print("avec pour entites ", self.entites[nomMC])
        if len(self.entites[nomMC]) == 1:
            mc = self.entites[nomMC][0]
            mc.dumpXsd(dansFactorisation=True)
            self.texteComplexe +=  mc.texteElt
            if debug: print("mc.aCreer ", mc.aCreer)
            if mc.aCreer: self.texteComplexeVenantDesFils += mc.texteComplexe
            if mc.aCreer: self.texteSimple += mc.texteSimple
            if mc.aCreer: mc.aCreer = False
            if debug:
                print("self.texteSimple", self.texteSimple)
                print( "self.texteComplexeVenantDesFils", self.texteComplexeVenantDesFils)
            return

        leType = type(self.entites[nomMC][0])
        for e in self.entites[nomMC][1:]:
            if type(e) != leType:
                print("Projection XSD impossible, changez un des ", nomMC)
                exit()

        # cas des matrices :
        if (self.entites[nomMC][0].label == "SIMP") and hasattr( self.entites[nomMC][0].type[0], "typElt"):
            typeEltMatrice = self.entites[nomMC][0].type[0].typElt
            memeElt = 1
            nbColsMin = self.entites[nomMC][0].type[0].nbCols
            nbColsMax = self.entites[nomMC][0].type[0].nbCols
            nbLigsMin = self.entites[nomMC][0].type[0].nbLigs
            nbLigsMax = self.entites[nomMC][0].type[0].nbLigs
            for e in self.entites[nomMC][1:]:
                if not (hasattr(e.type[0], "typElt")):
                    print("Projection XSD impossible, changez un des ", nomMC)
                    print("melange de matrice et de non matrice")
                    exit()
                if not (e.type[0].typElt == typeEltMatrice): memeElt = O
                else:
                    if nbColsMin > e.type[0].nbCols: nbColsMin = e.type[0].nbCols
                    if nbColsMax < e.type[0].nbCols: nbColsMax = e.type[0].nbCols
                    if nbLigsMin > e.type[0].nbLigs: nbLigsMin = e.type[0].nbLigs
                    if nbLigsMax < e.type[0].nbLigs: nbLigsMax = e.type[0].nbLigs
            if debug and memeElt: print("memeElt : ", memeElt)
            if memeElt:
                self.fusionneDesMatricesDeMemeType( nomMC, nbColsMin, nbColsMax, nbLigsMin, nbLigsMax)
            else:
                self.fusionneDesMatrices(self, nomMC)
            if debug: print("fin fusion des matrices")
            return

        # cette boucle ne fonctionne que pour des SIMP
        #if nomMC=='StoreSupplementaryCalculations': debug = True
        #if nomMC=='ValueTemplate': debug = True
        resteATraiter = copy(self.entites[nomMC])
        if debug:
            print("________ calcul des unions resteATraiter", self.nom, '\n', resteATraiter)
            print (len(self.entites[nomMC]))
            print (self.entites[nomMC])
            # for i in resteATraiter : print (i.nom)
        listePourFusion = []
        first = 1
        # On compare les types 1 à 1
        while resteATraiter != []:
            nvlListeATraiter = []
            mc = resteATraiter[0]
            listePourFusion.append(mc)
            for autre in resteATraiter[1:]:
                if not (mc.compare(autre)): nvlListeATraiter.append(autre)
            resteATraiter = copy(nvlListeATraiter)

        listePourUnion = []
        # On fusionne ceux dont seuls les into changent
        # Est-ce que cette boucle n est pas suffisante ?
        # Si les defaut ne sont pas les memes pas de souci (je crois)
        # Que faire si min et max ne sont pas les memes
        # je pense qu il faut avoir le min minimum et le max maximum
        # sur l arité de l element mais du coup liste ou pas liste ?
        # A verifier avec Eric
        # peur d un melange si intoXSD
        resteATraiter = listePourFusion
        while resteATraiter != []:
            nvlListeATraiter = []
            mc = resteATraiter[0]
            listePourUnion.append(mc)
            for autre in resteATraiter[1:]:
                if not (mc.compareEtFusionneInto(autre, debug)): nvlListeATraiter.append(autre)
            resteATraiter = copy(nvlListeATraiter)

        if debug: 
            print("listePourUnion apres le While: \n", listePourUnion)
            print (len(listePourUnion))
        # on ajoute les fact 6/12/2022 dans le cas de len(listePourUnion =1)
        if len(listePourUnion) == 1:
            mc = listePourUnion[0]
            if debug: print("ajout de ", mc.nom, " pour ", self.nom)
            mc.dumpXsd(dansFactorisation=True, multiple=False, first=first)
            if debug: print("mc.aCreer = ", mc.aCreer)
            # if debug : print ('mc.texteSimple = ', mc.texteSimple)
            if debug: print("mc.texteComplexe = ", mc.texteComplexe)
            self.texteComplexe +=  mc.texteElt
            if mc.aCreer: self.texteComplexeVenantDesFils += mc.texteComplexe
            if mc.aCreer: self.texteSimple += mc.texteSimple
            for mcIdent in self.entites[nomMC][1:]:
                mcIdent.metAJourPyxb(mc.nomDuTypePyxb)
                mcIdent.indiceDuTypePyxb = mc.indiceDuTypePyxb
            if mc.aCreer: mc.aCreer = False
            return

        # on ajoute le nom de l element
        if not (isinstance(self.entites[nomMC][0], Accas.SIMP)):
            sontTousDisjoint = True
            index = 1
            if debug:
                print("on cherche si ils sont disjoints : ", self.entites[nomMC])
            for mc in self.entites[nomMC]:
                if debug: print("compare mc", mc, " avec :")
                for mcFrere in self.entites[nomMC][index:]:
                    ok = mc.isDisjoint(mcFrere)
                    if not ok:
                        sontTousDisjoint = False
                        break
                if not (sontTousDisjoint):
                    break
                index += 1
            if not sontTousDisjoint:
                print( "2 blocs freres ont le meme nom et ne sont pas disjoints : pas encore traite")
                print("Projection XSD impossible, changez un des ", nomMC)
                exit()
            if debug:
                print("les 2 blocs sont disjoints")
            self.fusionneDsUnChoix(nomMC,  debug=debug)
            if debug: print("self.nom", self.nom)
            if debug: print("self.texteComplexe", self.texteComplexe)
            if debug: print("self.texteSimple", self.texteSimple)
            if debug: print("self.texteElt", self.texteElt)
            if debug: print("________________________")
            return

        if hasattr(self.entites[nomMC][0], "aDejaEteDumpe"):  # on a deja cree le type
            if debug: print(self.entites[nomMC][0].nomDuTypePyxb, " deja dumpe")
        else:
            if debug: print("appel de dumpXsd")
            self.entites[nomMC][0].aDejaEteDumpe = True
            self.entites[nomMC][0].dumpXsd( dansFactorisation=True, multiple=True, first=first)
            if debug: print(self.entites[nomMC][0].nomDuTypePyxb)

        texteDocUnion = "\n"
        i = 1
        for mc in self.entites[nomMC]:
            if mc.ang != "":
                texteDocUnion += str(i) + "- " + mc.ang + " or \n"
                i = i + 1
            elif mc.fr != "":
                texteDocUnion += str(i) + "- " + mc.fr + " ou \n"
                i = i + 1
        if texteDocUnion == "\n":
            self.texteComplexe +=  self.entites[nomMC][0].texteElt
        else:
            texteDocUnion = texteDocUnion[0:-4]
            debutTexteEltUnion = self.entites[nomMC][0].texteElt.split("maxOccurs=")[0]
            self.texteComplexe +=  reconstitueUnion.format( debutTexteEltUnion, texteDocUnion)
        if self.entites[nomMC][0].nomDuTypePyxb in self.typesXSDDejaDumpes: return
        self.typesXSDDejaDumpes.append(self.entites[nomMC][0].nomDuTypePyxb)
        if self.entites[nomMC][0].nomDuTypePyxb=='T_ValueTemplate': debug = True
        if debug:
            print( "et la j ajoute les definitions de type", self.entites[nomMC][0].nomDuTypePyxb,)

        nomTypePyxbUnion = self.entites[nomMC][0].nomDuTypePyxb
        #print (nomTypePyxbUnion)
        texteSimpleUnion = debutSimpleType.format(nomTypePyxbUnion)
        texteSimpleUnion += debutUnion
        texteSimpleUnion += self.entites[nomMC][0].texteSimplePart2
        texteSimplePart1 = self.entites[nomMC][0].texteSimplePart1
        listeTextesDejaLa=[]
        for e in listePourUnion[1:]:
            e.dumpXsd(dansFactorisation=True, multiple=True, first=False)
            # si on ext un mc simple la ligne suivante est inutile
            # en revanche on ajoute le texte a tous les coups
            # self.texteComplexeVenantDesFils += e.texteComplexe
            e.metAJourPyxb(nomTypePyxbUnion)
            if (e.texteSimplePart1 + e.texteSimplePart2).replace('\t','').replace(' ','') not in listeTextesDejaLa :
                a=(e.texteSimplePart1 + e.texteSimplePart2).replace('\t','').replace(' ','')
                if (a  in listeTextesDejaLa)  and self.nom == 'AnalysisPrinter_AnalysisSeriePrinterAndSaver':
                   print ('uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu')
                   print (a)
                   print (listeTextesDejaLa)
                   print ('uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu')
                listeTextesDejaLa.append((e.texteSimplePart1 + e.texteSimplePart2).replace('\t','').replace(' ',''))
                texteSimpleUnion +=  e.texteSimplePart2
                texteSimplePart1 += e.texteSimplePart1
        texteSimpleUnion += finUnion
        texteSimpleUnion += fermeSimpleType
        self.texteSimple += texteSimplePart1 + texteSimpleUnion
        # if debug :
        #   print ('______________')
        #   print (self.texteSimple)
        #   print ('______________')

    def fusionneDsUnChoix(self, nomMC,  debug=False):
        if debug:
            print("______fusionneDsUnChoix ", self.nom, self, nomMC)
        if debug:
            print(self.texteComplexe)
        texteDocUnion = "\n"
        texteComplexe = ""
        texteComplexeVenantDesFils = ""
        texteSimple = ""
        mcRef = self.entites[nomMC][0]
        # max = 1 : a priori les choix sont exclusifs
        if hasattr(mcRef, "aDejaEteDumpe"):
            self.texteComplexe +=  mcRef.texteElt
            if debug:
                print(
                    "je passe la NORMALEMENT car j ai deja ete dumpe, j ajoute juste l elt"
                )
            return
        leNomDuTypePyxb = mcRef.definitNomDuTypePyxb(forceACreer=True)
        if debug:
            print("nomMC", nomMC)
        i = 0

        cata = CONTEXT.getCurrentCata()
        for mc in self.entites[nomMC]:
            if debug:
                print("------------", mc)
            # on laisse dansFactorisation a False car ce n est pas comme une fusion de bloc
            mc.texteComplexe = ""
            mc.texteSimple = ""
            mc.texteElt = ""
            mc.dumpXsd(dansFactorisationDeFusion=True)
            mc.nomDuTypePyxb = leNomDuTypePyxb
            if debug:
                print("texteSimple\n", mc.texteSimple, "\n fin\n")
            if debug:
                print(
                    "texteComplexeVenantDesFils\n",
                    mc.texteComplexeVenantDesFils,
                    "\n fin\n",
                )
            if debug:
                print("texteComplexe\n", mc.texteComplexe, "\n fin\n")
            if mc.ang != "":
                texteDocUnion += str(i) + "- " + mc.ang + " or \n"
                i = i + 1
            elif mc.fr != "":
                texteDocUnion += str(i) + "- " + mc.fr + " ou \n"
                i = i + 1
            texteComplexe += mc.texteComplexe
            texteComplexeVenantDesFils += mc.texteComplexeVenantDesFils
            texteSimple += mc.texteSimple

        if debug:
            print("______________________________")
        if debug:
            print("textecomplexeVenantDesFils : \n", texteComplexeVenantDesFils)
        if debug:
            print("______________________________")
        if debug:
            print("______________________________")
        if debug:
            print("textecomplexe : \n", texteComplexe)
        if debug:
            print("______________________________")
        self.entites[nomMC][0].aDejaEteDumpe = True

        self.texteElt = eltCompoDsSequence.format(
            nomMC, self.nomDuCodeDumpe, mcRef.nomDuTypePyxb, 1, 1
        )
        self.texteDuFact = debutTypeCompo.format(self.entites[nomMC][0].nomDuTypePyxb)
        self.texteDuFact += debutChoiceDsBloc
        self.texteDuFact += texteComplexe
        self.texteDuFact += finChoiceDsBloc
        self.texteDuFact += finTypeCompo
        self.texteSimple += texteSimple
        self.texteComplexeVenantDesFils += texteComplexeVenantDesFils
        self.texteComplexeVenantDesFils += self.texteDuFact
        self.texteComplexe += self.texteElt
        if debug:
            print("______________________________")
        if debug:
            print("texteSimple : \n", self.texteSimple)
        if debug:
            print("______________________________")
        self.entites[nomMC][0].aDejaEteDumpe = True

    def fusionneDesMatricesDeMemeType(
        self, nomMC, nbColsMin, nbColsMax, nbLigsMin, nbLigsMax, debug=False
    ):
        if debug:
            print(
                "fusionneDesMatricesDeMemeType",
                nomMC,
                nbColsMin,
                nbColsMax,
                nbLigsMin,
                nbLigsMax,
            )
        elt = self.entites[nomMC][0]
        typeDeMatrice = elt.type[0]
        elt.dumpXsd(dansFactorisation=True)
        if debug:
            # print ('fusionneDesMatricesDeMemeType self.texteSimple avant', self.texteSimple)
            print(
                "fusionneDesMatricesDeMemeType self.texteComplexe avant",
                self.texteComplexe,
            )
        # if
        self.texteSimple += debutSimpleType.format(elt.nomDuTypePyxb + "_element")
        self.texteSimple += debutRestrictionBase.format(elt.nomDuTypeDeBase)
        if typeDeMatrice.typEltInto != None:
            for val in typeDeMatrice.typEltInto:
                self.texteSimple += enumeration.format(val)
        self.texteSimple += fermeRestrictionBase
        self.texteSimple += fermeSimpleType
        nom = elt.nomDuTypePyxb
        self.texteSimple += matriceSimpleType.format(
            nom,
            nom,
            nbColsMin,
            nbColsMax,
            nom,
            self.code,
            nom,
            nbLigsMin,
            nbLigsMax,
            nom,
            self.code,
            nom,
            1,
            1,
        )
        self.texteComplexe += eltMatrice.format(nomMC, self.code, nom, 0, 1)
        if debug:
            print("fusionneDesMatricesDeMemeType, self.texteSimple ", self.texteSimple)
        if debug:
            print(
                "fusionneDesMatricesDeMemeType self.texteComplexe", self.texteComplexe
            )
        if debug:
            print("------------------------------------------ ")

    def fusionneDesMatrices(self, nomMC):
        # print ('______fusionneDesMatrices ', nomMC, ' dans : ', self)
        # print ('Pas d union des types complexes')
        # if debug : print (self.texteComplexe)
        # self.texteComplexe = debutTypeSubstDsBlocFactorise.format(self.nomDuTypePyxb)
        self.texteComplexe += debutChoiceDsBloc
        for mc in self.entites[nomMC]:
            mc.dumpXsd()
            self.texteComplexe += mc.texteElt
            self.texteSimple += mc.texteSimple
            mc.aDejaEteDumpe = True
        self.texteComplexe += finChoiceDsBloc


# ----------------------------------------
class X_definitionComposee(X_definition):
# ------------------------------------------

    def creeTexteComplexeVenantDesFils(self, dansFactorisation=False, debug=False):
        texteComplexeVenantDesFils = ""
        blocsDejaDumpes = set()
        # for nom in self.ordreMC:
        #  mcFils = self.entites[nom]
        if debug:
            print("___________________ creeTexteComplexeVenantDesFils", self.nom)
        for mcFils in self.mcXSD:
            if debug:
                print(mcFils, mcFils.nom)
            else:
                debug = False
            if not (isinstance(mcFils, Accas.BLOC)):
                mcFils.dumpXsd(dansFactorisation=False)
                self.texteComplexe += mcFils.texteElt
                if mcFils.aCreer:
                    self.texteSimple += mcFils.texteSimple
                if mcFils.aCreer:
                    texteComplexeVenantDesFils += mcFils.texteComplexe
            else:
                if (
                    hasattr(mcFils, "nomXSD")
                    and mcFils.nomXSD in blocsDejaDumpes
                    and mcFils.nomXSD != None
                ):
                    continue
                if hasattr(mcFils, "nomXSD") and mcFils.nomXSD != None:
                    blocsDejaDumpes.add(mcFils.nomXSD)
                mcFils.dumpXsd(dansFactorisation=False)
                self.texteComplexe += mcFils.texteElt
                if mcFils.aCreer:
                    self.texteSimple += mcFils.texteSimple
                if mcFils.aCreer:
                    texteComplexeVenantDesFils += mcFils.texteComplexe
        return texteComplexeVenantDesFils

    def dumpXsd(
        self,
        dansFactorisation=False,
        dansFactorisationDeFusion=False,
        multiple=False,
        first=True,
        debug=False,
        withAbstractElt=True,
    ):
        self.fr=""
        self.ang=""
        # PNPN
        if debug:
            print(
                "dumpXsd pour",
                self.nom,
                dansFactorisation,
                dansFactorisationDeFusion,
                multiple,
                first,
            )
        if PourTraduction:
            print(self.nom)
        # le prepareDump est appele sur les fils
        if not (self.dejaPrepareDump):
            self.prepareDumpXSD()

        self.getNomDuCodeDumpe()
        if first:
            if multiple:
                self.nomDuTypePyxb = self.definitNomDuTypePyxb(forceACreer=True)
            else:
                self.nomDuTypePyxb = self.definitNomDuTypePyxb()
        if debug:
            print("dumpXsd pour", self.nom, self.aCreer)
        self.texteSimple = ""  # on n ajoute pas de type simple

        self.traduitMinMax()
        if dansFactorisation:
            self.minOccurs = 1
        # pour accepter les PROC et ...
        #
        if debug:
            print("dumpXsd apres traduitMinMax, aCreer", self.nom, self.aCreer)
        # if self.nom == 'Result' : print ('je suis dans dumpXsd et ', dansFactorisationDeFusion)
        if self.aCreer or dansFactorisationDeFusion:
            if not dansFactorisationDeFusion:
                self.texteComplexe = debutTypeCompo.format(self.nomDuTypePyxb)
            if (
                isinstance(self, X_OPER) or isinstance(self, X_PROC)
            ) and withAbstractElt:
                self.texteComplexe += debutTypeCompoEtape.format(self.code)
            self.texteComplexe += debutTypeCompoSeq
            texteComplexeVenantDesFils = self.creeTexteComplexeVenantDesFils(
                dansFactorisation
            )
            if not dansFactorisationDeFusion:
                self.texteComplexe = texteComplexeVenantDesFils + self.texteComplexe
                self.texteComplexeVenantDesFils = ""
            else:
                self.texteComplexeVenantDesFils = texteComplexeVenantDesFils
            # la fin de l oper est traitee dans le dumpXSD de X_OPER
            if not isinstance(self, X_OPER):
                self.texteComplexe += finTypeCompoSeq
            if isinstance(self, X_PROC) and withAbstractElt:
                self.texteComplexe += finTypeCompoEtape
            if not isinstance(self, X_OPER) and not dansFactorisationDeFusion:
                self.texteComplexe += finTypeCompo
        else:
            self.texteComplexe = ""

        if self.ang != "":
            self.texteElt = eltCompoDsSequenceWithHelp.format(
                self.nom,
                self.nomDuCodeDumpe,
                self.nomDuTypePyxb,
                self.minOccurs,
                self.maxOccurs,
                self.ang,
            )
        elif self.fr != "":
            self.texteElt = eltCompoDsSequenceWithHelp.format(
                self.nom,
                self.nomDuCodeDumpe,
                self.nomDuTypePyxb,
                self.minOccurs,
                self.maxOccurs,
                self.fr,
            )
        else:
            self.texteElt = eltCompoDsSequence.format(
                self.nom,
                self.nomDuCodeDumpe,
                self.nomDuTypePyxb,
                self.minOccurs,
                self.maxOccurs,
            )
        if debug:
            print("------------------------------------------------", self.nom)
        if debug:
            print("self.texteComplexe", self.texteComplexe)

    def traduitMinMax(self):
        # ______________________
        # valable pour PROC et OPER
        # Attention maxOccurs = unBounded si il y a une seule commande dans le cata
        # Pas pris en compte ici
        self.minOccurs = 0
        self.maxOccurs = 1

    def compare(self, autreMC):
        if self.label != autreMC.label:
            return False
        #if self.nom == 'ValueTemplate' : return True
        if ( hasattr(self, "nomXSD")
            and hasattr(autreMC, "nomXSD")
            and self.nomXSD == autreMC.nomXSD
            and self.nomXSD != None):
            return True
        for attr in ("regles", "fr", "defaut", "min", "max", "position", "docu"):
            try: val1 = getattr(self, attr)
            except: val1 = None
            try: val2 = getattr(autreMC, attr)
            except: val2 = None
            if val1 != val2: return False
        if len(self.entites) != len(autreMC.entites):
            return False
        for defFille in self.entites.keys():
            if defFille not in autreMC.entites.keys():
                return False
            if not self.entites[defFille].compare(autreMC.entites[defFille]):
                return False
        return True

    def prepareDumpXSD(self):
        self.dejaPrepareDump = True
        self.inUnion = False
        self.tousLesFils = []
        self.mcXSD = []
        for nomMC in self.ordreMC:
            mc = self.entites[nomMC]
            self.mcXSD.append(mc)
            mc.prepareDumpXSD()
        self.chercheListesDesBlocsNonDisjoints()
        for l in list(self.listeDesBlocsNonDisjoints):
            if not (self.besoinDeFactoriserTrivial(l)):
                self.listeDesBlocsNonDisjoints.remove(l)
            else:
                self.possedeDejaUnMCFactorise = 1
                self.factorise(l)

    def chercheListesDesBlocsNonDisjoints(self):
        self.listeDesBlocsNonDisjoints = []
        for nomChild in self.ordreMC:
            child = self.entites[nomChild]
            if child.label != "BLOC": continue
            if self.listeDesBlocsNonDisjoints == []:
                self.listeDesBlocsNonDisjoints.append([child])
                continue
            vraimentIndependant = True
            for liste in list(self.listeDesBlocsNonDisjoints):
                independant = True
                for bloc in liste:
                    if bloc.isDisjoint(child): continue
                    if bloc.estLeMemeQue(child): continue
                    independant = False
                    vraimentIndependant = False
                if not (independant):
                    liste.append(child)
            if vraimentIndependant:
                self.listeDesBlocsNonDisjoints.append([child])
        # on nettoye la liste des blocs tous seuls
        for l in list(self.listeDesBlocsNonDisjoints):
            if len(l) == 1:
                self.listeDesBlocsNonDisjoints.remove(l)


    def estLeMemeQue(self, autreMC):
        if (
            hasattr(self, "nomXSD")
            and hasattr(autreMC, "nomXSD")
            and self.nomXSD == autreMC.nomXSD
            and self.nomXSD != None
        ):
            return True
        return False

    def aUnPremierCommunDansLesPossibles(self, laListe):
        # fonctionne avec liste de mc ou une liste(mc,index)
        import types

        mesPremiers = set()
        for elt, index in laListe:
            if not type(e) == types.ListType:
                if elt.nom in mesPremiers:
                    return True
                mesPremiers.add(elt.nom)
            else:
                if elt[0].nom in mesPremiers:
                    return True
                mesPremiers.add(elt[0].nom)
        return False

    def besoinDeFactoriserTrivial(self, laListe):
        # tout faux
        # a revoir
        return True
        besoin = False
        lesPremiers = set()
        for mcBloc in laListe:
            mc = mcBloc.mcXSD[0]
            if mc.label == "BLOC":
                return True
            if not (mc.statut == "o"):
                return True
            if mc.nom in lesPremiers:
                return True
            lesPremiers.add(mc.nom)
        return False

    def factorise(self, liste, debug=False):
        self.listeConstruction = liste
        nomDebut = liste[0].nom
        indexDebut = self.mcXSD.index(liste[0])
        nomFin = liste[-1].nom
        indexFin = self.mcXSD.index(liste[-1]) + 1
        nom = nomDebut + "_" + nomFin
        if debug: print("___________ dans factorise", nom)
        listeAFactoriser = []
        for i in range(indexDebut, indexFin):
            listeAFactoriser.append(self.mcXSD[i])
        newListe = self.mcXSD[0:indexDebut]
        if debug : 
            print ('uuuuuuuuuuuuuuuuuuuuu')
            print ('new liste ', newListe) 
            print ('listeAFactoriser',listeAFactoriser) 
            if len(listeAFactoriser) >=1 : 
               print ( listeAFactoriser[0].nom)
               print ( listeAFactoriser[0])
               print ( listeAFactoriser[0].typeXSD )
        if len(listeAFactoriser) >=1 : typeXSD = listeAFactoriser[0].typeXSD
        else : typeXSD = None
        monEltFacteur = X_compoFactoriseAmbigu(nom, listeAFactoriser, self, typeXSD=typeXSD)
        newListe.append(monEltFacteur)
        newListe = newListe + self.mcXSD[indexFin:]
        self.mcXSD = newListe
        if debug:
            print("___________ fin fin factorise", nom)

    def construitTousLesFils(self):
        for nomChild in self.ordreMC:
            if nomChild == "Consigne" or nomChild == "blocConsigne": continue
            child = self.entites[nomChild]
            if child.label != "BLOC":
                self.tousLesFils.append(child.nom)
            else:
                if child.tousLesFils == []:
                    child.construitTousLesFils()
                for nomPetitFils in child.tousLesFils:
                    self.tousLesFils.append(nomPetitFils)
        #print ('construitTousLesFils pour ', self.nom, self.tousLesFils)

    def isDisjoint(self, mc1):
        if self.tousLesFils == []:
            self.construitTousLesFils()
        if not (hasattr(mc1, "tousLesFils")):
            mc1.tousLesFils = []
        if mc1.tousLesFils == []:
            mc1.construitTousLesFils()
        for fils in mc1.tousLesFils:
            if fils in self.tousLesFils:
                return False
        return True


# ---------------------------------
class X_FACT(X_definitionComposee):
# --------- ------------------------
    # Un FACT avec max=** doit se projeter en XSD sous forme d'une sequence a cardinalite 1 et
    # l'element qui porte la repetition du FACT
    def traduitMinMax(self, maxOccurs=None):
        if self.max == "**" or self.max == float("inf"):
            self.maxOccurs = "unbounded"
        else:
            self.maxOccurs = self.max
        self.minOccurs = self.min
        if self.statut == "f":
            self.minOccurs = 0
        if self.statut == "o" and self.min < 2:
            self.minOccurs = 1

    def construitArbrePossibles(self):
        if self.statut == "f":
            self.arbrePossibles = (self.nom, [])
            self.arbreMCPossibles = (self, None)
        else:
            self.arbrePossibles = (self.nom,)
            self.arbreMCPossibles = (self,)
        # print ('XFACT arbre des possibles de ' ,self.nom, self.arbrePossibles)


# ---------------------------------
class X_OPER(X_definitionComposee):
# ---------------------------------
    def dumpXsd(
        self, dansFactorisation=False, multiple=False, first=False, withAbstractElt=True
    ):
        self.fr=""
        self.ang=""
        X_definitionComposee.dumpXsd(
            self, dansFactorisation, withAbstractElt=withAbstractElt
        )
        self.texteComplexe += finTypeCompoSeq
        self.texteComplexe += attributeNameName
        self.texteComplexe += attributeTypeForASSD
        self.texteComplexe += attributeTypeUtilisateurName.format(self.sd_prod.__name__)
        if withAbstractElt:
            self.texteComplexe += finTypeCompoEtape
        self.texteComplexe += finTypeCompo

        cata = CONTEXT.getCurrentCata()
        if self.sd_prod.__name__ not in list(cata.dictTypesASSDorUserASSDCrees):
            cata.dictTypesASSDorUserASSDCrees[self.sd_prod.__name__] = [
                self,
            ]
        else:
            cata.dictTypesASSDorUserASSDCrees[self.sd_prod.__name__].append(self)


# ----------------------------------
class X_PROC(X_definitionComposee):
# -----------------------------------
    pass


# -----------------------------------
class X_BLOC(X_definitionComposee):
# -----------------------------------
    def dumpXsd( self, dansFactorisation=False, multiple=False, first=False, debug=False):
        self.fr=""
        self.ang=""
        if debug: print("X_BLOC dumpXsd", self.nom)
        self.tousLesFils = []
        if self.nom == "blocConsigne":
            self.texteComplexe = ""
            self.texteSimple = ""
            self.nomDuTypePyxb = "NonTraiteConsigne"
            self.aCreer = False
            self.texteElt = ""
            return
        self.getNomDuCodeDumpe()

        # dans ce cas les blocs successifs sont identiques et on ne dumpe que le 1er
        self.nomDuTypePyxb = self.definitNomDuTypePyxb()
        self.texteSimple = ""  # on n ajoute pas de type simple

        # Pour les blocs le minOccurs vaut 0 et le max 1
        if self.aCreer:
            self.texteComplexe = debutTypeSubst.format(self.nomDuTypePyxb)
            texteComplexeVenantDesFils = self.creeTexteComplexeVenantDesFils(
                dansFactorisation
            )
            self.texteComplexe = texteComplexeVenantDesFils + self.texteComplexe
            self.texteComplexe += finTypeSubst

        else:
            self.texteComplexe = ""

        texteCondition = "\n  condition : " + self.condition + '\n'
        if texteCondition.find ('>') > 0: 
            texteCondition=texteCondition.replace ('>', 'superieur')
        if texteCondition.find ('<') > 0: 
            texteCondition=texteCondition.replace ('<', 'inferieur')
        self.texteElt = substDsSequence.format(self.code, self.nomDuTypePyxb, 0, 1, texteCondition)
        # print ('------------------------------------------------')

    def compare(self, autreMC):
        if self.label != autreMC.label: return False
        if self.inUnion == True or autreMC.inUnion == True: return False
        if (
            hasattr(self, "nomXSD")
            and hasattr(autreMC, "nomXSD")
            and self.nomXSD == autreMC.nomXSD
            and self.nomXSD != None
        ):
            return True
        for attr in ( "condition", "regles",):
            val1 = getattr(self, attr)
            val2 = getattr(autreMC, attr)
            if val1 != val2:
                return False
        if len(self.entites) != len(autreMC.entites):
            return False
        for defFille in self.entites.keys():
            if defFille not in autreMC.entites.keys():
                return False
            if not self.entites[defFille].compare(autreMC.entites[defFille]):
                return False
        return True

    def construitArbrePossibles(self):
        self.arbrePossibles = [
            [],
        ]
        # print ('X_BLOC je construis l arbre des possibles pour ', self.nom)
        for child in self.mcXSD:
            if not hasattr(child, "arbrePossibles"):
                child.construitArbrePossibles()
            # print (child.nom, child.label, child.arbrePossibles)
            if child.label == "BLOC":
                self.arbrePossibles = deepcopy(
                    self.remplaceListeParContenuEtVide(
                        self.arbrePossibles, child.arbrePossibles
                    )
                )
            elif child.label == "BlocAmbigu":
                # print ("je passe par la pour", self.nom, child.nom, self.arbrePossibles, child.arbrePossibles)
                self.arbrePossibles = deepcopy(
                    self.remplaceListeParContenuEtVide(
                        self.arbrePossibles, child.arbrePossibles
                    )
                )
                # print ('resultat', self.arbrePossibles)
            else:
                self.arbrePossibles = deepcopy(
                    self.adjoint(self.arbrePossibles, child.arbrePossibles)
                )
        self.arbrePossibles.append([])  # un bloc n est pas obligatoire
        # print ('arbre des possibles de ' ,self.nom, self.arbrePossibles)


# --------------------------------
class X_SIMP(X_definition):
# --------------------------------
    def dumpXsd( self, dansFactorisation=False, multiple=False, first=False, debug=False):
        self.fr=""
        self.ang=""
        # if PourTraduction  : print (self.nom)
        if self.nom == 'malloc' : debug = True
        if debug:
            print( "X_SIMP dumpXsd pour", self.nom, dansFactorisation, "___________________________",)
        #debug = False
        self.prepareDumpXSD()
        # si inUnion la comparaison est fausse : on cree le nomDuType
        if multiple: self.inUnion = True
        # print ('exploreObjet SIMP')
        self.getNomDuCodeDumpe()
        self.aCreer = True
        self.texteComplexe = ""
        self.texteSimple = ""
        self.texteElt = ""
        if self.nom == "Consigne":
            return

        #  --> homonymie on peut utiliser genealogie ?
        self.nomDuTypeDeBase = self.traduitType()
        if debug: print("nomDuTypeDeBase", self.nomDuTypeDeBase)
        if debug: print("multiple", multiple, "first", first)
        if not multiple:
            self.nomDuTypePyxb = self.definitNomDuTypePyxb()
        else:
            if first:
                # on force la creation
                self.nomDuTypePyxb = self.definitNomDuTypePyxb()
                self.aCreer = True
            else:
                self.nomDuTypePyxb = "NonDetermine"

        # if self.nom == 'A' : debug = False
        if debug: print("nomDuTypePyxb", self.nomDuTypePyxb)
        if debug: print("---------------------------- aCreer", self.aCreer)
        debug = False

        # on se sert des listes ou non pour  la gestion des minOccurs /maxOccurs est > 0
        if self.statut == "f": minOccurs = 0
        else: minOccurs = 1
        if dansFactorisation: minOccurs = 1

        if self.suisUneMatrice:
            if dansFactorisation: return
            self.dumpSpecifiqueMatrice(minOccurs)
            return

        if self.suisUnTuple:
            self.dumpSpecifiqueTuple(minOccurs)
            return

        if self.avecBlancs and self.max > 1:
            self.dumpSpecifiqueTexteAvecBlancs(minOccurs, multiple)
            return

        # print ('minOccurs',minOccurs)
        # le defaut est dans l elt Name -> tester la coherence d existence avec Accas
        # regles Accas

        # pas d elt si on est dans multiple
        # sauf si on est le '1er'  dans un element ambigu
        if not multiple:
            if debug:
                print("je passe la pas multiple")
            texteAide = ""
            if self.ang != "":
                texteAide = self.ang
            else:
                texteAide = self.fr
            if self.intoXSD and self.into:
                if self.intoXSD != self.into:
                    # print ('je passe la pour ', self.nom)
                    texteAide = (
                        texteAide
                        + "\nPossible choices for "
                        + self.nom
                        + "at this place : \n"
                        + str(self.into)
                        + "\n"
                    )

            if self.defaut:
                if debug: print("j ai un defaut")
                if self.max > 1 or self.max == "**" or self.max == float("inf"):
                    txtDefaut = ""
                    for val in self.defaut:
                        txtDefaut += str(val) + " "
                    # cela ne fonctionne pas tres bien. a revoir
                    txtDefaut = txtDefaut[0:-1]
                    if not ("TXM" in (self.type)):
                        # a revoir pour les tuples avec defaut
                        if texteAide != "": self.texteElt = eltDsSequenceWithDefautAndHelp.format( self.nom, self.code,
                                self.nomDuTypePyxb, minOccurs, 1, txtDefaut, texteAide,)
                        else:
                            self.texteElt = eltDsSequenceWithDefaut.format( self.nom, self.code, self.nomDuTypePyxb,
                                minOccurs, 1, txtDefaut,)
                    else:
                        texteAide += ( texteAide + "\ndefault Value in MDM : \n" + txtDefaut)
                        self.texteElt = eltDsSequenceWithHelp.format( self.nom, self.code, self.nomDuTypePyxb,
                            minOccurs, 1, texteAide,) 
                else:
                    if str(self.defaut) == "True": txtDefaut = "true"
                    elif str(self.defaut) == "False": txtDefaut = "false"
                    else: txtDefaut = str(self.defaut)
                    if txtDefaut.find('"') >=0 :
                       txtDefaut=self.defaut
                       print ('Attention  :' , txtDefaut, 'chgmt des "')
                       txtDefaut = txtDefaut.replace('"',"'")
                    if texteAide != "":
                        self.texteElt = eltDsSequenceWithDefautAndHelp.format( self.nom, self.code,
                            self.nomDuTypePyxb, minOccurs, 1, txtDefaut, texteAide,)
                    else:
                        self.texteElt = eltDsSequenceWithDefaut.format( self.nom, self.code,
                            self.nomDuTypePyxb, minOccurs, 1, txtDefaut,)
            else:
                if texteAide != "":
                    self.texteElt = eltDsSequenceWithHelp.format(
                        self.nom, self.code, self.nomDuTypePyxb, minOccurs, 1, texteAide)
                else:
                    self.texteElt = eltDsSequence.format(
                        self.nom, self.code, self.nomDuTypePyxb, minOccurs, 1)
        elif first:
            # l'aide est geree a la fusion
            self.texteElt = eltDsSequence.format( self.nom, self.code, self.nomDuTypePyxb, 1, 1)

        # self.aCreer est mis a jour ds definitNomDuTypePyxb
        # ou si elt est le 1er d une liste identique
        if debug:
            print("je suis aCreer", self.aCreer)
        if not self.aCreer:
            return

        typeATraduire = self.type[0]

        self.texteSimplePart1 = ""
        if (
            not (isinstance(typeATraduire, str))
            and not (isinstance(typeATraduire, Accas.Tuple))
            and issubclass(typeATraduire, Accas.UserASSD)
        ):
            cata = CONTEXT.getCurrentCata()
            if len(self.type) == 2 and self.type[1] == "createObject":
                suffixe = "C"
            else:
                suffixe = "U"
            # print (cata.listeUserASSDDumpes)
            # print (typeATraduire.__name__)
            # print (typeATraduire.__name__ in cata.listeUserASSDDumpes)
            if typeATraduire.__name__ not in cata.listeUserASSDDumpes:
                cata.listeUserASSDDumpes.add(typeATraduire.__name__)
                if issubclass(typeATraduire, Accas.UserASSDMultiple):
                    self.texteSimplePart1 = defUserASSDMultiple.format( typeATraduire.__name__)
                    if cata.definitUserASSDMultiple == False:
                        cata.definitUserASSDMultiple = True
                        cata.texteSimple = cata.texteSimple + defBaseXSDUserASSDMultiple
                else:
                    self.texteSimplePart1 = defUserASSD.format(typeATraduire.__name__)
                    if cata.definitUserASSD == False:
                        cata.definitUserASSD = True
                        cata.texteSimple = cata.texteSimple + defBaseXSDUserASSD
            if typeATraduire.__name__ + "_" + suffixe not in cata.listeUserASSDDumpes:
                cata.texteSimple = (
                    cata.texteSimple
                    + defUserASSDOrUserASSDMultiple.format(
                        typeATraduire.__name__, suffixe, typeATraduire.__name__
                    )
                )
                cata.listeUserASSDDumpes.add(typeATraduire.__name__ + "_" + suffixe)

        if not multiple:
            self.texteSimple += debutSimpleType.format(self.nomDuTypePyxb)
        else:
            self.texteSimple += debutSimpleTypeSsNom
        # gestion des elements constants
        if self.homo == "constant":
            if type(self.defaut) in ("tuple", "list"):
                self.intoConstant = self.defaut
            else:
                if self.defaut != None:
                    self.intoConstant = [
                        self.defaut,
                    ]
                else:
                    self.intoConstant = None
        else:
            self.intoConstant = None
        # On est dans une liste
        if ( self.max > 1 or self.max == "**"
            or self.max == float("inf") or hasattr(self.type[0], "ntuple")):
            self.texteSimple += debutTypeSimpleListe
            self.texteSimple += debutRestrictionBase.format(self.nomDuTypeDeBase)
            if self.val_min != float("-inf"):
                self.texteSimple +=  minInclusiveBorne.format(self.val_min)
            if self.val_max != float("inf") and self.val_max != "**":
                self.texteSimple +=  maxInclusiveBorne.format(self.val_max)
            if self.into != None or self.intoConstant != None:
                # PN --> traduction des into
                into = self.into
                if self.intoConstant != None:
                    into = self.intoConstant
                if self.intoXSD != None:
                    into = self.intoXSD
                for val in into:
                    self.texteSimple +=  enumeration.format(val)
                if PourTraduction:
                    for val in into:
                        print(str(val))
            self.texteSimple += fermeBalisesMileu
            if self.max != 1 and self.max != "**" and self.max != float("inf"):
                self.texteSimple += maxLengthTypeSimple.format(self.max)
            if self.min != 1 and self.min != float("-inf"):
                self.texteSimple += minLengthTypeSimple.format(self.min)
            self.texteSimple += fermeRestrictionBase
        else:
            # ou pas
            self.texteSimple += debutRestrictionBase.format(self.nomDuTypeDeBase)
            if self.val_min != float("-inf"):
                self.texteSimple += minInclusiveBorne.format(self.val_min)
            if self.val_max != float("inf") and self.val_max != "**":
                self.texteSimple += maxInclusiveBorne.format(self.val_max)
            if self.into != None or self.intoConstant != None:
                # Pour ModelVariable et ObjectName de UQ
                # et autre mot clef ou le into est calcule
                if self.into != [] and type(self.into) != types.FunctionType:
                    into = self.into
                    if self.intoConstant != None:
                        into = self.intoConstant
                    if self.intoXSD != None:
                        into = self.intoXSD
                    for val in into:
                        self.texteSimple += enumeration.format(val)
                    if PourTraduction:
                        for val in into:
                            print(str(val))
            self.texteSimple += fermeRestrictionBase
        self.texteSimple += fermeSimpleType
        self.texteSimplePart2 = self.texteSimple
        self.texteSimple = self.texteSimplePart1 + self.texteSimplePart2
        if debug :  print (self.nomDuTypePyxb, self.unite)
        if self.unite != None:
            cata = CONTEXT.getCurrentCata()
            if cata.unitAsAttribute:
                self.texteSimple = self.texteSimple.replace(
                    self.nomDuTypePyxb, self.nomDuTypePyxb + "_NoUnit"
                )
                nouveauTexte = self.texteSimple
                nouveauTexte += typeAvecAttributUnite.format(
                    self.nomDuTypePyxb,
                    self.code,
                    self.nomDuTypePyxb,
                    self.nomDuTypePyxb,
                    self.unite,
                )
                cata.listeTypeWithUnit.append(self.nomDuTypePyxb)
                self.texteSimple = nouveauTexte
                if debug:
                    print(self.texteSimple)

    def dumpSpecifiqueTexteAvecBlancs(self, minOccurs, multiple):
        self.fr=""
        self.ang=""
        # attention multiple non traite
        # pour l instant on n a pas max =1 et on ne traite pas les into

        texteAide = ""
        if self.ang != "":
            texteAide = self.ang
        elif self.fr != "":
            texteAide = self.fr

        self.texteElt = eltDsSequenceWithHelp.format(
            self.nom, self.code, self.nomDuTypePyxb, minOccurs, 1, texteAide
        )
        txtDefaut = ""
        # Pas de Defaut pour les string en XSD
        # max sert pour la taille de la liste
        if self.defaut:
            texteAide += " Valeur par defaut dans le comm : " + str(self.defaut)
        if texteAide != "":
            self.texteElt = eltDsSequenceWithHelp.format(
                self.nom, self.code, self.nomDuTypePyxb, minOccurs, 1, texteAide
            )
        else:
            self.texteElt = eltDsSequence.format(
                self.nom, self.code, self.nomDuTypePyxb, minOccurs, 1
            )

        if self.max == "**" or self.max == float("inf"):
            max = "unbounded"
        else:
            max = self.max

        if self.max > 1:  # juste au cas ou on traite 1 pareil
            self.texteSimple = ""
            cata = CONTEXT.getCurrentCata()
            if self.nomDuTypePyxb in cata.listeTypeTXMAvecBlancs:
                return
            cata.listeTypeTXMAvecBlancs.add(self.nomDuTypePyxb)
            self.texteSimple = complexChaineAvecBlancs.format(
                self.nomDuTypePyxb, max, self.nomDuTypePyxb
            )
            if self.intoXSD != None:
                into = self.intoXSD
            else:
                into = self.into
            if into == None:
                self.texteSimple += typeEltChaineAvecBlancSansInto.format(
                    self.nomDuTypePyxb
                )
            else:
                self.texteSimple += debutChaineAvecBlancsInto.format(self.nomDuTypePyxb)
                for val in into:
                    self.texteSimple += milieuChaineAvecBlancsInto.format(val)
                self.texteSimple += finChaineAvecBlancsInto

    def dumpSpecifiqueTuple(self, minOccurs):
        self.fr=""
        self.ang=""
        self.nomDuTypeDeBase = self.traduitType()
        tousPareil = True
        # il faut gerer l aide et les defaut
        if self.defaut:
            print("il faut tester le defaut")
        if self.max == "**" or self.max == float("inf"):
            max = "unbounded"
        else:
            max = self.max
        self.texteElt = tupleNonHomogeneElt.format(
            self.nom, self.code, self.nomDuTypePyxb, minOccurs, max
        )
        leType = self.nomDuTypeDeBase[0]
        for leTypeComp in self.nomDuTypeDeBase[1:]:
            if leTypeComp != leType:
                tousPareil = False
                break
        # if tousPareil :
        # PN PN a statuer
        #    self.texteSimple  += debutSimpleType.format(self.nomDuTypePyxb)
        #    self.texteSimple  += debutTypeSimpleListe
        #    self.texteSimple  += "\t\t\t\t"+debutRestrictionBase.format(leType)
        #    if self.val_min != float('-inf')  : self.texteSimple += "\t\t\t\t"+minInclusiveBorne.format(self.val_min)
        #    if self.val_max != float('inf') and self.val_max != '**' : self.texteSimple +="\t\t\t\t"+ maxInclusiveBorne.format(self.val_max)
        #    if self.into != None:
        #        into=self.into
        #        if self.intoXSD != None : into = self.intoXSD
        #        for val in into : self.texteSimple += "\t\t\t\t"+enumeration.format(val)
        #        if PourTraduction  :
        #            for val in into : print (str(val))
        #    self.texteSimple  += fermeBalisesMileu
        #    if self.max !=1 and self.max != '**' and self.max !=  float('inf') : self.texteSimple  += maxLengthTypeSimple.format(self.max)
        #    if self.min !=1 and self.min !=  float('-inf') : self.texteSimple  += minLengthTypeSimple.format(self.min)
        #    self.texteSimple  += fermeSimpleType
        #    return

        if self.min == 0:
            sequenceVide = True
        else:
            sequenceVide = False
        self.texteSimple = ""
        complexeTypeTuple = tupleDebutComplexeType.format(self.nomDuTypePyxb)
        num = 1
        for leType in self.nomDuTypeDeBase:
            self.texteSimple += tupleNonHomogeneSimpleType.format(
                self.nomDuTypePyxb, str(num), leType
            )
            complexeTypeTuple += tupleMilieuComplexeType.format(
                str(num), self.nomDuTypePyxb, str(num)
            )
            num = num + 1
        complexeTypeTuple += tupleFinComplexeType
        self.texteSimple += complexeTypeTuple

    def dumpSpecifiqueMatrice(self, minOccurs):
        self.fr=""
        self.ang=""
        # ajouter le AccasAssd
        # if faut traiter le defaut
        typeDeMatrice = self.type[0]

        self.texteSimple += debutSimpleType.format(self.nomDuTypePyxb + "_element")
        self.texteSimple += debutRestrictionBase.format(self.nomDuTypeDeBase)
        if typeDeMatrice.typEltInto != None:
            for val in typeDeMatrice.typEltInto:
                self.texteSimple += enumeration.format(val)
        self.texteSimple += fermeRestrictionBase
        self.texteSimple += fermeSimpleType
        nom = self.nomDuTypePyxb
        nbCols = typeDeMatrice.nbCols
        nbLigs = typeDeMatrice.nbCols
        self.texteSimple += matriceSimpleType.format( nom, nom, nbCols, nbCols, nom, self.code, nom,
            nbLigs, nbLigs, nom, self.code, nom, self.min, self.max,)
        self.texteElt = eltMatrice.format( self.nom, self.code, self.nomDuTypePyxb, minOccurs, 1)

    def prepareDumpXSD(self):
        self.inUnion = False
        if self.statut == "f":
            self.arbrePossibles = (self.nom, [])
        else:
            self.arbrePossibles = (self.nom,)
        self.mcXSD = []

    def traduitType(self, debug=False):
        # il faut traduire le min et le max
        # il faut ajouter les regles
        # il faut gerer les types tuple et fichier
        # on ne paut pas tester le type qui depend du cataloge
        cata = CONTEXT.getCurrentCata()
        #if self.nom == 'malloc' : debug = True
        if hasattr(self.type[0], "typElt"):
            if debug:
                print(self.nom, "est une matrice")
            self.suisUneMatrice = True
            # on presume que le type de l elt est un ASSD si il n est pas un type connu
            if self.type[0].typElt not in dictNomsDesTypes.keys():
                cata.definitUserASSD = True
                return "AccasAssd"
            return dictNomsDesTypes[self.type[0].typElt]
        else:
            self.suisUneMatrice = False
        if hasattr(self.type[0], "ntuple"):
            if debug:
                print(self.nom, "est un tuple")
            self.suisUnTuple = True
            # Pour l instant pas de into dans les tuples non homogenes et pas de reference
            # sinon, il faudra faire un for sur la suite avec les createObjet
            leType = self.validators.typeDesTuples[0]
            enRetour = []
            for i in range(self.type[0].ntuple):
                # Attention, si plusieurs validators on a des soucis
                # a Reprendre
                typeATraduire = self.validators.typeDesTuples[i]
                if not (typeATraduire in list(dictNomsDesTypes.keys())):
                    cata.definitUserASSD = True
                    enRetour.append("AccasAssd")
                else:
                    enRetour.append(dictNomsDesTypes[self.validators.typeDesTuples[i]])
            return enRetour
            # typeATraduire=leType
        else:
            self.suisUnTuple = False
            typeATraduire = self.type[0]
        # Pour les types non encore implementes en Accas comme date
        if hasattr(self, "typeXSD") and self.typeXSD != None:
            if debug : print ('traduit Type retour ---------', self.typeXSD)
            return self.typeXSD
        if not (typeATraduire in list(dictNomsDesTypes.keys())):
            # if (isinstance(typeATraduire, Accas.ASSD) or issubclass(typeATraduire, Accas.ASSD)) :
            if debug:
                print(self.nom, "n est pas un type de base")
            if not (isinstance(typeATraduire, str)) and issubclass( typeATraduire, Accas.ASSD):
                if debug:
                    print(self.nom, "est d un type sous classe de ASSD")
                # cas d une creation
                cata = CONTEXT.getCurrentCata()
                # PNPNPN a Revoir pour la creation des keyrefs
                if len(self.type) == 2 and self.type[1] == "createObject":
                    if typeATraduire.__name__ not in list(
                        cata.dictTypesASSDorUserASSDCrees):
                        cata.dictTypesASSDorUserASSDCrees[typeATraduire.__name__] = [ self, ]
                    else:
                        cata.dictTypesASSDorUserASSDCrees[ typeATraduire.__name__ ].append(self)
                    if issubclass(typeATraduire, Accas.UserASSD):
                        return typeATraduire.__name__ + "_C"
                    if issubclass(typeATraduire, Accas.ASSD):
                        cata.definitUserASSD = True
                        return "AccasAssd"
                    else:
                        return "xs:string"

                # cas d une consommation
                if typeATraduire not in list(cata.dictTypesASSDorUserASSDUtilises):
                    cata.dictTypesASSDorUserASSDUtilises[typeATraduire] = [ self, ]
                else:
                    cata.dictTypesASSDorUserASSDUtilises[typeATraduire].append( self,)
                if issubclass(typeATraduire, Accas.UserASSD):
                    return typeATraduire.__name__ + "_U"
                if issubclass(typeATraduire, Accas.ASSD):
                    cata.definitUserASSD = True
                    return "AccasAssd"
                else:
                    return "xs:string"
            else:
                return "YYYYY"
        return dictNomsDesTypes[typeATraduire]

    def traduitValMinValMax(self):
        self.maxInclusive = self.val_max
        self.minInclusive = self.val_min
        if self.val_min == float("-inf") and val_max == float("inf"):
            return
        # print ('il faut affiner le type du SIMP ', self.nom)
        if self.val_max == "**" or self.val_max == float("inf"):
            self.maxInclusive = None
        else:
            self.maxInclusive = self.val_max
        if self.val_min == "**" or self.val_max == float("-inf"):
            self.maxInclusive = None
        else:
            self.minInclusive = self.val_min

    def traduitMinMax(self):
        if self.min == 1 and self.max == 1:
            return
        # print ('il faut creer une liste ' , self.nom)

    def compare(self, autreMC, debug = False):
        if debug : print (' compare SIMP', self.inUnion)
        if self.label != autreMC.label: return False
        if self.inUnion == True or autreMC.inUnion == True: return False
        if ( hasattr(self, "nomXSD")
            and hasattr(autreMC, "nomXSD")
            and self.nomXSD == autreMC.nomXSD
            and self.nomXSD != None):
            return True
        listeAComparer = ["type", "defaut", "min", "max", "val_min", "val_max"]
        if self.intoXSD != None: listeAComparer.append("intoXSD")
        else: listeAComparer.append("into")

        for attr in listeAComparer:
            val1 = getattr(self, attr)
            val2 = getattr(autreMC, attr)
            if val1 != val2: return False
        return True

    def compareEtFusionneInto(self, autreMC, debug = False):
        if debug : print (' compare et Fusion SIMP', self.nom)
        if self.label != autreMC.label: return False
        if ( hasattr(self, "nomXSD")
            and hasattr(autreMC, "nomXSD")
            and self.nomXSD == autreMC.nomXSD
            and self.nomXSD != None):
            return True
        listeAComparer = ["type", "val_min", "val_max"]
        for attr in listeAComparer:
            if debug : print (attr)
            if debug : print ('__________________')
            val1 = getattr(self, attr)
            val2 = getattr(autreMC, attr)
            if debug : print (val1)
            if debug : print (val2)
            if val1 != val2: return False

        if self.intoXSD == None and autreMC.intoXSD == None : return True
        if self.into == None and autreMC.into == None : return True

        # Si l un des deux n a pas de into on ne peut pas fusionner
        if self.intoXSD != None: 
            if autreMC.intoXSD == None : return False
            for possible in autreMC.intoXSD: 
                if possible not in self.intoXSD : self.intoXSD.append(possible)
        elif self.into != None: 
            if autreMC.into == None : return False
            for possible in autreMC.into: 
               if possible not in self.into : self.into.append(possible)
        if debug : print (self.into)
        return True


    def construitArbrePossibles(self):
        if self.statut == "f":
            self.arbrePossibles = (self.nom, [])
        else:
            self.arbrePossibles = (self.nom,)
        # print ('SIMP arbre des possibles de ' ,self.nom, self.arbrePossibles)


# -----------------
class X_JDC_CATA:
# -----------------

    def dumpXsd(self, withAbstractElt, withUnitAsAttribute , avecSubstitution=True, debug=False):
        self.fr=""
        self.ang=""
        # PN reflechir plus aux lignes suivantes
        CONTEXT.unsetCurrentCata()
        CONTEXT.setCurrentCata(self)
        cata = CONTEXT.getCurrentCata()
        cata=self
        cata.unitAsAttribute = withUnitAsAttribute
        cata.listeTypeWithUnit = [] 
        if debug: print("withAbstractElt   -------------------", withAbstractElt)
        if debug: print("self.importedBy -------------------", self.importedBy)
        if debug: print("self.code       -------------------", self.code)

        self.texteSimple = ""
        self.texteComplexe = ""
        self.texteCata = ""
        self.texteDeclaration = ""
        self.texteInclusion = ""
        self.texteElt = ""
        self.texteTypeAbstrait = ""

        if self.implement == "":
            self.nomDuCodeDumpe = self.code
            self.implement = self.code
            self.nomDuXsdPere = self.code
        else:
            self.implement, self.nomDuXsdPere = self.implement.split(":")
            self.nomDuCodeDumpe = self.implement

        if debug: print("self.implement       -------------------", self.implement)
        if debug: print("self.nomDuCodeDumpe   -------------------", self.nomDuCodeDumpe)
        if debug: print("self.nomDuXsdPere  -------------------", self.nomDuXsdPere)

        self.nomDuTypePyxb = "T_" + self.nomDuCodeDumpe
        if hasattr(self.cata, "dElementsRecursifs"):
            self.listeElementsRecursifs = list(self.cata.dElementsRecursifs.keys())
        else:
            self.listeElementsRecursifs = ()

        if withAbstractElt:
            self.dumpWithAbstractElt()
        else:
            self.dumpSimpleDesCommandes()

        if withAbstractElt:
            if self.implement == self.code:
                self.texteCata += eltAbstraitCataPPal.format(self.code)
                self.texteCata += eltCataPPal.format(self.code, self.code, self.code)
            else:
                self.texteCata += eltAbstraitCataFils.format(
                    self.implement, self.nomDuXsdPere, self.nomDuXsdPere
                )
                self.texteCata += eltCataFils.format(
                    self.implement,
                    self.nomDuXsdPere,
                    self.nomDuXsdPere,
                    self.nomDuXsdPere,
                )
                self.texteInclusion += includeCata.format(self.nomDuXsdPere)

            self.texteCata += eltCata.format(
                self.implement,
                self.implement,
                self.implement,
                self.implement,
                self.nomDuXsdPere,
            )
            if self.implement == self.code:
                self.texteXSD = texteDebut.format(
                    self.code, self.code, self.code, self.code, self.code, self.code
                )
            elif self.nomDuXsdPere == self.code:
                self.texteXSD = texteDebutNiveau2.format(
                    self.code,
                    self.implement,
                    self.code,
                    self.code,
                    self.code,
                    self.code,
                    self.code,
                    self.code,
                    self.code,
                    self.code,
                )
            else:
                self.texteXSD = texteDebutNiveau3.format(
                    self.code,
                    self.implement,
                    self.code,
                    self.nomDuXsdPere,
                    self.code,
                    self.code,
                    self.code,
                    self.code,
                    self.code,
                    self.code,
                    self.code,
                    self.code,
                )

            if self.texteInclusion != "":
                self.texteXSD += self.texteInclusion

        else:
            self.texteXSD = texteDebut.format(
                self.code, self.code, self.code, self.code, self.code, self.code
            )

        if self.definitUserASSD : self.texteXSD += defBaseXSDASSD
        self.texteSimple = self.formate(self.texteSimple)
        self.texteComplexe = self.formate(self.texteComplexe)
        self.texteXSD += self.texteSimple
        self.texteXSD += self.texteComplexe

        # if self.texteTypeAbstrait != "" : self.texteXSD += self.texteTypeAbstrait
        #self.texteCata = self.formate(self.texteCata, debug = True)
        self.texteCata = self.formate(self.texteCata)
        self.texteXSD += self.texteCata

        toutesLesKeys = set()
        texteKeyRef = ""
        # Pour le nom des key_ref en creation : le type ( une seule key-ref par type. facile a retrouver)
        for clef in self.dictTypesASSDorUserASSDCrees:
            existeASSD = 0
            texteDesFields = ""
            for unOper in self.dictTypesASSDorUserASSDCrees[clef]:
                if not (isinstance(unOper, Accas.OPER)):
                    continue
                existeASSD = 1
                texteDesFields += texteFieldUnitaire.format(self.code, unOper.nom)
            if existeASSD:
                texteDesFields = texteDesFields[0:-2]
            texteDesUserASSD = ""
            existeunUserASSD = 0
            for unSimp in self.dictTypesASSDorUserASSDCrees[clef]:
                if not (isinstance(unSimp, Accas.SIMP)):
                    continue
                texteDesUserASSD += unSimp.getXPathSansSelf() + " | "
                # print (unSimp.getXPathSansSelf())
                # texteFieldUnitaire='/'+self.code+":"+unSimp.nom
                existeunUserASSD = 1
            if existeunUserASSD:
                if existeASSD:
                    texteDesFields = (
                        texteDesFields + texteDesUserASSD[0:-2] + "/>\n"
                    )
                else:
                    texteDesFields = texteDesUserASSD[0:-2]
            # print (texteDesUserASSD)
            # print (texteDesFields)
            if texteDesFields != "":
                texteKeyRef += producingASSDkeyRefDeclaration.format(
                    clef, texteDesFields
                )

        # Pour le nom des key-ref en utilisation : la genealogie complete  ( une  key-ref par utilisation et on retrouve facilement la )
        for clef in self.dictTypesASSDorUserASSDUtilises:
            for unSimp in self.dictTypesASSDorUserASSDUtilises[clef]:
                # il faut la genealogie
                texteKeyRef += UsingASSDkeyRefDeclaration.format(
                    unSimp.getNomCompletAvecBloc(),
                    unSimp.type[0].__name__,
                    self.code,
                    unSimp.type[0].__name__,
                    unSimp.getXPathComplet(),
                )

        # PNPN on debranche les keyref le temps de bien reflechir a leur forme
        # if texteKeyRef != '' :
        #   self.texteXSD = self.texteXSD[0:-3]+'>\n'
        #   self.texteXSD += texteKeyRef
        #   self.texteXSD += fermeEltCata

        # if not PourTraduction : print (self.texteXSD)

        dico = {}
        # debug = True
        for k in list(cata.dictTypesXSD.keys()):
            if debug:
                print("cata.dictTypesXSD traitement de ", k)
            dico[k] = {}
            different = False
            for definition in cata.dictTypesXSD[k]:
                if definition.label == "BLOC" or definition.label == "BlocAmbigu":
                    continue
                if definition.nomDuTypePyxb != "T_" + definition.nom:
                    different = True
                    print (definition.nomDuTypePyxb, "T_" + definition.nom)
                if debug:
                    print("definition.nomDuTypePyxb", definition.nomDuTypePyxb)
                listeATraiter = [
                    definition.geneaCompleteSousFormeDeListe(),
                ]
                # print (listeATraiter)
                while listeATraiter != []:
                    listeGenea = listeATraiter[0]
                    listeATraiter = listeATraiter[1:]
                    txtNomComplet = ""
                    indexMC = 0
                    for MC in listeGenea:
                        # attention en cas de MC Recursif on a une boucle infinie avec le append
                        if MC.nom in self.listeElementsRecursifs:
                            continue
                        txtNomComplet = txtNomComplet + "_" + MC.nom
                        if MC in list(cata.dictTypesXSDJumeaux.keys()):
                            for MCJumeau in cata.dictTypesXSDJumeaux[MC]:
                                # attention nvlleGenalogie n a pas de sens en Accas
                                nvlleGenalogie = (
                                    listeGenea[:indexMC]
                                    + MCJumeau.geneaCompleteSousFormeDeListe()
                                )
                                listeATraiter.append(nvlleGenalogie)
                        indexMC = indexMC + 1
                    dico[k][txtNomComplet] = definition.nomDuTypePyxb
            if dico[k] == {} or (not different):
                del dico[k]
        import pprint

        # pprint.pprint(dico)
        # PN reflechir a ce *** de nom
        if dico != {} :
            self.texteXSD += texteDicoNomEltNomTypeDifferent.format(str(dico))
        # PN attention, les doublons ne sont pas geres ( 1 elt meme nom avec ou sans unit ou unite differente)
        # cependant, cette liste ne sert que d indication de projection comme des unites comme attributs
        # a changer si necessaire
        if cata.listeTypeWithUnit != () and cata.listeTypeWithUnit != []:  
            self.texteXSD += texteListeTypeWithUnit.format(str(cata.listeTypeWithUnit))

        # import pprint
        # if (not PourTraduction) and  (dico != {}) : pprint.pprint(dico)
        # print ('__________________________ decommenter pour le texteXSD________________________')
        # print (dico)
        # print (self.texteXSD)
        self.texteXSD += texteFin
        return self.texteXSD

    def dumpWithAbstractElt(self):
        cata = CONTEXT.getCurrentCata()
        cataFileSourceExt = os.path.basename(cata.cata.__file__)
        cataFileSource, extension = os.path.splitext(cataFileSourceExt)
        importCataSource = __import__(cataFileSource, {}, {})

        # a reprendre avec la nouvelle tructure et le JDC-CATA et JDC-SINGLETION
        texte = ""
        for m in sys.modules:
            monModule = sys.modules[m]
            try:
                if m in ("os", "sys", "inspect", "six", "pickle", "codecs"): continue
                if m in ("cPickle", "pprint", "dis", "_sre", "encodings.aliases"): continue
                if m in ("numbers", "optparse", "binascii", "posixpath"): continue
                if m in ("_locale", "_sysconfigdata_nd", "gc", "functools"): continue
                if m in ("posixpath", "types", "posix", "prefs"): continue
                if m in ("warnings", "types", "posix", "prefs"): continue
                if monModule.__name__[0:15] == "_sysconfigdata_": continue
                if monModule.__name__ == "__future__": continue
                if monModule.__name__[0:3] == "Ihm": continue
                if monModule.__name__[0:5] == "numpy": continue
                if monModule.__name__[0:5] == "processing": continue
                if monModule.__name__[0:5] == "Accas": continue
                if monModule.__name__[0:7] == "convert": continue
                if monModule.__name__[0:7] == "Efi2Xsd": continue
                if monModule.__name__[0:7] == "Editeur": continue
                if monModule.__name__[0:9] == "generator": continue
                if monModule.__name__[0:10] == "Validation": continue
                if monModule.__name__[0:10] == "extensions": continue
                if monModule.__name__[0:12] == "InterfaceQT": continue
                if monModule.__name__ == cataFileSource:
                    continue
                texte = texte + "try : import " + monModule.__name__ + " \n"
                texte = texte + "except : pass \n"
                texte = texte + "try : from  " + monModule.__name__ + " import * \n"
                texte = texte + "except : pass \n"
            except:
                pass

        newModule = imp.new_module("__main__")
        exec(texte, newModule.__dict__)
        allClassToDump = []
        for i in dir(importCataSource):
            if i not in dir(newModule):
                allClassToDump.append(importCataSource.__dict__[i])

        self.texteSimple = ""
        self.texteComplexe = ""
        for c in allClassToDump:
            if not (isinstance(c, Accas.OPER)) and not (isinstance(c, Accas.PROC)):
                continue
            c.nomDuCodeDumpe = self.nomDuCodeDumpe
            c.code = self.implement
            c.dumpXsd(withAbstractElt=True)

            self.texteSimple += c.texteSimple
            self.texteComplexe += c.texteComplexe
            if c.ang != "":
                c.texteElt = eltEtapeWithHelp.format(
                    c.nom, self.implement, c.nomDuTypePyxb, self.implement, c.ang
                )
            elif c.fr != "":
                c.texteElt = eltEtapeWithHelp.format(
                    c.nom, self.implement, c.nomDuTypePyxb, self.implement, c.fr
                )
            else:
                c.texteElt = eltEtape.format(
                    c.nom, self.implement, c.nomDuTypePyxb, self.implement
                )
            self.texteCata += c.texteElt

    def dumpSimpleDesCommandes(self, debug=False):
        self.texteCata = eltCataSimple.format( self.code, self.code, self.code, self.code)
        # on remplace les extensions par rien
        for c in self.commandes:
            if debug: print("commande ", c, c.nom)
            c.nomDuCodeDumpe = self.nomDuCodeDumpe
            c.code = self.implement
            c.dumpXsd(withAbstractElt=False)
            self.texteSimple += c.texteSimple
            self.texteSimple += c.texteComplexe
            if c.ang != "":
                c.texteElt = eltEtapeSimpleWithHelp.format(
                    c.nom, self.implement, c.nomDuTypePyxb, 0, 1, c.ang
                )
            elif c.fr != "":
                c.texteElt = eltEtapeSimpleWithHelp.format(
                    c.nom, self.implement, c.nomDuTypePyxb, 0, 1, c.fr
                )
            else:
                c.texteElt = eltEtapeSimple.format(
                    c.nom, self.implement, c.nomDuTypePyxb, 0, 1
                )
            self.texteCata += c.texteElt
        self.texteCata += finEltCataSimple

    def formate(self, texte, debug = 0) :
        newTexte=''
        indent = 1
        stop  = 0
        dansEnumeration = 0
        dansElement = 0
        for ligne in texte.split('\n'):
            #if ligne.find('<xs:minLen') >= 0  : debug = 1
            #if ligne.find('DATA_FILE') > 0 : debug = True
            if debug : print ('-------------------------')
            if debug : print (ligne)
            if debug : print ('indent debut ', indent)
            if ligne.find ('\&') > 0: 
               ligne=ligne.replace ('\&', 'et')
            if ligne.find ('&') > 0: 
               ligne=ligne.replace ('&', 'et')
            memeIndentation = 0
            if ligne.find('<xs:enumeration') == 0 : 
               if debug : print ('dansEnumeration', dansEnumeration)
               if dansEnumeration : memeIndentation = 1
               else : memeIndentation = 0
               dansEnumeration = 1
            else :
               if dansEnumeration == 1 : indent = indent -1
               dansEnumeration = 0
            if ligne.find('<xs:element') == 0 : 
               if debug : print ('dansELement', dansEnumeration)
               if dansElement : memeIndentation = 1
               else : memeIndentation = 0
               dansElement = 1
            else :
               if dansElement == 1 : indent = indent -1
               dansElement = 0
            if ligne.find('</xs:element') == 0 : 
                indent += 1
            if debug : print ('memeIndentation', memeIndentation)
            if not (memeIndentation) and ligne.find('<') >= 0: indent = indent + 1
            if debug : print ('indent apres les find ', indent)

            if ligne[0:2] == '</' : indent += -1
            if debug : print (indent , 'apres fermeture')

            newTexte += '  ' * indent + ligne + '\n'
            if ligne[0:2] == '</' : indent += -1
            if ligne.find('<xs:minInclusive') == 0  : indent += -1
            if ligne.find('<xs:maxInclusive') == 0  : indent += -1
            if ligne.find('<xs:attribute') == 0  : indent += -1
            # PN Attention > 0 car il y a les conditions possibles ou la doc est sur +sieurs lignes
            if ligne.find('</xs:documentation') > 0  : indent += -1
            if ligne.find('<xs:minLen') >= 0  : indent += -1
            if ligne.find('<xs:maxLen') >= 0  : indent += -1
            if debug : print (indent , 'apres ecriture')

            stop += 1
            #if stop == 1500 : 
            #   print(newTexte)
            #   break
        return newTexte

           
