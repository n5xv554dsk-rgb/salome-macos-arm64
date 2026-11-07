      subroutine pcsono ( numnp1, numnp2, typint, deraff, option,
     >                    nbpara, carenf, carchf, nrfonc,
     >                    hetnoe, ancnoe,
     >                    nnoeho, nnoeca, nnosho,
     >                    hetare, somare, filare,
     >                    np2are,
     >                    hettri, aretri, filtri,
     >                    hetqua, arequa, filqua,
     >                    tritet, cotrte, aretet,
     >                    filtet, hettet,
     >                    quahex, coquhe, arehex,
     >                    filhex, hethex, fhpyte,
     >                    facpen, cofape, arepen,
     >                    filpen, hetpen, fppyte,
     >                    facpyr, cofapy, arepyr,
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
c    aPres adaptation - Conversion de SOlution - NOeud
c     -                 -             --         --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numnp1 . e   .    1   . nombre de noeuds de la fonction si P1      .
c . numnp2 . e   .    1   . nombre de noeuds de la fonction si P2      .
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
c . hetnoe . e   . nbnoto . historique de l'etat des noeuds            .
c . ancnoe . e   . nbnoto . ancien numero de noeud si deraffinement    .
c . nnoeho . e   . renoto . numero des noeuds en entree pour homard    .
c . nnoeca . e   . renoto . numero des noeuds en entree dans le calcul .
c . nnosho . e   . rsnoto . numero des noeuds en sortie pour homard    .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. code des 6 quadrangles des hexaedres       .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . hethex . e   . nbheto . historique de l'etat des hexaedres        .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. codes des faces des pentaedres             .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
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
      parameter ( nompro = 'PCSONO' )
c
#include "nblang.h"
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
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      integer numnp1, numnp2
      integer typint
      integer option
c
      integer nbpara
      integer carenf(nbpara,*)
      integer nrfonc
c
      integer hetnoe(nbnoto), ancnoe(nbnoto)
      integer nnoeho(renoto), nnoeca(renoto)
      integer nnosho(rsnoto)
      integer hetare(nbarto), somare(2,nbarto), filare(nbarto)
      integer np2are(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3), filtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
      integer tritet(nbtecf,4),  cotrte(nbtecf,4), aretet(nbteca,6)
      integer filtet(nbteto), hettet(nbteto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto), filhex(nbheto), fhpyte(2,nbheco)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer filpen(nbpeto), hetpen(nbpeto), fppyte(2,nbpeco)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
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
      integer codre1, codre2
      integer codre0
c
      integer typfon, typcha, typgeo, typass
      integer ngauss, nnenmx, nnvapr, carsup, nbtafo
      integer n1vale, n1valr, n1obpr, n1obch, n1lipr
      integer npenmx, npvapr
      integer p1vale, p1valr, p1obpr, p1obch, p1vatt
      integer p1vane, p1tyas
      integer adpcan, adpcap
      integer nrfon2, nrfon3
      integer typprf, typin0
c
      integer nbfop1, nbfop2
      integer pvap1h, pvap2h
c
      character*8 nofonc, obpcan, obpcap, obprof
      character*8 oblopg
      character*8 nvap1h, nvap2h
c
      integer nbmess
      parameter ( nbmess = 120 )
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
#include "esimpr.h"
c
      texte(1,4) = '(5x,''Fonctions '',a2,'' :'')'
      texte(1,5) =
     > '(5x,''. nombre de noeuds dans leur definition     : '',i10)'
      texte(1,6) =
     > '(5x,''. nombre de noeuds dans le maillage initial : '',i10)'
      texte(1,7) =
     > '(5x,''. nombre de valeurs du profil : '',i10)'
      texte(1,8) = '(''... Premiere(s) valeur(s) : '',5i10)'
      texte(1,9) = '(''... Dernieres valeurs     : '',5i10)'
      texte(1,10) = '(''. Interpolation '',a)'
c
      texte(2,4) = '(5x,''Fonctions '',a2,'' :'')'
      texte(2,5) =
     > '(5x,''. number of nodes in their definition : '',i10)'
      texte(2,6) =
     > '(5x,''. number of nodes in the initial mesh : '',i10)'
      texte(2,7) =
     > '(5x,''. length of profile : '',i10)'
      texte(2,8) = '(''... First value(s) : '',5i10)'
      texte(2,9) = '(''... Last value(s)  : '',5i10)'
      texte(2,10) = '(''. '',a,'' interpolation '')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
#endif
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
     >              typfon, typcha, typgeo, typass,
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
cgn      write(ulsort,*) 'apres pcfor2'
cgn      write(ulsort,90002) 'carsup', carsup
cgn      write(ulsort,90002) 'nnvapr', nnvapr
cgn      write(ulsort,90002) 'nbtafo', nbtafo
c
c 2.2. ==> type de profil
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. type de profil ;  codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( degre.eq.2 .and. nnvapr.gt.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSPRN', nompro
#endif
        call pcsprn ( typprf, numnp1,
     >                hetnoe, nnoeho,
     >                nnvapr, imem(n1lipr) )
c
      else
c
        typprf = 0
c
      endif
c
      endif
c
c 2.3. ==> grandeurs deduites
c          . Si on n'a rien de special sur le profil, on est fidele
c            au degre
c          . Sinon, c'est une fonction de degre 1
c
      if ( codret.eq.0 ) then
c
      if ( typprf.eq.0 ) then
c
        if ( degre.eq.1 ) then
          nbfop1 = nbtafo
          nbfop2 = 0
        else
          nbfop1 = 0
          nbfop2 = nbtafo
        endif
c
      else
c
        nbfop1 = nbtafo
        nbfop2 = 0
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfop1, nbfop2, typint',
     >                      nbfop1, nbfop2, typint
      write (ulsort,texte(langue,7)) nnvapr
      if ( nnvapr.gt.0 ) then
        write (ulsort,texte(langue,8))
     >         (imem(iaux),iaux=n1lipr,n1lipr+min(4,nnvapr-1))
        if ( nnvapr.gt.5 ) then
          write (ulsort,texte(langue,9))
     >           (imem(iaux),iaux=n1lipr+nnvapr-5,n1lipr+nnvapr-1)
        endif
      endif
#endif
c
      endif
c
c 2.4. ==> verification des coherences de taille
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. verification ;  codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nnvapr.le.0 ) then
c
      if ( nbfop1.ne.0 ) then
        if ( numnp1.ne.reno1i ) then
          write (ulsort,texte(langue,4)) 'P1'
          write (ulsort,texte(langue,5)) numnp1
          write (ulsort,texte(langue,6)) reno1i
          write (ulsort,texte(langue,7)) nnvapr
          codret = 4
        endif
      endif
c
      if ( nbfop2.ne.0 ) then
        if ( numnp2.ne.renoto ) then
          write (ulsort,texte(langue,4)) 'P2'
          write (ulsort,texte(langue,5)) numnp2
          write (ulsort,texte(langue,6)) renoto
          write (ulsort,texte(langue,7)) nnvapr
          codret = 4
        endif
      endif
c
      endif
c
      endif
c
c 2.5. ==> type d'interpolation
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.5. type interpolation ;  codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      typin0 = -1
c
      if ( option.eq.1 ) then
        if ( nbfop1.ne.0 ) then
          typin0 = 5
        else
          typin0 = 4
        endif
      elseif ( typint.eq.0 ) then
        if ( nbfop1.ne.0 ) then
          typin0 = 1
        else
          typin0 = 2
        endif
      elseif ( typint.eq.1 ) then
        typin0 = 1
        if ( nbfop1.eq.0 ) then
          write (ulsort,texte(langue,100+typin0))
          write (ulsort,texte(langue,117)) 1, nbfop1
          codret = 251
        endif
      elseif ( typint.eq.2 .or. typint.eq.3 ) then
        typin0 = typint
        if ( nbfop2.eq.0 ) then
          write (ulsort,texte(langue,100+typin0))
          write (ulsort,texte(langue,117)) 2, nbfop2
          codret = 252
        endif
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typin0', typin0
      if ( typin0.ge.0 .and. typin0.le.5 ) then
        write (ulsort,texte(langue,100+typin0))
        write (ulsort,texte(langue,117)) 1, nbfop1
        write (ulsort,texte(langue,117)) 2, nbfop2
      endif
#endif
c
c====
c 3. interpolation des variables aux noeuds
c    remarque : si les fonctions sont inexistantes dans l'une des
c               categories, on alloue quand meme les tableaux. les
c               longueurs sont nulles donc on ne perd pas de place.
c               la lisibilite du programme compense le peu de temps cpu
c               necessaire a cela.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. redistribution ;  codret', codret
#endif
c
c 3.1. ==> allocations des tableaux intermediaires pour les fonctions
c          aux noeuds
c
      if ( codret.eq.0 ) then
c
      if ( nbfop1.ne.0 ) then
        iaux = nbfop1 * max(renoto,nbnoto)
      else
        iaux = 0
      endif
      call gmalot ( nvap1h, 'reel    ', iaux, pvap1h, codre1 )
      iaux = nbfop2 * max(renoto,nbnoto)
      call gmalot ( nvap2h, 'reel    ', iaux, pvap2h, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 3.2. ==> redistribution des valeurs dans la numerotation homard
c
cgn       write (*,*) 'fonctions P1'
cgn       write (*,92010)
cgn     >(rmem(iaux),iaux=n1valr,n1valr-1+nbfop1*max(nnvapr,renoto))
cgn       write (*,*) 'fonctions P2'
cgn      write (*,92010)
cgn     >(rmem(iaux),iaux=n1valr,n1valr-1+nbfop2*max(nnvapr,renoto))
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSRHO', nompro
#endif
      call pcsrho ( nbfop1, nbfop2, numnp1, numnp2,
     >              deraff, option,
     >              hetnoe, ancnoe,
     >              nnoeho, nnoeca,
     >              nnvapr, imem(n1lipr), imem(adpcan), imem(adpcap),
     >              rmem(n1valr), rmem(n1valr),
     >              rmem(pvap1h), rmem(pvap2h),
     >              ulsort, langue, codret )
c
      endif
cgn      write (*,*)'apres pcsrho'
cgn      call gmprsx (nompro, nvap1h )
cgn      write(*,91011) (imem(adpcap-1+iaux),iaux=2073,2073)
cgn      write(*,92010) (rmem(pvap1h-1+iaux),iaux=1,nbnoto)
cgn      write(*,91011) (imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*nbnoto)
cgn      write (*,92010)(rmem(pvap2h-1+iaux),iaux=1,nbfop2*nbnoto)
c
c====
c 4. Interpolation p1 des variables aux noeuds
c====
c
      if ( codret.eq.0 ) then
c
      if ( typin0.eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. ==> Interpolation p1 ; codret', codret
#endif
c
        write (ulsort,texte(langue,10)) 'P1'
c
c 4.1. ==> interpolation p1 pour les aretes decoupees
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS1AR', nompro
#endif
        call pcs1ar ( nbfop1, imem(adpcap),
     >                hetare, somare, filare,
     >                rmem(pvap1h) )
cgn      write (*,*)'apres pcs1ar'
cgn      write(*,91011) (imem(adpcap-1+iaux),iaux=2073,2073)
cgn      write(*,92010) (rmem(pvap1h-1+iaux),iaux=2073,2073)
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*nbnoto)
c
c 4.2. ==> interpolation p1 pour les quadrangles decoupes
c
        if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS1QU', nompro
#endif
          call pcs1qu ( nbfop1, imem(adpcap),
     >                  somare,
     >                  hetqua, arequa, filqua,
     >                  rmem(pvap1h) )
cgn      write (*,*)'apres pcs1qu'
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*nbnoto)
c
        endif
c
c 4.3. ==> interpolation p1 pour les hexaedres decoupes
c
        if ( nbheto.ne.0 ) then
c
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*nbnoto)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS1HE', nompro
#endif
          call pcs1he ( nbfop1, imem(adpcap),
     >                  somare,
     >                  aretri, arequa,
     >                  tritet, cotrte, aretet,
     >                  quahex, coquhe, arehex,
     >                  filhex, hethex, fhpyte,
     >                  facpyr, cofapy, arepyr,
     >                  rmem(pvap1h) )
