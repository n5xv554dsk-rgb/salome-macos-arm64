      subroutine cmcha1 ( lehexa, etahex,
     >                    indare, indtri, indpyr,
     >                    indptp,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
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
c                         - par 1 Arete - pilotage
c                               - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . etahex .  s  .    1   . etat final de l'hexaedre                   .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
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
      parameter ( nompro = 'CMCHA1' )
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
c
c 0.3. ==> arguments
c
      integer lehexa, etahex
      integer indare, indtri, indpyr
      integer indptp
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer arequa(nouvqu,4)
      integer filqua(nouvqu)
      integer hetpyr(nouvpy), facpyr(nouvyf,5), cofapy(nouvyf,5)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
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
      write (ulsort,1000) 'indare', indare
      write (ulsort,1000) 'indtri', indtri
      write (ulsort,1000) 'indpyr', indpyr
 1000 format (a6,' =',i10)
#endif
c
      texte(1,4) ='(''Aucune arete ne correspond.'')'
c
      texte(2,4) ='(''No Edge is good.'')'
c
      codret = 0
c
c====
c 2. Recherche des aretes et des sommets
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
c 3. Recherche de l'arete decoupee
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
      write(ulsort,*) 'listar(9) = ', listar(9),
     >                   ' de ',somare(1,listar(9)),
     >                   ' a ',somare(2,listar(9))
      write(ulsort,*) 'listar(11) = ', listar(11),
     >                   ' de ',somare(1,listar(11)),
     >                   ' a ',somare(2,listar(11))
#endif
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> C'est l'arete 1 qui est coupee
c
      if ( mod(hetare(listar(1)),10).eq.2 ) then
        etahex = 11
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH61', nompro
#endif
        call cmch61 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.2. ==> C'est l'arete 2 qui est coupee
c
      elseif ( mod(hetare(listar(2)),10).eq.2 ) then
        etahex = 12
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH62', nompro
#endif
        call cmch62 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.3. ==> C'est l'arete 3 qui est coupee
c
      elseif ( mod(hetare(listar(3)),10).eq.2 ) then
        etahex = 13
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH63', nompro
#endif
        call cmch63 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.4. ==> C'est l'arete 4 qui est coupee
c
      elseif ( mod(hetare(listar(4)),10).eq.2 ) then
        etahex = 14
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH64', nompro
#endif
        call cmch64 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.5. ==> C'est l'arete 5 qui est coupee
c
      elseif ( mod(hetare(listar(5)),10).eq.2 ) then
        etahex = 15
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH65', nompro
#endif
        call cmch65 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.6. ==> C'est l'arete 6 qui est coupee
c
      elseif ( mod(hetare(listar(6)),10).eq.2 ) then
        etahex = 16
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH66', nompro
#endif
        call cmch66 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.7. ==> C'est l'arete 7 qui est coupee
c
      elseif ( mod(hetare(listar(7)),10).eq.2 ) then
        etahex = 17
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH67', nompro
#endif
        call cmch67 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.8. ==> C'est l'arete 8 qui est coupee
c
      elseif ( mod(hetare(listar(8)),10).eq.2 ) then
        etahex = 18
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH68', nompro
#endif
        call cmch68 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.9. ==> C'est l'arete 9 qui est coupee
c
      elseif ( mod(hetare(listar(9)),10).eq.2 ) then
        etahex = 19
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH69', nompro
#endif
        call cmch69 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.10. ==> C'est l'arete 10 qui est coupee
c
      elseif ( mod(hetare(listar(10)),10).eq.2 ) then
        etahex = 20
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH70', nompro
#endif
        call cmch70 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.11. ==> C'est l'arete 11 qui est coupee
c
      elseif ( mod(hetare(listar(11)),10).eq.2 ) then
        etahex = 21
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH71', nompro
#endif
        call cmch71 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.12. ==> C'est l'arete 12 qui est coupee
c
      elseif ( mod(hetare(listar(12)),10).eq.2 ) then
        etahex = 22
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH72', nompro
#endif
        call cmch72 ( lehexa, listar, listso,
     >                indare, indtri, indpyr,
     >                indptp,
     >                hetare, somare,
     >                filare, merare, famare,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                quahex, coquhe,
     >                famhex, cfahex,
     >                ulsort, langue, codret )
c
c 3.13. ==> Laquelle ?
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
