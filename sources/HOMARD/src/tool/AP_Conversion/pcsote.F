      subroutine pcsote ( typint, deraff,
     >                    nbpara, carenf, carchf, nrfonc,
     >                    hettet, anctet, filtet,
     >                    nbante, anfite, anhete,
     >                    nteeca, ntesca,
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
c    aPres adaptation - Conversion de Solution - TEtraedres
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
c .        .     .        .  7 : oblo1g                                .
c .        .     .        .  8 : si aux points de Gauss, nom de la     .
c .        .     .        .      fonction n ELNO correspondante        .
c .        .     .        .  9 : si aux points de Gauss, nom de la     .
c .        .     .        .      fonction p ELNO correspondante        .
c . nrfonc . e   .   1    . numero de la fonction principale           .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . nbante . e   .   1    . nombre de tetraedres decoupes par          .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfite . e   . nbante . tableau filtet du maillage de l'iteration n.
c . anhete . e   . nbante . tableau hettet du maillage de l'iteration n.
c . nteeca . e   .    *   . tetraedres en entree dans le calcul        .
c . ntesca . e   . rsteto . tetraedres en sortie dans le calcul        .
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
      parameter ( nompro = 'PCSOTE' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "gmenti.h"
#include "gmreel.h"
c
#include "nombte.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer typint
      integer nbpara
      integer carenf(nbpara,*)
      integer nrfonc
c
      integer hettet(nbteto), anctet(*)
      integer filtet(nbteto)
      integer nbante, anfite(nbante), anhete(nbante)
c
      integer nteeca(reteto), ntesca(rsteto)
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
      integer typfon, typcha, typgeo, typass
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
      character*8 oblo1g
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
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "pcimp1.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nrfonc
#endif
c
c====
c 2. grandeurs utiles
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'carenf  ',(carenf(iaux,nrfonc),iaux= 1,10)
      write(ulsort,90002) 'carenf  ',(carenf(iaux,nrfonc),iaux=11,20)
      write(ulsort,90002) 'carenf  ',
     >                    (carenf(iaux,nrfonc),iaux=21,nbpara)
      write(ulsort,90003) 'carchf  ',(carchf(iaux,nrfonc),iaux= 1,9)
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFOR2', nompro
#endif
      iaux = nrfonc
      call pcfor2 ( nbpara, carenf, carchf,
     >              iaux,
     >              typfon, typcha, typgeo, typass,
     >              ngauss, nnenmx, nnvapr, carsup, nbtafo,
     >              n1vale, n1valr, n1obpr, n1obch, n1lipr,
     >              npenmx, npvapr,
     >              p1vale, p1valr, p1obpr, p1obch, p1vatt,
     >              p1vane, p1tyas,
     >              nrfon2, nrfon3,
     >              nofonc,
     >              obpcan, obpcap, obprof, adpcan, adpcap,
     >              oblo1g,
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
      write (ulsort,90002) 'typass', typass
      write (ulsort,90002) 'carsup', carsup
      write (ulsort,90002) 'nbtafo', nbtafo
      write (ulsort,90002) 'ngauss', ngauss
      write (ulsort,90003) 'oblo1g', oblo1g
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
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSTE0', nompro
#endif
cgn        print *,(rmem(n1valr+iaux-1),iaux=1,5)
        call pcste0 ( nbtafo, typint, deraff,
     >                imem(adpcan), imem(adpcap),
     >                hettet, anctet, filtet,
     >                nbante, anfite,
     >                nteeca, ntesca,
     >                rmem(n1valr), rmem(p1vatt),
     >                ulsort, langue, codret )
c
        endif
cgn        print *,(rmem(p1vatt+iaux-1),iaux=1,18)
c
      else
c
c 3.2. ==> avec plusieurs points de Gauss
c
c 3.2.1. ==> champ aux noeuds par element
c
        if ( carsup.eq.1 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCETE1', nompro
#endif
          call pcete1 ( nbtafo, ngauss, deraff,
     >                  imem(adpcan), imem(adpcap),
     >                  hettet, anctet, filtet,
     >                  nbante, anfite, anhete,
     >                  nteeca, ntesca,
     >                  rmem(n1valr), rmem(p1vatt),
     >                  ulsort, langue, codret )
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
          call utcapg ( oblo1g,
     >                  nolopg, typgeo, ngauss, dimcpg,
     >                  adcono, adcopg, adpopg,
     >                  ulsort, langue, codret )
c
          if ( degre.eq.1 ) then
            nbnorf = 4
          else
            nbnorf = 10
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
      write (ulsort,texte(langue,3)) 'PCSTEG', nompro
#endif
          call pcsteg ( nbtafo, ngauss, nbnorf, typgeo, deraff,
     >                  imem(adpcan), imem(adpcap),
     >                  hettet, anctet, filtet,
     >                  nbante, anfite,
     >                  nteeca, ntesca,
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
cgn      print *, 'codret = ', codret
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
