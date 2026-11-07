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

from __future__ import absolute_import
from __future__ import print_function
try :
    from builtins import str
    from builtins import object
except :
    pass
import sys,os
sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'..'))
sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'../InterfaceQT4'))
sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'../UiQT4'))
from Accas.extensions.eficas_translation import tr
from string import split,strip,lowercase,uppercase
import re,string

import xml.etree.ElementTree as ET
from xml.dom import minidom

from PyQt4.QtGui import *

def prettify(elem):
    """Return a pretty-printed XML string for the Element.
    """
    rough_string = ET.tostring(elem, 'iso-8859-1')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")


class CatalogueXML(object):
    def __init__(self,cata,cataName):
        self.fichier="/tmp/XML/"+cataName+".xml"
        self.cata=cata
        self.first=ET.Element('cata')
        comment=ET.Comment("catalogue "+str(cataName))
        self.first.append(comment)
        self.reglesUtilisees=[]
        self.validatorsUtilises=[]
        self.constrListTxtCmd()
        self.ecrire_fichier()


    def ecrire_fichier(self):
        try :
            import codecs
            f = codecs.open(self.fichier, "w", "ISO-8859-1")
            #print prettify(self.first)
            f.write(prettify(self.first))
            f.close()
        except :
            print(("Impossible d'ecrire le fichier : "+ str(self.fichier)))

    def constrListTxtCmd(self):
        mesCommandes=self.cata.JdC.commandes
        self.commandes=ET.SubElement(self.first,'commandes')
        for maCommande in mesCommandes:
            maCommande.enregistreXMLStructure(self.commandes,self)


if __name__ == "__main__" :
    #monCata="/local/noyret/Install_Eficas/MAP/mapcata.py"
    #monCata="/local/noyret/Install_Eficas/Aster/Cata/cataSTA11/cata.py"
    #monCata="/local/noyret/Install_Eficas/MAP/mapcata.py"
    #monCata="/local/noyret/Install_Eficas/MAP/mapcata.py"
    code="Aster"
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

    monCataXML=CatalogueXML(monCata,code)
