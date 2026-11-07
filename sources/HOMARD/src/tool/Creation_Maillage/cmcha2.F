      subroutine cmcha2 ( lehexa, etahex,
     >                    indnoe, indare, indtri, indtet, indpyr,
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
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
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
c                         - par 2 Aretes - pilotage
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
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
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
c . hetpyr . e   . nouvpy . historique de l'etat des pyramides         .
c . facpyr . e   .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nouvyf*5. codes des faces des pyramides              .
c . filpyr . e   . nouvpy . premier fils des pyramides                 .
c . perpyr . e   . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . e   . nouvpy . famille des pyramides                      .
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
      parameter ( nompro = 'CMCHA2' )
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
      integer indnoe, indare, indtri, indtet, indpyr
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
      integer hetpyr(nouvpy), facpyr(nouvyf,5), cofapy(nouvyf,5)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
      write (ulsort,1000) 'indnoe', indnoe
      write (ulsort,1000) 'indtri', indtri
      write (ulsort,1000) 'indtet', indtet
      write (ulsort,1000) 'indpyr', indpyr
 1000 format (a6,' =',i10)
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
c 3. Recherche des 2 aretes decoupees
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
c 3.1. ==> Ce sont les aretes 1 et 7 qui sont coupees
c
      if ( mod(hetare(listar(1)),10).eq.2 .and.
     >     mod(hetare(listar(7)),10).eq.2 ) then
        etahex = 23
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH01', nompro
#endif
        call cmch01 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.2. ==> Ce sont les aretes 1 et 8 qui sont coupees
c
      elseif ( mod(hetare(listar(1)),10).eq.2 .and.
     >         mod(hetare(listar(8)),10).eq.2 ) then
        etahex = 35
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH02', nompro
#endif
        call cmch02 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.3. ==> Ce sont les aretes 1 et 10 qui sont coupees
c
      elseif ( mod(hetare(listar(1)),10).eq.2 .and.
     >         mod(hetare(listar(10)),10).eq.2 ) then
        etahex = 36
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH03', nompro
#endif
        call cmch03 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.4. ==> Ce sont les aretes 1 et 11 qui sont coupees
c
      elseif ( mod(hetare(listar(1)),10).eq.2 .and.
     >         mod(hetare(listar(11)),10).eq.2 ) then
        etahex = 24
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH04', nompro
#endif
        call cmch04 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.5. ==> Ce sont les aretes 2 et 6 qui sont coupees
c
      elseif ( mod(hetare(listar(2)),10).eq.2 .and.
     >         mod(hetare(listar(6)),10).eq.2 ) then
        etahex = 37
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH05', nompro
#endif
        call cmch05 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.6. ==> Ce sont les aretes 2 et 8 qui sont coupees
c
      elseif ( mod(hetare(listar(2)),10).eq.2 .and.
     >         mod(hetare(listar(8)),10).eq.2 ) then
        etahex = 25
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH06', nompro
#endif
        call cmch06 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.7. ==> Ce sont les aretes 2 et 9 qui sont coupees
c
      elseif ( mod(hetare(listar(2)),10).eq.2 .and.
     >         mod(hetare(listar(9)),10).eq.2 ) then
        etahex = 26
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH07', nompro
#endif
        call cmch07 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.8. ==> Ce sont les aretes 2 et 12 qui sont coupees
c
      elseif ( mod(hetare(listar(2)),10).eq.2 .and.
     >         mod(hetare(listar(12)),10).eq.2 ) then
        etahex = 38
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH08', nompro
#endif
        call cmch08 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.9. ==> Ce sont les aretes 3 et 5 qui sont coupees
c
      elseif ( mod(hetare(listar(3)),10).eq.2 .and.
     >         mod(hetare(listar(5)),10).eq.2 ) then
        etahex = 27
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH09', nompro
#endif
        call cmch09 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.10. ==> Ce sont les aretes 3 et 7 qui sont coupees
c
      elseif ( mod(hetare(listar(3)),10).eq.2 .and.
     >         mod(hetare(listar(7)),10).eq.2 ) then
        etahex = 39
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH10', nompro
#endif
        call cmch10 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.11. ==> Ce sont les aretes 3 et 9 qui sont coupees
c
      elseif ( mod(hetare(listar(3)),10).eq.2 .and.
     >         mod(hetare(listar(9)),10).eq.2 ) then
        etahex = 40
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH11', nompro
#endif
        call cmch11 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.12. ==> Ce sont les aretes 3 et 12 qui sont coupees
c
      elseif ( mod(hetare(listar(3)),10).eq.2 .and.
     >         mod(hetare(listar(12)),10).eq.2 ) then
        etahex = 28
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH12', nompro
#endif
        call cmch12 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.13. ==> Ce sont les aretes 4 et 5 qui sont coupees
c
      elseif ( mod(hetare(listar(4)),10).eq.2 .and.
     >         mod(hetare(listar(5)),10).eq.2 ) then
        etahex = 41
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH13', nompro
#endif
        call cmch13 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.14. ==> Ce sont les aretes 4 et 6 qui sont coupees
c
      elseif ( mod(hetare(listar(4)),10).eq.2 .and.
     >         mod(hetare(listar(6)),10).eq.2 ) then
        etahex = 29
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH14', nompro
#endif
        call cmch14 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.15. ==> Ce sont les aretes 4 et 10 qui sont coupees
c
      elseif ( mod(hetare(listar(4)),10).eq.2 .and.
     >         mod(hetare(listar(10)),10).eq.2 ) then
        etahex = 30
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH15', nompro
#endif
        call cmch15 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.16. ==> Ce sont les aretes 4 et 11 qui sont coupees
c
      elseif ( mod(hetare(listar(4)),10).eq.2 .and.
     >         mod(hetare(listar(11)),10).eq.2 ) then
        etahex = 42
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH16', nompro
#endif
        call cmch16 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.17. ==> Ce sont les aretes 5 et 11 qui sont coupees
c
      elseif ( mod(hetare(listar(5)),10).eq.2 .and.
     >         mod(hetare(listar(11)),10).eq.2 ) then
        etahex = 43
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH17', nompro
#endif
        call cmch17 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.18 ==> Ce sont les aretes 5 et 12 qui sont coupees
c
      elseif ( mod(hetare(listar(5)),10).eq.2 .and.
     >         mod(hetare(listar(12)),10).eq.2 ) then
        etahex = 31
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH18', nompro
#endif
        call cmch18 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.19. ==> Ce sont les aretes 6 et 10 qui sont coupees
c
      elseif ( mod(hetare(listar(6)),10).eq.2 .and.
     >         mod(hetare(listar(10)),10).eq.2 ) then
        etahex = 32
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH19', nompro
#endif
        call cmch19 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.20. ==> Ce sont les aretes 6 et 12 qui sont coupees
c
      elseif ( mod(hetare(listar(6)),10).eq.2 .and.
     >         mod(hetare(listar(12)),10).eq.2 ) then
        etahex = 44
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH20', nompro
#endif
        call cmch20 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.21. ==> Ce sont les aretes 7 et 9 qui sont coupees
c
      elseif ( mod(hetare(listar(7)),10).eq.2 .and.
     >         mod(hetare(listar(9)),10).eq.2 ) then
        etahex = 45
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH21', nompro
#endif
        call cmch21 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.22. ==> Ce sont les aretes 7 et 11 qui sont coupees
c
      elseif ( mod(hetare(listar(7)),10).eq.2 .and.
     >         mod(hetare(listar(11)),10).eq.2 ) then
        etahex = 33
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH22', nompro
#endif
        call cmch22 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.23. ==> Ce sont les aretes 8 et 9 qui sont coupees
c
      elseif ( mod(hetare(listar(8)),10).eq.2 .and.
     >         mod(hetare(listar(9)),10).eq.2 ) then
        etahex = 34
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH23', nompro
#endif
        call cmch23 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.24. ==> Ce sont les aretes 8 et 10 qui sont coupees
c
      elseif ( mod(hetare(listar(8)),10).eq.2 .and.
     >         mod(hetare(listar(10)),10).eq.2 ) then
        etahex = 46
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH24', nompro
#endif
        call cmch24 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.31. ==> Ce sont les aretes 1 et 12 qui sont coupees
c
      elseif ( mod(hetare(listar(1)),10).eq.2 .and.
     >         mod(hetare(listar(12)),10).eq.2 ) then
        etahex = 47
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH31', nompro
#endif
        call cmch31 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.32. ==> Ce sont les aretes 2 et 11 qui sont coupees
c
      elseif ( mod(hetare(listar(2)),10).eq.2 .and.
     >         mod(hetare(listar(11)),10).eq.2 ) then
        etahex = 48
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH32', nompro
#endif
        call cmch32 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.33. ==> Ce sont les aretes 3 et 10 qui sont coupees
c
      elseif ( mod(hetare(listar(3)),10).eq.2 .and.
     >         mod(hetare(listar(10)),10).eq.2 ) then
        etahex = 49
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH33', nompro
#endif
        call cmch33 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.34. ==> Ce sont les aretes 4 et 9 qui sont coupees
c
      elseif ( mod(hetare(listar(4)),10).eq.2 .and.
     >         mod(hetare(listar(9)),10).eq.2 ) then
        etahex = 50
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH34', nompro
#endif
        call cmch34 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.35. ==> Ce sont les aretes 5 et 8 qui sont coupees
c
      elseif ( mod(hetare(listar(5)),10).eq.2 .and.
     >         mod(hetare(listar(8)),10).eq.2 ) then
        etahex = 51
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH35', nompro
#endif
        call cmch35 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.36. ==> Ce sont les aretes 6 et 7 qui sont coupees
c
      elseif ( mod(hetare(listar(6)),10).eq.2 .and.
     >         mod(hetare(listar(7)),10).eq.2 ) then
        etahex = 52
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH36', nompro
#endif
        call cmch36 ( lehexa, listar, listso,
     >                indnoe, indare, indtri, indtet, indpyr,
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
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.13. ==> Lesquelles ?
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
