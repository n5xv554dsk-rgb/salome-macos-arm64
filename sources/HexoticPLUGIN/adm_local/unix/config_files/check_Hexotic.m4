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

dnl  File   : check_Hexotic.m4
dnl  Author : Vadim SANDLER, Open CASCADE S.A.S (vadim.sandler@opencascade.com)
dnl
AC_DEFUN([CHECK_HEXOTIC],[

AC_CHECKING(for Hexotic commercial product)

AC_ARG_WITH([hexotic],
	    [AC_HELP_STRING([--with-hexotic=EXEC],
	                    [hexotic executable])],
            [],
            [with_hexotic=auto])

Hexotic_ok=no

if test "$with_hexotic" == "no" ; then
    AC_MSG_WARN(You have choosen building plugin without Hexotic)
else
    echo
    echo -------------------------------------------------
    echo You are about to choose to use somehow the
    echo Hexotic commercial product to generate 3D hexahedral mesh.
    echo
    
    if test "$with_hexotic" == "yes" || test "$with_hexotic" == "auto"; then
       AC_PATH_PROG([Hexotic],[hexotic])
    else
       Hexotic="$with_hexotic"
       AC_MSG_RESULT([Use $Hexotic as hexotic executable])
    fi
    
    if test "x$Hexotic" == x ; then
        AC_MSG_WARN(hexotic program is not found in PATH variable)
        AC_MSG_WARN(Build plugin without Hexotic)
    else
        Hexotic_ok=yes
    fi
fi

AC_MSG_RESULT(for Hexotic: $Hexotic_ok)

])dnl
