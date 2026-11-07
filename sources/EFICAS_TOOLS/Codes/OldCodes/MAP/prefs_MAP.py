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

import os, sys
# Les variables pouvant positionnees sont :
#print "import des prefs de MAP"

# repIni sert a localiser le fichier 
# initialdir sert comme directory initial des QFileDialog
# positionnee a repin au debut mise a jour dans configuration
repIni=os.path.dirname(os.path.abspath(__file__))
INSTALLDIR=os.path.join(repIni,'..')


# Codage des strings qui accepte les accents (en remplacement de 'ascii')
# lang indique la langue utilisee pour les chaines d'aide : fr ou ang
lang='fr'
encoding='iso-8859-1'

# Acces a la documentation
path_doc        = os.path.join(repIni,'Doc')
PedfReader    = "/usr/bin/xpdf"
savedir         = os.environ['HOME']
affiche         = "groupe"
taille          = 1400

rep_cata=os.path.dirname(os.path.abspath(__file__))
 
catalogues=(
# ('MAP','Solver',os.path.join(rep_cata,'cata_solver1.py'),'solver1'),
# ('MAP','Test',os.path.join(rep_cata,'cata_s_test03.py'),'s_test03'),
# ('MAP','Exemple python',os.path.join(rep_cata,'cata_c_transverse_empty_python.py'),'c_transverse_empty_python'),
# ('MAP','Image 3D',os.path.join(rep_cata,'cata_c_image_3d_altitude_thickness.py'),'c_image_3d_altitude_thickness'),
# ('MAP','Table FFT',os.path.join(rep_cata,'cata_c_post_table_fft.py'), 'c_post_table_fft'),
# ('MAP','PRE Mesh',os.path.join(rep_cata,'cata_c_pre_interface_mesh.py'), 'c_pre_interface_mesh'),
# ('MAP','Analyse 3D',os.path.join(rep_cata,'cata_s_scc_3d_analysis.py'), 's_scc_3d_analysis'),
 ('MAP','Map',os.path.join(rep_cata,'mapcata.py'), 'essai'),
)

closeAutreCommande = True
closeFrameRechercheCommande = True

