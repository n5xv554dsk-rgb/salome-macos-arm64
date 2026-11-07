      subroutine utad98 ( nomail, option, optio2,
     >                    nbaran, nbarno,
     >                    nbtran, nbtrno,
     >                    nbquan, nbquno,
     >                    nbtean, nbteno, nbtaan, nbtano,
     >                    nbhean, nbheno, nbhaan, nbhano,
     >                    nbpyan, nbpyno, nbyaan, nbyano,
     >                    nbpean, nbpeno, nbpaan, nbpano,
     >                    phetar, psomar, pfilar, pmerar, pancar,
     >                    pnp2ar, adhoar,
     >                    phettr, paretr, pfiltr, ppertr, panctr,
     >                    pnivtr, adpetr, adnmtr, adhotr,
     >                    phetqu, parequ, pfilqu, pperqu, pancqu,
     >                    pnivqu, adhequ, adnmqu, adhoqu,
     >                    phette, ptrite, pcotrt, parete,
     >                    pfilte, pperte, pancte,
     >                    phethe, pquahe, pcoquh, parehe,
     >                    pfilhe, pperhe, panche, adnmhe,
     >                    phetpy, pfacpy, pcofay, parepy,
     >                    pfilpy, pperpy, pancpy,
     >                    phetpe, pfacpe, pcofap, parepe,
     >                    pfilpe, pperpe, pancpe,
     >                    pfamar, pfamtr, pfamqu,
     >                    pfamte, pfamhe, pfampy, pfampe,
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
c    UTilitaire - ADresses - phase 98
c    --           --               --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . option . e   .   1    . 0 : on detruit les objets de taille nulle  .
c .        .     .        . 1 : on garde les objets de taille nulle    .
c . optio2 . e   .   1    . 1 : on raccourcit les volu/face des extrus..
c .        .     .        . 0 : on ne fait rien                        .
c . nbenan . e   .   1    . si < 0 : on ne modifie rien pour l'entite  .
c .        .     .        . si >= 0 : ancien nombre d'entite           .
c . nbenno . e   .   1    . nouveau nombre d'entite                    .
c . nbeaan . e   .   1    . ancien nombre d'entite decrits par aretes  .
c . nbeano . e   .   1    . nouveau nombre d'entite decrits par aretes .
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
      parameter ( nompro = 'UTAD98' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer option, optio2
      integer nbaran, nbarno
      integer nbtran, nbtrno
      integer nbquan, nbquno
      integer nbtean, nbteno, nbtaan, nbtano
      integer nbhean, nbheno, nbhaan, nbhano
      integer nbpyan, nbpyno, nbyaan, nbyano
      integer nbpean, nbpeno, nbpaan, nbpano
      integer phetar, psomar, pfilar, pmerar, pancar, pnp2ar
      integer adhoar
      integer phettr, paretr, pfiltr, ppertr, panctr, pnivtr
      integer adpetr, adnmtr
      integer adhotr
      integer phetqu, parequ, pfilqu, pperqu, pancqu, pnivqu
      integer adhequ, adnmqu
      integer adhoqu
      integer phette, ptrite, pcotrt, parete, pfilte, pperte, pancte
      integer phethe, pquahe, pcoquh, parehe, pfilhe, pperhe, panche
      integer adnmhe
      integer phetpy, pfacpy, pcofay, parepy, pfilpy, pperpy, pancpy
      integer phetpe, pfacpe, pcofap, parepe, pfilpe, pperpe, pancpe
      integer pfamar
      integer pfamtr
      integer pfamqu
      integer pfamte
      integer pfamhe
      integer pfampy
      integer pfampe
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer typenh
c
      integer codre0
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
      texte(1,6) = '(''Modification de taille des tableaux des '',a)'
      texte(1,7) = '(5x,''==> code de retour :'',i8)'
c
      texte(2,6) = '(''Size modification of arrays for '',a)'
      texte(2,7) = '(5x,''==> error code :'',i8)'
c
#include "impr03.h"
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
c 3.1. ==> Les aretes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. ==> aretes, codret', codret
      write (ulsort,90002) 'nbaran', nbaran
      write (ulsort,90002) 'nbarno', nbarno
#endif
c
      if ( ( nbaran.ne.nbarno ) .and. ( nbaran.ge.0 ) ) then
c
        if ( codret.eq.0 ) then
c
        typenh = 1
        iaux = 210
        if ( degre.eq.2 ) then
          iaux = iaux*13
        endif
        call gmobal ( nharet//'.Deraffin', codre0 )
        if ( codre0.eq.2 ) then
          iaux = iaux*23
        endif
        if ( homolo.ge.2 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_ar', nompro
#endif
        call utad06 ( typenh,   iaux, option, nharet,
     >                nbaran, nbarno, 0, 0,
     >                phetar, psomar, pfilar, pmerar,
     >                pfamar,
     >                  jaux, pnp2ar,   jaux,
     >                  jaux, pancar, adhoar,  jaux,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,1)
      write (ulsort,texte(langue,7)) codret
#endif
c
        endif
c
      endif
c
c 3.2. ==> Les triangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. triangles, codret', codret
      write (ulsort,90002) 'nbtran', nbtran
      write (ulsort,90002) 'nbtrno', nbtrno
#endif
c
      if ( ( nbtran.ne.nbtrno ) .and. ( nbtran.ge.0 ) ) then
c
        if ( codret.eq.0 ) then
c
        typenh = 2
        iaux = 7
        if ( nbtran.gt.0 ) then
          iaux = iaux*330
          if ( mod(mailet,2).eq.0 ) then
            iaux = iaux*19
          endif
          if ( homolo.ge.3 ) then
            iaux = iaux*29
          endif
          if ( optio2.eq.1 ) then
            iaux = iaux*13
          endif
        endif
        call gmobal ( nhtria//'.Deraffin', codre0 )
        if ( codre0.eq.2 ) then
          iaux = iaux*23
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_tr', nompro
#endif
        call utad06 ( typenh,   iaux, option, nhtria,
     >                nbtran, nbtrno, 0, 0,
     >                phettr, paretr, pfiltr, ppertr,
     >                pfamtr,
     >                pnivtr, adpetr,   jaux,
     >                adnmtr, panctr, adhotr,  jaux,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,2)
      write (ulsort,texte(langue,7)) codret
#endif
c
        endif
c
      endif
c
c 3.3. ==> Les quadrangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. quadrangles, codret', codret
      write (ulsort,90002) 'nbquan', nbquan
      write (ulsort,90002) 'nbquno', nbquno
#endif
c
      if ( ( nbquan.ne.nbquno ) .and. ( nbquan.ge.0 ) ) then
c
        if ( codret.eq.0 ) then
c
        typenh = 4
        iaux = 2310
        if ( mod(mailet,3).eq.0 ) then
          iaux = iaux*19
        endif
        call gmobal ( nhquad//'.Deraffin', codre0 )
        if ( codre0.eq.2 ) then
          iaux = iaux*23
        endif
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
        if ( optio2.eq.1 ) then
          iaux = iaux*13
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_qu', nompro
#endif
        call utad06 ( typenh,   iaux, option, nhquad,
     >                nbquan, nbquno,      0,      0,
     >                phetqu, parequ, pfilqu, pperqu,
     >                pfamqu,
     >                pnivqu, adhequ,   jaux,
     >                adnmqu, pancqu, adhoqu,   jaux,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,4)
      write (ulsort,texte(langue,7)) codret
#endif
c
        endif
c
      endif
c
c 3.4. ==> Les tetraedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. tetraedres, codret', codret
      write (ulsort,90002) 'nbtean', nbtean
      write (ulsort,90002) 'nbteno', nbteno
      write (ulsort,90002) 'nbtaan, nbtano,', nbtaan, nbtano
#endif
c
      if ( ( nbtean.ne.nbteno ) .and. ( nbtean.ge.0 ) ) then
c
        if ( codret.eq.0 ) then
c
        typenh = 3
        iaux = 7
        if ( nbtean.gt.0 ) then
          iaux = iaux*390
        endif
        call gmobal ( nhtetr//'.Deraffin', codre0 )
        if ( codre0.eq.2 ) then
          iaux = iaux*23
        endif
        if ( ( nbtaan.ne.nbtano ) .and. ( nbtaan.gt.0 ) ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_te', nompro
#endif
        call utad06 ( typenh,   iaux, option, nhtetr,
     >                nbtean, nbteno, nbtaan, nbtano,
     >                phette, ptrite, pfilte, pperte,
     >                pfamte,
     >                  jaux, pcotrt,   jaux,
     >                  jaux, pancte,   jaux, parete,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,3)
      write (ulsort,texte(langue,7)) codret
#endif
c
        endif
c
      endif
c
c 3.5. ==> Les pyramides
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.5. pyramides, codret', codret
      write (ulsort,90002) 'nbpyan', nbpyan
      write (ulsort,90002) 'nbpyno', nbpyno
      write (ulsort,90002) 'nbyaan, nbyano,', nbyaan, nbyano
#endif
c
      if ( ( nbpyan.ne.nbpyno ) .and. ( nbpyan.ge.0 ) ) then
c
        if ( codret.eq.0 ) then
c
        typenh = 5
        iaux = 7
        if ( nbpyan.gt.0 ) then
          iaux = iaux*390
        endif
        call gmobal ( nhpyra//'.Deraffin', codre0 )
        if ( codre0.eq.2 ) then
          iaux = iaux*23
        endif
        if ( ( nbyaan.ne.nbyano ) .and. ( nbyaan.gt.0 ) ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_py', nompro
#endif
        call utad06 ( typenh,   iaux, option, nhpyra,
     >                nbpyan, nbpyno, nbyaan, nbyano,
     >                phetpy, pfacpy, pfilpy, pperpy,
     >                pfampy,
     >                  jaux, pcofay,   jaux,
     >                  jaux, pancpy,   jaux, parepy,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,5)
      write (ulsort,texte(langue,7)) codret
#endif
c
        endif
c
      endif
c
c 3.6. ==> Les hexaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.6. ==> hexaedres, codret', codret
      write (ulsort,90002) 'nbhean', nbhean
      write (ulsort,90002) 'nbheno', nbheno
      write (ulsort,90002) 'nbhaan, nbhano,', nbhaan, nbhano
#endif
c
      if ( ( nbhean.ne.nbheno ) .and. ( nbhean.ge.0 ) ) then
c
        if ( codret.eq.0 ) then
c
        typenh = 6
        iaux = 210*13
        if ( mod(mailet,5).eq.0 ) then
          iaux = iaux*19
        endif
        call gmobal ( nhhexa//'.Deraffin', codre0 )
        if ( codre0.eq.2 ) then
          iaux = iaux*23
        endif
        if ( ( nbhaan.ne.nbhano ) .and. ( nbhaan.gt.0 ) ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_he', nompro
#endif
        call utad06 ( typenh,   iaux, option, nhhexa,
     >                nbhean, nbheno, nbhaan, nbhano,
     >                phethe, pquahe, pfilhe, pperhe,
     >                pfamhe,
     >                  jaux, pcoquh,   jaux,
     >                adnmhe, panche,   jaux, parehe,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,6)
      write (ulsort,texte(langue,7)) codret
#endif
c
        endif
c
      endif
c
c 3.7. ==> Les pentaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.7. ==> pentaedres, codret', codret
      write (ulsort,90002) 'nbpean', nbpean
      write (ulsort,90002) 'nbpeno', nbpeno
      write (ulsort,90002) 'nbpaan, nbpano,', nbpaan, nbpano
#endif
c
      if ( ( nbpean.ne.nbpeno ) .and. ( nbpean.ge.0 ) ) then
c
        if ( codret.eq.0 ) then
c
        typenh = 7
        iaux = 2730
        call gmobal ( nhpent//'.Deraffin', codre0 )
        if ( codre0.eq.2 ) then
          iaux = iaux*23
        endif
        if ( ( nbpaan.ne.nbpano ) .and. ( nbpaan.gt.0 ) ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_pe', nompro
#endif
        call utad06 ( typenh,   iaux, option, nhpent,
     >                nbpean, nbpeno, nbpaan, nbpano,
     >                phetpe, pfacpe, pfilpe, pperpe,
     >                pfampe,
     >                  jaux, pcofap,   jaux,
     >                  jaux, pancpe,   jaux, parepe,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,5)
      write (ulsort,texte(langue,7)) codret
#endif
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
