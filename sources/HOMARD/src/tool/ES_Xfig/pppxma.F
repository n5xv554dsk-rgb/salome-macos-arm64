      subroutine pppxma ( infsup, typcof, typcop, typbor, optnoe,
     >                    porpay, zoom, triedr,
     >                    degre, sdim, mailet, nivsup,
     >                    titre1, titre2,
     >                    nbarvi, nbtrvi, nbquvi,
     >                    nnarvi, nntrvi, nnquvi,
     >                    coopro, posini,
     >                    nnoeca, nareca, ntreca, nqueca,
     >                    fotrva, foquva, vafomi, vafoma,
     >                    ulvecs, nomflo, lnomfl, ulsost,
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
c     Post-Processeur - format Xfig - MAillage
c     -    -                   -      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
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
c .        .     .        .   3 : famille HOMARD, sans orientation     .
c .        .     .        .   4/5 : idem 2/3, en niveau de gris        .
c .        .     .        . +-6 : couleur selon un champ, echelle auto..
c .        .     .        . +-7 : idem avec echelle fixe               .
c .        .     .        . +-8/+-9 : idem +-6/+-7, en niveau de gris  .
c .        .     .        .  10 : niveau                               .
c . typcop . e   .   1    . type de coloriage du perimetre des faces   .
c .        .     .        .   0 : pas de trace                         .
c .        .     .        .   2 : noir                                 .
c .        .     .        .   4 : niveau de la face                    .
c . typbor . e   .   1    . type d'affichage du bord                   .
c .        .     .        .   0 : pas de trace                         .
c .        .     .        .   1 : trace en rouge                       .
c .        .     .        .   2 : trace en noir                        .
c . optnoe . e   .   1    . 0 : rien de special                        .
c .        .     .        . 1 : trace d'un rond vide sur chaque noeud  .
c .        .     .        . 2 : trace d'un rond plein sur chaque noeud .
c . porpay . e   .   1    . 0 : portrait/paysage selon la taille       .
c .        .     .        . 1 : portrait                               .
c .        .     .        . 2 : paysage                                .
c . zoom   . e   .   1    . vrai ou faux selon zoom ou non             .
c . triedr . e   .   1    . 0 : pas de trace du triedre                .
c .        .     .        . 1 : trace du triedre                       .
c . degre  . e   .   1    . degre du maillage                          .
c . sdim   . e   .   1    . dimension du maillage initial              .
c . mailet . e   .   1    . maillage etendu                            .
c . nivsup . e   .   1    . niveau superieur atteint dans le maillage  .
c . titre1 . e   .  char  . premiere ligne de titre                    .
c . titre2 . e   .  char  . seconde ligne de titre                     .
c . nbarvi . e   .   1    . nombre d'aretes visualisables              .
c . nbtrvi . e   .   1    . nombre triangles visualisables             .
c . nbquvi . e   .   1    . nombre de quadrangles visualisables        .
c . nnarvi . e   .6*nbarvi. numero des aretes a visualiser             .
c .        .     .        . 1 : niveau de l'arete a afficher           .
c .        .     .        . 2 : numero HOMARD de l'arete               .
c .        .     .        . 3, 4 : numero des 2 noeuds                 .
c .        .     .        . 5 : 0, si isolee, 1 si bord                .
c .        .     .        . 6 : numero de l'eventuel noeud P2          .
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
c . coopro . e   .    3*  . coordonnees projetees de :                 .
c .        .     .nbnot+12. le triedre : -8:O ; -9:I ; -10:J ; -11:K   .
c .        .     .        . la fenetre de zoom : de -7 a 0 en 3D ou    .
c .        .     .        .                      de -3 a 0 en 2D       .
c .        .     .        . les noeuds de 1 a nbnoto                   .
c . posini . aux . nbquvi . tableau auxiliaire de renumerotation des   .
c .        .     .+nbtrvi . faces en fonction de l'affichage           .
c . nnoeca . e   . renoto . noeuds en entree dans le calcul            .
c . nareca . e   . rearto . nro des aretes dans le calcul en entree    .
c . ntreca . e   . retrto . nro des triangles dans le calcul en entree .
c . nqueca . e   . requto . nro des quads dans le calcul en entree     .
c . fotrva . e   . nbtrvi . fonctions triangles : valeur               .
c . foquva . e   . nbquvi . fonctions quadrangles : valeur             .
c . vafomi . e   .   1    . minimum de l'echelle de la fonction        .
c . vafoma . e   .   1    . maximum de l'echelle de la fonction        .
c . ulvecs . e   .   1    . unite logique du fichier PostScript        .
c . nomflo . e   .   *    . nom local du fichier                       .
c . lnomfl . e   .    1   . longueur du nom local du fichier           .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
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
      parameter ( nompro = 'PPPXMA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "nombno.h"
#include "nomber.h"
#include "infini.h"
c
c 0.3. ==> arguments
c
      character*(*) titre1, titre2
c
      integer infsup, typcof, typcop, typbor, optnoe
      integer porpay, triedr
      integer ulvecs, lnomfl, ulsost
      integer nbarvi, nbtrvi, nbquvi
      integer nnarvi(5,nbarvi)
      integer nntrvi(10,nbtrvi)
      integer nnquvi(12,nbquvi)
      integer posini(nbtrvi+nbquvi)
      integer nnoeca(renoto)
      integer nareca(rearto), ntreca(retrto), nqueca(requto)
      integer degre, sdim, mailet, nivsup
c
      integer codre1, codre2
      integer codre0
c
      logical zoom
c
      double precision coopro(3,-11:nbnoto)
      double precision vafomi, vafoma
      double precision fotrva(*), foquva(*)
      character*(*) nomflo
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer lgtcmx
      parameter ( lgtcmx = 500 )
c
      integer iaux
      integer ncotbl
      integer ptrav1, ptrav2
      integer tbcoli(-3:lgtcmx)
c
      double precision vafodi
c
      character*8 ntrav1, ntrav2
      character*17 tbcols(-2:lgtcmx)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c_______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) = '(''Apres pp.ma'',i1,'', codret = '',i4)'
c
      texte(2,10) = '(''After pp.ma'',i1,'', codret = '',i4)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'infsup', infsup
      write (ulsort,90002) 'typcof', typcof
      write (ulsort,90002) 'typcop', typcop
      write (ulsort,90002) 'typbor', typbor
      write (ulsort,90002) 'optnoe', optnoe
      write (ulsort,90002) 'porpay', porpay
      write (ulsort,90002) 'triedr', triedr
#endif
c
      codret = 0
c
c====
c 2. la table de couleurs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. table des couleurs ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PPPMA1', nompro
#endif
      call pppma1 ( typcof,
     >              lgtcmx, tbcols, tbcoli, ncotbl,
     >              nbtrvi, nbquvi,
     >              nntrvi, nnquvi,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) 1, codret
#endif
c
      endif
c
c====
c 3. recherche des extrema de la fonction
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. extrema ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( abs(typcof).eq.6 .or. abs(typcof).eq.8 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PPPMA2', nompro
#endif
        call pppma2 ( vafomi, vafoma,
     >                typcof, nbtrvi, nbquvi,
     >                fotrva, foquva,
     >                ulsost,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) 2, codret
#endif
c
      endif
c
c     remarque : si l'ecart est nul, il faut eviter la division par 0
c                on peut mettre n'importe quelle valeur pour vafodi
c                car elle ne servira pas
      if ( abs(typcof).ge.6 .and. abs(typcof).le.9 ) then
        if ( (vafoma-vafomi).ge.1.d4*zeroma ) then
          vafodi = 1.d0 / ( vafoma - vafomi )
        else
          vafodi = 0.d0
        endif
      endif
c
      endif
c
c====
c 4. recherche de l'ordre d'affichage des faces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. ordre affichage ; codret', codret
      write (ulsort,90002) 'nbtrvi', nbtrvi
      write (ulsort,90002) 'nbquvi', nbquvi
      write (ulsort,90002) 'sdim  ', sdim
#endif
c
      if ( nbtrvi+nbquvi.gt.0 ) then
c
        if ( sdim.eq.3 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 9*(nbtrvi+nbquvi)
          call gmalot ( ntrav1, 'reel    ', iaux, ptrav1, codre1 )
          iaux = nbtrvi+nbquvi
          call gmalot ( ntrav2, 'entier  ', iaux, ptrav2, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
c
          endif
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'PPPMA3', nompro
#endif
        call pppma3 ( nbtrvi, nbquvi,
     >                nntrvi, nnquvi,
     >                coopro,
     >                posini, rmem(ptrav1), imem(ptrav2), nivsup,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) 4, codret
#endif
c
        endif
c
        if ( sdim.eq.3 ) then
c
          if ( codret.eq.0 ) then
c
          call gmlboj ( ntrav1, codre1 )
          call gmlboj ( ntrav2, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
c
          endif
c
        endif
c
      endif
c
c====
c 5. impression du maillage sur fichier
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. impression ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PPXMA5', nompro
#endif
      call ppxma5 ( lgtcmx, tbcoli, ncotbl,
     >              infsup, typcof, typcop, typbor, optnoe,
     >              porpay, zoom, triedr,
     >              degre, sdim, mailet,
     >              titre1, titre2,
     >              nbarvi, nbtrvi, nbquvi,
     >              nnarvi, nntrvi, nnquvi,
     >              coopro, posini,
     >              nnoeca, nareca, ntreca, nqueca,
     >              fotrva, foquva, vafomi, vafoma, vafodi,
     >              ulvecs, nomflo, lnomfl,
     >              ulsost,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) 5, codret
#endif
c
c====
c 6. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) 0, codret
#endif
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
