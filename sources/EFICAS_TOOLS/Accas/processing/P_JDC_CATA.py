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


"""
    Ce module contient la classe de definition JDC_CATA
    qui permet de spécifier les caractéristiques d'un JDC
"""

import types
import traceback

from Accas.processing import P_ENTITE
from Accas.processing import P_JDC


class JDC_CATA(P_ENTITE.ENTITE):

    """
    Classe pour definir un jeu de commandes

    Attributs de classe :

    - class_instance qui indique la classe qui devra etre utilisée
            pour créer l'objet qui servira à controler la conformité
            du jeu de commandes avec sa définition

    - label qui indique la nature de l'objet de définition (ici, JDC)

    """

    class_instance = P_JDC.JDC
    label = "JDC"

    def __init__( self, code="", execmodul=None, regles=(), niveaux=(),
        fichierSource=None, fr="", ang="", **args
    ):
        """
        on se laisse la possibilite d initier fichierSource avec autre chose que le nom du fichier
        au cas ou ... pour pouvoir changer le nom du 'sous code' implemente (cf readercata)
        """
        self.code = code
        self.fr = fr
        self.ang = ang
        self.execmodul = execmodul
        if type(regles) == tuple: self.regles = regles
        else: self.regles = (regles,)

        # Tous les arguments supplémentaires sont stockés dans l'attribut args
        # et seront passés au JDC pour initialiser ses paramètres propres
        self.args = args
        self.d_niveaux = {}
        self.lNiveaux = niveaux
        self.commandes = []
        self.fichierSource = fichierSource
        for niveau in niveaux:
            self.d_niveaux[niveau.nom] = niveau
        # On change d'objet catalogue. Il faut d'abord mettre le catalogue
        # courant à None
        CONTEXT.unsetCurrentCata()
        CONTEXT.setCurrentCata(self)
        #PN to do verifier pourquoi on y passe 2 fois
        #import traceback
        #traceback.print_stack()
        self.fenetreIhm = None
        self.definitUserASSD = False
        self.definitUserASSDMultiple = False
        self.dictTypesXSD = {}
        self.dictTypesXSDJumeaux = {}
        self.dictTypesASSDorUserASSDCrees = {}
        self.dictTypesASSDorUserASSDUtilises = {}
        self.listeUserASSDDumpes = set()
        self.listeTypeTXMAvecBlancs = set()

    def __call__( self, procedure=None, cata=None, dicoCataOrdonne=None, nom="SansNom",
        parent=None, **args):
        """
        Construit l'objet JDC a partir de sa definition (self),
        """
        return self.class_instance(
            definition=self,
            procedure=procedure,
            cata=cata,
            dicoCataOrdonne=dicoCataOrdonne,
            nom=nom,
            parent=parent,
            **args
        )

    def enregistre(self, commande):
        """
        Methode qui permet aux definitions de commandes de s'enregistrer aupres
        d'un JDC_CATA
        separee en 2 entre Accessor et Processing 
        car a priori commandes n est utilise que pour l ihm mais
        est-ce obsolete ?
        """
        debug = 0 
        if debug : print ('enregistre processing', commande)
        self.commandes.append(commande)

    def verifCata(self):
        """
        Méthode de vérification des attributs de définition
        """
        self.checkRegles()
        self.verifCataRegles()

    def verifCataRegles(self):
        """
        Cette méthode vérifie pour tous les objets stockés dans la liste entités
        respectent les REGLES associés  à self
        """
        # A FAIRE

    def report(self):
        """
        Methode pour produire un compte-rendu de Accas.validation d'un catalogue de commandes
        """
        self.cr = self.CR(
            debut="Compte-rendu de Accas.validation du catalogue " + self.code,
            fin="Fin Compte-rendu de Accas.validation du catalogue " + self.code,
        )
        self.verifCata()
        for commande in self.commandes:
            cr = commande.report()
            cr.debut = "Début Commande :" + commande.nom
            cr.fin = "Fin commande :" + commande.nom
            self.cr.add(cr)
        return self.cr

    def supprime(self):
        """
        Méthode pour supprimer les références arrières susceptibles de provoquer
        des cycles de références
        """
        for commande in self.commandes:
            commande.supprime()

    def getNiveau(self, nom_niveau):
        """
        Retourne l'objet de type NIVEAU de nom nom_niveau
        ou None s'il n'existe pas
        """
        return self.d_niveaux.get(nom_niveau, None)

    def dumpStructure(self):
        texte = ""
        for c in self.commandes:
            if not (c.label != "OPER") and not (c.label != "PROC"): continue
            if c.label == "OPER":
                texte += c.nom + " " + str(c.sd_prod) + "\n"
            if c.label == "PROC":
                texte += c.nom + " \n"
            texte += c.dumpStructure()
        return texte

    def dumpDBSchema(self, databaseName):
        texte = "create database {}; \n".format(databaseName)
        texte += "create user admin_{}; \n".format(databaseName)
        texte += "grant all privileges on database {} to admin_{}; \n".format( databaseName, databaseName)
        texte += "********* fin de creation de la database ********* \n\n"
        texte += "CREATE TABLE IF NOT EXISTS processing (\n"
        texte += "\tscript_name TEXT NOT NULL,\n"
        texte += "\tscript  TEXT NOT NULL,\n"
        texte += "\tversion  TEXT NOT NULL,\n"
        texte += "\tPRIMARY KEY (script_name));\n"
        texte += "CREATE TABLE IF NOT EXISTS created_table (\n"
        texte += "\tscript_name TEXT NOT NULL ,\n"
        texte += "\ttable_name  TEXT NOT NULL,\n"
        texte += "\tCONSTRAINT fk_script_table  FOREIGN KEY (script_name) REFERENCES processing(script_name) ON DELETE CASCADE);\n"
        texte += "********* fin de creation des tables pour sauvegarder les traitements ********* \n\n"
        dPrimaryKey = {}
        dRecursif = {}
        dForeignKey = {}
        dUnique = {}
        if hasattr(self.cata, "dPrimaryKey"):
            dPrimaryKey = self.cata.dPrimaryKey
        if hasattr(self.cata, "dElementsRecursifs"):
            dElementsRecursifs = self.cata.dElementsRecursifs
        if hasattr(self.cata, "dForeignKey"):
            dForeignKey = self.cata.dForeignKey
        if hasattr(self.cata, "dUnique"):
            dUnique = self.cata.dUnique
        for c in self.commandes:
            if not (c.label != "OPER") and not (c.label != "PROC"): continue  # une macro ?
            texte += c.dumpDBSchema(dPrimaryKey, dForeignKey, dElementsRecursifs, dUnique, {}, False)
            #print (texte)
        return texte

    def dumpGitStringFormat(self):
        texte = "git log --pretty=format:'"
        for c in self.commandes:
            if not (c.label != "OPER") and not (c.label != "PROC"):
                continue
            texte += "<ns1:{}>".format(c.nom)
            texte += c.dumpGitStringFormat()
            texte += "</ns1:{}>".format(c.nom)
        texte += "'"
        return texte
