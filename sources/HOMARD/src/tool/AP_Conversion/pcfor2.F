      subroutine pcfor2 ( nbpara, carenf, carchf,
     >                    nrfonc,
     >                    typfon, typcha, typgeo, nbtyas,
     >                    ngauss, nnenmx, nnvapr, carsup, nbtafo,
     >                    anvale, anvalr, anprpg, anobch, anlipr,
     >                    npenmx, npvapr,
     >                    apvale, apvalr, apprpg, apobch, apvatt,
     >                    apvane, aptyas,
     >                    nrfon2, nrfon3,
     >                    nofonc,
     >                    obpcan, obpcap, obprof, adpcan, adpcap,
     >                    oblopg,
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
c    aPres adaptation - Fonctions - Recuperation - phase 2
c     -                 --          -                    -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbpara . e   .   1    . nombre de parametres a enregistrer par fonc.
c . carenf . e   .nbpara* . caracteristiques entieres des fonctions :  .
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
c . carchf . e   .nbpara* . caracteristiques caracteres des fonctions :.
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
c . nrfonc . e   .    1   . numero de la fonction a examiner           .
c . typfon .   s .   1    . 0, si ancienne isolee, 1, si ancienne      .
c .        .     .        . associee a une  autre fonction, -1, si     .
c .        .     .        . nouvelle                                   .
c . typcha .   s .   1    . edin64/edfl64 selon entier/reel            .
c . typgeo .   s .   1    . type geometrique au sens MED               .
c . ngauss .   s .   1    . nombre de points de Gauss                  .
c . nbenmx .   s .   1    . nombre d'entites maximum                   .
c . nbvapr .   s .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil                       .
c . nbtyas .   s .   1    . 0, si aucun autre type geometrique n'est   .
c .        .     .        . associe dans une autre fonction            .
c .        .     .        . n, produit des types associes              .
c . nbtafo .   s .   1    . nombre de tableaux de la fonction          .
c . anvale .   s .   1    . adresse du tableau de valeurs entieres     .
c . anvalr .   s .   1    . adresse du tableau de valeurs reelles      .
c . anobch .   s .   1    . adresse des noms des objets 'Champ'        .
c . anprpg .   s .   1    . adresse des noms des objets 'Profil' et    .
c .        .     .        . 'LocaPG' eventuellement associes           .
c . anlipr .   s .   1    . adresse du tableau de travail              .
c . npenmx .   s .   1    . nombre d'entites maximum                   .
c . npvapr .   s .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil                       .
c . apvale .   s .   1    . adresse du tableau de valeurs entieres     .
c . apvalr .   s .   1    . adresse du tableau de valeurs reelles      .
c . apobch .   s .   1    . adresse des noms des objets 'Champ'        .
c . apprpg .   s .   1    . adresse des noms des objets 'Profil' et    .
c .        .     .        . 'LocaPG' eventuellement associes           .
c . apvatt .   s .   1    . adresse du tableau de travail              .
c . nofonc .   s . char*8 . nom de la fonction                         .
c . obpcan .   s . char*8 . objet du profil en entree                  .
c . obpcap .   s . char*8 . objet du profil en sortie                  .
c . obprof .   s . char*8 . objet du profil global                     .
c . oblopg .   s . char*8 . objet de la localisation des pts de Gauss  .
c . adpcan .   s .   1    . adresse du profil en entree                .
c . adpcap .   s .   1    . adresse du profil en sortie                .
c . nrfon2 .   s .   1   . numero de la 1ere fonction associee         .
c . nrfon3 .   s .   1   . numero de la 2nde fonction associee         .
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
      parameter ( nompro = 'PCFOR2' )
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
      integer nbpara
      integer carenf(nbpara,*)
c
      integer nrfonc
      integer typfon, typcha, typgeo, nbtyas
      integer ngauss, nnenmx, nnvapr, carsup, nbtafo
      integer anvale, anvalr, anprpg, anobch, anlipr
      integer npenmx, npvapr
      integer apvale, apvalr, apprpg, apobch, apvatt
      integer apvane, aptyas
      integer adpcan, adpcap
      integer nrfon2, nrfon3
c
      character*8 carchf(nbpara,*)
      character*8 nofonc, obpcan, obpcap, obprof
      character*8 oblopg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2
      integer codre0
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
      texte(1,6) = '(''.... profil '',a,'' : '',a)'
c
      texte(2,6) = '(''.... profile '',a,'' : '',a)'
c
#include "pcimp1.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nrfonc
cgn      write(ulsort,90002) 'carenf  ',(carenf(iaux,nrfonc),iaux= 1,10)
cgn      write(ulsort,90002) 'carenf  ',(carenf(iaux,nrfonc),iaux=11,20)
cgn      write(ulsort,90002) 'carenf  ',
cgn     >                    (carenf(iaux,nrfonc),iaux=21,nbpara)
cgn      write(ulsort,90003) 'carchf  ',(carchf(iaux,nrfonc),iaux= 1,9)
#endif
c
c====
c 2. le nom de l'objet fonction
c====
c
      if ( codret.eq.0 ) then
c
      nofonc = carchf( 1,nrfonc)
c
      endif
c
c====
c 3. les entiers
c====
c
      if ( codret.eq.0 ) then
c
      typfon = carenf( 1,nrfonc)
      typcha = carenf( 2,nrfonc)
      typgeo = carenf( 3,nrfonc)
      nbtyas = carenf( 4,nrfonc)
      ngauss = carenf( 5,nrfonc)
      nnenmx = carenf( 6,nrfonc)
      nnvapr = carenf( 7,nrfonc)
      carsup = carenf( 8,nrfonc)
      nbtafo = carenf( 9,nrfonc)
c
      anvale = carenf(10,nrfonc)
      anvalr = carenf(11,nrfonc)
      anobch = carenf(12,nrfonc)
      anprpg = carenf(13,nrfonc)
      anlipr = carenf(14,nrfonc)
c
      npenmx = carenf(15,nrfonc)
      npvapr = carenf(16,nrfonc)
c
      apvale = carenf(17,nrfonc)
      apvalr = carenf(18,nrfonc)
      apobch = carenf(19,nrfonc)
      apprpg = carenf(20,nrfonc)
      apvatt = carenf(21,nrfonc)
c
      apvane = carenf(22,nrfonc)
c
      aptyas = carenf(24,nrfonc)
c
      nrfon2 = carenf(25,nrfonc)
      nrfon3 = carenf(26,nrfonc)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,90002) 'typfon', typfon
      write (ulsort,90002) 'typcha', typcha
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'nbtyas', nbtyas
      write (ulsort,90002) 'ngauss', ngauss
      write (ulsort,90002) 'nnenmx', nnenmx
      write (ulsort,90002) 'nnvapr', nnvapr
      write (ulsort,90002) 'nbtafo', nbtafo
