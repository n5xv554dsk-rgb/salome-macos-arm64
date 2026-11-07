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

#  Check availability of PYHELLO binary distribution
#
#  Author : Marc Tajchman (CEA, 2002)
#------------------------------------------------------------

AC_DEFUN([CHECK_PYHELLO],[

AC_CHECKING(for PyHello)

PyHello_ok=no

AC_ARG_WITH(pyHello,
	    --with-py-hello=DIR root directory path of PYHELLO installation,
	    PYHELLO_DIR="$withval",PYHELLO_DIR="")

if test "x$PYHELLO_DIR" = "x" ; then

# no --with-py-hello option used

  if test "x$PYHELLO_ROOT_DIR" != "x" ; then

    # PYHELLO_ROOT_DIR environment variable defined
    PYHELLO_DIR=$PYHELLO_ROOT_DIR

  else

    # search PyHello binaries in PATH variable
    AC_PATH_PROG(TEMP, PYHELLOGUI.py)
    if test "x$TEMP" != "x" ; then
      PYHELLO_BIN_DIR=`dirname $TEMP`
      PYHELLO_DIR=`dirname $PYHELLO_BIN_DIR`
    fi

  fi
#
fi

if test -f ${PYHELLO_DIR}/bin/salome/PYHELLOGUI.py  ; then
  PyHello_ok=yes
  AC_MSG_RESULT(Using PYHELLO distribution in ${PYHELLO_DIR})

  if test "x$PYHELLO_ROOT_DIR" == "x" ; then
    PYHELLO_ROOT_DIR=${PYHELLO_DIR}
  fi
  AC_SUBST(PYHELLO_ROOT_DIR)
else
  AC_MSG_WARN("Cannot find compiled PYHELLO distribution")
fi
  
AC_MSG_RESULT(for PYHELLO: $PyHello_ok)
 
])dnl
 
