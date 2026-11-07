      subroutine utad31 ( option, nohind, typenh,
     >                    nbval, nbcomp,
     >                    adsupp, advale, advalr, typind,
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
c    UTilitaire - ADresses - phase 31
c    --           --               --
c ______________________________________________________________________
c   Recuperation des adresses des tableaux pour une entite Indicate
c   Remarque : le code de retour en entree ne doit pas etre ecrase
c              brutalement ; il doit etre cumule avec les operations
c              de ce programme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . option de pilotage des adresses a recuperer.
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : attributs                             .
c .        .     .        .  3 : adresse du support                    .
c .        .     .        .  5 : adresses des valeurs                  .
c .        .     .        . si negatif, on n'arrete pas quand la       .
c .        .     .        . structure n'est pas allouee                .
c . nohind . e   . char8  . nom de l'objet decrivant l'indicateur      .
c . typenh . e   .   1    . code des entites                           .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nbval  .   s  .  1    . nombre de valeurs par composante           .
c . nbcomp .   s  .  1    . nombre de composantes                      .
c . adsupp .   s  .  1    . support                                    .
c . advale .   s  .  1    . valeurs entieres, -1 si inexistante        .
c . advalr .   s  .  1    . valeurs reelles, -1 si inexistante         .
c . typind .  s  .   1    . type de valeurs                            .
c .        .     .        . 2 : entieres                               .
c .        .     .        . 3 : reelles                                .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'UTAD31' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
#include "enti01.h"
c
c 0.3. ==> arguments
c
      character*8 nohind
c
      integer option
      integer typenh
      integer nbval, nbcomp
      integer adsupp, advale, advalr
      integer typind
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
      integer codre1, codre2
c
      character*14 saux14
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
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
     > '(''Adresses relatives a l''''indicateur HOMARD pour les '',a)'
      texte(1,5) = '(''Codes de retour'',20i3)'
c
      texte(2,4) = '(''Adresses for HOMARD indicator for '',a)'
      texte(2,5) = '(''Error codes'',20i3)'
c
 1001 format ('Structure :',a)
 1002 format ('Option :',i10)
c
c====
c 2. recuperation des adresses
c====
c
      if ( option.ne.0 ) then
c
c 2.1. ==> nom de la structure
c
      saux14 = nohind//'.'//suffix(1,typenh)(1:5)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,1001) saux14
      write (ulsort,1002) option
      call dmflsh (iaux)
#endif
cgn      call gmprsx(nompro,saux14)
c
c 2.2. ==> la structure est-elle alloue ?
c
      call gmobal ( saux14, codre0 )
c
      if ( codre0.eq.0 ) then
        if ( option.lt.0 ) then
          goto 29
        else
          codret = max ( abs(codre0), codret )
        endif
      elseif ( codre0.ne.1 ) then
        codret = max ( abs(codre0), codret )
      endif
c
c 2.3. ==> attributs
c
      if ( mod(option,2).eq.0 ) then
c
        call gmliat ( saux14, 1, nbval, codre1 )
        call gmliat ( saux14, 2, nbcomp, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
c
c 2.4. ==> Support
c
      if ( mod(option,3).eq.0 ) then
c
        call gmadoj ( saux14//'.Support', adsupp, iaux, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
c 2.5. ==> Adresses des valeurs
c
      if ( mod(option,5).eq.0 ) then
c
        advale = -1
        advalr = -1
        typind = 0
c
        codre0 = 0
c
        call gmobal ( saux14//'.ValeursE', codre1 )
c
        if ( codre1.eq.2 ) then
          typind = 2
          call gmadoj ( saux14//'.ValeursE', advale, iaux, codre2 )
          if ( codre2.ne.0 ) then
            codre0 = 2
          endif
c
        elseif ( codre1.eq.0 ) then
          typind = 3
          call gmadoj ( saux14//'.ValeursR', advalr, iaux, codre2 )
          if ( codre2.ne.0 ) then
            codre0 = 2
          endif
c
        else
          codre0 = 2
        endif
c
        codret = max ( abs(codre0), codret )
c
      endif
c
      endif
c
c 2.9. ==> sortie anticipee
c
   29 continue
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
      write (ulsort,texte(langue,5)) codre1, codre2
      call gmprsx ( nompro, nohind )
      call gmprsx ( nompro, saux14 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
