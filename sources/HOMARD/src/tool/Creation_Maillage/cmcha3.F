      subroutine cmcha3 ( lehexa, etahex,
     >                    indnoe, indare, indtri, indtet,
     >                    indptp,
     >                    coonoe, hetnoe, arenoe,
     >                    famnoe,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    quahex, coquhe,
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
c                         - par 3 Aretes - pilotage
c                               - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . etahex .  s  .    1   . etat final de l'hexaedre                   .
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . famnoe . es  . nouvno . famille des noeuds                         .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare .     . nouvar . famille des aretes                         .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nouvtf*4. code des 4 triangles des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . quahex . e   .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nouvhf*6. codes des 6 quadrangles des hexaedres      .
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
      parameter ( nompro = 'CMCHA3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer lehexa, etahex
      integer indnoe, indare, indtri, indtet
      integer indptp
      integer hetnoe(nouvno), arenoe(nouvno)
      integer famnoe(nouvno)
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer arequa(nouvqu,4)
      integer filqua(nouvqu)
      integer hettet(nouvte), tritet(nouvtf,4), cotrte(nouvtf,4)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
c
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer listar(12), listso(8)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
      write (ulsort,90002) 'indnoe', indnoe
      write (ulsort,90002) 'indare', indare
      write (ulsort,90002) 'indtri', indtri
      write (ulsort,90002) 'indtet', indtet
#endif
c
      texte(1,4) = '(''Aucune paire d''''aretes ne correspond.'')'
c
      texte(2,4) = '(''No couple of edges is good.'')'
c
      codret = 0
c
c====
c 2. Recherche des aretes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARHE', nompro
#endif
      call utarhe ( lehexa,
     >              nouvqu, nouvhe,
     >              arequa, quahex, coquhe,
     >              listar )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSOHE', nompro
#endif
      call utsohe ( somare, listar, listso )
c
c====
c 3. Recherche des 3 aretes decoupees
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'listar(1) = ', listar(1),
     >                   ' de ',somare(1,listar(1)),
     >                   ' a ',somare(2,listar(1))
      write(ulsort,*) 'listar(2) = ', listar(2),
     >                   ' de ',somare(1,listar(2)),
     >                   ' a ',somare(2,listar(2))
      write(ulsort,*) 'listar(3) = ', listar(3),
     >                   ' de ',somare(1,listar(3)),
     >                   ' a ',somare(2,listar(3))
      write(ulsort,*) 'listar(4) = ', listar(4),
     >                   ' de ',somare(1,listar(4)),
     >                   ' a ',somare(2,listar(4))
      write(ulsort,*) 'listar(6) = ', listar(6),
     >                   ' de ',somare(1,listar(6)),
     >                   ' a ',somare(2,listar(6))
      write(ulsort,*) 'listar(11) = ', listar(11),
     >                   ' de ',somare(1,listar(11)),
     >                   ' a ',somare(2,listar(11))
#endif
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> Ce sont les aretes 1, 7 et 11 qui sont coupees
c
      if ( mod(hetare(listar(1)),10).eq.2 .and.
     >     mod(hetare(listar(7)),10).eq.2 .and.
     >     mod(hetare(listar(11)),10).eq.2 ) then
        etahex = 89
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH81', nompro
#endif
        call cmch81 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet,
     >                indptp,
     >                coonoe, hetnoe, arenoe,
     >                famnoe,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.2. ==> Ce sont les aretes 1, 8 et 10 qui sont coupees
c
      elseif ( mod(hetare(listar(1)),10).eq.2 .and.
     >         mod(hetare(listar(8)),10).eq.2 .and.
     >         mod(hetare(listar(10)),10).eq.2 ) then
        etahex = 93
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH82', nompro
#endif
        call cmch82 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet,
     >                indptp,
     >                coonoe, hetnoe, arenoe,
     >                famnoe,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.3. ==> Ce sont les aretes 2, 6 et 12 qui sont coupees
c
      elseif ( mod(hetare(listar(2)),10).eq.2 .and.
     >         mod(hetare(listar(6)),10).eq.2 .and.
     >         mod(hetare(listar(12)),10).eq.2 ) then
        etahex = 94
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH83', nompro
#endif
        call cmch83 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet,
     >                indptp,
     >                coonoe, hetnoe, arenoe,
     >                famnoe,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.4. ==> Ce sont les aretes 2, 8 et 9 qui sont coupees
c
      elseif ( mod(hetare(listar(2)),10).eq.2 .and.
     >         mod(hetare(listar(8)),10).eq.2 .and.
     >         mod(hetare(listar(9)),10).eq.2 ) then
        etahex = 90
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH84', nompro
#endif
        call cmch84 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet,
     >                indptp,
     >                coonoe, hetnoe, arenoe,
     >                famnoe,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.5. ==> Ce sont les aretes 3, 5 et 12 qui sont coupees
c
      elseif ( mod(hetare(listar(3)),10).eq.2 .and.
     >         mod(hetare(listar(5)),10).eq.2 .and.
     >         mod(hetare(listar(12)),10).eq.2 ) then
        etahex = 91
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH85', nompro
#endif
        call cmch85 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet,
     >                indptp,
     >                coonoe, hetnoe, arenoe,
     >                famnoe,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.6. ==> Ce sont les aretes 3, 7 et 9 qui sont coupees
c
      elseif ( mod(hetare(listar(3)),10).eq.2 .and.
     >         mod(hetare(listar(7)),10).eq.2 .and.
     >         mod(hetare(listar(9)),10).eq.2 ) then
        etahex = 95
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH86', nompro
#endif
        call cmch86 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet,
     >                indptp,
     >                coonoe, hetnoe, arenoe,
     >                famnoe,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.7. ==> Ce sont les aretes 4, 5 et 11 qui sont coupees
c
      elseif ( mod(hetare(listar(4)),10).eq.2 .and.
     >         mod(hetare(listar(5)),10).eq.2 .and.
     >         mod(hetare(listar(11)),10).eq.2 ) then
        etahex = 96
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH87', nompro
#endif
        call cmch87 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet,
     >                indptp,
     >                coonoe, hetnoe, arenoe,
     >                famnoe,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.8. ==> Ce sont les aretes 4, 6 et 10 qui sont coupees
c
      elseif ( mod(hetare(listar(4)),10).eq.2 .and.
     >         mod(hetare(listar(6)),10).eq.2 .and.
     >         mod(hetare(listar(10)),10).eq.2 ) then
        etahex = 92
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH88', nompro
#endif
        call cmch88 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet,
     >                indptp,
     >                coonoe, hetnoe, arenoe,
     >                famnoe,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.9. ==> Lesquelles ?
c
      else
        codret = 1
      endif
c
      endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
