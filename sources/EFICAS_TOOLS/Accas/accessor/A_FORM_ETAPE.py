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
classe pour declarer une formule
tombée en désuétude
Attention :
 1) n est pas projete en XSD
 2) verifier l analyse catalogue
"""
import string, traceback, re

identifier = re.compile(r"^[^\d\W]\w*\Z", re.UNICODE)


from Accas.extensions.eficas_translation import tr
from Accas.accessor.A_MACRO_ETAPE import MACRO_ETAPE
from Accas.extensions import interpreteur_formule
#from Accas.catalog import analyse_catalogue

#analyse_catalogue.l_noms_commandes.append(
#    "FORM"
#)  # declare le nom FORM a l'analyseur de catalogue


class FORM_ETAPE(MACRO_ETAPE):
    interpreteur = interpreteur_formule.Interpreteur_Formule

    def MCBuild(self):
        self.mcListe = self.buildMc()
        # on cree la liste des types autorises (liste des noms de mots-cles
        # simples dans le catalogue de FORMULE)
        self.l_types_autorises = list(self.definition.entites.keys())
        # en plus de la construction traditionnelle des fils de self
        # il faut pour les FORMULE decortiquer l'expression ...
        self.type_retourne, self.arguments, self.corps = self.analyseFormule()

    def analyseFormule(self):
        """
        Cette methode decortique l'expression de la FORMULE.
        Elle retourne 3 valeurs:
            - le type retourne par la FORMULE
            - les arguments de la FORMULE
            - le corps de la FORMULE, cad son expression
        """
        if len(self.mcListe) == 0:
            # pas de fils pour self --> la FORMULE est incomplete
            return None, None, None
        type_retourne = "REEL"
        if len(self.mcListe) > 0:
            child = self.mcListe[0]  # child est un MCSIMP
            corps = child.getVal()
        else:
            corps = None
        if len(self.mcListe) > 1:
            child = self.mcListe[1]
            l_args = child.getVal()
        else:
            l_args = None
        return type_retourne, l_args, corps

    def getNom(self):
        """
        Retourne le nom de la FORMULE, cad le nom de la SD si elle existe,
        la string vide sinon
        """
        if self.sd:
            return self.sd.getName()
        else:
            return ""

    def getFormule(self):
        """
        Retourne un tuple decrivant la formule :
        (nom,type_retourne,arguments,corps)
        """
        t, a, c = self.analyseFormule()
        n = self.getNom()
        return (n, t, a, c)

    def verifArguments(self, arguments=None):
        """
        Verifie si les arguments passes en argument (si aucun prend les arguments courants)
        sont des arguments valide pour une FORMULE.
        Retourne :
            - un booleen, qui vaut 1 si arguments licites, 0 sinon
            - un message d'erreurs ('' si illicites)
        """
        if not arguments:
            arguments = self.arguments
        if not arguments:
            return 0, "Une formule doit avoir au minimum un argument"
        # il faut au prealable enlever les parentheses ouvrantes et fermantes
        # encadrant les arguments
        arguments = string.strip(arguments)
        if arguments[0] != "(":
            return 0, tr(
                "La liste des arguments d'une formule doit etre entre parentheses : parenthese ouvrante manquante"
            )
        if arguments[-1] != ")":
            return 0, tr(
                "La liste des arguments d'une formule doit etre entre parentheses : parenthese fermante manquante"
            )
        # on peut tester la syntaxe de chaque argument maintenant
        erreur = ""
        test = 1
        arguments = arguments[1:-1]  # on enleve les parentheses ouvrante et fermante
        l_arguments = string.split(arguments, ",")
        for a in l_arguments:
            if not re.match(identifier, str(a)):
                return 0, str(a) + " n est pas un identifiant"
        return test, erreur

    def verifCorps(self, corps=None, arguments=None):
        """
        Cette methode a pour but de verifier si le corps de la FORMULE
        est syntaxiquement correct.
        Retourne :
            - un booleen, qui vaut 1 si corps de FORMULE licite, 0 sinon
            - un message d'erreurs ('' si illicite)
        """
        if not corps:
            corps = self.corps
        if not arguments:
            arguments = self.arguments
        formule = (self.getNom(), self.type_retourne, arguments, corps)
        # on recupere la liste des constantes et des autres fonctions predefinies
        # et qui peuvent etre utilisees dans le corps de la formule courante
        l_ctes, l_form = self.jdc.getParametresFonctionsAvantEtape(self)
        # on cree un objet verificateur
        try:
            verificateur = self.interpreteur(
                formule=formule, constantes=l_ctes, fonctions=l_form
            )
        except:
            traceback.print_exc()
            return 0, tr("Impossible de realiser la verification de la formule")
        return verificateur.isValid(), verificateur.report()

    def verifNom(self, nom=None):
        """
        Verifie si le nom passe en argument (si aucun prend le nom courant)
        est un nom valide pour une FORMULE.
        Retourne :
            - un booleen, qui vaut 1 si nom licite, 0 sinon
            - un message d'erreurs ('' si illicite)
        """
        if not nom:
            nom = self.getNom()
        if nom == "":
            return 0, tr("Pas de nom donne a la FORMULE")
        if len(nom) > 8:
            return 0, tr("Un nom de FORMULE ne peut depasser 8 caracteres")
        if nom[0] > "0" and nom[0] < "9":
            return 0, tr("Un nom de FORMULE ne peut pas commencer par un chiffre")
        sd = self.parent.getSdAutourEtape(nom, self)
        if sd:
            return 0, tr("Un concept de nom %s existe deja !" % nom)
        return 1, ""

    def verifType(self, type=None):
        """
        Verifie si le type passe en argument (si aucun prend le type courant)
        est un type valide pour une FORMULE.
        Retourne :
            - un booleen, qui vaut 1 si type licite, 0 sinon
            - un message d'erreurs ('' si illicite)
        """
        if not type:
            type = self.type_retourne
        if not type:
            return 0, tr("Le type de la valeur retournee n'est pas specifie")
        if type not in self.l_types_autorises:
            return 0, tr("Une formule ne peut retourner une valeur de type : %s" % type)
        return 1, ""

    def verifFormule(self, formule=None):
        """
        Verifie la validite de la formule passee en argument.
        Cette nouvelle formule est passee sous la forme d'un tuple : (nom,type_retourne,arguments,corps)
        Si aucune formule passee, prend les valeurs courantes de la formule
        Retourne :
            - un booleen, qui vaut 1 si formule licite, 0 sinon
            - un message d'erreurs ('' si illicite)
        """
        if not formule:
            formule = (None, None, None, None)
        testNom, erreurNom = self.verifNom(formule[0])
        testType, erreurType = self.verifType(formule[1])
        if formule[2]:
            args = "(" + formule[2] + ")"
        else:
            args = None
        testArguments, erreurArguments = self.verifArguments(args)
        testCorps, erreurCorps = self.verifCorps(corps=formule[3], arguments=args)
        # test global = produit des tests partiels
        test = testNom * testType * testArguments * testCorps
        # message d'erreurs global = concatenation des messages partiels
        erreur = ""
        if not test:
            for mess in (erreurNom, erreurType, erreurArguments, erreurCorps):
                erreur = erreur + (len(mess) > 0) * "\n" + mess
        return test, erreur

    def verifFormule_python(self, formule=None):
        """
        Pour l instant ne fait qu un compile python
        il serait possible d ajouter des tests sur les arguments
        ou le type retourne mais ...
        """
        if not formule:
            formule = (None, None, None, None)
        test_nom, erreur_nom = self.verifNom(formule[0])
        if formule[2]:
            args = "(" + formule[2] + ")"
        else:
            args = None
        test_arguments, erreur_arguments = self.verifArguments(args)
        corps = formule[3]
        erreur_formule = ""
        test_formule = 1
        try:
            compile(corps, "<string>", "eval")
        except:
            erreur_formule = (
                "le corps de la formule n'est pas une formule python valide"
            )
            test_formule = 0
        erreur = ""
        test = test_nom * test_arguments * test_formule
        if not test:
            for mess in (erreur_nom, erreur_arguments, erreur_formule):
                erreur = erreur + (len(mess) > 0) * "\n" + mess
        return test, erreur

    def update(self, formule):
        """
        Methode externe.
        Met a jour les champs nom, type_retourne,arguments et corps de la FORMULE
        par les nouvelles valeurs passees dans le tuple formule.
        On stocke les valeurs SANS verifications.
        """
        self.type_retourne = formule[1]
        self.arguments = "(" + formule[2] + ")"
        self.corps = formule[3]
        # il faut ajouter le mot-cle simple correspondant dans mcListe
        # pour cela on utilise la methode generale buildMc
        # du coup on est oblige de modifier le dictionnaire valeur de self ...
        self.valeur = {}
        self.valeur[self.type_retourne] = self.arguments + " = " + self.corps
        self.MCBuild()
        sd = self.getSdProd()
        if sd:
            sd.nom = formule[0]

    # bidouille PN
    # Il faut que formule soit constituee de
    # nom de la formule
    # type retourne
    # parametres
    # corps de la fonction
    # il faut aussi que les arguments soient sous forme de tuple
    def updateFormulePython(self, formule):
        self.buildMc()
        self.mcListe = []
        if len(formule) < 4:
            return 0
        arguments = formule[3]
        if arguments[0] == "(":
            arguments = arguments[1:]
        if arguments[-1] == ")":
            arguments = arguments[:-1]
        self.arguments = tuple(arguments.split(","))

        mocles = {"NOM_PARA": self.arguments}
        if formule[1] == "REEL":
            mocles["VALE"] = formule[2]
        if formule[1] == "COMPLEXE":
            mocles["VALE_C"] = formule[2]

        for k, v in self.definition.entites.items():
            if not k in mocles:
                continue
            child = self.definition.entites[k](None, nom=k, parent=self)
            child.valeur = mocles[k]
            child.state = "modified"
            self.mcListe.append(child)

        self.corps = formule[2]
        self.type_retourne = formule[1]
        sd = self.getSdProd()
        if sd:
            sd.nom = formule[0]
        self.initModif()
        return 1

    def active(self):
        """
        Rend l'etape courante active.
        Il faut ajouter la formule au contexte global du JDC
        """
        self.actif = 1
        self.initModif()
        nom = self.getNom()
        if nom == "":
            return
        try:
            self.jdc.appendFonction(self.sd)
        except:
            pass

    def inactive(self):
        """
        Rend l'etape courante inactive
        Il faut supprimer la formule du contexte global du JDC
        """
        self.actif = 0
        self.initModif()
        if not self.sd:
            return
        self.jdc.delFonction(self.sd)

    def updateConcept(self, sd):
        return

    def deleteConcept(self, sd):
        """
        Inputs :
          - sd=concept detruit
        Fonction :
        Mettre a jour les mots cles de l etape et eventuellement le concept produit si reuse
        suite a la disparition du concept sd
        Seuls les mots cles simples MCSIMP font un traitement autre que de transmettre aux fils,
        sauf les objets FORM_ETAPE qui doivent verifier que le concept detruit n'est pas
        utilise dans le corps de la fonction
        """
        self.initModif()

    def replaceConcept(self, old_sd, sd):
        """
        Inputs :
          - old_sd=concept remplace
          - sd = nouveau concept
        Fonction :
        Les objets FORM_ETAPE devraient verifier que le concept remplace n'est pas
        utilise dans le corps de la fonction
        """
        self.initModif()
