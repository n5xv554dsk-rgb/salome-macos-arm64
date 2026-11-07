# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 2007-2026  EDF R&D
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
#
#
# ======================================================================
"""
    Ce module contient la classe ENTITE qui est la classe de base
    de toutes les classes de definition d'EFICAS.
"""
from Accas.processing import P_CR
from Accas.processing import P_OPS

stringTypes = ((str,))


class ENTITE(object):

    """
    Classe de base pour tous les objets de definition : mots cles et commandes
    Cette classe ne contient que des methodes utilitaires
    Elle ne peut être instanciee et doit d abord être specialisee
    """

    CR = P_CR.CR
    from Accas.processing.P_VALIDATOR import validatorFactory
    factories = {"validator": validatorFactory}

    def __init__(self, validators=None):
        """
        Initialise les deux attributs regles et entites d'une classe dérivée
        à : pas de règles et pas de sous-entités.

        L'attribut regles doit contenir la liste des regles qui s'appliquent
        sur ses sous-entités

        L'attribut entités doit contenir le dictionnaires des sous-entités
        (clé = nom, valeur=objet)
        Les attributs utiles pour la projection xsd sont aussi initialises
        init non appele pour bloc
        """
        self.regles = ()
        self.entites = {}
        if validators:
            self.validators = self.factories["validator"](validators)
        else:
            self.validators = validators
        # self.doitSenregistrerComme = None
        self.txtNomComplet = ""
        self.redefinit = False
        self.dejaPrepareDump = False
        self.possedeDejaUnMCFactorise = False

    def affecter_parente(self):
        """
        Cette methode a pour fonction de donner un nom et un pere aux
        sous entités qui n'ont aucun moyen pour atteindre leur parent
        directement
        Il s'agit principalement des mots cles
        """
        for k, v in list(self.entites.items()):
            # print( k,v)
            v.pere = self
            v.nom = k

    def verifCata(self):
        """
        Cette methode sert à valider les attributs de l'objet de définition
        """
        raise NotImplementedError(
            "La méthode verifCata de la classe %s doit être implémentée"
            % self.__class__.__name__
        )

    def __call__(self):
        """
        Cette methode doit retourner un objet dérivé de la classe OBJECT
        """

        raise NotImplementedError(
            "La méthode __call__ de la classe %s doit être implémentée"
            % self.__class__.__name__
        )

    def report(self):
        """
        Cette méthode construit pour tous les objets dérivés de ENTITE un
        rapport de Accas.validation de la définition portée par cet objet
        """
        self.cr = self.CR()
        self.verifCata()
        for k, v in list(self.entites.items()):
            try:
                cr = v.report()
                cr.debut = "Début " + v.__class__.__name__ + " : " + k
                cr.fin = "Fin " + v.__class__.__name__ + " : " + k
                self.cr.add(cr)
            except:
                self.cr.fatal("Impossible d'obtenir le rapport de %s %s" % (k, repr(v)))
                print(("Impossible d'obtenir le rapport de %s %s" % (k, repr(v))))
                print(("père =", self))
        return self.cr

    def verifCataRegles(self):
        """
        Cette méthode vérifie pour tous les objets dérivés de ENTITE que
        les objets REGLES associés ne portent que sur des sous-entités
        existantes
        """
        for regle in self.regles:
            l = []
            for mc in regle.mcs:
                if not mc in self.entites:
                    l.append(mc)
            if l != []:
                txt = str(regle)
                self.cr.fatal(
                    _("Argument(s) non permis : %r pour la règle : %s"), l, txt
                )

    def checkDefinition(self, parent):
        """Verifie la definition d'un objet composite (commande, fact, bloc)."""
        args = self.entites.copy()
        mcs = set()
        for nom, val in list(args.items()):
            if val.label == "SIMP":
                mcs.add(nom)
                # XXX
                # if val.max != 1 and val.type == 'TXM':
                # print "#CMD", parent, nom
            elif val.label == "FACT":
                val.checkDefinition(parent)
                # CALC_SPEC !
                # assert self.label != 'FACT', \
                #'Commande %s : Mot-clef facteur present sous un mot-clef facteur : interdit !' \
                # % parent
            else:
                continue
            del args[nom]
        # seuls les blocs peuvent entrer en conflit avec les mcs du plus haut
        # niveau
        for nom, val in list(args.items()):
            if val.label == "BLOC":
                mcbloc = val.checkDefinition(parent)
                # XXX
                assert mcs.isdisjoint(
                    mcbloc
                ), "Commande %s : Mot(s)-clef(s) vu(s) plusieurs fois : %s" % (
                    parent,
                    tuple(mcs.intersection(mcbloc)),
                )
        return mcs

    def checkOp(self, valmin=-9999, valmax=9999):
        """Vérifie l'attribut op."""
        if self.op is not None and (
            type(self.op) is not int or self.op < valmin or self.op > valmax
        ):
            self.cr.fatal(
                _("L'attribut 'op' doit être un entier " "compris entre %d et %d : %r"),
                valmin,
                valmax,
                self.op,
            )

    def checkProc(self):
        """Vérifie l'attribut proc."""
        if self.proc is not None and not isinstance(self.proc, P_OPS.OPS):
            self.cr.fatal(
                _("L'attribut op doit être une instance d'OPS : %r"), self.proc
            )

    def checkRegles(self):
        """Vérifie l'attribut regles."""
        if type(self.regles) is not tuple:
            self.cr.fatal(_("L'attribut 'regles' doit être un tuple : %r"), self.regles)

    def checkFr(self):
        """Vérifie l'attribut fr."""
        if type(self.fr) not in stringTypes:
            self.cr.fatal(
                _("L'attribut 'fr' doit être une chaine de caractères : %r"), self.fr
            )

    def checkDocu(self):
        """Vérifie l'attribut docu."""
        if type(self.docu) not in stringTypes:
            self.cr.fatal(
                _("L'attribut 'docu' doit être une chaine de caractères : %r"),
                self.docu,
            )

    def checkNom(self):
        """Vérifie l'attribut proc."""
        if type(self.nom) is not str:
            self.cr.fatal(
                _("L'attribut 'nom' doit être une chaine de caractères : %r"), self.nom
            )

    def checkReentrant(self):
        """Vérifie l'attribut reentrant."""
        if self.reentrant not in ("o", "n", "f"):
            self.cr.fatal(
                _("L'attribut 'reentrant' doit valoir 'o','n' ou 'f' : %r"),
                self.reentrant,
            )

    def checkStatut(self, into=("o", "f", "c", "d")):
        """Vérifie l'attribut statut."""
        if self.statut not in into:
            self.cr.fatal(
                _("L'attribut 'statut' doit être parmi %s : %r"), into, self.statut
            )

    def checkCondition(self):
        """Vérifie l'attribut condition."""
        if self.condition != None:
            if type(self.condition) is not str:
                self.cr.fatal(
                    _("L'attribut 'condition' doit être une chaine de caractères : %r"),
                    self.condition,
                )
        else:
            self.cr.fatal(_("La condition ne doit pas valoir None !"))

    def checkMinMax(self):
        """Vérifie les attributs min/max."""
        if type(self.min) != int:
            if self.min != "**" and self.min != float("-inf"):
                self.cr.fatal(_("L'attribut 'min' doit être un entier : %r"), self.min)
        if type(self.max) != int:
            if self.max != "**" and self.max != float("inf"):
                self.cr.fatal(_("L'attribut 'max' doit être un entier : %r"), self.max)
        if self.min > self.max:
            self.cr.fatal(
                _("Nombres d'occurrence min et max invalides : %r %r"),
                self.min,
                self.max,
            )

    def checkValidators(self):
        """Vérifie les validateurs supplémentaires"""
        if self.validators and not self.validators.verifCata():
            self.cr.fatal(
                _("Un des validateurs est incorrect. Raison : %s"),
                self.validators.cata_info,
            )

    def checkHomo(self):
        """Vérifie l'attribut homo."""
        if self.homo != 0 and self.homo != 1:
            self.cr.fatal(_("L'attribut 'homo' doit valoir 0 ou 1 : %r"), self.homo)

    def checkInto(self):
        """Vérifie l'attribut into."""
        if self.into != None:
            if (type(self.into) not in (list, tuple)) and (
                type(self.into) != types.FunctionType
            ):
                self.cr.fatal(_("L'attribut 'into' doit être un tuple ou une fonction : %r"), self.into)

    def checkPosition(self):
        """Vérifie l'attribut position."""
        if self.position not in (
            "local",
            "global",
            "global_jdc",
            "inGetAttribut",
            "reCalculeEtape",
        ):
            self.cr.fatal(
                _(
                    "L'attribut 'position' doit valoir 'local', 'global' ,'global_jdc', 'inGetAttribut', 'reCalculeEtape' "
                    "ou 'global_jdc' : %r"
                ),
                self.position,
            )

    def nomComplet(self):
        if self.txtNomComplet != "":
            return self.txtNomComplet
        qui = self
        while hasattr(qui, "pere"):
            self.txtNomComplet += "_" + qui.nom
            qui = qui.pere
        self.txtNomComplet += "_" + qui.nom
        return self.txtNomComplet

    def geneaCompleteSousFormeDeListe(self):
        geneaCompleteSousFormeDeListe = []
        qui = self
        while hasattr(qui, "pere"):
            geneaCompleteSousFormeDeListe.append(qui)
            qui = qui.pere
        geneaCompleteSousFormeDeListe.append(qui)
        return geneaCompleteSousFormeDeListe

    def addDefinitionMC(self, listeMCAvant, **args):
        ouChercher = self
        for mot in listeMCAvant:
            try:
                ouChercher = ouChercher.entites[mot]
            except:
                print("impossible de trouver : ", mot, " ", listeMCAvant)
        (nomMC, defMC) = args.items()[0]
        defMC.pere = ouChercher
        defMC.pere.propageRedefinit()
        defMC.nom = nomMC
        cata = CONTEXT.getCurrentCata()
        # print (cata)
        ouChercher.entites[nomMC] = defMC

    def changeDefinitionMC(self, listeMCAvant, **args):
        ouChercher = self
        for mot in listeMCAvant:
            try:
                ouChercher = ouChercher.entites[mot]
            except:
                print("impossible de trouver : ", mot, " ", listeMCAvant)
        monSIMP = ouChercher
        for nomAttributDef, valeurAttributDef in args.items():
            if hasattr(monSIMP, nomAttributDef):
                setattr(monSIMP, nomAttributDef, valeurAttributDef)
            else:
                print("pb avec ", nomAttributdef, valeurAttributMC)
        monSIMP.propageRedefinit()

    def propageRedefinit(self):
        # a reflechir
        self.redefinit = True
        # PNPN il faut remonter a l etape

    def makeObjetPourVerifSignature(self, *args, **kwargs):
        etape = self.class_instance(oper=self, args=kwargs)
        etape.MCBuild()
        return etape

    def dumpDBSchema(self, dPrimaryKey, dForeignKey, dElementsRecursifs, dUnique, dKeys, inBloc):
        # ne fonctionne que pour OPER ET PROC
        # methode derivee pour P_SIMP, P_BLOC et P_FACT
        # on admet que si un FACT a une primaryKey, elle existe dans celui-ci
        # ou que il s agit d un motclef frere/oncle place avant
        # dKeys contient les noms des clefs possibles et les types
        if self.label != 'PROC' and self.label != 'OPER' :
           print ('pb avec P_ENTITE non prevu pour', self.nom, self.label)
           return ''
        debug = False
        if debug: print("****** traitement de ", self.nom)
        if debug: print( "dPrimaryKey", dPrimaryKey)
        if debug: print( "dForeignKey", dForeignKey) 
        if debug: print( "dElementsRecursifs", dElementsRecursifs)
        if debug: print( "dUnique", dUnique)
        if debug: print( "dKeys", dKeys)
        texte = ""
        PKDefined = 0
        texteDesFactTables = ""
        texteDesColonnes = ""
        #for mc in dPrimaryKey.values(): dictKey[mc] = None
        texte = "CREATE TABLE IF NOT EXISTS {} (\n".format(self.nom)
        if self.nom in dPrimaryKey :
           if dPrimaryKey[self.nom] not in self.entites.values() :
              # on estime qu on a alors une SERIAL PRIMARY KEY,
              texte += "\t{} SERIAL PRIMARY KEY,\n".format(dPrimaryKey[self.nom])
              dKeys[dPrimaryKey[self.nom]] = 'INT NOT NULL'
              PKDefined = 1
        for mc in self.entites.values():
            if mc.label == "SIMP":
                texteDesColonnes = mc.dumpDBSchema(inBloc)
            elif mc.label == "FACT" and  mc.nom in dElementsRecursifs:
                texteDesColonnes += mc.dumpDBSchema( dPrimaryKey, dForeignKey, dElementsRecursifs, dKeys, inBloc)
            else:
                t1, t2 = mc.dumpDBSchema( dPrimaryKey, dForeignKey, dElementsRecursifs, dUnique, dKeys, inBloc)
                texteDesColonnes += t1
                texteDesFactTables += t2
        texte += texteDesColonnes
        if self.nom in dPrimaryKey and not PKDefined :
            texte += "\tPRIMARY KEY ({}),\n".format(dPrimaryKey[self.nom])
        if self.nom in dUnique:
            texteUnique = "\tCONSTRAINT UC_{} UNIQUE {},\n".format(self.nom, str(dUnique[self.nom]).replace ("'",""))
            texteUnique = texteUnique.replace("'","")
            texte += texteUnique
        # on enleve la dernier ','
        texte = texte[0:-2]
        texte += "\n);\n"
        if debug  : print (texte)
        if debug  : print (texteDesFactTables)
        if self.nom not in dPrimaryKey and self.nom not in dForeignKey: 
        # alors ce n est pas une table
           texte = texteDesFactTables
        else : 
           texte += texteDesFactTables
        return texte

    def chercheDefinition(self,nomChamp):
        listeDefinition = []
        for mc in self.entites.values():
            if mc.nom == nomChamp : listeDefinition.append(mc)
        return listeDefinition

    def dumpGitStringFormat(self):
        texte = ""
        if self.label == "SIMP":
            texte += "<ns1:{}>".format(self.nom)
            texte += "%{}".format(self.fr)
            texte += "</ns1:{}>".format(self.nom)
        else:
            if self.label == "FACT":
                texte += "<ns1:{}>".format(self.nom)
            for c in self.entites.values():
                texte += c.dumpGitStringFormat()
            if self.label == "FACT":
                texte += "</ns1:{}>".format(self.nom)
        return texte

    def dumpStructure(self, depth=0 ):
        indent = "  " * depth
        texte = f"{indent}{self.label}: {self.nom}\n"
        if self.label == "SIMP": return texte
        if self.label == "BLOC": texte += " " + self.condition
        if self.label == "OPER": texte + " " + str(self.sd_prod) + "\n"
        for c in self.entites.values():
            texte += c.dumpStructure(depth + 1)
        return texte

