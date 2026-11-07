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
#include <stdlib.h>
#ifndef __APPLE__
#include <malloc.h>
#endif

/* %%%%%%%%%%%%%%%%% début de zone à préprocesser %%%%%%%%%%%%%%%%%% */
#ifdef _POSIX
void dmralc_( INTGR *iad_mem, INTGR *size )
#else
#ifdef extern_stdcall
extern void __stdcall DMRALC( INTGR *iad_mem, INTGR *size )
#else
void FortranCInterface_GLOBAL(dmralc, DMRALC)(INTGR *iad_mem, INTGR *size)
#endif
#endif
/* %%%%%%%%%%%%%%%%%% fin de zone à préprocesser %%%%%%%%%%%%%%%%%%% */

{
  void *adret ;

  adret = realloc( (void *) *iad_mem, (size_t) *size ) ;

  if ( adret != NULL )
  {
    *iad_mem = (INTGR) adret ;
  }
  else
  {
    *iad_mem = 0 ;
  }

}

