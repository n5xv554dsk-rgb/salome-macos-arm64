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
from builtins import str
from builtins import object

import re, os

from Accas.extensions.eficas_translation import tr

l_noms_commandes = ["OPER", "PROC", "MACRO", "FORM"]
l_noms_composes = ["FACT", "BLOC", "NUPL", "FORM"]
l_noms_simples = [
    "SIMP",
]
l_noms = l_noms_composes + l_noms_simples


def elimineCommentaires(text):
    """Elimine les lignes de commentaires dans text
    Attention : supprime sauvagement tous les caracteres entre # et le retour chariot ...
    """
    comments = re.compile(r"#[^\n]*")
    return comments.sub("", text)


def chercheNom(text):
    Whitespace = r"[ \f\t]*"
    Name = r"[a-zA-Z_]\w*"
    myexpr = "(u" + Name + ")" + Whitespace + "=" + Whitespace + "$"
    a = re.search(myexpr, text)
    return a.group(1)


def chercheArgs(text):
    text = text.strip()
    longueur = len(text)
    if text[0] != "(u":
        return "erreur !"
    else:
        nbpar = 1
        for i in range(1, longueur):
            if text[i] == "(u":
                nbpar = nbpar + 1
            elif text[i] == ")":
                nbpar = nbpar - 1
            else:
                continue
            if nbpar == 0:
                break
        if nbpar != 0:
            return tr("Erreur ! Erreur !")
        else:
            try:
                return (
                    text[1:i],
                    text[i + 1 :],
                )  # on enleve les premiere et derniere parentheses
            except:
                return text[1:i], ""


class ENTITE(object):
    def chercheEnfants(self):
        try:
            self.text = self.text.strip()
            liste = re.split("=", self.text, 1)
            if len(liste) > 1:
                arg1 = liste[0]
                reste = liste[1]
                reste = reste.strip()
                if reste[0:4] in l_noms:
                    nomMc = chercheNom(arg1 + "=")
                    argMc, self.text = chercheArgs(reste[4:])
                    self.creeMc(nomMc, argMc, reste[0:4])
                else:
                    self.text = reste
                self.chercheEnfants()
            else:
                # pas de = rencontre
                return
        except Exception as e:
            self.cr.fatal(tr("Erreur rencontree dans rechercheEnfants : %s", e.__str()))

    def creeMc(self, nomMc, argMc, test):
        if test in l_noms_composes:
            mc = FACT_CATA(nomMc, argMc, self)
            self.children.append(mc)
        elif test in l_noms_simples:
            mc = SIMP_CATA(nomMc, self)
            self.children.append(mc)
        else:
            print(tr("Erreur dans la creation du mot-cle : %s", nomMc))

    def construitListeDico(self):
        l = []
        d = {}
        if len(self.children) == 0:
            self.ordreMC = l
            self.entites = d
            return
        try:
            for child in self.children:
                l.append(child.nom)
                d[child.nom] = child
            self.ordreMC = l
            self.entites = d
        except:
            print(("erreur : ", self.nom, self.__class__))


class COMMANDE_CATA(ENTITE):
    def __init__(self, nom, args, parent):
        self.nom = nom
        self.args = args
        self.children = []
        self.text = args
        self.cr = CR()
        self.cr.debut = "Debut commande %s" % self.nom
        self.cr.fin = "Fin commande %s" % self.nom
        self.chercheEnfants()
        self.construitListeDico()
        parent.cr.add(self.cr)

    def affiche(self):
        texteCmd = "\n"
        texteCmd = texteCmd + "Commande :" + self.nom + "\n"
        for child in self.children:
            texteCmd = texteCmd + child.affiche(1)
        return texteCmd


class SIMP_CATA(object):
    def __init__(self, nom, parent):
        self.nom = nom
        self.cr = CR()
        self.cr.debut = "Debut mot-cle simple %s" % self.nom
        self.cr.fin = "Fin mot-cle simple %s" % self.nom
        parent.cr.add(self.cr)

    def affiche(self, ind):
        sep = " " * 5
        return sep * ind + self.nom + "\n"


