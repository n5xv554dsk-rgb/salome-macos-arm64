#!/usr/bin/env python
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

import sys,os
sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'..'))
sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'../InterfaceQT4'))
sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'../UiQT4'))
from Accas.extensions.eficas_translation import tr
from string import split,strip,lowercase,uppercase
import re,string
import Accas


class ChercheInto:
    def __init__(self,cata,cataName):
        self.cata=cata
        self.dictInto={}
        mesCommandes=self.cata.JdC.commandes
        for maCommande in mesCommandes:
            print (maCommande.nom)
            print (maCommande.entites )
            print (len(maCommande.entites) )


#        def construitListeInto(self,e):
#            if isinstance(e,Accas.A_BLOC.BLOC) :
#               print (e.condition.
#            for nomFils, fils in e.entites.items():
#                self.construitListeInto(fils)


if __name__ == "__main__" :
    #monCata="/local/noyret/Install_Eficas/MAP/mapcata.py"
    #monCata="/local/noyret/Install_Eficas/Aster/Cata/cataSTA11/cata.py"
    #monCata="/local/noyret/Install_Eficas/MAP/mapcata.py"
    monCata="/local/noyret/Install_Eficas/MAP/mapcata.py"
    code="MAP"
    version=None

    from Editeur  import session
    options=session.parse(sys.argv)
    if options.code!= None :    code=options.code
    if options.cata!= None : monCata=options.cata
    if options.ssCode!= None :  ssCode=options.ssCode

    sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'..',code))

    from InterfaceQT4.ssIhm  import QWParentSSIhm, appliEficasSSIhm
    Eficas=appliEficasSSIhm(code=code)
    parent=QWParentSSIhm(code,Eficas,version)

    import readercata
    monreadercata  = readercata.READERCATA( parent, parent )
    Eficas.readercata=monreadercata
    monCata=monreadercata.cata

    monConstruitInto=ChercheInto(monCata,code)
