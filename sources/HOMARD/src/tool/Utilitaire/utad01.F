      subroutine utad01 ( option, nhnoeu,
     >                    adhist,
     >                    adfami, adcofa,  bidon,
     >                    adcoor, adarno, adhono, adcocs,
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
c    UTilitaire - ADresses - phase 01
c    --           --               --
c ______________________________________________________________________
c   Recuperation des adresses des tableaux pour les noeuds HOM_Noeu
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
c .        .     .        .  7 : fami, cofa                            .
c .        .     .        . 11 : noho                                  .
c .        .     .        . 19 : constantes des coordonnees            .
c . nhnoeu . e   . char8  . nom de l'objet decrivant l'entite          .
c . adhist .   s  .  1    . historique de l'etat                       .
c . adfami .   s  .  1    . famille des noeuds                         .
c . adcofa .   s  .  1    . codes des familles des noeuds              .
c . bidon  .   s  .  1    . en attente si evolution                    .
c . adcoor .   s  .  1    . coordonnees                                .
c . adarno .   s  .  1    . arete supportant le noeud                  .
c . adhono .   s  .  1    . homologue du noeud                         .
c . adcocs .  s  .   1    . constantes des coordonnees                 .
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
      parameter ( nompro = 'UTAD01' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "indefi.h"
c
c 0.3. ==> arguments
c
      character*8 nhnoeu
c
      integer option
      integer adhist
      integer adfami, adcofa, bidon
      integer adcoor, adarno, adhono, adcocs
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
      integer codre1, codre2
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
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Adresses relatives aux noeuds'')'
      texte(1,5) = '(''Option :'',i10)'
      texte(1,8) = '(''Codes de retour'',20i3)'
c
      texte(2,4) = '(''Adresses for nodes'')'
      texte(2,5) = '(''Option :'',i10)'
      texte(2,8) = '(''Error codes'',20i3)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) option
      call dmflsh (iaux)
#endif
c
      do 10 , iaux = 1 , 7
        tabcod(iaux) = 0
   10 continue
c
      bidon = iindef
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
        call gmadoj ( nhnoeu//'.HistEtat', adhist, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 1
          tabcod(1) = codre0
        endif
c
      endif
c
c 2.2. ==> Les coordonnees
c
      if ( mod(option,3).eq.0 ) then
c
        call gmadoj ( nhnoeu//'.Coor', adcoor, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 2
          tabcod(2) = codre0
        endif
c
      endif
c
c 2.3. ==> L'arete supportant le noeud
c
      if ( mod(option,5).eq.0 ) then
c
        call gmadoj ( nhnoeu//'.AretSupp', adarno, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 3
          tabcod(3) = codre0
        endif
c
      endif
c
c 2.4. ==> Les familles
c
      if ( mod(option,7).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhnoeu//'.Famille.EntiFamm', adfami, iaux, codre1)
        call gmadoj ( nhnoeu//'.Famille.Codes'   , adcofa, iaux, codre2)
c
        if ( codre1.ne.0 ) then
          codret = 41
          tabcod(4) = codre1
        endif
        if ( codre2.ne.0 ) then
          codret = 42
          tabcod(5) = codre2
        endif
c
        endif
c
      endif
c
c 2.5. ==> L'homologue du noeud
c
      if ( mod(option,11).eq.0 ) then
c
        call gmadoj ( nhnoeu//'.Homologu', adhono, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 5
          tabcod(6) = codre0
        endif
c
      endif
c
c 2.6. ==> Constantes liees aux coordonnees
c
      if ( mod(option,19).eq.0 ) then
c
        call gmadoj ( nhnoeu//'.CoorCons', adcocs, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 6
          tabcod(7) = codre0
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
      call gmprsx ( nompro, nhnoeu )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
