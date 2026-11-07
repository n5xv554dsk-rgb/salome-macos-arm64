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

# Installation de tous les fichiers Python, texte et images du repertoire et des sous-repertoires (sauf CVS)
install ( 
          FILES
           __init__.py cataSTA8c_clefs_docu cataSTA9c_clefs_docu
          DESTINATION ${CMAKE_INSTALL_PREFIX}/Aster/Cata
	)
install (
          DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Utilitai
                    ${CMAKE_CURRENT_SOURCE_DIR}/cataSTA10
                    ${CMAKE_CURRENT_SOURCE_DIR}/cataSTA9
                    ${CMAKE_CURRENT_SOURCE_DIR}/cataSTA11
          DESTINATION ${CMAKE_INSTALL_PREFIX}/Aster/Cata
)


### Local Variables:
### mode: cmake
### End:
