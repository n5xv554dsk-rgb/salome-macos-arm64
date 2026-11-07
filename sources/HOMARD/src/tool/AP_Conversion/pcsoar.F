      subroutine pcsoar ( typint, deraff,
     >                    nbpara, carenf, carchf, nrfonc,
     >                    hetare, ancare, filare,
     >                    somare,
     >                    coonoe,
     >                    hettri, aretri, filtri,
     >                    hetqua, arequa, filqua,
     >                    nbanar, anfiar,
     >                    nareca, narsca,
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
c    aPres adaptation - Conversion de Solution - ARetes
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
c .        .     .        .  7 : oblopg                                .
c .        .     .        .  8 : si aux points de Gauss, nom de la     .
c .        .     .        .      fonction n ELNO correspondante        .
c .        .     .        .  9 : si aux points de Gauss, nom de la     .
c .        .     .        .      fonction p ELNO correspondante        .
c . nrfonc . e   .   1    . numero de la fonction principale           .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . ancare . e   . nbarto . anciens numeros des aretes conservees      .
c . filare . e   . nbarto . fille ainee de chaque arete                .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . nareca . e   .   *    . nro des aretes dans le calcul en entree    .
c . narsca . e   . rsarto . numero des aretes du calcul                .
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
      parameter ( nompro = 'PCSOAR' )
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
#include "gmenti.h"
c
#include "envca1.h"
#include "nomber.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      integer typint
      integer nbpara
      integer carenf(nbpara,*)
      integer nrfonc
c
      integer hetare(nbarto), ancare(*)
      integer filare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3), filtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
      integer nbanar, anfiar(nbanar)
      integer somare(2,*)
c
      integer nareca(rearto), narsca(rsarto)
c
      character*8 carchf(nbpara,*)
c
      logical deraff
c
      double precision coonoe(nbnoto,sdim)
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
c
      character*8 nofonc, obpcan, obpcap, obprof
      character*8 oblopg
c
#ifdef _DEBUG_HOMARD_
      integer jaux
      integer aretes(3)
      double precision champ(3), flux, lgaret(3)
#endif
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
      codret = 0
c
c====
c 2. grandeurs utiles
c====
c 2.1. ==> recuperation
c
      if ( codret.eq.0 ) then
c
      iaux = nrfonc
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFOR2', nompro
#endif
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
      endif
#endif
c
c====
c 3. interpolation des variables
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Interpolation ; codret', codret
#endif
c
c 3.1. ==> sans point de Gauss
c
      if ( ngauss.eq.ednopg ) then
c
c 3.1.1. ==> pour les aretes decoupees/reactivees
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSAR0', nompro
#endif
        call pcsar0 ( nbtafo, typint, deraff,
     >                imem(adpcan), imem(adpcap),
     >                hetare, ancare, filare,
     >                nbanar, anfiar,
     >                nareca, narsca,
     >                rmem(n1valr), rmem(p1vatt),
     >                ulsort, langue, codret )
c
        endif
c
c 3.1.2. ==> pour les triangles decoupes/reactives
c
        if ( nbtrma.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSAR1', nompro
#endif
          call pcsar1 ( nbtafo, typint, deraff,
     >                  imem(adpcan), imem(adpcap),
     >                  hetare, ancare, filare,
     >                  nbanar, anfiar,
     >                  somare,
     >                  hettri, aretri, filtri,
     >                  nareca, narsca,
     >                  rmem(n1valr), rmem(p1vatt),
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
c
        do 312 , iaux = 1 , nbtrto
c
          if ( mod(hettri(iaux),10).eq.0 ) then
            write (ulsort,90002) 'Triangle', iaux
c
            do 3121 , jaux = 1 , 3
              aretes(jaux) = aretri(iaux,jaux)
              champ(jaux) = rmem(p1vatt-1+narsca(aretes(jaux)))
 3121       continue
            jaux = 0
            call utfltr ( jaux, coonoe, somare, aretes,
     >                    champ, flux, lgaret,
     >                    ulsort, langue, codret )
            write (ulsort,90024) '==> Flux pour le triangle', iaux, flux
c
          endif
c
  312   continue
        do 3122 , iaux = 1 , nbarto
          if ( narsca(iaux).gt.0 ) then
            write(ulsort,90014) iaux, rmem(p1vatt-1+narsca(iaux))
          endif
 3122   continue
cgn        do 3123 , iaux = 1 , nbarto
cgn          if ( narsca(iaux).gt.0 ) then
cgn          write(ulsort,90014) narsca(iaux)-17,
cgn     >                  rmem(p1vatt-1+narsca(iaux))
cgn          endif
cgn 3123   continue
#endif
c
      else
c
        codret = 8
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
