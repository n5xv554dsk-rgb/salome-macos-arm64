      subroutine utqqu0 ( qualit, surf, sdim, coonoe )
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
c     UTilitaire : Qualite d'un QUadrangle - phase 0
c     --           -            --                 -
c ______________________________________________________________________
c
c    on utilise le critere decrit dans
c     'Pascal Jean Frey, Paul-Louis George'
c     'Maillages - applications aux elements finis, Hermes, 1999'
c
c     Chapitre 8 'Optimisation des maillages', page 610
c
c                                           hmax * hs
c    le critere de qualite, q, vaut alpha * ---------
c                                             Smin
c    hmax est la plus grande longueur entre les 4 cotes et les
c    2 diagonales
c    hs est la moyenne quadratique des longueur des cotes
c    Smin est la plus petite des surfaces des 4 triangles que l'on
c    peut tracer dans le quadrangle
c    alpha est un coefficient de normalisation pour que le critere q
c    vaille 1 pour un carre ==> alpha = racine(2)/8
c
c    pour tout autre quadrangle, le critere est donc superieur a 1
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . qualit .  s  .  1     . qualite                                    .
c . surf   .  s  .  1     . surface                                    .
c . sdim   . e   .  1     . dimension du probleme                      .
c . coonoe . e   . 4*sdim . coordonnees des 4 noeuds du quadrangle     .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTQQU0' )
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer sdim
      double precision qualit, surf, coonoe(4,sdim)
c
c 0.4. ==> variables locales
c
      double precision daux1, daux2, daux3, daux4
      double precision v1(3), v2(3), vdiag(3), vn(3)
      double precision lgar(6)
      double precision alpha
c
      logical prem
c
#include "fracta.h"
#include "fractc.h"
c
c 0.5. ==> initialisations
c
      data prem / .true. /
c ______________________________________________________________________
c    Pour calculer la surface, on coupe le quadrangle en deux triangles
c    On rappelle que la surface d'un triangle est egale a la moitie de
c    la norme du produit vectoriel de deux des vecteurs representant
c    ses aretes.
c
c====
c 1. le coefficient normalisateur
c====
c
      if ( prem ) then
        alpha = sqrt(2.d0)*unsqu
        prem = .false.
      endif
c
c====
c 2. calculs des surfaces triangles inscrits
c====
c
c 2.1. ==> en coupant selon la premiere diagonale
c           v1 : arete a1
c           v2 : arete a4
c           vdiag = diagonale(4-2)
c
c                          4  a4  3
c                          ._______.
c                          ..      .
c                          . .     .
c                        a1.  .    .a3
c                          .   .   .
c                          .    .  .
c                          .     . .
c                          .      ..
c                          ._______.
c                          1   a2  2
c
c       daux1 = double de la surface de (a1,a2,diagonale)
c       daux2 = double de la surface de (a4,a3,diagonale)
c
      if ( sdim.eq.2 ) then
c
        v1(1)    = coonoe(1,1) - coonoe(4,1)
        v1(2)    = coonoe(1,2) - coonoe(4,2)
c
        v2(1)    = coonoe(3,1) - coonoe(4,1)
        v2(2)    = coonoe(3,2) - coonoe(4,2)
c
        vdiag(1) = coonoe(2,1) - coonoe(4,1)
        vdiag(2) = coonoe(2,2) - coonoe(4,2)
c
        daux1 = abs ( v1(1)*vdiag(2) - v1(2)*vdiag(1) )
c
        daux2 = abs ( v2(1)*vdiag(2) - v2(2)*vdiag(1) )
c
        lgar(1) =    v1(1)*v1(1)    +    v1(2)*v1(2)
        lgar(4) =    v2(1)*v2(1)    +    v2(2)*v2(2)
        lgar(5) = vdiag(1)*vdiag(1) + vdiag(2)*vdiag(2)
c
      else
c
        v1(1)    = coonoe(1,1) - coonoe(4,1)
        v1(2)    = coonoe(1,2) - coonoe(4,2)
        v1(3)    = coonoe(1,3) - coonoe(4,3)
c
        v2(1)    = coonoe(3,1) - coonoe(4,1)
        v2(2)    = coonoe(3,2) - coonoe(4,2)
        v2(3)    = coonoe(3,3) - coonoe(4,3)
c
        vdiag(1) = coonoe(2,1) - coonoe(4,1)
        vdiag(2) = coonoe(2,2) - coonoe(4,2)
        vdiag(3) = coonoe(2,3) - coonoe(4,3)
c
        vn(1) = v1(2)*vdiag(3) - v1(3)*vdiag(2)
        vn(2) = v1(3)*vdiag(1) - v1(1)*vdiag(3)
        vn(3) = v1(1)*vdiag(2) - v1(2)*vdiag(1)
