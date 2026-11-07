      subroutine utad02 ( option, nhenti,
     >                    adhist, adcode, adfill, admere,
     >                    adfami, adcofa,  bidon,
     >                    adnivo, adinsu, adins2,
     >                    adnoim, adhomo, adcoar,
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
c    UTilitaire - ADresses - phase 02
c    --           --               --
c ______________________________________________________________________
c   Recuperation des adresses des tableaux pour une entite HOM_Enti
c   Remarque : le code de retour en entree ne doit pas etre ecrase
c              brutalement ; il doit etre cumule avec les operations
c              de ce programme
c   Remarque : utal02, utad02, utad06, utad08 et utad22 sont similaires
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . option de pilotage des adresses a recuperer.
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : historique, connectivite descendante  .
c .        .     .        .  3 : fille                                 .
c .        .     .        .  5 : mere                                  .
c .        .     .        .  7 : fami                                  .
c .        .     .        . 11 : nivo                                  .
c .        .     .        . 13 : isup                                  .
c .        .     .        . 17 : isup2                                 .
c .        .     .        . 19 : noeud interne a la maille             .
c .        .     .        . 29 : homologue                             .
c .        .     .        . 31 : connectivite par arete                .
c .        .     .        . 37 : cofa                                  .
c . nhenti . e   . char8  . nom de l'objet decrivant l'entite          .
c . adhist .   s  .  1    . historique de l'etat                       .
c . adcode .   s  .  1    . connectivite descendante                   .
c . adfill .   s  .  1    . fille des entites                          .
c . admere .   s  .  1    . mere des entites                           .
c . adfami .   s  .  1    . famille des entites                        .
c . adcofa .   s  .  1    . code des familles des entites              .
c . bidon  .   s  .  1    . en attente si evolution                    .
c . adnivo .   s  .  1    . niveau des entites                         .
c . adinsu.    s  .  1    . informations supplementaires               .
c . adins2.    s  .  1    . informations supplementaires numero 2      .
c . adnoim .   s  .  1    . noeud interne a la maille                  .
c . adhomo .   s  .  1    . homologue                                  .
c . adcoar .   s  .  1    . connectivite par arete                     .
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
      parameter ( nompro = 'UTAD02' )
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
      character*8 nhenti
c
      integer option
      integer adhist, adcode, adfill, admere
      integer adfami, adcofa, bidon
      integer adnivo
      integer adinsu
      integer adins2
      integer adnoim
      integer adhomo
      integer adcoar
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codava
      integer codre0
      integer codre1, codre2
      integer tabcod(12)
c
      integer nbmess
      parameter ( nbmess = 11 )
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
      texte(1,4) = '(''Adresses relatives aux entites'')'
      texte(1,8) = '(''Codes de retour'',20i3)'
c
      texte(2,4) = '(''Adresses for entities'')'
      texte(2,8) = '(''Error codes'',20i3)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,90002) 'option' ,option
      call dmflsh (iaux)
#endif
c
      do 10 , iaux = 1 , 12
        tabcod(iaux) = 0
   10 continue
c
      adcofa = iindef
      adhist = iindef
      adcode = iindef
      adfill = iindef
      admere = iindef
      adfami = iindef
      adcofa = iindef
      adnivo = iindef
      adinsu = iindef
      adins2 = iindef
      adnoim = iindef
      adhomo = iindef
      adcoar = iindef
      bidon = iindef
c
      codava = codret
      codret = 0
c
c====
c 2. recuperation des adresses
c====
c
      if ( option.gt.0 ) then
c
c 2.1. ==> Historique des etats et connectivite descendante
c
      if ( mod(option,2).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.HistEtat', adhist, iaux, codre1 )
        call gmadoj ( nhenti//'.ConnDesc', adcode, iaux, codre2 )
c
        if ( codre1.ne.0 ) then
          codret = 21
          tabcod(1) = codre1
        endif
        if ( codre2.ne.0 ) then
          codret = 22
          tabcod(2) = codre2
        endif
c
        endif
c
      endif
c
c 2.2. ==> Fille
c
      if ( mod(option,3).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.Fille', adfill, iaux, codre0 )
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
c 2.3. ==> Mere
c
      if ( mod(option,5).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.Mere', admere, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 5
          tabcod(4) = codre0
        endif
c
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
        call gmadoj ( nhenti//'.Famille.EntiFamm', adfami, iaux, codre0)
c
        if ( codre0.ne.0 ) then
          codret = 7
          tabcod(5) = codre0
        endif
c
        endif
c
      endif
c
      if ( mod(option,37).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.Famille.Codes'   , adcofa, iaux, codre0)
c
        if ( codre0.ne.0 ) then
          codret = 37
          tabcod(6) = codre0
        endif
c
        endif
c
      endif
c
c 2.5. ==> Le niveau
c
      if ( mod(option,11).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.Niveau', adnivo, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 11
          tabcod(7) = codre0
        endif
c
        endif
c
      endif
c
c 2.6. ==> Les informations supplementaires
c
      if ( mod(option,13).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.InfoSupp', adinsu, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 13
          tabcod(8) = codre0
        endif
c
        endif
c
      endif
c
c 2.7. ==> Les informations supplementaires numero 2
c
      if ( mod(option,17).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.InfoSup2', adins2, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 17
          tabcod(9) = codre0
        endif
c
        endif
c
      endif
c
c 2.8. ==> Le noeud supplementaire
c
      if ( mod(option,19).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.NoeuInMa', adnoim, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 19
          tabcod(10) = codre0
        endif
c
        endif
c
      endif
c
c 2.9. ==> Les homologues
c
      if ( mod(option,29).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.Homologu', adhomo, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 29
          tabcod(11) = codre0
        endif
c
        endif
c
      endif
c
c 2.10. ==> La connectivite par aretes
c
      if ( mod(option,31).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenti//'.ConnAret', adcoar, iaux, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 31
          tabcod(12) = codre0
        endif
c
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
