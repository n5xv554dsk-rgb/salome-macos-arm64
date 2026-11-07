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

dnl  File   : check_MESHGEMS_CADSURF.m4
dnl  Author : Gilles DAVID, Open CASCADE S.A.S (gilles.david@opencascade.com)
dnl
AC_DEFUN([CHECK_MESHGEMS_CADSURF],[

AC_REQUIRE([AC_PROG_CXX])dnl
AC_REQUIRE([AC_PROG_CXXCPP])dnl

AC_CHECKING([for MeshGems-CADSurf commercial product])

AC_LANG_SAVE
AC_LANG_CPLUSPLUS

MESHGEMS_CADSURF_INCLUDES=""
MESHGEMS_CADSURF_LIBS=""

AC_ARG_WITH([meshgems],
	    [  --with-meshgems=DIR       root directory path of MeshGems-CADSurf installation])

CADSURF_ok=no

if test "$with-meshgems" != "no" ; then
  if test "$with-meshgems" == "yes" || test "$with-meshgems" == "auto"; then
    MESHGEMS_CADSURF_HOME=""
  else
    MESHGEMS_CADSURF_HOME="$with_meshgems"
  fi

  if test "$MESHGEMS_CADSURF_HOME" == "" ; then
    if test "x$MESHGEMS_CADSURFHOME" != "x" ; then
      MESHGEMS_CADSURF_HOME=$MESHGEMS_CADSURFHOME
    fi
    if test "x$CADSURFHOME" != "x" ; then
      MESHGEMS_CADSURF_HOME=$CADSURFHOME
    fi
    if test "x$MESHGEMSHOME" != "x" ; then
      MESHGEMS_CADSURF_HOME=$MESHGEMSHOME
    fi
  fi

  if test "x$MESHGEMS_CADSURF_HOME" != "x"; then

    echo
    echo -------------------------------------------------
    echo You are about to choose to use somehow the
    echo MeshGems-CADSurf commercial product to generate 2D mesh.
    echo

    LOCAL_INCLUDES="-I$MESHGEMS_CADSURF_HOME/include"
    LOCAL_LIBS="-L$MESHGEMS_CADSURF_HOME/lib/Linux"
    archtest="$(`which arch`)"
    if test "x$archtest" = "x" ; then
      archtest="`uname -m`"
    fi
    if test $archtest = "x86_64" ; then
        LOCAL_LIBS="-L$MESHGEMS_CADSURF_HOME/lib/Linux_64"
    fi
    LOCAL_LIBS="${LOCAL_LIBS} -lmeshgems -lmg-cadsurf"

    CPPFLAGS_old="$CPPFLAGS"
    CXXFLAGS_old="$CXXFLAGS"
    CPPFLAGS="$LOCAL_INCLUDES $CPPFLAGS"
    CXXFLAGS="$LOCAL_INCLUDES $CXXFLAGS"

    AC_MSG_CHECKING([for MeshGems-CADSurf header file])

    AC_CHECK_HEADER([meshgems/meshgems.h],[CADSURF_ok=yes],[CADSURF_ok=no])
    AC_CHECK_HEADER([meshgems/cadsurf.h],[CADSURF_ok=yes],[CADSURF_ok=no])

    if test "x$CADSURF_ok" == "xyes"; then

      AC_MSG_CHECKING([for MeshGems-CADSurf library])

      LIBS_old="$LIBS"
      LIBS="-L. $LOCAL_LIBS $LIBS"

      AC_TRY_LINK(
extern "C" {
#include "meshgems/meshgems.h"
},  context_new(),
	CADSURF_ok=yes,CADSURF_ok=no
	)

      LIBS="$LIBS_old"

      AC_MSG_RESULT([$CADSURF_ok])
    fi

    CPPFLAGS="$CPPFLAGS_old"
    CXXFLAGS="$CXXFLAGS_old"

  fi
fi

if test "x$CADSURF_ok" == xno ; then
  AC_MSG_RESULT([for MeshGems-CADSurf: no])
  AC_MSG_WARN([MeshGems-CADSurf includes or libraries are not found or are not properly installed])
  AC_MSG_WARN([Cannot build without MeshGems-CADSurf. Use --with_meshgems option to define MeshGems installation.])
else
  MESHGEMS_CADSURF_INCLUDES=$LOCAL_INCLUDES
  MESHGEMS_CADSURF_LIBS=$LOCAL_LIBS
  AC_MSG_RESULT([for MeshGems-CADSurf: yes])
fi

AC_SUBST(MESHGEMS_CADSURF_INCLUDES)
AC_SUBST(MESHGEMS_CADSURF_LIBS)

AC_LANG_RESTORE

])dnl
