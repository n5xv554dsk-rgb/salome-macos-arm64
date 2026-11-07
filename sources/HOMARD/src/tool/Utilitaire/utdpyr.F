      subroutine utdpyr ( lapyra, diamet,
     >                    coonoe, somare, aretri,
     >                    facpyr, cofapy, arepyr )
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
c     UTilitaire : Diametre d'une PYRamide
c     --           -              ---
c ______________________________________________________________________
c
c    Le diametre d'une maille est la longueur du plus grand segment que
c    l'on peut tracer a l'interieur de cette maille.
c    Pour un pyramide, le diametre est le maximum des longueurs des
c    aretes et des diagonales de la base
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lapyra . e   .  1     . numero de la pyramide a examiner           .
c . diamet .  s  .  1     . qualite                                    .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
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
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombpy.h"
c
c 0.3. ==> arguments
c
      double precision diamet, coonoe(nbnoto,3)
c
      integer lapyra
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
c 0.4. ==> variables locales
c
      integer s1, s2, s3, s4, s5
c
      integer listar(8), listso(5)
      integer iaux
c
      double precision var(3)
      double precision ar1, ar2, ar3, ar4, ar5, ar6
      double precision ar7, ar8
      double precision ad1, ad2
c
c 0.5. ==> initialisations
c
c                            S5
c                            x
c                         . . . .
c                       .  .   .   .
c                     .   .   a4.     .
c                   .    .       .       .
c                 .     .        x .         .
c            a1 .      .     .   S4    .        .a3
c             .       .  .                 .       .
c           .        .                         .      .
c         .      .  .                           a7 .     .
c       .    .a8   .                                   .    .
c     .  .        .                                        .   .
c S1 .           .a2                                           .  .
c  x .         .                                                  .  .
c     a5  .    .                                                      .
c             x--------------------------------------------------------x
c           S2                            a6                          S3
c   La face f5 est le quadrangle.
c   La face fi, i<5, est le triangle s'appuyant sur l'arete ai.
c
c====
c 1. les aretes et les sommets de la pyramide
c====
c
      call utaspy ( lapyra,
     >              nbtrto, nbpycf, nbpyca,
     >              somare, aretri,
     >              facpyr, cofapy, arepyr,
     >              listar, listso )
c
      s1 = listso(1)
      s2 = listso(2)
      s3 = listso(3)
      s4 = listso(4)
      s5 = listso(5)
c
c====
c 2. les carres des longueurs des 8 aretes et des
c    diagonales du quadrangle
c====
c
c 2.1. ==> les aretes
c
      var(1) = coonoe(s5,1) - coonoe(s1,1)
      var(2) = coonoe(s5,2) - coonoe(s1,2)
      var(3) = coonoe(s5,3) - coonoe(s1,3)
      ar1 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s5,1) - coonoe(s2,1)
      var(2) = coonoe(s5,2) - coonoe(s2,2)
      var(3) = coonoe(s5,3) - coonoe(s2,3)
      ar2 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s5,1) - coonoe(s3,1)
      var(2) = coonoe(s5,2) - coonoe(s3,2)
      var(3) = coonoe(s5,3) - coonoe(s3,3)
      ar3 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s5,1) - coonoe(s4,1)
      var(2) = coonoe(s5,2) - coonoe(s4,2)
      var(3) = coonoe(s5,3) - coonoe(s4,3)
      ar4 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s2,1) - coonoe(s1,1)
      var(2) = coonoe(s2,2) - coonoe(s1,2)
      var(3) = coonoe(s2,3) - coonoe(s1,3)
      ar5 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s3,1) - coonoe(s2,1)
      var(2) = coonoe(s3,2) - coonoe(s2,2)
      var(3) = coonoe(s3,3) - coonoe(s2,3)
      ar6 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s4,1) - coonoe(s3,1)
      var(2) = coonoe(s4,2) - coonoe(s3,2)
      var(3) = coonoe(s4,3) - coonoe(s3,3)
      ar7 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s1,1) - coonoe(s4,1)
      var(2) = coonoe(s1,2) - coonoe(s4,2)
      var(3) = coonoe(s1,3) - coonoe(s4,3)
      ar8 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
c 2.2. ==> les diagonales de la base
c
      var(1) = coonoe(s3,1) - coonoe(s1,1)
      var(2) = coonoe(s3,2) - coonoe(s1,2)
      var(3) = coonoe(s3,3) - coonoe(s1,3)
      ad1 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s4,1) - coonoe(s2,1)
      var(2) = coonoe(s4,2) - coonoe(s2,2)
      var(3) = coonoe(s4,3) - coonoe(s2,3)
      ad2 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
c====
c 3. diametre
c    on ne prend la racine carre qu'ici pour economiser du temps calcul
c====
c
      diamet = max( ar1, ar2, ar3,  ar4,  ar5,  ar6,
     >              ar7, ar8, ad1, ad2 )
      diamet = sqrt(diamet)
c
      end
