      subroutine delist ( nomail, nmprde, avappr,
     >                    lgopts, taopts,
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
c traitement des DEcisions - LISTe des decisions
c                --          ----
c     Remarque : Les appels ont lieu seulement en mode DEBUG
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . nmprde . e   .  ch8   . nom du programme a pister                  .
c . avappr . e   .   1    . 1 : impression avant l'appel a "nmprde"    .
c .        .     .        . 2 : impression apres l'appel a "nmprde"    .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgoptc . tableau des options caracteres             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon, probleme                            .
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
      parameter ( nompro = 'DELIST' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "envca1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      character*6 nmprde
c
      integer avappr
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer pdecfa, pdecar
      integer phetar, pmerar
      integer phettr, paretr, pnivtr
      integer phetqu, parequ, pnivqu
      integer phethe, pquahe
      integer pposif, pfacar
      integer adhoar, adhotr, adhoqu
c
      integer codre0, codre1, codre2
c
      character*8 ntrav1, ntrav2
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
      texte(1,4) = '(/,''Avant appel a '',a6,'' :'',/)'
      texte(1,5) = '(/,''Apres appel a '',a6,'' :'',/)'
      texte(1,10) = '(/,''Mauvais code pour '',a6,'' : '',i8,/)'
c
      texte(2,4) = '(/,''Before calling '',a6,'':'',/)'
      texte(2,5) = '(/,''After calling '',a6,'':'',/)'
      texte(2,10) = '(/,''Bad code for '',a6,'': '',i8,/)'
c
#include "impr03.h"
c
c====
c 2. recuperation des pointeurs, initialisations
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
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
c 2.2. ==> tableaux
c
      if ( codret.eq.0 ) then
c
      iaux = 10
      if ( homolo.ge.2 ) then
        iaux = iaux*29
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 ( iaux, nharet,
     >              phetar, jaux  , jaux  , pmerar,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux, adhoar,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
        iaux = 22
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, jaux  ,  jaux,
     >                  jaux,   jaux,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                  jaux, adhotr,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
        iaux = 22
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                  jaux, adhoqu,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 2
        call utad02 ( iaux, nhhexa,
     >                phethe, pquahe, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      iaux = 3
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >                jaux,   jaux,
     >                jaux,   jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      ntrav1 = taopts(11)
      call gmadoj ( ntrav1, pdecar, iaux, codre1 )
      ntrav2 = taopts(12)
      call gmadoj ( ntrav2, pdecfa, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 3. impressions vraies
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. impressions vraies ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( avappr.eq.1 .or. avappr.eq.2 ) then
        write (ulsort,texte(langue,3+avappr)) nmprde
      else
        write (ulsort,texte(langue,10)) nmprde, avappr
      endif
c
      iaux = 3*5
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DELIS1', nompro
#endif
      call delis1
     >      ( iaux,
     >        imem(pdecar), imem(pdecfa),
     >        imem(pposif), imem(pfacar), imem(phetar), imem(pmerar),
     >        imem(phettr), imem(pnivtr),
     >        imem(phetqu), imem(pnivqu),
     >        ulsort, langue, codret )
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
