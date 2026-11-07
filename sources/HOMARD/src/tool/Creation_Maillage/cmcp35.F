      subroutine cmcp35 ( lepent, listar, listso,
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
     >                    facpen, cofape,
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
c                         - etat 35 - par les aretes 2 et 4
c                                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .   1    . pentaedre a decouper                       .
c . listar . e   .   9   . liste des aretes du pentaedre a decouper    .
c . listso . e   .   6    . liste des sommets du pentaedre a decouper  .
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
c . cotrte . e   .nouvtf*4. code des 4 triangles des tetraedres        .
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
c . facpen . e   .nouvpf*5. numeros des faces des pentaedres           .
c . cofape . e   .nouvpf*5. codes des faces des pentaedres             .
c . fampen . e   . nouvpe . famille des penaedres                      .
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
      parameter ( nompro = 'CMCP35' )
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
#include "i1i2i3.h"
#include "cofpfp.h"
c
c 0.3. ==> arguments
c
      integer lepent
      integer listar(9), listso(6)
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
      integer facpen(nouvpf,5), cofape(nouvpf,5)
      integer fampen(nouvpe), cfapen(nctfpe,nbfpen)
c
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbsomm
      parameter ( nbsomm = 6 )
c
      integer iaux, jaux
      integer f5, cf5
#ifdef _DEBUG_HOMARD_
      integer f1, cf1
      integer f2, cf2
      integer f3, cf3
      integer f4, cf4
#endif
      integer lesnoe(8), lesare(7)
      integer areint(8)
      integer triint(17)
      integer trifad(4,0:2), cotrvo(4,0:2), areqtr(4,0:2)
      integer nulofa(4)
      integer ind001(4)
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
#include "impr03.h"
#include "impr04.h"
c
      codret = 0
c
c====
c 2. initialisations
c====
c 2.1. ==> grandeurs independantes du cas traite (phase 1)
c          les faces du pentaedre et leurs codes
c
      f5 = facpen(lepent,5)
      cf5 = cofape(lepent,5)
#ifdef _DEBUG_HOMARD_
      f1 = facpen(lepent,1)
      cf1 = cofape(lepent,1)
      f2 = facpen(lepent,2)
      cf2 = cofape(lepent,2)
      f3 = facpen(lepent,3)
      cf3 = cofape(lepent,3)
      f4 = facpen(lepent,4)
      cf4 = cofape(lepent,4)
      write(ulsort,90002) 'f1', f1, cf1
      write(ulsort,90002) 'f2', f2, cf2
      write(ulsort,90002) 'f3', f3, cf3
      write(ulsort,90002) 'f4', f4, cf4
      write(ulsort,90002) 'f5', f5, cf5
#endif
c
c 2.2. ==> grandeurs dependant du cas traite
c     iaux = numero local de l'arete coupee
c     jaux = numero global de l'arete coupee
c     noemil = noeud milieu de l'arete coupee
c
      iaux = 2
      jaux = listar(iaux)
      lesnoe(7) = somare(2,filare(jaux))
c
      iaux = 4
      jaux = listar(iaux)
      lesnoe(8) = somare(2,filare(jaux))
c
c     lesnoe(i) = sommet a joindre au centre du pentaedre pour creer
c                 l'arete interne i
c      Les 4 premiers sont les sommets Si de la pyramide
c      lesnoe(5) : le dernier sommet de la face 1
c      lesnoe(6) : le dernier sommet de la face 2
c
      lesnoe(1) = listso(3)
      lesnoe(2) = listso(2)
      lesnoe(3) = listso(5)
      lesnoe(4) = listso(6)
      lesnoe(5) = listso(1)
      lesnoe(6) = listso(4)
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'lesnoe', lesnoe
#endif
c
c 2.3. ==> Triangles et aretes tracees sur les faces coupees
c
c     trifad(1,0) = triangle central de la face 1 : FF4
c     trifad(1,1) = triangle de la face 1 bordant la pyr : FF4 + 1/2
c     trifad(1,2) = triangle de la face 1 autre : FF4 + 2/1
c     areqtr(1,1) : AS5N2
c     areqtr(1,2) : AS4N2
c
c     trifad(2,0) = triangle central de la face 2 : FF3
c     trifad(2,1) = triangle de la face 2 bordant la pyr : FF3 + 2/1
c     trifad(2,2) = triangle de la face 2 autre : FF3 + 1/2
c     areqtr(2,1) : AS3N4
c     areqtr(2,2) : AS1N4
c
c     trifad(3,0) = triangle de la face 3 bordant la pyr : FF1 + 0/1
c     trifad(3,1) = triangle de la face 3 autre : FF1 + 1/0
c     areqtr(3,0) : arete de trifad(3,0) : AS2N2
c     areqtr(3,1) : arete de trifad(3,1) : AS1N2
c     areqtr(3,2) : arete commune : AS3N2
c
c     trifad(4,0) = triangle de la face 4 bordant la pyr : FF2 + 0/1
c     trifad(4,1) = triangle de la face 4 autre : FF2 + 1/0
c     areqtr(4,0) : arete de trifad(4,0) : AS6N4
c     areqtr(4,1) : arete de trifad(4,1) : AS4N4
c     areqtr(4,2) : arete commune : AS5N4
c
      if ( codret.eq.0 ) then
c
      nulofa(1) = 4
      nulofa(2) = 3
      nulofa(3) = 1
      nulofa(4) = 2
c
      ind001(1) = 6
      ind001(2) = 5
      ind001(3) = 4
      ind001(4) = 6
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP3F', nompro
#endif
      call cmcp3f ( nulofa, lepent,
     >              i2, i3, i1,
     >              i1, i2, i3,
     >              ind001,
     >              somare,
     >              aretri, nivtri, filtri,
     >              filqua,
     >              facpen, cofape,
     >              niveau,
     >              trifad, cotrvo, areqtr,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. Creation du noeud interne
c 4. Creation des aretes internes
c    areint(1) : AS3N0
c    areint(2) : AS2N0
c    areint(3) : AS5N0
c    areint(4) : AS6N0
c    areint(5) : AS1N0
c    areint(6) : AS4N0
c    areint(7) : AN2N0
c    areint(8) : AN4N0
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,98000) indnoe+1, indnoe+1
      write (ulsort,91000) indare+1, indare+8
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHPB', nompro
#endif
      iaux = 8
      call cmchpb ( indnoe, indare, iaux,
     >              nbsomm, lesnoe, areint,
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 400 , iaux = indare-7 , indare
        write (ulsort,90015) 'Arete', iaux,
     >                ', sommets', somare(1,iaux),somare(2,iaux)
  400 continue
#endif
c
      endif
c
c====
c 5. Creation des 17 triangles internes
c      triint( 1) = FA3
c      triint( 2) = FA8
c      triint( 3) = FA6
c      triint( 4) = FA9
c      triint( 5) = FA1
c      triint( 6) = FA5
c      triint( 7) = FA7
c      triint( 8) = FS2N2
c      triint( 9) = FS1N2
c      triint(10) = FS6N4
c      triint(11) = FS4N4
c      triint(12) = FS5N2
c      triint(13) = FS4N2
c      triint(14) = FS3N4
c      triint(15) = FS1N4
c      triint(16) = FS3N2
c      triint(17) = FS5N4
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,92000) indtri+1, indtri+17
#endif
c
      if ( codret.eq.0 ) then
c
      lesare(1) = listar(3)
      lesare(2) = listar(8)
      lesare(3) = listar(6)
      lesare(4) = listar(9)
      lesare(5) = listar(1)
      lesare(6) = listar(5)
      lesare(7) = listar(7)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP3G', nompro
#endif
      call cmcp3g ( indtri, triint,
     >              lesare,
     >              areint, areqtr, niveau,
     >              aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 500 , iaux = indtri-16 , indtri
        write(ulsort,90015) 'tria', iaux,
     >                      ' : aretes =', (aretri(iaux,jaux),jaux=1,3)
  500 continue
#endif
c
      endif
c
c====
c 6. Creation de la pyramide
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,95000) indpyr+1, indpyr+1
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = -indptp
      jaux = cfapen(cofpfp,fampen(lepent))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYR', nompro
#endif
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >                triint(1),           2,
     >                triint(2),           2,
     >                triint(3),           2,
     >                triint(4),           1,
     >                       f5,         cf5,
     >              iaux,  jaux,   indpyr )
c
#ifdef _DEBUG_HOMARD_
      do 600 , iaux = indpyr , indpyr
        write (ulsort,90015) 'Pyra', iaux,
     >                ', faces', (facpyr(iaux,jaux),jaux=1,5)
        write(ulsort,90015) 'Pyra', iaux,
     >                ', codes', (cofapy(iaux,jaux),jaux=1,5)
  600 continue
#endif
c
      endif
c
c====
c 7. Creation des tetraedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93000) indtet+1, indtet+10
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP3H', nompro
#endif
      call cmcp3h ( indtet, indptp,
     >              lepent,
     >              trifad, cotrvo, triint,
     >              hettet, tritet, cotrte,
     >              filtet, pertet, famtet,
     >              fampen, cfapen,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 700 , iaux = indtet-9 , indtet
        write (ulsort,90015) 'Tetra', iaux,
     >                ', faces', (tritet(iaux,jaux),jaux=1,4)
        write(ulsort,90015) 'Tetra', iaux,
     >                ', codes', (cotrte(iaux,jaux),jaux=1,4)
  700 continue
#endif
c
      endif
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