c
cgn      write (*,*)'apres pcs1he'
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*nbnoto)
        endif
c
c 4.3. ==> interpolation p1 pour les pentaedres decoupes
c
        if ( nbpeto.ne.0 ) then
c
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*nbnoto)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS1PE', nompro
#endif
          call pcs1pe ( nbfop1, imem(adpcap),
     >                  somare,
     >                  aretri, arequa,
     >                  tritet, cotrte,
     >                  facpen, cofape, arepen,
     >                  filpen, hetpen, fppyte,
     >                  facpyr, cofapy, arepyr,
     >                  rmem(pvap1h) )
c
cgn      write (*,*)'apres pcs1pe'
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*nbnoto)
        endif
c
c====
c 5. Interpolation p2 des variables aux noeuds
c    Attention a respecter l'ordre dans l'enchainement des appels
c====
c
      elseif ( typin0.eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Interpolation p2 ; codret', codret
#endif
c
        write (ulsort,texte(langue,10)) 'P2'
c
c 5.1. ==> pour les aretes decoupees
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2AR', nompro
#endif
        call pcs2ar ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                hetare, somare, np2are, filare )
cgn       write (*,*)'apres pcs2ar'
cgn      write(*,91011) (imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn       write (*,92010)(rmem(pvap2h-1+iaux),iaux=1,nbfop2*nbnoto-1)
cgn       write (*,92010)
cgn     > (rmem(pvap2h-1+iaux),iaux=nbfop2*nbnoto-1,nbfop2*nbnoto-1)
c
c 5.2. ==> pour les tetraedres decoupes
c
        if ( nbtema.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2TE', nompro
#endif
          call pcs2te ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                  tritet, cotrte, aretet,
     >                  hettet, filtet,
     >                  somare, np2are,
     >                  aretri )
c
        endif
c
c 5.3. ==> quadrangles et hexaedres decoupes
c          Remarque : avec les hexaedres, il faut faire deux passages
c                     pour gerer les raffinements sur deux niveaux
c                     Tant pis si des calculs sont faits deux fois.
c
        jaux = 1
        if ( nbheto.ne.0 ) then
          jaux = 2
        endif
c
        do 53 , iaux = 1 , jaux
c
c 5.3.1. ==> pour les quadrangles jaux
c
          if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2QU', nompro
#endif
            call pcs2qu ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                    hetqua, arequa, filqua,
     >                    somare, np2are,
     >                    aretri )
