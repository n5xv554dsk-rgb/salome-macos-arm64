dnl Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
dnl
dnl Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
dnl CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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

#  Check availability of COMPONENT module binary distribution
#
#  Author : Marc Tajchman (CEA, 2002)
#------------------------------------------------------------

AC_DEFUN([CHECK_COMPONENT],[

AC_CHECKING(for Component)

Component_ok=no

AC_ARG_WITH(comp,
	    --with-component=DIR root directory path of COMPONENT module installation,
	    COMPONENT_DIR="$withval",COMPONENT_DIR="")

if test "x$COMPONENT_DIR" = "x" ; then

# no --with-component option used

  if test "x$COMPONENT_ROOT_DIR" != "x" ; then

    # COMPONENT_ROOT_DIR environment variable defined
    COMPONENT_DIR=$COMPONENT_ROOT_DIR

  else

    # search component binaries in PATH variable
    AC_PATH_PROG(TEMP, libCalculatorEngine.so)
    if test "x$TEMP" != "x" ; then
      COMPONENT_DIR=`dirname $TEMP`
    fi

  fi

fi

if test -f ${COMPONENT_DIR}/lib/salome/libCalculatorEngine.so  ; then
  Component_ok=yes
  AC_MSG_RESULT(Using COMPONENT module distribution in ${COMPONENT_DIR})

  if test "x$COMPONENT_ROOT_DIR" == "x" ; then
    COMPONENT_ROOT_DIR=${COMPONENT_DIR}
  fi
  AC_SUBST(COMPONENT_ROOT_DIR)
else
  AC_MSG_WARN("Cannot find compiled COMPONENT module distribution")
fi
  
AC_MSG_RESULT(for COMPONENT: $Component_ok)
 
])dnl
 
