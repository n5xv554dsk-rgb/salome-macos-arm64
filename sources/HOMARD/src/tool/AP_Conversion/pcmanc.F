      subroutine pcmanc ( lgopti, taopti, lgoptr, taoptr,
     >                    lgopts, taopts,
     >                    lgetco, taetco,
     >                    ulsort, langue, codret)
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
c    aPres adaptation - Conversion de MAillage - Non Conforme
c     -                 -             --         -   -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgoptr . e   .   1    . longueur du tableau des options reelles    .
c . taoptr . e   . lgoptr . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'PCMANC' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgoptr
      double precision taoptr(lgoptr)
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nretap, nrsset
      integer iaux
      integer nonexm
c
      character*6 saux
      character*7 saux07
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      if ( taopti(11).eq.26 .or.
     >     taopti(11).eq.36 ) then
        saux07 = 'SATURNE'
      elseif ( taopti(11).eq.46 .or.
     >         taopti(11).eq.56 ) then
        saux07 = 'NEPTUNE'
      elseif ( taopti(11).eq.46 .or.
     >         taopti(11).eq.76 ) then
        saux07 = 'CARMEL '
      else
        saux07 = 'NON CFM'
      endif
c
      texte(1,4) = '(/,a6,1x,'''//saux07//' - COMPLEMENTS'')'
      texte(1,5) = '(28(''=''),/)'
c
      texte(2,4) = '(/,a6,1x,'''//saux07//' - ADDITIONAL OPERATIONS'')'
      texte(2,5) = '(38(''=''),/)'
c
#include "impr03.h"
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5 ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. Passage du maillage 2D au maillage 3D pour un maillage extrude
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. 2D -> 3D ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( taopti(39).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'PCMA23', nompro
#endif
        call pcma23 ( taopts(2),
     >                taopti(40), taoptr(4), taopts(20),
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 3. Les recollements par equivalence
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. recollements ; codret', codret
#endif
c
      if ( taopti(30).eq.-2 .or.
     >     taopti(30).eq.1 .or.
     >     taopti(30).eq.2 .or.
     >     taopti(30).eq.3 ) then
c
        if ( codret.eq.0 ) then
c
        nonexm = 1
        if ( ( taopti(11).eq.36 ) .or. ( taopti(11).eq.56 ) ) then
          nonexm = nonexm*2
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nonexm', nonexm
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMARC', nompro
#endif
        call pcmarc ( taopts(2), taopts(20),
     >                nonexm,
     >                ulsort, langue, codret )
c
        endif
c
      endif
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
c=======================================================================
      endif
c=======================================================================
c
      end
