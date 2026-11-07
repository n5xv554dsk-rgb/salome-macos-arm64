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
   Ce module sert a lancer EFICAS  configure pour Code_Aster
"""
# Modules Python
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

if len(sys.argv) > 1 :
    # on veut ouvrir un fichier directement au lancement d'Eficas
    eficas_go.lance_eficas_ssIhm_cherche_cr(code='ASTER',fichier = sys.argv[1],version='STA10.3')
