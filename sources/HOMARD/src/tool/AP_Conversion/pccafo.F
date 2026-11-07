      subroutine pccafo ( nrfonc, nofonc, obprof, oblopg,
     >                    nbpara, carenf, carach,
     >                    option,
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
c    aPres adaptation - mise a jour des CAracteristiques des FOnctions
c     -                                 --                   --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nrfonc . e   .   1    . numero de la fonction a examiner           .
c . nofonc .  s  . char8  . nom de la fonction iteration n+1           .
c . obprof .  s  . char8  . nom de l'objet profil eventuel             .
c . oblopg .  s  . char8  . nom de l'objet localisation points de Gauss.
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
c . option . e   .    1   . option du traitement                       .
c .        .     .        . -1 : Pas de changement dans le maillage    .
c .        .     .        .  0 : Adaptation complete                   .
c .        .     .        .  1 : Modification de degre                 .
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
      parameter ( nompro = 'PCCAFO' )
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
#include "gmstri.h"
c
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      integer nrfonc
      integer nbpara
      integer carenf(nbpara,*)
      integer option
c
      character*8 nofonc, obprof, oblopg
      character*8 carach(nbpara,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer typfon, typcha, typgeo, typass
      integer ngauss, nnenmx, nnvapr, carsup, nbtafo
      integer n1vale, n1valr, n1prpg, n1obch, n1lipr
      integer npenmx, npvapr
      integer p1vale, p1valr, p1prpg, p1obch, p1vatt
      integer p1vane, p1tyas
      integer adpcan, adpcap
      integer nrfon2, nrfon3
      integer adinch
c
      character*8 obpcan, obpcap
      character*8 obinch
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''.. Fonction numero '',i6)'
      texte(1,5) = '(''Nom de la fonction = '',a8)'
c
      texte(2,4) = '(''.. Function #'',i6)'
      texte(2,5) = '(''Name of the function ='',a8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nrfonc
      write (ulsort,90002) 'option', option
#endif
cgn      print *, nompro
cgn      print 1788,(carenf(iaux,nrfonc),iaux=1,nbpara)
cgn 1788  format(5I8)
cgn      print 1789,(carach(iaux,nrfonc),iaux=1,nbpara)
cgn 1789  format(5(a8,1x))
c
c====
c 2. caracteristiques de la fonction
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFOR2', nompro
#endif
      iaux = nrfonc
      call pcfor2 ( nbpara, carenf, carach,
     >              iaux,
     >              typfon, typcha, typgeo, typass,
     >              ngauss, nnenmx, nnvapr, carsup, nbtafo,
     >              n1vale, n1valr, n1prpg, n1obch, n1lipr,
     >              npenmx, npvapr,
     >              p1vale, p1valr, p1prpg, p1obch, p1vatt,
     >              p1vane, p1tyas,
     >              nrfon2, nrfon3,
     >              nofonc,
     >              obpcan, obpcap, obprof, adpcan, adpcap,
     >              oblopg,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nofonc
#endif
c
c====
c 3. mise a jour des informations
c====
c
c 3.1. ==> nombre de valeurs du profil
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nofonc, 4, npvapr, codret )
c
      endif
c
c 3.2. ==> les noms
c
      if ( codret.eq.0 ) then
c
      smem(p1prpg  ) = obprof
      smem(p1prpg+1) = oblopg
c
      endif
c
c 3.3. ==> changement de degre
c
      if ( option.eq.1 ) then
c
c 3.3.1. ==> le champ associe a la fonction
c            remarque : on aurait pu modifier utmoch
c
      do 332 , iaux =  1 , nbtafo
c
        if ( codret.eq.0 ) then
c
        obinch = smem(n1obch-1+iaux)
        call gmadoj ( obinch//'.Cham_Ent', adinch, jaux, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        imem(adinch  ) = carenf(3,nrfonc)
        imem(adinch+3) = carenf(5,nrfonc)
c
        endif
c
  332 continue
c
      endif
c
c====
c 4. compactage des valeurs pour les fonctions sur les elements
c    remarque : le traitement sur les fonctions aux noeuds est
c               different. Il est fait directement dans pcsono.
c====
c
      if ( codret.eq.0 ) then
cgn      print *,nompro
cgn      print *,'p1vatt = ',p1vatt
cgn      print *,'rmem(p1vatt+13) = ',rmem(p1vatt+13)
c
      if ( typgeo.ne.0 ) then
c
        if  ( ngauss.eq.ednopg ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSRC1', nompro
#endif
          call utsrc1 ( nbtafo, rseutc,
     >                  imem(adpcap), rmem(p1vatt), rmem(p1valr) )
c
        else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSRC2', nompro
#endif
          call utsrc2 ( nbtafo, ngauss, rseutc,
     >                  imem(adpcap), rmem(p1vatt), rmem(p1valr) )
c
        endif
c
cgn      print *,nompro,' ==> codret = ',codret
cgn      print 1790,(rmem(p1valr+iaux-1),iaux=1,nbtafo*rsevca)
cgn 1790 format(10g13.5)
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nofonc)
      call gmprsx (nompro,nofonc//'.ValeursR')
      call gmprsx (nompro,nofonc//'.InfoPrPG')
      if ( npvapr.gt.0 ) then
        call gmprsx (nompro,obprof)
      endif
      if ( oblopg.ne.blan08 ) then
        call gmprsx (nompro,oblopg)
      endif
#endif
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
