AC_INIT([top-ii-vol],[1.3],[mohd-afeef.badri@cea.fr; mohd-afeef.badri@hotmail.com])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_CONFIG_HEADERS([config.h])
AC_PREFIX_PROGRAM (program)

dnl Small macro to print out a nice, pretty section title.
define(SECTION_TITLE,
[
	echo >& AS_MESSAGE_FD
	echo '   $1   ' | sed -e's/./-/g' >&AS_MESSAGE_FD
	echo '   $1' >& AS_MESSAGE_FD
	echo '   $1   ' | sed -e's/./-/g' >&AS_MESSAGE_FD
])

AC_ARG_WITH([hdf5],
	[  --with-hdf5=               hdf5 root path : (e.g. --with-hdf5=/home/salome/INSTALL/hdf5)],
        [hdf5="$withval"], [hdf5="no"])

AC_ARG_WITH([medfile],
	[  --with-medfile=            medfile root path : (e.g. --with-medfile=/home/salome/INSTALL/medfile)],
        [medfile="$withval"], [medfile="no"])

AC_ARG_WITH([medcoupling],
	[  --with-medcoupling=        medcoupling root path : (e.g. --with-salome=/home/salome/INSTALL/MEDCOUPLING)],
        [medcoupling="$withval"], [medcoupling="no"])


AU_ALIAS([ACX_MPI], [AX_MPI])
AC_DEFUN([AX_MPI], [
AC_PREREQ(2.50) dnl for AC_LANG_CASE

AC_LANG_CASE([C], [
	AC_REQUIRE([AC_PROG_CC])
	AC_ARG_VAR(MPICC,[MPI C compiler command])
	AC_CHECK_PROGS(MPICC, mpicc hcc mpxlc_r mpxlc mpcc cmpicc, $CC)
	ax_mpi_save_CC="$CC"
	CC="$MPICC"
	AC_SUBST(MPICC)
],
[C++], [
	AC_REQUIRE([AC_PROG_CXX])
	AC_ARG_VAR(MPICXX,[MPI C++ compiler command])
	AC_CHECK_PROGS(MPICXX, mpic++ mpicxx mpiCC hcp mpxlC_r mpxlC mpCC cmpic++, $CXX)
	ax_mpi_save_CXX="$CXX"
	CXX="$MPICXX"
	AC_SUBST(MPICXX)
],
[Fortran 77], [
	AC_REQUIRE([AC_PROG_F77])
	AC_ARG_VAR(MPIF77,[MPI Fortran 77 compiler command])
	AC_CHECK_PROGS(MPIF77, mpif77 hf77 mpxlf_r mpxlf mpf77 cmpifc, $F77)
	ax_mpi_save_F77="$F77"
	F77="$MPIF77"
	AC_SUBST(MPIF77)
],
[Fortran], [
	AC_REQUIRE([AC_PROG_FC])
	AC_ARG_VAR(MPIFC,[MPI Fortran compiler command])
	AC_CHECK_PROGS(MPIFC, mpif90 mpxlf95_r mpxlf90_r mpxlf95 mpxlf90 mpf90 cmpif90c, $FC)
	ax_mpi_save_FC="$FC"
	FC="$MPIFC"
	AC_SUBST(MPIFC)
])

if test x = x"$MPILIBS"; then
	AC_LANG_CASE([C], [AC_CHECK_FUNC(MPI_Init, [MPILIBS=" "])],
		[C++], [AC_CHECK_FUNC(MPI_Init, [MPILIBS=" "])],
		[Fortran 77], [AC_MSG_CHECKING([for MPI_Init])
			AC_LINK_IFELSE([AC_LANG_PROGRAM([],[      call MPI_Init])],[MPILIBS=" "
				AC_MSG_RESULT(yes)], [AC_MSG_RESULT(no)])],
		[Fortran], [AC_MSG_CHECKING([for MPI_Init])
			AC_LINK_IFELSE([AC_LANG_PROGRAM([],[      call MPI_Init])],[MPILIBS=" "
				AC_MSG_RESULT(yes)], [AC_MSG_RESULT(no)])])
fi
AC_LANG_CASE([Fortran 77], [
	if test x = x"$MPILIBS"; then
		AC_CHECK_LIB(fmpi, MPI_Init, [MPILIBS="-lfmpi"])
	fi
	if test x = x"$MPILIBS"; then
		AC_CHECK_LIB(fmpich, MPI_Init, [MPILIBS="-lfmpich"])
	fi
],
[Fortran], [
	if test x = x"$MPILIBS"; then
		AC_CHECK_LIB(fmpi, MPI_Init, [MPILIBS="-lfmpi"])
	fi
	if test x = x"$MPILIBS"; then
		AC_CHECK_LIB(mpichf90, MPI_Init, [MPILIBS="-lmpichf90"])
	fi
])
if test x = x"$MPILIBS"; then
	AC_CHECK_LIB(mpi, MPI_Init, [MPILIBS="-lmpi"])
fi
if test x = x"$MPILIBS"; then
	AC_CHECK_LIB(mpich, MPI_Init, [MPILIBS="-lmpich"])
fi

dnl We have to use AC_TRY_COMPILE and not AC_CHECK_HEADER because the
dnl latter uses $CPP, not $CC (which may be mpicc).
AC_LANG_CASE([C], [if test x != x"$MPILIBS"; then
	AC_MSG_CHECKING([for mpi.h])
	AC_TRY_COMPILE([#include <mpi.h>],[],[AC_MSG_RESULT(yes)], [MPILIBS=""
		AC_MSG_RESULT(no)])
fi],
[C++], [if test x != x"$MPILIBS"; then
	AC_MSG_CHECKING([for mpi.h])
	AC_TRY_COMPILE([#include <mpi.h>],[],[AC_MSG_RESULT(yes)], [MPILIBS=""
		AC_MSG_RESULT(no)])
fi],
[Fortran 77], [if test x != x"$MPILIBS"; then
	AC_MSG_CHECKING([for mpif.h])
	AC_COMPILE_IFELSE([AC_LANG_PROGRAM([],[      include 'mpif.h'])],[AC_MSG_RESULT(yes)], [MPILIBS=""
		AC_MSG_RESULT(no)])
fi],
[Fortran], [if test x != x"$MPILIBS"; then
	AC_MSG_CHECKING([for mpif.h])
	AC_COMPILE_IFELSE([AC_LANG_PROGRAM([],[      include 'mpif.h'])],[AC_MSG_RESULT(yes)], [MPILIBS=""
		AC_MSG_RESULT(no)])
fi])

AC_LANG_CASE([C], [CC="$ax_mpi_save_CC"],
	[C++], [CXX="$ax_mpi_save_CXX"],
	[Fortran 77], [F77="$ax_mpi_save_F77"],
	[Fortran], [FC="$ax_mpi_save_FC"])

AC_SUBST(MPILIBS)

# Finally, execute ACTION-IF-FOUND/ACTION-IF-NOT-FOUND:
if test x = x"$MPILIBS"; then
        $2
        :
else
        ifelse([$1],,[AC_DEFINE(HAVE_MPI,1,[Define if you have the MPI library.])],[$1])
        :
fi
])dnl AX_MPI

