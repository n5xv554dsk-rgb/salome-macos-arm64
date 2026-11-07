      subroutine uttpyr ( lapyra, torsio,
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
c     UTilitaire : Torsion d'une PYRamide
c     --           -             ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lapyra . e   .  1     . numero de la pyramide a examiner           .
c . torsio .  s  .  1     . torsion de la pyramide                     .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*4. numeros des 4 aretes des quadrangles       .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
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
#include "nombpy.h"
c
c 0.3. ==> arguments
c
      double precision torsio, coonoe(nbnoto,3)
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
c====
c 2. Traitement
c    La face f5 est le quadrangle.
c    Elle s'appuie sur les sommets s1, s2, s3, s4.
c====
c
      call uttoqu ( listso(1), listso(2), listso(3), listso(4),
     >              coonoe, torsio )
c
      end
