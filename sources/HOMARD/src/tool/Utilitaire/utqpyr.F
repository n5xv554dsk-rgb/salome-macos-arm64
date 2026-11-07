      subroutine utqpyr ( lapyra, qualit, qualij, volume,
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
c     UTilitaire : Qualite d'une PYRamide
c     --           -             ---
c ______________________________________________________________________
c
c     . Jacobien normalise
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lapyra . e   .  1     . numero de la pyramide a examiner           .
c . qualit .  s  .  1     . qualite non definie                        .
c . qualij .  s  .  1     . qualite par le jacobien normalise          .
c . volume .  s  .  1     . volume                                     .
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
      double precision qualit, qualij, volume
      double precision coonoe(nbnoto,3)
c
      integer lapyra
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer aresom(0:3,8)
      integer listar(8), listso(5)
c
      double precision daux
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
c 1. les aretes et les sommets
c====
c
      call utaspy ( lapyra,
     >              nbtrto, nbpycf, nbpyca,
     >              somare, aretri,
     >              facpyr, cofapy, arepyr,
     >              listar, listso )
c
c====
c 2. volume
c====
c
      call utvopy ( coonoe, listso, volume )
c
c====
c 3. qualite bidon
c====
c
      qualit = -1789.d0
c
c====
c 4. qualite par le jacobien normalise
c====
c 4.1. ==> Liens sommet/aretes
c
      aresom(0,1) = 1
      aresom(1,1) = 5
      aresom(2,1) = 8
      aresom(3,1) = 1
c
      aresom(0,2) = 2
      aresom(1,2) = 6
      aresom(2,2) = 5
      aresom(3,2) = 2
c
      aresom(0,3) = 3
      aresom(1,3) = 7
      aresom(2,3) = 6
      aresom(3,3) = 3
c
      aresom(0,4) = 4
      aresom(1,4) = 8
      aresom(2,4) = 7
      aresom(3,4) = 4
c
      aresom(0,5) = 5
      aresom(1,5) = 2
      aresom(2,5) = 1
      aresom(3,5) = 4
c
      aresom(0,6) = 5
      aresom(1,6) = 3
      aresom(2,6) = 2
      aresom(3,6) = 1
c
      aresom(0,7) = 5
      aresom(1,7) = 4
      aresom(2,7) = 3
      aresom(3,7) = 2
c
      aresom(0,8) = 5
      aresom(1,8) = 1
      aresom(2,8) = 4
      aresom(3,8) = 3
c
c 4.2. ==> fonction generique
c
      iaux = 8
      daux = sqrt(2.d0)/2.d0
      call utqjno (   iaux, aresom,   daux,
     >              listar, listso, somare, coonoe,
     >              qualij )
cgn      write(1,*) '==> qualij : ', qualij
c
      end
