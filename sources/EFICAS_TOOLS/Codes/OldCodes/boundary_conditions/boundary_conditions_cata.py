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

class grma(GEOM):
  """
  Class used to define the group on which the boundary condition is defined.
  Method __convert__ is redefined to skip the test on the string length.
  """
  def __convert__(cls, valeur):
    if isinstance(valeur, (str, unicode)):
      return valeur.strip()
    raise ValueError('A string is expected')

  __convert__ = classmethod(__convert__)


JdC = JDC_CATA(regles = (AU_MOINS_UN('BOUNDARY_CONDITION',)),
                        )

BOUNDARY_CONDITION = PROC(
    nom = "BOUNDARY_CONDITION", op = None,
    fr = u"Définition d'une condition limite pour Telemac2D",
    ang = u"Definition of a boundary condition for Telemac2D",

    GROUP = SIMP(statut = "o", typ = grma,
                 fr = u"Groupe sur lequel la condition limite est définie",
                 ang = u"Group on which the boundary condition is defined",
                ),
    LIHBOR = SIMP(statut = "o", typ = "I",
                  fr = u"Type de condition limite pour la hauteur d'eau",
                  ang = u"Boundary condition type for the water height",
                 ),
    LIUBOR = SIMP(statut = "o", typ = "I",
                  fr = u"Type de condition limite pour la composante U de la vitesse",
                  ang = u"Boundary condition type for the U component of the water velocity",
                 ),
    LIVBOR = SIMP(statut = "o", typ = "I",
                  fr = u"Type de condition limite pour la composante V de la vitesse",
                  ang = u"Boundary condition type for the V component of the water velocity",
                 ),
)
