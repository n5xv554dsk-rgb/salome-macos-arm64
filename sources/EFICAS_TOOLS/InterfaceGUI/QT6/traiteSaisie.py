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

import types
from Accas.extensions.eficas_translation import tr

#--------------------------
class SaisieValeur(object):
#--------------------------
    """
    Classe contenant les methodes communes aux  panels
    permettant de choisir des valeurs
    """

    def valeurChanged(self,valeur=None):
    #-----------------------------------
    # pour la partie Web
        debug=0
        if debug :  print('valeurChanged', valeur, type(valeur))
        nouvelleValeurFormat=self.politique.getValeurTexte(nouvelleValeur)
        validite,commentaire=self.politique.recordValeur(nouvelleValeurFormat)
        if commentaire != "" :
            if validite : self.editor.afficheCommentaire(commentaire)
            else        : self.editor.afficheMessageQt(commentaire,'red')
        self.inSaisieValeur=False
        self.setValide()


    def LEvaleurPressed(self, valeur=None):
    #---------------------------------------
    # pour la partie Qt
        debug=0
        if debug :  print('LEvaleurPressed', valeur, type(valeur))
        if not hasattr(self, "inSaisieValeur"): self.inSaisieValeur = False
        if self.inSaisieValeur: return
        self.inSaisieValeur = True

        if valeur == None:
            try:
                nouvelleValeur = str(self.lineEditVal.text())
            except UnicodeEncodeError as e:
                self.editor.afficheMessageQt("pb d encoding", 'red')
                validite, commentaire = self.politique.recordValeur(None)
                self.lineEditVal.setText("")
                self.setValide()
                self.inSaisieValeur = False
                return
        else:
            try:
                # la 1 ligne est tres bizarre. remplacee par le 3nd le 01 10 19
                # if hasattr(self,"lineEditVal"):self.lineEditVal.setText(tr(valeur.nom))
                if hasattr(self, "lineEditVal"): self.lineEditVal.setText(tr(valeur))
            except:
                if hasattr(self, "lineEditVal"): self.lineEditVal.setText(valeur)
            nouvelleValeur = valeur

        if self.node.item.definition.validators != None:
            if self.node.item.definition.validators.verifItem(nouvelleValeur) != 1:
                commentaire = self.node.item.definition.validators.infoErreurItem()
                self.editor.afficheMessageQt(commentaire, 'red')
                self.inSaisieValeur = False
                return

        nouvelleValeurFormat = self.politique.getValeurTexte(nouvelleValeur)
        validite, commentaire = self.politique.recordValeur(nouvelleValeurFormat)
        if commentaire != "":
            if validite: self.editor.afficheCommentaire(commentaire)
            else: self.editor.afficheMessageQt(commentaire, 'red')
        self.inSaisieValeur = False
        self.setValide()

    def TraiteLEValeur(self, valeurTraitee=None):
    #---------------------------------------------
        # pour Qt
        # lit la chaine entree dans le lineedit
        # et la tranforme en chaine de valeurs
        # attention eventuellement aux complexes

        listeValeurs = []
        if valeurTraitee == None:
            valeurBrute = str(self.LEValeur.text())
        else:
            valeurBrute = valeurTraitee
        if valeurBrute == str(""): return listeValeurs, 1
        return self.traiteValeurSaisie(valeurBrute)

    def traiteValeurSaisie(self, valeurSaisie):
    #---------------------------------------
        # appelé directerment pour le web 
        # ou pour QT via la fonction TraiteLEValeur 
        listeValeurs = []
        valeurBrute = valeurSaisie
        try:    valeur = eval(valeurBrute, {})
        except: valeur = valeurBrute


        # pour traiter 11.0 - 30.0 pour le CIST
        # if (valeurTraitee and (type(valeurTraitee) in types.StringTypes) and (self.node.item.waitTxm())) :
        if ( valeurSaisie and isinstance(valeurSaisie, str) and (self.node.item.waitTxm())):
            valeur = str(valeurSaisie)

        if type(valeur) in (list, tuple):
            if self.node.item.waitComplex():
                indice = 0
                while indice < len(valeur):
                    v = valeur[indice]

                    if v == "RI" or v == "MP":
                        try:
                            t = tuple([v, valeur[indice + 1], valeur[indice + 2]])
                            listeValeurs.append(t)
                            indice = indice + 3
                        except:
                            commentaire = tr(
                                "Veuillez entrer le complexe sous forme aster ou sous forme python"
                            )
                            self.editor.afficheMessageQt(commentaire)
                            return listeValeurs, 0

                    else:  # ce n'est pas un tuple a la mode aster
                        listeValeurs.append(v)
                        indice = indice + 1

            else:  # on n'attend pas un complexe
                listeValeurs = valeurBrute.split(",")

        elif type(valeur) == bytes:
            listeValeurs = valeur.split(",")
        else:
            # listeValeurs.append(valeurBrute)
            listeValeurs.append(valeur)

        return listeValeurs, 1


class SaisieSDCO(object):
    def LESDCOReturnPressed(self):
        """
        Lit le nom donne par l'utilisateur au concept de type CO qui doit être
        la valeur du MCS courant et stocke cette valeur
        """
        self.editor.initModif()
        anc_val = self.node.item.getValeur()
        if anc_val != None:
            # il faut egalement propager la destruction de l'ancien concept
            self.node.item.deleteValeurCo(valeur=anc_val)
            # et on force le recalcul des concepts de sortie de l'etape
            self.node.item.object.etape.getType_produit(force=1)
            # et le recalcul du contexte
            self.node.item.object.etape.parent.resetContext()
        nomConcept = str(self.LESDCO.text())
        if nomConcept == "":
            return

        test, commentaire = self.node.item.setValeurCo(nomConcept)
        if test:
            commentaire = tr("Valeur du mot-clef enregistree")
            self.node.updateNodeValid()
        else:
            cr = self.node.item.getCr()
            commentaire = tr("Valeur du mot-clef non autorisee :") + cr.getMessFatal()
