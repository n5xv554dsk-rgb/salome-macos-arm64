      subroutine infve6 ( action, numblo, numniv,
     >                    infsup, typcof,
     >                    nomcha, nomcmp, nrocha,
     >                    titre0,
     >                    titre1, lgtit1, titre2, lgtit2,
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
c   INformation : Fichier VEctoriel - 6eme partie
c   --            -       --          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . action . e   . char8  . action en cours                            .
c . numblo . e   .   1    . numero du bloc a tracer                    .
c .        .     .        . 0 : trace du domaine global                .
c . numniv . e   .   1    . numero du niveau a tracer                  .
c .        .     .        . -1 : tous les niveaux                      .
c . infsup . e   .   1    . information supplementaire a afficher      .
c .        .     .        . 0 : aucune                                 .
c .        .     .        . 1 : numero homard des noeuds               .
c .        .     .        . 2 : numero du calcul des noeuds            .
c .        .     .        . 3 : numero homard des faces                .
c .        .     .        . 4 : numero du calcul des faces             .
c .        .     .        . 5 : numero homard des aretes               .
c .        .     .        . 6 : numero du calcul des aretes            .
c .        .     .        . np : choix n et choix p simultanement      .
c . typcof . e   .   1    . type de coloriage des faces                .
c .        .     .        .   0 : incolore transparent                 .
c .        .     .        .   1 : incolore opaque                      .
c .        .     .        .   2 : famille HOMARD                       .
c .        .     .        .   4 : idem 2, en niveau de gris            .
c .        .     .        . +-6 : couleur selon un champ, echelle auto..
c .        .     .        . +-7 : idem avec echelle fixe               .
c .        .     .        . +-8/+-9 : idem +-6/+-7, en niveau de gris  .
c .        .     .        .  10 : niveau                               .
c . nomcha . e   . char64 . nom du champ retenu pour le coloriage      .
c . nomcmp . e   .   1    . nom de la composante retenue               .
c . nrocha . e   .   1    . nunero du champ retenu pour le coloriage   .
c .        .     .        . -1 si coloriage selon la qualite           .
c . titre0 . e   .   20   . titre initial                              .
c . titre1 .  s  .  100   . titre 1                                    .
c . lgtit1 .  s  .   1    . longueur du titre 1                        .
c . titre2 .  s  .  100   . titre 2                                    .
c . lgtit2 .  s  .   1    . longueur du titre 2                        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans les memoires             .
c .        .     .        . 3 : probleme dans les fichiers             .
c .        .     .        . 5 : probleme autre                         .
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
      parameter ( nompro = 'INFVE6' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca2.h"
#include "envada.h"
c
c 0.3. ==> arguments
c
      integer numblo, numniv
      integer infsup, typcof
      integer nrocha
      integer lgtit1, lgtit2
c
      character*8 action
      character*16 nomcmp
      character*64 nomcha
      character*100 titre1, titre2
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      character*8 saux08
      character*20 titre0
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
      texte(1,4) = '(''Action en cours : '',a)'
      texte(1,10) = '(''titre'',i1,'' : '',a)'
c
      texte(2,4) = '(''Current action : '',a)'
      texte(2,10) = '(''titre'',i1,'' : '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) action
#endif
c
c====
c 2. Titres
c====
c 2.1. ==> Titres vides au depart
c
      do 21 , iaux = 1 , 100
        titre1(iaux:iaux) = ' '
        titre2(iaux:iaux) = ' '
   21 continue
c
c 2.2 ==> Action et numero d'iteration
c               12345678
      saux08 = '        '
      if ( action(1:7).eq.'info_av' ) then
        saux08(1:4) = 'avad'
      elseif ( action(1:7).eq.'info_ap' ) then
        saux08(1:4) = 'apad'
      endif
c
      call utench ( nbiter, '0', iaux, saux08(6:7),
     >              ulsort, langue, codret )
c
c 2.3 ==> Ajout du titre du calcul
c
      if ( codret.eq.0 ) then
c
      call utlgut ( iaux, titre, ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      titre1(1:iaux+11) = saux08//'- '//titre
c
      lgtit1 = iaux + 11
c
      endif
c
c 2.4 ==> Bloc eventuel
c
      if ( codret.eq.0 ) then
c
      if ( numblo.gt.0 ) then
c
        call utench ( numblo, 'g', jaux, saux08,
     >                ulsort, langue, codret )
c
        if ( codret.eq.0 ) then
c
        if ( langue.eq.1 ) then
          if ( lgtit1+14+jaux.le.100 ) then
            titre1(lgtit1+1:lgtit1+14+jaux) =
     >                                 '- Bloc numero '//saux08(1:jaux)
c                                       12345678901234
            lgtit1 = lgtit1+14+jaux
          endif
        else
          if ( lgtit1+10+jaux.le.100 ) then
            titre1(lgtit1+1:lgtit1+10+jaux) =
     >                                 '- Block # '//saux08(1:jaux)
c                                       1234567890
            lgtit1 = lgtit1+10+jaux
          endif
        endif
c
        endif
c
      endif
c
      endif
c
c 2.5 ==> Niveau eventuel
c
      if ( codret.eq.0 ) then
c
      if ( numniv.gt.-1 ) then
c
        call utench ( numniv, 'g', jaux, saux08,
     >                ulsort, langue, codret )
c
        if ( codret.eq.0 ) then
c
        if ( langue.eq.1 ) then
          if ( iaux+10+jaux.le.100 ) then
            titre1(iaux+1:iaux+10+jaux) =
     >                              ' - Niveau '//saux08(1:jaux)
c                                    1234567890
            iaux = iaux+10+jaux
          endif
        else
          if ( iaux+11+jaux.le.100 ) then
            titre1(iaux+1:iaux+11+jaux) =
     >                                 ' - Level # '//saux08(1:jaux)
c                                       12345678901
            iaux = iaux+11+jaux
          endif
        endif
c
        lgtit1 = iaux
c
        endif
c
      endif
c
      endif
c
c 2.6 ==> Complements en fonction des choix retenus pour les couleurs
c
      if ( codret.eq.0 ) then
cgn      print *,titre1
cgn      print *,'lgtit1 =', lgtit1
c
      if (      ( typcof.ge.2 .and. typcof.le.5 ) .or.
     >     ( abs(typcof).ge.6 .and. abs(typcof).le.9 ) .or.
     >     typcof.eq.10 ) then
c
        if ( typcof.eq.10 ) then
          if ( langue.eq.1 ) then
            if ( lgtit1+24.le.100 ) then
c                                           123456789012345678901234
              titre1(lgtit1+1:lgtit1+24) = ' - Niveau de raffinement'
              lgtit1 = lgtit1 + 24
            endif
          else
            if ( iaux+19.le.100 ) then
              titre1(lgtit1+1:lgtit1+19) = ' - Refinement level'
              lgtit1 = lgtit1 + 19
            endif
          endif
        elseif ( typcof.eq.2 .or. typcof.eq.4 ) then
          if ( langue.eq.1 ) then
            if ( lgtit1+17.le.100 ) then
c                                           12345678901234567
              titre1(lgtit1+1:lgtit1+17) = ' - Famille HOMARD'
              lgtit1 = lgtit1 + 17
            endif
          else
            if ( lgtit1+16.le.100 ) then
              titre1(lgtit1+1:lgtit1+16)  = ' - HOMARD family'
              lgtit1 = lgtit1 + 16
            endif
          endif
        else
          if ( nrocha.le.0 ) then
            if ( langue.eq.1 ) then
              if ( lgtit1+10.le.100 ) then
c                                             1234567890
                titre1(lgtit1+1:lgtit1+10) = ' - Qualite'
                lgtit1 = lgtit1 + 10
              endif
            else
              if ( lgtit1+10.le.100 ) then
                titre1(lgtit1+1:lgtit1+10) = ' - Quality'
                lgtit1 = lgtit1 + 10
              endif
            endif
          else
            call utlgut ( iaux, nomcha, ulsort, langue, codret )
            jaux = lgtit1 + 3 + iaux
            if ( iaux.gt.0 .and. jaux.le.100 ) then
              titre1(lgtit1+1:jaux) = ' - '//nomcha(1:iaux)
              lgtit1 = jaux
            endif
            call utlgut ( iaux, nomcmp, ulsort, langue, codret )
            jaux = lgtit1 + 2 + iaux
            if ( iaux.gt.0 .and. jaux.le.100 ) then
              titre1(lgtit1+1:jaux) = ', '//nomcmp(1:iaux)
              lgtit1 = jaux
            endif
            call utlgut ( iaux, titre0, ulsort, langue, codret )
            jaux = lgtit1 + 1 + iaux
            if ( iaux.gt.0 .and. jaux.le.100 ) then
              titre1(lgtit1+1:jaux) = ' ' // titre0(1:iaux)
              lgtit1 = jaux
            endif
          endif
        endif
      endif
c
      endif
c
c 2.6 ==> Complements en fonction des choix retenus pour les ecritures
c
      if ( codret.eq.0 ) then
c
c                    123456789012345678901234567
      if ( infsup.eq.1 ) then
        if ( langue.eq.1 ) then
          titre2 = 'Numero HOMARD des noeuds'
          lgtit2 = 24
        else
          titre2 = 'HOMARD # of nodes'
          lgtit2 = 17
        endif
      elseif ( infsup.eq.2 ) then
        if ( langue.eq.1 ) then
          titre2 = 'Numero du calcul des noeuds'
          lgtit2 = 27
        else
          titre2 = 'Extern # of nodes'
          lgtit2 = 17
        endif
      elseif ( infsup.eq.3 ) then
        if ( langue.eq.1 ) then
          titre2 = 'Numero HOMARD des faces'
          lgtit2 = 23
        else
          titre2 = 'HOMARD # of faces'
          lgtit2 = 17
        endif
      elseif ( infsup.eq.4 ) then
        if ( langue.eq.1 ) then
          titre2 = 'Numero du calcul des faces'
          lgtit2 = 26
        else
          titre2 = 'Extern # of faces'
          lgtit2 = 17
        endif
      elseif ( infsup.eq.5 ) then
        if ( langue.eq.1 ) then
          titre2 = 'Numero HOMARD des aretes'
          lgtit2 = 24
        else
          titre2 = 'HOMARD # of edges'
          lgtit2 = 17
        endif
      elseif ( infsup.eq.6 ) then
        if ( langue.eq.1 ) then
          titre2 = 'Numero du calcul des aretes'
          lgtit2 = 27
        else
          titre2 = 'Extern # of edges'
          lgtit2 = 17
        endif
      else
        lgtit2 = 0
      endif
c
      if ( lgtit2.ne.0 ) then
        titre2(lgtit2+1:lgtit2+3) = ' - '
        lgtit2 = lgtit2 + 3
      endif
      call utlgut ( iaux, ladate, ulsort, langue, codret )
      titre2(lgtit2+1:lgtit2+iaux) = ladate
      lgtit2 = lgtit2 + iaux
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) 1, titre1
      write (ulsort,texte(langue,10)) 2, titre2
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
