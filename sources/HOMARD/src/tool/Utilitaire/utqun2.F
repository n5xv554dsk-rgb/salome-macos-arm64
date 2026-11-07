      subroutine utqun2 ( dedans,
     >                    v1, v2, v3, v4, vn, typbor )
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
c    UTilitaire - QUadrangle - Noeud - dimension 2
c    --           --           -                 -
c ______________________________________________________________________
c
c teste si le noeud de coordonnees vn est a l'interieur d'un quadrangle
c programme en dimension 2
c
c         Conventions d'orientation :
c
c              4 .--------------------. 3
c                .                    .
c                .                    .
c                .                    .
c              1 .--------------------. 2
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . dedans .  s  . 1      . vrai ou faux selon que le noeud est dedans .
c .        .     .        . ou hors du triangle                        .
c . v1     . e   .   2    . coordonnees du sommet 1 du quadrangle      .
c . v2     . e   .   2    . coordonnees du sommet 2 du quadrangle      .
c . v3     . e   .   2    . coordonnees du sommet 3 du quadrangle      .
c . v4     . e   .   2    . coordonnees du sommet 4 du quadrangle      .
c . vn     . e   .   2    . coordonnees du noeud a tester              .
c . typbor . e   .   1    . 1, si on accepte un noeud sur le bord      .
c .        .     .        . 0, si on rejette un noeud sur le bord      .
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
cgn      character*6 nompro
cgn      parameter ( nompro = 'UTTRN2' )
c
c 0.2. ==> communs
c
#include "precis.h"
c
c 0.3. ==> arguments
c
      integer typbor
c
      double precision v1(2), v2(2), v3(2), v4(2), vn(2)
c
      logical dedans
c
c 0.4. ==> variables locales
c
      double precision pvnoeu, pvtria
      double precision xmax, xmin, ymax, ymin
      double precision prosca
      double precision daux

c 0.5. ==> initialisations
c ______________________________________________________________________
c
c
cgn      print 1789 ,'........ v1 = ',v1
cgn      print 1789 ,'........ v2 = ',v2
cgn      print 1789 ,'........ v3 = ',v3
cgn      print 1789 ,'........ v4 = ',v4
cgn      print 1789 ,'........ vn = ',vn
cgn 1789 format(a,4g14.7)
c====
c 2. controle
c              4 .--------------------. 3
c                .                    .
c                .                    .
c                .                    .
c              1 .--------------------. 2
c====
c
      xmin = min(v1(1),v2(1),v3(1),v4(1))
      xmax = max(v1(1),v2(1),v3(1),v4(1))
      ymin = min(v1(2),v2(2),v3(2),v4(2))
      ymax = max(v1(2),v2(2),v3(2),v4(2))
c
c 2.1. ==> controle elementaire : le noeud doit etre dans le quadrangle
c          enveloppe du quadrangle
c
      if ( vn(1).lt.xmin .or. vn(1).gt.xmax .or.
     >     vn(2).lt.ymin .or. vn(2).gt.ymax ) then
c
        dedans = .false.
c
      else
c
c 2.2. ==> n est-il dans le triangle ?
c          cela est vrai si le noeud et un sommet sont du meme cote
c          de l'arete formee par les deux autres sommets, et cela pour
c          toutes les aretes.
c          on regarde si les produits vectoriels (ab,ac) et (ab,an)
c          sont de meme orientation pour les trois permutations
c          circulaires sur (a,b,c), c'est-a-dire si le produit
c          scalaire des deux produits vectoriels est positif.
c          pour pouvoir pieger les cas ou le noeud est sur une arete, on
c          teste le caractere strictement positif ou positif du produit
c          scalaire, selon la demande.
c
c
        if ( typbor.eq.0 ) then
          daux = 1.d-10
        else
          daux = -epsima
        endif
c
        dedans = .true.
c
c 2.2.1. ==> arete (s1,s2) : comparaison de sn et de s4
c            pvnoeu represente le produit vectoriel s1s2 x s1s4
        pvnoeu = (v2(1)-v1(1)) * (v4(2)-v1(2))
     >         - (v2(2)-v1(2)) * (v4(1)-v1(1))
c            pvtria represente le produit vectoriel s1s2 x s1n.
        pvtria = (v2(1)-v1(1)) * (vn(2)-v1(2))
     >         - (v2(2)-v1(2)) * (vn(1)-v1(1))
c
        prosca = pvtria*pvnoeu + pvtria*pvnoeu + pvtria*pvnoeu
c
cgn      print 1789 ,'........ prosca s1s2 = ',prosca
        if ( prosca.le.daux ) then
          dedans = .false.
          goto 30
        endif
c
c 2.2.2. ==> arete (s2,s3) : comparaison de sn et de s1
c            pvnoeu represente le produit vectoriel s2s3 x s2s1
        pvnoeu = (v3(1)-v2(1)) * (v1(2)-v2(2))
     >         - (v3(2)-v2(2)) * (v1(1)-v2(1))
c            pvtria represente le produit vectoriel s2s3 x s2sn.
        pvtria = (v3(1)-v2(1)) * (vn(2)-v2(2))
     >         - (v3(2)-v2(2)) * (vn(1)-v2(1))
c
        prosca = pvtria*pvnoeu + pvtria*pvnoeu + pvtria*pvnoeu
c
cgn      print 1789 ,'........ prosca s2s3 = ',prosca
        if ( prosca.le.daux ) then
          dedans = .false.
          goto 30
        endif
c
c 2.2.3. ==> arete (s3,s4) : comparaison de sn et de s2
c            pvnoeu represente le produit vectoriel s3s4 x s3s2
        pvnoeu = (v4(1)-v3(1)) * (v2(2)-v3(2))
     >         - (v4(2)-v3(2)) * (v2(1)-v3(1))
c            pvtria represente le produit vectoriel s3s4 x s3n.
        pvtria = (v4(1)-v3(1)) * (vn(2)-v3(2))
     >         - (v4(2)-v3(2)) * (vn(1)-v3(1))
c
        prosca = pvtria*pvnoeu + pvtria*pvnoeu + pvtria*pvnoeu
cgn      print 1789 ,'........ prosca s3s1 = ',prosca
c
        if ( prosca.le.daux ) then
          dedans = .false.
          goto 30
        endif
c
c 2.2.3. ==> arete (s4,s1) : comparaison de sn et de s3
c            pvnoeu represente le produit vectoriel s4s1 x s4s3
        pvnoeu = (v1(1)-v4(1)) * (v3(2)-v4(2))
     >         - (v1(2)-v4(2)) * (v3(1)-v4(1))
c            pvtria represente le produit vectoriel s4s1 x s4n.
        pvtria = (v1(1)-v4(1)) * (vn(2)-v4(2))
     >         - (v1(2)-v4(2)) * (vn(1)-v4(1))
c
        prosca = pvtria*pvnoeu + pvtria*pvnoeu + pvtria*pvnoeu
cgn      print 1789 ,'........ prosca s3s1 = ',prosca
c
        if ( prosca.le.daux ) then
          dedans = .false.
        endif
c
   30   continue
c
      endif
c
      end
