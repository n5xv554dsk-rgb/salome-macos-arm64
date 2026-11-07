      subroutine cmcp5e ( indtet, indptp,
     >                    lepent,
     >                    trifad, cotrvo, triint,
     >                    facdec, laface, coface,
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
c                         - cas 5, phase E
c                               -        -
c    Construction des tetraedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . lepent . e   .   1    . pentaedre a decouper                       .
c . trifad . e   .(4,0:3) . triangles traces sur les faces decoupees   .
c . cotrvo . e   .(4,0:3) . code des triangles dans les volumes        .
c . triint . e   .  15    . triangles internes au pentaedre            .
c .        .     .        .  1-3 = milieu/milieu et sommet face opposee.
c .        .     .        .  4-6 = milieu/milieu et noeud central      .
c .        .     .        .  7-9 = arete face oppose et noeud central  .
c .        .     .        . 10-15 = appuyes sur une arete interne a    .
c .        .     .        .        une face quadrangulaire coupee      .
c . facdec . e   .   1    . numero local de la face non coupee         .
c . laface . e   .   1    . numero global de la face non coupee        .
c . coface . e   .   1    . futur code de la face dans le tetraedre    .
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
      parameter ( nompro = 'CMCP5E' )
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
#include "ope1a3.h"
#include "coftfp.h"
c
c 0.3. ==> arguments
c
      integer indtet, indptp
      integer lepent
      integer trifad(4,0:3), cotrvo(4,0:3)
      integer triint(15)
      integer facdec, laface, coface
      integer hettet(nouvte), tritet(nouvtf,4), cotrte(nouvtf,4)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer fampen(nouvpe), cfapen(nctfpe,nbfpen)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
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
cgn      write (ulsort,*) 'lepent', lepent
cgn      write (ulsort,*) 'fampen(lepent)', fampen(lepent)
cgn      write (ulsort,*) 'nufami', nufami
c
c====
c 2. Tetraedres sur les triangles de la face coupee, sauf le central
c====
c
      do 21 , iaux = 1 , 3
c
        jaux = per1a3(1,iaux)
c
        indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_123', nompro
#endif
        call cmctet ( tritet, cotrte, famtet,
     >                hettet, filtet, pertet,
     >    triint(iaux), trifad(4,iaux), trifad(jaux,2), trifad(iaux,1),
     >               4, cotrvo(4,iaux), cotrvo(jaux,2), cotrvo(iaux,1),
     >                nupere, nufami, indtet )
c
   21 continue
c
c====
c 3. Tetraedres avec une arete de la face coupee, le sommet oppose,
c    le noeud central
c====
c
      do 31 , iaux = 1 , 3
c
        jaux = per1a3(1,iaux)
c
        indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_456', nompro
#endif
        call cmctet ( tritet, cotrte, famtet,
     >                hettet, filtet, pertet,
     >    triint(iaux), triint(iaux+3), triint(iaux+9), triint(jaux+12),
     >               2,              2,              4,               2,
     >                nupere, nufami, indtet )
c
   31 continue
c
c====
c 4. Tetraedres bases sur le triangle central aux faces quadrangulaires
c====
c
      do 41 , iaux = 1 , 3
c
        indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_789', nompro
#endif
        call cmctet ( tritet, cotrte, famtet,
     >                hettet, filtet, pertet,
     >  trifad(iaux,0), triint(iaux+6), triint(iaux+9), triint(iaux+12),
     >  cotrvo(iaux,0),              2,              2,               4,
     >                nupere, nufami, indtet )
c
   41 continue
c
c====
c 5. Tetraedre sur le triangle central de la face coupee
c====
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_10', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >              trifad(4,0), triint(5), triint(6), triint(4),
     >              cotrvo(4,0),         4,         2,         4,
     >              nupere, nufami, indtet )
c
c====
c 8. Tetraedre sur la face non coupee
c====
c
      indtet = indtet + 1
      if ( facdec.eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_11', nompro
#endif
        call cmctet ( tritet, cotrte, famtet,
     >                hettet, filtet, pertet,
     >                laface, triint(7), triint(9), triint(8),
     >                coface,         4,         2,         4,
     >                nupere, nufami, indtet )
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET_11', nompro
#endif
        call cmctet ( tritet, cotrte, famtet,
     >                hettet, filtet, pertet,
     >                laface, triint(8), triint(7), triint(9),
     >                coface,         4,         2,         4,
     >                nupere, nufami, indtet )
c
      endif
c
c====
c 9. la fin
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
