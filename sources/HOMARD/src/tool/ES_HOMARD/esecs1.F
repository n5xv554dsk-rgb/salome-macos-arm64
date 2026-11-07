      subroutine esecs1 ( idfmed,
     >                    nomail,
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
c  Entree-Sortie : ECriture des informations Supplementaires - 1
c  -      -        --                        -                 -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomail . e   . char*8 . structure du maillage a ecrire             .
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
      parameter ( nompro = 'ESECS1' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
c
      character*8 nomail
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer adinsu, lginsu
c
      character*2 saux02
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''... Ecriture des renumerotations'')'
      texte(1,7) = '(''Premieres valeurs : '',10i6)'
c
      texte(2,4) = '(''... Writings of numbering'')'
      texte(2,7) = '(''First values : '',10i6)'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. Ecriture des informations supplementaires sous forme de profil
c====
c
      do 21 , iaux = 1, 10
c
c 2.1. ==> decodage des caracteristiques
c
        if ( codret.eq.0 ) then
c
        jaux = iaux
        call utench ( jaux, 'g', kaux, saux02,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        noprof = blan64
c                       123456789012
        noprof(1:12) = 'InfoSupE_Tab'
        noprof(13:kaux+12) = saux02(1:kaux)
        call gmobal ( nomail//'.InfoSupE.Tab'//saux02(1:kaux), codret )
c
        endif
c
        if ( codret.eq.2 ) then
c
        call gmadoj ( nomail//'.InfoSupE.Tab'//saux02(1:kaux),
     >                adinsu, lginsu, codret )
c
        else
c
          goto 21
c
        endif
cgn        print *,saux02,lginsu
c
c 2.2. ==> Ecriture sous forme de profil
c
        if ( lginsu.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,61)) noprof
        write (ulsort,texte(langue,62)) lginsu
        write (ulsort,texte(langue,7))
     > (imem(jaux), jaux = adinsu, adinsu+min(9,lginsu-1))
cgn        write (ulsort,91020) (imem(jaux),jaux=adinsu,adinsu+lginsu-1)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW', nompro
#endif
        call mpfprw ( idfmed, noprof, lginsu, imem(adinsu), codret )
c
        endif
c
        endif
c
   21 continue
c
c====
c 3. la fin
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
