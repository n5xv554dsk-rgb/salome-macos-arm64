      subroutine pppma1 ( typcof,
     >                    lgtcmx, tbcols, tbcoli, ncotbl,
     >                    nbtrvi, nbquvi,
     >                    nntrvi, nnquvi,
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
c     Post-Processeur - Preparation du MAillage - phase 1
c     -    -            -              --               -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typcof . e   .   1    . type de coloriage des faces                .
c .        .     .        .   0 : incolore transparent                 .
c .        .     .        .   1 : incolore opaque                      .
c .        .     .        .   2 : famille HOMARD                       .
c .        .     .        .   3 : famille HOMARD, sans orientation     .
c .        .     .        .   4/5 : idem 2/3, en niveau de gris        .
c .        .     .        . +-6 : couleur selon un champ, echelle auto..
c .        .     .        . +-7 : idem avec echelle fixe               .
c .        .     .        . +-8/+-9 : idem +-6/+-7, en niveau de gris  .
c .        .     .        .  10 : niveau                               .
c . lgtcmx . e   .   1    . longueur maximale de la table de couleur   .
c . tbcoli . e   .        . table de couleur entier                    .
c . tbcols .  s  .char*17 . table de couleur caracteres                .
c .        .     . (-3:   . Les immuables sont :                       .
c .        .     . lgtcmx).       -3 : defaut de xfig                  .
c .        .     .        .       -2 : noir                            .
c .        .     .        .       -1 : blanc                           .
c .        .     .        . lgtcmx-2 : rouge pour les aretes de bord   .
c .        .     .        . lgtcmx-1 : un gris pale pour les familles  .
c .        .     .        .            libres et le triedre            .
c .        .     .        .  lgtcmx : un vert pale (cadre de zoom)     .
c . ncotbl .  s  .   1    . nombre de couleurs dans la table           .
c . nbtrvi . e   .   1    . nombre triangles visualisables             .
c . nbquvi . e   .   1    . nombre de quadrangles visualisables        .
c . nntrvi . e   .10nbtrvi. 1 : niveau du triangle a afficher          .
c .        .     .        . 2 : numero HOMARD du triangle              .
c .        .     .        . 3, 4, 5 : numeros des noeuds p1            .
c .        .     .        . 6 : famille du triangle                    .
c .        .     .        . 7, 8, 9 : numeros des noeuds p2            .
c .        .     .        . 10 : numero du noeud interne               .
c . nnquvi . e   .12nbquvi. 1 : niveau du quadrangle a afficher        .
c .        .     .        . 2 : numero HOMARD du quadrangle            .
c .        .     .        . 3, 4, 5, 6 : numeros des noeuds p1         .
c .        .     .        . 7 : famille du quadrangle                  .
c .        .     .        . 8, 9, 10, 11 : numeros des noeuds p2       .
c .        .     .        . 12 : numero du noeud interne               .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'PPPMA1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer lgtcmx, typcof, ncotbl
      integer nbtrvi, nbquvi
      integer nntrvi(10,nbtrvi)
      integer nnquvi(12,nbquvi)
      integer tbcoli(-3:lgtcmx)
c
      character*17 tbcols(-2:lgtcmx)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      double precision daux
c
      character*3 saux03
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c      Codification Xfig :
c      -1 = Default
c       0 = Black
c       1 = Blue
c       2 = Green
c       3 = Cyan
c       4 = Red
c       5 = Magenta
c       6 = Yellow
c       7 = White
c    8-11 = four shades of blue (dark to lighter)
c   12-14 = three shades of green (dark to lighter)
c   15-17 = three shades of cyan (dark to lighter)
c   18-20 = three shades of red (dark to lighter)
c   21-23 = three shades of magenta (dark to lighter)
c   24-26 = three shades of brown (dark to lighter)
c   27-30 = four shades of pink (dark to lighter)
c      31 = Gold
c_______________________________________________________________________
c
c====
c 1. les messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      codret = 0
c
c====
c 2. les immuables
c          -3 : defaut de xfig
c          -2 : noir
c          -1 : blanc
c    lgtcmx-2 : rouge pour les aretes de bord
c    lgtcmx-1 : un gris pale pour les familles libres et le triedre
c      lgtcmx : un vert pale (pour la fenetre de zoom)
c====
c
      tbcols(-2) = '0.000 0.000 0.000'
      tbcols(-1) = '1.000 1.000 1.000'
c
      tbcols(lgtcmx-2) = '1.000 0.000 0.000'
      tbcols(lgtcmx-1) = '0.800 0.800 0.800'
      tbcols(lgtcmx)   = '0.100 0.600 0.200'
c
      tbcoli(-3) = -1
      tbcoli(-2) = 0
      tbcoli(-1) = 7
c
      tbcoli(lgtcmx-2) = 4
      tbcoli(lgtcmx-1) = 30
      tbcoli(lgtcmx)   = 14
c
c====
c 3. pour un coloriage par valeur discrete : niveau ou famille
c    typcof compris entre 1 et 5
c====
c 3.1. ==> en couleur ; typcof valant 2, 3 ou 10
c           0 : bleu
c           1 : rouge
c           2 : vert
c           3 : magenta
c           4 : turquoise
c           5 : jaune
c           etc
c           pour xfig on est limite a 31
c
      if ( typcof.eq.2 .or. typcof.eq.3 .or. typcof.eq.10 ) then
c
        tbcols(0)  = '0.000 0.000 1.000'
        tbcoli(0)  = 1
        tbcols(1)  = '1.000 0.000 0.000'
        tbcoli(1)  = 4
        tbcols(2)  = '0.000 1.000 0.000'
        tbcoli(2)  = 2
        tbcols(3)  = '1.000 0.000 1.000'
        tbcoli(3)  = 5
        tbcols(4)  = '0.000 1.000 1.000'
        tbcoli(4)  = 3
        tbcols(5)  = '1.000 1.000 0.000'
        tbcoli(5)  = 6
        tbcols(6)  = '0.200 0.400 0.600'
        tbcoli(6)  = 27
        tbcols(7)  = '0.400 0.600 0.200'
        tbcoli(7)  = 24
        tbcols(8)  = '0.600 0.200 0.400'
        tbcoli(8)  = 21
        tbcols(9)  = '0.100 0.200 0.800'
        tbcoli(9)  = 18
        tbcols(10) = '0.800 0.200 0.100'
        tbcoli(10)  = 15
        kaux = 0
        do 311 , iaux = 1 , nbtrvi
          kaux = max ( kaux, nntrvi(6,iaux) )
  311   continue
        do 312 , iaux = 1 , nbquvi
          kaux = max ( kaux, nnquvi(7,iaux) )
  312   continue
        if ( kaux.gt.10 ) then
          do 313 , iaux = 11 , kaux
            tbcols(iaux) = '0.000 0.000 0.000'
            call utench ( iaux, 'g', jaux, saux03,
     >                    ulsort, langue, codret )
            tbcols(iaux)(3:2+jaux) = saux03(1:jaux)
            call utench ( 100+iaux, 'g', jaux, saux03,
     >                    ulsort, langue, codret )
            tbcols(iaux)(9:8+jaux) = saux03(1:jaux)
            call utench ( mod(iaux,100), 'g', jaux, saux03,
     >                    ulsort, langue, codret )
            tbcols(iaux)(15:14+jaux) = saux03(1:jaux)
            if ( mod(iaux-11,18).eq.0 ) then
              tbcoli(iaux)  = 8
            elseif ( mod(iaux-11,17).eq.1 ) then
              tbcoli(iaux)  = 12
            elseif ( mod(iaux-11,17).eq.2 ) then
              tbcoli(iaux)  = 16
            elseif ( mod(iaux-11,17).eq.3 ) then
              tbcoli(iaux)  = 19
            elseif ( mod(iaux-11,17).eq.4 ) then
              tbcoli(iaux)  = 22
            elseif ( mod(iaux-11,17).eq.5 ) then
              tbcoli(iaux)  = 9
            elseif ( mod(iaux-11,17).eq.6 ) then
              tbcoli(iaux)  = 13
            elseif ( mod(iaux-11,17).eq.7 ) then
              tbcoli(iaux)  = 28
            elseif ( mod(iaux-11,17).eq.8 ) then
              tbcoli(iaux)  = 25
            elseif ( mod(iaux-11,17).eq.9 ) then
              tbcoli(iaux)  = 10
            elseif ( mod(iaux-11,17).eq.10 ) then
              tbcoli(iaux)  = 14
            elseif ( mod(iaux-11,17).eq.11 ) then
              tbcoli(iaux)  = 17
            elseif ( mod(iaux-11,17).eq.12 ) then
              tbcoli(iaux)  = 29
            elseif ( mod(iaux-11,17).eq.13 ) then
              tbcoli(iaux)  = 20
            elseif ( mod(iaux-11,17).eq.14 ) then
              tbcoli(iaux)  = 23
            elseif ( mod(iaux-11,17).eq.15 ) then
              tbcoli(iaux)  = 26
            elseif ( mod(iaux-11,17).eq.16 ) then
              tbcoli(iaux)  = 11
            elseif ( mod(iaux-11,17).eq.17 ) then
              tbcoli(iaux)  = 30
            endif
  313     continue
        endif
c
c 3.2. ==> en niveau de gris ; typcof compris entre 4 et 5
c           0 : blanc
c           1 : gris tres tres clair
c           2 : gris tres clair
c           etc
c
      elseif ( typcof.ge.4 .and. typcof.le.5 ) then
c
c
        tbcols(0)  = '1.000 1.000 1.000'
        tbcoli(0)  = 7
        kaux = 0
        do 321 , iaux = 1 , nbtrvi
          kaux = max ( kaux, nntrvi(6,iaux) )
  321   continue
        do 322 , iaux = 1 , nbquvi
          kaux = max ( kaux, nnquvi(7,iaux) )
  322   continue
        daux = 999.d0/dble(kaux)
        do 333 , iaux = 1 , kaux
          tbcols(iaux)  = '0.000 0.000 0.000'
          jaux = int ( dble(iaux)*daux )
          saux03 = '000'
          call utench ( jaux, '0', laux, saux03,
     >                 ulsort, langue, codret )
          tbcols(iaux)( 3: 6) = saux03
          tbcols(iaux)( 9:12) = saux03
          tbcols(iaux)(15:17) = saux03
          tbcoli(iaux)  = 0
  333   continue
c
c====
c 4. pour un coloriage par valeur continue : fonction
c    typcof valant +-6 ou +-7
c====
c
      elseif ( abs(typcof).eq.6 .or. abs(typcof).eq.7 ) then
c
c       Pour l'ancien PostScript, pour memoire
c       on fait un degrade du minimum, 0/bleu, au maximum, 22/rouge
c       la progression en RGB est issue des travaux presentes sur :
c       http://the-light.com/colclick.html
c
        laux = 39
        daux = 1000.d0/(dble(laux+1))
c
c bleu pur
c
        tbcols(0)   = '0.000 0.000 1.000'
c
c nuances de bleu a turquoise : on augmente le G
c
        ncotbl = 0
        do 41 , iaux = 1, laux
          kaux = nint(daux*dble(iaux))
          call utench ( kaux, '0', jaux, saux03,
     >                  ulsort, langue, codret )
          ncotbl = ncotbl + 1
c                           12345678901234567
          tbcols(ncotbl) = '0.000 0.zzz 1.000'
          tbcols(ncotbl)(9:11) = saux03
   41   continue
c
c turquoise pur
c
        ncotbl = ncotbl + 1
        tbcols(ncotbl)   = '0.000 1.000 1.000'
c
c nuances de turquoise a vert : on diminue le B
c
        do 42 , iaux = laux , 1, -1
          kaux = nint(daux*dble(iaux))
          call utench ( kaux, '0', jaux, saux03,
     >                  ulsort, langue, codret )
          ncotbl = ncotbl + 1
c                           12345678901234567
          tbcols(ncotbl) = '0.000 1.000 0.zzz'
          tbcols(ncotbl)(15:17) = saux03
   42   continue
c
c vert pur
c
        ncotbl = ncotbl + 1
        tbcols(ncotbl)   = '0.000 1.000 0.000'
c
c nuances de vert a jaune : on augmente le R
c
        do 43 , iaux = 1, laux
          kaux = nint(daux*dble(iaux))
          call utench ( kaux, '0', jaux, saux03,
     >                  ulsort, langue, codret )
          ncotbl = ncotbl + 1
c                           12345678901234567
          tbcols(ncotbl) = '0.zzz 1.000 0.000'
          tbcols(ncotbl)(3:5) = saux03
   43   continue
c
c jaune pur
c
        ncotbl = ncotbl + 1
        tbcols(ncotbl)   = '1.000 1.000 0.000'
c
c nuances de jaune a rouge : on diminue le G
c
        do 44 , iaux = laux , 1, -1
          kaux = nint(daux*dble(iaux))
          call utench ( kaux, '0', jaux, saux03,
     >                  ulsort, langue, codret )
          ncotbl = ncotbl + 1
c                           12345678901234567
          tbcols(ncotbl) = '1.000 0.zzz 0.000'
          tbcols(ncotbl)(9:11) = saux03
   44   continue
c
c rouge pur
c
        ncotbl = ncotbl + 1
        tbcols(ncotbl)   = '1.000 0.000 0.000'
c
c       Pour Xfig, on fait un degrade du minimum, 0/bleu sombre, au
c       maximum, 7/rouge
c
        tbcoli(0) =  8
        tbcoli(1) =  1
        tbcoli(2) =  3
        tbcoli(3) =  2
        tbcoli(4) =  6
        tbcoli(5) = 31
        tbcoli(6) =  4
        tbcoli(7) = 18
c
        ncotbl = 7
c
      endif
c
cgn      print 1789,(tbcols(iaux),iaux=-2,ncotbl)
cgn 1789 format(a17)
cgn        print *,'ncotbl = ',ncotbl
c
c====
c 5. la fin
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
