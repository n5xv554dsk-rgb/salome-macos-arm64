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
from Accas.extensions.eficas_translation import tr
from Accas.accessor import CONNECTOR
from Accas.accessor import A_MCCOMPO
from Accas.processing import P_MCFACT


class MCFACT(A_MCCOMPO.MCCOMPO):
    def isRepetable(self):
        """
        Indique si l'objet est repetable.
        Retourne 1 si le mot-cle facteur self peut etre repete
        Retourne 0 dans le cas contraire
        """
        objet = self.parent.getChild(self.nom)
        lenDejaLa = len(objet)
        if self.definition.max > 1 and lenDejaLa < self.definition.max:
            return 1
        else:
            return 0

    def isOblig(self):
        if self.definition.statut != "f":
            return 0
        objet = self.parent.getChild(self.nom)
        if len(objet) > self.definition.min:
            return 0
        else:
            return 1

    def getMinMax(self):
        """
        Retourne les valeurs min et max admissibles pour la valeur de self
        """
        return self.definition.min, self.definition.max

    def getNomDsXML(self):
        # en xml on a une sequence si max est superieur a 1
        # sinon non
        objet = self.parent.getChild(self.nom, restreint="oui")
        if len(objet) > 1:
            index = objet.getIndex(self)
            nom = self.nom + "[" + str(index) + "]"
        else:
            if self.definition.max == 1:
                nom = self.nom
            else:
                nom = self.nom + "[0]"
        nomDsXML = self.parent.getNomDsXML() + "." + nom
        return nomDsXML

    def getStatutEtRepetable(self):
        """
        Retourne l index du MCFACT ds la MCList
        """
        objet = self.parent.getChild(self.nom, restreint="oui")
        if len(objet) > 1:
            index = objet.getIndex(self) + 1
        else:
            index = 1
        if self.definition.max > index:
            repetable = 1
        else:
            repetable = 0
        if self.definition.min < index or self.definition.statut == "f":
            statut = "f"
        else:
            statut = "o"
        return (statut, repetable)

    def getLabelText(self):
        """
        Retourne le label de self suivant qu'il s'agit d'un MCFACT
        isole ou d'un MCFACT appartenant a une MCList :
        utilisee pour l'affichage dans l'arbre
        """
        objet = self.parent.getChild(self.nom, restreint="oui")
        # objet peut-etre self ou une MCList qui contient self ...
        if objet is None or objet is self:
            return tr("Erreur - mclist inexistante : %s", self.nom)

        try:
            if len(objet) > 1:
                index = (
                    objet.getIndex(self) + 1
                )  # + 1 a cause de la numerotation qui commence a 0
                return tr(self.nom) + "_" + repr(index) + ":"
            else:
                return tr(self.nom)
        except:
            return tr("Erreur - mot cle facteur de nom : %s", self.nom)

    def getGenealogiePrecise(self):
        nom = self.getLabelText()
        if nom[-1] == ":":
            nom = nom[0:-1]
        if self.parent:
            l = self.parent.getGenealogiePrecise()
            l.append(nom.strip())
            return l
        else:
            return [nom.strip()]

    def getMCPath(self):
        objet = self.parent.getChild(self.nom, restreint="oui")
        if objet is None or objet is self:
            return "mauvais MCPath"
        if len(objet) > 1:
            index = objet.getIndex(self)
        else:
            index = 0
        nom = self.nom
        if self.parent:
            l = self.parent.getMCPath()
        else:
            l = []
        l.append(nom.strip())
        l.append("@index " + str(index) + " @")
        return l

    def initModif(self):
        """
        Met l'etat de l'objet a modified et propage au parent
        qui vaut None s'il n'existe pas
        """
        self.state = "modified"
        parent = hasattr(self, "alt_parent") and self.alt_parent or self.parent
        if parent:
            parent.initModif()

    def finModif(self):
        """
        Methode appelee apres qu'une modification a ete faite afin de declencher
        d'eventuels traitements post-modification
        """
        # print "finModif",self
        # pour les objets autres que les commandes, aucun traitement specifique
        # on remonte l'info de fin de modif au parent
        CONNECTOR.Emit(self, "valid")
        parent = hasattr(self, "alt_parent") and self.alt_parent or self.parent
        if parent:
            parent.finModif()

    def normalize(self):
        """Retourne le MCFACT normalise. Pour un MCFACT isole, l'objet normalise
        est une MCLIST de longueur 1 qui contient ce MCFACT
        """
        new_obj = self.definition.list_instance()
        new_obj.init(nom=self.nom, parent=None)
        new_obj.append(self)
        return new_obj

    def supprime(self):
        self.alt_parent = None
        P_MCFACT.MCFACT.supprime(self)

    def getDicoForFancy(self):
        # print ('MCFACT getDicoForFancy ')
        monDico = {}
        leNom = self.nom

        leNom = self.getLabelText()
        monDico["statut"] = self.definition.statut
        monDico["nomCommande"] = self.nom
        if self.state == "undetermined":
            self.isValid()

        monDico["title"] = leNom
        monDico["key"] = self.idUnique
        monDico["classeAccas"] = self.nature
        monDico["validite"] = self.getValid()
        if not (monDico["validite"]):
            monDico["validite"] = 0

        (statut, repetable) = self.getStatutEtRepetable()
        monDico["statut"] = statut
        monDico["repetable"] = repetable
        if monDico["validite"] == 0 and monDico["statut"] == "f":
            monDico["validite"] = 2

        listeNodes = []
        for obj in self.mcListe:
            lesNodes = obj.getDicoForFancy()
            if not (isinstance(lesNodes, list)):
                listeNodes.append(lesNodes)
            else:
                for leNode in lesNodes:
                    listeNodes.append(leNode)
        monDico["children"] = listeNodes
        if self.nature != "MCSIMP" and self.nature != "MCLIST":
            monDico["infoOptionnels"] = self.calculOptionnelInclutBlocs()
        return monDico
