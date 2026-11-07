      subroutine cmch41 ( lehexa, listar, listso,
     >                    indare, indtri, indtet, indpyr,
     >                    indptp,
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
c                         - par 1 Face - etat 41
c                                 -           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . listar . e   .   12   . liste des aretes de l'hexaedre a decouper  .
c . listso . e   .    8   . liste des sommets de l'hexaedre a decouper .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
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
c .        .     .        . 1 : aucune face ne correspond              .
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
      parameter ( nompro = 'CMCH41' )
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
      integer lehexa
      integer listar(12), listso(8)
      integer indare, indtri, indtet, indpyr
      integer indptp
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer arequa(nouvqu,4), filqua(nouvqu)
      integer hettet(nouvte), tritet(nouvtf,4), cotrte(nouvtf,4)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer hetpyr(nouvpy), facpyr(nouvyf,5), cofapy(nouvyf,5)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer tabaux(4)
      integer somm(4)
      integer arext1, arext2, arext3, arext4
      integer trigpy(4)
      integer facnde, cofnde
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
#endif
c
#ifdef _DEBUG_HOMARD_
 1789 format(5(a,i5,', '))
#endif
c
      codret = 0
c
c====
c 2. initialisations
c====
c 2.1. ==> le numero local de la face coupee en 4
c
      iaux = 1
c
c 2.2. ==> les numeros locaux des faces coupees en 3, dans l'ordre
c          des pyramides p/p+1 
c
      tabaux(1) = 3
      tabaux(2) = 5
      tabaux(3) = 4
      tabaux(4) = 2
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'tabaux(1) = ', tabaux(1),
     >                   'tabaux(2) = ', tabaux(2),
     >                   'tabaux(3) = ', tabaux(3),
     >                   'tabaux(4) = ', tabaux(4)
#endif
c
c 2.3. ==> Sommets de la face opposee a la face coupee
c          somm(p) est la pointe de la pyramide fille numero p
c
      somm(1) = listso(6)
      somm(2) = listso(7)
      somm(3) = listso(8)
      somm(4) = listso(5)
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'somm(1) = ', somm(1),'somm(2) = ', somm(2),
     >                   'somm(3) = ', somm(3),'somm(4) = ', somm(4)
#endif
c
c 2.4. ==> Aretes de la face opposee a la face coupee
c          arextp relie les pyramides p et p+1
c
      arext1 = listar(10)
      arext2 = listar(12)
      arext3 = listar(11)
      arext4 = listar( 9)
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'arext1 = ', arext1, 'arext2 = ', arext2,
     >                   'arext3 = ', arext3, 'arext4 = ', arext4
#endif
c
c====
c 3. Creation
c          Noeud central de la face coupee en 4
c     noefac : NF1
c          Sommets de la face opposee a la face coupee
c          somm(p) est la pointe de la pyramide fille numero p
c     somm(1) : S6
c     somm(2) : S7
c     somm(3) : S8
c     somm(4) : S5
c          Quadrangles fils de la face coupee en 4
c          quabas(p) est la base de la pyramide fille numero p
c     quabas(1) : F1S1
c     quabas(2) : F1S4
c     quabas(3) : F1S3
c     quabas(4) : F1S2
c          Aretes tracees sur la face coupee en 4
c          arefad(p) est l'arete commune aux pyramides filles
c          numero p et p+1
c     arefad(1) : AN2NF1
c     arefad(2) : AN4NF1
c     arefad(3) : AN3NF1
c     arefad(4) : AN1NF1
c          Triangles et aretes tracees sur les faces coupees en 3
c          Chaque quadrangle de bord qui est decoupe en 3 triangles
c          borde deux pyramides consecutives : p et p+1
c     trifad(p,0) : triangle central de ce decoupage
c     trifad(p,1) : triangle bordant la pyramide p
c     trifad(p,2) : triangle bordant la pyramide p+1
c     cotrvo(p,0) : futur code du triangle trifad(p,0) dans la
c                   description du tetraedre p
c     cotrvo(p,1) : futur code du triangle trifad(p,1) dans la
c                   description de la pyramide p
c     cotrvo(p,2) : futur code du triangle trifad(p,2) dans la
c                   description de la pyramide p+1
c     areqtr(p,1) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,1)
c     areqtr(p,2) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,2)
c
c     trifad(1,0) : FF3
c     trifad(1,1) : FF3 + 1/2
c     trifad(1,2) : FF3 + 2/1
c     areqtr(1,1) : AS6N2
c     areqtr(1,2) : AS7N2
c
c     trifad(2,0) : FF5
c     trifad(2,1) : FF5 + 1/2
c     trifad(2,2) : FF5 + 2/1
c     areqtr(2,1) : AS7N4
c     areqtr(2,2) : AS8N4
c
c     trifad(3,0) : FF4
c     trifad(3,1) : FF4 + 1/2
c     trifad(3,2) : FF4 + 2/1
c     areqtr(3,1) : AS8N3
c     areqtr(3,2) : AS5N3
c
c     trifad(4,0) : FF2
c     trifad(4,1) : FF2 + 1/2
c     trifad(4,2) : FF2 + 2/1
c     areqtr(4,1) : AS5N1
c     areqtr(4,2) : AS6N1
c
c    areint(p) relie le sommet somm(p) (de la pyramide fille p)
c    au centre de la face coupee
c     areint(1) : AS6N1
c     areint(2) : AS7N1
c     areint(3) : AS8N1
c     areint(4) : AS5N1
c
c        Triangles s'appuyant sur la face decoupee
c     triint(p,1) : triangle contenant arefad(p) et de la pyramide p  
c     triint(p,2) : triangle contenant arefad(p) et de la pyramide p+1
c     triint(1,1) : P1A1S6
c     triint(1,2) : P1A1S7
c     triint(2,1) : P1A2S7
c     triint(2,2) : P1A2S8
c     triint(3,1) : P1A1S8
c     triint(3,2) : P1A1S5
c     triint(4,1) : P1A2S5
c     triint(4,2) : P1A2S6
c
c     Triangles s'appuyant sur les aretes de la face non decoupee
c          Ce sont ceux qui bordent la grande pyramide
c     trigpy(t) : triangle appuyant sur le tetraedre t
c     trigpy(1) : PA10F1
c     trigpy(2) : PA12F1
c     trigpy(3) : PA11F1
c     trigpy(4) : PA9F1
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCH40_41', nompro
#endif
      call cmch40 ( lehexa, iaux, tabaux,
     >              somm, arext1, arext2, arext3, arext4,
     >              indare, indtri, indtet, indpyr, indptp,
     >              hetare, somare,
     >              filare, merare, famare,
     >              hettri, aretri,
     >              filtri, pertri, famtri,
     >              nivtri,
     >              arequa, filqua,
     >              hettet, tritet, cotrte,
     >              filtet, pertet, famtet,
     >              hetpyr, facpyr, cofapy,
     >              filpyr, perpyr, fampyr,
     >              quahex, coquhe,
     >              famhex, cfahex,
     >              trigpy, facnde, cofnde,
     >              ulsort, langue, codret )
c
c====
c 4. Pyramide s'appuyant sur la face non decoupee,
c          dite la 'grosse pyramide'
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYR_41', nompro
#endif
      iaux = fampyr(indpyr)
      jaux = -indptp
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trigpy(4),      3,
     >              trigpy(3),      3,
     >              trigpy(2),      3,
     >              trigpy(1),      2,
     >                 facnde, cofnde,
     >              jaux,   iaux, indpyr )
c
      endif
c
c====
c 5. la fin
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
