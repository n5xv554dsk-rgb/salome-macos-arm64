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
    Ce module contient la classe PROC_ETAPE qui sert à vérifier et à exécuter
    une procédure
"""

# Modules Python

import types
import sys
import traceback

# Modules EFICAS
from Accas.processing import P_MCCOMPO
from Accas.processing import P_ETAPE
from Accas.processing.P_Exception import AsException
from Accas.processing import P_utils


class PROC_ETAPE(P_ETAPE.ETAPE):

    """
    Cette classe hérite de ETAPE. La seule différence porte sur le fait
    qu'une procédure n'a pas de concept produit

    """

    nature = "PROCEDURE"

    def __init__(self, oper=None, reuse=None, args={}):
        """
        Attributs :
         - definition : objet portant les attributs de définition d'une étape de type opérateur. Il
                        est initialisé par l'argument oper.
         - valeur : arguments d'entrée de type mot-clé=valeur. Initialisé avec l'argument args.
         - reuse : forcément None pour une PROC
        """
        P_ETAPE.ETAPE.__init__(self, oper, reuse=None, args=args, niveau=5)
        self.reuse = None

    def buildSd(self):
        """
        Cette methode applique la fonction op_init au contexte du parent
        et lance l'exécution en cas de traitement commande par commande
        Elle doit retourner le concept produit qui pour une PROC est toujours None
        En cas d'erreur, elle leve une exception : AsException ou EOFError
        """
        if not self.isActif():
            return
        try:
            if self.parent:
                if type(self.definition.op_init) == types.FunctionType:
                    self.definition.op_init(*(self, self.parent.g_context))
            else:
                pass
        except AsException as e:
            raise AsException(
                "Etape ",
                self.nom,
                "ligne : ",
                self.appel[0],
                "fichier : ",
                self.appel[1],
                e,
            )
        except EOFError:
            raise
        except:
            l = traceback.format_exception(
                sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]
            )
            raise AsException(
                "Etape ",
                self.nom,
                "ligne : ",
                self.appel[0],
                "fichier : ",
                self.appel[1] + "\n",
                "".join(l),
            )

        self.Execute()
        return None

    def supprime(self):
        """
        Méthode qui supprime toutes les références arrières afin que l'objet puisse
        etre correctement détruit par le garbage collector
        """
        P_MCCOMPO.MCCOMPO.supprime(self)
        self.jdc = None
        self.appel = None

    def accept(self, visitor):
        """
        Cette methode permet de parcourir l'arborescence des objets
        en utilisant le pattern VISITEUR
        """
        visitor.visitPROC_ETAPE(self)

    def updateContext(self, d):
        """
        Met à jour le contexte de l'appelant passé en argument (d)
        Une PROC_ETAPE n ajoute pas directement de concept dans le contexte
        Seule une fonction enregistree dans op_init pourrait le faire
        """
        if type(self.definition.op_init) == types.FunctionType:
            self.definition.op_init(*(self, d))

