      subroutine utcafo ( obfonc,
     >                    typcha,
     >                    typgeo, ngauss, nbenmx, nbvapr, nbtyas,
     >                    carsup, nbtafo, typint,
     >                    advale, advalr, adobch, adprpg, adtyas,
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
c    UTilitaire - CAracteristiques d'une FOnction
c    --           --                     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . obfonc . e   . char8  . nom de l'objet fonction                    .
c . typcha .   s .   1    . edin32/edin64/edfl64 selon entier/reel     .
c . typgeo .   s .   1    . type geometrique au sens MED               .
c . ngauss .   s .   1    . nombre de points de Gauss                  .
c . nbenmx .   s .   1    . nombre d'entites maximum                   .
c . nbvapr .   s .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil                       .
c . nbtyas .   s .   1    . nombre de types de support associes        .
c . carsup .   s .   1    . caracteristiques du support                .
c .        .     .        . 1, si aux noeuds par elements              .
c .        .     .        . 2, si aux points de Gauss, associe avec    .
c .        .     .        .    n champ aux noeuds par elements         .
c .        .     .        . 3 si aux points de Gauss autonome          .
c .        .     .        . 0, sinon                                   .
c . nbtafo .   s .   1    . nombre de tableaux de la fonction          .
c . typint .   s .        . type interpolation                         .
c .        .     .        . 0, si automatique                          .
c .        .     .        . 1 si degre 1, 2 si degre 2,                .
c .        .     .        . 3 si iso-P2                                .
c . advale .   s .   1    . adresse du tableau de valeurs entieres     .
c . advalr .   s .   1    . adresse du tableau de valeurs reelles      .
c . adobch .   s .   1    . adresse des noms des objets 'Champ'        .
c . adprpg .   s .   1    . adresse des noms des objets 'Profil',      .
c .        .     .        . 'LocaPG' et fonction aux noeuds par        .
c .        .     .        . elements eventuellement associes           .
c . adtyas .   s .   1    . adresse des types associes                 .
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
      parameter ( nompro = 'UTCAFO' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "meddc0.h"
c
c 0.3. ==> arguments
c
      character*8 obfonc
c
      integer typcha
      integer typgeo, ngauss, nbenmx, nbvapr, nbtyas
      integer carsup, nbtafo, typint
      integer advale, advalr, adobch, adprpg, adtyas
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Impossible de lire les attributs de l''''objet '',a)'
      texte(1,5) =
     > '(''Impossible de lire les adresses de l''''objet '',a)'
      texte(1,6) =
     > '(''Impossible de lire les valeurs de l''''objet '',a)'
c
      texte(2,4) = '(''Attributes of object '',a,'' cannot be read.'')'
      texte(2,5) = '(''Adresses of object '',a,'' cannot be read.'')'
      texte(2,6) = '(''Values of object '',a,'' cannot be read.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, obfonc )
      call gmprot (nompro, obfonc//'.ValeursR', 1, 10 )
      call gmprsx (nompro, obfonc//'.InfoCham' )
      call gmprsx (nompro, obfonc//'.InfoPrPG' )
      call gmprsx (nompro, obfonc//'.TypeSuAs' )
#endif
c
      codret = 0
c
c====
c 2. caracteristiques de la fonction
c====
c
c 2.1. ==> Les attributs
c
      call gmliat ( obfonc, 1, typgeo, codre1 )
      call gmliat ( obfonc, 2, ngauss, codre2 )
      call gmliat ( obfonc, 3, nbenmx, codre3 )
      call gmliat ( obfonc, 4, nbvapr, codre4 )
      call gmliat ( obfonc, 5, nbtyas, codre5 )
      call gmliat ( obfonc, 6, carsup, codre6 )
      call gmliat ( obfonc, 7, nbtafo, codre7 )
      call gmliat ( obfonc, 8, typint, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
      write (ulsort,texte(langue,4)) obfonc
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'ngauss', ngauss
      write (ulsort,90002) 'nbenmx', nbenmx
      write (ulsort,90002) 'nbvapr', nbvapr
      write (ulsort,90002) 'nbtyas', nbtyas
      write (ulsort,90002) 'carsup', carsup
      write (ulsort,90002) 'nbtafo', nbtafo
      write (ulsort,90002) 'typint', typint
      if ( nbtyas.gt.0 ) then
      call gmprsx (nompro, obfonc//'.TypeSuAs' )
      endif
      endif
#endif
c
c 2.2. ==> Les adresses
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( obfonc//'.InfoCham', adobch, iaux, codre1 )
      call gmadoj ( obfonc//'.InfoPrPG', adprpg, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      if ( codret.ne.0 ) then
      write (ulsort,texte(langue,5)) obfonc//'.InfoCham/InfoPrPG'
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmobal ( obfonc//'.ValeursR', codre1 )
      if ( codre1.eq.0 ) then
        call gmadoj ( obfonc//'.ValeursE', advale, iaux, codre2 )
        typcha = edint
      elseif ( codre1.eq.2 ) then
        codre1 = 0
        call gmadoj ( obfonc//'.ValeursR', advalr, iaux, codre2 )
        typcha = edfl64
      else
        codre1 = 2
      endif
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typcha', typcha
#endif
c
      if ( codret.ne.0 ) then
      write (ulsort,texte(langue,6)) obfonc//'.ValeursR/E'
      endif
c
      endif
c
      if ( nbtyas.gt.0 ) then
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( obfonc//'.TypeSuAs', adtyas, iaux, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      if ( codret.ne.0 ) then
      write (ulsort,texte(langue,5)) obfonc//'.TypeSuAs'
      endif
c
      endif
c
      endif
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
      end
