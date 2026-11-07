      subroutine utdtet ( letetr, diamet,
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
c     UTilitaire : Diametre d'un TETraedre
c     --           -             ---
c ______________________________________________________________________
c
c    Le diametre d'une maille est la longueur du plus grand segment que
c    l'on peut tracer a l'interieur de cette maille.
c    Pour un tetraedre, le diametre est la longueur maximale des aretes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letetr . e   .  1     . numero du tetraedre a examiner             .
c . diamet .  s  .  1     . qualite                                    .
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
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
c
c 0.3. ==> arguments
c
      double precision diamet, coonoe(nbnoto,3)
c
      integer letetr
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
c
c 0.4. ==> variables locales
c
      integer listar(6), listso(4)
      integer iaux
c
      double precision ar1, ar2, ar3, ar4, ar5, ar6
      double precision var(3)
cc
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
c====
c 1. les aretes et les sommets de ce tetraedre
c====
c
      call utaste ( letetr,
     >              nbtrto, nbtecf, nbteca,
     >              somare, aretri,
     >              tritet, cotrte, aretet,
     >              listar, listso )
c
c====
c 2. les carres des longueurs des 6 aretes
c====
c
      var(1) = coonoe(listso(2),1) - coonoe(listso(1),1)
      var(2) = coonoe(listso(2),2) - coonoe(listso(1),2)
      var(3) = coonoe(listso(2),3) - coonoe(listso(1),3)
      ar1 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(listso(3),1) - coonoe(listso(1),1)
      var(2) = coonoe(listso(3),2) - coonoe(listso(1),2)
      var(3) = coonoe(listso(3),3) - coonoe(listso(1),3)
      ar2 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(listso(4),1) - coonoe(listso(1),1)
      var(2) = coonoe(listso(4),2) - coonoe(listso(1),2)
      var(3) = coonoe(listso(4),3) - coonoe(listso(1),3)
      ar3 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(listso(3),1) - coonoe(listso(2),1)
      var(2) = coonoe(listso(3),2) - coonoe(listso(2),2)
      var(3) = coonoe(listso(3),3) - coonoe(listso(2),3)
      ar4 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(listso(4),1) - coonoe(listso(2),1)
      var(2) = coonoe(listso(4),2) - coonoe(listso(2),2)
      var(3) = coonoe(listso(4),3) - coonoe(listso(2),3)
      ar5 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(listso(4),1) - coonoe(listso(3),1)
      var(2) = coonoe(listso(4),2) - coonoe(listso(3),2)
      var(3) = coonoe(listso(4),3) - coonoe(listso(3),3)
      ar6 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
c====
c 3. diametre
c    on ne prend la racine carre qu'ici pour economiser du temps calcul
c====
c
      diamet = max ( ar1, ar2, ar3, ar4, ar5, ar6 )
      diamet = sqrt(diamet)
cgn      print *, ar1, ar2, ar3, ar4, ar5, ar6, ' ==> ', diamet
c
      end
