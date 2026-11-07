/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
/*  include (langage C ou C++) pour portage des routines             */
/*         "dependance_machine"                                      */
/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

#ifndef dmport_h
#define dmport_h

#if defined(__unix__) || defined(__APPLE__)
#define _POSIX
#warning "-------- definition de _POSIX --------"
#endif

#if defined __LP64__ || defined __MINGW64__
#define _USE_64_BITS
#warning "-------- definition de _USE_64_BITS --------"
#endif


/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
/* Correspondance entre les entiers fortran et les entiers C :       */
/* Utile par exemple sur machine DEC, quand les pointeurs sont sur   */
/* 64 bits et qu'on utilise une option du compilateur fortran qui    */
/* force tous les entiers fortran a 64 bits                          */
/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
#define DOUBLE double

#ifdef _USE_64_BITS
#pragma message ( "-------- passage par ifdef _USE_64_BITS --------" )
  typedef long long INTGR ;
  #define INTEGER_NB_CHIFFRES_SIGNIFICATIFS 19
#else
#pragma message ( "-------- passage par else de ifdef _USE_64_BITS --------" )
  typedef int INTGR ;
  #define INTEGER_NB_CHIFFRES_SIGNIFICATIFS  9
#endif


/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
/* Longueur des chaines de caractères fortran (telles que passées    */
/* comme arguments cachés par les compilateurs fortran)              */
/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
#ifdef _USE_64_BITS
    typedef long long LNSTRF ;
#else
    typedef int LNSTRF ;
#endif
//
#endif
