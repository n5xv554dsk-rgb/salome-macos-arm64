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
# File   : check_HYBRID.m4
# Author : Vadim SANDLER, Open CASCADE S.A.S (vadim.sandler@opencascade.com)
#
# ---

AC_DEFUN([CHECK_HYBRID],[

AC_REQUIRE([AC_PROG_CXX])dnl
AC_REQUIRE([AC_PROG_CXXCPP])dnl

AC_CHECKING(for HYBRID(MG_hybrid) commercial product)

AC_LANG_SAVE
AC_LANG_CPLUSPLUS

AC_ARG_WITH(,
	    [  --with-hybrid=DIR     root directory path of HYBRID (MG_hybrid) installation])

HYBRID_ok=no

if test "$with_hybrid" == "no" ; then
    AC_MSG_WARN(You have choosen building plugin without HYBRID)
else
    if test "$with_hybrid" == "yes" || test "$with_hybrid" == "auto"; then
        HYBRID_HOME=""
    else
        HYBRID_HOME="$with_hybrid"
    fi
    
    if test "$HYBRID_HOME" == "" ; then
        if test "x$HYBRIDHOME" != "x" ; then
            HYBRID_HOME=$HYBRIDHOME
        else
            AC_MSG_WARN(Build plugin without HYBRID)
        fi
    fi
    
    if test "x$HYBRID_HOME" != "x"; then
    
      echo
      echo -------------------------------------------------
      echo You are about to choose to use somehow the
      echo "HYBRID(MG-hybrid) commercial product to generate 3D tetra-hexahedral mesh."
      echo
    
      AC_CHECKING(for HYBRID(MG-hybrid) executable)
    
      AC_CHECK_PROG(HYBRID,MG-hybrid,found)
    
      if test "x$HYBRID" == x ; then
        AC_MSG_WARN(MG-hybrid program not found in PATH variable)
        AC_MSG_WARN(Build plugin without HYBRID)
      else
        HYBRID_ok=yes
      fi
    
    fi
fi

AC_MSG_RESULT(for HYBRID: $HYBRID_ok)
AC_LANG_RESTORE

])dnl
