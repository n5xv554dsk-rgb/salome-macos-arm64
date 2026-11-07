      subroutine utahma ( nomail, typnom, option,
     >                      sdim,   mdim,  degre, mailet, maconf,
     >                    homolo, hierar, rafdef,
     >                    nbmane, typcca, typsfr, maextr,
     >                    norenu,
     >                    nhnoeu, nhmapo, nharet,
     >                    nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    nhelig,
     >                    nhvois, nhsupe, nhsups,
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
c    UTilitaire - Allocation pour HOMARD - MAillage
c    --           -               -        --
c
c    Branche InfoSupE :
c       Tab1 : communs entiers
c       Tab2 : type des elements
c       Si le format externe est le format MED :
c         Tab3 : tableau de la branche Famille.Attribut.Pointeur
c         Tab4 : tableau de la branche Famille.Attribut
c         Tab5 : tableau de la branche Famille.Groupe.Pointeur
c         Tab6 : tableau de la branche Famille.Groupe.Taille
c         Tab7 : tableau de la branche InfoGene.Pointeur
c         Tab8 : tableau de la branche InfoGene.Taille
c         Tab9 : tableau de la branche Famille.Numero
c    Branche InfoSupS :
c       Tab1 : commun de la date
c       Si le format externe est le format MED :
c         Tab2 : tableau de la branche Famille.Groupe.Table
c         Tab3 : tableau de la branche InfoGene.Table
c         Tab4 : tableau de la branche Famille.Nom
c         Tab5 : tableau de la branche Equivalt.InfoGene
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . es  . char8  . nom de l'objet maillage homard             .
c . typnom . e   .    1   . type du nom de l'objet maillage            .
c .        .     .        . 0 : le nom est a creer automatiquement     .
c .        .     .        . 1 : le nom est impose par l'appel          .
c . option . e   .    1   . option de creation de l'objet maillage     .
c .        .     .        . 1 : toutes les branches sont a creer       .
c .        .     .        . 2x : sauf la branche RenuMail              .
c . sdim   . e   .    1   . dimension de l'espace                      .
c . mdim   . e   .    1   . dimension du maillage                      .
c . degre  . e   .    1   . degre du maillage                          .
c . maconf . e   .    1   . conformite du maillage                     .
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
c . homolo . e   .    1   . type de relations par homologues           .
c .        .     .        . 0 : pas d'homologues                       .
c .        .     .        . 1 : relations sur les noeuds               .
c .        .     .        . 2 : relations sur les noeuds et les aretes .
c .        .     .        . 3 : relations sur les noeuds, les aretes   .
c .        .     .        .     et les triangles                       .
c . hierar . e   .    1   . maillage hierarchique                      .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : oui                                    .
c . rafdef . e   .    1   . 0 : macro-maillage                         .
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
c . nbmane . e   .    1   . nombre maximum de noeuds par element       .
c . typcca . e   .   1    . type du code de calcul                     .
c . typsfr . e   .   1    . type du suivi de frontiere                 .
c .        .     .        . 0 : aucun                                  .
c .        .     .        . 1 : maillage de degre 1, avec projection   .
c .        .     .        .     des nouveaux sommets                   .
c .        .     .        . 2 : maillage de degre 2, seuls les noeuds  .
c .        .     .        .     P1 sont sur la frontiere ; les noeuds  .
c .        .     .        .     P2 restent au milieu des P1            .
c .        .     .        . 3 : maillage de degre 2, les noeuds P2     .
c .        .     .        .     etant sur la frontiere                 .
c . maextr . e   .   1    . maillage extrude                           .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : selon X                                .
c .        .     .        . 2 : selon Y                                .
c .        .     .        . 3 : selon Z (cas de Saturne ou Neptune)    .
c . mailet . e   .    1   . presence de mailles etendues               .
c .        .     .        .  1 : aucune                                .
c .        .     .        . 2x : TRIA7                                 .
c .        .     .        . 3x : QUAD9                                 .
c .        .     .        . 5x : HEXA27                                .
c . norenu .   s . char8  . nom de la branche RenuMail                 .
c . nhnoeu .   s . char8  . nom de la branche Noeud                    .
c . nhmapo .   s . char8  . nom de la branche Ma_Point                 .
c . nharet .   s . char8  . nom de la branche Arete                    .
c . nhtria .  s  . char8  . nom de l'objet decrivant les triangles     .
c . nhquad .  s  . char8  . nom de l'objet decrivant les quadrangles   .
c . nhtetr .  s  . char8  . nom de l'objet decrivant les tetraedres    .
c . nhhexa .  s  . char8  . nom de l'objet decrivant les hexaedres     .
c . nhpyra .  s  . char8  . nom de l'objet decrivant les pyramides     .
c . nhpent .  s  . char8  . nom de l'objet decrivant les pentaedres    .
c . nhvois .   s . char8  . nom de la branche Voisins                  .
c . nhsupe .  s  . char8  . informations supplementaires entieres      .
c . nhsups .  s  . char8  . informations supplementaires caracteres 8  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . -1 : mauvaise demande pour le type de nom  .
c .        .     .        . autre : probleme dans l'allocation         .
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
      parameter ( nompro = 'UTAHMA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer typnom, option
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
      integer codre6, codre7, codre8, codre9
      integer codre0
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
      texte(1,4) = '(''Allocation d''''un objet maillage HOMARD'',/)'
      texte(1,5) = '(''Mauvaise demande de type de nom :'',i6)'
      texte(1,6) = '(''Probleme pour allouer l''''objet '',a8)'
      texte(1,7) = '(''Probleme pour allouer un objet temporaire.'')'
c
      texte(2,4) = '(''Allocation of an object HOMARD mesh'',/)'
      texte(2,5) = '(''Bad request for the type of the name :'',i6)'
      texte(2,6) = '(''Problem while allocating object '',a8)'
      texte(2,7) = '(''Problem while allocating a temporary object.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,4))
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'sdim  ', sdim
      write (ulsort,90002) 'mdim  ', mdim
      write (ulsort,90002) 'degre ', degre
      write (ulsort,90002) 'mailet', mailet
      write (ulsort,90002) 'maconf', maconf
      write (ulsort,90002) 'homolo', homolo
      write (ulsort,90002) 'hierar', hierar
      write (ulsort,90002) 'rafdef', rafdef
      write (ulsort,90002) 'nbmane', nbmane
      write (ulsort,90002) 'typcca', typcca
      write (ulsort,90002) 'typsfr', typsfr
      write (ulsort,90002) 'maextr', maextr
#endif
c
c====
c 2. allocation de la structure du maillage HOMARD
c====
c 2.1. ==> allocation de la tete du maillage HOMARD
c
      if ( typnom.eq.0 ) then
c
        call gmalot ( nomail, 'HOM_Mail', 0, iaux, codre1 )
        codret = abs(codre1)
c
      elseif ( typnom.eq.1 ) then
c
        call gmaloj ( nomail, 'HOM_Mail', 0, iaux, codre1 )
        codret = abs(codre1)
c
      else
c
        codret = -1
c
      endif
c
c 2.2. ==> Attributs
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.2. attributs ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nomail, 1, sdim, codre1 )
      call gmecat ( nomail, 2, mdim, codre2 )
      call gmecat ( nomail, 3, degre, codre3 )
      call gmecat ( nomail, 4, maconf, codre4 )
      call gmecat ( nomail, 5, homolo, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      call gmecat ( nomail, 6, hierar, codre1 )
      call gmecat ( nomail, 7, rafdef, codre2 )
      call gmecat ( nomail, 8, nbmane, codre3 )
      call gmecat ( nomail, 9, typcca, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      call gmecat ( nomail,10, typsfr, codre1 )
      call gmecat ( nomail,11, maextr, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 3. Allocation des branches principales
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. branches principales ; codret = ', codret
#endif
c
c 3.1. ==> Allocation des branches principales
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( nomail//'.Noeud'   , ' ', 0, iaux, codre1 )
      call gmaloj ( nomail//'.Ma_Point', ' ', 0, iaux, codre2 )
      call gmaloj ( nomail//'.Arete'   , ' ', 0, iaux, codre3 )
      call gmaloj ( nomail//'.Face'    , ' ', 0, iaux, codre4 )
      call gmaloj ( nomail//'.Volume'  , ' ', 0, iaux, codre5 )
      call gmaloj ( nomail//'.ElemIgno', ' ', 0, iaux, codre6 )
      call gmaloj ( nomail//'.Voisins' , ' ', 0, iaux, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      call gmaloj ( nomail//'.InfoSupE', ' ', 0, iaux, codre1 )
      call gmaloj ( nomail//'.InfoSupS', ' ', 0, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 3.2. ==> Allocation des branches optionnelles
c
      if ( codret.eq.0 ) then
c
      if ( mod(option,2).ne.0 ) then
c
        call gmaloj ( nomail//'.RenuMail', ' ', 0, iaux, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        if ( codret.eq.0 ) then
c
        call gmaloj ( nomail//'.RenuMail.InfoSupE',
     >                ' ', 0, iaux, codre1 )
        codre2 = 0
        do 32 , iaux = 1 , 10
          call gmecat ( nomail//'.RenuMail.InfoSupE', iaux, 0, codre0 )
          codre2 = max ( abs(codre2), codre0 )
   32   continue
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
      endif
c
      endif
c
c====
c 4. branches decrivant les elements
c    on le fait pour un nombre nul d'elements
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. branches des elements ; codret = ', codret
#endif
c 4.1. ==> allocation
c
      jaux = 0
c
      if ( codret.eq.0 ) then
c
      if ( degre.eq.1 ) then
        call gmaloj (nomail//'.Arete.HOM_Se02' , ' ', jaux, iaux,codre1)
        call gmaloj (nomail//'.Face.HOM_Tr03'  , ' ', jaux, iaux,codre2)
        call gmaloj (nomail//'.Face.HOM_Qu04'  , ' ', jaux, iaux,codre3)
        call gmaloj (nomail//'.Volume.HOM_Te04', ' ', jaux, iaux,codre4)
        call gmaloj (nomail//'.Volume.HOM_He08', ' ', jaux, iaux,codre5)
        call gmaloj (nomail//'.Volume.HOM_Py05', ' ', jaux, iaux,codre6)
        call gmaloj (nomail//'.Volume.HOM_Pe06', ' ', jaux, iaux,codre7)
      else
        call gmaloj (nomail//'.Arete.HOM_Se03' , ' ', jaux, iaux,codre1)
        if ( mod(mailet,2).eq.0 .or. mod(mailet,3).eq.0 ) then
          call gmaloj (nomail//'.Face.HOM_Tr07', ' ', jaux, iaux,codre2)
        else
          call gmaloj (nomail//'.Face.HOM_Tr06', ' ', jaux, iaux,codre2)
        endif
        if ( mod(mailet,3).eq.0 ) then
          call gmaloj (nomail//'.Face.HOM_Qu09', ' ', jaux, iaux,codre3)
        else
          call gmaloj (nomail//'.Face.HOM_Qu08', ' ', jaux, iaux,codre3)
        endif
        call gmaloj (nomail//'.Volume.HOM_Te10', ' ', jaux, iaux,codre4)
        if ( mod(mailet,5).eq.0 ) then
          call gmaloj (nomail//'.Volume.HOM_He27',
     >                  ' ', jaux, iaux, codre5)
        else
          call gmaloj (nomail//'.Volume.HOM_He20',
     >                  ' ', jaux, iaux, codre5)
        endif
        call gmaloj (nomail//'.Volume.HOM_Py13', ' ', jaux, iaux,codre6)
        call gmaloj (nomail//'.Volume.HOM_Pe15', ' ', jaux, iaux,codre7)
      endif
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      endif
c
c 4.2. ==> nom interne de ces branches
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4.2. nom interne ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c 4.3. ==> on met un nombre nul de mailles a priori
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4.3 ; codret = ', codret
#endif
c
      jaux = 0
c
      do 43 , iaux = 1 , 2
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nhmapo, iaux, jaux, codre1 )
        call gmecat ( nharet, iaux, jaux, codre2 )
        call gmecat ( nhtria, iaux, jaux, codre3 )
        call gmecat ( nhtetr, iaux, jaux, codre4 )
        call gmecat ( nhquad, iaux, jaux, codre5 )
        call gmecat ( nhpyra, iaux, jaux, codre6 )
        call gmecat ( nhhexa, iaux, jaux, codre7 )
        call gmecat ( nhpent, iaux, jaux, codre8 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >                 codre6, codre7, codre8 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5,
     >                 codre6, codre7, codre8 )
c
        endif
c
   43 continue
c
      call gmecat ( nhelig, 1, jaux, codre0 )
      codret = max ( abs(codre0), codret )
c
c 4.4. ==> idem en renumerotation
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4.4 ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(option,2).ne.0 ) then
c
        do 44 , iaux = 1 , 19
c
          jaux = iaux
          kaux = 0
          call gmecat ( norenu, jaux, kaux, codre0 )
c
          codret = max ( abs(codre0), codret )
c
   44   continue
c
      endif
c
      endif
c
c====
c 5. allocation de la branche des familles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. familles ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( nhnoeu//'.Famille', ' ', 0, iaux, codre1 )
      call gmaloj ( nhmapo//'.Famille', ' ', 0, iaux, codre2 )
      call gmaloj ( nharet//'.Famille', ' ', 0, iaux, codre3 )
      call gmaloj ( nhtria//'.Famille', ' ', 0, iaux, codre4 )
      call gmaloj ( nhtetr//'.Famille', ' ', 0, iaux, codre5 )
      call gmaloj ( nhquad//'.Famille', ' ', 0, iaux, codre6 )
      call gmaloj ( nhpyra//'.Famille', ' ', 0, iaux, codre7 )
      call gmaloj ( nhhexa//'.Famille', ' ', 0, iaux, codre8 )
      call gmaloj ( nhpent//'.Famille', ' ', 0, iaux, codre9 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8, codre9 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8, codre9 )
c
      endif
c
c====
c 6. allocation des branches decrivant les voisinages
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. voisinages ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( nhvois//'.0D/1D' , ' ', 0, iaux, codre1 )
      call gmaloj ( nhvois//'.1D/2D' , ' ', 0, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 7. attributs nuls pour les informations supplementaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. infos supplementaires ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 71 , iaux = 1 , 10
        call gmecat ( nomail//'.InfoSupE' , iaux, 0, codre1 )
        call gmecat ( nomail//'.InfoSupS' , iaux, 0, codre2 )
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
   71 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
c
c====
c 8. impression du graphe
c====
c
      call gmprsx (nompro, nomail )
      call gmprsx (nompro, nomail//'.Arete' )
      call gmprsx (nompro, nomail//'.Face' )
      call gmprsx (nompro, nomail//'.Volume' )
      call gmprsx (nompro, nomail//'.Voisins' )
      call gmprsx (nompro, nomail//'.InfoSupE' )
      call gmprsx (nompro, nomail//'.InfoSupS' )
#endif
c
c====
c 9. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      if ( codret.eq.-1 ) then
        write (ulsort,texte(langue,5)) typnom
      else
        if ( typnom.eq.1 ) then
          write (ulsort,texte(langue,6)) nomail
        else
          write (ulsort,texte(langue,7))
        endif
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
