      subroutine cmal01 ( typall, extrus,
     >                    nomail, ndecfa,
     >                    nbnoan, nbnono,
     >                    nbaran, nbarno,
     >                    nbtran, nbtrno,
     >                    nbquan, nbquno,
     >                    nbtean, nbteno, nbtaan, nbtano,
     >                    nbhean, nbheno, nbhaan, nbhano,
     >                    nbpean, nbpeno, nbpaan, nbpano,
     >                    nbpyan, nbpyno, nbyaan, nbyano,
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
c    Creation du Maillage - ALlocations - 01
c    -           -          --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typall . e   .    1   . type d'allocation                          .
c .        .     .        . 0 : raffinement                            .
c .        .     .        . 1 : deraffinement                          .
c .        .     .        . 2 : conformite                             .
c . extrus . e   .    1   . prise en compte d'extrusion                .
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . ndecfa . e   .  ch8   . nom de l'objet des decisions sur les faces .
c . nbnoan . e   .    1   . nombre de noeuds - ancien                  .
c . nbnono . e   .    1   . nombre de noeuds - nouveau                 .
c . nbaran . e   .    1   . nombre d'aretes - ancien                   .
c . nbarno . e   .    1   . nombre d'aretes - nouveau                  .
c . nbtran . e   .    1   . nombre de triangles - ancien               .
c . nbtrno . e   .    1   . nombre de triangles - nouveau              .
c . nbquan . e   .    1   . nombre de quadrangles - ancien             .
c . nbquno . e   .    1   . nombre de quadrangles - nouveau            .
c . nbtean . e   .    1   . nombre de tetraedres - ancien              .
c . nbteno . e   .    1   . nombre de tetraedres - nouveau             .
c . nbtaan . e   .    1   . nombre de tetraedres - par aretes - ancien .
c . nbtano . e   .    1   . nombre de tetraedres - par aretes - nouveau.
c . nbhean . e   .    1   . nombre d'hexaedres - ancien                .
c . nbheno . e   .    1   . nombre d'hexaedres - nouveau               .
c . nbhaan . e   .    1   . nombre d'hexaedres - par aretes - ancien   .
c . nbhano . e   .    1   . nombre d'hexaedres - par aretes - nouveau  .
c . nbpean . e   .    1   . nombre de pentaedres - ancien              .
c . nbpeno . e   .    1   . nombre de pentaedres - nouveau             .
c . nbpaan . e   .    1   . nombre de pentaedres - par aretes - ancien .
c . nbpano . e   .    1   . nombre de pentaedres - par aretes - nouveau.
c . nbpyan . e   .    1   . nombre de pyramides - ancien               .
c . nbpyno . e   .    1   . nombre de pyramides - nouveau              .
c . nbyaan . e   .    1   . nombre de pyramides - par aretes - ancien  .
c . nbyano . e   .    1   . nombre de pyramides - par aretes - nouveau .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .   1    . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . e/s .   1    . code de retour des modules                 .
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
      parameter ( nompro = 'CMAL01' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer typall
c
      character*8 nomail
      character*8 ndecfa
c
      integer nbnoan, nbnono
      integer nbaran, nbarno
      integer nbtran, nbtrno
      integer nbquan, nbquno
      integer nbtean, nbteno, nbtaan, nbtano
      integer nbhean, nbheno, nbhaan, nbhano
      integer nbpyan, nbpyno, nbyaan, nbyano
      integer nbpean, nbpeno, nbpaan, nbpano
c
      logical extrus
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, paux
c
      integer codre0
      integer codre1, codre2
      integer iaux1, iaux2
      integer un
      integer pdecfa
      integer pcoono, phetno, pareno, pancno
      integer psomar, pposif, phetar, pfilar, pmerar
      integer pancar, pnp2ar
      integer paretr, phettr, pfiltr, ppertr, pnivtr
      integer adpetr, panctr, adnmtr
      integer parequ, phetqu, pfilqu, pperqu, pnivqu
      integer adhequ, pancqu, adnmqu
      integer phette, ptrite, pcotrt, parete, pfilte, pperte, pancte
      integer phethe, pquahe, pcoquh, parehe, pfilhe, pperhe, panche
      integer adnmhe
      integer phetpy, pfacpy, pcofay, parepy, pfilpy, pperpy, pancpy
      integer phetpe, pfacpe, pcofap, parepe, pfilpe, pperpe, pancpe
      integer adhono, adhoar, adhotr, adhoqu
      integer pfamno, pfamar, pfamtr, pfamqu
      integer pfamte, pfamhe, pfampe, pfampy
      integer typenh
      integer option, optio2
c
      logical eancno, eancar, eanctr, eancqu
      logical eancte, eanche, eancpe, eancpy
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
c
      data un / 1 /
c ______________________________________________________________________
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typall', typall
      write (ulsort,90002) 'no', nbnoan, nbnono
      write (ulsort,90002) 'ar', nbaran, nbarno
      write (ulsort,90002) 'tr', nbtran, nbtrno
      write (ulsort,90002) 'qu', nbquan, nbquno
      write (ulsort,90002) 'te', nbtean, nbteno, nbtaan, nbtano
      write (ulsort,90002) 'he', nbhean, nbheno, nbhaan, nbhano
      write (ulsort,90002) 'py', nbpyan, nbpyno, nbyaan, nbyano
      write (ulsort,90002) 'pe', nbpean, nbpeno, nbpaan, nbpano
#endif
c
c 1.2. messages
c
      eancno = .false.
c
c====
c 2. recuperation des pointeurs
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
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
c====
c 3. reallocation des tableaux avec les nouvelles dimensions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. reallocation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. ==> noeuds, codret', codret
      write (ulsort,90002) 'nbnoan', nbnoan
      write (ulsort,90002) 'nbnono', nbnono
#endif
c
      if ( nbnoan.ne.nbnono ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 210
        call gmobal ( nhnoeu//'.Deraffin', codre0 )
        if ( codre0.eq.2 ) then
          eancno = .true.
          iaux = iaux*13
        endif
        if ( homolo.ge.1 ) then
          iaux = iaux*11
        endif
        jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD05', nompro
#endif
        call utad05 ( iaux, jaux, nhnoeu,
     >                nbnoan, nbnono, sdim,
     >                phetno,
     >                pfamno,
     >                pcoono, pareno, adhono, pancno,
     >                ulsort, langue, codret )
c
        call gmecat ( nhnoeu, 1, nbnono, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
      endif
c
c 3.2. ==> Les entites
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. ==> entites, codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      option = 1
      if ( extrus ) then
        optio2 = 1
      else
        optio2 = 0
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD98', nompro
#endif
      call utad98 ( nomail, option, optio2,
     >              nbaran, nbarno,
     >              nbtran, nbtrno,
     >              nbquan, nbquno,
     >              nbtean, nbteno, nbtaan, nbtano,
     >              nbhean, nbheno, nbhaan, nbhano,
     >              nbpyan, nbpyno, nbyaan, nbyano,
     >              nbpean, nbpeno, nbpaan, nbpano,
     >              phetar, psomar, pfilar, pmerar, pancar,
     >              pnp2ar, adhoar,
     >              phettr, paretr, pfiltr, ppertr, panctr,
     >              pnivtr, adpetr, adnmtr, adhotr,
     >              phetqu, parequ, pfilqu, pperqu, pancqu,
     >              pnivqu, adhequ, adnmqu, adhoqu,
     >              phette, ptrite, pcotrt, parete,
     >              pfilte, pperte, pancte,
     >              phethe, pquahe, pcoquh, parehe,
     >              pfilhe, pperhe, panche, adnmhe,
     >              phetpy, pfacpy, pcofay, parepy,
     >              pfilpy, pperpy, pancpy,
     >              phetpe, pfacpe, pcofap, parepe,
     >              pfilpe, pperpe, pancpe,
     >              pfamar, pfamtr, pfamqu,
     >              pfamte, pfamhe, pfampy, pfampe,
     >              ulsort, langue, codret )
c
      endif
c
c 3.3. ==> triangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. triangles, codret', codret
      write (ulsort,90002) 'nbtran', nbtran
      write (ulsort,90002) 'nbtrno', nbtrno
#endif
c
      if ( nbtran.ne.nbtrno ) then
c
        if ( nbtran.eq.0 ) then
c
          if ( codret.eq.0 ) then
c
          typenh = 2
          iaux = 330
          if ( mod(mailet,2).eq.0 ) then
            iaux = iaux*19
          endif
          if ( homolo.ge.3 ) then
            iaux = iaux*29
          endif
          kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_tr', nompro
#endif
          call utal02 ( typenh, iaux,
     >                  nhtria, nbtrno, kaux,
     >                  phettr, paretr, pfiltr, ppertr,
     >                    paux,  paux,
     >                  pnivtr,   paux,   paux,
     >                  adnmtr, adhotr, paux,
     >                  ulsort, langue, codret )
c
          call gmecat ( nhtria, 1, nbtrno, codre0 )
c
          codret = max ( abs(codre0), codret )
c
          endif
c
        endif
c
      endif
c
c 3.4. ==> tetraedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. tetraedres, codret', codret
      write (ulsort,90002) 'nbtean', nbtean
      write (ulsort,90002) 'nbteno', nbteno
      write (ulsort,90002) 'nbtano', nbtano
#endif
c
      if ( nbtean.ne.nbteno ) then
c
        if ( codret.eq.0 ) then
c
        typenh = 3
        iaux = 1
        if ( nbtean.eq.0 ) then
          iaux = iaux*390
        endif
        if ( nbtano.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_te', nompro
#endif
        call utal02 ( typenh, iaux,
     >                nhtetr, nbteno, nbtano,
     >                phette, ptrite, pfilte, pperte,
     >                  paux,  paux,
     >                  paux, pcotrt,   paux,
     >                  paux,   paux, parete,
     >                ulsort, langue, codret )
c
        call gmecat ( nhtetr, 1, nbteno, codre1 )
        call gmecat ( nhtetr, 2, nbtano, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
      endif
c
c 3.5. ==> pyramides
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.5. pyramides, codret', codret
      write (ulsort,90002) 'nbpyan', nbpyan
      write (ulsort,90002) 'nbpyno', nbpyno
      write (ulsort,90002) 'nbyano', nbyano
#endif
c
      if ( nbpyan.ne.nbpyno ) then
c
        if ( codret.eq.0 ) then
c
        typenh = 5
        iaux = 1
        if ( nbpyan.eq.0 ) then
          iaux = iaux*390
        endif
        if ( nbyano.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_py', nompro
#endif
        call utal02 ( typenh, iaux,
     >                nhpyra, nbpyno, nbyano,
     >                phetpy, pfacpy, pfilpy, pperpy,
     >                  paux,  paux,
     >                  paux, pcofay,   paux,
     >                  paux,   paux, parepy,
     >                ulsort, langue, codret )
c
        call gmecat ( nhpyra, 1, nbpyno, codre1 )
        call gmecat ( nhpyra, 2, nbyano, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        endif
c
      endif
c
c 3.6. ==> hexaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.6. hexaedres, codret', codret
      write (ulsort,90002) 'nbhean', nbhean
      write (ulsort,90002) 'nbheno', nbheno
      write (ulsort,90002) 'nbhano', nbhano
#endif
c
      if ( nbhean.ne.nbheno ) then
c
        if ( codret.eq.0 ) then
c
        typenh = 6
c
        if ( nbhean.eq.0 ) then
          iaux = 390
        else
          iaux = 1
        endif
        if ( nbhano.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_he', nompro
#endif
          call utal02 ( typenh, iaux,
     >                  nhhexa, nbheno, nbhano,
     >                  phethe, pquahe, pfilhe, pperhe,
     >                    paux,  paux,
     >                    paux, pcoquh,   paux,
     >                    paux,   paux, parehe,
     >                  ulsort, langue, codret )
c
          call gmecat ( nhhexa, 1, nbheno, codre1 )
          call gmecat ( nhhexa, 2, nbhano, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
c
        endif
c
      endif
c
c====
c 4. tableaux speciaux
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. tableaux speciaux ; codret', codret
#endif
c
c 4.1. ==> decisions
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1. decisions, codret', codret
#endif
c
      if ( typall.eq.0 .or. typall.eq.1 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GMMOD', nompro
      write (ulsort,90002) 'nbtran', nbtran
      write (ulsort,90002) 'nbtrno', nbtrno
      write (ulsort,90002) 'nbquan', nbquan
      write (ulsort,90002) 'nbquno', nbquno
#endif
        call gmmod ( ndecfa,
     >               pdecfa, -nbquan, -nbquno,  nbtran, nbtrno, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
      endif
c
c 4.2. ==> voisinages
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. voisinages, codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux1 = nbaran + 1
      iaux2 = nbarno + 1
      call gmmod ( nhvois//'.1D/2D.Pointeur',
     >             pposif, iaux1,  iaux2,  un, un, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
c 4.3. ==> deraffinement
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nharet//'.Deraffin', codre0 )
      if ( codre0.eq.2 ) then
        eancar = .true.
      else
        eancar = .false.
      endif
c
      call gmobal ( nhtria//'.Deraffin', codre0 )
      if ( codre0.eq.2 ) then
        eanctr = .true.
      else
        eanctr = .false.
      endif
c
      call gmobal ( nhquad//'.Deraffin', codre0 )
      if ( codre0.eq.2 ) then
        eancqu = .true.
      else
        eancqu = .false.
      endif
c
      call gmobal ( nhtetr//'.Deraffin', codre0 )
      if ( codre0.eq.2 ) then
        eancte = .true.
      else
        eancte = .false.
      endif
c
      call gmobal ( nhhexa//'.Deraffin', codre0 )
      if ( codre0.eq.2 ) then
        eanche = .true.
      else
        eanche = .false.
      endif
c
      call gmobal ( nhpyra//'.Deraffin', codre0 )
      if ( codre0.eq.2 ) then
        eancpy = .true.
      else
        eancpy = .false.
      endif
c
      call gmobal ( nhpent//'.Deraffin', codre0 )
      if ( codre0.eq.2 ) then
        eancpe = .true.
      else
        eancpe = .false.
      endif
c
      endif
c
c====
c 5. initialisations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. initialisations ; codret', codret
      write (ulsort,99002) 'eancno-ar-tr-qu-te-he-pe-py',
     > eancno, eancar, eanctr, eancqu, eancte, eanche, eancpe, eancpy
#endif
c
      if ( typall.eq.0 .or. typall.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'CMIN00', nompro
#endif
        call cmin00 ( typall,
     >                degre, homolo,
     >                eancno, nbnoan, nbnono,
     >                eancar, nbaran, nbarno,
     >                eanctr, nbtran, nbtrno,
     >                eancqu, nbquan, nbquno,
     >                eancte, nbtean, nbteno,
     >                eanche, nbhean, nbheno,
     >                eancpe, nbpean, nbpeno,
     >                eancpy, nbpyan, nbpyno,
     >                imem(pdecfa),
     >                imem(pancno), imem(adhono),
     >                imem(pancar), imem(adhoar), imem(pnp2ar),
     >                imem(panctr), imem(adhotr),
     >                imem(pancqu), imem(adhoqu),
     >                imem(pancte), imem(panche),
     >                imem(pancpe), imem(pancpy) )
c
        endif
c
      endif
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
