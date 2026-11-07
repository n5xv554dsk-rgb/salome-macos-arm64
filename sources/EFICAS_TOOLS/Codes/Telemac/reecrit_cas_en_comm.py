#!/usr/bin/env python
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

"""
"""
# Modules Python
from __future__ import absolute_import
from __future__ import print_function

import sys,os

# Modules Eficas
import prefs
if hasattr(prefs,'encoding'):
   # Hack pour changer le codage par defaut des strings
   import sys
   reload(sys)
   sys.setdefaultencoding(prefs.encoding)
   del sys.setdefaultencoding
   # Fin hack


sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'..'))
from InterfaceQT4 import eficas_go

from PyQt5.QtWidgets import QApplication
app = QApplication(sys.argv)
#for badf in ('t2d_bridge.cas','t2d_estu_gir.cas' ):
#for f in ('t2d_bj78.cas',):
for f in ('t2d_weirs.cas',):
#for f in ('t2d_bj78.cas' ,'t2d_bowl_fe.cas' ,'t2d_bowl_vf.cas' ,'t2d_bowl_vf_gb.cas' ,'t2d_breach.cas' ,'t2d_break.cas' ,'t2d_bumpcri.cas' ,'t2d_bumpflu.cas' ,'t2d_cavity.cas' ,'t2d_cinetiques.cas' ,'t2d_clotilde.cas' ,'t2d_cone.cas' ,'t2d_confluence.cas' ,'t2d_culm.cas' ,'t2d_dambreak_v1p0.cas' ,'t2d_dambreak_v2p0.cas' ,'t2d_digue.cas' ,'t2d_donau.cas' ,'t2d_dragforce.cas' ,'t2d_estimation.cas' ,'t2d_flotteurs_v1p0.cas' ,'t2d_flotteurs_v2p0.cas' ,'t2d_friction.cas' ,'t2d_gouttedo.cas' ,'t2d_gouttedo_cin.cas' ,'t2d_gouttedo_qua.cas' ,'t2d_hydraulic_jump_v1p0.cas' ,'t2d_hydraulic_jump_v2p0.cas' ,'t2d_init-1.cas' ,'t2d_init-2.cas' ,'t2d_init-3.cas' ,'t2d_init_cin.cas' ,'t2d_island.cas' ,'t2d_m2wave.cas' ,'t2d_malpasset-large.cas' ,'t2d_malpasset-large_med.cas' ,'t2d_malpasset-small_charac.cas' ,'t2d_malpasset-small_cin.cas' ,'t2d_malpasset-small_ERIA.cas' ,'t2d_malpasset-small_pos.cas' ,'t2d_malpasset-small_prim.cas' ,'t2d_mersey.cas' ,'t2d_monai.cas' ,'t2d_okada.cas' ,'t2d_ondem2.cas' ,'t2d_pildepon.cas' ,'t2d_pildepon_cin.cas' ,'t2d_pildepon_qua.cas' ,'t2d_pluie.cas' ,'t2d_pluie_cn.cas' ,'t2d_pluie_cn_geo_hyetograph.cas' ,'t2d_porosite.cas' ,'t2d_riogrande.cas' ,'t2d_ritter.cas' ,'t2d_riv_art.cas' ,'t2d_ruptmoui.cas' ,'t2d_seccurrents.cas' ,'t2d_seiche.cas' ,'t2d_shoal.cas' ,'t2d_siphon.cas' ,'t2d_swash.cas' ,'t2d_tests_channel.cas' ,'t2d_thacker.cas' ,'t2d_thomson.cas' ,'t2d_tide-ES_real.cas' ,'t2d_tide-jmj_real_gen.cas' ,'t2d_tide-jmj_type.cas' ,'t2d_tide-jmj_type_gen.cas' ,'t2d_tide-jmj_type_med.cas' ,'t2d_tide-NEA_prior_real.cas' ,'t2d_tide-NEA_prior_type.cas' ,'t2d_tracer_decay.cas' ,'t2d_trdec.cas' ,'t2d_triangular_shelf.cas' ,'t2d_vasque.cas' ,'t2d_waq_o2.cas' ,'t2d_waq_thermic.cas' ,'t2d_wave.cas' ,'t2d_weirs.cas' ,'t2d_wesel.cas' ,'t2d_wesel_pos.cas' ,'t2d_wind.cas' ,'t2d_wind_txy_bin.cas' ,'t2d_wind_txy.cas' ,'waq_steer.cas') :

    if f == ' ' : continue
    print ("traitement de : ", 'CasEn/'+f)

    # on veut ouvrir un fichier directement au lancement d'Eficas
    eficas_go.lanceQtEficas_ssIhm_reecrit(code='TELEMAC',fichier = 'CasEn/'+f,ou = 'CasEn_Reecrits',cr=True)
    print ("\n")
