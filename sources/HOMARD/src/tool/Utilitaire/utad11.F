      subroutine utad11 ( option, ncnoeu, nccono,
     >                    adcoor, adfano, adneno, adcocs,
     >                    adtyel, adfael, adnoel, adneel,
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
c    UTilitaire - ADresses - phase 11
c    --           --               --
c ______________________________________________________________________
c   Recuperation des adresses des tableaux pour MC_Noe et MC_CNo
c   Remarque : le code de retour en entree ne doit pas etre ecrase
c              brutalement ; il doit etre cumule avec les operations
c              de ce programme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . option de pilotage des adresses a recuperer.
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : coordonnees des noeuds                .
c .        .     .        .  3 : famille MED des noeuds                .
c .        .     .        .  5 : numerotation externe des noeuds       .
c .        .     .        .  7 : type des elements                     .
c .        .     .        . 11 : famille MED des elements              .
c .        .     .        . 13 : noeuds des elements                   .
c .        .     .        . 17 : numerotation externe des elements     .
c .        .     .        . 19 : constantes des coordonnees            .
c . ncnoeu . e   . char8  . nom de la branche Noeud                    .
c . nccono . e   . char8  . nom de la branche ConnNoeu                 .
c . adcoor .  s  .   1    . coordonnees des noeuds                     .
c . adfano .  s  .   1    . famille MED des noeuds                     .
c . adneno .  s  .   1    . numerotation externe des noeuds            .
c . adcocs .  s  .   1    . constantes des coordonnees                 .
c . adtyel .  s  .   1    . type des elements                          .
c . adfael .  s  .   1    . famille MED des elements                   .
c . adnoel .  s  .   1    . noeuds des elements                        .
c . adneel .  s  .   1    . numerotation externe des elements          .
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
      parameter ( nompro = 'UTAD11' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 ncnoeu, nccono
c
      integer option
      integer adcoor, adfano, adneno, adcocs
      integer adtyel, adfael, adnoel, adneel
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
      integer tabcod(8)
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
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Adresses relatives aux entites'')'
      texte(1,5) = '(''Option :'',i10)'
      texte(1,8) = '(''Codes de retour'',20i3)'
c
      texte(2,4) = '(''Adresses for entities'')'
      texte(2,5) = '(''Option :'',i10)'
      texte(2,6) = '(''Error codes'',20i3)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) option
      call dmflsh (iaux)
#endif
c
      do 10 , iaux = 1 , 8
        tabcod(iaux) = 0
   10 continue
c
c====
c 2. recuperation des adresses
c====
c
      if ( option.gt.0 ) then
c
c 2.1. ==> Coordonnees des noeuds
c
      if ( mod(option,2).eq.0 ) then
c
        call gmadoj ( ncnoeu//'.Coor', adcoor, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 1
          tabcod(1) = codre0
        endif
c
      endif
c
c 2.2. ==> Famille MED des noeuds
c
      if ( mod(option,3).eq.0 ) then
c
        call gmadoj ( ncnoeu//'.FamilMED', adfano, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 2
          tabcod(2) = codre0
        endif
c
      endif
c
c 2.3. ==> Numerotation externe des noeuds
c
      if ( mod(option,5).eq.0 ) then
c
        call gmadoj ( ncnoeu//'.NumeExte', adneno, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 3
          tabcod(3) = codre0
        endif
c
      endif
c
c 2.4. ==> Type des elements
c
      if ( mod(option,7).eq.0 ) then
c
        call gmadoj ( nccono//'.Type', adtyel, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 4
          tabcod(4) = codre0
        endif
c
      endif
c
c 2.5. ==> Famille MED des elements
c
      if ( mod(option,11).eq.0 ) then
c
        call gmadoj ( nccono//'.FamilMED', adfael, iaux, codre0)
c
        if ( codre0.ne.0 ) then
          codret = 5
          tabcod(5) = codre0
        endif
c
      endif
c
c 2.6. ==> Noeuds des elements
c
      if ( mod(option,13).eq.0 ) then
c
        call gmadoj ( nccono//'.Noeuds', adnoel, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 6
          tabcod(6) = codre0
        endif
c
      endif
c
c 2.7. ==> Numerotation externe des elements
c
      if ( mod(option,17).eq.0 ) then
c
        call gmadoj ( nccono//'.NumeExte', adneel, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 7
          tabcod(7) = codre0
        endif
c
      endif
c
c 2.8. ==> Constantes liees aux coordonnees
c
      if ( mod(option,19).eq.0 ) then
c
        call gmadoj ( ncnoeu//'.CoorCons', adcocs, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 8
          tabcod(8) = codre0
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
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) option
      write (ulsort,texte(langue,8)) tabcod
      call gmprsx ( nompro, nccono )
      call gmprsx ( nompro, ncnoeu )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
