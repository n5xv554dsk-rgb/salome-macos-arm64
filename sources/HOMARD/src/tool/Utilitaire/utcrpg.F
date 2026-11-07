      subroutine utcrpg ( oblopg,
     >                    nolopg, typgeo, ngauss, dimcpg, carsup,
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
c  Entree-Sortie - CReation d'une localisation des Points de Gauss
c  -      -        --                              -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . oblopg .   s . char8  . nom de l'objet points de Gauss             .
c . nolopg .   s . char64 . nom de la localisation cree                .
c . typgeo . e   .   1    . type geometrique au sens MED               .
c . ngauss . e   .   1    . nombre de points de Gauss                  .
c . dimcpg . e   .   1    . dimension des coordonnees des pts de Gauss .
c . carsup . e   .   1    . caracteristiques du support                .
c .        .     .        . 1, si aux noeuds par element               .
c .        .     .        . 2, si aux points de Gauss, associe avec    .
c .        .     .        .    n champ aux noeuds par elements         .
c .        .     .        . 3 si aux points de Gauss autonome          .
c .        .     .        . 0, sinon                                   .
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
      parameter ( nompro = 'UTCRPG' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmreel.h"
#ifdef _DEBUG_HOMARD_
#include "indefi.h"
#endif
#include "indefs.h"
c
c 0.3. ==> arguments
c
      integer typgeo, ngauss, dimcpg, carsup
c
      character*8 oblopg
      character*64 nolopg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer adcono, adcopg, adpopg
c
      integer nbmess
      parameter ( nbmess = 100 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
      texte(1,4) =
     >'(''Creation d''''une localisation de points de Gauss'')'
      texte(1,5) = '(''Objet GM de la localisation : '',a)'
      texte(1,6) = '(''Nom de la localisation : '',a)'
      texte(1,10) = '(''On ne sait pas faire aujourd''''hui.'')'
c
      texte(2,4) = '(''Creation of a localization for Gauss points'')'
      texte(2,5) = '(''GM object for localization : '',a)'
      texte(2,6) = '(''Name for localization : '',a)'
      texte(2,10) = '(''Cannot be constructed today.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'ngauss', ngauss
      write (ulsort,90002) 'carsup', carsup
#endif
c
c====
c 2. creation
c====
c
c 2.1. ==> creation du nom de la localisation
c
      if ( codret.eq.0 ) then
c
      if ( carsup.eq.1 ) then
c
        nolopg = blan64
        if ( typgeo.eq.edtri3 ) then
          nolopg(1:32) = 'TRIA3___ELNO____________________'
        elseif ( typgeo.eq.edtri6 ) then
          nolopg(1:32) = 'TRIA6___ELNO____________________'
        else
          codret = -1
        endif
c
      else
c
        codret = -1
c
      endif
c
      endif
c
c 2.2. ==> allocation de la localisation
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALPG', nompro
#endif
c
      call utalpg ( oblopg,
     >              nolopg, typgeo, ngauss, dimcpg,
     >              adcono, adcopg, adpopg,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      if ( codret.ne.iindef ) then
#else
      if ( codret.ne.0 ) then
#endif
      write (ulsort,texte(langue,5)) oblopg
      if ( oblopg.ne.sindef ) then
        call gmprsx (nompro, oblopg )
        call gmprsx (nompro, oblopg//'.NomLocPG' )
      endif
      endif
c
      endif
c
c 2.3. ==> Les valeurs
c
      if ( codret.eq.0 ) then
c
c 2.3.1. ==> Aux noeuds par element
c
      if ( carsup.eq.1 ) then
c
c 2.3.1.1. ==> Le triangle a 3 noeuds
c
        if ( typgeo.eq.edtri3 ) then
          rmem(adcono   ) = 0.0d0
          rmem(adcono+ 1) = 0.0d0
          rmem(adcono+ 2) = 1.0d0
          rmem(adcono+ 3) = 0.0d0
          rmem(adcono+ 4) = 0.0d0
          rmem(adcono+ 5) = 1.0d0
          jaux = 2*ngauss-1
          do 23111 , iaux = 0 , jaux
            rmem(adcopg+iaux) = rmem(adcono+iaux)
23111     continue
          jaux = ngauss-1
          do 23112 , iaux = 0 , jaux
            rmem(adpopg+iaux) = 1.d0
23112     continue
c
c 2.3.1.2. ==> Le triangle a 6 noeuds
c
        elseif ( typgeo.eq.edtri6 ) then
          rmem(adcono   ) = 0.0d0
          rmem(adcono+ 1) = 0.0d0
          rmem(adcono+ 2) = 1.0d0
          rmem(adcono+ 3) = 0.0d0
          rmem(adcono+ 4) = 0.0d0
          rmem(adcono+ 5) = 1.0d0
          rmem(adcono+ 6) = 0.5d0
          rmem(adcono+ 7) = 0.0d0
          rmem(adcono+ 8) = 0.5d0
          rmem(adcono+ 9) = 0.5d0
          rmem(adcono+10) = 0.0d0
          rmem(adcono+11) = 0.5d0
          jaux = 2*ngauss-1
          do 23121 , iaux = 0 , jaux
            rmem(adcopg+iaux) = rmem(adcono+iaux)
23121     continue
          jaux = ngauss-1
          do 23122 , iaux = 0 , jaux
            rmem(adpopg+iaux) = 1.d0
23122     continue
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) oblopg
      if ( oblopg.ne.sindef ) then
        call gmprsx (nompro, oblopg//'.CoorNoeu' )
        call gmprsx (nompro, oblopg//'.CoorPtGa' )
        call gmprsx (nompro, oblopg//'.PoidPtGa' )
      endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nolopg
      iaux = mod(typgeo,100)
      jaux = (typgeo-iaux) / 100
      call utimpg ( 2, ngauss, iaux, jaux,
     >              rmem(adcono), rmem(adcopg), rmem(1),
     >              ulsort, langue, codret )
#endif
c
      endif
c
c====
c 3. la fin
c====

      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4))
      if ( codret.lt.0 ) then
        write (ulsort,90002) 'typgeo', typgeo
        write (ulsort,90002) 'ngauss', ngauss
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,texte(langue,11+codret))
        codret = abs(codret)
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
