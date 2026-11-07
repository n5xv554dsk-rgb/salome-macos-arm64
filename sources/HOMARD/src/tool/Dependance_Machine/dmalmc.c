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
/* Copyright EDF 2014                                                         */
/* Copyright EDF 2021                                                         */
/* __________________________________________________________________________ */

// long est en général de la taille des adresses gérées par le processeur (taille des pointeurs).
// machines 64bits => long=64bits
// machines 32bits => long=32bits

// 1) ad_mem est un pointeur (32/64 bits fonction de la machine) sur une variable fortran
// dont la taille doit être celle des pointeurs de la machine (car cette variable stocke un pointeur C)
// Le type long (C) est correct pour stocker les pointeurs sur machines 32/64 bits. Cependant il faut faire attention à ce que la taille de la variable fortran corresponde aux caractéristiques de la machine.
// En effet, sur machine 32bits certains fortrans sont capables de gérer des integer*8 en 64bits ce qui ne correspondrait pas à la taille d'un long sur machine 32 bits. (cf détection configuration autoconf med)
// 2) size est le nombre d'éléments de type INTGR (entiers 32/64 bits) que l'on veut allouer.
// size pourrait être de type int (C) / integer*4 (F) mais en général si l'on a besoin d'entier 64bits pour stoker des grandeurs on a aussi besoin de dénombrer un grand nombre d'éléments.
// C'est la raison pour laquelle on a le type INTGR (C) <=> INTEGER*4 ou INTEGER*8 <=> INTEGER avec option gfortran  -fdefault-integer-8 (F)

#include "dminfc.h"
#include "dmport.h"
#include "FC.h"
#include <stdlib.h>
#include <stdio.h>
#ifndef __APPLE__
#include <malloc.h>
#endif

/* %%%%%%%%%%%%%%%%% début de zone à préprocesser %%%%%%%%%%%%%%%%%% */
#ifdef _POSIX
void dmalmc_( long * const ad_mem, const INTGR * const size )
#else
#ifdef extern_stdcall
extern void __stdcall DMALMC( long long * const ad_mem, const INTGR * const size )
#else
void FortranCInterface_GLOBAL(dmalmc, DMALMC)(long * const ad_mem, const INTGR * const size)
#endif
#endif
/* %%%%%%%%%%%%%%%%%% fin de zone à préprocesser %%%%%%%%%%%%%%%%%%% */

{

   if ( *size == 0 )
     { printf(" demande d allocation d une taille nulle\n") ; }

   if ( *size >= 0 )
   {
#ifdef _DEBUG_HOMARD_
     printf ("demande de %d octets\n",*size*sizeof(int));
#endif

   // p_intgr est un pointeur sur des entiers de taille sizeof(INTGR)
     size_t size_pintgr = (*size) * sizeof(INTGR);
     INTGR* p_intgr =  malloc(size_pintgr) ;
   // On renvoie la valeur de notre pointeur alloué dans la variable Fortran *ad_mem
   (*ad_mem) = (long long) p_intgr;

#ifdef _DEBUG_HOMARD_
     printf ("==> ad_mem = %d\n",*ad_mem);
#endif
   }

   else
   {
     printf(" demande d allocation d une taille negative\n") ;
     *ad_mem = 0 ;
   }

}

