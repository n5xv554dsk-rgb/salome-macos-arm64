      subroutine cmcham ( lehexa, etahex, indtet, indptp,
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
c                         - par 3 Aretes - phase M
c                                 -              -
c    Remarque : cmchae, cmchag, cmchai, cmchan et cmcham sont des clones
c               cmchan et cmcham sont symetriques
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . etahex . e   .   1    . etat de l'hexaedre                         .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . trifad . e   .(6,0:2) . triangles traces sur les faces decoupees   .
c . cotrvo . e   .(6,0:2) . code des triangles dans les volumes        .
c . triint .  s  .  27    . triangles internes a l'hexaedre            .
c .        .     .        .  1-6 = appuyes sur une arete non decoupee  .
c .        .     .        .   base de face centrale                    .
c .        .     .        .  7-9 = appuyes sur une arete non decoupee  .
c .        .     .        .   non base de face centrale                .
c .        .     .        .  10-21 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee                          .
c .        .     .        .  22-27 = appuyes sur les filles des aretes .
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
      parameter ( nompro = 'CMCHAM' )
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
      integer lehexa, etahex, indtet, indptp
      integer trifad(6,0:2), cotrvo(6,0:2)
      integer triint(27)
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
      integer code
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHxx', nompro
      write (ulsort,1200) indtet+1, indtet+18
 1200 format( '.. tetraedres de',i10,' a',i10)
#endif
c
c 1.2. ==> Le pere des tetraedres et leur famille
c
      nupere = -indptp
      nufami = cfahex(coftfh,famhex(lehexa))
c
c====
c 2. Face 1
c====
c 2.1. ==> tetraedre central
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(1,0), triint(1), triint(11), triint(10),
     >              cotrvo(1,0),         3,          5,          3,
     >              nupere, nufami, indtet )
c
c 2.2. ==> tetraedre du cote du sommet 1
c
      if ( etahex.eq.82 .or. etahex.eq.86 ) then
        code = 3
      else
        code = 5
      endif
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(1,1), triint(3), triint(10), triint(22),
     >              cotrvo(1,1),      code,          3,          5,
     >              nupere, nufami, indtet )
c
c 2.3. ==> tetraedre de l'autre cote
c
      if ( etahex.eq.82 .or. etahex.eq.83 ) then
        code = 3
      else
        code = 5
      endif
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(1,2), triint(8), triint(23), triint(11),
     >              cotrvo(1,2),      code,          3,          5,
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
     >              trifad(2,0), triint(2), triint(12), triint(13),
     >              cotrvo(2,0),         3,          5,          3,
     >              nupere, nufami, indtet )
c
c 3.2. ==> tetraedre du cote du sommet 1
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(2,1), triint(9), triint(22), triint(12),
     >              cotrvo(2,1),         3,          5,          5,
     >              nupere, nufami, indtet )
c
c 3.3. ==> tetraedre de l'autre cote
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(2,2), triint(6), triint(13), triint(23),
     >              cotrvo(2,2),         3,          3,          3,
     >              nupere, nufami, indtet )
c
c====
c 4. Face 3
c====
c 4.1. ==> tetraedre central
c
      if ( etahex.eq.82 .or. etahex.eq.86 ) then
        code = 5
      else
        code = 3
      endif
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(3,0), triint(3), triint(15), triint(14),
     >              cotrvo(3,0),      code,          5,          3,
     >              nupere, nufami, indtet )
c
c 4.2. ==> tetraedre du cote du sommet 1
c
      if ( etahex.eq.82 .or. etahex.eq.83 ) then
        code = 3
      else
        code = 5
      endif
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(3,1), triint(5),  triint(14), triint(24),
     >              cotrvo(3,1),         3,          3,       code,
     >              nupere, nufami, indtet )
c
c 4.3. ==> tetraedre de l'autre cote
c
      if ( etahex.eq.82 .or. etahex.eq.83 ) then
        code = 5
      else
        code = 3
      endif
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(3,2), triint(9), triint(25), triint(15),
     >              cotrvo(3,2),         5,       code,          5,
     >              nupere, nufami, indtet )
c
c====
c 5. Face 4
c====
c 5.1. ==> tetraedre central
c
      if ( etahex.eq.82 .or. etahex.eq.86 ) then
        code = 5
      else
        code = 3
      endif
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(4,0), triint(4), triint(16), triint(17),
     >              cotrvo(4,0),      code,          5,          3,
     >              nupere, nufami, indtet )
c
c 5.2. ==> tetraedre du cote du sommet 1
c
      if ( etahex.eq.82 .or. etahex.eq.83 ) then
        code = 3
      else
        code = 5
      endif
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(4,1), triint(7), triint(24), triint(16),
     >              cotrvo(4,1),         3,       code,          5,
     >              nupere, nufami, indtet )
c
c 5.3. ==> tetraedre de l'autre cote
c
      if ( etahex.eq.82 .or. etahex.eq.83 ) then
        code = 5
      else
        code = 3
      endif
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(4,2), triint(2), triint(17), triint(25),
     >              cotrvo(4,2),         5,          3,       code,
     >              nupere, nufami, indtet )
c
c====
c 6. Face 5
c====
c 6.1. ==> tetraedre central
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(5,0), triint(5), triint(19), triint(18),
     >              cotrvo(5,0),         5,          5,          3,
     >              nupere, nufami, indtet )
c
c 6.2. ==> tetraedre du cote du sommet 1
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(5,1), triint(1), triint(18), triint(26),
     >              cotrvo(5,1),         5,          3,          5,
     >              nupere, nufami, indtet )
c
c 6.3. ==> tetraedre de l'autre cote
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(5,2), triint(7), triint(27), triint(19),
     >              cotrvo(5,2),         5,          3,          5,
     >              nupere, nufami, indtet )
c
c====
c 7. Face 6
c====
c 7.1. ==> tetraedre central
c
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(6,0), triint(6), triint(20), triint(21),
     >              cotrvo(6,0),         5,          5,          3,
     >              nupere, nufami, indtet )
c
c 7.2. ==> tetraedre du cote du sommet 1
c
      if ( etahex.eq.82 .or. etahex.eq.83 ) then
        code = 5
      else
        code = 3
      endif
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(6,1), triint(8), triint(26), triint(20),
     >              cotrvo(6,1),      code,          5,          5,
     >              nupere, nufami, indtet )
c
c 7.3. ==> tetraedre de l'autre cote
c
      if ( etahex.eq.82 .or. etahex.eq.86 ) then
        code = 3
      else
        code = 5
      endif
      indtet = indtet + 1
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(6,2), triint(4), triint(21), triint(27),
     >              cotrvo(6,2),      code,          3,          3,
     >              nupere, nufami, indtet )
c
#ifdef _DEBUG_HOMARD_
      do 2222 , iaux = indtet-17, indtet
      write(ulsort,1789) iaux, (tritet(iaux,code),code=1,4),
     > (cotrte(iaux,code),code=1,4)
 2222 continue
 1789 format('tetraedre ',i6,' : ',4i6,4i2)
#endif
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
