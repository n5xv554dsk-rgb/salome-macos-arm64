      subroutine mmagr2 ( nbnotn, nbartn, nbtrtn, nbqutn,
     >                    nbtetn, nbpetn, nbhetn,
     >                    nhnoeu, nharet, nhtria, nhquad,
     >                    nhtetr, nhpent, nhhexa,
     >                    phetno, pcoono, pareno, pderno,
     >                    phetar, psomar, pfilar, pmerar,
     >                    phettr, paretr, pfiltr, ppertr, pnivtr,
     >                    phetqu, parequ, pfilqu, pperqu, pnivqu,
     >                    phette, ptrite, pfilte, pperte, pcotrt,
     >                    phetpe, pfacpe, pfilpe, pperpe, pcofap,
     >                    phethe, pquahe, pfilhe, pperhe, pcoquh,
     >                    pfamno, pfamar, pfamtr, pfamqu,
     >                    pfamte, pfampe, pfamhe,
     >                    ulsort, langue, codret )
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
c    Modification de Maillage - AGRegat - phase 2
c    -               -          ---             -
c    Reallocation des tableaux
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbnotn . e   .   1    . nombre de noeuds total nouveau             .
c . nbartn . e   .   1    . nombre d'aretes total nouveau              .
c . nbtrtn . e   .   1    . nombre de triangles total nouveau          .
c . nbqutn . e   .   1    . nombre de quadrangles total nouveau        .
c . nbtetn . e   .   1    . nombre de tetraaedres total nouveau        .
c . nbpetn . e   .   1    . nombre de pentaedres total nouveau         .
c . nbhetn .  s  .   1    . nombre d'hexaedres total nouveau           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'MMAGR2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
#include "envca1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpe.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer nbnotn, nbartn, nbtrtn, nbqutn
      integer nbtetn, nbpetn, nbhetn
      integer phetno, pcoono, pareno, pderno
      integer phetar, psomar, pfilar, pmerar
      integer phettr, paretr, pfiltr, ppertr, pnivtr
      integer phetqu, parequ, pfilqu, pperqu, pnivqu
      integer phette, ptrite, pfilte, pperte, pcotrt
      integer phetpe, pfacpe, pfilpe, pperpe, pcofap
      integer phethe, pquahe, pfilhe, pperhe, pcoquh
      integer pfamno, pfamar, pfamtr, pfamqu
      integer pfamte, pfampe, pfamhe
c
      character*8 nhnoeu, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpent
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, paux
c
      integer nbmess
      parameter ( nbmess = 30 )
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
#include "mmag01.h"
c
      texte(1,4) = '(''(Re)allocation des tableaux des '',a)'
      texte(1,5) = '(5x,''==> code de retour :'',i8)'
c
      texte(2,4) = '(''(Re)allocation of arrays for '',a)'
      texte(2,5) = '(5x,''==> error code :'',i8)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      if ( nbnotn.gt.0 ) then
        write (ulsort,texte(langue,15)) mess14(langue,3,-1), nbnotn
      endif
      if ( nbartn.gt.0 ) then
        write (ulsort,texte(langue,15)) mess14(langue,3,1), nbartn
      endif
      if ( nbtrtn.gt.0 ) then
        write (ulsort,texte(langue,15)) mess14(langue,3,2), nbtrtn
      endif
      if ( nbqutn.gt.0 ) then
        write (ulsort,texte(langue,15)) mess14(langue,3,4), nbqutn
      endif
      if ( nbtetn.gt.0 ) then
        write (ulsort,texte(langue,15)) mess14(langue,3,3), nbtetn
      endif
      if ( nbpetn.gt.0 ) then
        write (ulsort,texte(langue,15)) mess14(langue,3,7), nbpetn
      endif
      if ( nbhetn.gt.0 ) then
        write (ulsort,texte(langue,15)) mess14(langue,3,6), nbhetn
      endif
#endif
c
      codret = 0
c
c====
c 2. Les noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. noeuds ; codret', codret
#endif
c
      if ( nbnotn.gt.0 .and. nbnoto.ne.nbnotn ) then
c
        if ( codret.eq.0 ) then
cgn         call gmprsx(nompro,nhnoeu)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD05', nompro
#endif
        iaux = 2730
        jaux = 1
        call utad05 ( iaux, jaux, nhnoeu,
     >                nbnoto, nbnotn, sdim,
     >                phetno,
     >                pfamno,
     >                pcoono, pareno, jaux, pderno,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nbnoto = nbnotn
c
        endif
cgn         call gmprsx(nompro,nhnoeu)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,-1)
      write (ulsort,texte(langue,5)) codret
#endif
c
      endif
c
c====
c 3. Les aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Les aretes ; codret', codret
#endif
c
      if ( nbartn.gt.0 .and. nbarto.ne.nbartn ) then
c
        if ( codret.eq.0 ) then
cgn         call gmprsx(nompro,nharet)
c
        iaux = 1
        jaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_ar', nompro
#endif
        call utad06 ( iaux, jaux, 1, nharet,
     >                nbarto, nbartn, 0, 0,
     >                phetar, psomar, pfilar, pmerar,
     >                pfamar,
     >                  paux,   paux,   paux,
     >                  paux,   paux,   paux,  paux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nbarto = nbartn
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1)
      write (ulsort,texte(langue,5)) codret
