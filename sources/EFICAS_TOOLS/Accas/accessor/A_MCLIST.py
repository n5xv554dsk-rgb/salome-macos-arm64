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
import types, traceback
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException
from copy import copy
from Accas.accessor import CONNECTOR


class MCList:
    def isMCList(self):
        """
        Retourne 1 si self est une MCList (liste de mots-cles), 0 sinon (defaut)
        """
        return 1

    def getIndex(self, objet):
        """
        Retourne la position d'objet dans la liste self
        """
        return self.data.index(objet)

    def ajoutPossible(self):
        """
        Methode booleenne qui retourne 1 si on peut encore ajouter une occurrence
        de l'element que contient self, 0 sinon
        """
        max = self.data[0].definition.max
        if max == "**" or max == float("inf"):
            return 1
        else:
            if len(self) < max:
                return 1
            else:
                return 0

    def isRepetable(self):
        """
        Indique si l'objet est repetable.
        Retourne 1 si le mot-cle facteur self peut etre repete
        Retourne 0 dans le cas contraire
        """
        if self.data[0].definition.max > 1:
            # marche avec '**'
            return 1
        else:
            return 0

    def getDicoObjetsCompletsPourTree(self):
        # print ('MCList getDicoObjetsCompletsPourTree pour ', self)
        listeDict = []
        for i in self.data:
            listeDict.append(i.getDicoObjetsCompletsPourTree())
        return listeDict
    def getDicoForFancy(self):
        listeDict = []
        nbFactDejaLa = len(self.data)
        for i in self.data:
            dico = i.getDicoForFancy()
            if nbFactDejaLa > i.definition.min:
                dico["statut"] = "f"
            if nbFactDejaLa < i.definition.max:
                dico["repetable"] = 1
            else:
                dico["repetable"] = 0
            listeDict.append(dico)
        return listeDict

    def isOblig(self):
        """
        Une MCList n'est jamais obligatoire (meme si le MCFACT qu'elle represente l'est
        """
        return self.data[0].definition.statut == "o"

    def suppEntite(self, obj):
        """
        Supprime le mot cle facteur obj de la MCLIST
        """
        if obj not in self:
            return 0

        self.initModif()
        self.remove(obj)
        CONNECTOR.Emit(self, "supp", obj)
        #print ('jjjjjjjjjj CONNECTOR.Emit MCLIST')
        self.updateConditionBloc()
        obj.delObjPyxb()
        obj.supprime()
        self.etape.modified()
        self.finModif()
        if obj.nom == "VariableProbabiliste":
            if obj.variableDeterministe:
                obj.variableDeterministe.variableProbabiliste = None
                obj.variableDeterministe.associeVariableUQ = False
        return 1

    def addEntite(self, obj, pos=None):
        """
        Ajoute le mot cle facteur obj a la MCLIST a la position pos
        Retourne None si l'ajout est impossible
        """
        if type(obj) == bytes or type(obj) == str:
            # on est en mode creation d'un motcle
            raise EficasException(tr("traitement non-prevu"))

        if not self.ajoutPossible():
            self.jdc.editor.afficheMessage(
                tr("Erreur"), tr("L'objet {} ne peut pas etre ajoute").format(obj.nom),
                couleur='red'
            )
            return None

        if self.nom != obj.nom:
            return None

        if obj.isMCList():
            obj = obj.data[0]

        # traitement du copier coller seulement
        # Les autres cas d'ajout sont traites dans MCFACT
        self.initModif()
        obj.verifExistenceSd()
        obj.reparent(self.parent)
        if pos is None:
            self.append(obj)
        else:
            self.insert(pos, obj)
        CONNECTOR.Emit(self, "add", obj)
        self.finModif()
        self.updateConditionBloc()
        return obj

    def listeMcPresents(self):
        return []

    def updateConcept(self, sd):
        for child in self.data:
            child.updateConcept(sd)
    def demandeUpdateOptionnels(self):
        for child in self.data:
            child.demandeUpdateOptionnels()

    def deleteRef(self):
        for child in self.data:
            child.deleteRef()

    def deleteConcept(self, sd):
        """
        Inputs :
           - sd=concept detruit
        Fonction : Mettre a jour les fils de l objet suite a la disparition
        du concept sd
        Seuls les mots cles simples MCSIMP font un traitement autre
        que de transmettre aux fils
        """
        for child in self.data:
            child.deleteConcept(sd)

    def replaceConcept(self, old_sd, sd):
        """
        Inputs :
           - old_sd=concept remplace
           - sd=nouveau concept
        Fonction : Mettre a jour les fils de l objet suite au remplacement
        du concept old_sd
        """
        for child in self.data:
            child.replaceConcept(old_sd, sd)

    def getDocu(self):
        return self.data[0].definition.getDocu()

    def getListeMcInconnus(self):
        """
        Retourne la liste des mots-cles inconnus dans self
        """
        l_mc = []
        for mcfact in self.data:
            if mcfact.isValid():
                continue
            l_child = mcfact.getListeMcInconnus()
            for mc in l_child:
                l = [self]
                l.extend(mc)
                l_mc.append(l)
        return l_mc

    def verifConditionRegles(self, liste_presents):
        """
        Retourne la liste des mots-cles a rajouter pour satisfaire les regles
        en fonction de la liste des mots-cles presents
        """
        # Sans objet pour une liste de mots cles facteurs
        return []

    def deepUpdateConditionBloc(self):
        """
        Parcourt l'arborescence des mcobject et realise l'update
        des blocs conditionnels par appel de la methode updateConditionBloc
        """
        # print "deepUpdateConditionBloc",self
        for mcfact in self.data:
            mcfact.deepUpdateConditionBloc()

    def updateConditionBloc(self):
        """
        Propage la mise a jour des conditions au parent.
        Une liste ne fait pas de traitement sur les conditions
        """
        if self.parent:
            self.parent.updateConditionBloc()

    def verifConditionBloc(self):
        """
        Evalue les conditions de tous les blocs fils possibles
        (en fonction du catalogue donc de la definition) de self et
        retourne deux listes :
           - la premiere contient les noms des blocs a rajouter
           - la seconde contient les noms des blocs a supprimer
        """
        # Sans objet pour une liste de mots cles facteurs (a voir !!!)
        return [], []

    def initModif(self):
        """
        Met l'etat de l'objet a modified et propage au parent
        qui vaut None s'il n'existe pas
        """
        self.state = "modified"
        if self.parent:
            self.parent.initModif()

    def finModif(self):
        """
        Methode appelee apres qu'une modification a ete faite afin de declencher
        d'eventuels traitements post-modification
        """
        # print "finModif",self
        CONNECTOR.Emit(self, "valid")
        if self.parent:
            self.parent.finModif()

    def getGenealogiePrecise(self):
        if self.parent:
            return self.parent.getGenealogiePrecise()
        else:
            return []

    def getMCPath(self):
        if self.parent:
            return self.parent.getMCPath()
        else:
            return []

    def getGenealogie(self):
        """
        Retourne la liste des noms des ascendants.
        Un objet MCList n'est pas enregistre dans la genealogie.
        XXX Meme si le MCFACT fils ne l'est pas lui non plus ????
        """
        if self.parent:
            return self.parent.getGenealogie()
        else:
            return []

    def getListeMcOrdonneeBrute(self, liste, dico):
        """
        Retourne la liste ordonnee (suivant le catalogue) BRUTE des mots-cles
        d'une entite composee dont le chemin complet est donne sous forme
        d'une liste du type :ETAPE + MCFACT ou MCBLOC + ...
        """
        for arg in liste:
            objet_cata = dico[arg]
            dico = objet_cata.entites
        return objet_cata.ordreMC

    def verifExistenceSd(self):
        """
        Verifie que les structures de donnees utilisees dans self existent bien dans le contexte
        avant etape, sinon enleve la reference a ces concepts
        """
        for motcle in self.data:
            motcle.verifExistenceSd()

    def getFr(self):
        """
        Retourne la chaine d'aide contenue dans le catalogue
        en tenant compte de la langue
        """
        try:
            return self.data[0].getFr()
        except:
            return ""

    def normalize(self):
        """
        Retourne l'objet normalise. Une liste est deja normalisee
        """
        return self

    def updateMcGlobal(self):
        """
        Met a jour les mots cles globaux enregistres dans l'etape parente
        et dans le jdc parent.
        Une liste ne peut pas etre globale. Elle se contente de passer
        la requete a ses fils.
        """
        for motcle in self.data:
            motcle.updateMcGlobal()

    def deleteMcGlobal(self):
        for motcle in self.data:
            motcle.deleteMcGlobal()

    # def __del__(self):
    #   print "__del__",self
