      subroutine pcfor1 ( option,
     >                    nofonc, nrfonc,
     >                    nbpara, carenf, carchf,
     >                    nopafo, nbfopa,
     >                    nbtrav, litrav,
     >                    typfon, typcha, typgeo, nbtyas,
     >                    ngauss, nbenmx, nbvapr,
     >                    carsup, nbtafo, typint,
     >                    lgtbix, tbiaux,
     >                    advale, advalr, adobch, adprpg, adtyas,
     >                    advatt,
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
c    aPres adaptation - Fonctions - Recuperation - phase 1
c     -                 --          -                    -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . option du traitement                       .
c .        .     .        . -1 : Pas de changement dans le maillage    .
c .        .     .        .  0 : Adaptation complete                   .
c .        .     .        .  1 : Modification de degre                 .
c . nofonc . e   . char8  . nom de l'objet fonction similaire          .
c . nrfonc . e   .   1    . numero de la fonction dans le tableau      .
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
c .        .     .        .  8 : nbtafo                                .
c .        .     .        .  9 : libre                                 .
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
c . nopafo . es  .    1   . nom du paquet de fonctions a enrichir      .
c . nbfopa .  s  .   1    . nombre de fonctions du paquet a enrichir   .
c . nbtrav . es  .   1    . nombre de tableaux de travail crees        .
c . litrav . es  .   *    . liste des noms de tableaux de travail crees.
c . typcha . e   .   1    . edin64/edfl64 selon entier/reel            .
c . typgeo . e   .   1    . type geometrique au sens MED               .
c . ngauss . e   .   1    . nombre de points de Gauss                  .
c . nbenmx . e   .   1    . nombre d'entites maximum                   .
c . nbvapr . e   .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil                       .
c . nbtyas . e   .   1    . nombre de types de support associes        .
c . carsup . e   .   1    . caracteristiques du support                .
c .        .     .        . 1, si aux noeuds par element               .
c .        .     .        . 2, si aux points de Gauss, associe avec    .
c .        .     .        .    n champ aux noeuds par elements         .
c .        .     .        . 3 si aux points de Gauss autonome          .
c .        .     .        . 0, sinon                                   .
c . nbtafo . e   .   1    . nombre de tableaux de la fonction          .
c . typint . e   .        . type interpolation                         .
c .        .     .        . 0, si automatique                          .
c .        .     .        . 1 si degre 1, 2 si degre 2,                .
c .        .     .        . 3 si iso-P2                                .
c . lgtbix . e   .   1    . nouveau nombre de types de support associes.
c . tbiaux . e   . lgtbix . nouveaux types de support associes         .
c . advale .   s .   1    . adresse du tableau de valeurs entieres     .
c . advalr .   s .   1    . adresse du tableau de valeurs reelles      .
c . adobch .   s .   1    . adresse des noms des objets 'Champ'        .
c . adprpg .   s .   1    . adresse des noms des objets 'Profil' et    .
c .        .     .        . 'LocaPG' eventuellement associes           .
c . adtyas .   s .   1    . adresse des types associes                 .
c . advatt .   s .   1    . adresse du tableau de travail              .
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
      parameter ( nompro = 'PCFOR1' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombsr.h"
#include "gmenti.h"
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbpara
      integer carenf(nbpara,*)
c
      integer nrfonc
      integer typfon, typcha, typgeo, nbtyas
      integer ngauss, nbenmx, nbvapr
      integer carsup, nbtafo, typint
      integer nbfopa, nbtrav
      integer advale, advalr, adprpg, adtyas
      integer adobch, advatt
      integer lgtbix, tbiaux(lgtbix)
c
      character*8 nofonc
      character*8 carchf(nbpara,*)
      character*8 litrav(*)
      character*8 nopafo
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux, maux
      integer adobfo
c
      integer ngausa, nnenma, nnvapa, nbtyaa
      integer carsua, nbtafa, typina
      integer apvane, anvala, anobca, anprpa, antyaa
      integer codre1, codre2
      integer codre0
c
      character*8 nofon2
      character*8 saux08
      character*8 tbsaux(1)
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
      texte(1,4) = '(''Fonction de depart : '',a)'
      texte(1,5) = '(''Fonction creee : '',a)'
      texte(1,6) = '(''En retour de '',a,'', codret ='',i13)'
c
      texte(2,4) = '(''Initial function : '',a)'
      texte(2,5) = '(''Created function : '',a)'
      texte(2,6) = '(''Back from '',a,'', codret ='',i13)'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nofonc
      write (ulsort,90002) 'option', option
#endif
cgn      print *, 'DEBUT DE ',nompro, ' pour la fonction numero ',nrfonc
cgn      print 1788,(carenf(iaux,nrfonc),iaux=1,nbpara)
cgn      print 1789,(carchf(iaux,nrfonc),iaux=1,9)
c
c====
c 2. modification eventuelle des caracteristiques
c====
c
      if ( codret.eq.0 ) then
c
      if ( option.eq.1 ) then
c
cgn      write (ulsort,90002) 'typgeo initial', typgeo
        typgeo = medt12(typgeo)
cgn      write (ulsort,90002) 'ngauss typgeo', typgeo
c
        if ( carsup.eq.1 ) then
cgn      write (ulsort,90002) 'ngauss initial', ngauss
          ngauss = mednnm(typgeo)
cgn      write (ulsort,90002) 'nouveau ngauss', ngauss
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'ngauss', ngauss
      write (ulsort,90002) 'nbenmx', nbenmx
      write (ulsort,90002) 'nbvapr', nbvapr
      write (ulsort,90002) 'nbtyas', nbtyas
      write (ulsort,90002) 'carsup', carsup
      write (ulsort,90002) 'nbtafo', nbtafo
      write (ulsort,90002) 'typint', typint
      write (ulsort,90002) 'lgtbix', lgtbix
      if ( lgtbix.gt.0 ) then
        write (ulsort,90002) '==> ', (tbiaux(iaux),iaux=1,lgtbix)
      endif
#endif
c
      endif
c
c====
c 3. allocation de la fonction
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALFO', nompro
#endif
      call utalfo ( nofon2, typcha,
     >              typgeo, ngauss, nbenmx, nbvapr, nbtyas,
     >              carsup, nbtafo, typint,
     >              advale, advalr, adobch, adprpg, adtyas,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,6)) 'utalfo', codret
      endif
      write (ulsort,texte(langue,5)) nofon2
      call gmprsx (nompro, nofon2 )
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      carenf( 1,nrfonc) = typfon
      carenf( 2,nrfonc) = typcha
      carenf( 3,nrfonc) = typgeo
      carenf( 4,nrfonc) = nbtyas
      carenf( 5,nrfonc) = ngauss
      carenf( 6,nrfonc) = 0
      carenf( 7,nrfonc) = nbvapr
      carenf( 8,nrfonc) = carsup
      carenf( 9,nrfonc) = nbtafo
      carenf(15,nrfonc) = nbenmx
      carenf(16,nrfonc) = nbvapr
      carenf(17,nrfonc) = advale
      carenf(18,nrfonc) = advalr
      carenf(19,nrfonc) = adobch
      carenf(20,nrfonc) = adprpg
      carenf(23,nrfonc) = adtyas
c
      carchf( 1,nrfonc) = nofon2
c
      endif
c
c====
c 4. caracteristiques des supports associes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. supports associes ; codret = ', codret
#endif
c
c 4.1. ==> S'il n'y a pas d'ajout de fonction pour la conformite,
c          lgtbix vaut nbtyas.
c          Donc si on avait deja des supports (nbtyas>0), il faut
c          recopier le tableau.
c
      if ( lgtbix.eq.nbtyas ) then
c
        if ( nbtyas.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Copie de', nofonc//'.TypeSuAs',
     >                 ' vers', nofon2//'.TypeSuAs'
#endif
          call gmcpgp ( nofonc//'.TypeSuAs',
     >                  nofon2//'.TypeSuAs', codret )
c
          endif
c
        endif
c
c 4.2. ==> S'il y a de nouveau support, lgtbix est different de nbtyas.
c          Il faut creer la liste des supports.
c
      else
c
        if ( lgtbix.gt.0 ) then
c
c 4.2.1. ==> On commence par detruire le tableau s'il existait
c
          if ( codret.eq.0 ) then
          if ( nbtyas.gt.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Destruction de', nofon2//'.TypeSuAs'
#endif
            call gmlboj( nofon2//'.TypeSuAs', codret )
          endif
          endif
c
c 4.2.2. ==> Allocation du tableau et mise a jour de l'attribut
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Allocation de', nofon2//'.TypeSuAs'
#endif
          iaux = lgtbix - 1
          call gmaloj ( nofon2//'.TypeSuAs', ' ',
     >                  iaux, adtyas, codre1 )
          call gmecat ( nofon2, 5, iaux, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
          endif
c
c 4.2.3. ==> Valeurs
c
          if ( codret.eq.0 ) then
c
          carenf( 4,nrfonc) = lgtbix - 1
          carenf(23,nrfonc) = adtyas
c
          jaux = adtyas - 1
          do 423 , iaux = 1 , lgtbix
            if ( tbiaux(iaux).ne.typgeo ) then
              jaux = jaux + 1
              imem(jaux) = tbiaux(iaux)
            endif
  423     continue
c
          endif
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro, nofon2 )
      call gmprsx ( nompro, nofon2//'.TypeSuAs' )
#endif
c
c====
c 5. copie des caracteristiques du champ
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. champ ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmcpgp ( nofonc//'.InfoCham',
     >              nofon2//'.InfoCham', codret )
c
      endif
c
c====
c 6. dans le cas de support element, creation d'un tableau de
c    travail pour gerer la renumerotation
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. support element ; codret = ', codret
#endif
c
      if ( typgeo.ne.0 ) then
c
c 6.1. ==> Taille
c
        if ( codret.eq.0 ) then
c
        iaux = nbtafo * rseutc
c
        if ( ngauss.ne.ednopg ) then
          iaux = ngauss*iaux
        endif
c
        endif
c
c 6.2. ==> Allocation
c
        if ( codret.eq.0 ) then
cgn      write (ulsort,90002) 'allocation a la taille', iaux
c
        call gmalot ( saux08, 'reel    ', iaux, advatt, codret )
cgn      write (ulsort,90003) 'allocation de', saux08
c
        endif
c
c 6.3. ==> Archivage
c
        if ( codret.eq.0 ) then
c
        nbtrav = nbtrav + 1
        litrav(nbtrav) = saux08
cgn        print *,nompro,' 2.3 nbtrav = ', nbtrav
cgn        print *,'litrav(',nbtrav,') = ',saux08
cgn        carenf( 5,nrfonc) = ngauss
        carenf(21,nrfonc) = advatt
c
        endif
c
      endif
c
c====
c 7. dans le cas d'un champ aux points de Gauss avec un champ aux
c    noeuds par elements associe, reperage de la fonction associee
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '7. support Gauss ; codret = ', codret
#endif
c
      if ( carsup.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
        saux08 = carchf(9,nrfonc)
cgn        call gmprsx (nompro,saux08)
cgn        call gmprsx (nompro,saux08//'.ValeursR')
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
        call utcafo ( saux08,
     >                typcha,
     >                typgeo, ngausa, nnenma, nnvapa, nbtyaa,
     >                carsua, nbtafa, typina,
     >                anvala, apvane, anobca, anprpa, antyaa,
     >                ulsort, langue, codret )
c
        carenf(22,nrfonc) = apvane
cgn        print *,'apvane = ',apvane
c
        endif
c
      endif
c
c====
c 8. ajout de la fonction au paquet de sortie
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '8. ajout ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMOPF', nompro
#endif
      iaux = 1
      call utmopf ( nopafo, iaux,
     >              iaux, tbsaux, tbiaux,
     >              nofon2,
     >              nbfopa, jaux, kaux, laux, maux,
     >              adobfo,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nopafo )
      call gmprsx (nompro, nopafo//'.Fonction' )
      call gmprsx (nompro, nofon2//'.ValeursR' )
      call gmprsx (nompro, nofon2//'.InfoPrPG' )
#endif
c
c====
c 9. la fin
c====
c
cgn      print *, 'FIN DE ',nompro, ' pour la fonction numero ',nrfonc
cgn      print 1788,(carenf(iaux,nrfonc),iaux=1,nbpara)
cgn 1788  format(10I8)
cgn      print 1789,(carchf(iaux,nrfonc),iaux=1,9)
cgn 1789  format(10(a8,1x))
cgn      print *, ' '
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
