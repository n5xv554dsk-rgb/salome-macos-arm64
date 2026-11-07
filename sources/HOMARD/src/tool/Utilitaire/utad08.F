      subroutine utad08 ( typenh, option, nhenti,
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
c    UTilitaire - ADresses - phase 08
c    --           --               --
c ______________________________________________________________________
c   Suppression des tableaux des familles pour une entite HOM_Enti
c   Remarque : le code de retour en entree ne doit pas etre ecrase
c              brutalement ; il doit etre cumule avec les operations
c              de ce programme
c   Remarque : utal02, utad02, utad06, utad08 et utad22 sont similaires
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : segments                             .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . option . e   .   1    . option de pilotage des destructions        .
c .        .     .        .  1 : la branche Famille complete           .
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : fami                                  .
c .        .     .        .  3 : cofa                                  .
c .        .     .        .  si negatif, on ramene a une longueur nulle.
c .        .     .        .  si positif, on supprime le tableau        .
c . nhenti . e   . char8  . nom de l'objet decrivant l'entite          .
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
      parameter ( nompro = 'UTAD08' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nhenti
c
      integer typenh
      integer option
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codava
      integer codre0
      integer tabcod(12)
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
     > '(''Suppressions des tableaux liees aux familles des '',a)'
      texte(1,8) = '(''Codes de retour'',20i3)'
c
      texte(2,4) =
     > '(''Destruction of the arrays for the families of the '',a)'
      texte(2,8) = '(''Error codes'',20i3)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,90002) 'option', option
      call dmflsh (iaux)
#endif
c
      do 10 , iaux = 1 , 3
        tabcod(iaux) = 0
   10 continue
c
      codava = codret
      codret = 0
c
c====
c 2. Destruction totale
c====
c
      if ( option.eq.1 ) then
c
        if ( codret.eq.0 ) then
c
        call gmsgoj ( nhenti//'.Famille' , codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 2
          tabcod(1) = codre0
        endif
c
      endif
c
c====
c 3. Destruction partielle
c====
c
      elseif ( option.gt.0 ) then
c
c 3.1. ==> Familles des entites
c
      if ( mod(option,2).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        if ( option.gt.0 ) then
c
          call gmlboj ( nhenti//'.Famille.EntiFamm' , codre0 )
c
        else
c
          call gmadoj ( nhenti//'.Famille.EntiFamm',
     >                  iaux, jaux, codre0 )
c
          if ( codre0.eq.0 ) then
          call gmmod ( nhenti//'.Famille.EntiFamm', iaux,
     >                 jaux, 0, 1, 1, codre0 )
          endif
c
        endif
c
        if ( codre0.ne.0 ) then
          codret = 2
          tabcod(1) = codre0
        endif
c
        endif
c
      endif
c
c 3.2. ==> Code des Familles
c
      if ( mod(option,3).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        if ( option.gt.0 ) then
c
          call gmlboj ( nhenti//'.Famille.Codes' , codre0 )
c
        else
c
          call gmadoj ( nhenti//'.Famille.Codes',
     >                  iaux, jaux, codre0 )
c
          if ( codre0.eq.0 ) then
          call gmmod ( nhenti//'.Famille.Codes', iaux,
     >                 jaux, 0, 1, 1, codre0 )
          endif
c
        endif
c
        if ( codre0.ne.0 ) then
          codret = 3
          tabcod(3) = codre0
        endif
c
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
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,90002) 'option' ,option
      write (ulsort,90003) 'structure', nhenti
      write (ulsort,texte(langue,8)) tabcod
      call gmprsx ( nompro, nhenti )
      call gmprsx ( nompro, nhenti//'.Famille' )
c
      else
c
      codret = codava
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
