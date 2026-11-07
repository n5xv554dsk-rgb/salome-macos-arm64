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
"""Ce module contient le plugin generateur de fichier au format  Code_Carmel3D pour EFICAS.
"""
from builtins import str

import traceback
import types, re, os
from Accas.extensions.eficas_translation import tr
from Accas.IO.writer.writer_python import PythonGenerator


def entryPoint():
    """
    Retourne les informations necessaires pour le chargeur de plugins
    Ces informations sont retournees dans un dictionnaire
    """
    return {
        # Le nom du plugin
        "name": "xml",
        # La factory pour creer une instance du plugin
        "factory": XMLGenerator,
    }


class XMLGenerator(PythonGenerator):
    """
    Ce generateur parcourt un objet de type JDC et produit
    un texte au format eficas et

    """

    # Les extensions de fichier permis?
    extensions = (".comm",)

    # ----------------------------------------------------------------------------------------
    def gener(
        self, obj, format="brut", config=None, appliEficas=None, uniteAsAttribut=False
    ):
        try :
        #print ('Attention changement try en if')
        #if 1:
            self.texteXML = obj.toXml()
        #    print (obj.toXml)
        except :
            self.texteXML='Erreur a la generation du fichier XML'
        # print (self.texteXML)

        self.textePourAide = ""
        self.dictNbNomObj = {}
        # Cette instruction genere le contenu du fichier de commandes (persistance)
        self.text = PythonGenerator.gener(self, obj, format)
        return self.text

    # ----------------------------------------------------------------------------------------
    # initialisations
    # ----------------------------------------------------------------------------------------

    # ecriture
    # ----------------------------------------------------------------------------------------

    def writeDefault(self, fn):
        if self.texteXML == "Erreur a la generation du fichier XML":
            print(self.texteXML)
            return 0
        fileXML = fn[: fn.rfind(".")] + ".xml"
        # filePyxb = fn[:fn.rfind(".")] + '.py'
        fileBase = os.path.basename(fileXML)
        fileBase = fileBase[: fileBase.rfind(".")] + ".py"
        filePyxb = "/tmp/example_" + fileBase
        # print (filePyxb)
        # fileDico='/tmp/toto.xml'
        # print (self.texteXML)
        f = open(str(fileXML), "w")
        f.write(str(self.texteXML))
        f.close()

        f = open(str(filePyxb), "w")
        self.textePourAide = 'txt=""' + "\n" + self.textePourAide
        self.textePourAide = self.textePourAide + "print (txt)" + "\n"
        f.write(str(self.textePourAide))
        f.close()
        return 1

    def generMCSIMP(self, obj):
        if obj.nom != "Consigne":
            if obj.nom in self.dictNbNomObj.keys():
                nomUtil = obj.nom + "_" + str(self.dictNbNomObj[obj.nom])
                self.dictNbNomObj[obj.nom] += 1
            else:
                nomUtil = obj.nom
                self.dictNbNomObj[obj.nom] = 1
            if obj.definition.avecBlancs:
                self.textePourAide += (
                    nomUtil + " = vimmpCase." + obj.getNomDsXML() + ".s\n"
                )
            else:
                self.textePourAide += (
                    nomUtil + " = vimmpCase." + obj.getNomDsXML() + "\n"
                )
            self.textePourAide += (
                'txt += "' + nomUtil + '" + " = " +str( ' + nomUtil + ')+"\\n"' + "\n"
            )

        s = PythonGenerator.generMCSIMP(self, obj)
        return s