#endif
c
      endif
c
c====
c 4. Les triangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Les triangles ; codret', codret
#endif
c
      if ( nbtrtn.gt.0 .and. nbtrto.ne.nbtrtn ) then
c
        if ( codret.eq.0 ) then
cgn         call gmprsx(nompro,nhtria)
c
        iaux = 2
        jaux = 2310
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_tr', nompro
#endif
        call utad06 ( iaux, jaux, 1, nhtria,
     >                nbtrto, nbtrtn, 0, 0,
     >                phettr, paretr, pfiltr, ppertr,
     >                pfamtr,
     >                pnivtr,   paux,   paux,
     >                  paux,   paux,   paux,  paux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nbtrto = nbtrtn
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,2)
      write (ulsort,texte(langue,5)) codret
#endif
c
      endif
c
c====
c 5. Les quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Les quadrangles ; codret', codret
#endif
c
      if ( nbqutn.gt.0 .and. nbquto.ne.nbqutn ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 4
        jaux = 330
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_qu', nompro
#endif
        call utal02 (   iaux,   jaux,
     >                nhquad, nbqutn, kaux,
     >                phetqu, parequ, pfilqu, pperqu,
     >                pfamqu,   paux,
     >                pnivqu,   paux,   paux,
     >                  paux,   paux,   paux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 4
        jaux = 7
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_qu', nompro
#endif
        call utad06 ( iaux, jaux, 1, nhquad,
     >                nbquto, nbqutn, 0, 0,
     >                  paux,   paux,   paux,   paux,
     >                pfamqu,
     >                  paux,   paux,   paux,
     >                  paux,   paux,   paux,  paux,
     >                ulsort, langue, codret )
c
        endif
cgn         call gmprsx(nompro,nhquad)
c
        if ( codret.eq.0 ) then
c
        nbquto = nbqutn
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,4)
      write (ulsort,texte(langue,5)) codret
#endif
c
      endif
c
c====
c 6. Les tetraedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Les tetraedres ; codret', codret
#endif
c
      if ( nbtetn.gt.0 .and. nbteto.ne.nbtetn ) then
c
        if ( codret.eq.0 ) then
cgn         call gmprsx(nompro,nhtria)
c
        iaux = 3
        jaux = 2730
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_te', nompro
#endif
        call utad06 ( iaux, jaux, 1, nhtetr,
     >                nbteto, nbtetn, 0, 0,
     >                phette, ptrite, pfilte, pperte,
     >                pfamte,
     >                  paux, pcotrt,   paux,
     >                  paux,   paux,   paux,  paux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nbteto = nbtetn
        nbtecf = nbtetn
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,3)
      write (ulsort,texte(langue,5)) codret
#endif
c
      endif
c
c====
c 7. Les pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. Les pentaedres ; codret', codret
#endif
c
      if ( nbpetn.gt.0 .and. nbpeto.ne.nbpetn ) then
c
        if ( codret.eq.0 ) then
cgn         call gmprsx(nompro,nhpent)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_pe', nompro
#endif
        iaux = 7
        jaux = 390
        kaux = 0
        call utal02 (   iaux,   jaux,
     >                nhpent, nbpetn, kaux,
     >                phetpe, pfacpe, pfilpe, pperpe,
     >                pfampe,   paux,
     >                paux  , pcofap,   paux,
     >                  paux,   paux,   paux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 7
        jaux = 7
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_pe', nompro
#endif
        call utad06 ( iaux, jaux, 1, nhpent,
     >                nbpeto, nbpetn, 0, 0,
     >                  paux,   paux,   paux,   paux,
     >                pfampe,
     >                  paux,   paux,   paux,
     >                  paux,   paux,   paux,  paux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nbpeto = nbpetn
        nbpecf = nbpetn
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,7)
      write (ulsort,texte(langue,5)) codret
#endif
c
      endif
c
c====
c 8. Les hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. Les hexaedres ; codret', codret
#endif
c
      if ( nbhetn.gt.0 .and. nbheto.ne.nbhetn ) then
c
        if ( codret.eq.0 ) then
cgn         call gmprsx(nompro,nhhexa)
c
        iaux = 6
        jaux = 390
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_he', nompro
#endif
        call utal02 (   iaux,   jaux,
     >                nhhexa, nbhetn, kaux,
     >                phethe, pquahe, pfilhe, pperhe,
     >                pfamhe,   paux,
     >                paux  , pcoquh,   paux,
     >                  paux,   paux,   paux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 6
        jaux = 7
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_he', nompro
#endif
        call utad06 ( iaux, jaux, 1, nhhexa,
     >                nbheto, nbhetn, 0, 0,
     >                  paux,   paux,   paux,   paux,
     >                pfamhe,
     >                  paux,   paux,   paux,
     >                  paux,   paux,   paux,  paux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nbheto = nbhetn
        nbhecf = nbhetn
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,6)
      write (ulsort,texte(langue,5)) codret
#endif
c
      endif
c
c====
c 9. la fin
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
