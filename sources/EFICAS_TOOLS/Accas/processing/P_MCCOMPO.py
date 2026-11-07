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
    Ce module contient la classe MCCOMPO qui sert à factoriser les comportements
    des OBJECT composites
"""

from copy import copy
from Accas.processing import P_OBJECT


class MCCOMPO(P_OBJECT.OBJECT):
    """
    Classe support d'un OBJECT composite

    """

    def buildMc(self):
        """
        Construit la liste des sous-entites du MCCOMPO
        à partir du dictionnaire des arguments (valeur)
        """

        # import traceback
        # traceback.print_stack()
        # print(("MCCOMPO.buildMc _____________________________________", self.nom))
        if CONTEXT.debug:
            print(("MCCOMPO.buildMc ", self.nom))
        # Dans la phase de reconstruction args peut contenir des mots-clés
        # qui ne sont pas dans le dictionnaire des entites de definition (self.definition.entites)
        # de l'objet courant (self)
        # mais qui sont malgré tout des descendants de l'objet courant
        # (petits-fils, ...)
        args = self.valeur
        # print ('MCCOMPO___________________', self.valeur)
        if args == None:
            args = {}
        mcListe = []

        # On recopie le dictionnaire des arguments pour protéger l'original des
        # delete (del args[k])
        args = args.copy()

        # Phase 1:
        # On construit les sous entites presentes ou obligatoires
        # 1- les entites présentes dans les arguments et dans la définition
        # 2- les entités non présentes dans les arguments, présentes dans la définition avec un défaut
        # Phase 1.1 : on traite d'abord les SIMP pour enregistrer les mots cles
        # globaux
        if not hasattr(self, "dicoPyxbDeConstruction"):
            self.dicoPyxbDeConstruction = {}
        for k, v in list(self.definition.entites.items()):
            if v.label != "SIMP":
                continue
            if k in args or v.statut in ("o", "d"):
                #
                # Creation par appel de la methode __call__ de la definition de la sous entite k de self
                # si une valeur existe dans args ou est obligatoire (generique si toutes les
                # entites ont l attribut statut )
                #
                if self.dicoPyxbDeConstruction and k in self.dicoPyxbDeConstruction:
                    objPyxbDeConstruction = self.dicoPyxbDeConstruction[k]
                    del self.dicoPyxbDeConstruction[k]
                else:
                    objPyxbDeConstruction = None
                # print (args.get(k, None))
                objet = v(
                    val=args.get(k, None),
                    nom=k,
                    parent=self,
                    objPyxbDeConstruction=objPyxbDeConstruction,
                )
                mcListe.append(objet)
                # Si l'objet a une position globale on l'ajoute aux listes
                # correspondantes
                if hasattr(objet.definition, "position"):
                    if objet.definition.position == "global":
                        self.append_mc_global(objet)
                    if objet.definition.position == "reCalculeEtape":
                        # print ('-------------------------- rencontre reCalculeEtape: ', objet.nom)
                        self.append_mc_global_avecRecalcule(objet)
                    elif objet.definition.position == "global_jdc":
                        self.append_mc_global_jdc(objet)
            if k in args:
                del args[k]

        # Phase 1.2 : on traite les autres entites que SIMP
        # FACT ou listeDeFAct en fait car un BLOC ne peut etre present dans les args
        for k, v in list(self.definition.entites.items()):
            if v.label == "SIMP":
                continue
            if k in args or v.statut == "o":
                # print ('construit', k)
                #
                # Creation par appel de la methode __call__ de la definition de la sous entite k de self
                # si une valeur existe dans args ou est obligatoire (generique si toutes les
                # entites ont l attribut statut )
                #
                if self.dicoPyxbDeConstruction and k in self.dicoPyxbDeConstruction:
                    dicoPyxbDeConstruction = self.dicoPyxbDeConstruction[k]
                    del self.dicoPyxbDeConstruction[k]
                else:
                    dicoPyxbDeConstruction = None
                objet = v(
                    val=args.get(k, None),
                    nom=k,
                    parent=self,
                    dicoPyxbDeConstruction=dicoPyxbDeConstruction,
                )
                mcListe.append(objet)
            if k in args:
                del args[k]

        # Phase 2:
        # On construit les objets (en général, blocs) conditionnés par les mots-clés précédemment créés.
        # A ce stade, mcListe ne contient que les fils de l'objet courant
        # args ne contient plus que des mots-clés qui n'ont pas été attribués car ils sont
        #      à attribuer à des blocs du niveau inférieur ou bien sont des mots-clés erronés
        for k, v in list(self.definition.entites.items()):
            if v.label != "BLOC":
                continue
            # PNPN on recalcule dico_valeurs dans le for
            # pour les globaux imbriques (exple Telemac Advection)
            # avant le calcul etait avant le for
            dico_valeurs = self.creeDictCondition(mcListe, condition=1)
            globs = self.jdc and self.jdc.condition_context or {}
            if v.verifPresence(dico_valeurs, globs):
                # print ('appel construit bloc', k, 'avec', args, 'a partir de', self.nom )
                # Si le bloc existe :
                #        1- on le construit
                #        2- on l'ajoute à mcListe
                #        3- on récupère les arguments restant
                # 4- on reconstruit le dictionnaire équivalent à mcListe
                bloc = v(
                    nom=k,
                    val=args,
                    parent=self,
                    dicoPyxbDeConstruction=self.dicoPyxbDeConstruction,
                )
                mcListe.append(bloc)
                args = bloc.reste_val
                # print ('les args deviennent ', args)
                # On ne recalcule pas le contexte car on ne tient pas compte des blocs
                # pour évaluer les conditions de présence des blocs
                # dico_valeurs = self.creeDictValeurs(mcListe)

        # On conserve les arguments superflus dans l'attribut reste_val
        # les reste_val des blocs  vont contenir trop de MC
        # car ils sont appeles avec tous les MC de leur niveau qui n ont pas ete consommes
        # et le reste_val n est pas remis a jour
        # est-ce un pb ? a priori non
        self.reste_val = args
        # print ('self.reste_val de ', self.nom, self.reste_val)
        # On ordonne la liste ainsi créée suivant l'ordre du catalogue
        # (utile seulement pour IHM graphique)
        mcListe = self.ordonneListe(mcListe)
        # on retourne la liste ainsi construite
        if self.jdc:
            self.cata = self.jdc.cata
        else:
            self.cata = None
        self.buildObjPyxb(mcListe)
        # print ('______________________________________ fin ', self.nom)
        return mcListe

    def buildMcApresGlobalEnSuppression(self):
        blocsDejaLa = []
        for mc in self.mcListe:
            if mc.nature == "MCBLOC":
                blocsDejaLa.append(mc)
        for mc in blocsDejaLa:
            dico_valeurs = self.creeDictCondition(self.mcListe, condition=1)
            globs = self.jdc and self.jdc.condition_context or {}
            defBloc = mc.definition
            if not (defBloc.verifPresence(dico_valeurs, globs)):
                self.suppEntite(mc)

    def reConstruitResteVal(self):
        # normal que apres buildMcApresGlobalEnCreation les reste_val ne soient pas corrects
        for mc in self.mcListe:
            if mc.nom in self.reste_val:
                del self.reste_val[mc.nom]
            if mc.nature == "MCBLOC":
                ancetre = mc.parent
                for mcFDuMc in mc.mcListe:
                    while ancetre.nature == "MCBLOC":
                        ancetre = ancetre.parent
                        if mcFDuMc.nom in ancetre.reste_val:
                            del ancetre.reste_val[mcFDuMc.nom]
            if mc.nature == "MCSIMP":
                continue
            if mc.nature == "MCList":
                for mcObj in mc.data:
                    mcObj.reConstruitResteVal()
            else:
                mc.reConstruitResteVal()

    def buildMcApresGlobalEnCreation(self):
        nouveau_args = self.reste_val
        blocsDejaLa = []
        for mc in self.mcListe:
            if mc.nature == "MCBLOC":
                blocsDejaLa.append(mc.nom)
        for k, v in list(self.definition.entites.items()):
            if v.label != "BLOC":
                continue
            if k in blocsDejaLa:
                continue
            dico_valeurs = self.creeDictCondition(self.mcListe, condition=1)
            globs = self.jdc and self.jdc.condition_context or {}
            if v.verifPresence(dico_valeurs, globs):
                bloc = v(
                    nom=k,
                    val=nouveau_args,
                    parent=self,
                    dicoPyxbDeConstruction=self.dicoPyxbDeConstruction,
                )
                if bloc:
                    self.mcListe.append(bloc)
                    bloc.addObjPyxb(self.chercheIndiceDsLeContenu(bloc))
                    nouveau_args = self.reste_val
                    self.reste_val = bloc.reste_val

    def ordonneListe(self, mcListe):
        """
        Ordonne la liste suivant l'ordre du catalogue.
        Seulement pour IHM graphique
        """
        if self.jdc and self.jdc.dicoCataOrdonne != None:
            liste_noms_mc_ordonnee = self.getListeMcOrdonneeBrute(
                self.getGenealogie(), self.jdc.dicoCataOrdonne
            )
            return self.ordonneListeMc(mcListe, liste_noms_mc_ordonnee)
        else:
            return mcListe

    def creeDictValeurs(self, liste=[], condition=0):
        """
        Cette méthode crée un contexte (sous la forme d'un dictionnaire)
        à partir des valeurs des mots clés contenus dans l'argument liste.
        L'opération consiste à parcourir la liste (d'OBJECT) et à la
        transformer en un dictionnaire dont les clés sont les noms des
        mots clés et les valeurs dépendent du type d'OBJECT.
        Ce dictionnaire servira de liste d'arguments d'appel pour les
        fonctions sd_prod de commandes et ops de macros ou de contexte
        d'évaluation des conditions de présence de BLOC.

        Si l'argument condition de la méthode vaut 1, on ne
        remonte pas les valeurs des mots clés contenus dans des blocs
        pour eviter les bouclages.

        Cette méthode réalise les opérations suivantes en plus de transformer
        la liste en dictionnaire :

           - ajouter tous les mots-clés non présents avec la valeur None
           - ajouter tous les mots-clés globaux (attribut position = 'global'
             et 'global_jdc')

        L'argument liste est, en général, une mcListe en cours de
        construction, contenant les mots-clés locaux et les blocs déjà créés.

        """
        dico = {}
        for v in liste:
            if v.isBLOC():
                # Si v est un BLOC, on inclut ses items dans le dictionnaire
                # représentatif du contexte. Les blocs sont retournés par getValeur
                # sous la forme d'un dictionnaire : les mots-clés fils de blocs sont
                # donc remontés au niveau du contexte.
                if not condition:
                    dadd = v.getValeur()
                    assert intersection_vide(dico, dadd)
                    dico.update(dadd)
            else:
                assert not v.nom in dico, "deja vu : %s" % v.nom
                dico[v.nom] = v.getValeur()

        # On rajoute tous les autres mots-clés locaux possibles avec la valeur
        # par défaut ou None
        # Pour les mots-clés facteurs, on ne traite que ceux avec statut défaut ('d')
        # et caché ('c')
        # On n'ajoute aucune information sur les blocs. Ils n'ont pas de défaut seulement
        # une condition.
        # XXX remplacer le not has_key par un dico différent et faire dico2.update(dico)
        #    ce n'est qu'un pb de perf
        for k, v in list(self.definition.entites.items()):
            if not k in dico:
                if v.label == "SIMP":
                    # Mot clé simple
                    dico[k] = v.defaut
                elif v.label == "FACT":
                    if v.statut in ("c", "d"):
                        # Mot clé facteur avec défaut ou caché provisoire
                        dico[k] = v(val=None, nom=k, parent=self)
                        # On demande la suppression des pointeurs arrieres
                        # pour briser les eventuels cycles
                        dico[k].supprime()
                    else:
                        dico[k] = None
        # A ce stade on a rajouté tous les mots-clés locaux possibles (fils directs) avec leur
        # valeur par défaut ou la valeur None

        # On rajoute les mots-clés globaux sans écraser les clés existantes
        dico_mc = self.rechercheMcGlobaux()
        dico_mc.update(dico)
        dico = dico_mc

        return dico

    def creeDictToutesValeurs(self):
        """Semblable à `creeDictValeurs(liste=self.mcListe)` en supprimant les
        valeurs None."""
        dico = self.creeDictValeurs(self.mcListe, condition=0)
        dico = dict([(k, v) for k, v in list(dico.items()) if v is not None])
        return dico

    def creeDictCondition(self, liste=[], condition=0):
        """
        Methode pour construire un contexte qui servira dans l'évaluation
        des conditions de présence de blocs. Si une commande a un concept
        produit réutilisé, on ajoute la clé 'reuse'
        """
        dico = self.creeDictValeurs(liste, condition=1)
        # On ajoute la cle "reuse" pour les MCCOMPO qui ont un attribut reuse. A destination
        # uniquement des commandes. Ne devrait pas etre dans cette classe mais
        # dans une classe dérivée
        if not "reuse" in dico and hasattr(self, "reuse"):
            dico["reuse"] = self.reuse
        return dico

    def rechercheMcGlobaux(self):
        """
        Retourne la liste des mots-clés globaux de l'étape à laquelle appartient self
        et des mots-clés globaux du jdc
        """
        etape = self.getEtape()
        if etape:
            dict_mc_globaux_fac = self.rechercheMcGlobauxFacultatifs()
            for k, v in list(etape.mc_globaux.items()):
                dict_mc_globaux_fac[k] = v.getValeur()
            if self.jdc:
                for k, v in list(self.jdc.mc_globaux.items()):
                    dict_mc_globaux_fac[k] = v.getValeur()
            return dict_mc_globaux_fac
        else:
            return {}

    def rechercheMcGlobauxFacultatifs(self):
        """
        Cette méthode interroge la définition de self et retourne la liste des mots-clés fils
        directs de self de type 'global'.
        position='global' n'est donc possible (et n'a de sens) qu'au plus haut niveau.
        du coup ici on ajoute les globaux de l etape qui sont dans mc_recalculeEtape
        """
        # print ('je passe par ici', self.nom)
        dico = {}
        etape = self.getEtape()
        if not etape:
            return {}
        for k, v in list(etape.definition.entites.items()):
            if v.label != "SIMP": continue
            if v.position == "local": continue
            if v.position == "inGetAttribut": continue
            if v.position == "reCalculeEtape": continue
            if v.statut == "o": continue
            obj = v(val=None, nom=k, parent=etape)
            dico[k] = obj.getValeur()
        return dico

    def revalide(self, definition):
        for v in self.mcListe:
            if v.nature == "MCSIMP" :
                if v.definition == definition: 
                    v.revalide()
            else : v.revalide(definition)    

 
    def supprime(self):
        """
        Méthode qui supprime toutes les références arrières afin que l'objet puisse
        etre correctement détruit par le garbage collector
        """
        P_OBJECT.OBJECT.supprime(self)
        for child in self.mcListe:
            child.supprime()

    def __getitem__(self, key):
        """
        Cette méthode retourne la valeur d'un sous mot-clé (key)
        """
        return self.getMocle(key)

    def getMocle(self, key):
        """
        Retourne la valeur du sous mot-clé key
        Ce sous mot-clé peut exister, avoir une valeur par defaut ou etre
        dans un BLOC fils de self
        """
        # on cherche dans les mots cles presents, le mot cle de nom key
        # s'il est là on retourne sa valeur (méthode getVal)
        for child in self.mcListe:
            if child.nom == key:
                return child.getValeur()
        #  Si on n a pas trouve de mot cle present on retourne le defaut
        #  eventuel pour les mots cles accessibles dans la definition
        #  a ce niveau
        try:
            d = self.definition.entites[key]
            if d.label == "SIMP":
                return d.defaut
            elif d.label == "FACT":
                # il faut construire les objets necessaires pour
                # evaluer les conditions des blocs eventuels (a faire)
                if d.statut == "o":
                    return None
                if d.statut != "c" and d.statut != "d":
                    return None
                else:
                    return d(val=None, nom=key, parent=self)
        except KeyError:
            # le mot cle n est pas defini a ce niveau
            pass
        #  Si on a toujours rien trouve, on cherche dans les blocs presents
        #  On suppose que tous les blocs possibles ont ete crees meme ceux
        #  induits par un mot cle simple absent avec defaut (???)
        for mc in self.mcListe:
            if not mc.isBLOC():
                continue
            try:
                return mc.getMocle(key)
            except:
                # On n a rien trouve dans ce bloc, on passe au suivant
                pass
        #  On a rien trouve, le mot cle est absent.
        #  On leve une exception
        raise IndexError("Le mot cle %s n existe pas dans %s" % (key, self))

    def getChild(self, name, restreint="non"):
        """
        Retourne le fils de self de nom name ou None s'il n'existe pas
        Si restreint vaut oui : ne regarde que dans la mcListe
        Si restreint vaut non : regarde aussi dans les entites possibles
        avec defaut (Ce dernier cas n'est utilisé que dans le catalogue)
        """
        for v in self.mcListe:
            if v.nom == name:
                return v
        if restreint == "non":
            try:
                entite = self.definition.entites[name]
                if entite.label == "SIMP" or (
                    entite.label == "FACT" and entite.statut in ("c", "d")
                ):
                    return entite(None, name, None)
            except:
                pass

        return None

    def getChildOrChildInBloc(self, name, restreint="non"):
        # cherche dans les fils et les fils des blocs
        # tout est base sur le fait que deux freres ne peuvent pas avoir le meme nom
        # dans des blocs non exclusifs, sinon le .comm n est pas du python valide
        for v in self.mcListe:
            if v.nom == name:
                return v
        if restreint == "non":
            try:
                entite = self.definition.entites[name]
                if entite.label == "SIMP" or (
                    entite.label == "FACT" and entite.statut in ("c", "d")
                ):
                    return entite(None, name, None)
            except:
                pass
        for v in self.mcListe:
            if v.nature == "MCBLOC":
                petitFils = v.getChildOrChildInBloc(name, restreint)
                if petitFils != None:
                    return petitFils
        return None

    def append_mc_global_avecRecalcule(self, mc):
        etape = self.getEtape()
        if etape:
            nom = mc.nom
            if not (nom in etape.mc_globaux):
                etape.doitEtreRecalculee = True
            etape.mc_globaux[nom] = mc
            # print ('ajout de nom', mc.nom, 'ds les mc_globaux de', etape.nom)

    def append_mc_global(self, mc):
        """
        Ajoute le mot-clé mc à la liste des mots-clés globaux de l'étape
        """
        etape = self.getEtape()
        if etape:
            nom = mc.nom
            etape.mc_globaux[nom] = mc

    def append_mc_global_jdc(self, mc):
        """
        Ajoute le mot-clé mc à la liste des mots-clés globaux du jdc
        """
        nom = mc.nom
        self.jdc.mc_globaux[nom] = mc

    def copy(self):
        """Retourne une copie de self"""
        objet = self.makeobjet()
        # attention !!! avec makeobjet, objet a le meme parent que self
        # ce qui n'est pas du tout bon dans le cas d'une copie !!!!!!!
        # le pb c'est qu'on vérifie ensuite quel parent avait l'objet
        # Il me semble preferable de changer le parent a la fin quand la copie
        # est acceptee
        objet.valeur = copy(self.valeur)
        objet.val = copy(self.val)
        objet.mcListe = []
        for obj in self.mcListe:
            new_obj = obj.copy()
            new_obj.reparent(objet)
            objet.mcListe.append(new_obj)
        return objet

    def reparent(self, parent):
        """
        Cette methode sert a reinitialiser la parente de l'objet
        """
        self.parent = parent
        self.jdc = parent.getJdcRoot()
        self.etape = parent.etape
        for mocle in self.mcListe:
            mocle.reparent(self)

    def getSd_utilisees(self):
        """
        Retourne la liste des concepts qui sont utilisés à l'intérieur de self
        ( comme valorisation d'un MCS)
        """
        l = []
        for child in self.mcListe:
            l.extend(child.getSd_utilisees())
        return l

    def getSdMCSUtilisees(self):
        """
        Retourne la ou les SD utilisée par self sous forme d'un dictionnaire :
          - Si aucune sd n'est utilisée, le dictionnaire est vide.
          - Sinon, les clés du dictionnaire sont les mots-clés derrière lesquels on
            trouve des sd ; la valeur est la liste des sd attenante.
            Exemple ::

              { 'VALE_F': [ <Cata.cata.fonction_sdaster instance at 0x9419854>,
                            <Cata.cata.fonction_sdaster instance at 0x941a204> ],
                'MODELE': [<Cata.cata.modele instance at 0x941550c>] }
        """
        dico = {}
        for child in self.mcListe:
            daux = child.getSdMCSUtilisees()
            for cle in daux:
                dico[cle] = dico.get(cle, [])
                dico[cle].extend(daux[cle])
        return dico

    def getMcsWithCo(self, co):
        """
        Cette methode retourne l'objet MCSIMP fils de self
        qui a le concept co comme valeur.
        En principe, elle ne doit etre utilisee que pour les concepts
        instances de la classe CO
        """
        l = []
        for child in self.mcListe:
            l.extend(child.getMcsWithCo(co))
        return l

    def getAllCo(self):
        """
        Cette methode retourne tous les concepts instances de CO
        """
        l = []
        for child in self.mcListe:
            l.extend(child.getAllCo())
        return l

    # def getSdCreeParObjetAvecFiltre(self,objetAssdMultiple):
    # est-ce que si on est bloc, il faut passer à parent ?
    # ou prevoir une autre fonction qui tienne compte de cela
    # ou prevoir un xpath
    #   classeAChercher = objetAssdMultiple.definition.type
    #   filtre  = objetAssdMultiple.definition.filtre
    #   print ('getSdCreeParObjetAvecFiltre', classeAChercher, filtre)
    #   dicoValeurs = self.creeDictCondition(self.mcListe, condition=1)
    #   l=[]
    #   for k,v in self.jdc.sdsDict.items():
    #      if (isinstance(v, classeAChercher)) :
    #         if v.executeExpression(filtre,dicoValeurs) : l.append(k)
    #   return l


def intersection_vide(dict1, dict2):
    """Verification qu'il n'y a pas de clé commune entre 'dict1' et 'dict2'."""
    sk1 = set(dict1)
    sk2 = set(dict2)
    inter = sk1.intersection(sk2)
    ok = len(inter) == 0
    if not ok:
        print(("ERREUR: Mot(s)-clef(s) vu(s) plusieurs fois :", tuple(inter)))
    return ok
