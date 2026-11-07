      subroutine utqtet ( letetr, qualit, qualij, volume,
     >                    coonoe, somare, aretri,
     >                    tritet, cotrte, aretet )
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
c     UTilitaire : Qualite d'un TETraedre
c     --           -            ---
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
c    h est le diametre du tetraedre, i.e. son plus grand cote
c    r est le rayon de la sphere inscrite
c    alpha est un coefficient de normalisation pour que le critere q
c    vaille 1 pour un tetraedre regulier ==> alpha = 1/racine(24)
c
c    pour tout autre tetraedre, le critere est donc superieur a 1
c
c                              max(ak) * somme des si
c    tous calculs faits q vaut ----------------------
c                               3 * racine(24) * vol
c
c    ou si est la surface de la i-eme face,
c       ak est la longueur du k-eme cote
c       vol le volume du tetraedre.
c
c Un tetraedre regulier :
c noeud 1
c     x = 0.5d0
c     y = 0.5d0*sqrt(3.0d0)/3.d0
c     z = sqrt(2.0d0/3.0d0)
c noeud 2
c     x = 0.0d0
c     y = 0.0d0
c     z = 0.0d0
c noeud 3
c     x = 1.0d0
c     y = 0.0d0
c     z = 0.0d0
c noeud 4
c     x = 0.5d0
c     y = 0.5d0*sqrt(3.0d0)
c     z = 0.0d0
c
c     . Jacobien normalise
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letetr . e   .  1     . numero du tetraedre a examiner             .
c . qualit .  s  .  1     . qualite                                    .
c . qualij .  s  .  1     . qualite par le jacobien normalise          .
c . volume .  s  .  1     . volume                                     .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
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
#include "fractl.h"
#include "fracte.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
c
c 0.3. ==> arguments
c
      double precision qualit, qualij, volume, coonoe(nbnoto,3)
c
      integer letetr
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer aresom(0:3,4)
      integer listar(6), listso(4)
c
      double precision coosom(3,4)
      double precision sf1, sf2, sf3, sf4, sixvol
      double precision ar1, ar2, ar3, ar4, ar5, ar6
      double precision v1(3), v3(3), v4(3), v6(3), vn(3)
      double precision daux
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les aretes et sommets de ce tetraedre
c====
c
      call utaste ( letetr,
     >              nbtrto, nbtecf, nbteca,
     >              somare, aretri,
     >              tritet, cotrte, aretet,
     >              listar, listso )
c
      do 11 , jaux = 1, 4
        do 111 , iaux = 1, 3
          coosom(iaux,jaux) = coonoe(listso(jaux),iaux)
  111   continue
   11 continue
c
c====
c 2. longueurs des aretes 2 (n1-n3) et 5 (n2-n4)
c====
c
      vn(1) = coosom(1,3) - coosom(1,1)
      vn(2) = coosom(2,3) - coosom(2,1)
      vn(3) = coosom(3,3) - coosom(3,1)
      ar2 = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
      vn(1) = coosom(1,4) - coosom(1,2)
      vn(2) = coosom(2,4) - coosom(2,2)
      vn(3) = coosom(3,4) - coosom(3,2)
      ar5 = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
c====
c 3. memorisation des vecteurs liees aux aretes 1 (n1-n2),
c          3 (n1-n4), 4 (n2-n3) et 6 (n3-n4)
c        et calcul des longueurs de ces aretes
c====
c
      v1(1) = coosom(1,2) - coosom(1,1)
      v1(2) = coosom(2,2) - coosom(2,1)
      v1(3) = coosom(3,2) - coosom(3,1)
      ar1 = sqrt ( v1(1)*v1(1) + v1(2)*v1(2) + v1(3)*v1(3) )
c
      v3(1) = coosom(1,4) - coosom(1,1)
      v3(2) = coosom(2,4) - coosom(2,1)
      v3(3) = coosom(3,4) - coosom(3,1)
      ar3 = sqrt ( v3(1)*v3(1) + v3(2)*v3(2) + v3(3)*v3(3) )
c
      v4(1) = coosom(1,3) - coosom(1,2)
      v4(2) = coosom(2,3) - coosom(2,2)
      v4(3) = coosom(3,3) - coosom(3,2)
      ar4 = sqrt ( v4(1)*v4(1) + v4(2)*v4(2) + v4(3)*v4(3) )
c
      v6(1) = coosom(1,4) - coosom(1,3)
      v6(2) = coosom(2,4) - coosom(2,3)
      v6(3) = coosom(3,4) - coosom(3,3)
      ar6 = sqrt ( v6(1)*v6(1) + v6(2)*v6(2) + v6(3)*v6(3) )
cgn      write(1,*) ar1,ar2,ar3,ar4,ar5,ar6
c
c====
c 4. calcul des 4 surfaces (plutot 2 fois les surfaces)
c           on rappelle que la surface d'un triangle est egale
c           a la moitie de la norme du produit vectoriel de deux
c           des vecteurs representant les aretes.
c====
c
      vn(1) = v6(2)*v4(3) - v6(3)*v4(2)
      vn(2) = v6(3)*v4(1) - v6(1)*v4(3)
      vn(3) = v6(1)*v4(2) - v6(2)*v4(1)
      sf1 = vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3)
c
      vn(1) = v6(2)*v3(3) - v6(3)*v3(2)
      vn(2) = v6(3)*v3(1) - v6(1)*v3(3)
      vn(3) = v6(1)*v3(2) - v6(2)*v3(1)
      sf2 = vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3)
c
      vn(1) = v1(2)*v3(3) - v1(3)*v3(2)
      vn(2) = v1(3)*v3(1) - v1(1)*v3(3)
      vn(3) = v1(1)*v3(2) - v1(2)*v3(1)
      sf3 = vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3)
c
      vn(1) = v1(2)*v4(3) - v1(3)*v4(2)
      vn(2) = v1(3)*v4(1) - v1(1)*v4(3)
      vn(3) = v1(1)*v4(2) - v1(2)*v4(1)
      sf4 = vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3)
cgn      write(1,*) sf1,sf2,sf3,sf4
c
c====
c 5. calcul du volume du tetraedre
c====
c
      call utvot0 ( coosom,  volume )
c
c====
c 6. volume et qualite
c====
c
      sixvol = 6.d0*volume
c
      qualit = sqrt(uns24) * max(ar1,ar2,ar3,ar4,ar5,ar6)
     >     * (sqrt(sf1)+sqrt(sf2)+sqrt(sf3)+sqrt(sf4)) / sixvol
c
c====
c 7. qualite par le jacobien normalise
c====
c 7.1. ==> Liens sommet/aretes
c
      aresom(0,1) = 1
      aresom(1,1) = 1
      aresom(2,1) = 3
      aresom(3,1) = 2
c
      aresom(0,2) = 2
      aresom(1,2) = 5
      aresom(2,2) = 1
      aresom(3,2) = 4
c
      aresom(0,3) = 3
      aresom(1,3) = 4
      aresom(2,3) = 2
      aresom(3,3) = 6
c
      aresom(0,4) = 4
      aresom(1,4) = 6
      aresom(2,4) = 3
      aresom(3,4) = 5
c
c 7.2. ==> fonction generique
c
      iaux = 4
      daux = sqrt(2.d0)/2.d0
      call utqjno (   iaux, aresom,   daux,
     >              listar, listso, somare, coonoe,
     >              qualij )
cgn      write(1,*) '==> qualij : ', qualij
c
      end
