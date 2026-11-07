# Copyright (C) 2007-2026  CEA, EDF
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

# ---
#
# File   : check_HYBRIDPLUGIN.m4
# Author : Vadim SANDLER, Open CASCADE S.A.S (vadim.sandler@opencascade.com)
#
# ---

AC_DEFUN([CHECK_HYBRIDPLUGIN],[

AC_CHECKING(for HYBRID mesh plugin)

HYBRIDplugin_ok=no

HYBRIDPLUGIN_LDFLAGS=""
HYBRIDPLUGIN_CXXFLAGS=""

AC_ARG_WITH(HYBRIDplugin,
	    [  --with-HYBRIDplugin=DIR root directory path of HYBRID mesh plugin installation ])

if test "$with_HYBRIDplugin" != "no" ; then
    if test "$with_HYBRIDplugin" == "yes" || test "$with_HYBRIDplugin" == "auto"; then
	if test "x$HYBRIDPLUGIN_ROOT_DIR" != "x" ; then
            HYBRIDPLUGIN_DIR=$HYBRIDPLUGIN_ROOT_DIR
        fi
    else
        HYBRIDPLUGIN_DIR="$with_HYBRIDplugin"
    fi

    if test "x$HYBRIDPLUGIN_DIR" != "x" ; then
	if test -f ${HYBRIDPLUGIN_DIR}/lib${LIB_LOCATION_SUFFIX}/salome/libHYBRIDEngine.so ; then
	    HYBRIDplugin_ok=yes
	    AC_MSG_RESULT(Using HYBRID mesh plugin distribution in ${HYBRIDPLUGIN_DIR})
	    HYBRIDPLUGIN_ROOT_DIR=${HYBRIDPLUGIN_DIR}
	    HYBRIDPLUGIN_LDFLAGS=-L${HYBRIDPLUGIN_DIR}/lib${LIB_LOCATION_SUFFIX}/salome
	    HYBRIDPLUGIN_CXXFLAGS=-I${HYBRIDPLUGIN_DIR}/include/salome
	else
	    AC_MSG_WARN("Cannot find compiled HYBRID mesh plugin distribution")
	fi
    else
	AC_MSG_WARN("Cannot find compiled HYBRID mesh plugin distribution")
    fi
fi

AC_MSG_RESULT(for HYBRID mesh plugin: $HYBRIDplugin_ok)

AC_SUBST(HYBRIDPLUGIN_ROOT_DIR)
AC_SUBST(HYBRIDPLUGIN_LDFLAGS)
AC_SUBST(HYBRIDPLUGIN_CXXFLAGS)
 
])dnl
 
