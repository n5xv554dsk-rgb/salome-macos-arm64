      subroutine cmcpya ( arepyr, fampyr,
     >                    hetpyr, filpyr, perpyr,
     >                    naret1, naret2, naret3, naret4,
     >                    naret5, naret6, naret7, naret8,
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
c    Creation du Maillage - Creation d'une PYramide par ses Aretes
c    -           -          -              --               -
c ______________________________________________________________________
c
c but : creation effective d'une pyramide etant donne :
c       - le numero de la pyramide
c       - les numeros globaux des aretes
c       - le numero du pere
c       - la famille a attribuer
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . arepyr . es  .provya*8. numeros des aretes des pyramides           .
c . fampyr . es  . nouvpy . famille des pyramides                      .
c . hetpyr . es  . nouvpy . historique de l'etat des pyramides         .
c . filpyr . es  . nouvpy . premier fils des pyramides                 .
c . perpyr . es  . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . nareti . e   . 1      . arete de numero local i dans la pyramide   .
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
      integer arepyr(provya,8), fampyr(nouvpy)
      integer hetpyr(nouvpy), filpyr(nouvpy), perpyr(nouvpy)
      integer naret1, naret2, naret3, naret4
      integer naret5, naret6, naret7, naret8
      integer nupere, famill, nupyra
c
c 0.4. ==> variables locales
c
      integer iaux
c ______________________________________________________________________
c
#include "impr03.h"
c
c====
c 1. creation effective d'une pyramide
c====
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'nupyra', nupyra
      write (*,90002) 'nouvya', nouvya
      write (*,90002) 'nouvyf', nouvyf
      write (*,90015) 'Pyramide', nupyra,
     >                ', aretes', naret1, naret2, naret3, naret4,
     >                            naret5, naret6, naret7, naret8
#endif
c
      iaux = nupyra - nouvyf
      arepyr(iaux,1) = naret1
      arepyr(iaux,2) = naret2
      arepyr(iaux,3) = naret3
      arepyr(iaux,4) = naret4
      arepyr(iaux,5) = naret5
      arepyr(iaux,6) = naret6
      arepyr(iaux,7) = naret7
      arepyr(iaux,8) = naret8
c
      fampyr(nupyra) = famill
c
      hetpyr(nupyra) = 5500
      filpyr(nupyra) = 0
      perpyr(nupyra) = nupere
c
      end
