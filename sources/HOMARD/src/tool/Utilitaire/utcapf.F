      subroutine utcapf ( obpafo,
     >                    nbfopa, typgpf, ngauss, carsup, typint,
     >                    adobfo, adtyge,
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
c    UTilitaire - CAracteristiques d'un Paquet de Fonctions
c    --           --                    -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . obpafo . e   . char8  . nom de l'objet du paquet de fonctions      .
c . nbfopa .   s .   1    . nombre de fonctions dans le paquet         .
c . typgpf .  s  .   1    . si >0 : type geometrique s'il est unique   .
c .        .     .        . si <0 : nombre de type geometriques associe.
c . ngauss .   s .   1    . nombre de points de gauss                  .
c . carsup .   s .   1    . caracteristiques du support                .
c .        .     .        . 1, si aux noeuds par elements              .
c .        .     .        . 2, si aux points de Gauss, associe avec    .
c .        .     .        .    n champ aux noeuds par elements         .
c .        .     .        . 3 si aux points de Gauss autonome          .
c .        .     .        . 0, sinon                                   .
c . typint .   s .   s    . type d'interpolation                       .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  elements : 0 si intensif, sans orientation.
c .        .     .        .             1 si extensif, sans orientation.
c .        .     .        .             2 si intensif, avec orientation.
c .        .     .        .             3 si extensif, avec orientation.
c .        .     .        .  noeuds : 1 si degre 1                     .
c .        .     .        .           2 si degre 2                     .
c .        .     .        .           3 si iso-P2                      .
c . adobfo .   s .   1    . adresse des noms des objets 'Fonction' et  .
c .        .     .        . de l'eventuel paquet associe               .
c . adtyge .   s .   1    . adresse des types geometriques             .
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
      parameter ( nompro = 'UTCAPF' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 obpafo
c
      integer nbfopa, typgpf, ngauss, carsup, typint
      integer adobfo, adtyge
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
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
      texte(1,4) =
     > '(''Impossible de lire les attributs de l''''objet '',a)'
      texte(1,5) =
     > '(''Impossible de lire les valeurs de l''''objet '',a)'
c
      texte(2,4) = '(''Attributes of object '',a,'' cannot be read.'')'
      texte(2,5) = '(''Values of object '',a,'' cannot be read.'')'
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, obpafo )
      call gmprsx (nompro, obpafo//'.Fonction' )
#endif
c
      codret = 0
c
c====
c 2. caracteristiques du paquet de fonctions
c====
c
      call gmliat ( obpafo, 1, nbfopa, codre1 )
      call gmliat ( obpafo, 2, typgpf, codre2 )
      call gmliat ( obpafo, 3, ngauss, codre3 )
      call gmliat ( obpafo, 4, carsup, codre4 )
      call gmliat ( obpafo, 5, typint, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      if ( codret.ne.0 ) then
      write (ulsort,texte(langue,4)) obpafo
      endif
c
c====
c 3. les branches
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. branches ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( obpafo//'.Fonction', adobfo, iaux, codret )
c
      if ( codret.ne.0 ) then
      write (ulsort,texte(langue,5)) obpafo
      endif
c
      endif
c
      if ( typgpf.lt.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( obpafo//'.TypeSuAs', adtyge, iaux, codret )
c
        if ( codret.ne.0 ) then
        write (ulsort,texte(langue,5)) obpafo
        endif
c
        endif
c
      endif
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
