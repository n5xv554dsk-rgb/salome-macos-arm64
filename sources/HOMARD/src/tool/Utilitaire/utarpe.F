      subroutine utarpe ( lepent,
     >                    nbquto, nbpecf,
     >                    arequa, facpen, cofape,
     >                    listar )
c
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
c     UTilitaire : ARetes d'un PEntaedre decrit par ses faces
c     --           --          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .  1     . numero du pentaedre a examiner             .
c . nbquto . e   .  1     . nombre total de quadrangles                .
c . nbpecf . e   .  1     . nombre total de pentaedres                 .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. codes des 5 faces des pentaedres           .
c . listar .  s  .   9    . les 9 aretes du pentaedre                  .
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
#include "j1234j.h"
c
c 0.3. ==> arguments
c
      integer lepent
      integer nbquto, nbpecf
      integer listar(9)
      integer arequa(nbquto,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5)
c
c 0.4. ==> variables locales
c
      integer lafac3, lafac4, lafac5
      integer codfa3, codfa4, codfa5
c
c Sur ce croquis, semblable a la documentation sur les structures de
c donnees, la droite S2-S5 est a l'arriere-plan.
c
c          S3                   a9                     S6
c           x------------------------------------------x
c          .                                          .
c         .  .                                       .  .
c     a3 .                                       a6 .
c       .     .                                    .     .
c      .                                          .
c     .        .a1                               .        .a4
c    .                                          .
c S2.           .       a8                   S5.           .
c  x - - - - - - - - - - - - - - - - - - - - -x
c     .          .                               .          .
c          .                                          .
c        a2    .  .                                 a5    .  .
c                  x------------------------------------------x
c                 S1                   a7                     S4
c   La face f1 est le triangle (S1,S2,S3).
c   La face f2 est le triangle (S4,S6,S5).
c   L'arete a1 est relie les sommets S1 et S3.
c   Les aretes (a1,a2,a3) realisent une rotation entrante dans le
c   pentaedre. L'arete ai+3 est parallele a l'arete ai.
c   La face fi, 3<=i<=5, est le quadrangle s'appuyant sur l'arete ai-2.
c
c remarque : le schema de mmag35 doit etre similaire
c====
c 1. traitement
c====
c
      lafac3 = facpen(lepent,3)
      lafac4 = facpen(lepent,4)
      lafac5 = facpen(lepent,5)
c
      codfa3 = cofape(lepent,3)
      codfa4 = cofape(lepent,4)
      codfa5 = cofape(lepent,5)
c
      listar(1)  = arequa(lafac3,j1(codfa3))
      listar(2)  = arequa(lafac4,j1(codfa4))
      listar(3)  = arequa(lafac5,j1(codfa5))
      listar(4)  = arequa(lafac3,j3(codfa3))
      listar(5)  = arequa(lafac4,j3(codfa4))
      listar(6)  = arequa(lafac5,j3(codfa5))
      listar(7)  = arequa(lafac3,j4(codfa3))
      listar(8)  = arequa(lafac4,j4(codfa4))
      listar(9)  = arequa(lafac5,j4(codfa5))
c
      end
