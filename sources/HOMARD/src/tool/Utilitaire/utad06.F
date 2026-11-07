      subroutine utad06 ( typenh, option, optio2, nhenti,
     >                    nbeold, nbenew, nbaold, nbanew,
     >                    adhist, adcode, adfill, admere,
     >                    adfami,
     >                    adnivo, adinsu, adins2,
     >                    adnoim, adanci, adhomo, adcoar,
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
c    UTilitaire - ADresses - phase 06
c    --           --               --
c ______________________________________________________________________
c   Modification des longueurs des tableaux pour une entite HOM_Enti
c   et recuperation de leurs adresses
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
c .        .     .        . 23 : Deraffin                              .
c .        .     .        . 29 : homologue                             .
c .        .     .        . 31 : connectivite par arete                .
c . optio2 . e   .   1    . 0 : on detruit les objets de taille nulle  .
c .        .     .        . 1 : on garde les objets de taille nulle    .
c . nhenti . e   . char8  . nom de l'objet decrivant l'entite          .
c . nbeold . e   .   1    . nombre d'entites ancien                    .
c . nbenew . e   .   1    . nombre d'entites nouveau                   .
c . nbaold . e   .   1    . nombre d'entites decrites par arete ancien .
c . nbanew . e   .   1    . nombre d'entites decrites par arete nouveau.
c . adhist .  s  .  1    . historique de l'etat                        .
c . adcode .  s  .  1    . connectivite descendante                    .
c . adfill .  s  .  1    . fille des entites                           .
c . admere .  s  .  1    . mere des entites                            .
c . adfami .  s  .  1    . famille des entites                         .
c . adnivo .  s  .  1    . niveau des entites                          .
c . adinsu .  s  .  1    . informations supplementaires                .
c . adins2 .  s  .  1    . informations supplementaires numero 2       .
c . adnoim .  s  .  1    . noeud interne a la maille                   .
c . adanci .  s  .  1    . memorisation du deraffinement               .
c . adhomo .  s  .  1     . homologue                                  .
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
      parameter ( nompro = 'UTAD06' )
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
      integer option, optio2
      integer nbeold, nbenew, nbaold, nbanew
      integer adhist, adcode, adfill, admere
      integer adfami
      integer adnivo
      integer adinsu
      integer adins2
      integer adnoim
      integer adanci
      integer adhomo
      integer adcoar
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer un
      parameter ( un = 1 )
c
      integer iaux, jaux, kaux, laux
      integer dimaux
      integer codava
      integer codre0
      integer codre1, codre2
      integer tabcod(0:13)
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
      texte(1,4) = '(''Reallocations pour les '',a)'
      texte(1,6) = '(''On detruit les objets de taille nulle.'')'
      texte(1,7) = '(''On garde les objets de taille nulle.'')'
      texte(1,8) = '(''Codes de retour'',20i3)'
      texte(1,9) =  '(''Ancien nombre d''''entites   : '',i10)'
      texte(1,10) = '(''Nouveau nombre d''''entites  : '',i10)'
c
      texte(2,4) = '(''Reallocation for the '',a)'
      texte(2,6) = '(''Null size objects are destroyed.'')'
      texte(2,7) = '(''Null size objetcs are kept.'')'
      texte(2,8) = '(''Error codes'',20i3)'
      texte(2,9) =  '(''Old number of entities : '',i10)'
      texte(2,10) = '(''New number of entities : '',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,90002) 'option', option
      write (ulsort,texte(langue,6+optio2))
      write (ulsort,texte(langue,9)) nbeold
      write (ulsort,texte(langue,10)) nbenew
cgn      call gmprsx ( nompro, nhenti )
      call dmflsh (iaux)
#endif
c
      do 10 , iaux = 0 , 13
        tabcod(iaux) = 0
   10 continue
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
        if ( optio2.eq.0 .and. nbenew.eq.0 ) then
c
          call gmlboj ( nhenti//'.HistEtat' , codre1 )
          call gmlboj ( nhenti//'.ConnDesc' , codre2 )
c
        else
c
          call gmmod ( nhenti//'.HistEtat',
     >                 adhist, nbeold, nbenew, un, un, codre1 )
c
          if ( typenh.eq.0 ) then
            dimaux = 1
          elseif ( typenh.eq.1 ) then
            dimaux = -2
          elseif ( typenh.eq.2 ) then
            dimaux = 3
          elseif ( typenh.eq.3 ) then
            dimaux = 4
          elseif ( typenh.eq.4 ) then
            dimaux = 4
          elseif ( typenh.eq.5 ) then
            dimaux = 5
          elseif ( typenh.eq.6 ) then
            dimaux = 6
          elseif ( typenh.eq.7 ) then
            dimaux = 5
          else
            codret = 120
            tabcod(2) = 1
          endif
c
          if ( codret.eq.0 ) then
c
          if ( dimaux.lt.0 ) then
            iaux = -dimaux
            jaux = -dimaux
            kaux = nbeold
            laux = nbenew
          else
            iaux = (nbeold-nbaold)
            jaux = (nbenew-nbanew)
            kaux = dimaux
            laux = dimaux
          endif
          call gmmod ( nhenti//'.ConnDesc',
     >                 adcode, iaux, jaux, kaux, laux, codre2 )
c
          endif
c
        endif
c
        if ( codre1.ne.0 ) then
          codret = 11
          tabcod(1) = 1
        endif
c
        if ( codre2.ne.0 ) then
          codret = 12
          tabcod(2) = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 2
      write (ulsort,texte(langue,8)) codre1, codre2
#endif
c
      endif
c
c 2.2. ==> Fille
c
      if ( mod(option,3).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        if ( optio2.eq.0 .and. nbenew.eq.0 ) then
c
          call gmlboj ( nhenti//'.Fille' , codre0 )
c
        else
c
          call gmmod ( nhenti//'.Fille',
     >                 adfill, nbeold, nbenew, un, un, codre0 )
c
        endif
c
        if ( codre0.ne.0 ) then
          codret = 2
          tabcod(3) = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 3
      write (ulsort,texte(langue,8)) codre0
#endif
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
        if ( optio2.eq.0 .and. nbenew.eq.0 ) then
c
          call gmlboj ( nhenti//'.Mere' , codre0 )
c
        else
c
          call gmmod ( nhenti//'.Mere',
     >                 admere, nbeold, nbenew, un, un, codre0 )
c
        endif
c
        if ( codre0.ne.0 ) then
          codret = 3
          tabcod(4) = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 5
      write (ulsort,texte(langue,8)) codre0
#endif
c
        endif
c
      endif
c
c 2.4. ==> Les familles
c          Attention : ne jamais tuer EntiFamm si taille nulle
c
      if ( mod(option,7).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmmod ( nhenti//'.Famille.EntiFamm',
     >               adfami, nbeold, nbenew, un, un, codre0 )
c
        if ( codre0.ne.0 ) then
          codret = 4
          tabcod(5) = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 7
      write (ulsort,texte(langue,8)) codre0
#endif
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
        if ( optio2.eq.0 .and. nbenew.eq.0 ) then
c
          call gmlboj ( nhenti//'.Niveau' , codre0 )
c
        else
c
          call gmmod ( nhenti//'.Niveau',
     >                 adnivo, nbeold, nbenew, un, un, codre0 )
c
        endif
c
        if ( codre0.ne.0 ) then
          codret = 5
          tabcod(7) = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 11
      write (ulsort,texte(langue,8)) codre0
#endif
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
        if ( optio2.eq.0 .and. nbenew.eq.0 ) then
c
          call gmlboj ( nhenti//'.InfoSupp' , codre0 )
c
        else
c
          if ( typenh.eq.0 ) then
            dimaux = 1
          elseif ( typenh.eq.1 ) then
            dimaux = 1
          elseif ( typenh.eq.2 ) then
            dimaux = 1
          elseif ( typenh.eq.3 ) then
            dimaux = 4
          elseif ( typenh.eq.4 ) then
            dimaux = 1
          elseif ( typenh.eq.5 ) then
            dimaux = 5
          elseif ( typenh.eq.6 ) then
            dimaux = 6
          elseif ( typenh.eq.7 ) then
            dimaux = 5
          else
            codret = 6
            tabcod(8) = 1
          endif
          iaux = (nbeold-nbaold)
          jaux = (nbenew-nbanew)
          kaux = dimaux
          laux = dimaux
          call gmmod ( nhenti//'.InfoSupp',
     >                 adinsu, iaux, jaux, kaux, laux, codre0 )
c
        endif
c
        if ( codre0.ne.0 ) then
          codret = 6
          tabcod(8) = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 13
      write (ulsort,texte(langue,8)) codre0
#endif
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
        if ( optio2.eq.0 .and. nbenew.eq.0 ) then
c
          call gmlboj ( nhenti//'.InfoSup2' , codre0 )
c
        else
c
          call gmmod ( nhenti//'.InfoSup2',
     >                 adins2, nbeold, nbenew, un, un, codre0 )
c
        endif
c
        if ( codre0.ne.0 ) then
          codret = 7
          tabcod(9) = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 17
      write (ulsort,texte(langue,8)) codre0
#endif
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
        if ( optio2.eq.0 .and. nbenew.eq.0 ) then
c
          call gmlboj ( nhenti//'.NoeuInMa' , codre0 )
c
        else
c
          call gmmod ( nhenti//'.NoeuInMa',
     >                 adnoim, nbeold, nbenew, un, un, codre0 )
c
        endif
c
        if ( codre0.ne.0 ) then
          codret = 8
          tabcod(10) = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 19
      write (ulsort,texte(langue,8)) codre0
#endif
c
        endif
c
      endif
c
c 2.9. ==> La memorisation du deraffinement
c
      if ( mod(option,23).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmobal ( nhenti//'.Deraffin', codre0 )
c
        if ( codre0.eq.2 ) then
c
          if ( optio2.eq.0 .and. nbenew.eq.0 ) then
c
            call gmlboj ( nhenti//'.Deraffin' , codre0 )
c
          else
c
            call gmmod ( nhenti//'.Deraffin',
     >                   adanci, nbeold, nbenew, un, un, codre0 )
c
          endif
c
          if ( codre0.ne.0 ) then
            codret = 9
            tabcod(11) = 1
          endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 23
      write (ulsort,texte(langue,8)) codre0
#endif
c
        endif
c
        endif
c
      endif
c
c 2.10. ==> Les homologues
c
      if ( mod(option,29).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        if ( optio2.eq.0 .and. nbenew.eq.0 ) then
c
          call gmlboj ( nhenti//'.Homologu' , codre0 )
c
        else
c
          call gmmod ( nhenti//'.Homologu',
     >                 adhomo, nbeold, nbenew, un, un, codre0 )
c
        endif
c
        if ( codre0.ne.0 ) then
          codret = 10
          tabcod(12) = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 29
      write (ulsort,texte(langue,8)) codre0
#endif
c
        endif
c
      endif
c
c 2.11. ==> Connectivites par aretes
c
      if ( mod(option,31).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        if ( optio2.eq.0 .and. nbanew.eq.0 ) then
c
          call gmlboj ( nhenti//'.ConnAret' , codre0 )
c
        else
c
          call gmmod ( nhenti//'.ConnAret',
     >                 adcoar, nbaold, nbanew, un, un, codre0 )
c
        endif
c
        if ( codre0.ne.0 ) then
          codret = 11
          tabcod(13) = 1
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'traitement', 31
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
c 3. Attributs
c====
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nhenti, 1, nbenew, codre1 )
      call gmecat ( nhenti, 2, nbanew, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      if ( codret.ne.0 ) then
        codret = 30
        tabcod(0) = 1
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
      write (ulsort,texte(langue,8)) tabcod
      write (ulsort,texte(langue,9)) nbeold
      write (ulsort,texte(langue,10)) nbenew
      call gmprsx(nompro,nhenti)
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
