# -*- coding: utf-8 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991-2026, 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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

set ( _PYFILES )
macro ( eficas_compile_ui uifile )
  get_filename_component ( _file_we ${uifile} NAME_WE )
  set ( _pyfile "${_file_we}.py" )
  add_custom_command ( OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_pyfile}
                       COMMAND ${PYUIC4} ARGS -x -o ${CMAKE_CURRENT_BINARY_DIR}/${_pyfile} ${CMAKE_CURRENT_SOURCE_DIR}/${uifile}
                       MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/${uifile}
                       COMMENT "Compiling ${uifile}"
                     )
  list ( APPEND _PYFILES ${CMAKE_CURRENT_BINARY_DIR}/${_pyfile} )
endmacro ( eficas_compile_ui )

eficas_compile_ui ( myMain.ui )
eficas_compile_ui ( desBaseWidget.ui )
eficas_compile_ui ( desChoixCata.ui )
eficas_compile_ui ( desChoixCode.ui )
eficas_compile_ui ( desChoixCommandes.ui )
eficas_compile_ui ( desChoixLangue.ui )
eficas_compile_ui ( desRecherche.ui )
eficas_compile_ui ( desRechercheCatalogue.ui )
eficas_compile_ui ( desSelectVal.ui )
eficas_compile_ui ( desViewTexte.ui )
eficas_compile_ui ( desViewRegles.ui )
eficas_compile_ui ( desVisu.ui )
eficas_compile_ui ( desWidgetCreeParam.ui )
eficas_compile_ui ( desWidgetCommande.ui )
eficas_compile_ui ( desWidgetFormule.ui )
eficas_compile_ui ( desWidgetOptionnel.ui )
eficas_compile_ui ( desGroupeOptionnel.ui )
eficas_compile_ui ( Tuple2.ui )
eficas_compile_ui ( Tuple3.ui )
#
eficas_compile_ui ( desWidgetBloc.ui )
eficas_compile_ui ( desWidgetCB.ui )
eficas_compile_ui ( desWidgetCommentaire.ui )
eficas_compile_ui ( desWidgetDate.ui )
eficas_compile_ui ( desWidgetFact.ui )
eficas_compile_ui ( desWidgetFactPlie.ui )
eficas_compile_ui ( desWidgetHeure.ui )
eficas_compile_ui ( desWidgetInactif.ui )
eficas_compile_ui ( desWidgetInformation.ui )
eficas_compile_ui ( desWidgetMatrice.ui )
eficas_compile_ui ( desWidgetParam.ui )
eficas_compile_ui ( desWidgetPlusieursBase.ui )
eficas_compile_ui ( desWidgetPlusieursInto.ui )
eficas_compile_ui ( desWidgetPlusieursIntoOrdonne.ui )
eficas_compile_ui ( desWidgetPlusieursTuple.ui )
eficas_compile_ui ( desWidgetPlusieursPlie.ui )
eficas_compile_ui ( desWidgetRadioButton.ui ) 
eficas_compile_ui ( desWidget4a6RadioButton.ui )
eficas_compile_ui ( desWidgetSDCOInto.ui )
eficas_compile_ui ( desWidgetSimpBase.ui )
eficas_compile_ui ( desWidgetSimpBool.ui )
eficas_compile_ui ( desWidgetSimpComplexe.ui )
eficas_compile_ui ( desWidgetSimpFichier.ui )
eficas_compile_ui ( desWidgetSimpSalome.ui )
eficas_compile_ui ( desWidgetSimpTxt.ui )
eficas_compile_ui ( desWidgetTuple2.ui )
eficas_compile_ui ( desWidgetTuple3.ui )
eficas_compile_ui ( desWidgetUniqueSDCO.ui )
eficas_compile_ui ( desWidgetVide.ui )

add_custom_target ( CompileUI ALL DEPENDS ${_PYFILES}
                    COMMENT "Built UI files"
                  )

install ( FILES ${_PYFILES}
          DESTINATION ${CMAKE_INSTALL_PREFIX}/UiQT4
        )

# Rules to compile TS files
SET(TSFILES eficas_en.ts
            eficas_fr.ts)

SET(QMFILES)
FOREACH(input ${TSFILES})
  GET_FILENAME_COMPONENT(base ${input} NAME_WE)
  SET(output ${CMAKE_CURRENT_BINARY_DIR}/${base}.qm)
  SET(QMFILES ${QMFILES} ${output})
  ADD_CUSTOM_COMMAND(OUTPUT ${output}
    COMMAND ${QT_LRELEASE_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/${input} -qm ${output}
    MAIN_DEPENDENCY ${input})
ENDFOREACH(input ${TSFILES})

ADD_CUSTOM_TARGET(CompileTS ALL DEPENDS ${QMFILES})
INSTALL(FILES ${QMFILES} DESTINATION ${CMAKE_INSTALL_PREFIX}/UiQT4)

### Local Variables:
### mode: cmake
### End:
