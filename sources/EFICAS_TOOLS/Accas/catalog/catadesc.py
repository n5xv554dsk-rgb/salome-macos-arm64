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

# Classe permettant a un utilisateur d ajouter un catalogue
# permet d avoir les valeurs par defaut dans le tuple
# Exemple dans un pref.py
# gere les ssCodes autrefois utilises par Map
# self.catalogues = (CatalogDescription("monCataVO", os.path.join(repIni, "monCata.py")),)

class CatalogDescription(object):
    def __init__(
        self,
        versionCode,
        cataFile,
        formatFichierOut="python",
        formatFichierIn="python",
        default=False,
        code=None,
        ssCode=None,
        selectable=True,
        userName=None,
    ):
        """
        This class can be used to describe an Eficas catalog.

        :type  versionCode: string
        :param versionCode: unique versionCode for the catalog

        :type  cataFile: string
        :param cataFile: path of the file containing the catalog itself

        :type  fileFormatOut: string
        :param fileFormatOut: format of the files generated when using this catalog

        :type  default: boolean
        :param default: indicate if this catalog is the default one (appear on the top of the catalogs list)

        :type  code: string
        :param code: Used to indicate the code associated to this catalog

        :type  ssCode: string
        :param ssCode: scheme associated to this catalog (Map only)

        :type  userName: string
        :param userName: name of the catalog as it will appear in the list

        :type  selectable: boolean
        :param selectable: indicate if this catalog appears in the list.
                           Setting this parameter to False is useful to keep
                           old catalogs to edit existing files but to forbid
                           to use them to create new files.




        """

        self.versionCode = versionCode
        self.cataFile = cataFile
        self.formatFichierOut = formatFichierOut
        self.formatFichierIn = formatFichierIn
        self.default = default
        self.code = code
        self.ssCode = ssCode
        if userName is None:
            self.userName = versionCode
        else:
            self.userName = userName
        self.selectable = selectable

    @staticmethod
    def createFromTuple(cataTuple):
        # print "Warning: Describing a catalog with a tuple is deprecated. " \
        #      "Please create a CatalogDescription instance directly."
        if cataTuple[0] == "TELEMAC":
            desc = CatalogDescription(
                code=cataTuple[0],
                ssCode=cataTuple[1],
                versionCode=cataTuple[0] + cataTuple[1],
                cataFile=cataTuple[2],
                formatFichierOut=cataTuple[3],
                formatFichierIn=cataTuple[4],
            )
            return desc
        if cataTuple[0] == "MAP":
            desc = CatalogDescription(
                code=cataTuple[0],
                versionCode=cataTuple[1],
                cataFile=cataTuple[2],
                ssCode=cataTuple[3],
                formatFichierOut="MAP",
                formatFichierIn="MAP",
            )
        elif len(cataTuple) == 4:
            desc = CatalogDescription(
                code=cataTuple[0],
                versionCode=cataTuple[1],
                cataFile=cataTuple[2],
                formatFichierOut=cataTuple[3],
                formatFichierIn="python",
            )
        elif len(cataTuple) == 5:
            desc = CatalogDescription(
                code=cataTuple[0],
                versionCode=cataTuple[1],
                cataFile=cataTuple[2],
                formatFichierOut=cataTuple[3],
                formatFichierIn=cataTuple[4],
            )
        elif len(cataTuple) == 6:
            desc = CatalogDescription(
                code=cataTuple[0],
                versionCode=cataTuple[1],
                cataFile=cataTuple[2],
                formatFichierOut=cataTuple[3],
                formatFichierIn=cataTuple[4],
                defaut=cataTuple[5],
            )
        else:
            print("pb a la description du catalogue avec les donnees")
            print(cataTuple)
            desc = None

        return desc
