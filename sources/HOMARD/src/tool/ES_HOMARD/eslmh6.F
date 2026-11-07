      subroutine eslmh6 ( idfmed,
     >                    nhelig,
     >                    tbiaux,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : Lecture du Maillage Homard - phase 6
c  -      -        -          -        -              -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nhelig . e   . char8  . nom de l'objet decrivant les ignores       .
c . tbiaux .     .    *   . tableau tampon entier                      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'ESLMH6' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
c
#include "envca1.h"
#include "envex1.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer tbiaux(0:*)
c
      character*8 nhelig
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer hfmdel, hnoeel
      integer nbnoel
      integer codre1, codre2, codre3
      integer codre0
c
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. intialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "esimpr.h"
c
#include "impr03.h"
c
c====
c 2. les elements ignores
c====
c 2.1. ==> Lecture
c
      if ( codret.eq.0 ) then
c
      noprof = blan64
c                     1234567890123456
      noprof(1:16) = 'Elements_Ignores'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRR', nompro
#endif
      call mpfprr ( idfmed, noprof, tbiaux, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
#endif
c
c 2.2. ==> Allocations
c
      if ( codret.eq.0 ) then
c
      nbelig = tbiaux(0)
c
      if ( degre.eq.1 ) then
        nbnoel = 5
      else
        nbnoel = 13
      endif
c
      iaux = nbelig * nbnoel
      call gmaloj ( nhelig//'.ConnNoeu', ' ', iaux ,  hnoeel, codre1 )
      call gmaloj ( nhelig//'.FamilMED', ' ', nbelig, hfmdel, codre2 )
      call gmecat ( nhelig, 1, nbelig, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
cgn      write (ulsort,90002) 'tbiaux', (tbiaux(iaux),iaux=1,14)
c
c 2.3. ==> Transfert
c
      if ( codret.eq.0 ) then
c
      do 231 , iaux = 1 , nbelig
        imem(hfmdel+iaux-1) = tbiaux(iaux)
  231 continue
      jaux = nbelig*nbnoel
      do 232 , iaux = 1 , jaux
        imem(hnoeel+iaux-1) = tbiaux(nbelig+iaux)
  232 continue
c
      endif
cgn      call gmprsx ( nompro, nhelig )
cgn      call gmprsx ( nompro, nhelig//'.ConnNoeu' )
cgn      call gmprsx ( nompro, nhelig//'.FamilMED' )
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
