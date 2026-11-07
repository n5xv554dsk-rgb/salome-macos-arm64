      subroutine pccapr ( npfopa, npprof, liprof,
     >                    nbpara, carenf, carach,
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
c    aPres adaptation - mise a jour des CAracteristiques
c     -                                 --
c                                   des PRofils
c                                       --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . npfopa . e   .   1    . nombre de fonctions a traiter              .
c . npprof . es  .   1    . nombre de profils en sortie enregistres    .
c . liprof . es  . char*8 . nom des objets de type 'Profil' enregistres.
c . nbpara . e   .   1    . nombre de parametres a enregistrer par fonc.
c . carenf .   s .nbpara* . caracteristiques entieres des fonctions :  .
c .        .     .  nnfopa.  1 : 0, pour une fonction ancienne isolee  .
c .        .     .        .      1, pour une ancienne associee a une   .
c .        .     .        .         autre fonction                     .
c .        .     .        .      -1, pour une nouvelle fonction        .
c .        .     .        .  2 : typcha                                .
c .        .     .        .  3 : typgeo                                .
c .        .     .        .  4 : typass                                .
c .        .     .        .  5 : ngauss                                .
c .        .     .        .  6 : nnenmx                                .
c .        .     .        .  7 : nnvapr                                .
c .        .     .        .  8 : carsup                                .
c .        .     .        .  9 : nbtafo                                .
c .        .     .        . 10 : anvale                                .
c .        .     .        . 11 : anvalr                                .
c .        .     .        . 12 : anobch                                .
c .        .     .        . 13 : adprpg                                .
c .        .     .        . 14 : anlipr                                .
c .        .     .        . 15 : npenmx                                .
c .        .     .        . 16 : npvapr                                .
c .        .     .        . 17 : apvale                                .
c .        .     .        . 18 : apvalr                                .
c .        .     .        . 19 : apobch                                .
c .        .     .        . 20 : apprpg                                .
c .        .     .        . 21 : apvatt                                .
c .        .     .        . 22 : apvane                                .
c .        .     .        . 23 : antyas                                .
c .        .     .        . 24 : aptyas                                .
c .        .     .        . 25 : numero de la 1ere fonction associee   .
c .        .     .        . 26 : numero de la 2nde fonction associee   .
c . carach . es  .nbpara* . caracteristiques caracteres des fonctions :.
c .        .     .  nnfopa.  1 : nom de la fonction                    .
c .        .     .        .  2 : nom de la fonction n associee         .
c .        .     .        .  3 : nom de la fonction p associee         .
c .        .     .        .  4 : obpcan                                .
c .        .     .        .  5 : obpcap                                .
c .        .     .        .  6 : obprof                                .
c .        .     .        .  7 : oblopg                                .
c .        .     .        .  8 : si aux points de Gauss, nom de la     .
c .        .     .        .      fonction n ELNO correspondante        .
c .        .     .        .  9 : si aux points de Gauss, nom de la     .
c .        .     .        .      fonction p ELNO correspondante        .
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
      parameter ( nompro = 'PCCAPR' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "nombsr.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer npfopa, npprof
      integer nbpara
      integer carenf(nbpara,*)
c
      character*8 liprof(*)
      character*8 carach(nbpara,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nrfonc
      integer rsenac, adpcap
      integer typgeo
      integer nnvapr, npvapr
c
      character*8 obpcap, opprof
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nom de l''''objet profil etape n = '',a8)'
c
      texte(2,4) = '(''Name of the profile object #n: '',a8)'
c
#include "impr03.h"
c
c====
c 2. mise a jour des caracteristiques des profils
c====
c
      do 20 , nrfonc = 1 , npfopa
c
        if ( codret.eq.0 ) then
c
        nnvapr = carenf(7,nrfonc)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '============================'
        write (ulsort,90002) 'nnvapr', nnvapr
#endif
c
        endif
c
c 2.1. ==> creation du profil eventuel
c
c 2.1.1. ==> recuperation des informations
c
        if ( nnvapr.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          obpcap = carach( 5,nrfonc)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,4)) obpcap
cgn          call gmprsx (nompro, obpcap )
#endif
          call gmadoj ( obpcap, adpcap, iaux, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          typgeo = carenf( 3,nrfonc)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'typgeo', typgeo
#endif
c
c          Par convention HOMARD, les mailles sont rangees ainsi :
c            . les tetraedres
c            . les triangles
c            . les aretes
c            . les mailles-points
c            . les quadrangles
c            . les hexaedres
c            . les pyramides
c            . les pentaedres
c
          if ( typgeo.eq.0 ) then
            rsenac = rsnoto
            iaux = 1
            jaux = 0
          elseif ( typgeo.eq.edtet4 .or. typgeo.eq.edte10 ) then
            rsenac = rsteac
            iaux = 1
            jaux = 0
          elseif ( typgeo.eq.edtri3 .or. typgeo.eq.edtri6 ) then
            rsenac = rstrac
            iaux = 1
            jaux = nbtetr
          elseif ( typgeo.eq.edseg2 .or. typgeo.eq.edseg3 ) then
            rsenac = rsarac
            iaux = 1
            jaux = nbtetr + nbtria
          elseif ( typgeo.eq.edpoi1 ) then
            rsenac = rsmpac
            iaux = 1
            jaux = nbtetr + nbtria + nbsegm
          elseif ( typgeo.eq.edqua4 .or. typgeo.eq.edqua8 ) then
            rsenac = rsquac
            iaux = 1
            jaux = nbtetr + nbtria + nbsegm + nbmapo
          elseif ( typgeo.eq.edhex8 .or. typgeo.eq.edhe20 ) then
            rsenac = rsheac
            iaux = 1
            jaux = nbtetr + nbtria + nbsegm + nbmapo + nbquad
          elseif ( typgeo.eq.edpyr5 .or. typgeo.eq.edpy13 ) then
cc            rsenac = rspyac
            iaux = 1
            jaux = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa
          elseif ( typgeo.eq.edpen6 .or. typgeo.eq.edpe15 ) then
cc            rsenac = rspeac
            iaux = 1
            jaux = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa
     >           + nbpyra
          else
            goto 20
          endif
c
          endif
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'rsenac', rsenac
          write (ulsort,90002) 'iaux  ', iaux
          write (ulsort,90002) 'jaux  ', jaux
#endif
c
c 2.1.2. ==> creation du profil
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTPR01', nompro
#endif
          call utpr01 ( iaux, jaux,
     >                  rsenac, imem(adpcap), imem(iaux),
     >                  npvapr, opprof,
     >                  npprof, liprof,
     >                  ulsort, langue, codret )
c
c
#ifdef _DEBUG_HOMARD_
          call gmprsx (nompro,opprof)
          call gmprsx (nompro,opprof//'.ListEnti')
#endif
c
          endif
c
c 2.2. ==> sans profil
c
        else
c
          npvapr = -1
          opprof = '        '
c                   12345678
c
        endif
c
c 2.3. ==> archivages
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'npvapr', npvapr
#endif
        carenf(16,nrfonc) = npvapr
        carach( 6,nrfonc) = opprof
c
        endif
c
c
   20 continue
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
