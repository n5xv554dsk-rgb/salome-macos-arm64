      subroutine pccapg ( npfopa, nplopg, lilopg,
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
c                                   des Points de Gauss
c                                       -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . npfopa . e   .   1    . nombre de fonctions a traiter              .
c . nplopg . es  .   1    . nbre de localisations en sortie enregistres.
c . lilopg . es  . char*8 . nom des objets de type 'LocaPG' enregistres.
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
c .        .     .        .  7 : ngauss                                .
c .        .     .        .  8 : carsup                                .
c .        .     .        .  9 : nbtafo                                .
c .        .     .        . 10 : anvale                                .
c .        .     .        . 11 : anvalr                                .
c .        .     .        . 12 : anobch                                .
c .        .     .        . 13 : adprpg                                .
c .        .     .        . 14 : anlipr                                .
c .        .     .        . 15 : npenmx                                .
c .        .     .        . 16 : ngauss                                .
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
      parameter ( nompro = 'PCCAPG' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer npfopa, nplopg
      integer nbpara
      integer carenf(nbpara,*)
c
      character*8 lilopg(*)
      character*8 carach(nbpara,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nrfonc
      integer ngauss, carsup
c
      character*8 oblopg
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
      texte(1,4) = '(''.. Fonction numero '',i6)'
      texte(1,5) = '(''Nom de l''''objet localisation = '',a8)'
c
      texte(2,4) = '(''.. Function # '',i6)'
      texte(2,5) = '(''Name of the localization object = '',a8)'
c
#include "impr03.h"
c
c====
c 2. mise a jour des caracteristiques des localications
c====
c
      do 20 , nrfonc = 1 , npfopa
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nrfonc
#endif
cgn      write (ulsort,90002) nompro,
cgn     >(carenf(iaux,nrfonc),iaux=1,nbpara)
cgn      print 1789,(carach(iaux,nrfonc),iaux=1,nbpara)
cgn 1789  format(5(a8,1x))
c
        if ( codret.eq.0 ) then
c
        ngauss = carenf(5,nrfonc)
        carsup = carenf(8,nrfonc)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'ancien ngauss', ngauss
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,*) 'carach( 7,nrfonc) : ', carach( 7,nrfonc)//'XX'
        write (ulsort,*) '           blan08 : ', blan08//'XX'
#endif
c
        endif
c
c 2.1. ==> creation de la localisation eventuelle
c
        oblopg = blan08
c
        if ( carach( 7,nrfonc).ne.blan08 ) then
c
          if ( codret.eq.0 ) then
c
          oblopg = carach( 7,nrfonc)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,5)) oblopg
          call gmprsx (nompro, oblopg )
#endif
c
          endif
c
        endif
c
        if ( ngauss.eq.ednopg ) then
          ngauss = 1
        endif
c
c 2.2. ==> archivages
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nouveau ngauss', ngauss
#endif
        carenf( 5,nrfonc) = ngauss
        carach( 7,nrfonc) = oblopg
c
        endif
c
c 2.3. ==> si la localisation n'est pas dans la liste, on l'ajoute
c
        if ( codret.eq.0 ) then
c
        if ( oblopg.ne.blan08 ) then
c
          do 231 , iaux = 1 , nplopg
c
            if ( lilopg(iaux).eq.oblopg ) then
              goto 232
            endif
c
  231     continue
c
          nplopg = nplopg + 1
          lilopg(nplopg) = oblopg
c
  232     continue
c
        endif
c
        endif
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nplopg', nplopg
#endif
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
