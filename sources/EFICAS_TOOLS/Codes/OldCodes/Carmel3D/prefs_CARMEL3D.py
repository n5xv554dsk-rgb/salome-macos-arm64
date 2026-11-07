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
repIni=os.path.dirname(os.path.abspath(__file__))

# lang indique la langue utilisee pour les chaines d'aide : fr ou ang
lang='fr'

# Codage des strings qui accepte les accents (en remplacement de 'ascii')
encoding='utf-8'

# Choix des catalogues
# format du Tuple (code,version,catalogue,formatOut, finit par defaut Ăventuellement)
catalogues = (

# catalogue avec generation Phys et materiaux reels
 ('CARMEL3D','temporel (dev)',os.path.join(repIni,'Carmel3D_Cata_temporel_V0.py'),'CARMEL3DTV0','defaut'), 
 ('CARMEL3D','frequentiel',os.path.join(repIni,'Carmel3D_Cata_frequentiel_V1.py'),'CARMEL3DFV0','defaut')
)
