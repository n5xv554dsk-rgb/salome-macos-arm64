      subroutine cmcp3h ( indtet, indptp,
     >                    lepent,
     >                    trifad, cotrvo, triint,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    fampen, cfapen,
     >                    ulsort, langue, codret )
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
c    Creation du Maillage - Conformite - decoupage des Pentaedres
c    -           -          -                          -
c                         - cas 3, phase H
c                               -        -
c    Construction des tetraedres
c    Remarque : cmcp3e et cmcp3h sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . lepent . e   .   1    . pentaedre a decouper                       .
c . trifad . e   .(4,0:2) . triangles traces sur les faces decoupees   .
c . cotrvo . e   .(4,0:2) . code des triangles dans les volumes        .
c . triint . e   .  17    . triangles internes au pentaedre            .
c .        .     .        .  1-4 = bordant la pyramide                 .
c .        .     .        .  5 = bordant la face f1                    .
c .        .     .        .  6 = bordant la face f2                    .
c .        .     .        .  7 = s'appuyant sur la derniere non coupee .
c .        .     .        .  8-11 = appuyes sur les filles des aretes  .
c .        .     .        .   coupees                                  .
c .        .     .        .  12-17 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee                          .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . es  .nouvtf*4. code des 4 triangles des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . fampen . e   . nouvpe . famille des pentaedres                     .
c . cfapen . e   . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : aucune arete ne correspond             .
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
      character*6 nompro
      parameter ( nompro = 'CMCP3H' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nouvnb.h"
#include "coftfp.h"
c
c 0.3. ==> arguments
c
      integer indtet, indptp
      integer lepent
      integer trifad(4,0:2), cotrvo(4,0:2)
      integer triint(17)
      integer hettet(nouvte), tritet(nouvtf,4), cotrte(nouvtf,4)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer fampen(nouvpe), cfapen(nctfpe,nbfpen)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nupere, nufami
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      codret = 0
c
c 1.2. ==> Le pere des tetraedres et leur famille
c
      nupere = -indptp
      nufami = cfapen(coftfp,fampen(lepent))
c
c====
c 2. Face 1
c====
c 2.1. ==> tetraedre du cote de la pyramide
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_1', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(3,0), triint(1), triint(16), triint(8),
     >              cotrvo(3,0),         4,          4,         2,
     >              nupere, nufami, indtet )
c
c 2.1. ==> tetraedre de l'autre cote
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_2', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(3,1), triint(5), triint(9), triint(16),
     >              cotrvo(3,1),         2,         4,         4,
     >              nupere, nufami, indtet )
c
c====
c 3. Face 2
c====
c 3.1. ==> tetraedre du cote de la pyramide
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_3', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(4,0), triint(3), triint(17), triint(10),
     >              cotrvo(4,0),         4,          4,         2,
     >              nupere, nufami, indtet )
c
c 3.1. ==> tetraedre de l'autre cote
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_4', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(4,1), triint(6), triint(11), triint(17),
     >              cotrvo(4,1),         2,          4,         4,
     >              nupere, nufami, indtet )
c
c====
c 4. Face quadrangulaire dont l'arete coupee est sur la face 1
c====
c 4.1. ==> tetraedre central
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_5', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(1,0), triint(6), triint(12), triint(13),
     >              cotrvo(1,0),         4,          4,         2,
     >              nupere, nufami, indtet )
c
c 4.2. ==> tetraedre du cote pyramide
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_6', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(1,1), triint(2), triint(8), triint(12),
     >              cotrvo(1,1),         4,         2,          4,
     >              nupere, nufami, indtet )
c
c 4.3. ==> tetraedre de l'autre cote
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_7', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(1,2), triint(7), triint(13), triint(9),
     >              cotrvo(1,2),         2,          2,         4,
     >              nupere, nufami, indtet )
c
c====
c 5. Face quadrangulaire dont l'arete coupee est sur la face 2
c====
c 5.1. ==> tetraedre central
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_8', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(2,0), triint(5), triint(14), triint(15),
     >              cotrvo(2,0),         4,          4,         2,
     >              nupere, nufami, indtet )
c
c 5.2. ==> tetraedre du cote pyramide
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_9', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(2,1), triint(4), triint(10), triint(14),
     >              cotrvo(2,1),         4,          2,         4,
     >              nupere, nufami, indtet )
c
c 5.3. ==> tetraedre de l'autre cote
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_10', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(2,2), triint(7), triint(15), triint(11),
     >              cotrvo(2,2),         4,          2,          4,
     >              nupere, nufami, indtet )
c
c====
c 8. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
