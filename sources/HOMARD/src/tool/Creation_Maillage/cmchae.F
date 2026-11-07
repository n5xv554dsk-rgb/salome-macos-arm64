      subroutine cmchae ( lehexa, indtet, indptp, tcod,
     >                    trifad, cotrvo, triint,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    famhex, cfahex,
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
c    Creation du Maillage - Conformite - decoupage des Hexaedres
c    -           -          -                          -
c                         - par 2 Aretes en vis-a-vis - phase E
c                                 -                           -
c    Remarque : cmchae, cmchag, cmchai, cmchan et cmcham sont des clones
c               cmchan et cmcham sont symetriques
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . tcod   . e   .   1    . type des codes des triangles dans les      .
c .        .     .        . tetraedres                                 .
c . trifad . e   .(4,0:2) . triangles traces sur les faces decoupees   .
c . cotrvo . e   .(4,0:2) . code des triangles dans les volumes        .
c . triint . e   .  22    . triangles internes a l'hexaedre            .
c .        .     .        .  1-4 = bordant la pyramide 1               .
c .        .     .        .  5-8 = bordant la pyramide 2               .
c .        .     .        .  9-10 = s'appuyant sur les 2 autres aretes .
c .        .     .        .         non decoupees                      .
c .        .     .        .  11-14 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee, du cote de la pyramide 1.
c .        .     .        .  15-18 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee, du cote de la pyramide 2.
c .        .     .        .  19-22 = appuyes sur les filles des aretes .
c .        .     .        .   coupees                                  .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . es  .nouvtf*4. code des 4 triangles des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . famhex . e   . nouvhe . famille des hexaedres                      .
c . cfahex .     . nctfhe. codes des familles des hexaedres            .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
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
      parameter ( nompro = 'CMCHAE' )
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
#include "coftfh.h"
c
c 0.3. ==> arguments
c
      integer lehexa, indtet, indptp, tcod
      integer trifad(4,0:2), cotrvo(4,0:2)
      integer triint(22)
      integer hettet(nouvte), tritet(nouvtf,4), cotrte(nouvtf,4)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nupere, nufami
      integer tb11(2,2), tb12(2,2)
      integer tb21(2,2), tb22(2,2)
      integer tb31(2,2), tb32(2,2)
      integer tb41(2,2), tb42(2,2)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c         tbij contient les codes pour le tetraedre de la face i qui
c              est du cote de la pyramide j
c         tbij(1,tcod) = code du 3-eme triangle
c         tbij(2,tcod) = code du 4-eme triangle
c                   tcod = 1       tcod = 2
c                 (1,1)  (2,1)   (1,2)  (2,2)
      data tb11 /   3,     3,      3,     5  /
      data tb12 /   5,     5,      3,     5  /
      data tb21 /   3,     5,      5,     5  /
      data tb22 /   3,     5,      3,     3  /
      data tb31 /   3,     5,      3,     3  /
      data tb32 /   3,     5,      5,     5  /
      data tb41 /   5,     5,      3,     5  /
      data tb42 /   3,     3,      3,     5  /
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
cgn      print *,tb11(1,tcod),tb11(2,tcod)
cgn      print *,tb12(1,tcod),tb12(2,tcod)
cgn      print *,tb21(1,tcod),tb21(2,tcod)
cgn      print *,tb22(1,tcod),tb22(2,tcod)
cgn      print *,tb31(1,tcod),tb31(2,tcod)
cgn      print *,tb32(1,tcod),tb32(2,tcod)
cgn      print *,tb41(1,tcod),tb41(2,tcod)
cgn      print *,tb42(1,tcod),tb42(2,tcod)
c
c 1.2. ==> Le pere des tetraedres et leur famille
c
      nupere = -indptp
      nufami = cfahex(coftfh,famhex(lehexa))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHxx', nompro
      write (ulsort,1200) indtet+1, indtet+12
 1200 format( '.. tetraedres de',i10,' a',i10)
#endif
c
c====
c 2. Face 1
c====
c 2.1. ==> tetraedre central
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(1,0), triint(10), triint(15), triint(11),
     >              cotrvo(1,0),          3,          5,          3,
     >              nupere, nufami, indtet )
c
c 2.2. ==> tetraedre du cote de la pyramide 1
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(1,1), triint(1),   triint(11),   triint(19),
     >              cotrvo(1,1),         5, tb11(1,tcod), tb11(2,tcod),
     >              nupere, nufami, indtet )
c
c 2.3. ==> tetraedre du cote de la pyramide 2
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(1,2), triint(5),   triint(21),   triint(15),
     >              cotrvo(1,2),         5, tb12(1,tcod), tb12(2,tcod),
     >              nupere, nufami, indtet )
c
c====
c 3. Face 2
c====
c 3.1. ==> tetraedre central
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(2,0), triint( 9), triint(12), triint(16),
     >              cotrvo(2,0),          3,          5,          3,
     >              nupere, nufami, indtet )
c
c 3.2. ==> tetraedre du cote de la pyramide 1
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(2,1), triint(2),   triint(19),   triint(12),
     >              cotrvo(2,1),         5, tb21(1,tcod), tb21(2,tcod),
     >              nupere, nufami, indtet )
c
c 3.3. ==> tetraedre du cote de la pyramide 2
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(2,2), triint(6),   triint(16),   triint(21),
     >              cotrvo(2,2),         5, tb22(1,tcod), tb22(2,tcod),
     >              nupere, nufami, indtet )
c
c====
c 4. Face 3
c====
c 4.1. ==> tetraedre central
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(3,0), triint(9), triint(17), triint(13),
     >              cotrvo(3,0),        5,          5,           3,
     >              nupere, nufami, indtet )
c
c 4.2. ==> tetraedre du cote de la pyramide 1
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(3,1),  triint(3),  triint(13),   triint(20),
     >              cotrvo(3,1),         5, tb31(1,tcod), tb31(2,tcod),
     >              nupere, nufami, indtet )
c
c 4.3. ==> tetraedre du cote de la pyramide 2
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(3,2), triint(7),   triint(22),   triint(17),
     >              cotrvo(3,2),         5, tb32(1,tcod), tb32(2,tcod),
     >              nupere, nufami, indtet )
c
c====
c 5. Face 4
c====
c 5.1. ==> tetraedre central
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(4,0), triint(10), triint(14), triint(18),
     >              cotrvo(4,0),          5,          5,          3,
     >              nupere, nufami, indtet )
c
c 5.2. ==> tetraedre du cote de la pyramide 1
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(4,1), triint(4),   triint(20),   triint(14),
     >              cotrvo(4,1),         5, tb41(1,tcod), tb41(2,tcod),
     >              nupere, nufami, indtet )
c
c 5.3. ==> tetraedre du cote de la pyramide 2
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(4,2), triint(8),   triint(18),   triint(22),
     >              cotrvo(4,2),         5, tb42(1,tcod), tb42(2,tcod),
     >              nupere, nufami, indtet )
c
#ifdef _DEBUG_HOMARD_
      do 2222 , iaux = indtet-11, indtet
      write(ulsort,1789) iaux, (tritet(iaux,tcod),tcod=1,4),
     > (cotrte(iaux,tcod),tcod=1,4)
 2222 continue
 1789 format('tetraedre ',i6,' : ',4i6,4i2)
#endif
c
c====
c 6. la fin
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
