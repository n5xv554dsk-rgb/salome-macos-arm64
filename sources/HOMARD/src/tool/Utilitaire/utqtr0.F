      subroutine utqtr0 ( qualit, surf, sdim, coonoe )
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
c     UTilitaire : Qualite d'un TRiangle - phase 0
c     --           -            --               -
c ______________________________________________________________________
c
c    on utilise le critere decrit dans
c     'Maillages, applications aux elements finis'
c     Pascal Jean Frey, Paul-Louis George
c     Hermes, 1999
c     Chapitre 18.2, page 606
c                                           h
c    le critere de qualite, q, vaut alpha * -
c                                           r
c    h est le diametre du triangle, i.e. son plus grand cote
c    r est le rayon du cercle inscrit
c    alpha est un coefficient de normalisation pour que le critere q
c    vaille 1 pour un triangle equilateral ==> alpha = 1/racine(12)
c
c    pour tout autre triangle, le critere est donc superieur a 1
c
c                              max(ak) * somme des ak
c    tous calculs faits q vaut ----------------------
c                               racine(48) * surface
c
c    ou si est la surface du i-eme triangle,
c       ak est la longueur du k-eme cote
c       surface est la surface du triangle.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . qualit .  s  .  1     . qualite                                    .
c . surf   .  s  .  1     . surface                                    .
c . sdim   . e   .  1     . dimension du probleme                      .
c . coonoe . e   . 3*sdim . coordonnees des 3 noeuds du triangle       .
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
      parameter ( nompro = 'UTQTR0' )
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer sdim
      double precision qualit, surf, coonoe(3,sdim)
c
c 0.4. ==> variables locales
c
      double precision ar1, ar2, ar3
      double precision v1(3), v2(3), v3(3)
      double precision alpha
c
      logical prem
c
#include "fract0.h"
#include "fracta.h"
c
c 0.5. ==> initialisations
c
      data prem / .true. /
c ______________________________________________________________________
c
c====
c 1. le coefficient normalisateur
c====
c
      if ( prem ) then
        alpha = sqrt(unsdz)
        prem = .false.
      endif
c
c====
c 2. les diverses longueurs et la surface
c====
c
c 2.1. ==> en dimension 2
c
      if ( sdim.eq.2 ) then
c
c 2.1.1. ==> calcul des longueurs des aretes
c
        v1(1) = coonoe(2,1) - coonoe(1,1)
        v1(2) = coonoe(2,2) - coonoe(1,2)
        ar1 = sqrt ( v1(1)*v1(1) + v1(2)*v1(2) )
c
        v2(1) = coonoe(3,1) - coonoe(2,1)
        v2(2) = coonoe(3,2) - coonoe(2,2)
        ar2 = sqrt ( v2(1)*v2(1) + v2(2)*v2(2) )
c
        v3(1) = coonoe(1,1) - coonoe(3,1)
        v3(2) = coonoe(1,2) - coonoe(3,2)
        ar3 = sqrt ( v3(1)*v3(1) + v3(2)*v3(2) )
c
c 2.1.2. ==> calcul de la surface (plutot 2 fois la surface)
c            on rappelle que la surface d'un triangle est egale
c            a la moitie de la norme du produit vectoriel de deux
c            des vecteurs representant les aretes.
c
        surf = abs ( v1(1)*v3(2) - v1(2)*v3(1) )
c
c 2.2. ==> en dimension 3
c
      else
c
c 2.2.1. ==> calcul des longueurs des aretes
c
        v1(1) = coonoe(2,1) - coonoe(1,1)
        v1(2) = coonoe(2,2) - coonoe(1,2)
        v1(3) = coonoe(2,3) - coonoe(1,3)
        ar1 = sqrt ( v1(1)*v1(1) + v1(2)*v1(2) + v1(3)*v1(3) )
c
        v2(1) = coonoe(3,1) - coonoe(2,1)
        v2(2) = coonoe(3,2) - coonoe(2,2)
        v2(3) = coonoe(3,3) - coonoe(2,3)
        ar2 = sqrt ( v2(1)*v2(1) + v2(2)*v2(2) + v2(3)*v2(3) )
c
        v3(1) = coonoe(1,1) - coonoe(3,1)
        v3(2) = coonoe(1,2) - coonoe(3,2)
        v3(3) = coonoe(1,3) - coonoe(3,3)
        ar3 = sqrt ( v3(1)*v3(1) + v3(2)*v3(2) + v3(3)*v3(3) )
c
c 2.2.2. ==> calcul de la surface (plutot 2 fois la surface)
c            on rappelle que la surface d'un triangle est egale
c            a la moitie de la norme du produit vectoriel de deux
c            des vecteurs representant les aretes.
c
        v2(1) = v1(2)*v3(3) - v1(3)*v3(2)
        v2(2) = v1(3)*v3(1) - v1(1)*v3(3)
        v2(3) = v1(1)*v3(2) - v1(2)*v3(1)
        surf = sqrt ( v2(1)*v2(1) + v2(2)*v2(2) + v2(3)*v2(3) )
c
      endif
c
c====
c 3. qualite et surface
c====
c
      qualit = alpha * max(ar1,ar2,ar3) * (ar1+ar2+ar3) / surf
c
      surf = unsde * surf
c
      end
