      subroutine utinca
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
c    UTilitaire - INitialisation des Constantes de l'Adaptation
c    --           --                 -               -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
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
c 0.2. ==> communs
c
#include "permut.h"
#include "cofhex.h"
#include "cofpen.h"
c
c 0.3. ==> arguments
c
c 0.4. ==> variables locales
c
c====
c 1. permutations des codes des faces dans les tetraedres
c====
c
      perm1(1) = 4
      perm1(2) = 5
      perm1(3) = 6
      perm1(4) = 1
      perm1(5) = 2
      perm1(6) = 3
c
      perm2(1) = 5
      perm2(2) = 6
      perm2(3) = 4
      perm2(4) = 3
      perm2(5) = 1
      perm2(6) = 2
c
      perm3(1) = 6
      perm3(2) = 4
      perm3(3) = 5
      perm3(4) = 2
      perm3(5) = 3
      perm3(6) = 1
c
c===
c 2. codes des faces creees dans le raffinement standard d'un hexaedre
c    suivant le code de la mere
c===
c
      cofh18(1)=1
      cofh18(2)=1
      cofh18(3)=1
      cofh18(4)=1
      cofh18(5)=8
      cofh18(6)=8
      cofh18(7)=8
      cofh18(8)=8

      cofh25(1)=2
      cofh25(2)=2
      cofh25(3)=2
      cofh25(4)=2
      cofh25(5)=5
      cofh25(6)=5
      cofh25(7)=5
      cofh25(8)=5

      cofh36(1)=3
      cofh36(2)=3
      cofh36(3)=3
      cofh36(4)=3
      cofh36(5)=6
      cofh36(6)=6
      cofh36(7)=6
      cofh36(8)=6
c
      cofh47(1)=4
      cofh47(2)=4
      cofh47(3)=4
      cofh47(4)=4
      cofh47(5)=7
      cofh47(6)=7
      cofh47(7)=7
      cofh47(8)=7
c
c===
c 3. codes des faces creees dans le raffinement standard d'un pentaedre
c    suivant le code de la mere
c===
c
      cofp08(1,0) = 1
      cofp08(2,0) = 2
      cofp08(3,0) = 3
      cofp08(4,0) = 4
      cofp08(5,0) = 5
      cofp08(6,0) = 6
      cofp08(7,0) = 7
      cofp08(8,0) = 8
c
      cofp08(1,1) = 2
      cofp08(2,1) = 3
      cofp08(3,1) = 4
      cofp08(4,1) = 1
      cofp08(5,1) = 8
      cofp08(6,1) = 5
      cofp08(7,1) = 6
      cofp08(8,1) = 7
c
      cofp08(1,2) = 3
      cofp08(2,2) = 4
      cofp08(3,2) = 1
      cofp08(4,2) = 2
      cofp08(5,2) = 7
      cofp08(6,2) = 8
      cofp08(7,2) = 5
      cofp08(8,2) = 6
c
      cofp08(1,3) = 4
      cofp08(2,3) = 1
      cofp08(3,3) = 2
      cofp08(4,3) = 3
      cofp08(5,3) = 6
      cofp08(6,3) = 7
      cofp08(7,3) = 8
      cofp08(8,3) = 5
c
      end
