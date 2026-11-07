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
"""

from Accas.accessor import CONNECTOR
import re

conceptRE = re.compile(r"[a-zA-Z_]\w*$")


class OBJECT:
    from Accas.processing.P_CO import CO
    from Accas.processing.P_ASSD import assd

    def isMCList(self):
        """
        Retourne 1 si self est une MCList (liste de mots-cles), 0 sinon (defaut)
        """
        return 0

    def getRegles(self):
        """
        Retourne les regles de self
        """
        if hasattr(self, "definition"): return self.definition.regles
        elif hasattr(self, "regles"): return self.regles
        else: return []

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
        # pour les objets autres que les commandes, aucun traitement specifique
        # on remonte l'info de fin de modif au parent
        CONNECTOR.Emit(self, "valid")
        if self.parent:
            self.parent.finModif()

    def isRepetable(self):
        """
        Indique si l'objet est repetable
        """
        return 0

    def listeMcPresents(self):
        """
        Retourne la liste des noms des mots cles presents
        """
        return []

    def getDocu(self):
        return self.definition.getDocu()

    def getListeMcInconnus(self):
        """
        Retourne la liste des mots-cles inconnus dans self
        """
        return []

    def verifConditionRegles(self, liste_presents):
        """
        Retourne la liste des mots-cles a rajouter pour satisfaire les regles
        en fonction de la liste des mots-cles presents
        """
        liste = []
        for regle in self.definition.regles:
            liste = regle.verifConditionRegle(liste, liste_presents)
        return liste

    def verifConditionBloc(self):
        """
        Evalue les conditions de tous les blocs fils possibles
        (en fonction du catalogue donc de la definition) de self et
        retourne deux listes :
          - la premiere contient les noms des blocs a rajouter
          - la seconde contient les noms des blocs a supprimer
        """
        return [], []

    def getGenealogiePrecise(self):
        if self.parent:
            l = self.parent.getGenealogiePrecise()
            l.append(self.nom.strip())
            return l
        else:
            return [self.nom.strip()]

    def getMCPath(self):
        if self.parent:
            l = self.parent.getMCPath()
            l.append(self.nom.strip())
            return l
        else:
            # a priori on ne devrait pas passer la
            print("Erreur dans getMCPath de A_OBJECT")
            return [self.nom.strip()]

    def getObjetByMCPath(self, MCPath):
        debug = 0
        if debug:
            print("getObjetByMCPath pour", self, self.nom, MCPath)
        nomFils = MCPath[0]
        if debug:
            print("self", self.nom)
        if debug:
            print("MCPath restant", MCPath[1:])
        if MCPath[1:] == [] or MCPath[1:] == ():
            if debug:
                print("objFils", self.getChildOrChildInBloc(nomFils))
            return self.getChildOrChildInBloc(nomFils)
        else:
            objetFils = self.getChildOrChildInBloc(nomFils)
            if debug:
                print("dans else", self, self.nom, objetFils, nomFils)
            if MCPath[1].startswith("@index "):
                indexObj = MCPath[1].split(" ")[1]
                indexObj = int(indexObj.split(" ")[0])
                if debug:
                    print("index de l objet", indexObj)
                objetFils = objetFils.data[indexObj]
                if debug:
                    print("objetFils cas Mclist", objetFils)
                if MCPath[2:] == [] or MCPath[2:] == ():
                    return objetFils
                else:
                    return objetFils.getObjetByMCPath(MCPath[2:])
            return objetFils.getObjetByMCPath(MCPath[1:])

    def getGenealogie(self):
        """
        Retourne la liste des noms des ascendants (noms de MCSIMP,MCFACT,MCBLOC
        ou ETAPE) de self jusqu'au premier objet etape rencontre
        """
        if self.parent:
            l = self.parent.getGenealogie()
            l.append(self.nom.strip())
            return l
        else:
            return [self.nom.strip()]

    def getFr(self):
        """
        Retourne la chaine d'aide contenue dans le catalogue
        en tenant compte de la langue
        """
        try:
            # if 1 :
            c = getattr(self.definition, self.jdc.lang)
            return c
        except:
            # else:
            try:
                c = getattr(self.definition, "fr")
                return c
            except:
                return ""

    def updateConcept(self, sd):
        pass

    def normalize(self):
        """Retourne l'objet normalise. En general self sauf si
        pour etre insere dans l'objet pere il doit etre
        wrappe dans un autre objet (voir mot cle facteur).
        """
        return self

    def deleteMcGlobal(self):
        return

    def updateMcGlobal(self):
        return

    # def __del__(self):
    #   print "__del__",self

    def nommeSd(self):
        # surcharge dans A_ETAPE.py
        if nom in dir(self.jdc.cata):
            return (0, nom + tr("mot reserve"))
        if not conceptRE.match(nom):
            return 0, tr("Un nom de concept doit etre un identificateur Python")
        self.initModif()
        # self.getSdProd()
        # self.sd.nom = nom
        # self.sdnom=nom
        # self.parent.updateConceptAfterEtape(self,self.sd)
        # self.finModif()
        # return 1, tr("Nommage du concept effectue")

    def deleteRef(self):
        # est surcharge dans  MC_SIMP et dans MC_List
        # print ('je suis dans deleteRef pour', self.nom)
        for obj in self.mcListe:
            obj.deleteRef()

    def supprimeUserAssd(self):
        pass

    def getDicoForFancy(self):
        # print ('OBJECT getDicoForFancy ',self, self.nature)
        monDico = {}
        leNom = self.nom

        if self.nature == "MCFACT":
            leNom = self.getLabelText()
            monDico["statut"] = self.definition.statut
            monDico["nomCommande"] = self.nom

        if self.nature == "MCLIST":
            monDico["validite"] = 0
        elif self.nature == "MCBLOC":
            monDico["validite"] = 0
        else:
            monDico["validite"] = self.getValid()
            if monDico["validite"] == None:
                monDico["validite"] = 0

        if self.nature == "OPERATEUR" or self.nature == "PROCEDURE":
            monDico["statut"] = "f"
        if self.nature == "OPERATEUR":
            if hasattr(self, "sdnom") and self.sdnom != "sansnom":
                monDico["sdnom"] = self.sdnom
            else:
                monDico["sdnom"] = ""
                if monDico["validite"] == 0:
                    monDico["validite"] = 2
        monDico["title"] = leNom
        monDico["key"] = self.idUnique
        monDico["classeAccas"] = self.nature

        listeNodes = []
        # Cas d un fichier vide
        if not hasattr(self, "mcListe"):
           self.mcListe = []
        for obj in self.mcListe:
            lesNodes = obj.getDicoForFancy()
            if not (isinstance(lesNodes, list)):
                listeNodes.append(lesNodes)
            else:
                for leNode in lesNodes:
                    listeNodes.append(leNode)
        monDico["children"] = listeNodes
        #print (self.nature)
        if self.nature != "MCSIMP" and self.nature != "MCLIST" and self.nature != "JDC":
            monDico["infoOptionnels"] = self.calculOptionnelInclutBlocs()
        return monDico

    def getNomClassWeb(self):
        # code mort
        laClasse = self.nature
        if self.isValid():
            laClasse += "Valide"
        else:
            laClasse += "NonValide"
        return laClasse

    def demandeUpdateOptionnels(self):
        CONNECTOR.Emit(self, "demandeUpdateOptionnels")
        for mc in self.mcListe:
            mc.demandeUpdateOptionnels()
    def demandeRedessine(self):
        # print ('demandeRedessine pour', self.nom, self, tout)
        CONNECTOR.Emit(self, "redessine")

    def getIndexDsParent(self):
        return self.parent.mcListe.index(self)


class ErrorObj(OBJECT):
    pass