c
      write (ulsort,90002) 'npenmx', npenmx
      write (ulsort,90002) 'npvapr', npvapr
c
      write (ulsort,90002) 'anvale', anvale
      write (ulsort,90002) 'anvalr', anvalr
      write (ulsort,90002) 'anobch', anobch
      write (ulsort,90002) 'anprpg', anprpg
      write (ulsort,90002) 'anlipr', anlipr
c
      write (ulsort,90002) 'apvale', apvale
      write (ulsort,90002) 'apvalr', apvalr
      write (ulsort,90002) 'apobch', apobch
      write (ulsort,90002) 'apprpg', apprpg
      write (ulsort,90002) 'apvatt', apvatt
c
      write (ulsort,90002) 'apvane', apvane
c
      write (ulsort,90002) 'aptyas', aptyas
c
      write (ulsort,90002) 'nrfon2', nrfon2
      write (ulsort,90002) 'nrfon3', nrfon3
#endif
c
c====
c 4. les noms des profils
c====
c
      if ( codret.eq.0 ) then
c
      obpcan = carchf( 4,nrfonc)
      obpcap = carchf( 5,nrfonc)
      obprof = carchf( 6,nrfonc)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) ' '
      write (ulsort,texte(langue,6)) 'n', obpcan
      call gmprsx (nompro,obpcan)
      write (ulsort,texte(langue,6)) 'p', obpcap
      call gmprsx (nompro,obpcap)
      write (ulsort,texte(langue,6)) 'g', obprof
#endif
c
      if ( typfon.ge.0 ) then
        call gmadoj ( obpcan, adpcan, iaux, codre1 )
      else
        codre1 = 0
      endif
      call gmadoj ( obpcap, adpcap, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 5. les localisations de points de Gauss
c====
c
      if ( codret.eq.0 ) then
c
      oblopg = carchf( 7,nrfonc)
c
#ifdef _DEBUG_HOMARD_
      if ( oblopg.ne.blan08 ) then
      write (ulsort,*) ' '
      write (ulsort,*) 'Objet localisations des points de Gauss'
      call gmprsx (nompro,oblopg)
      endif
#endif
c
      endif
c
c====
c 6. la fin
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