cgn       write(ulsort,*)'apres pcs2qu'
cgn       write(ulsort,91011) (imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn       write(ulsort,92010)(rmem(pvap2h-1+iaux),iaux=1,nbnoto)
c
          endif
c
c 5.3.2. ==> pour les hexaedres decoupes
c
          if ( nbheto.ne.0 ) then
c
cgn      write (*,*)'avant pcs2he'
cgn      call gmprsx ( 'avant pcs2he',nvap2h )
cgn      write(*,91011)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*nbnoto)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2HE', nompro
#endif
            call pcs2he ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                    hethex, quahex, coquhe, arehex,
     >                    filhex, fhpyte,
     >                    somare, np2are,
     >                    aretri,
     >                    hetqua, arequa, filqua,
     >                    tritet, cotrte, aretet,
     >                    facpyr, cofapy, arepyr,
     >                    ulsort, langue, codret )
c
cgn      write (*,*)'apres pcs2he'
cgn      write(*,91011)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap2h-1+iaux),iaux=1,nbfop2*nbnoto)
cgn      call gmprsx ( 'apres pcs2he',nvap2h )
cgn      call gmprsx ( 'apres pcs2he',obpcap)
          endif
c
   53   continue
c
c 5.4. ==> pour les pentaedres decoupes
c
        if ( nbpeto.ne.0 ) then
