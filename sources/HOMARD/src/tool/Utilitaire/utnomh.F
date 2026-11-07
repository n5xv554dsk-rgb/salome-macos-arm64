      subroutine utnomh ( nomail,
     >                      sdim,   mdim,
     >                     degre, maconf, homolo, hierar,
     >                    rafdef, nbmane, typcca, typsfr, maextr,
     >                    mailet,
     >                    norenu,
     >                    nhnoeu, nhmapo, nharet,
     >                    nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    nhelig,
     >                    nhvois, nhsupe, nhsups,
     >                    ulsort, langue, codret)
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
c    UTilitaire - Nom des Objets du Maillage HOMARD
c    --           -       -         -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard             .
c . sdim   .  s  .    1   . dimension de l'espace                      .
c . mdim   .  s  .    1   . dimension du maillage                      .
c . degre  .  s  .    1   . degre du maillage                          .
c . maconf .  s  .    1   . conformite du maillage                     .
c .        .     .        .  0 : oui                                   .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2 par face           .
c .        .     .        .  2 : non-conforme avec 1 seul noeud pendant.
c .        .     .        .      par arete                             .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 et des boites pour les  .
c .        .     .        .       quadrangles, hexaedres et pentaedres .
c .        .     .        . 10 : non-conforme sans autre connaissance  .
c . homolo .  s  .    1   . type de relations par homologues           .
c .        .     .        . 0 : pas d'homologues                       .
c .        .     .        . 1 : relations sur les noeuds               .
c .        .     .        . 2 : relations sur les noeuds et les aretes .
c .        .     .        . 3 : relations sur les noeuds, les aretes   .
c .        .     .        .     et les triangles                       .
c . hierar .  s  .    1   . maillage hierarchique                      .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : oui                                    .
c . rafdef .  s  .    1   . 0 : macro-maillage                         .
c .        .     .        . 1 : le maillage est inchange               .
c .        .     .        . 2 : le maillage est issu du raffinement pur.
c .        .     .        .     d'un autre maillage                    .
c .        .     .        . 3 : le maillage est issu du deraffinement  .
c .        .     .        .     pur d'un autre maillage                .
c .        .     .        . 4 : le maillage est issu de raffinement et .
c .        .     .        .     de deraffinement d'un autre maillage   .
c .        .     .        . 12 : le maillage est un maillage passe de  .
c .        .     .        .      degre 1 a 2                           .
c .        .     .        . 21 : le maillage est un maillage passe de  .
c .        .     .        .      degre 2 a 1                           .
c . nbmane .  s  .    1   . nombre maximum de noeuds par element       .
c . typcca .  s  .   1    . type du code de calcul                     .
c . typsfr .  s  .   1    . type du suivi de frontiere                 .
c .        .     .        . 0 : aucun                                  .
c .        .     .        . 1 : maillage de degre 1, avec projection   .
c .        .     .        .     des nouveaux sommets                   .
c .        .     .        . 2 : maillage de degre 2, seuls les noeuds  .
c .        .     .        .     P1 sont sur la frontiere ; les noeuds  .
c .        .     .        .     P2 restent au milieu des P1            .
c .        .     .        . 3 : maillage de degre 2, les noeuds P2     .
c .        .     .        .     etant sur la frontiere                 .
c . maextr .  s  .   1    . maillage extrude                           .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : selon X                                .
c .        .     .        . 2 : selon Y                                .
c .        .     .        . 3 : selon Z (cas de Saturne ou Neptune)    .
c . mailet .  s  .    1   . presence de mailles etendues               .
c .        .     .        .  1 : aucune                                .
c .        .     .        . 2x : TRIA7                                 .
c .        .     .        . 3x : QUAD9                                 .
c .        .     .        . 5x : HEXA27                                .
c . norenu .  s  . char8  . nom de la branche RenuMail                 .
c . nhnoeu .  s  . char8  . nom de l'objet decrivant les noeuds        .
c . nhmapo .  s  . char8  . nom de l'objet decrivant les mailles-points.
c . nharet .  s  . char8  . nom de l'objet decrivant les aretes        .
c . nhtria .  s  . char8  . nom de l'objet decrivant les triangles     .
c . nhquad .  s  . char8  . nom de l'objet decrivant les quadrangles   .
c . nhtetr .  s  . char8  . nom de l'objet decrivant les tetraedres    .
c . nhhexa .  s  . char8  . nom de l'objet decrivant les hexaedres     .
c . nhpyra .  s  . char8  . nom de l'objet decrivant les pyramides     .
c . nhpent .  s  . char8  . nom de l'objet decrivant les pentaedres    .
c . nhelig .  s  . char8  . nom de l'objet decrivant les ignores       .
c . nhvois .   s . char8  . nom de la branche Voisins                  .
c . nhsupe .  s  . char8  . informations supplementaires entieres      .
c . nhsups .  s  . char8  . informations supplementaires caracteres 8  .
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
      parameter ( nompro = 'UTNOMH' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
c
      integer   sdim,   mdim
      integer  degre, maconf, homolo, hierar
      integer rafdef, nbmane, typcca, typsfr, maextr
      integer mailet
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      character*4 saux02(3,2)
      character*8 saux08
      character*80 saux80
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
      texte(1,4) = '(''Noms des objets du maillage : '',a)'
      texte(1,5) = '(''.. L''''objet n''''est pas alloue.'')'
      texte(1,6) = '(''.. L''''objet est un objet simple !'')'
      texte(1,7) = '(''.. L''''objet a un nom bizarre.'')'
      texte(1,8) = '(''Une branche est indefinie.'')'
c
      texte(2,4) = '(''Names oj objects for mesh : '',a)'
      texte(2,5) = '(''.. The object is not allocated.'')'
      texte(2,6) = '(''.. The object is a simple object.'')'
      texte(2,7) = '(''.. The object name is strange.'')'
      texte(2,8) = '(''A branch is undefined.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomail
      call gmprsx (nompro, nomail )
      call gmprsx (nompro, nomail//'.RenuMail' )
      call gmprsx (nompro, nomail//'.Noeud' )
      call gmprsx (nompro, nomail//'.Arete' )
      call gmprsx (nompro, nomail//'.Face' )
      call gmprsx (nompro, nomail//'.Volume' )
#endif
c
c====
c 2. recuperation des donnees du maillage
c====
c
c 2.1. ==> l'objet existe-t-il vraiment ?
c
      call gmobal ( nomail, codret )
c
      if ( codret.eq.1 ) then
c
        codret = 0
c
      else
c
        write (ulsort,texte(langue,4)) nomail
c
        if ( codret.eq.0 ) then
          write (ulsort,texte(langue,5))
c
        elseif ( codret.eq.2 ) then
          write (ulsort,texte(langue,6))
c
        else
          write (ulsort,texte(langue,7))
c
        endif
c
        codret = 1
c
      endif
c
c 2.2. ==> caracteristiques de base
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nomail, 1, sdim  , codre1 )
      call gmliat ( nomail, 2, mdim  , codre2 )
      call gmliat ( nomail, 3, degre , codre3 )
      call gmliat ( nomail, 4, maconf, codre4 )
      call gmliat ( nomail, 5, homolo, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      call gmliat ( nomail, 6, hierar, codre1 )
      call gmliat ( nomail, 7, rafdef, codre2 )
      call gmliat ( nomail, 8, nbmane, codre3 )
      call gmliat ( nomail, 9, typcca, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      call gmliat ( nomail,10, typsfr, codre1 )
      call gmliat ( nomail,11, maextr, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 2.3. ==> noms des branches
c
c    le code de retour de gmnomc est :
c      0 : tout va bien
c     -1 : l'objet n'est pas defini ; dans ce cas, le nom est "Indefini"
c     -3 : le nom etendu est invalide
c
c    Ici, on tolere le retour -1, car selon les endroits, les branches
c    ne sont pas toutes definies.
c    En revanche, le -3 est une vraie erreur car c'est que le nom
c    de l'objet maillage est mauvais.
c
c    Consequence : Il faut cumuler le codret et le tester seulement
c                  a la fin du 2.3
c
      if ( codret.eq.0 ) then
c
c 2.3.1 ==> Renumerotations et noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) nompro//' 2.3.1 Renum etc. ; codret = ', codret
#endif
c
      call gmnomc ( nomail//'.RenuMail', norenu, codre1 )
      call gmnomc ( nomail//'.Noeud'   , nhnoeu, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
c 2.3.2 ==> Aretes, tetraedres, pyramides et pentaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) nompro//' 2.3.2 Are etc. ; codret = ', codret
#endif
c
cgn      call gmprsx ('nomail.Face dans '//nompro, nomail//'.Face')
cgn      call gmprsx ('nomail.Volume dans '//nompro, nomail//'.Volume')
      if ( degre.eq.1 ) then
        call gmnomc ( nomail//'.Arete.HOM_Se02' , nharet, codre1 )
        call gmnomc ( nomail//'.Volume.HOM_Te04', nhtetr, codre2 )
        call gmnomc ( nomail//'.Volume.HOM_Py05', nhpyra, codre3 )
        call gmnomc ( nomail//'.Volume.HOM_Pe06', nhpent, codre4 )
      else
        call gmnomc ( nomail//'.Arete.HOM_Se03' , nharet, codre1 )
        call gmnomc ( nomail//'.Volume.HOM_Te10', nhtetr, codre2 )
        call gmnomc ( nomail//'.Volume.HOM_Py13', nhpyra, codre3 )
        call gmnomc ( nomail//'.Volume.HOM_Pe15', nhpent, codre4 )
      endif
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
c 2.3.3 ==> Triangles, quadrangles et hexaedres : eventuellement etendu
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) nompro//' 2.3.3 Tri etc. ; codret = ', codret
#endif
c
      mailet = 1
c
      if ( degre.eq.1 ) then
c
        call gmnomc ( nomail//'.Face.HOM_Tr03'  , nhtria, codre1 )
        call gmnomc ( nomail//'.Face.HOM_Qu04'  , nhquad, codre2 )
        call gmnomc ( nomail//'.Volume.HOM_He08', nhhexa, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
      else
c
cgn            call gmprsx ( nompro, nomail//'.Face' )
cgn            call gmprsx ( nompro, nomail//'.Volume' )
        saux02(1,1) = 'Tr06'
        saux02(1,2) = 'Tr07'
        saux02(2,1) = 'Qu08'
        saux02(2,2) = 'Qu09'
        saux02(3,1) = 'He20'
        saux02(3,2) = 'He27'
c
        do 233 , iaux = 1 , 3
c
          saux80 = blan80
          if ( iaux.le.2 ) then
            kaux = 8 + 10
            saux80(1:kaux) = nomail//'.Face.HOM_'
          else
            kaux = 8 + 12
            saux80(1:kaux) = nomail//'.Volume.HOM_'
          endif
          do 2331 , jaux = 1 , 2
c
            saux80(kaux+1:kaux+4) = saux02(iaux,jaux)
            call gmobal ( saux80 , codre0 )
cgn        write(ulsort,90002) 'gmobal pour '//saux80(1:kaux+4),codre0
            if ( codre0.eq.0 ) then
              goto 2331
            elseif ( codre0.eq.1 ) then
              call gmnomc ( saux80 , saux08, codre1 )
              if ( codre1.eq.0 ) then
cgn             write(ulsort,90003) 'nom de '//saux80(1:kaux+4), saux08
                if ( iaux.eq.1 ) then
                  nhtria = saux08
                  if ( jaux.eq.2 ) then
                    mailet = mailet*2
                  endif
                elseif ( iaux.eq.2 ) then
                  nhquad = saux08
                  if ( jaux.eq.2 ) then
                    mailet = mailet*3
                  endif
                else
                  nhhexa = saux08
                  if ( jaux.eq.2 ) then
                    mailet = mailet*5
                  endif
                endif
                goto 233
              else
                codret = 1
              endif
            else
              codret = 1
            endif
c
 2331     continue
c
  233   continue
#ifdef _DEBUG_HOMARD_
        write(ulsort,90002) 'mailet' , mailet
        write(ulsort,90003) 'nhtria' , nhtria
        write(ulsort,90003) 'nhquad' , nhquad
        write(ulsort,90003) 'nhhexa' , nhhexa
#endif
c
      endif
c
c 2.3.4 ==> Voisinages et autres
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) nompro//' 2.3.4 Voisinages ; codret = ', codret
#endif
c
      call gmnomc ( nomail//'.Voisins' , nhvois, codre1 )
      call gmnomc ( nomail//'.Ma_Point', nhmapo, codre2 )
      call gmnomc ( nomail//'.ElemIgno', nhelig, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      call gmnomc ( nomail//'.InfoSupE', nhsupe, codre1 )
      call gmnomc ( nomail//'.InfoSupS', nhsups, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
c 2.3.5 ==> Corrections du code de retour
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) nompro//' 2.3.5 correction ; codret = ', codret
#endif
c
      if ( codret.eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,8))
#endif
        codret = 0
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
