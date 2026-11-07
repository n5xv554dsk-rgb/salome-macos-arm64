      subroutine cmchfd ( indpyr,
     >                    facpyr, cofapy, fampyr,
     >                    hetpyr, filpyr, perpyr,
     >                    trifad, cotrvo, triint, quabas, cofdec,
     >                    nupere, famill )
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
c    Creation du Maillage - Conformite - decoupage des Hexaedres
c    -           -          -                          -
c                         - par 1 Face - utilitaire D
c                                 -                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . facpyr . es  .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . es  .nouvyf*5. codes des faces des pyramides              .
c . fampyr . es  . nouvpy . famille des pyramides                      .
c . hetpyr . es  . nouvpy . historique de l'etat des pyramides         .
c . filpyr . es  . nouvpy . premier fils des pyramides                 .
c . perpyr . es  . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . trifad . e   . (4,0:2). triangles sur les faces coupees en 3       .
c . cotrvo . e   . (4,0:2). code de ces triangles dans les pyramides   .
c . triint . e   .  (4,2) . triangles internes a l'hexaedre            .
c . quabas . e   .   4    . faces de base des pyramides                .
c . cofdec . e   . 1      . code de la face decoupee dans l'hexaedre   .
c . famill . e   . 1      . famille a attribuer a la pyramide          .
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
cgn      character*6 nompro
cgn      parameter ( nompro = 'CMCHFD' )
c
c 0.2. ==> communs
c
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer indpyr
      integer trifad(4,0:2), cotrvo(4,0:2)
      integer triint(4,2)
      integer quabas(4), cofdec
      integer facpyr(nouvyf,5), cofapy(nouvyf,5), fampyr(nouvpy)
      integer hetpyr(nouvpy), filpyr(nouvpy), perpyr(nouvpy)
      integer nupere, famill
c
c 0.4. ==> variables locales
c
      integer iaux
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
#ifdef _DEBUG_HOMARD_
      call dmflsh (iaux)
#endif
c
c====
c 1. creation des pyramides
c====
c
      iaux = -nupere
c
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trifad(1,1), cotrvo(1,1),
     >               triint(1,1),       3,
     >               triint(4,2),      3,
     >               trifad(4,2), cotrvo(4,2),
     >              quabas(1), cofdec,
     >              iaux,   famill, indpyr )
c
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trifad(2,1), cotrvo(2,1),
     >               triint(2,1),       3,
     >               triint(1,2),      3,
     >              trifad(1,2), cotrvo(1,2),
     >              quabas(2), cofdec,
     >              iaux,   famill, indpyr )
c
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trifad(3,1), cotrvo(3,1),
     >              triint(3,1),       3,
     >              triint(2,2),      3,
     >              trifad(2,2), cotrvo(2,2),
     >              quabas(3),  cofdec,
     >              iaux,   famill, indpyr )
c
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trifad(4,1), cotrvo(4,1),
     >              triint(4,1),      3,
     >              triint(3,2),     3,
     >              trifad(3,2), cotrvo(3,2),
     >              quabas(4), cofdec,
     >              iaux,   famill, indpyr )
c
#ifdef _DEBUG_HOMARD_
      call dmflsh (iaux)
#endif
c
      end