c
cgn      call gmprsx ( 'avant pcs2pe',nvap2h )
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*nbnoto)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2PE', nompro
#endif
          call pcs2pe ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                  hetpen, facpen, cofape, filpen, fppyte,
     >                  somare, np2are,
     >                  aretri, arequa,
     >                  tritet, cotrte,
     >                  facpyr, cofapy,
     >                  ulsort, langue, codret )
c
cgn      write (*,*)'apres pcs2pe'
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap2h-1+iaux),iaux=1,nbfop2*nbnoto)
cgn      call gmprsx ( 'apres pcs2he',nvap2h )
cgn      call gmprsx ( 'apres pcs2he',obpcap)
        endif
cgn      call gmprsx ( 'au final',nvap2h )
cgn      call gmprsx ( 'au final',obpcap)
c
c 5.5. ==> pour les triangles decoupes
c
        if ( nbtrma.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCS2TR', nompro
#endif
          call pcs2tr ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                  hettri, aretri, filtri,
     >                  somare, np2are )
cgn       write (*,*)'apres pcs2tr'
cgn      write(*,91011) (imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn       write (*,92010)(rmem(pvap2h-1+iaux),iaux=1,nbnoto)
cgn       write (*,92010)
cgn     > (rmem(pvap2h-1+iaux),iaux=nbfop2*nbnoto,nbfop2*nbnoto)
c
        endif
c
c====
c 6. Interpolation iso-p2 des variables aux noeuds
c    Attention a respecter l'ordre dans l'enchainement des appels
c====
c
      elseif ( typin0.eq.3 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Interpolation iso-p2 ; codret', codret
#endif
c
        write (ulsort,texte(langue,10)) 'iso-P2'
cgn      write (*,*)'au debut'
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap2h-1+iaux),iaux=1,2*nbnoto)
c
c 6.1. ==> pour les aretes decoupees
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSIAR', nompro
#endif
        call pcsiar ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                hetare, somare, np2are, filare )
