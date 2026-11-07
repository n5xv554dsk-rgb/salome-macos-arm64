# Copyright (C) 1991-2026   EDF R&D
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

from Accas.extensions.eficas_translation import tr

# import traceback
# traceback.print_stack()

from Accas.IO.reader.reader_python import Pythonparser


def entryPoint():
    """
    Return a dictionary containing the description needed to load the plugin
    """
    return {"name": "pythonUQ", "factory": pythonUQParser}


class pythonUQParser(Pythonparser):
    """
    This converter works like Pythonparser, except that it also initializes all
    links between deterministic and probabilistic variables
    """

    def convert(self, outformat, appliEficas=None):
        text = Pythonparser.convert(self, outformat, appliEficas)
        return text

    def traitementApresLoad(self, jdc):
        debug = 0
        if debug:
            print("traitementApresLoad")
        etapeIncertitude = jdc.getEtapesByName("ExpressionIncertitude")
        if etapeIncertitude == []:
            return

        incertitudeInput = etapeIncertitude[0].getChildOrChildInBloc("Input")
        self.lesVariablesInput = incertitudeInput[0].getChildOrChildInBloc(
            "VariableProbabiliste"
        )
        for mc in self.lesVariablesInput:
            # if debug : print (mc,'mc')
            mcVDPath = mc.getChild("MCPath").valeur
            if debug:
                print(mcVDPath)
            # a modifier lorsque le MCPath comprendra le nom des OPERs
            if not (mcVDPath):
                mc.parent.suppentite(mc)
                break  # on admet ici que le . comm n est pas valide
            mcModelVariable = mc.getChild("ModelVariable")
            mcModelVariable.definition.addInto(mcModelVariable.valeur)
            # try :
            #   mcObjectName=mc.getChild('ObjectName')
            #   mcObjectName.changeStatut('f')
            # except :
            #  pass
            mcCherche = jdc.getObjetByMCPath(mcVDPath)
            if not (mcCherche):
                mc.parent.suppentite(mc)
                break  # on admet ici que le . comm n est pas valide
            if debug:
                print(mcCherche)
            if mc.nature == "MCFACT":
                mc[0].variableDeterministe = mcCherche
                mcCherche.variableProbabiliste = mc[0]
            else:
                mc.variableDeterministe = mcCherche
                mcCherche.variableProbabiliste = mc[0]
            mcCherche.definition.siValide = mcCherche.changeValeursRefUQ
            mcCherche.associeVariableUQ = True
            itemConsigne = mc.getChild("Consigne")
            itemConsigne.setValeur(
                "la valeur entrée pour {} est {}".format(
                    mcCherche.nom, mcCherche.valeur
                )
            )
