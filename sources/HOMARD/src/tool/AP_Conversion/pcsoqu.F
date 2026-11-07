      subroutine pcsoqu ( typint, deraff, option,
     >                    nbpara, carenf, carchf, nrfonc,
     >                    coonoe,
     >                    somare,
     >                    aretri,
     >                    arequa, hetqua, ancqua, filqua,
     >                    nbanqu, anfiqu, anhequ,
     >                    nqueca, nqusca,
     >                    nbantr, anfatr,
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
c    aPres adaptation - Conversion de Solution - QUadrangles
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
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . nbanqu . e   .   1    . nombre de quadrangles decoupes par         .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfiqu . e   . nbanqu . tableau filqua du maillage de l'iteration n
c . anhequ . e   . nbanqu . tableau hetqua du maillage de l'iteration n
c . nqueca . e   .   *    . nro des quadrangles dans le calcul en ent. .
c . nqusca . e   . rsquto . numero des quadrangles du calcul           .
c . nbantr . e   .   1    . nombre de triangles issus du decoupage par .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfatr . e   . nbantr . tableau famtri du maillage de l'iteration n.
c . ntreca . e   .   *    . nro des triangles dans le calcul en entree .
c . ntrsca . e   . rstrac . numero des triangles du calcul             .
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
      parameter ( nompro = 'PCSOQU' )
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
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer typint
      integer option
      integer nbpara
      integer carenf(nbpara,*)
      integer nrfonc
c
      double precision coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4), hetqua(nbquto), ancqua(*)
      integer filqua(nbquto)
      integer nbanqu, anfiqu(nbanqu), anhequ(nbanqu)
      integer nbantr, anfatr(nbantr)
c
      integer nqueca(requto), nqusca(rsquto)
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
      integer iaux, jaux
c
      integer typfon, typcha, typgeo, nbtyas
      integer ngauss, nnenmx, n1vapr, carsup, nbtafo
      integer n1vale, n1valr, n1obpr, n1obch, n1lipr
      integer npenm1, npvap1
      integer p1vale, p1valr, p1obpr, p1obch, p1vatt
      integer p1vane, p1tyas
      integer dimcpg
c
      integer typfo2, typch2, typge2, nbtya2
      integer ngaus2, nnenm2, nnvap2, carsu2, nbtaf2
      integer n2vale, n2valr, n2obpr, n2obch, n2lipr
      integer npenm2, npvap2
      integer p2vale, p2valr, p2obpr, p2obch, p2vatt
      integer p2vane, p2tyas
      integer nrfon2
c
      integer nrfon3
c
      integer adpc1n, adpc1p
      integer adpc2n, adpc2p
c
      integer nbnor1
      integer adcon1, adcop1, adpop1, adwip1
c
      character*8 nofon1, obpc1n, obpc1p, obpro1, oblo1g
      character*8 nofon2, obpc2n, obpc2p, obpro2, oblo2g
      character*8 ntrava
      character*64 nolop1
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
#endif
c
      codret = 0
c
#include "pcimp1.h"
#include "impr03.h"
c
c====
c 2. grandeurs utiles
c====
c
c 2.1. ==> la fonction de base
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'carenf',(carenf(iaux,nrfonc),iaux= 1,10)
      write(ulsort,90002) 'carenf',(carenf(iaux,nrfonc),iaux=11,20)
      write(ulsort,90002) 'carenf',(carenf(iaux,nrfonc),iaux=21,nbpara)
      write(ulsort,90003) 'carchf',(carchf(iaux,nrfonc),iaux= 1,9)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFOR2', nompro
#endif
      iaux = nrfonc
      call pcfor2 ( nbpara, carenf, carchf,
     >              iaux,
     >              typfon, typcha, typgeo, nbtyas,
     >              ngauss, nnenmx, n1vapr, carsup, nbtafo,
     >              n1vale, n1valr, n1obpr, n1obch, n1lipr,
     >              npenm1, npvap1,
     >              p1vale, p1valr, p1obpr, p1obch, p1vatt,
     >              p1vane, p1tyas,
     >              nrfon2, nrfon3,
     >              nofon1,
     >              obpc1n, obpc1p, obpro1, adpc1n, adpc1p,
     >              oblo1g,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90003) 'nofon1', nofon1
      write (ulsort,90002) 'typfon', typfon
      write (ulsort,90002) 'typcha', typcha
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'nbtyas', nbtyas
      write (ulsort,90002) 'carsup', carsup
      write (ulsort,90002) 'ngauss', ngauss
      write (ulsort,90002) 'nbtafo', nbtafo
      write (ulsort,90002) 'nrfon2', nrfon2
cgn      write (ulsort,90003) 'oblo1g', oblo1g
      endif
