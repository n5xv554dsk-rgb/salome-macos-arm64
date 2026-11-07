      subroutine utvpyr ( lapyra, volume,
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
c     UTilitaire : Volume d'une PYRamide
c     --           -            ---
c ______________________________________________________________________
c
c     . Jacobien normalise
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lapyra . e   .  1     . numero de la pyramide a examiner           .
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
      double precision volume
      double precision coonoe(nbnoto,3)
c
      integer lapyra
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
c 0.4. ==> variables locales
c
      integer listar(8), listso(5)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
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
      end
