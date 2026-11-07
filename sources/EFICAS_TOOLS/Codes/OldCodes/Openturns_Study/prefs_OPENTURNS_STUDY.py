# -*- coding: utf-8 -*-
# Copyright (C) 2007 - 2026   EDF R&D
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

import os, sys
# Les variables pouvant positionnees sont :
print "import des prefs de OPENTURNS"

# repIni sert a localiser le fichier 
# initialdir sert comme directory initial des QFileDialog
# positionnee a repin au debut mise a jour dans configuration
repIni=os.path.dirname(os.path.abspath(__file__))
INSTALLDIR=os.path.join(repIni,'..')
sys.path[:0]=[INSTALLDIR]


# Codage des strings qui accepte les accents (en remplacement de 'ascii')
# lang indique la langue utilisée pour les chaines d'aide : fr ou ang
lang='fr'
encoding='iso-8859-1'

# Acces a la documentation
path_doc        = os.path.join(INSTALLDIR,'Doc')
PedfReader    = "/usr/bin/xpdf"
savedir         = os.environ['HOME']


# OpenTURNS Python module
OpenTURNS_path=""
if len(OpenTURNS_path) > 0: sys.path[:0]=[OpenTURNS_path]

# Choix des catalogues
from Editeur.catadesc import CatalogDescription

catalogues = (
    CatalogDescription(identifier = "OPENTURNS_STUDY_V8",
                       cata_file_path = os.path.join(os.path.abspath(repIni), 'OpenTURNS_Cata_Study_V8.py'),
                       file_format = "openturns_study"),
)