SECTION_TITLE([ checking for a C++/MPIC++ compilers ])
AC_PROG_CC
dnl AX_MPI
AC_PROG_CXX
AC_LANG(C++)
AX_MPI

AC_ARG_WITH(MPICXX,
	[  --with-MPICXX=          path of the MPI C++ compiler to be used 
	                  (e.g. --with-MPICXX=your/MPIC++/Install/path/bin/mpic++)],
	   MPICXX="${withval}")

test "$MPICXX" == "$CXX" && AC_MSG_ERROR([

  Required  MPI C++ compilers were not  found. If you are
  sure that MPI C++ compiler is  present on you operating
  system you might use the ./configure flag:
  
    '--with-MPICXX=your/MPIC++/Install/path/bin/mpic++' 
     
  to provide the location of MPI C++ compiler. 
                                   ])

dnl ---------------------------------------------------------------
dnl Did the user provide salome/medcoupling
dnl ---------------------------------------------------------------
SECTION_TITLE([      checking for a med support     ])

AC_SUBST([hdf5])
AC_SUBST([medfile])
AC_SUBST([medcoupling])

CXXFLAGS_MED="-I${hdf5}/include -I${medfile}/include -I${medcoupling}/include  ${CXXFLAGS}"
LDFLAGS_MED="-L${hdf5}/lib -L${medfile}/lib -L${medcoupling}/lib ${LDFLAGS}"
LIBS_MED="-lhdf5 -lmedC -lmedloader -lmedcoupling -linterpkernel -lmedcouplingremapper   ${LIBS}"
AC_SUBST(CXXFLAGS_MED,[$CXXFLAGS_MED])
AC_SUBST(LDFLAGS_MED,[$LDFLAGS_MED])
AC_SUBST(LIBS_MED,[$LIBS_MED])

AM_CONDITIONAL([HAVEMED], [test $hdf5 != no -a $medfile != no -a $medcoupling != no])

