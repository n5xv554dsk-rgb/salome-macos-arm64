      subroutine utalfo ( nofonc,
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
c    UTilitaire - ALlocation d'une FOnction
c    --           --               --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nofonc .   s . char8  . nom de l'objet fonction                    .
c . typcha . e   .   1    . edin64/edfl64 selon entier/reel            .
c . typgeo . e   .   1    . type geometrique au sens MED               .
c . ngauss . e   .   1    . nombre de points de Gauss                  .
c . nbenmx . e   .   1    . nombre d'entites maximum                   .
c . nbvapr . e   .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil                       .
c . nbtyas . e   .   1    . nombre de types de support associes        .
c . carsup . e   .   1    . caracteristiques du support                .
c .        .     .        . 1, si aux noeuds par elements              .
c .        .     .        . 2, si aux points de Gauss, associe avec    .
c .        .     .        .    n champ aux noeuds par elements         .
c .        .     .        . 3 si aux points de Gauss autonome          .
c .        .     .        . 0, sinon                                   .
c . nbtafo . e   .   1    . nombre de tableaux de la fonction          .
c . typint . e   .        . type interpolation                         .
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
      parameter ( nompro = 'UTALFO' )
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
      character*8 nofonc
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      write (ulsort,90002) 'typcha', typcha
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'ngauss', ngauss
      write (ulsort,90002) 'nbenmx', nbenmx
      write (ulsort,90002) 'nbvapr', nbvapr
      write (ulsort,90002) 'nbtyas', nbtyas
      write (ulsort,90002) 'carsup', carsup
      write (ulsort,90002) 'nbtafo', nbtafo
      write (ulsort,90002) 'typint', typint
      call dmflsh (iaux)
#endif
c
c====
c 2. creation de la fonction
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
      call gmalot ( nofonc, 'Fonction', 0, iaux, codret )
c
      endif
c
c 2.2. ==> les caracteristiques de cette fonction
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nofonc, 1, typgeo, codre1 )
      call gmecat ( nofonc, 2, ngauss, codre2 )
      call gmecat ( nofonc, 3, nbenmx, codre3 )
      call gmecat ( nofonc, 4, nbvapr, codre4 )
      call gmecat ( nofonc, 5, nbtyas, codre5 )
      call gmecat ( nofonc, 6, carsup, codre6 )
      call gmecat ( nofonc, 7, nbtafo, codre7 )
      call gmecat ( nofonc, 8, typint, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      iaux = nbenmx*nbtafo
      if ( ngauss.ne.ednopg ) then
        iaux = iaux*ngauss
      endif
      if ( typcha.eq.edfl64 ) then
        call gmaloj ( nofonc//'.ValeursR', ' ', iaux, advalr, codre1 )
      else
        call gmaloj ( nofonc//'.ValeursE', ' ', iaux, advale, codre1 )
      endif
      call gmaloj ( nofonc//'.InfoCham', ' ', nbtafo, adobch, codre2 )
      iaux = 3
      call gmaloj ( nofonc//'.InfoPrPG', ' ', iaux, adprpg, codre3 )
      if ( nbtyas.gt.0 ) then
        call gmaloj ( nofonc//'.TypeSuAs', ' ', nbtyas, adtyas, codre4 )
      else
        codre4 = 0
      endif
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nofonc )
cgn      call gmprot (nompro, nofonc//'.ValeursR', 1, 10 )
cgn      call gmprsx (nompro, nofonc//'.InfoCham' )
cgn      call gmprsx (nompro, nofonc//'.InfoPrPG' )
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
