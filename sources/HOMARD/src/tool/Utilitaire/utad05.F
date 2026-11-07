      subroutine utad05 ( option, optio2, nhnoeu,
     >                    nbeold, nbenew, sdim,
     >                    adhist,
     >                    adfami,
     >                    adcoor, adarno, adhono, adanci,
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
c    UTilitaire - ADresses - phase 05
c    --           --               --
c ______________________________________________________________________
c   Modification des longueurs des tableaux pour une entite HOM_Noeu
c   et recuperation de leurs adresses
c   Remarque : le code de retour en entree ne doit pas etre ecrase
c              brutalement ; il doit etre cumule avec les operations
c              de ce programme
c   Remarque : utad01 et utad05 sont similaires
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . option de pilotage des adresses a recuperer.
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : historique                            .
c .        .     .        .  3 : coordonnees                           .
c .        .     .        .  5 : arete support du noeud                .
c .        .     .        .  7 : fami                  .
c .        .     .        . 11 : noho                                  .
c .        .     .        . 13 : dera                                  .
c . optio2 . e   .   1    . 0 : on detruit les objets de taille nulle  .
c .        .     .        . 1 : on garde les objets de taille nulle    .
c . nhnoeu . e   . char8  . nom de l'objet decrivant l'entite          .
c . nbeold . e   .   1    . nombre d'entites ancien                    .
c . nbenew . e   .   1    . nombre d'entites nouveau                   .
c . sdim   . e   .   1    . dimension                                  .
c . adhist .  s  .  1    . historique de l'etat                        .
c . adfami .  s  .  1    . famille des noeuds                          .
c . adcoor .  s  .  1    . coordonnees                                 .
c . adarno .  s  .  1    . arete supportant le noeud                   .
c . adhono .  s  .  1    . homologue du noeud                          .
c . adanci .  s  .  1    . deraffinement                               .
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
      parameter ( nompro = 'UTAD05' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nhnoeu
c
      integer option, optio2
      integer nbeold, nbenew, sdim
      integer adhist
      integer adfami
      integer adcoor, adarno, adhono, adanci
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer un
      parameter ( un = 1 )
c
      integer iaux
      integer codre0
      integer tabcod(7)
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
      texte(1,4) = '(''Adresses relatives aux noeuds'')'
      texte(1,8) = '(''Codes de retour'',20i3)'
      texte(1,9) =  '(''Ancien nombre de noeuds  : '',i10)'
      texte(1,10) = '(''Nouveau nombre de noeuds : '',i10)'
c
      texte(2,4) = '(''Adresses for nodes'')'
      texte(2,8) = '(''Error codes'',20i3)'
      texte(2,9) = '(''Old number of nodes : '',i10)'
      texte(2,10) = '(''New number of nodes : '',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,90002) 'option' ,option
      write (ulsort,texte(langue,9)) nbeold
      write (ulsort,texte(langue,10)) nbenew
      call gmprsx ( nompro, nhnoeu )
      call dmflsh (iaux)
#endif
c
      do 10 , iaux = 1 , 7
        tabcod(iaux) = 0
   10 continue
c
c====
c 2. recuperation des adresses
c====
c
      if ( option.gt.0 ) then
c
c 2.1. ==> Historique des etats
c
      if ( mod(option,2).eq.0 ) then
c
cgn        call gmprsx ( nompro, nhnoeu//'.HistEtat' )
        call gmmod ( nhnoeu//'.HistEtat',
     >               adhist, nbeold, nbenew, un, un, codre0 )
c
        if ( codre0.ne.0 ) then
          tabcod(1) = 1
          codret = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Choix',  2
      write (ulsort,texte(langue,8)) codre0
#endif
c
      endif
c
c 2.2. ==> Les coordonnees
c
      if ( mod(option,3).eq.0 ) then
c
        call gmmod ( nhnoeu//'.Coor',
     >               adcoor, nbeold, nbenew, sdim, sdim, codre0 )
c
        if ( codre0.ne.0 ) then
          tabcod(2) = 2
          codret = 2
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Choix',  3
      write (ulsort,texte(langue,8)) codre0
#endif
c
      endif
c
c 2.3. ==> L'arete supportant le noeud
c
      if ( mod(option,5).eq.0 ) then
c
        call gmmod ( nhnoeu//'.AretSupp',
     >               adarno, nbeold, nbenew, un, un, codre0 )
c
        if ( codre0.ne.0 ) then
          tabcod(3) = 3
          codret = 3
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Choix',  5
      write (ulsort,texte(langue,8)) codre0
#endif
c
      endif
c
c 2.4. ==> Les familles
c
      if ( mod(option,7).eq.0 ) then
c
        call gmmod ( nhnoeu//'.Famille.EntiFamm',
     >               adfami, nbeold, nbenew, un, un, codre0 )
c
        if ( codre0.ne.0 ) then
          tabcod(4) = 4
          codret = 4
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Choix',  7
      write (ulsort,texte(langue,8)) codre0
#endif
c
      endif
c
c 2.5. ==> L'homologue du noeud
c
      if ( mod(option,11).eq.0 ) then
c
        call gmmod ( nhnoeu//'.Homologu',
     >                 adhono, nbeold, nbenew, un, un, codre0 )
c
        if ( codre0.ne.0 ) then
          tabcod(5) = 5
          codret = 5
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Choix',  11
      write (ulsort,texte(langue,8)) codre0
#endif
c
      endif
c
c 2.6. ==> La memorisation du deraffinement
c
      if ( mod(option,13).eq.0 ) then
c
        call gmobal ( nhnoeu//'.Deraffin', codre0 )
c
        if ( codre0.eq.2 ) then
c
          if ( optio2.eq.0 .and. nbenew.eq.0 ) then
c
            call gmlboj ( nhnoeu//'.Deraffin' , codre0 )
c
          else
c
            call gmmod ( nhnoeu//'.Deraffin',
     >                   adanci, nbeold, nbenew, un, un, codre0 )
c
          endif
c
          if ( codre0.ne.0 ) then
            codret = 13
            tabcod(6) = 13
          endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Choix',  13
      write (ulsort,texte(langue,8)) codre0
#endif
c
        endif
c
      endif
c
      endif
c
c====
c 3. Attribut
c====
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nhnoeu, 1, nbenew, codre0 )
c
      if ( codre0.ne.0 ) then
        codret = 30
        tabcod(7) = 1
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
      write (ulsort,texte(langue,8)) tabcod
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
