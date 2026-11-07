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
   Module de chargement des composants et de mapping des objets du processing
   Accas vers les items d'EFICAS

     - composants : dictionnaire de stockage des relations entre types
       d'objet du processing et types d'item
     - chargerComposants() : fonction de chargement des composants. Retourne
       le dictionnaire composants.
     - gettreeitem(object) -> type d'item : fonction qui retourne un type
       d'item correspondant au type de l'objet processing fourni.
     - makeObjecttreeitem(appliEficas,labeltext, object, setFunction=None) -> item : fonction qui retourne un item
       correspondant a l'objet processing fourni.
"""
import os, glob, types

# Dictionnaire {object : item} permettant d'associer un item a un object
# Ce dictionnaire est renseigne par la methode chargerComposants
composants = {}


def chargerComposants(GUIPath):
    """
    Cette fonction a pour but de charger tous les modules composants graphiques
    (fichiers compo*.py dans le meme repertoire que ce module )
    et de remplir le dictionnaire composants utilise par makeObjecttreeitem
    """
    debug = 0
    ici=os.path.dirname(os.path.abspath(__file__))
    if debug : print ('GUIPath ', GUIPath)
    repertoire = os.path.join(ici,"../..", "InterfaceGUI",GUIPath)
    if debug : print ('repertoire', repertoire)
    package = 'InterfaceGUI.'+GUIPath
    listfich = glob.glob(os.path.join(repertoire, "compo*.py"))
    if debug : print ('listfich', listfich)
    for fichier in listfich:
        if debug : print (fichier)
        m = os.path.basename(fichier)[:-3]
        module = __import__(package, globals(), locals(), [m])
        module = getattr(module, m)
        composants[module.objet] = module.treeitem
    if debug:
        print("fin chargerComposants, composants : ", composants)
    return composants


def gettreeitem(object):
    """
    Cette fonction retourne la classe item associee a l'objet object.
    Cette classe item depend bien sur de la nature de object, d'ou
    l'interrogation du dictionnaire composants
    """
    # Si la definition de l'objet a un attribut itemeditor, il indique
    # la classe a utiliser pour l'item
    try:
        return object.definition.itemeditor
    except:
        pass

    try:
        itemtype = composants[object.__class__]
        return itemtype
    except:
        pass

    # Puis une eventuelle classe heritee (aleatoire car sans ordre)
    for e in list(composants.keys()):
        if e and isinstance(object, e):
            itemtype = composants[e]
            return itemtype

    # Si on n'a rien trouve dans les composants on utilise l'objet par defaut
    # fonctionnalite qui n est pas developpee : composants[None] n existe pas
    itemtype = composants[None]
    return itemtype


def makeObjecttreeitem(appliEficas, labeltext, object, setFunction=None):
    """
    Cette fonction permet de construire et de retourner un objet
    de type item associe a l'object passe en argument.
    """
    debug = 0
    if debug:
        print(appliEficas, labeltext, object, setFunction)
    c = gettreeitem(object)
    return c(appliEficas, labeltext, object, setFunction)
