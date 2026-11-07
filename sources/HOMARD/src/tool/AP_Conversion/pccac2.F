      subroutine pccac2 ( nofonc, nnfonc,
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
c    aPres adaptation - mise a jour des CAracteristiques des Champs - 2
c     -                                 --                   -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nofonc . e   . char8  . nom de la fonction a ajouter               .
c . nnfonc . e   . char8  . nom de la fonction associee                .
c . adinch .   s .   1    . adresse de l'information sur les champs    .
c . adinpf .   s .   1    . adresse de l'information sur les fonctions .
c . adinpr .   s .   1    . adresse de l'information sur les profils   .
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
      parameter ( nompro = 'PCCAC2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      character*8 nofonc
      character*8 nnfonc
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codre1, codre2
      integer codre0
c
      integer nbtafo
      integer adobch
      integer nbcomp, nbtvch, typcha
      integer adnocp, adcaen, adcare, adcaca
c
      character*8 nocham, saux08
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
      texte(1,4) = '(''Nom de la fonction a ajouter : '',a8)'
      texte(1,5) = '(''Nom de la fonction associee  : '',a8)'
      texte(1,6) = '(''..... Tableau'',i4,'' ==> Nom du champ : '',a)'
      texte(1,7) = '(''..... Avant l''''ajout de la fonction :'')'
      texte(1,8) = '(''..... Apres l''''ajout de la fonction :'')'
      texte(1,9) = '(''Nombre de tableaux :'',i8)'
c
      texte(2,4) = '(''Name of the function to add     : '',a8)'
      texte(2,5) = '(''Name of the associated function : '',a8)'
      texte(2,6) = '(''..... Array'',i4,'' ==> Name of field : '',a)'
      texte(2,7) = '(''..... Before the addition of function :'')'
      texte(2,8) = '(''..... Following the addition of function :'')'
      texte(2,9) = '(''Number of arrays :'',i8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nofonc
      call gmprsx (nompro, nofonc )
      write (ulsort,texte(langue,5)) nnfonc
      call gmprsx (nompro, nnfonc )
      call gmprsx (nompro, nnfonc//'.InfoCham' )
#endif
c
c====
c 2. mise a jour des caracteristiques du champ
c====
c
c 2.1. ==> reperage des tableaux et des champs associes a cette fonction
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nofonc, 7, nbtafo, codre1 )
      call gmadoj ( nofonc//'.InfoCham', adobch, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) nbtafo
#endif
c
c 2.2. ==> enregistrement du champ associe a chaque tableau de
c          cette fonction
c
      if ( codret.eq.0 ) then
c
      saux08 = '        '
c               12345678
c
      do 22 , jaux = 1 , nbtafo
c
        nocham = smem(adobch+jaux-1)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) jaux, nocham
#endif
c
        if ( nocham.ne.saux08 ) then
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,texte(langue,7))
          call gmprsx (nompro, nocham )
          call gmprsx (nompro, nocham//'.Cham_Ent' )
          call gmprsx (nompro, nocham//'.Cham_Car' )
          endif
#endif
c
          iaux = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMOCH', nompro
#endif
          call utmoch ( nocham, iaux,
     >                  nofonc, nnfonc,
     >                  nbcomp, nbtvch, typcha,
     >                  adnocp, adcaen, adcare, adcaca,
     >                  ulsort, langue, codret )
c
          saux08 = nocham
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,texte(langue,8))
          call gmprsx (nompro, nocham )
          call gmprsx (nompro, nocham//'.Cham_Ent' )
          call gmprsx (nompro, nocham//'.Cham_Car' )
          endif
#endif
c
        endif
c
   22 continue
c
      endif
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
