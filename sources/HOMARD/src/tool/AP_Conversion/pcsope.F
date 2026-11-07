      subroutine pcsope ( typint, deraff,
     >                    nbpara, carenf, carchf, nrfonc,
     >                    coonoe,
     >                    somare,
     >                    aretri,
     >                    arequa,
     >                    tritet, cotrte, aretet,
     >                    facpen, cofape, arepen,
     >                    facpyr, cofapy, arepyr,
     >                    hetpen, ancpen, filpen, fppyte,
     >                    nbanpe, anfipe, anhepe, anptpe,
     >                    npeeca, npesca,
     >                    nteeca, ntesca,
     >                    npyeca, npysca,
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
c    aPres adaptation - Conversion de Solution - PEntaedres
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
c .        .     .        .  4 : nbtyas                                .
c .        .     .        .  5 : ngauss                                .
c .        .     .        .  6 : nnenmx                                .
c .        .     .        .  7 : n1vapr                                .
c .        .     .        .  8 : carsup                                .
c .        .     .        .  9 : nbtafo                                .
c .        .     .        . 10 : anvale                                .
c .        .     .        . 11 : anvalr                                .
c .        .     .        . 12 : anobch                                .
c .        .     .        . 13 : anprpg                                .
c .        .     .        . 14 : anlipr                                .
c .        .     .        . 15 : npenm1                                .
c .        .     .        . 16 : npvap1                                .
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
c .        .     .        .  4 : obpc1n                                .
c .        .     .        .  5 : obpc1p                                .
c .        .     .        .  6 : obpro1                                .
c .        .     .        .  7 : oblo1g                                .
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
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . nbanpe . e   .   1    . nombre de pentaedres decoupes par          .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfipe . e   . nbanpe . tableau filpen du maillage de l'iteration n.
c . anhepe . e   . nbanpe . tableau hetpen du maillage de l'iteration n.
c . anptpe . e   .  2**   . tableau fppyte du maillage de l'iteration n.
c . npeeca . e   .    *   . numero des pentaedres dans le calcul entree.
c . npesca . e   . rspeto . numero des pentaedres dans le calcul sortie.
c . nteeca . e   .    *   . numero des tetraedres dans le calcul entree.
c . ntesca . e   . rsteto . numero des tetraedres dans le calcul sortie.
c . npyeca . e   .    *   . numero des pyramides dans le calcul entree .
c . npysca . e   . rspyto . numero des pyramides dans le calcul sortie .
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
      parameter ( nompro = 'PCSOPE' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
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
#include "nombte.h"
#include "nombpe.h"
#include "nombpy.h"
c
c 0.3. ==> arguments
c
      integer typint
      integer nbpara
      integer carenf(nbpara,*)
      integer nrfonc
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      integer hetpen(nbpeto), ancpen(*)
      integer filpen(nbpeto), fppyte(2,nbpeco)
      integer nbanpe, anfipe(nbanpe), anhepe(nbanpe), anptpe(2,*)
c
      integer npeeca(repeto), npesca(rspeto)
      integer nteeca(reteto), ntesca(rsteto)
      integer npyeca(repyto), npysca(rspyto)
c
      double precision coonoe(nbnoto,sdim)
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
c
      integer nrfon2
      integer typfo2, typch2, typge2, typas2
      integer ngaus2, nnenm2, nnvap2, carsu2, nbtaf2
      integer n2vale, n2valr, n2obpr, n2obch, n2lipr
      integer npenm2, npvap2
      integer p2vale, p2valr, p2obpr, p2obch, p2vatt
      integer p2vane, p2tyas
c
      integer nrfon3
      integer typfo3, typch3, typge3, typas3
      integer ngaus3, nnenm3, nnvap3, carsu3, nbtaf3
      integer n3vale, n3valr, n3obpr, n3obch, n3lipr
      integer npenm3, npvap3
      integer p3vale, p3valr, p3obpr, p3obch, p3vatt
      integer p3vane, p3tyas
c
      integer adpc1n, adpc1p
      integer adpc2n, adpc2p
      integer adpc3n, adpc3p
c
      character*8 nofon1, obpc1n, obpc1p, obpro1, oblo1g
      character*8 nofon2, obpc2n, obpc2p, obpro2, oblo2g
      character*8 nofon3, obpc3n, obpc3p, obpro3, oblo3g
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
      write (ulsort,90002) 'nbtafo', nbtafo
      write (ulsort,90002) 'ngauss', ngauss
      write (ulsort,90002) 'nrfon2', nrfon2
      write (ulsort,90002) 'nrfon3', nrfon3
      write (ulsort,90003) 'oblo1g', oblo1g
      endif
#endif
c
c 2.2. ==> les fonctions annexes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. fonctions annexes ; codret', codret
#endif
c 2.2.1. ==> tetraedres
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
      write (ulsort,texte(langue,3)) 'PCFOR2_te', nompro
#endif
        call pcfor2 ( nbpara, carenf, carchf,
     >                nrfon2,
     >                typfo2, typch2, typge2, typas2,
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
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90003) 'nofon2', nofon2
      write (ulsort,90002) 'typfo2', typfo2
      write (ulsort,90002) 'typch2', typch2
      write (ulsort,90002) 'typge2', typge2
      write (ulsort,90002) 'typas2', typas2
      write (ulsort,90002) 'carsu2', carsu2
      write (ulsort,90002) 'ngaus2', ngaus2
c      write (ulsort,90003) 'oblo2g', oblo2g
      endif
#endif
c
        endif
c
      endif
c
c 2.2.2. ==> pyramides
c
      if ( nrfon3.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nrfon3
      write(ulsort,90002) 'carenf',(carenf(iaux,nrfon3),iaux= 1,10)
      write(ulsort,90002) 'carenf',(carenf(iaux,nrfon3),iaux=11,20)
      write(ulsort,90002) 'carenf',(carenf(iaux,nrfon3),iaux=21,nbpara)
      write(ulsort,90003) 'carchf',(carchf(iaux,nrfon3),iaux= 1,9)
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFOR2_py', nompro
#endif
        call pcfor2 ( nbpara, carenf, carchf,
     >                nrfon3,
     >                typfo3, typch3, typge3, typas3,
     >                ngaus3, nnenm3, nnvap3, carsu3, nbtaf3,
     >                n3vale, n3valr, n3obpr, n3obch, n3lipr,
     >                npenm3, npvap3,
     >                p3vale, p3valr, p3obpr, p3obch, p3vatt,
     >                p3vane, p3tyas,
     >                iaux, jaux,
     >                nofon3,
     >                obpc3n, obpc3p, obpro3, adpc3n, adpc3p,
     >                oblo3g,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90003) 'nofon3', nofon3
      write (ulsort,90002) 'typfo3', typfo3
      write (ulsort,90002) 'typch3', typch3
      write (ulsort,90002) 'typge3', typge3
      write (ulsort,90002) 'typas3', typas3
      write (ulsort,90002) 'carsu3', carsu3
      write (ulsort,90002) 'ngaus3', ngaus3
c      write (ulsort,90003) 'oblo3g', oblo3g
      endif
#endif
c
        endif
c
      endif
c
c====
c 3. interpolation des variables
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. interpolation variables ; codret', codret
#endif
c
c 3.1. ==> sans point de Gauss
c
      if ( ngauss.eq.ednopg ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'PCSPE0', nompro
#endif
        call pcspe0 ( nbtafo, typint, deraff,
     >                imem(adpc1n), imem(adpc1p),
     >                coonoe,
     >                somare,
     >                aretri,
     >                arequa,
     >                tritet, cotrte, aretet,
     >                facpen, cofape, arepen,
     >                facpyr, cofapy, arepyr,
     >                hetpen, ancpen, filpen, fppyte,
     >                nbanpe, anfipe, anptpe,
     >                npeeca, npesca,
     >                nteeca, ntesca,
     >                npyeca, npysca,
     >                rmem(n1valr), rmem(p1vatt),
     >                rmem(n2valr), rmem(p2vatt),
     >                imem(adpc2n), imem(adpc2p),
     >                rmem(n3valr), rmem(p3vatt),
     >                imem(adpc3n), imem(adpc3p),
     >                ulsort, langue, codret )
c
        endif
cgn      write(ulsort,*) 'pent'
cgn      if ( nbpent.eq.8 ) then
cgn         codret=67
cgn      else
cgn         codret=178
cgn      endif
cgn      write(ulsort,92010) (rmem(p1vatt+iaux),iaux=0,nbpeto-1)
cgn      write(ulsort,*) 'penr'
cgn      write(ulsort,3000) (rmem(p2vatt+iaux),iaux=0,nbpent-1)
cgn      write(ulsort,*) 'pyra'
cgn      if ( nbpent.eq.8 ) then
cgn         codret=75
cgn      else
cgn         codret=225
cgn      endif
cgn      write(ulsort,3000) (rmem(p3vatt+codret+iaux),iaux=0,nbpyto-1)
cgn 3000 format(10g13.5)
cgn       codret = 0
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
          write (ulsort,texte(langue,8)) mess14(langue,1,6)
          write (ulsort,texte(langue,10))
          codret = 321
c
          endif
c
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCEPE1', nompro
#endif
          call pcepe1 ( nbtafo, ngauss, deraff,
     >                  imem(adpc1n), imem(adpc1p),
     >                  hetpen, ancpen, filpen, fppyte,
     >                  nbanpe, anfipe, anhepe, anptpe,
     >                  npeeca, npesca,
     >                  nteeca, ntesca,
     >                  npyeca, npysca,
     >                  rmem(n1valr), rmem(p1vatt),
     >                  ulsort, langue, codret )
c
          endif
c
c 3.2.2. ==> vrai champ aux points de Gauss
c
        else
c
          if ( codret.eq.0 ) then
c
          write (ulsort,texte(langue,9)) mess14(langue,1,6)
          write (ulsort,texte(langue,10))
          codret = 322
c
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