test $hdf5 != no && AC_MSG_RESULT([checking for hdf5... yes])
test $hdf5 == no && AC_MSG_RESULT([checking for hdf5... no])
test $medfile != no && AC_MSG_RESULT([checking for medfile... yes])
test $medfile == no && AC_MSG_RESULT([checking for medfile... no])
test $medcoupling != no && AC_MSG_RESULT([checking for medcoupling... yes])
test $medcoupling == no && AC_MSG_RESULT([checking for medcoupling... yes])
test $hdf5 != no -a $medfile != no -a $medcoupling != no && AC_MSG_RESULT([med support... yes
 ])

test $hdf5 == no -o $medfile == no -o $medcoupling == no && AC_MSG_WARN([
top-ii-vol will not be configured with med support,
you did not provide the flags:
    --with-hdf5
    --with-medfile
    --with-medcoupling

 SALOME SUPPORT = OFF
 ])
dnl ---------------------------------------------------------------


dnl ---------------------------------------------------------------
dnl Associate appropriate suffix for diffrent os
dnl ---------------------------------------------------------------
SECTION_TITLE([      checking for operating system type    ])

os_uname=`uname`
case $os_uname in
     CYGWIN*|MINGW*|MSYS_NT*)
	os_type="windows";;
     Darwin)
	os_type="mac";;
     Linux)
	os_type="linux";;
     *)
	os_type="unknown";;
esac

AC_MSG_RESULT([])
test "$os_type" == "windows" && AC_MSG_RESULT([ OS identified: Windows])
test "$os_type" == "mac"     && AC_MSG_RESULT([ OS identified: MacOs])
test "$os_type" == "linux"   && AC_MSG_RESULT([ OS identified: Linux])

test "$os_type" == "unknown" && AC_MSG_ERROR([
  For the moment top-ii-vol is only built on Linux or MacOS
  please contact  mohd-afeef.badri@cea.fr  for  help
  regarding to building top-ii-vol on your OS.
                                   ])

AM_CONDITIONAL([WINDOWS], [test "$os_type" == "windows"])
AM_CONDITIONAL([MAC],     [test "$os_type" == "mac"])
AM_CONDITIONAL([LINUX],   [test "$os_type" == "linux"])

test "$os_type" == "windows" && AC_SUBST(SO_SUFFIX,"dll"  )
test "$os_type" == "mac"     && AC_SUBST(SO_SUFFIX,"dylib")
test "$os_type" == "linux"   && AC_SUBST(SO_SUFFIX,"so"   )

AC_MSG_RESULT([ Shared object sufix   : '$SO_SUFFIX'])
dnl ---------------------------------------------------------------

SECTION_TITLE([  generating the required makefiles  ])

dnl AC_PREFIX_DEFAULT($HOME)
AC_CONFIG_FILES([
 Makefile
 src/Makefile
 src/mesher/Makefile
 src/par-mesher/Makefile
 src/distributed-mesher/Makefile
])
AC_OUTPUT

SECTION_TITLE([                 status              ])

dnl Print results
AC_MSG_RESULT([])
AC_MSG_RESULT([ top-ii-vol version $VERSION configured successfully.])
AC_MSG_RESULT([])
AC_MSG_RESULT([ top-ii-vol install  path  : '$prefix'])
AC_MSG_RESULT([ top-ii-vol tutoirlas path : '$HOME/topIIvol-tutorials'])
AC_MSG_RESULT([])
AC_MSG_RESULT([ C++ compiler       : '$CXX'])
AC_MSG_RESULT([ MPIC++ compiler    : '$MPICXX'])
AC_MSG_RESULT([ FC compiler        : '$FC'])
AC_MSG_RESULT([ F77 compiler       : '$F77'])
AC_MSG_RESULT([])
AC_MSG_RESULT([ C/C++ compiler flags   : '$CXXFLAGS'])
AC_MSG_RESULT([ C/C++ linker flags     : '$LDFLAGS'])
AC_MSG_RESULT([ C/C++ library path     : '$LIBS'])
AC_MSG_RESULT([])
test "$hdf5" != "no" &&  AC_MSG_RESULT([ Hdf5          : YES $hdf5])
test "$hdf5" == "no" &&  AC_MSG_RESULT([ Hdf5          : NO])
test "$medfile" != "no" &&  AC_MSG_RESULT([ medfile       : YES $medfile])
test "$medfile" == "no" &&  AC_MSG_RESULT([ medfile       : NO])
test "$medcoupling" != "no" &&  AC_MSG_RESULT([ medcoupling   : YES $medcoupling])
test "$medcoupling" == "no" &&  AC_MSG_RESULT([ medcoupling   : NO])
test $hdf5 != no -a $medfile != no -a $medcoupling != no &&  AC_MSG_RESULT([ med support   : YES])
test $hdf5 == no -o $medfile == no -o $medcoupling == no &&  AC_MSG_RESULT([ med support   : NO])
AC_MSG_RESULT([])
AC_MSG_RESULT([])
