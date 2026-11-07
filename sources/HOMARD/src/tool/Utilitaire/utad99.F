      subroutine utad99 ( nomail,
     >                    phetar, psomar, pfilar, pmerar, adhoar,
     >                    phettr, paretr, pfiltr, ppertr, pnivtr,
     >                    adnmtr, adhotr,
     >                    phetqu, parequ, pfilqu, pperqu, pnivqu,
     >                    adnmqu, adhoqu,
     >                    phette, ptrite,
     >                    phethe, pquahe, pcoquh,
     >                    phetpy, pfacpy, pcofay,
     >                    phetpe, pfacpe, pcofap,
     >                    nhvois, nharet, nhtria, nhquad,
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
c
c    UTilitaire - ADresses - phase 99
c    --           --               --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
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
      parameter ( nompro = 'UTAD99' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer phetar, psomar, pfilar, pmerar, adhoar
      integer phettr, paretr, pfiltr, ppertr, pnivtr
      integer adnmtr, adhotr
      integer phetqu, parequ, pfilqu, pperqu, pnivqu
      integer adnmqu, adhoqu
      integer phette, ptrite
      integer phethe, pquahe, pcoquh
      integer phetpy, pfacpy, pcofay
      integer phetpe, pfacpe, pcofap
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
c====
c 2. structure generale
c====
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
c====
c 3. tableaux
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. tableaux ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 30
      if ( homolo.ge.2 ) then
        iaux = iaux*29
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 (   iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux, adhoar,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
        iaux = 330
        if ( mod(mailet,2).eq.0 ) then
          iaux = iaux*19
        endif
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 (   iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                  jaux,   jaux,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                adnmtr, adhotr,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
        iaux = 330
        if ( mod(mailet,3).eq.0 ) then
          iaux = iaux*19
        endif
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 (   iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                  jaux,   jaux,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                adnmqu, adhoqu,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        iaux = 2
        call utad02 (   iaux, nhtetr,
     >                phette, ptrite, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 26
        call utad02 (   iaux, nhhexa,
     >                phethe, pquahe, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcoquh,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        iaux = 26
        call utad02 (   iaux, nhpyra,
     >                phetpy, pfacpy, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcofay,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        iaux = 26
        call utad02 (   iaux, nhpent,
     >                phetpe, pfacpe, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, pcofap,   jaux,
     >                  jaux,   jaux,   jaux,
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
      end
