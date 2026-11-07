# Copyright (C) 2011-2026  CEA, EDF
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
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
#  Author : Marc Tajchman (CEA, 2002)
#------------------------------------------------------------

AC_DEFUN([CHECK_SALOME_GUI],[

AC_CHECKING(for Salome GUI)

SalomeGUI_ok=no

AC_ARG_WITH(gui,
	    --with-salome_gui=DIR root directory path of SALOME GUI installation,
	    SALOME_GUI_DIR="$withval",SALOME_GUI_DIR="")

if test "x$SALOME_GUI_DIR" = "x" ; then
  if test "x$GUI_ROOT_DIR" != "x" ; then
    SALOME_GUI_DIR=$GUI_ROOT_DIR
  else
    # search Salome binaries in PATH variable
    AC_PATH_PROG(TEMP, SUITApp)
    if test "x$TEMP" != "x" ; then
      SALOME_GUI_BIN_DIR=`dirname $TEMP`
      SALOME_GUI_DIR=`dirname $SALOME_GUI_BIN_DIR`
    fi
  fi
fi

if test "x$SALOME_GUI_DIR" != "x" ; then
  if test -f ${SALOME_GUI_DIR}/bin/salome/SUITApp  ; then
    SalomeGUI_ok=yes
    AC_MSG_RESULT(Using SALOME GUI distribution in ${SALOME_GUI_DIR})
    GUI_ROOT_DIR=${SALOME_GUI_DIR}
  fi
fi
if test "x$SalomeGUI_ok" == "xno" ; then
  AC_MSG_WARN("Cannot find compiled SALOME GUI distribution")
fi
  
AC_SUBST(GUI_ROOT_DIR)

AC_MSG_RESULT(for SALOME GUI: $SalomeGUI_ok)
 
])dnl
 
