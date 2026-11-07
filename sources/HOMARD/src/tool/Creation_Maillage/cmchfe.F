      subroutine cmchfe ( indtet, indptp,
     >                    tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    trifad, cotrvo, triint, trigpy,
     >                    nufami )
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
c                         - par 1 Face - utilitaire E
c                                 -                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . es  .nouvtf*4. code des 4 triangles des tetraedres        .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . trifad . e   . (4,0:2). triangles sur les faces coupees en 3       .
c . cotrvo . e   . (4,0:2). code de ces triangles dans les pyramides   .
c . triint . e   .  (4,2) . triangles internes a l'hexaedre            .
c . trigpy . e   .   4    . triangle de la grande pyramide             .
c . nufami . e   . 1      . famille a attribuer au tetraedre           .
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
cgn      parameter ( nompro = 'CMCHFE' )
c
c 0.2. ==> communs
c
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer indtet, indptp
      integer tritet(nouvtf,4), cotrte(nouvtf,4), famtet(nouvte)
      integer hettet(nouvte), filtet(nouvte), pertet(nouvte)
      integer trifad(4,0:2), cotrvo(4,0:2)
      integer triint(4,2)
      integer trigpy(4)
      integer nufami
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
c 2. les 4 tetraedres internes au decoupage selon une face d'hexaedre
c    le tetraedre p est entre les pyramides p et p+1
c====
c
      iaux = -indptp
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(1,0), trigpy(1), triint(1,2), triint(1,1),
     >              cotrvo(1,0),         5,           1,           4,
     >              iaux, nufami, indtet )
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(2,0), trigpy(2), triint(2,2), triint(2,1),
     >              cotrvo(2,0),         5,           1,           4,
     >              iaux, nufami, indtet )
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(3,0), trigpy(3), triint(3,2), triint(3,1),
     >              cotrvo(3,0),         5,           1,           4,
     >              iaux, nufami, indtet )
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(4,0), trigpy(4), triint(4,2), triint(4,1),
     >              cotrvo(4,0),         5,           1,           4,
     >              iaux, nufami, indtet )
c
#ifdef _DEBUG_HOMARD_
      call dmflsh (iaux)
#endif
c
      end
