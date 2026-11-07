      subroutine vcfiad ( lgopti, taopti, lgoptr, taoptr,
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
c    aVant adaptation - FIltrage de l'ADaptation
c     -                 --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options entieres   .
c . taopti . e   . lgopti . tableau des options entieres               .
c . lgoptr . e   .   1    . longueur du tableau des options reelles    .
c . taoptr . es  . lgoptr . tableau des options                        .
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
      parameter ( nompro = 'VCFIAD' )
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
c
      integer nretap, nrsset
      integer iaux
c
      character*6 saux
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
      texte(1,4) = '(/,a6,'' FILTRAGE DE L''''ADAPTATION'')'
      texte(1,5) = '(31(''=''),/)'
      texte(1,6) = '(/,''Influence sur les '',a)'
c
      texte(2,4) = '(/,a6,'' ADAPTATION FILTERING'')'
      texte(2,5) = '(27(''=''),/)'
      texte(2,6) = '(/,''Influence over '',a)'
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
c 2. filtrage par les groupes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. groupes ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( taopti(19).gt.0 ) then
c
        iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCFIA0', nompro
#endif
        call vcfia0 ( lgopti, taopti, lgoptr, taoptr,
     >                lgopts, taopts,
     >                iaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 3. filtrage par un diametre minimal
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. diametre minimal ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( taoptr(3).gt.0.d0 ) then
c
        iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCFIA0', nompro
#endif
        call vcfia0 ( lgopti, taopti, lgoptr, taoptr,
     >                lgopts, taopts,
     >                iaux,
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
