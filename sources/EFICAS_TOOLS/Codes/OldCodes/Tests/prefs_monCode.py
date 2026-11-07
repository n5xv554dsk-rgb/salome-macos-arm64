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

import os,sys
# repIni sert a localiser le fichier editeur.ini
# Obligatoire
repIni=os.path.dirname(os.path.abspath(__file__))
INSTALLDIR=os.path.join(repIni,'..')
sys.path[:0]=[INSTALLDIR]


# lang indique la langue utilisee pour les chaines d'aide : fr ou ang
lang='en'

# Codage des strings qui accepte les accents (en remplacement de 'ascii')
encoding='iso-8859-1'
docPath=repIni

#
catalogues=(
   ('monCode','med',os.path.join(repIni,'CataAZ.py'),'python','python'), 
#   ('monCode','53036',os.path.join(repIni,'Elementary_Lists_53036_Cata.py'),'dico','python'), 
#   ('monCode','53033',os.path.join(repIni,'Tuples_Cata.py'),'dico','python'), 
#   ('monCode','53031',os.path.join(repIni,'Tuples_Cata.py'),'dico','python'), 
#   ('monCode','53030',os.path.join(repIni,'Tuples_Cata.py'),'dico','python'), 
#   ('monCode','53020',os.path.join(repIni,'Nested_Cond_52945_Cata.py'),'dico','python'), 
#   ('monCode','53013',os.path.join(repIni,'Elementary_Lists_53013_Cata.py'),'dico','python'), 
#   ('monCode','53000',os.path.join(repIni,'Elementary_Lists_53030_Cata.py'),'dico','python'), 
#   ('monCode','52996',os.path.join(repIni,'Elementary_Lists_52996_Cata.py'),'dico','python'), 
#   ('monCode','52992',os.path.join(repIni,'Many_Concepts_52992_Cata.py'),'dico','python'), 
#   ('monCode','52989',os.path.join(repIni,'Many_Concepts_52989_Cata.py'),'dico','python'), 
#   ('monCode','52988',os.path.join(repIni,'Many_Concepts_52988_Cata.py'),'dico','python'), 
#   ('monCode','52985',os.path.join(repIni,'fin_52985_Cata.py'),'dico','python'), 
#   ('monCode','52983',os.path.join(repIni,'Many_Concepts_52983_Cata.py'),'dico','python'), 
#   ('monCode','52975',os.path.join(repIni,'Separate_Blocks_52975_Cata.py'),'dico','python'), 
#   ('monCode','52972',os.path.join(repIni,'Separate_Blocks_52972_Cata.py'),'dico','python'), 
#   ('monCode','52958',os.path.join(repIni,'Separate_Blocks_52958_Cata.py'),'dico','python'), 
#   ('monCode','52952',os.path.join(repIni,'Nested_Cond_52952_Cata.py'),'dico','python'), 
#   ('monCode','52949',os.path.join(repIni,'Nested_Cond_52949_Cata.py'),'dico','python'), 
#   ('monCode','52947',os.path.join(repIni,'Nested_Cond_52947_Cata.py'),'dico','python'), 
#   ('monCode','52946',os.path.join(repIni,'Nested_Cond_52946_Cata.py'),'dico','python'), 
#   ('monCode','52945',os.path.join(repIni,'Nested_Cond_52945_Cata.py'),'dico','python'), 
#   ('monCode','Global',os.path.join(repIni,'Global_Condition_Cata.py'),'dico','python'),
## resolu ('monCode','52948',os.path.join(repIni,'Nested_Cond_52948_Cata.py'),'dico','python'),
#  pb d afffichage des optionnels ('monCode','52963',os.path.join(repIni,'Separate_Blocks_52963_Cata.py'),'dico','python'),
#  pb d afffichage des optionnels ('monCode','52966',os.path.join(repIni,'Separate_Blocks_52966_Cata.py'),'dico','python'),

#   ('monCode','test',os.path.join(repIni,'monCode_Cata1.py'),'dico','python'),
)

