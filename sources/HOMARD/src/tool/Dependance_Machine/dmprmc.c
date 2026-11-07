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
/*     Retourne la précision machine                                 */
/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

/* %%%%%%%%%%%%%%%%% début de zone à préprocesser %%%%%%%%%%%%%%%%%% */
#ifdef _POSIX
void dmprmc_( DOUBLE *epsima, INTGR *nbchii )
#else
#ifdef extern_stdcall
extern void __stdcall DMPRMC( DOUBLE *epsima, INTGR *nbchii )
#else
void FortranCInterface_GLOBAL(dmprmc, DMPRMC)(DOUBLE *epsima, INTGR *nbchii)
#endif
#endif
/* %%%%%%%%%%%%%%%%%% fin de zone à préprocesser %%%%%%%%%%%%%%%%%%% */

{

/* %%%%%%%%%%%%%%%%% début de zone à préprocesser %%%%%%%%%%%%%%%%%% */
#ifdef _USE_64_BITS
   *epsima = 1.e-31;

#else
   *epsima = 1.e-15;

#endif
/* %%%%%%%%%%%%%%%%%% fin de zone à préprocesser %%%%%%%%%%%%%%%%%%% */

/*    printf (". INTEGER_NB_CHIFFRES_SIGNIFICATIFS   : %d\n", INTEGER_NB_CHIFFRES_SIGNIFICATIFS); */
   *nbchii = INTEGER_NB_CHIFFRES_SIGNIFICATIFS ;


}

