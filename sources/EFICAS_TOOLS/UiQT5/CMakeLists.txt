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
                       COMMAND ${PYUIC5} ARGS -x -o ${CMAKE_CURRENT_BINARY_DIR}/${_pyfile} ${CMAKE_CURRENT_SOURCE_DIR}/${uifile}
                       MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/${uifile}
                       COMMENT "Compiling ${uifile}"
                     )
  list ( APPEND _PYFILES ${CMAKE_CURRENT_BINARY_DIR}/${_pyfile} )
endmacro ( eficas_compile_ui )

macro ( eficas_compile_ui_2 uifile )
  get_filename_component ( _file_we ${uifile} NAME_WE )
  set ( _pyfile "${_file_we}.py" )
  add_custom_command ( OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_pyfile}
                       COMMAND ${PYUIC5} ARGS -x -o ${CMAKE_CURRENT_BINARY_DIR}/${_pyfile} ${CMAKE_CURRENT_SOURCE_DIR}/${uifile}
                       COMMAND sed -i -e "'s/\\(QtCore\\.QMetaObject\\.connectSlotsByName(WidgetFactPlie)\\)/#\\1/'" ${CMAKE_CURRENT_BINARY_DIR}/${_pyfile}
                       MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/${uifile}
                       COMMENT "Compiling ${uifile}"
                     )
  list ( APPEND _PYFILES ${CMAKE_CURRENT_BINARY_DIR}/${_pyfile} )
endmacro ( eficas_compile_ui_2 )

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
eficas_compile_ui ( Tuple4.ui )
eficas_compile_ui ( Tuple5.ui )
eficas_compile_ui ( Tuple6.ui )
eficas_compile_ui ( Tuple7.ui )
eficas_compile_ui ( Tuple8.ui )
eficas_compile_ui ( Tuple9.ui )
eficas_compile_ui ( Tuple10.ui )
eficas_compile_ui ( desPBOptionnelMT.ui )
#
eficas_compile_ui ( desWidgetBloc.ui )
eficas_compile_ui ( desWidgetCB.ui )
eficas_compile_ui ( desWidgetCBIntoSug.ui )
eficas_compile_ui ( desWidgetCommentaire.ui )
eficas_compile_ui ( desWidgetDate.ui )
eficas_compile_ui ( desWidgetFact.ui )
eficas_compile_ui ( desWidgetFactPlie.ui )
eficas_compile_ui ( desWidgetFactTableau.ui )
eficas_compile_ui ( desWidgetHeure.ui )
eficas_compile_ui ( desWidgetInactif.ui )
eficas_compile_ui ( desWidgetInformation.ui )
eficas_compile_ui ( desWidgetIntoSug.ui )
eficas_compile_ui ( desWidgetMatrice.ui )
eficas_compile_ui ( desWidgetNiveauFact.ui )
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
eficas_compile_ui ( desWidgetTableau.ui )
eficas_compile_ui ( desWidgetTuple2.ui )
eficas_compile_ui ( desWidgetTuple3.ui )
eficas_compile_ui ( desWidgetTuple4.ui )
eficas_compile_ui ( desWidgetTuple5.ui )
eficas_compile_ui ( desWidgetTuple6.ui )
eficas_compile_ui ( desWidgetTuple7.ui )
eficas_compile_ui ( desWidgetTuple8.ui )
eficas_compile_ui ( desWidgetTuple9.ui )
eficas_compile_ui ( desWidgetTuple10.ui )
eficas_compile_ui ( desWidgetUniqueSDCO.ui )
eficas_compile_ui ( desWidgetVide.ui )

add_custom_target ( CompileUI ALL DEPENDS ${_PYFILES}
                    COMMENT "Built UI files"
                  )

install ( FILES ${_PYFILES}
          DESTINATION ${CMAKE_INSTALL_PREFIX}/UiQT5
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
    #    EXECUTE_PROCESS(COMMAND \${MYLRELEASE} \${MYTSFILE} -qm \${MYFULLDIR}/\${MYOUTQMFILE})
    MAIN_DEPENDENCY ${input})
ENDFOREACH(input ${TSFILES})

ADD_CUSTOM_TARGET(CompileTS ALL DEPENDS ${QMFILES})
INSTALL(FILES ${QMFILES} DESTINATION ${CMAKE_INSTALL_PREFIX}/UiQT5)

### Local Variables:
### mode: cmake
### End:
