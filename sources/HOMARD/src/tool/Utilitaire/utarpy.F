      subroutine utarpy ( lapyra,
     >                    nbtrto, nbpycf,
     >                    aretri, facpyr, cofapy,
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
c     UTilitaire : ARetes d'une PYramide decrite par ses faces
c     --           --           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lapyra . e   .  1     . numero de la pyramide a examiner           .
c . nbtrto . e   .  1     . nombre total de triangles                  .
c . nbpycf . e   .  1     . nombre total de pyramides                  .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . listar .  s  .   8    . les 8 aretes de la pyramide                .
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
      integer lapyra
      integer nbtrto, nbpycf
      integer listar(8)
      integer aretri(nbtrto,3)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5)
c
c 0.4. ==> variables locales
c
      integer lafac1, lafac2, lafac3, lafac4
      integer codfa1, codfa2, codfa3, codfa4
c
c 0.5. ==> initialisations
c ______________________________________________________________________
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
c 1. traitement
c====
c
      lafac1 = facpyr(lapyra,1)
      lafac2 = facpyr(lapyra,2)
      lafac3 = facpyr(lapyra,3)
      lafac4 = facpyr(lapyra,4)
c
      codfa1 = cofapy(lapyra,1)
      codfa4 = cofapy(lapyra,4)
      codfa2 = cofapy(lapyra,2)
      codfa3 = cofapy(lapyra,3)
cgn      print 1789, 'triangles ',lafac1, lafac2, lafac3, lafac4
cgn      print 1789, 'codes     ',codfa1, codfa2, codfa3, codfa4
cgn 1789 format(a,5i10)
c
      listar(1)  = aretri(lafac1,i1(codfa1))
      listar(2)  = aretri(lafac1,i2(codfa1))
      listar(3)  = aretri(lafac2,i2(codfa2))
      listar(4)  = aretri(lafac3,i2(codfa3))
      listar(5)  = aretri(lafac1,i3(codfa1))
      listar(6)  = aretri(lafac2,i3(codfa2))
      listar(7)  = aretri(lafac3,i3(codfa3))
      listar(8)  = aretri(lafac4,i2(codfa4))
c
      end
