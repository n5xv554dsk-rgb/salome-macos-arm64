      subroutine gmdmps ( gmimp )
c ______________________________________________________________________
c
c                             H O M A R D
c
c Outil de Maillage Adaptatif par Raffinement et Deraffinement d'EDF R&D
c
c Version originale enregistree le 18 juin 1996 sous le numero 96036
c aupres des huissiers de justice Simart et Lavoir a Clamart
c Version 11.2 enregistree le 13 fevrier 2015 sous le numero 2015/014
c aupres des huissiers de justice
c Lavoir, Silinski & Cherqui-Abrahmi a Clamart
c
c    HOMARD est une marque deposee d'Electricite de France
c
c Copyright EDF 1996
c Copyright EDF 1998
c Copyright EDF 2002
c Copyright EDF 2020
c ______________________________________________________________________
c
c .  derniere modif octo 93 gn programme generique
c .  creation juin 93 jyb
c ......................................................................
c .
c .  - interet:
c .       impression detaillee du contenu du tableau de travail
c .       character*8
c .          ( caracteristiques des trous et des zones allouees)
c_______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . gmimp  . e   .    1   . 0 => pas d'impression                      .
c .        .     .        . <=2 => impression simple                   .
c .        .     .        . >2 => impression etendue                   .
c ______________________________________________________________________
c----
c 0. declarations et dimensionnement
c----
c
c
c 0.1. ==> generalites
c
      implicit none
      save
c
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmstri.h"
c
#include "gmadus.h"
#include "gmtrst.h"
#include "gmalst.h"
c
c 0.3. ==> arguments
c
      integer gmimp
c
c 0.4. ==> variables locales
c
      character*1 typtab
c
      integer iaux
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c---
c 2. appel du programme generique
c---
c
      read(smem(1),'(i8)') iaux
      typtab = 's'
      call gmdmpg ( minmes, ntrous, nballs, ptrous, ltrous,
     >      ptalls, lgalls, adus, nommxs, nomals, iaux, typtab,
     >      gmimp )
c
      end
