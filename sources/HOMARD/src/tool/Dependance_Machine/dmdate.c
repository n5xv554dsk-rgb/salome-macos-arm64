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
#include <time.h>

/* %%%%%%%%%%%%%%%%% début de zone à préprocesser %%%%%%%%%%%%%%%%%% */
#ifdef _POSIX
void dmdate_( char *ladate, LNSTRF bidon )
#else
#ifdef extern_stdcall
extern void __stdcall DMDATE( char *ladate, LNSTRF bidon )
#else
void FortranCInterface_GLOBAL(dmdate, DMDATE)(char *ladate, LNSTRF bidon)
#endif
#endif
/* %%%%%%%%%%%%%%%%%% fin de zone à préprocesser %%%%%%%%%%%%%%%%%%% */

/* time renvoie le nombre de secondes écoulées depuis le 1er janvier 1970 à 0h */
/* ctime convertit ce nombre en une chaine de 26 caractères */
/* sous la forme 'day mon dd hh:mm:ss yyyy\n\0' */
/*                123456789012345678901234 5 6 */
/*          ex : 'Thu Jul 19  9:42:23 1994' */
/* On renvoie alors les 24 premiers caractères utiles. */
{

  char *c ;
  time_t t ;

  t = time( (time_t *)0 ) ;
  c = ctime(&t) ;
  strncpy(ladate, c, (size_t)24 ) ;

}