#endif
c
c 2.2. ==> la fonction annexe
c
      if ( nrfon2.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nrfon2
      write(ulsort,90002) 'carenf',(carenf(iaux,nrfon2),iaux= 1,10)
      write(ulsort,90002) 'carenf',(carenf(iaux,nrfon2),iaux=11,20)
      write(ulsort,90002) 'carenf',(carenf(iaux,nrfon2),iaux=21,nbpara)
      write(ulsort,90003) 'carchf',(carchf(iaux,nrfon2),iaux= 1,9)
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFOR2_tr', nompro
#endif
        call pcfor2 ( nbpara, carenf, carchf,
     >                nrfon2,
     >                typfo2, typch2, typge2, nbtya2,
     >                ngaus2, nnenm2, nnvap2, carsu2, nbtaf2,
     >                n2vale, n2valr, n2obpr, n2obch, n2lipr,
     >                npenm2, npvap2,
     >                p2vale, p2valr, p2obpr, p2obch, p2vatt,
     >                p2vane, p2tyas,
     >                iaux, jaux,
     >                nofon2,
     >                obpc2n, obpc2p, obpro2, adpc2n, adpc2p,
     >                oblo2g,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90002) 'typfo2', typfo2
      write (ulsort,90002) 'typch2', typch2
      write (ulsort,90002) 'typge2', typge2
      write (ulsort,90002) 'nbtya2', nbtya2
      write (ulsort,90002) 'carsu2', carsu2
      write (ulsort,90002) 'ngaus2', ngaus2
cgn      write (ulsort,90003) 'oblo2g', oblo2g
      endif
#endif
c
      endif
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
        write (ulsort,texte(langue,3)) 'PCSQU0', nompro
#endif
        call pcsqu0 ( nbtafo, typint, deraff,
     >                imem(adpc1n), imem(adpc1p),
     >                coonoe,
     >                somare,
     >                arequa, hetqua, ancqua, filqua,
     >                nbanqu, anfiqu,
     >                nqueca, nqusca,
     >                aretri,
     >                ntreca, ntrsca,
     >                rmem(n1valr), rmem(p1vatt),
     >                rmem(n2valr), rmem(p2vatt),
     >                imem(adpc2n), imem(adpc2p),
     >                ulsort, langue, codret )
c
        endif
c
      else
c
c 3.2. ==> avec plusieurs points de Gauss
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3.2 plusieurs pts de Gauss ; codret = ', codret
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
      write (ulsort,texte(langue,3)) 'PCEQU1', nompro
#endif
              call pcequ1 ( nbtafo, ngauss, deraff,
     >                      imem(adpc1n), imem(adpc1p),
     >                      hetqua, ancqua, filqua,
     >                      nbanqu, anfiqu, anhequ,
     >                      nqueca, nqusca,
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
      write (ulsort,texte(langue,3)) 'PCEQU3', nompro
#endif
              iaux = 8
              call pcequ3 ( nbtafo, iaux, ngauss,
     >                      imem(adpc1n), imem(adpc1p),
     >                      nqueca, nqusca,
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
      write (ulsort,texte(langue,3)) 'PCEQU2', nompro
#endif
              call pcequ2 ( nbtafo, ngauss, deraff,
     >                      imem(adpc1n), imem(adpc1p),
     >                      hetqua, ancqua, filqua,
     >                      nbanqu, anfiqu, anhequ,
     >                      nqueca, nqusca,
     >                      nbantr, anfatr,
     >                      ntreca, ntrsca,
     >                      rmem(n1valr), rmem(p1vatt),
     >                      rmem(n2valr), rmem(p2vatt),
     >                      imem(adpc2n), imem(adpc2p),
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
      write (ulsort,texte(langue,3)) 'PCEQU4', nompro
#endif
              iaux = 4
              call pcequ4 ( nbtafo, iaux, ngauss,
     >                      imem(adpc1n), imem(adpc1p),
     >                      nqueca, nqusca,
     >                      rmem(n1valr), rmem(p1vatt),
     >                      ulsort, langue, codret )
c
              endif
c
            endif
cgn            print*,'retour de pcequ2 dans pcsoqu'
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
     >                  nolop1, typgeo, ngauss, dimcpg,
     >                  adcon1, adcop1, adpop1,
     >                  ulsort, langue, codret )
c
          if ( degre.eq.1 ) then
            nbnor1 = 4
          else
            nbnor1 = 8
          endif
c
          endif
c
c 3.2.2.2. ==> interpolation
c
          if ( codret.eq.0 ) then
          iaux = ngauss*nbnor1
          call gmalot ( ntrava, 'reel    ', iaux, adwip1, codret )
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSQUG', nompro
#endif
          call pcsqug ( nbtafo, ngauss, nbnor1, typgeo, deraff,
     >                  imem(adpc1n), imem(adpc1p),
     >                  hetqua, ancqua, filqua,
     >                  nbanqu, anfiqu, anhequ,
     >                  nqueca, nqusca,
     >                  ntreca, ntrsca,
     >                  rmem(n1valr), rmem(p1vatt),
     >                  rmem(adcon1), rmem(adcop1), rmem(adwip1),
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) rmem(n1valr), rmem(p1vatt)
      write (ulsort,*) rmem(n1valr+1), rmem(p1vatt+1)
#endif
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
