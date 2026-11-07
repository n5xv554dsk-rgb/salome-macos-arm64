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
"""Ce module contient le plugin generateur de fichier au format  Code_Carmel3D pour EFICAS.
"""
from builtins import str

import traceback
import types, re, os
from Accas.extensions.eficas_translation import tr
from Accas.IO.writer.writer_python import PythonGenerator

extensions = (".comm",)


def entryPoint():
    """
    Retourne les informations necessaires pour le chargeur de plugins
    Ces informations sont retournees dans un dictionnaire
    """
    return {
        # Le nom du plugin
        "name": "TELEMAC",
        # La factory pour creer une instance du plugin
        "factory": TELEMACGenerator,
    }


class TELEMACGenerator(PythonGenerator):
    """
    Ce generateur parcourt un objet de type JDC et produit
    un texte au format eficas et
    un texte au format dictionnaire

    """

    # ----------------------------------------------------------------------------------------
    def gener(self, obj, format="brut", config=None, appliEficas=None, statut="Leger"):
        self.statut = statut
        self.langue = appliEficas.langue
        try:
            self.TelemacdicoEn = appliEficas.readercata.TelemacdicoEn
        except:
            print("Attention : pas de TelemacdicoEn declare")
            self.TelemacdicoEn = {}
        self.DicoEnumCasEnInverse = {}
        # from enum_Telemac2d_auto       import self.TelemacdicoEn
        for motClef in self.TelemacdicoEn:
            d = {}
            for valTelemac in self.TelemacdicoEn[motClef]:
                valEficas = self.TelemacdicoEn[motClef][valTelemac]
                d[valEficas] = valTelemac
            self.DicoEnumCasEnInverse[motClef] = d
        if self.langue == "fr":
            # from  enum_Telemac2d_auto import DicoEnumCasFrToEnumCasEn
            self.DicoEnumCasFrToEnumCasEn = (
                appliEficas.readercata.DicoEnumCasFrToEnumCasEn
            )
            for motClef in self.DicoEnumCasFrToEnumCasEn:
                d = {}
                for valTelemac in self.DicoEnumCasFrToEnumCasEn[motClef]:
                    valEficas = self.DicoEnumCasFrToEnumCasEn[motClef][valTelemac]
                    d[valEficas] = valTelemac
                self.DicoEnumCasEnInverse[motClef] = d
        self.initDico()
        # Pour Simplifier les verifs d ecriture
        if hasattr(appliEficas, "listeTelemac"):
            self.listeTelemac = appliEficas.listeTelemac
        else:
            self.listeTelemac = ()

        self.dicoCataToCas = {}
        try:
            self.dicoCasToCata = appliEficas.readercata.dicoCasToCata
        except:
            print("Attention pas de dicoCasToCata declare")
            self.dicoCasToCata = {}
            self.dicoCataToCas = {}
        for motClef in self.dicoCasToCata:
            self.dicoCataToCas[self.dicoCasToCata[motClef]] = motClef

        # Cette instruction genere le contenu du fichier de commandes (persistance)
        self.text = PythonGenerator.gener(self, obj, format)
        return self.text

    # ----------------------------------------------------------------------------------------
    # initialisations
    # ----------------------------------------------------------------------------------------

    def initDico(self):
        self.PE = False
        self.FE = False
        self.VE = False
        self.commentaireAvant = False
        self.texteCom = ""
        if self.langue == "fr":
            self.textPE = "COTES IMPOSEES :"
            self.textFE = "DEBITS IMPOSES :"
            self.textVE = "VITESSES IMPOSEES :"
        else:
            self.textPE = "PRESCRIBED ELEVATIONS :"
            self.textFE = "PRESCRIBED FLOWRATES :"
            self.textVE = "PRESCRIBED VELOCITIES :"
        self.nbTracers = 0
        self.texteDico = ""

    # ----------------------------------------------------------------------------------------
    # ecriture de tout
    # ----------------------------------------------------------------------------------------

    def writeDefault(self, fn):
        self.texteDico += "&ETA\n"
        # if self.statut == 'Leger' : extension = ".Lcas"
        # else                      : extension = ".cas"
        extension = ".cas"
        fileDico = fn[: fn.rfind(".")] + extension
        f = open(str(fileDico), "w")
        f.write(self.texteDico)
        f.close()

    # ----------------------------------------------------------------------------------------
    # ecriture de Leger
    # ----------------------------------------------------------------------------------------

    def writeComplet(self, fn, jdc, config, appliEficas):
        jdc_formate = self.gener(
            jdc, config=config, appliEficas=appliEficas, statut="Entier"
        )
        self.writeDefault(fn)

    # ----------------------------------------------------------------------------------------
    #  analyse de chaque noeud de l'arbre
    # ----------------------------------------------------------------------------------------

    def generPROC_ETAPE(self, obj):
        if not self.commentaireAvant or self.texteCom.find(obj.nom) < 0:
            self.texteDico += (
                "/------------------------------------------------------------------/\n"
            )
            self.texteDico += "/\t\t\t" + obj.nom + "\n"
            self.texteDico += (
                "/------------------------------------------------------------------/\n"
            )
        self.commentaireAvant = False
        self.texteCom = ""
        s = PythonGenerator.generPROC_ETAPE(self, obj)
        if obj.nom in TELEMACGenerator.__dict__:
            TELEMACGenerator.__dict__[obj.nom](*(self, obj))

        return s

    def generMCSIMP(self, obj):
        """recuperation de l objet MCSIMP"""
        s = PythonGenerator.generMCSIMP(self, obj)

        # Attention pas sur --> ds certains cas non traite par MCFACT ?
        # a reflechir avec Yoann
        # ajouter le statut ?
        if self.statut == "Leger":
            if (
                hasattr(obj.definition, "defaut")
                and (obj.definition.defaut == obj.valeur)
                and (obj.nom not in self.listeTelemac)
            ):
                return s
            if (
                hasattr(obj.definition, "defaut")
                and obj.definition.defaut != None
                and (type(obj.valeur) == tuple or type(obj.valeur) == list)
                and (tuple(obj.definition.defaut) == tuple(obj.valeur))
                and (obj.nom not in self.listeTelemac)
            ):
                return s

        # nomMajuscule=obj.nom.upper()
        # nom=nomMajuscule.replace('_',' ')
        # if nom in listeSupprime or s == "" : return s
        if s == "None,":
            s = None
        if s == "" or s == None:
            return s

        sTelemac = s[0:-1]
        if not (type(obj.valeur) in (tuple, list)):
            if obj.nom in self.DicoEnumCasEnInverse:
                try:
                    sTelemac = str(self.DicoEnumCasEnInverse[obj.nom][obj.valeur])
                except:
                    if obj.valeur == None:
                        sTelemac = obj.valeur
                    else:
                        print(("generMCSIMP Pb valeur avec ", obj.nom, obj.valeur))
                # Si le resultat est du texte on ajoute des guillemets
                if sTelemac[0] not in "0123456789":
                    sTelemac = "'" + sTelemac + "'"

        if type(obj.valeur) in (tuple, list):
            if obj.nom in self.DicoEnumCasEnInverse:
                # sT = "'"
                sT = ""
                for v in obj.valeur:
                    try:
                        sT += str(self.DicoEnumCasEnInverse[obj.nom][v]) + ";"
                    except:
                        if obj.definition.intoSug != []:
                            sT += str(v) + ";"
                        else:
                            print(
                                ("generMCSIMP Pb Tuple avec ", obj.nom, v, obj.valeur)
                            )
                # sTelemac=sT[0:-1]+"'"
                sTelemac = sT[0:-1]
            else:
                sTelemac = sTelemac[0:-1]
                if sTelemac.find("'") > 0:
                    sTelemac = sTelemac.replace(",", ";\n    ")
                    # on enleve le dernier  ';'
                    index = sTelemac.rfind(";")
                    sTelemac = sTelemac[:index] + " " + sTelemac[index + 1 :]

        if self.langue == "fr":
            s1 = str(sTelemac).replace("True", "OUI")
            s2 = s1.replace("False", "NON")
        else:
            s1 = str(sTelemac).replace("True", "YES")
            s2 = s1.replace("False", "NO")
        if hasattr(obj.definition, "max"):
            if obj.definition.max != 1:
                s3 = s2.replace(",", ";")
            else:
                s3 = s2
        if s3 != "" and s3[0] == "(":
            try:
                s3 = s3[1:-1]  # cas de liste vide
            except:
                s3 = " "

        # LIQUID_BOUNDARIES
        # if obj.nom in ('PRESCRIBED_FLOWRATES','PRESCRIBED_VELOCITIES','PRESCRIBED_ELEVATIONS') :
        #   return s

        # cas des Tuples
        if obj.waitTuple() and s3 != "" and s3 != "None":
            s3 = s
            if s3[-1] == ",":
                s3 = s3[:-1]

        if obj.nom not in self.dicoCataToCas:
            if obj.nom == "Consigne":
                return ""
            return s

        nom = self.dicoCataToCas[obj.nom]
        if nom in [
            "VARIABLES FOR GRAPHIC PRINTOUTS",
            "VARIABLES POUR LES SORTIES GRAPHIQUES",
            "VARIABLES TO BE PRINTED",
            "VARIABLES A IMPRIMER",
            "VARIABLES FOR 3D GRAPHIC PRINTOUTS",
            "VARIABLES POUR LES SORTIES GRAPHIQUES 3D",
            "VARIABLES POUR LES SORTIES GRAPHIQUES 2D",
            "VARIABLES FOR 2D GRAPHIC PRINTOUTS",
            "C_VSM_PRINTOUT_SELECTION",
        ]:
            if s3 != "" and s3 != "None":
                s3 = s3.replace(";", ",")
                s3 = "'" + s3 + "'"
            else:
                s3 = "''"
        if nom in ["COUPLING WITH", "COUPLAGE AVEC"]:
            s3 = (
                s3.strip()
                .replace("\n", "")
                .replace(" ", "")
                .replace("\t", "")
                .replace("';'", ",")
            )
        if s3 == "" or s3 == " ":
            s3 = " "
        ligne = nom + " : " + s3 + "\n"
        if len(ligne) > 72:
            ligne = self.redecoupeLigne(nom, s3)
        self.texteDico += ligne

    def generMCFACT(self, obj):
        """ """
        s = PythonGenerator.generMCFACT(self, obj)
        if obj.nom in TELEMACGenerator.__dict__:
            TELEMACGenerator.__dict__[obj.nom](self, obj)

        return s

    def TRACERS(self, obj):
        if self.nbTracers != 0:
            self.texteDico += "NUMBER_OF_TRACERS : " + str(self.nbTracers) + "\n"

    def NAME_OF_TRACER(self, obj):
        print((dir(obj)))
        print((obj.getGenealogiePrecise()))

    def Validation(self, obj):
        self.texteDico += "VALIDATION : True \n"

    def Date_De_L_Origine_Des_Temps(self, obj):
        an = obj.getChild("Year").valeur
        mois = obj.getChild("Month").valeur
        jour = obj.getChild("Day").valeur
        self.texteDico += (
            "ORIGINAL DATE OF TIME  :"
            + str(an)
            + " ,"
            + str(mois)
            + ","
            + str(jour)
            + "\n"
        )

    def Original_Hour_Of_Time(self, obj):
        hh = obj.getChild("Hour").valeur
        mm = obj.getChild("Minute").valeur
        ss = obj.getChild("Second").valeur
        self.texteDico += (
            "ORIGINAL HOUR OF TIME :" + str(hh) + " ," + str(mm) + "," + str(ss) + "\n"
        )

    def Type_Of_Advection(self, obj):
        listeAdvection = [1, 5, 1, 1]
        listeSupg = [2, 2, 2, 2]
        listeUpwind = [1.0, 1.0, 1.0, 1.0]
        self.listeMCAdvection = []
        self.chercheChildren(obj)
        dicoSuf = {"U_And_V": 0, "H": 1, "K_And_Epsilon": 2, "Tracers": 3}
        for c in self.listeMCAdvection:
            if c.nom[0:18] == "Type_Of_Advection_" and c.valeur != None:
                suf = c.nom[18:]
                index = dicoSuf[suf]
                listeAdvection[index] = self.DicoEnumCasEnInverse["Type_Of_Advection"][
                    c.valeur
                ]
            if c.nom[0:13] == "Supg_Option_" and c.valeur != None:
                suf = c.nom[13:]
                index = dicoSuf[suf]
                listeAdvection[index] = self.DicoEnumCasEnInverse["Supg_Option"][
                    c.valeur
                ]
            if c.nom[0:23] == "Upwind_Coefficients_Of_" and c.valeur != None:
                suf = c.nom[23:]
                index = dicoSuf[suf]
                listeUpwind[index] = c.valeur
        self.texteDico += "TYPE OF ADVECTION = " + str(listeAdvection) + "\n"
        self.texteDico += "SUPG OPTION = " + str(listeSupg) + "\n"
        self.texteDico += "UPWIND COEFFICIENTS = " + str(listeUpwind) + "\n"

    def chercheChildren(self, obj):
        for c in obj.listeMcPresents():
            objc = obj.getChild(c)
            if hasattr(objc, "listeMcPresents") and objc.listeMcPresents() != []:
                self.chercheChildren(objc)
            else:
                self.listeMCAdvection.append(objc)

    def redecoupeLigne(self, nom, valeur):
        text = nom + " : \n"
        valeur = valeur
        if valeur.find("'") > -1:
            lval = valeur.split(";")
            for v in lval:
                text += "   " + v + ";"
            text = text[0:-1] + "\n"
        else:
            lval = valeur.split(";")
            ligne = "   "
            for v in lval:
                if len(ligne + str(v) + "; ") < 70:
                    ligne += str(v) + "; "
                else:
                    text += ligne + "\n"
                    ligne = "   " + str(v) + "; "
            text += ligne[0:-2] + "\n"
        return text

    def generCOMMENTAIRE(self, obj):
        sans_saut = re.sub("\n$", "", obj.valeur)
        l_lignes = sans_saut.split("\n")
        txt = "/" + 66 * "-" + "/" + "\n"
        i = 1
        for ligne in l_lignes:
            self.texteCom += ligne + "\n"
            txt = txt + "/" + ligne + "\n"
        txt = txt + "/" + 66 * "-" + "/" + "\n"
        self.texteDico += txt
        self.commentaireAvant = True
        return PythonGenerator.generCOMMENTAIRE(self, obj)
