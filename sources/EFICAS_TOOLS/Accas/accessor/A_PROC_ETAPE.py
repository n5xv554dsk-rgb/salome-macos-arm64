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
from Accas.accessor import A_ETAPE


# import rajoutes suite a l'ajout de buildSd --> a resorber
import sys
import traceback, types
from Accas.processing import P_PROC_ETAPE
from Accas.processing import P_Exception
from Accas.processing.P_Exception import AsException
from Accas.extensions.eficas_exception import EficasException


class PROC_ETAPE(A_ETAPE.ETAPE):
    def getSdname(self):
        return ""

    def getSdprods(self, nom_sd):
        """
        Fonction : retourne le concept produit par l etape de nom nom_sd
        s il existe sinon None
        Une PROC ne produit aucun concept
        """
        return None

    def supprimeSdProds(self):
        """
        Fonction: Lors d'une destruction d'etape, detruit tous les concepts produits
        Une procedure n'en a aucun
        """
        return

    def deleteConcept(self, sd):
        """
        Fonction : Mettre a jour les mots cles de l etape
        suite a la disparition du concept sd
        Seuls les mots cles simples MCSIMP font un traitement autre
        que de transmettre aux fils

        Inputs :
           - sd=concept detruit
        """
        for child in self.mcListe:
            child.deleteConcept(sd)

    def replaceConcept(self, old_sd, sd):
        """
        Fonction : Mettre a jour les mots cles de l etape
        suite au remplacement du concept old_sd

        Inputs :
           - old_sd=concept remplace
           - sd=nouveau concept
        """
        for child in self.mcListe:
            child.replaceConcept(old_sd, sd)

    def getMCPath(self):
        index = self.jdc.getIndex(self)
        return [self.nom, "@index " + str(index) + " @"]

    def delieIncertitude(self):
        mcVP = self.getChild("Input").getChild("VariableProbabiliste")
        for vp in mcVP:
            vp.variableDeterministe.variableProbabilite = None
            vp.variableDeterministe.associeVariableUQ = False
            vp.variableDeterministe.definition.siValide = None

    # ATTENTION SURCHARGE: a garder en synchro ou a reintegrer dans le Noyau
    def buildSd(self):
        """
        Mmethode de processing surchargee pour poursuivre malgre tout
        si une erreur se produit pendant la creation du concept produit
        """
        try:
            sd = P_PROC_ETAPE.PROC_ETAPE.buildSd(self)
        except AsException:
            # Une erreur s'est produite lors de la construction du concept
            # Comme on est dans EFICAS, on essaie de poursuivre quand meme
            # Si on poursuit, on a le choix entre deux possibilites :
            # 1. on annule la sd associee a self
            # 2. on la conserve mais il faut la retourner
            # En plus il faut rendre coherents sdnom et sd.nom
            self.sd = None
            self.sdnom = None
            self.state = "unchanged"
            self.valid = 0
