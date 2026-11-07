      subroutine utindh ( typpro, ulsort, langue, codret )
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
c   UTilitaire : INitialisation des Donnees de HOMARD
c   --           --                 -          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typpro . e   .    1   . type de programme                          .
c .        .     .        . 1 : homard complet                         .
c .        .     .        . 2 : interface avant adaptation             .
c .        .     .        . 3 : adaptation                             .
c .        .     .        . 4 : suivi de frontiere                     .
c .        .     .        . 5 : interface apres adaptation             .
c .        .     .        . 6 : information                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : impossible d'allouer la tete           .
c .        .     .        . 4 : impossible d'allouer les objets simples.
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
      parameter ( nompro = 'UTINDH' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "cndoad.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer typpro
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2
      integer codre0
      integer adress
c
      character*200 nomobj
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
c 1.1. ==> tout va bien
c
      codret = 0
c
c 1.2. ==> les messages,
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) =
     > '(''Impossible d''''allouer la tete de type DonnHOMA.'')'
      texte(1,4) = '(''Impossible d''''allouer l''''objet :'')'
c
      texte(2,10) =
     > '(''Head object of type DonnHOMA cannot be allocated.'')'
      texte(2,4) = '(''This object cannot be allocated :'')'
c
c====
c 2. Les options
c====
c
c 2.1. ==> allocation de l'objet de tete
c
      call gmalot ( nndoad, 'DonnHOMA', 0, iaux, codre0 )
c
      if ( codre0.ne.0 ) then
        codret = 2
      endif
c
c 2.2. ==> allocation des options entieres
c
      if ( codret.eq.0 ) then
c
        nomobj = nndoad//'.OptEnt'
        iaux = 50
        call gmecat ( nndoad, 1, iaux, codre1 )
        call gmaloj ( nomobj, ' ', iaux, adress, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        if ( codret.ne.0 ) then
          codret = 4
        else
          imem(adress) = langue
        endif
c
      endif
c
c 2.3. ==> allocation des options reelles
c
      if ( codret.eq.0 ) then
c
        nomobj = nndoad//'.OptRee'
        iaux = 20
        call gmecat ( nndoad, 2, iaux, codre1 )
        call gmaloj ( nomobj, ' ', iaux, adress, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        if ( codret.ne.0 ) then
          codret = 4
        endif
c
      endif
c
c 2.4. ==> allocation des options caracteres
c
      if ( codret.eq.0 ) then
c
        nomobj = nndoad//'.OptCar'
        iaux = 40
        call gmecat ( nndoad, 3, iaux, codre1 )
        call gmaloj ( nomobj, ' ', iaux, adress, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        if ( codret.ne.0 ) then
          codret = 4
        endif
c
      endif
c
c 2.5. ==> allocation de l'etat courant
c
      if ( codret.eq.0 ) then
c
        nomobj = nndoad//'.EtatCour'
        iaux = 10
        call gmecat ( nndoad, 4, iaux, codre1 )
        call gmaloj ( nomobj, ' ', iaux, adress, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        if ( codret.ne.0 ) then
          codret = 4
        else
          imem(adress) = 1
          imem(adress+1) = 1
          imem(adress+2) = 10
          imem(adress+3) = 10
        endif
c
      endif
c
c 2.6. ==> le type de programme
c
      if ( codret.eq.0 ) then
c
        call gmecat ( nndoad, 5, typpro, codret )
c
        if ( codret.ne.0 ) then
          codret = 4
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nndoad )
      call gmprsx (nompro, nndoad//'.OptEnt' )
      call gmprsx (nompro, nndoad//'.OptRee' )
      call gmprsx (nompro, nndoad//'.OptCar' )
      call gmprsx (nompro, nndoad//'.EtatCour' )
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
        if ( codret.eq.2 ) then
          write (ulsort,texte(langue,10))
        else
          write (ulsort,texte(langue,4))
          write (ulsort,*) nomobj
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
