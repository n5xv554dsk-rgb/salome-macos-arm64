# coding=utf-8
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


""" Ce module contient la classe compte-rendu de Accas.validation
"""


class CR(object):

    """
    Classe servant a la construction et a l'affichage des objets Comptes-rendus
    """

    def __init__(self, verbeux="non", debut="", fin="", dec="   "):
        """
        Attributs
         - verbeux
         - debut
         - fin
         - dec
        """
        self.verbeux = verbeux
        self.debut = debut
        self.fin = fin
        self.dec = dec
        self.crok = []
        self.crwarn = []
        self.crfatal = []
        self.crexception = []
        self.subcr = []

    def ok(self, comment):
        """Ajoute un commentaire OK a la liste crok"""
        self.crok.append(comment)

    def warn(self, comment):
        """Ajoute un commentaire Warning a la liste crwarn"""
        self.crwarn.append(comment)

    def fatal(self, comment, *args):
        """Ajoute un commentaire Erreur Fatale a la liste crfatal a formater"""
        self.crfatal.append(comment)
        self.crfatal.append(str(*args))

    def exception(self, comment):
        """Ajoute un commentaire Exception a la liste crexception"""
        self.crexception.append(comment)

    def add(self, cr):
        """Ajoute un objet CR a la liste subcr :il s'agit de l'objet CR d'un fils de self"""
        self.subcr.append(cr)

    def estvide(self):
        """
        Retourne 1 si self ne contient aucun message grave (fatal ou exception)
        et aucun CR qui en contienne, 0 sinon
        """
        if self.crexception:
            return 0
        if self.crfatal:
            return 0
        for s in self.subcr:
            if not s.estvide():
                return 0
        return 1

    def purge(self):
        """
        Purge complètement le CR sauf les exceptions
        """
        self.debut = ""
        self.fin = ""
        self.dec = "   "
        self.crok = []
        self.crwarn = []
        self.crfatal = []
        self.subcr = []

    def beautifieMessages(self):
        """
        Beautifie les messages stockés dans crok,crfatal,crexception et crwarn
        """
        l = []
        for mess in self.crok:
            l.append(mess + "\n")
        self.crok_belle = l
        l = []
        for mess in self.crwarn:
            l.append(encadreMessage(mess, "*"))
        self.crwarn_belle = l
        l = []
        for mess in self.crfatal:
            l.append(encadreMessage(mess, "!"))
        self.crfatal_belle = l
        l = []
        for mess in self.crexception:
            l.append(encadreMessage(mess, "!"))
        self.crexception_belle = l

    def indent(self, s):
        """
        Insère en tete de chaque ligne du texte s la chaine self.dec
        """
        l = s.split("\n")
        a = "\n" + self.dec
        return self.dec + a.join(l)[:-3]

    def __unicode__(self):
        """
        Retourne une chaine de caractères décorée et représentative de self
        """
        s = ""
        self.beautifieMessages()
        s = s + "".join(self.crok_belle)
        s = s + "".join(self.crwarn_belle)
        s = s + "".join(self.crfatal_belle)
        s = s + "".join(self.crexception_belle)
        for subcr in self.subcr:
            if self.verbeux == "oui":
                s = s + str.text_type(subcr) + "\n"
            else:
                if not subcr.estvide():
                    s = s + str(subcr)
        if s != "":
            s = self.debut + "\n" + self.indent(s) + self.fin + "\n"
        else:
            s = self.debut + "\n" + self.fin + "\n"
        return s

    def __str__(self):
        """Return the report representation"""
        txt = self.__unicode__()
        return txt

    def report(self, decalage=2):
        """
        Retourne une chaine de caractères non encadrée mais représentative de self
        """
        s = ""
        # on stocke dans s les messages de premier niveau
        for mess in self.crok:
            s = s + decalage * self.dec + mess + self.dec + "\n"
        for mess in self.crwarn:
            s = s + decalage * self.dec + mess + self.dec + "\n"
        for mess in self.crfatal:
            s = s + decalage * self.dec + mess + self.dec + "\n"
        for mess in self.crexception:
            s = s + decalage * self.dec + mess + self.dec + "\n"
        # on récupère les messages des sous comptes-rendus ...
        for subcr in self.subcr:
            if not subcr.estvide():
                s = s + subcr.report(decalage=decalage + 1)
        # on rajoute les flags de début et de fin ... (si self n'est pas vide)
        if not self.estvide():
            s = (
                (decalage - 1) * self.dec
                + self.debut
                + "\n"
                + s
                + (decalage - 1) * self.dec
                + self.fin
                + "\n"
            )
        return s

    def getMessFatal(self):
        """
        Retourne une chaine de caractères contenant les messages de
        la liste crfatal (du dernier au premier)
        """
        self.crfatal.reverse()
        s = ""
        for elem in self.crfatal:
            s = s + elem
        self.crfatal.reverse()
        return s

    def getMessException(self):
        """
        Retourne une chaine de caractères contenant les messages
        de la liste crexception (du dernier au premier)
        """
        self.crexception.reverse()
        s = ""
        for elem in self.crexception:
            s = s + elem
        self.crexception.reverse()
        return s


separateurs = (" ", ",", "/")


def split(ligne, cesure):
    ligne = ligne.rstrip()
    if len(ligne) <= cesure:
        return ligne
    else:
        coupure = cesure
        while ligne[coupure] not in separateurs and coupure > 0:
            coupure = coupure - 1
        if coupure == 0:
            # Il faut augmenter la cesure
            coupure = cesure
            while ligne[coupure] not in separateurs and coupure < len(ligne) - 1:
                coupure = coupure + 1
        if coupure == len(ligne) - 1:
            return ligne
        else:
            return ligne[: coupure + 1] + "\n" + split(ligne[coupure + 1 :], cesure)


def justifyText(texte="", cesure=50):
    if not isinstance(texte, str):
        texte = "".join(texte)
    texte = texte.strip()
    liste_lignes = texte.split("\n")
    l = [split(l, cesure) for l in liste_lignes]
    texte_justifie = "\n".join(l)
    return texte_justifie


def encadreMessage(texte, motif):
    """
    Retourne la chaine de caractères texte entourée d'un cadre formés
    d'éléments 'motif'
    """
    texte = justifyText(texte, cesure=80)
    if texte.strip() == "":
        return ""
    lignes = texte.split("\n")
    longueur = 0
    for ligne in lignes:
        ligne = ligne.rstrip()
        if len(ligne) > longueur:
            longueur = len(ligne)
    longueur = longueur + 4
    txt = motif * longueur + "\n"
    for ligne in lignes:
        if ligne == "":
            continue
        txt = (
            txt
            + motif
            + " "
            + ligne
            + " " * (longueur - len(motif + ligne) - 2)
            + motif
            + "\n"
        )
    txt = txt + motif * longueur + "\n"
    return txt
