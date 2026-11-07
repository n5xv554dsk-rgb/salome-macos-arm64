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

import re
from Accas.extensions.eficas_translation import tr
from Accas.IO.reader.reader_python import Pythonparser

def entryPoint():
    """
    Return a dictionary containing the description needed to load the plugin
    """
    return {
           'name' : 'pythonUQ',
           'factory' : pythonUQParser
           }

class pythonUQParser(Pythonparser):
    """
    This converter works like Pythonparser, except that it also initializes all
    links between deterministic and probabilistic variables
    """

    def convert(self, outformat, appliEficas=None):
        text=Pythonparser.convert(self, outformat, appliEficas)
        return text

    def traitementApresLoad(self,jdc):
        debug=0
        if debug : print ('traitementApresLoad')
        etapeIncertitude=jdc.getEtapesByName('ExpressionIncertitude')
        if etapeIncertitude==[] : return
        
        incertitudeInput = etapeIncertitude[0].getChildOrChildInBloc('Input')[0]
        self.lesVariablesInput = incertitudeInput.getChildOrChildInBloc('VariableProbabiliste')
        for mc in self.lesVariablesInput :
            if debug : print (mc,'mc')
            mcVDPath=mc.getChild('MCPath').valeur
            if debug : print(mcVDPath)
            if not (mcVDPath) : 
               try: mc.parent.suppentite(mc)
               except : pass
               break # on admet ici que le . comm n est pas valide 
            mcModelVariable=mc.getChild('ModelVariable')
            mcModelVariable.definition.addInto(mcModelVariable.valeur)

            mcDeterministe=jdc.getObjetByMCPath(mcVDPath)
            if debug : print ('mcDeterministe', mcDeterministe, 'trouve a partir de ',  mcVDPath)
            if not (mcDeterministe) : 
               try: mc.parent.suppentite(mc)
               except : pass
               break # on admet ici que le . comm n est pas valide 
            if debug : print('mcDeterministe',mcDeterministe, mcDeterministe.nom)

            mc.variableDeterministe=mcDeterministe
            if debug : print ('variableDeterministe pour ', mc, 'mis a ', mcDeterministe)
            mcDeterministe.variableProbabiliste=mc
            if debug : print ('variableProbabiliste pour ', mcDeterministe, 'mis a ', mc)

            mcDeterministe.definition.siValide = mcDeterministe.changeValeursRefUQ
            mcDeterministe.associeVariableUQ = True
            # il ne faut pas mettre la consigne a jour. Elle le sera a la validation sans erreur sur les valeurs

