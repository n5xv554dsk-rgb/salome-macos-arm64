sC -*- coding: utf-8 -*-
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
    Ce module SERVAIT a lire un catalogue et a construire
    un objet CataItem pour Eficas.
    Il s'appuie sur la classe READERCATA
    OBSOLETE
"""
import autre_analyse_cata
import Accas.catalogue.uiinfo


# Modules Eficas

from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException
from autre_analyse_cata import analyseCatalogue


from Accas.catalog.readercata import ReaderCataCommun


class ReaderCata(ReaderCataCommun):
# essai de lecture de catalogue en XML
# obsolete
    def __init__(self, appliEficas, editor):
        self.appliEficas = appliEficas
        self.editor = editor
        self.versionEficas = self.appliEficas.versionEficas
        self.code = self.appliEficas.code

        # PN ?? bizarre le 22/04/24
        self.appliEficas.formatfichierOut = "python"
        self.appliEficas.formatfichierIn = "xml"
        self.modeNouvCommande = self.appliEficas.maConfiguration.modeNouvCommande
        self.versionCode = self.appliEficas.versionCode
        self.version_cata = None
        self.ficCata = None
        self.OpenCata()
        self.cataitem = None
        self.titre = "Eficas XML"
        self.ordreDesCommandes = None
        self.Classement_Commandes_Ds_Arbre = ()
        self.demandeCatalogue = False

        # self.traiteIcones()
        # self.creeDicoInverse()

    def OpenCata(self):
        # self.ficCata = 'Cata_MED_FAM.xml'
        # xml = open('/home/A96028/QT5GitEficasTravail/eficas/Med/Cata_MED_FAM.xml').read()
        # xml = open('/home/A96028/QT5GitEficasTravail/eficas/CataTestXSD/cata_test1.xml').read()
        self.choisitCata()
        xml = open(self.ficCata).read()
        SchemaMed = readerEfiXsd.efficas.CreateFromDocument(xml)
        SchemaMed.exploreCata()
        self.cata = SchemaMed
        uiinfo.traite_UIinfo(self.cata)
        #self.commandesOrdreCatalogue = []
        self.dicoCataOrdonne, self.appliEficas.liste_simp_reel = autre_analyse_cata.analyseCatalogue(self.cata)
        self.liste_groupes = None

    def dumpToXml(self):
        # pour compatibilite
        pass
