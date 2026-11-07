dnl Copyright (C) 2007-2026  CEA, EDF
dnl
dnl This library is free software; you can redistribute it and/or
dnl modify it under the terms of the GNU Lesser General Public
dnl License as published by the Free Software Foundation; either
dnl version 2.1 of the License, or (at your option) any later version.
dnl
dnl This library is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl Lesser General Public License for more details.
dnl
dnl You should have received a copy of the GNU Lesser General Public
dnl License along with this library; if not, write to the Free Software
dnl Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
dnl
dnl See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
dnl

dnl  File   : check_HexoticPLUGIN.m4
dnl  Author : Vadim SANDLER, Open CASCADE S.A.S (vadim.sandler@opencascade.com)
dnl
AC_DEFUN([CHECK_HEXOTICPLUGIN],[

AC_CHECKING(for Hexotic mesh plugin)

Hexoticplugin_ok=no

HexoticPLUGIN_LDFLAGS=""
HexoticPLUGIN_CXXFLAGS=""

AC_ARG_WITH(Hexoticplugin,
      --with-Hexoticplugin=DIR  root directory path of Hexotic mesh plugin installation,
      HexoticPLUGIN_DIR="$withval",HexoticPLUGIN_DIR="")

if test "x$HexoticPLUGIN_DIR" = "x" ; then

# no --with-Hexoticplugin option used

  if test "x$HexoticPLUGIN_ROOT_DIR" != "x" ; then

    # SALOME_ROOT_DIR environment variable defined
    HexoticPLUGIN_DIR=$HexoticPLUGIN_ROOT_DIR

  else

    # search Salome binaries in PATH variable
    AC_PATH_PROG(TEMP, libHexoticEngine.so)
    if test "x$TEMP" != "x" ; then
      HexoticPLUGIN_DIR=`dirname $TEMP`
    fi

  fi

fi

if test -f ${HexoticPLUGIN_DIR}/lib${LIB_LOCATION_SUFFIX}/salome/libHexoticEngine.so  ; then
  Hexoticplugin_ok=yes
  AC_MSG_RESULT(Using Hexotic mesh plugin distribution in ${HexoticPLUGIN_DIR})

  if test "x$HexoticPLUGIN_ROOT_DIR" == "x" ; then
    HexoticPLUGIN_ROOT_DIR=${HexoticPLUGIN_DIR}
  fi
  HexoticPLUGIN_CXXFLAGS+=-I${HexoticPLUGIN_ROOT_DIR}/include/salome
  HexoticPLUGIN_LDFLAGS+=-L${HexoticPLUGIN_ROOT_DIR}/lib${LIB_LOCATION_SUFFIX}/salome
  AC_SUBST(HexoticPLUGIN_ROOT_DIR)
  AC_SUBST(HexoticPLUGIN_LDFLAGS)
  AC_SUBST(HexoticPLUGIN_CXXFLAGS)
else
  AC_MSG_WARN("Cannot find compiled Hexotic mesh plugin distribution")
fi
  
AC_MSG_RESULT(for Hexotic mesh plugin: $Hexoticplugin_ok)
 
])dnl
