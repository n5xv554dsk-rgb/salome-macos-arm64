      subroutine cmch19 ( lehexa, listar, listso,
     >                    indnoe, indare, indtri, indtet, indpyr,
     >                    indptp,
     >                    coonoe, hetnoe, arenoe,
     >                    famnoe,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    filqua,
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
c                         - par 2 Aretes - etat 19
c                                               --
c    Decoupage par les aretes 6 et 10
c    Serie A
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . listar . e   .   12   . liste des aretes de l'hexaedre a decouper  .
c . listso . e   .    8   . liste des sommets de l'hexaedre a decouper .
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
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . es  .nouvtf*4. code des 4 triangles des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . hetpyr . es  . nouvpy . historique de l'etat des pyramides         .
c . facpyr . es  .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . es  .nouvyf*5. codes des faces des pyramides              .
c . filpyr . es  . nouvpy . premier fils des pyramides                 .
c . perpyr . es  . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . es  . nouvpy . famille des pyramides                      .
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
      parameter ( nompro = 'CMCH19' )
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
#include "cofpfh.h"
c
c 0.3. ==> arguments
c
      integer lehexa
      integer listar(12), listso(8)
      integer indnoe, indare, indtri, indtet, indpyr
      integer indptp
      integer hetnoe(nouvno), arenoe(nouvno)
      integer famnoe(nouvno)
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
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
      integer nbsomm
      parameter ( nbsomm = 8 )
c
      integer iaux, jaux
      integer laface, codfac
      integer lesnoe(10), lesare(10)
      integer tab1(2)
      integer nulofa(4)
      integer areint(10)
      integer areqtr(4,2)
      integer triint(22)
      integer trifad(4,0:2), cotrvo(4,0:2)
      integer niveau
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
c====
c 2. grandeurs dependant du cas traite
c      lesnoe(1) = S4
c      lesnoe(2) = S3
c      lesnoe(3) = S2
c      lesnoe(4) = S1
c      lesnoe(5) = S7
c      lesnoe(6) = S8
c      lesnoe(7) = S5
c      lesnoe(8) = S6
c      lesnoe( 9) = N6
c      lesnoe(10) = N10
c====
c     lesnoe(i) = sommet a joindre au centre de l'hexaedre pour
c                 definir la ieme arete interne
      lesnoe(1) = listso(4)
      lesnoe(2) = listso(3)
      lesnoe(3) = listso(2)
      lesnoe(4) = listso(1)
      lesnoe(5) = listso(7)
      lesnoe(6) = listso(8)
      lesnoe(7) = listso(5)
      lesnoe(8) = listso(6)
c
c     iaux = numero local de la 1ere arete coupee : celle qui partage un
c            sommet avec la 1ere pyramide
      iaux = 6
c
c     lesnoe(9) = noeud milieu de la 1ere arete coupee
      lesnoe(9) = somare(2,filare(listar(iaux)))
c
c     iaux = numero local de la 2eme arete coupee : celle qui partage un
c            sommet avec la 2nde pyramide
      iaux = 10
c
c     lesnoe(10) = noeud milieu de la 2eme arete coupee
      lesnoe(10) = somare(2,filare(listar(iaux)))
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'listso = ', listso
      write(ulsort,*) 'arete 1 = ', listar(6)
      write(ulsort,*) 'lesnoe(9) = ', lesnoe(9)
      write(ulsort,*) 'arete 2 = ', listar(10)
      write(ulsort,*) 'lesnoe(10) = ', lesnoe(10)
      write(ulsort,*) 'lesnoe(1) = ', lesnoe(1),
     >                ', lesnoe(2) = ', lesnoe(2)
      write(ulsort,*) 'lesnoe(3) = ', lesnoe(3),
     >                ', lesnoe(4) = ', lesnoe(4)
      write(ulsort,*) 'lesnoe(5) = ', lesnoe(5),
     >                ', lesnoe(6) = ', lesnoe(6)
      write(ulsort,*) 'lesnoe(7) = ', lesnoe(7),
     >                ', lesnoe(8) = ', lesnoe(8)
#endif
c
c  Triangles et aretes tracees sur les faces coupees en 3
c            La premiere pyramide s'appuie sur celle des 2 faces de
c            l'hexaedre qui est non decoupee et de plus petit numero
c            local. Le positionnement de la pyramide a defini une
c            orientation de sa face quadrangulaire.
c            On traite les faces de l'hexaedre coupees en 3 comme suit :
c            . la 1ere et la 2eme partagent la 1ere arete coupee
c            . la 3eme et la 4eme partagent la 2nde arete coupee
c            Le choix de la 1ere est tel que l'ordre 1/2 corresponde a
c            l'orientation de la pyramide numero 1.
c            Le choix de la 3eme est tel que l'ordre 3/4 corresponde a
c            l'orientation de la pyramide numero 2.
c     trifad(p,0) : triangle central de ce decoupage
c     trifad(p,1) : triangle ayant une arete commune a une pyramide
c     trifad(p,2) : triangle sans arete commune avec une pyramide
c     cotrvo(p,0/1/2) : futur code du triangle trifad(p,0/1/2) dans la
c                       description du tetraedre voisin
c     areqtr(p,1) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,1)
c     areqtr(p,2) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,2)
c
c     trifad(1,0) = triangle central de la face 1 : FF4
c     trifad(1,1) = triangle de la face 1 du cote de PYR1 : FF4 + 1/2
c     trifad(1,2) = triangle de la face 1 de l'autre cote : FF4 + 2/1
c     areqtr(1,1) : AS3N6
c     areqtr(1,2) : AS8N6
c
c     trifad(2,0) = triangle central de la face 2 : FF2
c     trifad(2,1) = triangle de la face 2 du cote de PYR1 : FF2 + 2/1
c     trifad(2,2) = triangle de la face 2 de l'autre cote : FF2 + 1/2
c     areqtr(2,1) : AS1N6
c     areqtr(2,2) : AS6N6
c
c     trifad(3,0) = triangle central de la face 3 : FF3
c     trifad(3,1) = triangle de la face 3 du cote de PYR2 : FF3 + 1/2
c     trifad(3,2) = triangle de la face 3 de l'autre cote : FF3 + 2/1
c     areqtr(3,1) : AS4N10
c     areqtr(3,2) : AS1N10
c
c     trifad(4,0) = triangle central de la face 4 : FF6
c     trifad(4,1) = triangle de la face 4 du cote de PYR2 : FF6 + 2/1
c     trifad(4,2) = triangle de la face 4 de l'autre cote : FF6 + 1/2
c     areqtr(4,1) : AS8N10
c     areqtr(4,2) : AS5N10
c
      nulofa(1) = 4
      nulofa(2) = 2
      nulofa(3) = 3
      nulofa(4) = 6
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHAA', nompro
#endif
      call cmchaa ( nulofa, lehexa,
     >              somare,
     >              aretri, nivtri,
     >              filqua,
     >              quahex, coquhe,
     >              niveau, areqtr,
     >              trifad, cotrvo,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. Creation du noeud interne et des dix aretes internes
c    noecen : N0
c    areint( 1) : AS4N0
c    areint( 2) : AS3N0
c    areint( 3) : AS2N0
c    areint( 4) : AS1N0
c    areint( 5) : AS7N0
c    areint( 6) : AS8N0
c    areint( 7) : AS5N0
c    areint( 8) : AS6N0
c    areint( 9) : AN6N0
c    areint(10) : AN10N0
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHAB', nompro
      write (ulsort,*) '.. noeud ', indnoe+1
      write (ulsort,*) '.. aretes de ', indare+1, ' a ', indare+10
#endif
      iaux = 10
      call cmchpb ( indnoe, indare, iaux,
     >              nbsomm, lesnoe, areint,
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. Creation des triangles internes
c    triint( 1) : FA4
c    triint( 2) : FA3
c    triint( 3) : FA1
c    triint( 4) : FA2
c    triint( 5) : FA7
c    triint( 6) : FA12
c    triint( 7) : FA8
c    triint( 8) : FA9  (F2/F4)
c    triint( 9) : FA11 (F1/F4)
c    triint(10) : FA5  (F2/F3)
c    triint(11) : FS3N6
c    triint(12) : FS1N6
c    triint(13) : FS4N10
c    triint(14) : FS8N10
c    triint(15) : FS8N6
c    triint(16) : FS6N6
c    triint(17) : FS1N10
c    triint(18) : FS5N10
c    triint(19) : FS2N6
c    triint(20) : FS7N10
c    triint(21) : FS5N6
c    triint(22) : FS6N10
c====
c
      if ( codret.eq.0 ) then
c
      lesare( 1) = listar(4)
      lesare( 2) = listar(3)
      lesare( 3) = listar(1)
      lesare( 4) = listar(2)
      lesare( 5) = listar(7)
      lesare( 6) = listar(12)
      lesare( 7) = listar(8)
      lesare( 8) = listar(9)
      lesare( 9) = listar(11)
      lesare(10) = listar(5)
c
      tab1(1) = 1
      tab1(2) = 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHAH', nompro
      write (ulsort,*) '.. triangles de ', indtri+1, ' a ', indtri+10
#endif
      call cmchah ( indtri, triint,
     >              lesare, tab1,
     >              trifad, areint, areqtr, niveau,
     >              aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. Creation des deux pyramides
c====
c
      if ( codret.eq.0 ) then
c
      iaux = -indptp
      jaux = cfahex(cofpfh,famhex(lehexa))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '.. pyramides de ', indpyr+1, ' a ', indpyr+2
#endif
c
      laface = quahex(lehexa,1)
      codfac = coquhe(lehexa,1)
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              triint(3), 3,
     >              triint(4), 3,
     >              triint(1), 3,
     >              triint(2), 2,
     >                 laface, codfac,
     >              iaux,  jaux,   indpyr )
c
      laface = quahex(lehexa,5)
      codfac = coquhe(lehexa,5)
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              triint(1), 5,
     >              triint(5), 3,
     >              triint(6), 3,
     >              triint(7), 2,
     >                 laface, codfac,
     >              iaux,  jaux,   indpyr )
c
#ifdef _DEBUG_HOMARD_
      do 4333 , iaux = indpyr-1, indpyr
      write(ulsort,1789) iaux, (facpyr(iaux,jaux),jaux=1,5)
 4333 continue
 1789 format('pyramide ',i6,' : ',5i6)
#endif
c
      endif
c
c====
c 6. Creation des douze tetraedres dans l'ordre suivant :
c  tetraedre 7
c  tetraedre 8
c  tetraedre 9
c  tetraedre 1
c  tetraedre 2
c  tetraedre 3
c  tetraedre 4
c  tetraedre 6
c  tetraedre 5
c  tetraedre 10
c  tetraedre 12
c  tetraedre 11
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHAI', nompro
      write (ulsort,*) '.. tetraedres de ', indtet+1, ' a ', indtet+12
#endif
c
      iaux = 3
      call cmchai ( lehexa, indtet, indptp,   iaux,
     >              trifad, cotrvo, triint,
     >              hettet, tritet, cotrte,
     >              filtet, pertet, famtet,
     >              famhex, cfahex,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 7. la fin
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
