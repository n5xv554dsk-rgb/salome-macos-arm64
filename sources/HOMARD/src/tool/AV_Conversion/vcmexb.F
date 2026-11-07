      subroutine vcmexb ( nomail, maext0,
     >                    phetno,
     >                    pcoono, pareno, adhono, adcocs,
     >                    adnohn, adnocn,
     >                    phetar, psomar, pfilar, pmerar,
     >                    pnp2ar, adhoar,
     >                    phettr, paretr, pfiltr, ppertr,
     >                    pnivtr, adnmtr, adhotr, adpetr,
     >                    adtrhn, adtrcn,
     >                    phetqu, parequ, pfilqu, pperqu,
     >                    pnivqu, adnmqu, adhoqu, adhequ,
     >                    adquhn, adqucn,
     >                    phethe, pquahe, pcoquh,
     >                    phetpe, pfacpe, pcofap,
     >                    pfamno, pcfano,
     >                    pfammp, pcfamp,
     >                    pfamar, pcfaar,
     >                    pfamtr, pcfatr,
     >                    pfamqu, pcfaqu,
     >                    pfamhe, pcfahe,
     >                    pfampe, pcfape,
     >                    pposif, pfacar,
     >                    nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >                    nhhexa, nhpent, norenu,
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
c    aVant adaptation - Conversion de Maillage EXtrude - phase B
c     -                 -             -        --              -
c    Recuperation des adresses
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
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
      parameter ( nompro = 'VCMEXB' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
c
#include "envada.h"
#include "envex1.h"
#include "envca1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nbfami.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer maext0
      integer phetno, pcoono, pareno, adcocs
      integer phetar, psomar, pfilar, pmerar, pnp2ar
      integer phettr, paretr, pfiltr, ppertr, pnivtr, adnmtr, adpetr
      integer phetqu, parequ, pfilqu, pperqu, pnivqu, adnmqu, adhequ
      integer phethe, pquahe, pcoquh
      integer phetpe, pfacpe, pcofap
      integer pposif, pfacar
c
      integer adnohn, adnocn
      integer adtrhn, adtrcn
      integer adquhn, adqucn
c
      integer pfamno, pcfano
      integer pfammp, pcfamp
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
      integer pfamhe, pcfahe
      integer pfampe, pcfape
      integer adhono, adhoar, adhotr, adhoqu
c
      character*8 nomail
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhhexa, nhpent
      character*8 norenu
      character*8 nhvois
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer tbiaux(1)
c
      character*8 nhtetr, nhpyra
      character*8 nhelig
      character*8 nhsupe, nhsups
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
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
      texte(1,4) = '(''Gestion de la memoire'')'
c
      texte(2,4) = '(''Memory management'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
      codret = 0
c
#include "impr03.h"
c
c====
c 2. la structure generale
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. structures gale ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 3. Tableaux
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. ==> tableaux ; codret', codret
      call dmflsh(iaux)
#endif
c
c 3.1. ==> Les noeuds
c
      if ( codret.eq.0 ) then
c
      iaux = 3990
      if ( homolo.ge.1 ) then
        iaux = iaux*11
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 (   iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono, pareno, adhono, adcocs,
     >              ulsort, langue, codret )
c
c 3.2. ==> Les entites
c
      if ( nbfmpo.ne.0 ) then
c
        iaux = 259
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_mp', nompro
#endif
        call utad02 (   iaux, nhmapo,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfammp, pcfamp,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      iaux = 7770
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
      if ( homolo.ge.2 ) then
        iaux = iaux*29
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 (   iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >              pfamar, pcfaar,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux, adhoar,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbftri.ne.0 ) then
c
        iaux = 37
        if ( nbtrto.ne.0 ) then
          iaux = iaux*2310
          if ( mod(mailet,2).eq.0 ) then
            iaux = iaux*19
          endif
          if ( homolo.ge.3 ) then
            iaux = iaux*29
          endif
          if ( nbiter.ge.1 ) then
            iaux = iaux*13
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 (   iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                pfamtr, pcfatr,   jaux,
     >                pnivtr, adpetr,   jaux,
     >                adnmtr, adhotr,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfqua.ne.0 ) then
c
        iaux = 37
        if ( nbquto.ne.0 ) then
          iaux = iaux*2310
          if ( mod(mailet,3).eq.0 ) then
            iaux = iaux*19
          endif
          if ( homolo.ge.3 ) then
            iaux = iaux*29
          endif
          if ( nbiter.ge.1 ) then
            iaux = iaux*13
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 (   iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                pfamqu, pcfaqu,   jaux,
     >                pnivqu, adhequ,   jaux,
     >                adnmqu, adhoqu,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfhex.ne.0 ) then
c
        iaux = 37
        if ( nbheto.ne.0 ) then
          iaux = iaux*182
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 (   iaux, nhhexa,
     >                phethe, pquahe,   jaux,  jaux,
     >                pfamhe, pcfahe,   jaux,
     >                  jaux, pcoquh,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfpen.ne.0 ) then
c
        iaux = 37
        if ( nbpeto.ne.0 ) then
          iaux = iaux*182
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 (   iaux, nhpent,
     >                phetpe, pfacpe,   jaux,  jaux,
     >                pfampe, pcfape,   jaux,
     >                  jaux, pcofap,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.3. ==> Les voisinages
c
      if ( codret.eq.0 ) then
c
      iaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      call utad04 ( iaux, nhvois,
     >              jaux,   jaux, pposif, pfacar,
     >              jaux,   jaux,
     >              jaux,   jaux,   jaux,   jaux,
     >              jaux,   jaux,   jaux,
     >              jaux,   jaux,   jaux,
     >              jaux,   jaux,   jaux,
     >              jaux,   jaux,   jaux,
     >            ulsort, langue, codret )
c
      endif
c
c 3.4. ==> Les liens triangle/pentaedre et quadrangle/hexaedre
c
      if ( nbiter.eq.0 ) then
c
        if ( nbftri.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 2
          jaux = 13
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_tr', nompro
#endif
          call utal02 (   iaux,   jaux,
     >                  nhtria, nbtrto,      0,
     >                    kaux,   kaux,   kaux,   kaux,
     >                    kaux,   kaux,
     >                    kaux, adpetr,   kaux,
     >                    kaux,   kaux,   kaux,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
        if ( nbfqua.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 4
          jaux = 13
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAL02_qu', nompro
#endif
          call utal02 (   iaux,   jaux,
     >                  nhquad, nbquto,      0,
     >                    kaux,   kaux,   kaux,   kaux,
     >                    kaux,   kaux,
     >                    kaux, adhequ,   kaux,
     >                    kaux,   kaux,   kaux,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
c
c====
c 4. Rableaux lies a la renumerotation
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. renumerotation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_no', nompro
#endif
      iaux = -1
      jaux = 210
      call utre03 ( iaux, jaux, norenu,
     >              renoac, renoto, adnohn, adnocn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( nbtrto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTRE03_tr', nompro
#endif
        iaux = 2
        jaux = -210
        call utre03 ( iaux, jaux, norenu,
     >                retrac, retrto, adtrhn, adtrcn,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTRE03_qu', nompro
#endif
      iaux = 4
      jaux = -210
      call utre03 ( iaux, jaux, norenu,
     >              requac, requto, adquhn, adqucn,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 5. Impressions des familles d'origine
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Impressions familles ; codret', codret
#endif
c
      nbftet = 0
      nbfpyr = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECFE - initial', nompro
#endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call utecfe ( maext0,
     >              imem(pfamno), imem(pcfano),
     >              imem(pfammp), imem(pcfamp),
     >              imem(pfamar), imem(pcfaar),
     >              imem(pfamtr), imem(pcfatr),
     >              imem(pfamqu), imem(pcfaqu),
     >                    tbiaux,       tbiaux,
     >              imem(pfamhe), imem(pcfahe),
     >                    tbiaux,       tbiaux,
     >              imem(pfampe), imem(pcfape),
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 6. la fin
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
