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
   Ce module sert a retrouver l'ordre des mots cles d'un catalogue de
   commandes
"""
import sys
from Accas import NUPL


def traiteEntiteNUPL(entite):
    """
    Fonction speciale pour les nuplets (classe NUPL)
    Cette fonction ajoute a l'objet entite un attribut de nom ordreMC
    qui est une liste vide.
    """
    entite.ordreMC = []


def traiteEntite(entite, listeSimpReel):
    """
    Cette fonction ajoute a l'objet entite un attribut de nom ordreMC
    qui est une liste contenant le nom des sous entites dans l'ordre
    de leur apparition dans le catalogue.
    L'ordre d'apparition dans le catalogue est donne par l'attribut _no
    de l'entite
    La fonction active le meme type de traitement pour les sous entites
    de entite
    """
    l = []
    for k, v in list(entite.entites.items()):
        if isinstance(v, NUPL):
            traiteEntiteNUPL(v)
        else:
            traiteReel(v, listeSimpReel)
            traiteEntite(v, listeSimpReel)
            traiteCache(v)
        l.append((v._no, k))
    l.sort()
    entite.ordreMC = [item for index, item in l]


def traiteCache(objet):
    if not hasattr(objet, "cache"):
        return
    if objet.cache == 0:
        return
    clef = objet.nom
    if objet.equiv != None:
        clef = objet.equiv
    if hasattr(objet.pere, "mcOblig"):
        objet.pere.mcOblig[clef] = objet.defaut
    else:
        objet.pere.mcOblig = {}
        objet.pere.mcOblig[clef] = objet.defaut


def traiteReel(objet, listeSimpReel):
    if objet.__class__.__name__ == "SIMP":
        if "R" in objet.type:
            if objet.nom not in listeSimpReel:
                listeSimpReel.append(objet.nom)


def analyseNiveau(dicoCataOrdonne, niveau, listeSimpReel):
    """
    Analyse un niveau dans un catalogue de commandes
    """
    if niveau.lNiveaux == ():
        # Il n'y a pas de sous niveaux
        for oper in niveau.entites:
            traiteEntite(oper, listeSimpReel)
            dicoCataOrdonne[oper.nom] = oper
    else:
        for niv in niveau.lNiveaux:
            analyseNiveau(dicoCataOrdonne, niv)


def analyseCatalogue(cata):
    """
    Cette fonction analyse le catalogue cata pour construire avec l'aide
    de traiteEntite la structure de donnees ordreMC qui donne l'ordre
    d'apparition des mots cles dans le catalogue
    Elle retourne un dictionnaire qui contient toutes les commandes
    du catalogue indexees par leur nom
    """
    dicoCataOrdonne = {}
    listeSimpReel = []
    if cata.JdC.lNiveaux == ():
        # Il n'y a pas de niveaux
        for oper in cata.JdC.commandes:
            traiteEntite(oper, listeSimpReel)
            dicoCataOrdonne[oper.nom] = oper
    else:
        for niv in cata.JdC.lNiveaux:
            analyseNiveau(dicoCataOrdonne, niv, listeSimpReel)
    return dicoCataOrdonne, listeSimpReel


if __name__ == "__main__":
    print (' a faire')
    exit()
    from Test import cataTest

    dico = analyseCatalogue(cataTest)

    def print_entite(entite, dec="  "):
        print(dec, entite.nom, entite.__class__.__name__)
        for mocle in entite.ordreMC:
            print_entite(entite.entites[mocle], dec=dec + "  ")

    for k, v in list(dico.items()):
        print_entite(v, dec="")

    print(dico)
