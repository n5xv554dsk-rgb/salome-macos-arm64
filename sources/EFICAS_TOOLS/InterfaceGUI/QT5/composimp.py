# -*- coding: iso-8859-1 -*-
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
# Modules Python
import types, os

from copy import copy, deepcopy
import traceback

# Modules Eficas
from InterfaceGUI.Common import objecttreeitem
from InterfaceGUI.Common.simp_treeItem_commun import SIMPTreeItemCommun
from InterfaceGUI.QT5 import browser
from InterfaceGUI.QT5 import typeNode
from Accas import SalomeEntry

class Node(browser.JDCNode, typeNode.PopUpMenuNodeMinimal):
    def createPopUpMenu(self):
        typeNode.PopUpMenuNodeMinimal.createPopUpMenu(self)


    def getPanelGroupe(self, parentQt, maCommande):
        # Attention l ordre des if est important
        # print (self,self.item.nom, )
        maDefinition = self.item.get_definition()
        monObjet = self.item.object
        monNom = self.item.nom

        # le mot clef est cache ou cache avec defaut
        if maDefinition.statut in ("c", "d"): return None

        # label informatif
        if monObjet.isInformation():
            from InterfaceGUI.QT5.InterfaceGUI.QT5.monWidgetInfo import MonWidgetInfo
            widget = MonWidgetInfo( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            self.widget = widget
            return widget

        # Recalule des into si on a une fonction
        if maDefinition.into != [] and maDefinition.into != None:
            if type(maDefinition.into) ==types.FunctionType : monInto=maDefinition.into()
            else : monInto = maDefinition.into

        # Gestion des widgets specifiees dans le cata
        widgetParticularise = None
        if maDefinition.fenetreIhm != 'menuDeroulant' and maDefinition.fenetreIhm != None:
           widgetParticularise=maDefinition.fenetreIhm
        if widgetParticularise != None:
            from importlib import import_module
            module = import_module(widgetParticularise)
            classeWidget = getattr(module,'MonWidgetSpecifique')
            self.widget=classeWidget(self,maDefinition,monNom,monObjet,parentQt,maCommande)
            return self.widget

        # Gestion des matrices
        if self.item.waitMatrice():
            from InterfaceGUI.QT5.monWidgetMatrice import MonWidgetMatrice
            widget = MonWidgetMatrice( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            self.widget = widget
            return widget

        # Gestion des SIMP attendant une seule valeur (eventuellement un tuple ou un complexe)
        if maDefinition.max == 1:
            # Mot Clef avec une suggestion dans une combobox 
            if maDefinition.intoSug != [] and maDefinition.intoSug != None:
                from InterfaceGUI.QT5.monWidgetCBIntoSug import MonWidgetCBIntoSug
                widget = MonWidgetCBIntoSug( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif maDefinition.into != [] and maDefinition.into != None:
                if maDefinition.fenetreIhm == "menuDeroulant":
                    from InterfaceGUI.QT5.monWidgetCB import MonWidgetCB
                    widget = MonWidgetCB( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                elif len(monInto) < 4:
                    from InterfaceGUI.QT5.monWidgetRadioButton import MonWidgetRadioButton
                    widget = MonWidgetRadioButton( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                elif len(monInto) < 7:
                    from InterfaceGUI.QT5.monWidget4a6RadioButton import MonWidget4a6RadioButton
                    widget = MonWidget4a6RadioButton( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                else:
                    from InterfaceGUI.QT5.monWidgetCB import MonWidgetCB
                    widget = MonWidgetCB( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif self.item.waitBool():
                from InterfaceGUI.QT5.monWidgetSimpBool import MonWidgetSimpBool
                widget = MonWidgetSimpBool( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif self.item.waitFichier():
                from InterfaceGUI.QT5.monWidgetSimpFichier import MonWidgetSimpFichier
                widget = MonWidgetSimpFichier( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            # PNPNPN - a retester
            elif self.item.waitDate():
                from InterfaceGUI.QT5.monWidgetDate import MonWidgetDate
                widget = MonWidgetDate( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif self.item.waitHeure():
                from InterfaceGUI.QT5.monWidgetHeure import MonWidgetHeure
                widget = MonWidgetHeure( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif self.item.waitTuple():
                num = self.item.object.definition.type[0].ntuple
                nomDeLaClasse = "MonWidgetSimpTuple" + str(num)
                nomDuFichier = "InterfaceGUI.QT5.monWidgetSimpTupleN"
                try:
                    # if 1 :
                    _temp = __import__( nomDuFichier, globals(), locals(), [nomDeLaClasse], 0)
                    # print (_temp)
                    MonWidgetSimpTuple = getattr(_temp, nomDeLaClasse)
                    # print (MonWidgetSimpTuple)
                except:
                    print("Pas de Tuple de longueur : ", num)
                #   print ("Prevenir la maintenance ")
                widget = MonWidgetSimpTuple( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif self.item.waitComplex():
                from InterfaceGUI.QT5.monWidgetSimpComplexe import MonWidgetSimpComplexe
                widget = MonWidgetSimpComplexe( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif self.item.waitCo():
                if len(self.item.getSdAvantDuBonType()) == 0:
                    from InterfaceGUI.QT5.monWidgetUniqueSDCO import MonWidgetUniqueSDCO
                    widget = MonWidgetUniqueSDCO( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                else:
                    from InterfaceGUI.QT5.monWidgetSDCOInto import MonWidgetSDCOInto
                    widget = MonWidgetSDCOInto( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif self.item.waitAssd():
                # PN - pour ne pas appeller trop souvent self.item.getSdAvantDuBonType()
                if not (self.item.waitUserAssdOrAssdMultipleEnCreation()):
                    maListe = self.item.getSdAvantDuBonType()
                if self.item.waitUserAssdOrAssdMultipleEnCreation():
                    from InterfaceGUI.QT5.monWidgetCreeUserAssd import MonWidgetCreeUserAssd
                    widget = MonWidgetCreeUserAssd( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                elif len(maListe) == 0:
                    from InterfaceGUI.QT5.monWidgetVide import MonWidgetVide
                    widget = MonWidgetVide( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                elif len(maListe) < 4:
                    from InterfaceGUI.QT5.monWidgetRadioButton import MonWidgetRadioButtonSD
                    widget = MonWidgetRadioButtonSD( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                elif len(maListe) < 7:
                    from InterfaceGUI.QT5.monWidget4a6RadioButton import ( MonWidget4a6RadioButtonSD,)
                    widget = MonWidget4a6RadioButtonSD( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                else:
                    from InterfaceGUI.QT5.monWidgetCB import MonWidgetCBSD
                    widget = MonWidgetCBSD( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif self.item.waitSalome() and self.editor.appliEficas.salome:
                from InterfaceGUI.QT5.monWidgetSimpSalome import MonWidgetSimpSalome
                widget = MonWidgetSimpSalome( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif self.item.waitTxm():
                from InterfaceGUI.QT5.monWidgetSimpTxt import MonWidgetSimpTxt
                widget = MonWidgetSimpTxt( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            else:
                from InterfaceGUI.QT5.monWidgetSimpBase import MonWidgetSimpBase
                widget = MonWidgetSimpBase( self, maDefinition, monNom, monObjet, parentQt, maCommande)

        # Gestion des SIMP attendant une liste
        else:
            if maDefinition.intoSug != [] and maDefinition.intoSug != None:
                if self.item in self.editor.listeDesListesOuvertes or not (self.editor.afficheListesPliees):
                    from InterfaceGUI.QT5.monWidgetIntoSug import MonWidgetIntoSug
                    widget = MonWidgetIntoSug( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                else:
                    from InterfaceGUI.QT5.monWidgetPlusieursPlie import MonWidgetPlusieursPlie
                    widget = MonWidgetPlusieursPlie( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            # if maDefinition.into != [] and maDefinition.into != None:
            # Attention pas fini --> on attend une liste de ASSD avec ordre
            elif self.item.waitAssd() and self.item.isListSansOrdreNiDoublon():
                listeAAfficher = self.item.getSdAvantDuBonType()
                if len(listeAAfficher) == 0:
                    from InterfaceGUI.QT5.monWidgetVide import MonWidgetVide
                    widget = MonWidgetVide( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                else:
                    from InterfaceGUI.QT5.monWidgetPlusieursInto import MonWidgetPlusieursInto
                    widget = MonWidgetPlusieursInto( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif  self.item.waitAssd() and not self.item.waitUserAssdOrAssdMultipleEnCreation():
                listeAAfficher = self.item.getSdAvantDuBonType()
                # a changer selon UserASSD ou UserASSDMultiple
                mctype = maDefinition.type[0]
                enable_salome_selection = self.editor.appliEficas.salome and (
                    ("grma" in repr(mctype))
                    or ("grno" in repr(mctype))
                    or ("SalomeEntry" in repr(mctype))
                    or (
                        hasattr(mctype, "enable_salome_selection")
                        and mctype.enable_salome_selection
                    )
                )
                if enable_salome_selection:
                    from InterfaceGUI.QT5.monWidgetPlusieursBase import MonWidgetPlusieursBase
                    widget = MonWidgetPlusieursBase( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                elif len(listeAAfficher) == 0:
                    from InterfaceGUI.QT5.monWidgetVide import MonWidgetVide
                    widget = MonWidgetVide( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                elif self.item in self.editor.listeDesListesOuvertes or not ( self.editor.afficheListesPliees):
                    from InterfaceGUI.QT5.monWidgetPlusieursASSDIntoOrdonne import MonWidgetPlusieursASSDIntoOrdonne
                    widget = MonWidgetPlusieursASSDIntoOrdonne( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                else:
                    from InterfaceGUI.QT5.monWidgetPlusieursPlie import MonWidgetPlusieursPlieASSD
                    widget = MonWidgetPlusieursPlieASSD( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            elif self.item.waitTuple():
                if self.item.object.definition.fenetreIhm == "Tableau":
                # Attention, tableau est obsolete et mal teste
                    from InterfaceGUI.QT5.monWidgetTableau import MonWidgetTableau
                    widget = MonWidgetTableau( self, maDefinition, monNom, monObjet, parentQt, maCommande) 
                else:
                    num = self.item.object.definition.type[0].ntuple
                    nomDeLaClasse = "MonWidgetPlusieursTuple" + str(num)
                    nomDuFichier = "InterfaceGUI.QT5.monWidgetPlusieursTupleN"
                    try:
                        _temp = __import__( nomDuFichier, globals(), locals(), [nomDeLaClasse], 0)
                        MonWidgetPlusieursTuple = getattr(_temp, nomDeLaClasse)
                    except:
                        print("Pas de Tuple de longueur : ", num)
                        print("Prevenir la maintenance ")
                    widget = MonWidgetPlusieursTuple( self, maDefinition, monNom, monObjet, parentQt, maCommande)

            elif self.item.hasInto():
                if self.item.isListSansOrdreNiDoublon():
                    if self.item in self.editor.listeDesListesOuvertes or not ( self.editor.afficheListesPliees):
                        from InterfaceGUI.QT5.monWidgetPlusieursInto import MonWidgetPlusieursInto
                        widget = MonWidgetPlusieursInto( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                    else:
                        from InterfaceGUI.QT5.monWidgetPlusieursPlie import MonWidgetPlusieursPlie
                        widget = MonWidgetPlusieursPlie( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                else:
                    if self.item in self.editor.listeDesListesOuvertes or not (self.editor.afficheListesPliees):
                        from InterfaceGUI.QT5.monWidgetPlusieursIntoOrdonne import MonWidgetPlusieursIntoOrdonne
                        widget = MonWidgetPlusieursIntoOrdonne( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                    else:
                        from InterfaceGUI.QT5.monWidgetPlusieursPlie import MonWidgetPlusieursPlie
                        widget = MonWidgetPlusieursPlie( self, maDefinition, monNom, monObjet, parentQt, maCommande)
            else:
                if self.item.waitUserAssdOrAssdMultipleEnCreation():
                    from InterfaceGUI.QT5.monWidgetPlusieursCreeUserAssd import MonWidgetPlusieursCreeUserAssd
                    widget = MonWidgetPlusieursCreeUserAssd( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                elif self.item in self.editor.listeDesListesOuvertes or not ( self.editor.afficheListesPliees):
                    from InterfaceGUI.QT5.monWidgetPlusieursBase import MonWidgetPlusieursBase
                    widget = MonWidgetPlusieursBase( self, maDefinition, monNom, monObjet, parentQt, maCommande)
                else:
                    from InterfaceGUI.QT5.monWidgetPlusieursPlie import MonWidgetPlusieursPlie
                    widget = MonWidgetPlusieursPlie( self, maDefinition, monNom, monObjet, parentQt, maCommande)
        self.widget = widget
        return widget




class SIMPTreeItem(SIMPTreeItemCommun):
    itemNode = Node

import Accas
treeitem = SIMPTreeItem
objet = Accas.MCSIMP
