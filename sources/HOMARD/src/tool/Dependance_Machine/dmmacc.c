/* __________________________________________________________________________ */
/*                                                                            */
/*                              H O M A R D                                   */
/*                                                                            */
/*   Outil de Maillage Adaptatif par Raffinement et Deraffinement d'EDF R&D   */
/*                                                                            */
/* Version originale enregistrée le 18 juin 1996 sous le numéro 96036 auprès  */
/* des huissiers de justice Simart et Lavoir à Clamart                        */
/* Version 11.2 enregistrée le 13 février 2015 sous le numéro 2015/014 auprès */
/* des huissiers de justice Lavoir, Silinski & Cherqui-Abrahmi à Clamart      */
/*                                                                            */
/*   HOMARD est une marque déposée d'Electricite de France                    */
/*                                                                            */
/* Copyright EDF 1997                                                         */
/* Copyright EDF 1998                                                         */
/* Copyright EDF 1999                                                         */
/* Copyright EDF 2021                                                         */
/* __________________________________________________________________________ */

#include "dminfc.h"
#include "dmport.h"
#include "FC.h"
#include <string.h>

// for getenv
#include <stdlib.h>

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
/* Retourne le nom de la machine, son système, etc.                  */
/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

/* %%%%%%%%%%%%%%%%% début de zone à préprocesser %%%%%%%%%%%%%%%%%% */
#ifdef _POSIX
#include <sys/utsname.h> /* Pour le nom de la machine d'execution */
#endif
/* %%%%%%%%%%%%%%%%%% fin de zone à préprocesser %%%%%%%%%%%%%%%%%%% */

#include <stdio.h>

/* %%%%%%%%%%%%%%%%% début de zone à préprocesser %%%%%%%%%%%%%%%%%%  */

#ifdef _POSIX
void dmmacc_( char *nodeno, INTGR *nodelg, char *machno, INTGR *machlg, char *systno, INTGR *systlg, char *releno, INTGR *relelg, char *versno, INTGR *verslg, LNSTRF nodebi, LNSTRF machbi, LNSTRF systbi, LNSTRF relebi, LNSTRF versbi )
#else
#ifdef extern_stdcall
extern void __stdcall DMMACC( char *nodeno, LNSTRF nodebi, INTGR *nodelg, char *machno, LNSTRF machbi, INTGR *machlg, char *systno, LNSTRF systbi, INTGR *systlg, char *releno, LNSTRF relebi, INTGR *relelg, char *versno, LNSTRF versbi, INTGR *verslg )
#else
void FortranCInterface_GLOBAL(dmmacc, DMMACC)(char *nodeno, INTGR *nodelg, char *machno, INTGR *machlg, char *systno, INTGR *systlg, char *releno, INTGR *relelg, char *versno, INTGR *verslg)
#endif
#endif
/* %%%%%%%%%%%%%%%%%% fin de zone à préprocesser %%%%%%%%%%%%%%%%%%% */

{
  int lg ;

/* %%%%%%%%%%%%%%%%% début de zone à préprocesser %%%%%%%%%%%%%%%%%% */
#ifdef _POSIX

  struct utsname myname ;

  lg = fflush(0) ;

  if ( uname ( &myname ) != -1 ) {

        lg = (int)strlen(myname.nodename) ;
        if ( *nodelg > lg ) *nodelg = lg ;
        strncpy (nodeno,myname.nodename, (size_t)*nodelg ) ;

        lg = (int)strlen(myname.machine) ;
        if ( *machlg > lg ) *machlg = lg ;
        strncpy (machno,myname.machine, (size_t)*machlg ) ;

        lg = (int)strlen(myname.sysname) ;
        if ( *systlg > lg ) *systlg = lg ;
        strncpy (systno,myname.sysname, (size_t)*systlg ) ;

        lg = (int)strlen(myname.release) ;
        if ( *relelg > lg ) *relelg = lg ;
        strncpy (releno,myname.release, (size_t)*relelg ) ;

        lg = (int)strlen(myname.version) ;
        if ( *verslg > lg ) *verslg = lg ;
        strncpy (versno,myname.version, (size_t)*verslg ) ;

  }

  else {

        if ( *nodelg > 7 ) *nodelg = 7 ;
        strncpy (nodeno,"inconnu", (size_t)*nodelg ) ;
        if ( *machlg > 1 ) *machlg = 1 ;
        strncpy (machno," ", (size_t)*machlg ) ;
        if ( *systlg > 4 ) *systlg = 4 ;
        strncpy (systno,"Unix", (size_t)*systlg ) ;
        if ( *relelg > 1 ) *relelg = 1 ;
        strncpy (releno," ", (size_t)*relelg ) ;
        if ( *verslg > 1 ) *verslg = 1 ;
        strncpy (versno," ", (size_t)*verslg ) ;
  }

#else


  char *nodename, *machine, *sysname, *release, *version;

  nodename=getenv("COMPUTERNAME");
  if ( nodename == NULL ) {
      nodename="inconnu";
  }
  lg = (int)strlen(nodename) ;
  if ( *nodelg > lg ) *nodelg = lg ;
  strncpy (nodeno,nodename, (size_t)*nodelg ) ;

  machine=getenv ("CPU");
  if ( machine == NULL ) {
      machine="inconnu";
  }
  lg = (int)strlen(machine) ;
  if ( *machlg > lg ) *machlg = lg ;
  strncpy (machno,machine, (size_t)*machlg ) ;

  sysname=getenv ("OS");
  if ( sysname == NULL ) {
      sysname="inconnu";
  }
  lg = (int)strlen(sysname) ;
  if ( *systlg > lg ) *systlg = lg ;
  strncpy (systno,sysname, (size_t)*systlg ) ;

  release="inconnu";
  lg = (int)strlen(release) ;
  if ( *relelg > lg ) *relelg = lg ;
  strncpy (releno,release, (size_t)*relelg ) ;

  version="inconnu";
  lg = (int)strlen(version) ;
  if ( *verslg > lg ) *verslg = lg ;
  strncpy (versno,version, (size_t)*verslg ) ;

#endif
/* %%%%%%%%%%%%%%%%%% fin de zone à préprocesser %%%%%%%%%%%%%%%%%%% */


}