c
        daux1 = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
        vn(1) = v2(2)*vdiag(3) - v2(3)*vdiag(2)
        vn(2) = v2(3)*vdiag(1) - v2(1)*vdiag(3)
        vn(3) = v2(1)*vdiag(2) - v2(2)*vdiag(1)
c
        daux2 = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
        lgar(1) =    v1(1)*v1(1)    +    v1(2)*v1(2)    +    v1(3)*v1(3)
        lgar(4) =    v2(1)*v2(1)    +    v2(2)*v2(2)    +    v2(3)*v2(3)
        lgar(5) =
     >         vdiag(1)*vdiag(1) + vdiag(2)*vdiag(2) + vdiag(3)*vdiag(3)
c
      endif
c
c 2.2. ==> en coupant selon la seconde diagonale
c           v1 : arete a1
c           v2 : arete a2
c           vdiag = diagonale(1-3)
c
c                          4  a4  3
c                          .______.
c                          .     ..
c                          .    . .
c                        a1.   .  .a3
c                          .  .   .
c                          . .    .
c                          ..     .
c                          .______.
c                          1   a2  2
c
c       daux3 = double de la surface de (a1,a4,diagonale)
c       daux4 = double de la surface de (a2,a3,diagonale)
c
      if ( sdim.eq.2 ) then
c
        v2(1)    = coonoe(2,1) - coonoe(1,1)
        v2(2)    = coonoe(2,2) - coonoe(1,2)
c
        vdiag(1) = coonoe(3,1) - coonoe(1,1)
        vdiag(2) = coonoe(3,2) - coonoe(1,2)
c
        daux3 = abs ( v1(1)*vdiag(2) - v1(2)*vdiag(1) )
c
        daux4 = abs ( v2(1)*vdiag(2) - v2(2)*vdiag(1) )
c
        lgar(2) =    v2(1)*v2(1)    +    v2(2)*v2(2)
        lgar(6) = vdiag(1)*vdiag(1) + vdiag(2)*vdiag(2)
c
      else
c
        v2(1)    = coonoe(2,1) - coonoe(1,1)
        v2(2)    = coonoe(2,2) - coonoe(1,2)
        v2(3)    = coonoe(2,3) - coonoe(1,3)
c
        vdiag(1) = coonoe(3,1) - coonoe(1,1)
        vdiag(2) = coonoe(3,2) - coonoe(1,2)
        vdiag(3) = coonoe(3,3) - coonoe(1,3)
c
        vn(1) = v1(2)*vdiag(3) - v1(3)*vdiag(2)
        vn(2) = v1(3)*vdiag(1) - v1(1)*vdiag(3)
        vn(3) = v1(1)*vdiag(2) - v1(2)*vdiag(1)
c
        daux3 = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
        vn(1) = v2(2)*vdiag(3) - v2(3)*vdiag(2)
        vn(2) = v2(3)*vdiag(1) - v2(1)*vdiag(3)
        vn(3) = v2(1)*vdiag(2) - v2(2)*vdiag(1)
c
        daux4 = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
        lgar(2) =    v2(1)*v2(1) +    v2(2)*v2(2)    +    v2(3)*v2(3)
        lgar(6) =
     >         vdiag(1)*vdiag(1) + vdiag(2)*vdiag(2) + vdiag(3)*vdiag(3)
c
      endif
c
c====
c 3. surface : la somme des surfaces des 2 triangles
c====
c
      surf = unsde * ( daux1 + daux2 )
c
c====
c 4. qualite
c====
c
c 4.1. ==> surface minimale des triangles (le double)
c
      daux1 = min ( daux1, daux2, daux3, daux4 )
c
c 4.2. ==> carre de la longueur de l'arete a3
c
      if ( sdim.eq.2 ) then
c
        v1(1) = coonoe(3,1) - coonoe(2,1)
        v1(2) = coonoe(3,2) - coonoe(2,2)
c
        lgar(3) = v1(1)*v1(1) + v1(2)*v1(2)
c
      else
c
        v1(1) = coonoe(3,1) - coonoe(2,1)
        v1(2) = coonoe(3,2) - coonoe(2,2)
        v1(3) = coonoe(3,3) - coonoe(2,3)
c
        lgar(3) = v1(1)*v1(1) + v1(2)*v1(2) + v1(3)*v1(3)
c
      endif
c
c 4.3. ==> moyenne quadratique des longueurs des cotes
c
      daux2 = sqrt ( lgar(1) + lgar(2) + lgar(3) + lgar(4) )
c
c 4.4. ==> plus grande valeur des longueurs (cotes et diagonales)
c
      daux3 = max ( lgar(1), lgar(2), lgar(3), lgar(4),
     >              lgar(5), lgar(6) )
      daux3 = sqrt(daux3)
c
c 4.5. ==> qualite
c
      qualit = alpha * daux3 * daux2 / daux1
c
      end
