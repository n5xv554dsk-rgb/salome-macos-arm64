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
Ce module contient la classe PARAMETRE_EVAL qui sert a definir
des objets parametres qui sont comprehensibles et donc affichables
par EFICAS.
Ces objets sont crees a partir de la modification du fichier de commandes
de l'utilisateur par le parseur de fichiers Python
"""
# import de modules Python
import types, re
import traceback

# import modules Eficas
from . import interpreteur_formule
from Accas.processing.P_CR import CR
from Accas.extensions.eficas_translation import tr
from . import parametre

pattern_eval = re.compile(r"^(EVAL)([ \t\r\f\v]*)\(([\w\W]*)")


class PARAMETRE_EVAL(parametre.PARAMETRE):
    """
    Cette classe permet de creer des objets de type PARAMETRE_EVAL
    cad des affectations directes evaluees dans le jeu de commandes (ex: a=EVAL('''10.*SQRT(25)'''))
    qui sont interpretees par le parseur de fichiers Python.
    Les objets ainsi crees constituent des parametres evalues pour le jdc
    """

    nature = "PARAMETRE_EVAL"
    idracine = "param_eval"

    def __init__(self, nom, valeur=None):
        # parent ne peut etre qu'un objet de type JDC
        import Accas

        self.Accas_EVAL = Accas.EVAL
        self.valeur = self.interpreteValeur(valeur)
        self.val = valeur
        self.nom = nom
        self.jdc = self.parent = CONTEXT.getCurrentStep()
        self.definition = self
        self.niveau = self.parent.niveau
        self.actif = 1
        self.state = "undetermined"
        # Ceci est-il indispensable ???
        # self.appel = P_utils.calleeWhere(niveau=2)
        self.register()

    def __repr__(self):
        """
        Donne un echo de self sous la forme nom = valeur
        """
        return self.nom + " = " + repr(self.valeur)

    def __str__(self):
        """
        Retourne le nom du parametre evalue comme representation de self
        """
        return self.nom

    def interpreteValeur(self, val):
        """
        Essaie d'interpreter val (chaine de caracteres ou None) comme :
        une instance de Accas.EVAL
        Retourne la valeur interpretee
        """
        if not val:
            return None
        d = {}
        val = val.strip()
        if val[-1] == ";":
            val = val[0:-1]
        d["EVAL"] = self.Accas_EVAL
        try:
            valeur = eval(val, {}, d)
            return valeur
        except:
            traceback.print_exc()
            print(("Le texte %s n'est pas celui d'un parametre evalue" % val))
            return None

    def setValeur(self, new_valeur):
        """
        Remplace la valeur de self par new_valeur interpretee.
        """
        self.valeur = self.interpreteValeur(new_valeur)
        self.val = new_valeur
        self.initModif()

    def getNom(self):
        """
        Retourne le nom du parametre
        """
        return self.nom

    def getValeur(self):
        """
        Retourne la valeur de self, cad le texte de l'objet class_eval.EVAL
        """
        if self.valeur:
            return self.valeur.valeur
        else:
            return ""

    def verifEval(self, exp_eval=None, cr="non"):
        """
        Cette methode a pour but de verifier si l'expression EVAL
        est syntaxiquement correcte.
        Retourne :
            - un booleen, qui vaut 1 si licite, 0 sinon
            - un message d'erreurs ('' si illicite)
        """
        if not exp_eval:
            if self.valeur:
                exp_eval = self.valeur.valeur[3:-3]  # on enleve les triples guillemets
            else:
                exp_eval = None
        if exp_eval:
            # on construit un interpreteur de formule
            formule = (self.nom, "", None, exp_eval)
            # on recupere la liste des constantes et des autres fonctions predefinies
            # et qui peuvent etre utilisees dans le corps de la formule courante
            l_ctes, l_form = self.jdc.getParametresFonctionsAvantEtape(self)
            # on cree un objet verificateur
            verificateur = interpreteur_formule.Interpreteur_Formule(
                formule=formule, constantes=l_ctes, fonctions=l_form
            )
            if cr == "oui":
                if not verificateur.cr.estvide():
                    self.cr.fatal(verificateur.cr.getMessFatal())
            return verificateur.isValid(), "".join(verificateur.cr.crfatal)
        else:
            # pas d'expression EVAL --> self non valide
            if cr == "oui":
                self.cr.fatal(tr("Le parametre EVAL %s ne peut valoir None"), self.nom)
            return 0, tr("Le parametre EVAL ne peut valoir None")

    def verifNom(self, nom=None, cr="non"):
        """
        Verifie si le nom passe en argument (si aucun prend le nom courant)
        est un nom valide pour un parametre EVAL
        Retourne :
            - un booleen, qui vaut 1 si nom licite, 0 sinon
            - un message d'erreurs ('' si illicite)
        """
        if not nom:
            nom = self.nom
        if nom == "":
            if cr == "oui":
                self.cr.fatal(tr("Pas de nom donne au parametre EVAL"))
            return 0, "Pas de nom donne au parametre EVAL"
        if len(nom) > 8:
            if cr == "oui":
                self.cr.fatal(tr("Un nom de parametre ne peut depasser 8 caracteres"))
            return 0, "Un nom de parametre ne peut depasser 8 caracteres"
        sd = self.parent.getSdAutourEtape(nom, self)
        if sd:
            if cr == "oui":
                self.cr.fatal(tr("Un concept de nom %s existe deja !"), nom)
            return 0, "Un concept de nom %s existe deja !" % nom
        return 1, ""

    def verifParametreEval(self, param=None, cr="non"):
        """
        Verifie la validite du parametre EVAL passe en argument.
        Ce nouveau parametre est passe sous la forme d'un tuple : (nom,valeur)
        Si aucun tuple passe, prend les valeurs courantes de l'objet
        Retourne :
                - un booleen, qui vaut 1 si EVAL licite, 0 sinon
                - un message d'erreurs ('' si illicite)
        """
        if not param:
            if self.valeur:
                param = (self.nom, self.valeur.valeur)
            else:
                param = (self.nom, None)
        test_nom, erreur_nom = self.verifNom(param[0], cr=cr)
        test_eval, erreur_eval = self.verifEval(param[1], cr=cr)
        # test global = produit des tests partiels
        test = test_nom * test_eval
        # message d'erreurs global = concatenation des messages partiels
        erreur = ""
        if not test:
            for mess in (erreur_nom, erreur_eval):
                erreur = erreur + (len(mess) > 0) * "\n" + mess
        return test, erreur

    def update(self, param):
        """
        Methode externe.
        Met a jour les champs nom, valeur de self
        par les nouvelles valeurs passees dans le tuple formule.
        On stocke les valeurs SANS verifications.
        """
        self.initModif()
        self.setNom(param[0])
        self.setValeur('EVAL("""' + param[1] + '""")')

    def isValid(self, cr="non"):
        """
        Retourne 1 si self est valide, 0 sinon
        Un parametre evalue est considere comme valide si :
          - il a un nom
          - il a une valeur qui est interpretable par l'interpreteur de FORMULEs
        """
        resu, erreur = self.verifParametreEval(cr=cr)
        return resu

    def report(self):
        """
        Genere l'objet rapport (classe CR)
        """
        self.cr = CR()
        self.isValid(cr="oui")
        return self.cr

    def setNom(self, new_nom):
        """
        Remplace le nom de self par new_nom
        """
        self.nom = new_nom
