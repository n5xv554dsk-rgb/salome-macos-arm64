      subroutine sffaff ( suifro,
     >                    ncafdg, ncafan, ncfgnf, ncfgng, ncafar,
     >                    nhsupe, nhsups,
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
c   Suivi de Frontiere - Frontieres AFFichage
c   -        -           -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . suifro . e   .   1    . 1 : pas de suivi de frontiere              .
c .        .     .        . 2x : frontiere discrete                    .
c .        .     .        . 3x : frontiere analytique                  .
c .        .     .        . 5x : frontiere cao                         .
c . ncafdg . e   . char*8 . nom de l'objet des frontieres discretes/CAO.
c .        .     .        . nom des groupes                            .
c . ncafan . e   . char*8 . nom de l'objet des frontieres analytiques :.
c .        .     .        . nom des groupes                            .
c . ncfgnf . es  . char*8 . lien frontiere/groupe : nom des frontieres .
c . ncfgng . e   . char*8 . lien frontiere/groupe : nom des groupes    .
c . ncafar . e   . char*8 . nom de l'objet des frontieres analytiques :.
c .        .     .        . valeurs reelles                            .
c . nhsupe . e   . char*8 . informations supplementaires maillage      .
c . nhsups . e   . char*8 . informations supplementaires maillage      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . en entree = celui du module d'avant        .
c .        .     .        . en sortie = celui du module en cours       .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 2x : probleme dans les memoires            .
c .        .     .        . 2x : probleme dans les fichiers            .
c .        .     .        . 5 : mauvaises options                      .
c .        .     .        . 6 : problemes dans les noms d'objet        .
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
      parameter ( nompro = 'SFFAFF' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envada.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer suifro
c
      character*8 ncafdg, ncafan, ncfgnf, ncfgng, ncafar
      character*8 nhsupe, nhsups
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
c
      integer adcafr, adfrgr, adnogr
      integer pttgrd, ptngrd, pointd
      integer adcpoi, adctai, adctab
      integer adfpoi, adftai, adftab
      integer adgpoi, adgtai, adgtab
      integer nbfrdc, nbfrgr, nbfran
c
      integer codre0
      integer codre1, codre2, codre3
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
      texte(1,6) = '(''Nombre de frontieres discretes   :'',i8)'
      texte(1,7) = '(''Nombre de liens frontiere/groupe :'',i8)'
      texte(1,8) = '(''Nombre de frontieres analytiques :'',i8)'
c
      texte(2,6) = '(''Number of discrete boundaries  :'',i8)'
      texte(2,7) = '(''Number of links boundary/group :'',i8)'
      texte(2,8) = '(''Number of analytical boundaries:'',i8)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'suifro', suifro
#endif
c
c====
c 2. Les frontieres discretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Fr. discretes ; codret', codret
#endif
c
      if ( ( mod(suifro,2).eq.0 )  .and.
     >     ( nbiter.eq.0 ) ) then
c
c 2.1. ==> Combien de frontieres discretes
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, ncafdg )
#endif
c
        if ( codret.eq.0 ) then
c
        call gmliat ( ncafdg, 1, nbfrdc, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) nbfrdc
#endif
c
c 2.2. ==> Affichage des frontieres discretes
c
        if ( nbfrdc.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          call gmprsx(nompro,ncafdg//'.Pointeur')
          call gmprsx(nompro,ncafdg//'.Taille')
          call gmprsx(nompro,ncafdg//'.Table')
#endif
          iaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
          call utadpt ( ncafdg, iaux,
     >                    jaux,   jaux,
     >                  pointd, pttgrd, ptngrd,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFFAF1', nompro
#endif
          call sffaf1 ( nbfrdc,
     >                  imem(pointd), imem(pttgrd), smem(ptngrd),
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
c
c====
c 3. Les frontieres analytiques
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Fr. analytiques; codret', codret
#endif
c
      if ( ( mod(suifro,3).eq.0 )  .and.
     >     ( nbiter.eq.0 ) ) then
c
c 3.1. ==> Combien de liens frontiere/groupe ?
c
cgn        call gmprsx (nompro,ncfgng )
c
        if ( codret.eq.0 ) then
c
        call gmliat ( ncfgnf, 1, nbfrgr, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nbfrgr
#endif
c
        if ( nbfrgr.gt.0 ) then
c
c 3.2. ==> Description des noms des frontieres dans les liens
c
          if ( codret.eq.0 ) then
c
cgn        call gmprsx (nompro,ncfgnf//'.Pointeur' )
cgn        call gmprsx (nompro,ncfgnf//'.Table' )
cgn        call gmprsx (nompro,ncfgnf//'.Taille' )
          iaux = 3
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
          call utadpt ( ncfgnf, iaux,
     >                  jaux, kaux,
     >                  adfpoi, adftai, adftab,
     >                  ulsort, langue, codret )
c
          endif
c
c 3.3. ==> Description des noms des groupes dans les liens
c
          if ( codret.eq.0 ) then
cgn        call gmprsx (nompro,ncfgng//'.Pointeur' )
cgn        call gmprsx (nompro,ncfgng//'.Table' )
cgn        call gmprsx (nompro,ncfgng//'.Taille' )
          iaux = 3
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
          call utadpt ( ncfgng, iaux,
     >                  jaux, kaux,
     >                  adgpoi, adgtai, adgtab,
     >                  ulsort, langue, codret )
c
          endif
c
c 3.4. ==> Description des frontieres
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, ncafar )
#endif
c
          if ( codret.eq.0 ) then
c
          call gmadoj ( ncafar, adcafr, iaux, codret )
c
          endif
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
          call gmprsx(nompro,ncafan//'.Pointeur')
          call gmprsx(nompro,ncafan//'.Taille')
          call gmprsx(nompro,ncafan//'.Table')
#endif
c
            iaux = 6
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
            call utadpt ( ncafan, iaux,
     >                    nbfran, kaux,
     >                    adcpoi, adctai, adctab,
     >                    ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) nbfran
#endif
c
            endif
c
c 3.5. ==> Affichage des frontieres analytiques
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFFAF2', nompro
#endif
          call sffaf2 ( nbfrgr, nbfran,
     >                  rmem(adcafr),
     >                  imem(adcpoi), imem(adctai), smem(adctab),
     >                  imem(adfpoi), imem(adftai), smem(adftab),
     >                  imem(adgpoi), imem(adgtai), smem(adgtab),
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
c
c====
c 4. Les frontieres CAO
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. frontieres  CAO ; codret', codret
#endif
c
      if ( ( mod(suifro,5).eq.0 ) .or.
     >     ( nbiter.ge.1 ) ) then
c
c 4.1. ==> Combien de frontieres ?
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, nhsupe//'.Tab10' )
        call gmprsx (nompro, nhsups//'.Tab10' )
#endif
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhsupe//'.Tab10', adfrgr, iaux, codre1 )
        call gmadoj ( nhsups//'.Tab10', adnogr, iaux, codre2 )
        call gmliat ( nhsupe, 10, nbfrgr, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) nbfrgr
#endif
c
c 4.2. ==> Affichage des frontieres
c
        if ( nbfrgr.gt.0 ) then
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFFAF3', nompro
#endif
          call sffaf3 ( nbfrgr, imem(adfrgr), smem(adnogr),
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
c
c====
c 5. la fin
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