cgn      write (*,*)'apres pcsiar'
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap2h-1+iaux),iaux=1,2*nbnoto)
c
c 6.2. ==> pour les tetraedres decoupes
c
        if ( nbtema.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSITE', nompro
#endif
          call pcsite ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                  tritet, cotrte, aretet,
     >                  hettet, filtet,
     >                  somare, np2are,
     >                  aretri )
c
        endif
c
c 6.3. ==> quadrangles et hexaedres decoupes
c          Remarque : avec les hexaedres, il faut faire deux passages
c                     pour gerer les raffinements sur deux niveaux
c                     Tant pis si des calculs sont faits deux fois.
c
        jaux = 1
        if ( nbheto.ne.0 ) then
          jaux = 2
        endif
c
        do 63 , iaux = 1 , jaux
c
c 6.3.1. ==> pour les quadrangles decoupes
c
        if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSIQU', nompro
#endif
          call pcsiqu ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                  hetqua, arequa, filqua,
     >                  somare, np2are,
     >                  aretri )
cgn      write (*,*)'apres pcsiqu'
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap2h-1+iaux),iaux=1,2*nbnoto)
c
        endif
c
c 6.3.2. ==> pour les hexaedres decoupes
c
        if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSIHE', nompro
#endif
          call pcsihe ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                  hethex, quahex, coquhe, arehex,
     >                  filhex, fhpyte,
     >                  somare, np2are,
     >                  aretri,
     >                  arequa,
     >                  tritet, cotrte, aretet,
     >                  facpyr, cofapy, arepyr )
c
cgn      write (*,*)'apres pcs2he'
cgn      write(*,91011)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap2h-1+iaux),iaux=1,nbfop2*nbnoto)
cgn      call gmprsx ( 'apres pcs2he',nvap2h )
cgn      call gmprsx ( 'apres pcs2he',obpcap)
c
        endif
c
   63   continue
c
c 6.4. ==> pour les pentaedres decoupes
c
        if ( nbpeto.ne.0 ) then
c
cgn      call gmprsx ( 'avant pcsipe',nvap2h )
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*nbnoto)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSIPE', nompro
#endif
          call pcsipe ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                  hetpen, facpen, cofape, filpen, fppyte,
     >                  somare, np2are,
     >                  aretri, arequa,
     >                  tritet, cotrte,
     >                  facpyr, cofapy,
     >                  ulsort, langue, codret )
c
        endif
c
c 6.5. ==> pour les triangles decoupes
c
        if ( nbtrma.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSITR', nompro
#endif
          call pcsitr ( nbfop2, imem(adpcap), rmem(pvap2h),
     >                  hettri, aretri, filtri,
     >                  somare, np2are )
cgn      write (*,*)'apres pcsitr'
cgn      write (*,*)(imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap2h-1+iaux),iaux=1,2*nbnoto)
c
        endif
