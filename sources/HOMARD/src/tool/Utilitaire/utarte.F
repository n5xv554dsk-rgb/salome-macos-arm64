      subroutine utarte ( letetr,
     >                    nbtrto, nbtecf,
     >                    aretri, tritet, cotrte,
     >                    listar )
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
c     UTilitaire : ARetes d'un TEtraedre decrit par ses faces
c     --           --          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letetr . e   .  1     . numero du tetraedre a examiner             .
c . nbtrto . e   .  1     . nombre total de triangles                  .
c . nbtecf . e   .  1     . nombre total de tetraedres decrits par face.
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. codes des 4 triangles des tetraedres       .
c . listar .  s  .   6    . les 6 aretes du tetraedre                  .
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
#include "i1i2i3.h"
c
c 0.3. ==> arguments
c
      integer letetr
      integer nbtrto, nbtecf
      integer listar(6)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
c
c 0.4. ==> variables locales
c
      integer lafac1, lafac3, lafac4
      integer codfa1, codfa3, codfa4
c
c====
c 1. traitement
c====
c
c                                    la face fi est opposee au sommet ni
c                     n1
c                     *
c                    .  ..
c                   .     . . a3
c                  .        .  .
c                 .           .   .
c             a1 .          a2  .    .  n4
c               .                 .    *
c              .                  . .   .
c             .        a5    .        .  . a6
c            .          .               . .
c           .      .                      ..
c          .  .                             .
c         *..................................*
c       n2               a4                  n3
c
c    . Les noeuds (1,2,3) definissent un triangle a orientation
c      vers l'exterieur
c     Avec le code 1, les faces sont :
c     Face 1 : aretes 4, 5, 6 (sortante)
c     Face 2 : aretes 2, 3, 6 (entrante)
c     Face 3 : aretes 1, 3, 5 (sortante)
c     Face 4 : aretes 1, 2, 4 (entrante)
c
      lafac1 = tritet(letetr,1)
      lafac3 = tritet(letetr,3)
      lafac4 = tritet(letetr,4)
c
      codfa1 = cotrte(letetr,1)
      codfa3 = cotrte(letetr,3)
      codfa4 = cotrte(letetr,4)
c
      listar(1) = aretri(lafac4,i1(codfa4))
      listar(2) = aretri(lafac4,i2(codfa4))
      listar(3) = aretri(lafac3,i2(codfa3))
      listar(4) = aretri(lafac1,i1(codfa1))
      listar(5) = aretri(lafac1,i2(codfa1))
      listar(6) = aretri(lafac1,i3(codfa1))
c
      end
