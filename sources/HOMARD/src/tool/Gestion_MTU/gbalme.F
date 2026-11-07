      subroutine gbalme ( typzon, lgzone, adress )
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
c     allocation d'une zone de lgzone places dans le type 'typzon'
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typzon . e   . char*1 . type de la zone a allouer                  .
c . lgzone . e   .    1   . longueur de la zone                        .
c . adress .  s  .    1   . adresse du premier element de la zone      .
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c 0.1. ==> generalites
c
      implicit none
      save
c
      character*6 nompro
      parameter ( nompro = 'GBALME' )
c
#include "genbla.h"
c
c 0.2. ==> communs
c
#include "gmtail.h"
c
#include "gmimpr.h"
#include "envex1.h"
#include "gmlang.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*1 typzon
      integer lgzone, adress
c
c 0.4. ==> variables locales
c
      integer ltype, taille
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 2. controle du type et de sa longueur
c====
c
      if ( typzon.eq.'i'.or.typzon.eq.'I') then
       ltype = tentie
      elseif ( typzon.eq.'s'.or.typzon.eq.'S') then
       ltype = tchain
      elseif ( typzon.eq.'r'.or.typzon.eq.'R') then
       ltype = treel
      else
        write(ulsort,*) nompro, ', type inconnu ', typzon
        coergm = 1
      endif
c
c====
c 3. Allocations
c====
c
      if ( coergm.eq.0 ) then
c
      taille = ltype*lgzone
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '..... taille : ', taille
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DMALME', nompro
#endif
      call dmalme ( adress, taille, coergm )
c
      endif
c
c====
c 4. Fin
c====
c
      if ( coergm.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
      end