class FACT_CATA(ENTITE):
    def __init__(self, nom, args, parent):
        self.nom = nom
        self.args = args
        self.children = []
        self.text = args
        self.cr = CR()
        self.cr.debut = "Debut mot-cle facteur ou bloc %s" % self.nom
        self.cr.fin = "Fin mot-cle facteur ou bloc %s" % self.nom
        self.chercheEnfants()
        self.construitListeDico()
        parent.cr.add(self.cr)

    def affiche(self, ind):
        sep = " " * 5
        text = ""
        text = text + sep * ind + self.nom + "\n"
        for child in self.children:
            text = text + child.affiche(ind + 1)
        return text


class CATALOGUE_CATA(object):
    def __init__(self, parent, fichier):
        self.parent = parent
        self.fichier = fichier
        self.cr = CR()
        self.cr.debut = "Debut compte-rendu catalogue %s" % self.fichier
        self.cr.fin = "Fin compte-rendu catalogue %s" % self.fichier
        self.ouvrirFichier()
        self.listeCommandes = []
        self.listeTextesCommandes = []

    def ouvrirFichier(self):
        try:
            with open(self.fichier) as fd:
                self.texte_complet = fd.read()
        except:
            print((tr("Impossible d'ouvrir le fichier : %s ", str(self.fichier))))
            self.cr.fatal(tr("Impossible d'ouvrir le fichier : %s ", str(self.fichier)))

    def constrListTxtCmd(self, text):
        text = elimineCommentaires(text)
        pattern = "\) *;"
        liste = re.split(pattern, text)
        for i in range(0, len(liste) - 1):
            self.listeTextesCommandes.append(liste[i] + ")")

    def analyseCommande(self, text):
        for nomCmd in l_noms_commandes:
            liste = re.split(nomCmd + " *\(u", text, 1)
            if len(liste) == 2:
                break
        if len(liste) < 2:
            print(
                (
                    tr(
                        "le texte a analyser n'est pas celui d'une commande connue : \
                            %(v_1)s %(v_2)s",
                        {"v_1": str(l_noms_commandes), "v_2": text},
                    )
                )
            )
            self.cr.fatal(
                tr(
                    "le texte a analyser n'est pas celui d'une commande connue : \
                             %(v_1)s %(v_2)s",
                    {"v_1": str(l_noms_commandes), "v_2": text},
                )
            )
            return
        debut = liste[0]
        fin = liste[1]
        nomCmd = chercheNom(debut)
        if nomCmd == "erreur !":
            print((tr("Erreur dans la recherche du  nom de la commande : "), debut))
        args_cmd, toto = chercheArgs("(u" + fin)
        if args_cmd == "erreur !":
            print((tr("Erreur dans la recherche des args de la commande : "), debut))
            print((tr(fin)))
        cmd = COMMANDE_CATA(nomCmd, args_cmd, self)
        self.listeCommandes.append(cmd)

    def analyseTexte(self, texte):
        self.constrListTxtCmd(texte)
        try:
            self.parent.configure_barre(len(self.listeTextesCommandes))
        except:
            pass
        for texte_commande in self.listeTextesCommandes:
            try:
                self.parent.update_barre()
            except:
                pass
            self.analyseCommande(texte_commande)
        self.construitListeDico()

    def ecritLcmd(self):
        f = open("U:\\EFICAS\\Accas\\cata.txt", "w")
        for cmd in self.listeCommandes:
            f.write(cmd.affiche())
        f.close()

    def construitListeDico(self):
        l = []
        d = {}
        for cmd in self.listeCommandes:
            l.append(cmd.nom)
            d[cmd.nom] = cmd
        self.ordreMC = l
        self.entites = d

    def report(self):
        """retourne l'objet rapport du catalogue de commande"""
        return self.cr


def analyseCatalogue(parent, nom_cata):
    cata = CATALOGUE_CATA(parent, nom_cata)
    cata.analyseTexte(cata.texte_complet)
    return cata


def analyseCatalogueCommande(parent, nom_cata):
    cata = CATALOGUE_CATA(parent, nom_cata)
    cata.analyseCommande(cata.texte_complet)
    cata.construitListeDico()
    return cata


if __name__ == "__main__":
    import profile

    profile.run("analyseCatalogue(None,'U:\\EFICAS\\Cata\\cata_saturne.py')")
