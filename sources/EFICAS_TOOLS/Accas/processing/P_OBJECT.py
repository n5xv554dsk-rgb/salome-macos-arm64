## coding=utf-8
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
    Ce module contient la classe OBJECT classe mère de tous les objets
    servant à controler les valeurs par rapport aux définitions
"""
from builtins import object
from Accas.processing.P_CR import CR


class OBJECT(object):

    """
    Classe OBJECT : cette classe est virtuelle et sert de classe mère
    aux classes de type ETAPE et MOCLES.
    Elle ne peut etre instanciée.
    Une sous classe doit obligatoirement implémenter les méthodes :

    - __init__

    """

    def getEtape(self):
        """
        Retourne l'étape à laquelle appartient self
        Un objet de la catégorie etape doit retourner self pour indiquer que
        l'étape a été trouvée
        XXX double emploi avec self.etape ???
        """
        if self.parent == None:
            return None
        return self.parent.getEtape()

    def supprime(self):
        """
        Méthode qui supprime les références arrières suffisantes pour
        que l'objet puisse etre correctement détruit par le
        garbage collector
        """
        self.parent = None
        self.etape = None
        self.jdc = None
        self.niveau = None

    def getVal(self):
        """
        Retourne la valeur de l'objet. Cette méthode fournit
        une valeur par defaut. Elle doit etre dérivée pour chaque
        type d'objet
        """
        return self

    def getJdcRoot(self):
        """
        Cette méthode doit retourner l'objet racine c'est à dire celui qui
        n'a pas de parent
        """
        if self.parent:
            return self.parent.getJdcRoot()
        else:
            return self

    def getValeurEffective(self, val):
        """
        Retourne la valeur effective du mot-clé en fonction
        de la valeur donnée. Defaut si val == None
        """
        if val is None and hasattr(self.definition, "defaut"):
            return self.definition.defaut
        else:
            return val

    def reparent(self, parent):
        """
        Cette methode sert a reinitialiser la parente de l'objet
        """
        self.parent = parent
        self.jdc = parent.jdc

    def isBLOC(self):
        """
        Indique si l'objet est un BLOC
        surcharge dans MCBLOC
        """
        return 0

    def longueurDsArbre(self):
        if self.nom == "Consigne":
            return 0
        if self.nom == "blocConsigne":
            return 0
        return 1

    def prepareInsertInDB(self, dictKey, dElementsRecursifs, dPrimaryKey):
        # Comme c est recursif doit etre dans Objet
        # derive pour MCSIMP et MCLIST
        #debug = 1
        if debug:
            print("prepareInsertInDB traitement de ", self.nom)
        if self.nature in ("OPERATEUR", "PROCEDURE"):
            texteColonnes = "INSERT INTO {} (".format(self.nom)
            texteValeurs = " VALUES("
        elif self.nom in dPrimaryKey:
            texteColonnes = "INSERT INTO {} (".format(self.nom)
            texteValeurs = " VALUES("
            texteColonnes += dPrimaryKey[self.nom]
            texteValeurs += dictKey[dPrimaryKey[self.nom]]
        else:
            texteColonnes = ""
            texteValeurs = ""
        texteAutresTables = ""
        for mc in self.mcListe:
            if debug:
                print("prepareInsertInDB appel pour", mc.nom, dictKey)
            if mc.nom in dElementsRecursifs:
                print("Mot Clef Recursifs", mc.nom)
            if mc.nature == "MCSIMP":
                col, val = mc.prepareInsertInDB()
                if mc.nom in dictKey:
                    dictKey[mc.nom] = val
                texteValeurs += val + " ,"
                texteColonnes += col + " ,"
            else:
                tc, tv, ta = mc.prepareInsertInDB(
                    dictKey, dElementsRecursifs, dPrimaryKey
                )
                texteValeurs += val + " ,"
                texteColonnes += col + " ,"
                texteAutresTables += ta

        if self.nature in ("OPERATEUR", "PROCEDURE") or self.nom in dPrimaryKey:
            texteColonnes = texteColonnes[0:-1] + ") "
            texteValeurs = texteValeurs[0:-1] + ");\n"
        return (texteColonnes, texteValeurs, texteAutresTables)

    def longueurDsArbreAvecConsigne(self):
        return 1

class ErrorObj(OBJECT):

    """Classe pour objets errones : emule le comportement d'un objet tel mcsimp ou mcfact"""

    def __init__(self, definition, valeur, parent, nom="err"):
        self.nom = nom
        self.definition = definition
        self.valeur = valeur
        self.parent = parent
        self.mcListe = []
        if parent:
            self.jdc = self.parent.jdc
            # self.niveau = self.parent.niveau
            # self.etape = self.parent.etape
        else:
            # Pas de parent
            self.jdc = None
            # self.niveau = None
            # self.etape = None

    def isValid(self, cr="non"):
        return 0

    def report(self):
        """génère le rapport de Accas.validation de self"""
        self.cr = CR()
        self.cr.debut = "Mot-clé invalide : " + self.nom
        self.cr.fin = "Fin Mot-clé invalide : " + self.nom
        self.cr.fatal(
            _("Type non autorisé pour le mot-clé %s : '%s'"), self.nom, self.valeur
        )
        return self.cr


def newGetattr(self, name):
    try:
        fils = self.getChildOrChildInBloc(name, restreint="non")
        if fils:
            if fils.nature == "MCSIMP":
                return fils.valeur
            if fils.nature == "MCList":
                if fils[0].definition.max == 1:
                    return fils[0]
            return fils
    except:
        raise AttributeError(
            "%r object has no attribute %r" % (self.__class__.__name__, name)
        )
    raise AttributeError(
        "%r object has no attribute %r" % (self.__class__.__name__, name)
    )


def newGetattrForEtape(self, name):
    try:
        lesFils = self.getEtapesByName(name)
        if lesFils != []:
            return lesFils
    except:
        raise AttributeError(
            "%r object has no attribute %r" % (self.__class__.__name__, name)
        )
    raise AttributeError(
        "%r object has no attribute %r" % (self.__class__.__name__, name)
    )


def activeSurcharge():
    from .P_MCCOMPO import MCCOMPO

    MCCOMPO.__getattr__ = newGetattr
    from .P_JDC import JDC

    JDC.__getattr__ = newGetattrForEtape
