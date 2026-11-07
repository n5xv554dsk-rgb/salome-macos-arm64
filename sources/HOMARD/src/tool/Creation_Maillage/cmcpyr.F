      subroutine cmcpyr ( facpyr, cofapy, fampyr,
     >                    hetpyr, filpyr, perpyr,
     >                    nface1, codef1,
     >                    nface2, codef2,
     >                    nface3, codef3,
     >                    nface4, codef4,
     >                    nface5, codef5,
     >                    nupere, famill, nupyra )
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
c    Creation du Maillage - Creation d'une PYRamide
c    -           -          -              ---
c ______________________________________________________________________
c
c but : creation effective d'une pyramide etant donne :
c       - le numero de la pyramide
c       - les numero globaux des faces locales 1,2,3 et 4
c       - les codes des faces
c       - le numero du pere
c       - la famille a attribuer
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . facpyr . es  .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . es  .nouvyf*5. codes des faces des pyramides              .
c . fampyr . es  . nouvpy . famille des pyramides                      .
c . hetpyr . es  . nouvpy . historique de l'etat des pyramides         .
c . filpyr . es  . nouvpy . premier fils des pyramides                 .
c . perpyr . es  . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . nface1 . e   . 1      . face de numero local 1 dans la pyramide    .
c . nface2 . e   . 1      . face de numero local 2 dans la pyramide    .
c . nface3 . e   . 1      . face de numero local 3 dans la pyramide    .
c . nface4 . e   . 1      . face de numero local 4 dans la pyramide    .
c . nface5 . e   . 1      . face de numero local 5 dans la pyramide    .
c . codef1 . e   . 1      . code de la face 1                          .
c . codef2 . e   . 1      . code de la face 2                          .
c . codef3 . e   . 1      . code de la face 3                          .
c . codef4 . e   . 1      . code de la face 4                          .
c . codef5 . e   . 1      . code de la face 5                          .
c . nupere . e   . 1      . numero du pere de la pyramide              .
c . famill . e   . 1      . famille a attribuer a la pyramide          .
c . nupyra . e   . 1      . numero de la pyramide a creer              .
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
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer facpyr(nouvyf,5), cofapy(nouvyf,5), fampyr(nouvpy)
      integer hetpyr(nouvpy), filpyr(nouvpy), perpyr(nouvpy)
      integer nface1, nface2, nface3, nface4, nface5
      integer codef1, codef2, codef3, codef4, codef5
      integer nupere, famill, nupyra
c
c 0.4. ==> variables locales
c ______________________________________________________________________
c
c====
c 1. creation effective d'une pyramide
c====
#ifdef _DEBUG_HOMARD_
#include "impr03.h"
      write (1,90015) 'Pyramide', nupyra,
     >                ', faces', nface1, nface2, nface3, nface4, nface5
      write (1,90015) 'Pyramide', nupyra,
     >                ', codes', codef1, codef2, codef3, codef4, codef5
#endif
c
      facpyr(nupyra,1) = nface1
      facpyr(nupyra,2) = nface2
      facpyr(nupyra,3) = nface3
      facpyr(nupyra,4) = nface4
      facpyr(nupyra,5) = nface5
c
      cofapy(nupyra,1) = codef1
      cofapy(nupyra,2) = codef2
      cofapy(nupyra,3) = codef3
      cofapy(nupyra,4) = codef4
      cofapy(nupyra,5) = codef5
c
      fampyr(nupyra) = famill
c
      hetpyr(nupyra) = 5500
      filpyr(nupyra) = 0
      perpyr(nupyra) = nupere
c
      end