c
c====
c 7. Interpolation des variables aux noeuds P1 vers P2
c    Les nouveaux noeuds P2 sont tous des milieux d'aretes (cf mmcnp2)
c====
c
      elseif ( typin0.eq.4 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. modification P1 vers P2 ; codret', codret
#endif
c
        write (ulsort,texte(langue,10)) 'P1'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSMAR', nompro
#endif
        call pcsmar ( nbfop2, imem(adpcap),
     >                somare, np2are,
     >                rmem(pvap2h) )
cgn      write (*,*)'apres pcsmar'
cgn      write(*,91011) (imem(adpcap-1+iaux),iaux=2073,2073)
cgn      write(*,92010) (rmem(pvap2h-1+iaux),iaux=1,nbnoto)
c
c====
c 8. Interpolation des variables aux noeuds P2 vers P1
c    Rien n'est a faire puisque la copie des valeurs sur les noeuds P1
c    a eu lieu au depart
c====
c
      elseif ( typin0.eq.5 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. modification P2 vers P1 ; codret', codret
#endif
c
        write (ulsort,texte(langue,10)) 'P1'
c
c====
c 9. Type inconnu
c====
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. type inconnu ; codret', codret
#endif
c
        write (ulsort,texte(langue,109))
        codret = 90
c
      endif
c
      endif
c
c====
c 10. redistribution des valeurs dans la numerotation du calcul
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. ==> redistribution ; codret', codret
#endif
cgn       write (ulsort,90002)'avant pcsrc0 : nbfop1, nbfop2',
cgn     >                            nbfop1, nbfop2
cgn      do 888 , iaux = 1 , nbnoto
cgn        if ( imem(adpcap-1+iaux).eq.0 ) then
cgn          write(ulsort,*) 'Noeud', iaux
cgn        endif
cgn  888 continue
cgn      write(*,91011) (imem(adpcap-1+iaux),iaux=1,nbnoto)
cgn      write (*,92010)(rmem(pvap1h-1+iaux),iaux=1,nbfop1*rsnoto-1)
c
      if ( nbfop1.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSRC0_d1', nompro
#endif
        call pcsrc0 ( nbfop1, rsnoto,
     >                imem(adpcap), nnosho,
     >                rmem(pvap1h), rmem(p1valr) )
c
cgn       write (*,*)'apres pcsrc0'
cgn      write(*,91011) (imem(adpcap-1+iaux),iaux=2073,2073)
cgn      write(*,92010) (rmem(p1valr-1+iaux),iaux=2073,2073)
cgn      write(*,92010)(rmem(iaux),iaux=p1valr,p1valr-1+nbfop1*rsnoto-1)
        endif
c
      endif
c
      if ( nbfop2.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSRC0_d2', nompro
#endif
        call pcsrc0 ( nbfop2, rsnoto,
     >                imem(adpcap), nnosho,
     >                rmem(pvap2h), rmem(p1valr) )
cgn       write (*,*)nbnoto, rsnoto
cgn       write (*,*)'apres pcsrc0'
cgn       write (*,92010)(rmem(iaux),iaux=p1valr,p1valr-1+nbfop2*rsnoto)
cgn       write (*,92010)
cgn     > (rmem(p1valr-1+iaux),iaux=nbfop2*nbnoto-5,nbfop2*nbnoto)
cgn      do 889 , iaux = 1 , nbnoto
cgn        if ( imem(adpcap-1+iaux).eq.0 ) then
cgn          write(ulsort,*) 'Noeud', iaux
cgn        endif
cgn  889 continue
c
        endif
c
      endif
c
c====
c 11. menage
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GMLBOJ', nompro
#endif
c
      call gmlboj ( nvap1h, codre1 )
      call gmlboj ( nvap2h, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 10. la fin
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
cgn      write(ulsort,90002)'debut du profil',
cgn     >          (imem(adpcap+iaux),iaux=0,4)
cgn      write(ulsort,90004)'debut des valeurs',
cgn     >          (rmem(pvap2h+iaux),iaux=0,4)
cgn        do 999 , iaux = 1 , nbnoto
cgn         if ( imem(adpcap-1+iaux).eq.0 ) then
cgn          write(ulsort,90002) 'oubli de', iaux
cgn            endif
cgn  999 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
