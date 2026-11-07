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

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
/*     Retourne les temps user et système écoulés depuis le début    */
/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

#ifdef _POSIX
#include <sys/times.h>
#include <unistd.h>
#endif

#include <time.h>

#ifdef CLK_TCK
#define CLOCKS_PER_SEC_VALUE CLK_TCK
#else
#define CLOCKS_PER_SEC_VALUE sysconf(_SC_CLK_TCK)
#endif

/* %%%%%%%%%%%%%%%%% début de zone à préprocesser %%%%%%%%%%%%%%%%%% */
#ifdef _POSIX
void dmtemc_( DOUBLE *tuser, DOUBLE *tsyst )
#else
#ifdef extern_stdcall
extern void __stdcall DMTEMC( DOUBLE *tuser, DOUBLE *tsyst )
#else
void FortranCInterface_GLOBAL(dmtemc, DMTEMC)(DOUBLE *tuser, DOUBLE *tsyst)
#endif
#endif
/* %%%%%%%%%%%%%%%%%% fin de zone à préprocesser %%%%%%%%%%%%%%%%%%% */

{

/* %%%%%%%%%%%%%%%%% début de zone à préprocesser %%%%%%%%%%%%%%%%%% */
#ifdef _POSIX
   struct tms temps;
   times (&temps);
   *tuser=(DOUBLE)temps.tms_utime/(DOUBLE)CLOCKS_PER_SEC_VALUE;
   *tsyst=(DOUBLE)temps.tms_stime/(DOUBLE)CLOCKS_PER_SEC_VALUE;

#else
   *tuser=(DOUBLE)clock()/CLOCKS_PER_SEC_VALUE;
   *tsyst=(DOUBLE)0.;

#endif
/* %%%%%%%%%%%%%%%%%% fin de zone à préprocesser %%%%%%%%%%%%%%%%%%% */

}

