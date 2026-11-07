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

import os

# repIni sert a localiser le fichier editeur.ini
# Obligatoire
repIni=os.path.dirname(os.path.abspath(__file__))
rep_cata = os.path.join(repIni,'Cata')
mode_nouv_commande='alpha'


# lang indique la langue utilisee pour les chaines d'aide : fr ou ang
lang='fr'

# Codage des strings qui accepte les accents (en remplacement de 'ascii')
encoding='iso-8859-1'

# Utilisateur/Developpeur
isdeveloppeur   =       "NON"

repMat_STA88=os.path.join(rep_cata,'cataSTA8','materiau')
repMat_STA98=os.path.join(rep_cata,'cataSTA9','materiau')
repMat_STA103=os.path.join(rep_cata,'cataSTA10','materiau')
 
#path_doc="/local/noyret/Docs"
rep_doc_STA88="/local/noyret/Docs"
rep_doc_STA103="/local/noyret/Docs"
rep_doc_STA11="/local/noyret/Docs/cataSTA11c_clefs_docu"

# Choix des catalogues
catalogues=(
#('ASTER','STA8.8',os.path.join(rep_cata,'cataSTA8'),'python'),
#('ASTER','STA9.8',os.path.join(rep_cata,'cataSTA9'),'python'),
#('ASTER','STA10.3',os.path.join(rep_cata,'cataSTA10'),'python'),
#('ASTER','STA11',os.path.join(rep_cata,'cataSTA11'),'python','defaut'),
('ASTER','STA12',os.path.join(rep_cata,'cataSTA12'),'python','defaut'),
)
PedfReader    = '/usr/bin/xgd-open'


def addCatalog(catalogName, catalogPath):
    """
    This function helps you to add a new catalog dynamically
    """
    global catalogues
    item=('ASTER',catalogName,catalogPath,'python')
    catalogues+=(item,)
    
