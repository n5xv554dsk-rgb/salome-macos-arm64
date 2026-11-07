      subroutine utal02 ( typenh, option,
     >                    nhenti, nbento, nbenca,
     >                    adhist, adcode, adfill, admere,
     >                    adfami, adcofa,
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
c    UTilitaire - ALlocations - phase 02
c    --           --                  --
c ______________________________________________________________________
c   Allocations des tableaux pour une entite HOM_Enti
c   Remarque : le code de retour en entree ne doit pas etre ecrase
c              brutalement ; il doit etre cumule avec les operations
c              de ce programme
c   Remarque : utal02, utad02, utad06, utad08 et utad22 sont similaires
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : segments                             .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . option . e   .   1    . option de pilotage des allocations a faire .
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
c . nhenti . e   . char8  . nom de l'objet decrivant l'entite          .
c . nbento . e   .    1   . nombre d'entites                           .
c . nbenca . e   .    1   . nombre d'entites en connectivite par arete .
c . adhist .  s  .  1     . historique de l'etat                       .
c . adcode .  s  .  1     . connectivite descendante                   .
c . adfill .  s  .  1     . fille des entites                          .
c . admere .  s  .  1     . mere des entites                           .
c . adfami .  s  .  1     . famille des entites                        .
c . adcofa .  s  .  1     . code des familles des entites              .
c . adnivo .  s  .  1     . niveau des entites                         .
c . adinsu .  s  .  1     . informations supplementaires               .
c . adins2 .  s  .  1     . informations supplementaires numero 2      .
c . adnoim .  s  .  1     . noeud interne a la maille                  .
c . adhomo .  s  .  1     . homologue                                  .
c . adcoar .  s   .  1    . connectivite par arete                     .
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
      parameter ( nompro = 'UTAL02' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
#include "indefi.h"
c
c 0.3. ==> arguments
c
      character*8 nhenti
c
      integer typenh, option
      integer nbento, nbenca
      integer adhist, adcode, adfill, admere
      integer adfami, adcofa
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
      integer iaux, jaux
      integer codava
      integer codre0
      integer codre1, codre2
      integer tabcod(0:12)
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
      texte(1,4) = '(''Allocations pour les '',a)'
      texte(1,6) = '(''Structure : '',a)'
      texte(1,8) = '(''Codes de retour'',20i3)'
c
      texte(2,4) = '(''Allocations for '',a)'
      texte(2,6) = '(''Structure: '',a)'
      texte(2,8) = '(''Error codes'',20i3)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,90002) 'option', option
      write (ulsort,90002) 'nbento', nbento
      write (ulsort,90002) 'nbenca', nbenca
cgn      call gmprsx(nompro,nhenti)
cgn      call gmprsx(nompro,nhenti//'.Famille')
      call dmflsh (iaux)
#endif
c
      do 10 , iaux = 0 , 12
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
c
      codava = codret
      codret = 0
c
c====
c 2. Allocation et recuperation des adresses
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
        call gmaloj ( nhenti//'.HistEtat', ' ', nbento, adhist, codre1 )
        if ( codre1.ne.0 ) then
          codret = 11
          tabcod(1) = codre1
        endif
c
        if ( typenh.eq.0 ) then
          jaux = 1
        elseif ( typenh.eq.1 ) then
          jaux = 2
        elseif ( typenh.eq.2 ) then
          jaux = 3
        elseif ( typenh.eq.3 ) then
          jaux = 4
        elseif ( typenh.eq.4 ) then
          jaux = 4
        elseif ( typenh.eq.5 ) then
          jaux = 5
        elseif ( typenh.eq.6 ) then
          jaux = 6
        elseif ( typenh.eq.7 ) then
          jaux = 5
        else
          codret = 120
          tabcod(2) = 1
        endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = (nbento-nbenca)*jaux
        call gmaloj ( nhenti//'.ConnDesc', ' ', iaux, adcode, codre2 )
c
        if ( codre2.ne.0 ) then
          codret = 12
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
        call gmaloj ( nhenti//'.Fille', ' ', nbento, adfill, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 2
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
        call gmaloj ( nhenti//'.Mere', ' ', nbento, admere, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 3
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
        call gmaloj ( nhenti//'.Famille.EntiFamm', ' ',
     >                nbento, adfami, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 4
          tabcod(5) = codre0
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
        call gmaloj ( nhenti//'.Niveau', ' ', nbento, adnivo, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 5
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
        if ( typenh.eq.3 ) then
          iaux = (nbento-nbenca)*4
        elseif ( typenh.eq.5 ) then
          iaux = (nbento-nbenca)*5
        elseif ( typenh.eq.6 ) then
          iaux = (nbento-nbenca)*6
        elseif ( typenh.eq.7 ) then
          iaux = (nbento-nbenca)*5
        else
          iaux = nbento
        endif
        call gmaloj ( nhenti//'.InfoSupp', ' ', iaux, adinsu, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 6
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
        call gmaloj ( nhenti//'.InfoSup2', ' ', nbento, adins2, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 7
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
        call gmaloj ( nhenti//'.NoeuInMa', ' ', nbento, adnoim, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 8
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
        call gmaloj ( nhenti//'.Homologu', ' ', nbento, adhomo, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 9
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
        if ( typenh.eq.3 ) then
          iaux = nbenca*6
        elseif ( typenh.eq.5 ) then
          iaux = nbenca*8
        elseif ( typenh.eq.6 ) then
          iaux = nbenca*12
        elseif ( typenh.eq.7 ) then
          iaux = nbenca*9
        else
          iaux = 0
        endif
        call gmaloj ( nhenti//'.ConnAret', ' ', iaux, adcoar, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 10
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
c 3. Attributs
c====
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nhenti, 1, nbento, codre1 )
      call gmecat ( nhenti, 2, nbenca, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      if ( codret.ne.0 ) then
        tabcod(0) = codret
        codret = 30
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
      write (ulsort,90002) 'option', option
      write (ulsort,texte(langue,6)) nhenti
      write (ulsort,texte(langue,8)) tabcod
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
