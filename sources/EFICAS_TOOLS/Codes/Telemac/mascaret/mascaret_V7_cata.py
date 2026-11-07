# -*- coding: utf-8 -*-
#
#  Copyright (C) 2012-2026 EDF
#
#  This file is part of SALOME HYDRO module.
#
#  SALOME HYDRO module is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  SALOME HYDRO module is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with SALOME HYDRO module.  If not, see <http://www.gnu.org/licenses/>.

from Accas import *

JdC = JDC_CATA(regles = (UN_PARMI('MASCARET',)),
                        )

MASCARET = PROC(
    nom = "MASCARET", op = None,
    fr = u"Définition d'un cas d'étude Mascaret",
    ang = u"Definition of a Mascaret study case",
    FICHIER_DICO = SIMP(statut = "o", typ = 'Fichier',
                        fr = u"Fichier Dictionnaire",
                        ang = u"Dictionary file"),
    FICHIER_MOT_CLE = SIMP(statut = "o",
            typ = ('Fichier', 'Fichiers CAS (*.cas);;Tous les fichiers (*)',),
            fr = u"Fichier Mot Clé",
            ang = u"Keyword file"),
    FICHIER_GEOMETRIE = SIMP(statut = "f",
            typ = ('Fichier', 'Fichiers GEO (*.geo);;Tous les fichiers (*)',),
            fr = u"Fichier de géométrie",
            ang = u"Geometry file"),
    FICHIER_LOI = FACT(statut = 'f', max = '**',
        NOM = SIMP(statut = "o",
                   typ = ('Fichier', 'Fichiers LOI (*.loi);;Tous les fichiers (*)',),
                   fr = u"Fichier de lois",
                   ang = u"Laws file"),
                       ),
    FICHIER_ABAQUES = SIMP(statut = "f",
            typ = ('Fichier', 'Tous les fichiers (*)',),
            fr = u"Fichier abaques",
            ang = u"Abacus file"),
    FICHIER_CASIER = SIMP(statut = "f",
            typ = ('Fichier', 'Tous les fichiers (*)',),
            fr = u"Fichier casier",
            ang = u"Compartment file"),
    FICHIER_DAMOCLE = SIMP(statut = "f",
            typ = ('Fichier', 'Tous les fichiers (*)',),
            fr = u"Fichier damocle",
            ang = u"Damocle file"),
    FICHIER_LIG = SIMP(statut = "o",
            typ = ('Fichier', 'Fichiers LIG (*.lig);;Tous les fichiers (*)',),
            fr = u"Fichier LIG",
            ang = u"LIG file"),
    LISTING = SIMP(statut = "f",
            typ = ('Fichier', 'Tous les fichiers (*)', "Sauvegarde"),
            fr = u"Fichier de listing",
            ang = u"Listing file"),
    LISTING_CASIER = SIMP(statut = "f",
            typ = ('Fichier', 'Tous les fichiers (*)', "Sauvegarde"),
            fr = u"Fichier de listing casier",
            ang = u"Compartment listing file"),
    LISTING_LIAISON = SIMP(statut = "f",
            typ = ('Fichier', 'Tous les fichiers (*)', "Sauvegarde"),
            fr = u"Fichier de listing liaison",
            ang = u"Link listing file"),
    RESULTAT = SIMP(statut = "f",
            typ = ('Fichier', 'Tous les fichiers (*)', "Sauvegarde"),
            fr = u"Fichier de résultat",
            ang = u"Result file"),
    RESULTAT_CASIER = SIMP(statut = "f",
            typ = ('Fichier', 'Tous les fichiers (*)', "Sauvegarde"),
            fr = u"Fichier de résultat casier",
            ang = u"Compartment result file"),
    RESULTAT_LIAISON = SIMP(statut = "f",
            typ = ('Fichier', 'Tous les fichiers (*)', "Sauvegarde"),
            fr = u"Fichier de résultat liaison",
            ang = u"Link result file"),
    VARIABLE_SORTIE = FACT(statut = 'f', max = '**',
                           fr = u"Variable de sortie du calcul",
                           ang = u"Computation output variable",
        NOM = SIMP(statut = "o", typ = 'TXM',
                   fr = u"Nom de la variable",
                   ang = u"Variable name"),
        VARIABLE_MASCARET = SIMP(statut = "o", typ = 'TXM',
                   fr = u'Variable Mascaret (ex : "Etat.Z(1,0,0)")',
                   ang = u'Mascaret variable (ex : "Etat.Z(1,0,0)")'),
                           ),
    VARIABLE_ENTREE = FACT(statut = 'f', max = '**',
                           fr = u"Variable d'entrée du calcul",
                           ang = u"Computation input variable",
        NOM = SIMP(statut = "o", typ = 'TXM',
                   fr = u"Nom de la variable",
                   ang = u"Variable name"),
        VARIABLE_MASCARET = SIMP(statut = "o", typ = 'TXM',
                   fr = u'Variable Mascaret (ex : "Modele.Lois.Debit(1,1-2,0)")',
                   ang = u'Mascaret variable (ex : "Modele.Lois.Debit(1,1-2,0)")'),
                           ),
)
TEXTE_NEW_JDC="MASCARET()"
