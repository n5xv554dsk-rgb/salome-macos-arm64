      subroutine pcsotr ( typint, deraff, option,
     >                    nbpara, carenf, carchf, nrfonc,
     >                    hettri, anctri, filtri,
     >                    nbantr, anfitr, anhetr,
     >                    ntreca, ntrsca,
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
c    aPres adaptation - Conversion de Solution - TRiangles
c     -                 -             -          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typint . e   .   1    . type d'interpolation                       .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  elements : 0 si intensif, sans orientation.
c .        .     .        .             1 si extensif, sans orientation.
c .        .     .        .             2 si intensif, avec orientation.
c .        .     .        .             3 si extensif, avec orientation.
c .        .     .        .  noeuds : 1 si degre 1                     .
c .        .     .        .           2 si degre 2                     .
c .        .     .        .           3 si iso-P2                      .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
c . option . e   .    1   . option du traitement                       .
c .        .     .        . -1 : Pas de changement dans le maillage    .
c .        .     .        .  0 : Adaptation complete                   .
c .        .     .        .  1 : Modification de degre                 .
c . nbpara . e   .   1    . nombre de parametres a enregistrer par fonc.
c . carenf .   s .nbpara* . caracteristiques entieres des fonctions :  .
c .        .     .  nnfopa.  1 : 0, pour une fonction ancienne isolee  .
c .        .     .        .      1, pour une ancienne associee a une   .
c .        .     .        .         autre fonction                     .
c .        .     .        .      -1, pour une nouvelle fonction        .
c .        .     .        .  2 : typcha                                .
c .        .     .        .  3 : typgeo                                .
c .        .     .        .  4 : nbtyas                                .
c .        .     .        .  5 : ngauss                                .
c .        .     .        .  6 : nnenmx                                .
c .        .     .        .  7 : nnvapr                                .
c .        .     .        .  8 : carsup                                .
c .        .     .        .  9 : nbtafo                                .
c .        .     .        . 10 : anvale                                .
c .        .     .        . 11 : anvalr                                .
c .        .     .        . 12 : anobch                                .
c .        .     .        . 13 : anprpg                                .
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
c . carchf . es  .nbpara* . caracteristiques caracteres des fonctions :.
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
c . nrfonc . e   .   1    . numero de la fonction principale           .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . anctri . e   . nbtrto . anciens numeros des triangles conserves    .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . nbantr . e   .   1    . nombre de triangles decoupes par           .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfitr . e   . nbantr . tableau filtri du maillage de l'iteration n.
c . anhetr . e   . nbantr . tableau hettri du maillage de l'iteration n.
c . ntreca . e   .   *    . nro des triangles dans le calcul en entree .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
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
      parameter ( nompro = 'PCSOTR' )
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
#include "gmreel.h"
c
#include "envca1.h"
#include "nombsr.h"
#include "nomber.h"
#include "nombtr.h"
c
c 0.3. ==> arguments
c
      integer typint
      integer option
      integer nbpara
      integer carenf(nbpara,*)
      integer nrfonc
c
      integer hettri(nbtrto), anctri(*)
      integer filtri(nbtrto)
      integer nbantr, anfitr(nbantr), anhetr(nbantr)
c
      integer ntreca(retrto), ntrsca(rstrto)
c
      character*8 carchf(nbpara,*)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer typfon, typcha, typgeo, nbtyas
      integer ngauss, nnenmx, nnvapr, carsup, nbtafo
      integer n1vale, n1valr, n1obpr, n1obch, n1lipr
      integer npenmx, npvapr
      integer p1vale, p1valr, p1obpr, p1obch, p1vatt
      integer p1vane, p1tyas
      integer adpcan, adpcap
      integer nrfon2, nrfon3
      integer nbnorf
      integer adcono, adcopg, adpopg, adwipg
      integer dimcpg
c
      character*8 nofonc, obpcan, obpcap, obprof
      character*8 oblopg
      character*8 ntrava
      character*64 nolopg
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
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
#endif
c
      codret = 0
c
#include "pcimp1.h"
c
c====
c 2. grandeurs utiles
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFOR2', nompro
#endif
      iaux = nrfonc
      call pcfor2 ( nbpara, carenf, carchf,
     >              iaux,
     >              typfon, typcha, typgeo, nbtyas,
     >              ngauss, nnenmx, nnvapr, carsup, nbtafo,
     >              n1vale, n1valr, n1obpr, n1obch, n1lipr,
     >              npenmx, npvapr,
     >              p1vale, p1valr, p1obpr, p1obch, p1vatt,
     >              p1vane, p1tyas,
     >              nrfon2, nrfon3,
     >              nofonc,
     >              obpcan, obpcap, obprof, adpcan, adpcap,
     >              oblopg,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90003) 'nofonc', nofonc
      write (ulsort,90002) 'typfon', typfon
      write (ulsort,90002) 'typcha', typcha
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'nbtyas', nbtyas
      write (ulsort,90002) 'carsup', carsup
      write (ulsort,90002) 'ngauss', ngauss
      write (ulsort,90002) 'nbtafo', nbtafo
      write (ulsort,90002) 'p1vane', p1vane
      write (ulsort,90002) 'p1tyas', p1tyas
      endif
#endif
c
c====
c 3. interpolation des variables
c====
c
c 3.1. ==> sans point de Gauss
c
      if ( ngauss.eq.ednopg ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1 sans pts de Gauss ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSTR0', nompro
#endif
        call pcstr0 ( nbtafo, typint, deraff,
     >                imem(adpcan), imem(adpcap),
     >                hettri, anctri, filtri,
     >                nbantr, anfitr,
     >                ntreca, ntrsca,
     >                rmem(n1valr), rmem(p1vatt),
     >                ulsort, langue, codret )
c
        endif
c
      else
c
c 3.2. ==> avec plusieurs points de Gauss
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2 plusieurs pts de Gauss ; codret', codret
#endif
c
c 3.2.1. ==> champ aux noeuds par element
c
        if ( carsup.eq.1 ) then
c
c 3.2.1.1. ==> en degre 1
c
          if ( degre.eq.1 ) then
c
c 3.2.1.1.1. ==> adaptation standard
c
            if ( option.le.0 ) then
c
              if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCETR1', nompro
#endif
              call pcetr1 ( nbtafo, deraff,
     >                      imem(adpcan), imem(adpcap),
     >                      hettri, anctri, filtri,
     >                      nbantr, anfitr, anhetr,
     >                      ntreca, ntrsca,
     >                      rmem(n1valr), rmem(p1vatt),
     >                      ulsort, langue, codret )
c
              endif
c
c 3.2.1.1.2. ==> modification de degre : de 2 vers 1
c
            else
c
              if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCETR3', nompro
#endif
              iaux = 6
              call pcetr3 ( nbtafo, iaux, ngauss,
     >                      imem(adpcan), imem(adpcap),
     >                      ntreca, ntrsca,
     >                      rmem(n1valr), rmem(p1vatt),
     >                      ulsort, langue, codret )
c
              endif
c
            endif
c
c 3.2.1.2. ==> en degre 2
c
          else
c
c 3.2.1.2.1. ==> adaptation standard
c
            if ( option.le.0 ) then
c
              if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCETR2', nompro
#endif
              call pcetr2 ( nbtafo, deraff,
     >                      imem(adpcan), imem(adpcap),
     >                      hettri, anctri, filtri,
     >                      nbantr, anfitr, anhetr,
     >                      ntreca, ntrsca,
     >                      rmem(n1valr), rmem(p1vatt),
     >                      ulsort, langue, codret )
c
              endif
c
c 3.2.1.2.2. ==> modification de degre : de 1 vers 2
c
            else
c
              if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCETR4', nompro
#endif
              iaux = 3
              call pcetr4 ( nbtafo, iaux, ngauss,
     >                      imem(adpcan), imem(adpcap),
     >                      ntreca, ntrsca,
     >                      rmem(n1valr), rmem(p1vatt),
     >                      ulsort, langue, codret )
c
              endif
c
            endif
c
          endif
c
c 3.2.2. ==> vrai champ aux points de Gauss
c
        else
c
c 3.2.2.1. ==> recuperation de la localisation des points de Gauss
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPG', nompro
#endif
c
          call utcapg ( oblopg,
     >                  nolopg, typgeo, ngauss, dimcpg,
     >                  adcono, adcopg, adpopg,
     >                  ulsort, langue, codret )
c
          if ( degre.eq.1 ) then
            nbnorf = 3
          else
            nbnorf = 6
          endif
c
          endif
c
c 3.2.2.2. ==> interpolation
c
          if ( codret.eq.0 ) then
          iaux = ngauss*nbnorf
          call gmalot ( ntrava, 'reel    ', iaux, adwipg, codret )
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSTRG', nompro
#endif
          call pcstrg ( nbtafo, ngauss, nbnorf, typgeo, deraff,
     >                  imem(adpcan), imem(adpcap),
     >                  hettri, anctri, filtri,
     >                  nbantr, anfitr,
     >                  ntreca, ntrsca,
     >                  rmem(n1valr), rmem(p1vatt),
     >                  rmem(adcono), rmem(adcopg), rmem(adwipg),
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
          call gmlboj ( ntrava , codret )
          endif
c
        endif
c
      endif
cgn      print 90002, 'codret', codret
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
