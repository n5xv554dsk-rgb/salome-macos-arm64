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

dnl  File   : check_BLSURF.m4
dnl  Author : Vadim SANDLER, Open CASCADE S.A.S (vadim.sandler@opencascade.com)
dnl
AC_DEFUN([CHECK_BLSURF],[

AC_REQUIRE([AC_PROG_CXX])dnl
AC_REQUIRE([AC_PROG_CXXCPP])dnl

AC_CHECKING([for BLSURF commercial product])

AC_LANG_SAVE
AC_LANG_CPLUSPLUS

BLSURF_INCLUDES=""
BLSURF_LIBS=""

AC_ARG_WITH([blsurf],
	    [  --with-blsurf=DIR       root directory path of BLSURF installation])

BLSURF_ok=no

if test "$with_blsurf" != "no" ; then
  if test "$with_blsurf" == "yes" || test "$with_blsurf" == "auto"; then
    BLSURF_HOME=""
  else
    BLSURF_HOME="$with_blsurf"
  fi

  if test "$BLSURF_HOME" == "" ; then
    if test "x$BLSURFHOME" != "x" ; then
      BLSURF_HOME=$BLSURFHOME
    fi
  fi

  if test "x$BLSURF_HOME" != "x"; then

    echo
    echo -------------------------------------------------
    echo You are about to choose to use somehow the
    echo BLSURF commercial product to generate 2D mesh.
    echo

    LOCAL_INCLUDES="-I$BLSURF_HOME/include"
    LOCAL_LIBS="-L$BLSURF_HOME/lib/Linux"
    archtest="$(`which arch`)"
    if test "x$archtest" = "x" ; then
      archtest="`uname -m`"
    fi
    if test $archtest = "x86_64" ; then
        LOCAL_LIBS="-L$BLSURF_HOME/lib/Linux_64"
    fi
    LOCAL_LIBS="${LOCAL_LIBS} -ldistene -lBLSurf -lPreCAD"

    CPPFLAGS_old="$CPPFLAGS"
    CXXFLAGS_old="$CXXFLAGS"
    CPPFLAGS="$LOCAL_INCLUDES $CPPFLAGS"
    CXXFLAGS="$LOCAL_INCLUDES $CXXFLAGS"

    AC_MSG_CHECKING([for BLSURF header file])

    AC_CHECK_HEADER([distene/api.h],[BLSURF_ok=yes],[BLSURF_ok=no])

    if test "x$BLSURF_ok" == "xyes"; then

      AC_MSG_CHECKING([for BLSURF library])

      LIBS_old="$LIBS"
      LIBS="-L. $LOCAL_LIBS $LIBS"

      AC_TRY_LINK(
extern "C" {
#include "distene/api.h"
},  distene_context_new(),
	BLSURF_ok=yes,BLSURF_ok=no
	)

      LIBS="$LIBS_old"

      AC_MSG_RESULT([$BLSURF_ok])
    fi

    CPPFLAGS="$CPPFLAGS_old"
    CXXFLAGS="$CXXFLAGS_old"

  fi
fi

if test "x$BLSURF_ok" == xno ; then
  AC_MSG_RESULT([for BLSURF: no])
  AC_MSG_WARN([BLSURF includes or libraries are not found or are not properly installed])
  AC_MSG_WARN([Cannot build without BLSURF. Use --with-blsurf option to define BLSURF installation.])
else
  BLSURF_INCLUDES=$LOCAL_INCLUDES
  BLSURF_LIBS=$LOCAL_LIBS
  AC_MSG_RESULT([for BLSURF: yes])
fi

AC_SUBST(BLSURF_INCLUDES)
AC_SUBST(BLSURF_LIBS)

AC_LANG_RESTORE

])dnl
