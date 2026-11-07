# -*- coding: utf-8 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991-2026  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
#
#
# ======================================================================

from __future__ import absolute_import
import os,sys
# repIni sert a localiser le fichier editeur.ini
# Obligatoire
repIni = os.path.dirname(os.path.abspath(__file__))
INSTALLDIR = os.path.join(repIni,'..')
sys.path[:0] = [INSTALLDIR]


# lang indique la langue utilisee pour les chaines d'aide : fr ou ang
lang = 'ang'
#lang='fr'
#force_langue=True

# Codage des strings qui accepte les accents (en remplacement de 'ascii')
encoding = 'iso-8859-1'

rep_cata = repIni

cata_telemac = {
      'telemac2d': os.path.join(rep_cata, 'telemac2d_cata_auto.py'),
      'telemac3d': os.path.join(rep_cata, 'telemac3d_cata_auto.py'),
      'tomawac': os.path.join(rep_cata, 'tomawac_cata_auto.py'),
      'artemis': os.path.join(rep_cata, 'artemis_cata_auto.py'),
      'sisyphe': os.path.join(rep_cata, 'sisyphe_cata_auto.py'),
      'waqtel': os.path.join(rep_cata, 'waqtel_cata_auto.py'),
      'stbtel': os.path.join(rep_cata, 'stbtel_cata_auto.py'),
      'postel3d': os.path.join(rep_cata, 'postel3d_cata_auto.py'),
      'gaia': os.path.join(rep_cata, 'gaia_cata_auto.py'),
      'khione': os.path.join(rep_cata, 'khione_cata_auto.py'),
               }

translator_telemac = {\
      'telemac2d': os.path.join(rep_cata, 'telemac2d_labelCataToIhm'),
      'telemac3d': os.path.join(rep_cata, 'telemac3d_labelCataToIhm'),
      'tomawac': os.path.join(rep_cata, 'tomawac_labelCataToIhm'),
      'artemis': os.path.join(rep_cata, 'artemis_labelCataToIhm'),
      'sisyphe': os.path.join(rep_cata, 'sisyphe_labelCataToIhm'),
      'waqtel': os.path.join(rep_cata, 'waqtel_labelCataToIhm'),
      'stbtel': os.path.join(rep_cata, 'stbtel_labelCataToIhm'),
      'postel3d': os.path.join(rep_cata, 'postel3d_labelCataToIhm'),
      'gaia': os.path.join(rep_cata, 'gaia_labelCataToIhm'),
      'khione': os.path.join(rep_cata, 'khione_labelCataToIhm'),
                     }
#
catalogues = (\
    ('TELEMAC', 'telemac2d', cata_telemac['telemac2d'], 'TELEMAC', 'TELEMAC'),
    ('TELEMAC', 'telemac3d', cata_telemac['telemac3d'], 'TELEMAC', 'TELEMAC'),
    ('TELEMAC', 'tomawac', cata_telemac['tomawac'], 'TELEMAC', 'TELEMAC'),
    ('TELEMAC', 'artemis', cata_telemac['artemis'], 'TELEMAC', 'TELEMAC'),
    ('TELEMAC', 'sisyphe', cata_telemac['sisyphe'], 'TELEMAC', 'TELEMAC'),
    ('TELEMAC', 'waqtel', cata_telemac['waqtel'], 'TELEMAC', 'TELEMAC'),
    ('TELEMAC', 'stbtel', cata_telemac['stbtel'], 'TELEMAC', 'TELEMAC'),
    ('TELEMAC', 'postel3d', cata_telemac['postel3d'], 'TELEMAC', 'TELEMAC'),
    ('TELEMAC', 'gaia', cata_telemac['gaia'], 'TELEMAC', 'TELEMAC'),
    ('TELEMAC', 'khione', cata_telemac['khione'], 'TELEMAC', 'TELEMAC'),
)
mode_nouv_commande = "figee"
affiche = "ordre"
translatorFile_pn = os.path.join(repIni, 'labelCataToIhm')
translatorFile_telemac2d = translator_telemac['telemac2d']
translatorFile_telemac3d = translator_telemac['telemac3d']
translatorFile_tomawac = translator_telemac['tomawac']
translatorFile_artemis = translator_telemac['artemis']
translatorFile_sisyphe = translator_telemac['sisyphe']
translatorFile_waqtel = translator_telemac['waqtel']
translatorFile_stbtel = translator_telemac['stbtel']
translatorFile_postel3d = translator_telemac['postel3d']
translatorFile_gaia = translator_telemac['gaia']
translatorFile_khione = translator_telemac['khione']
closeFrameRecherche = True
differencieSiDefaut = True
