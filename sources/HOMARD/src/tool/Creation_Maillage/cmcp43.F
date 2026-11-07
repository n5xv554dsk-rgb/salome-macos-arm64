      subroutine cmcp43 ( lepent, listar, listso,
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
c                         - etat 43 - par la face F3
c                                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .   1    . pentaedre a decouper                       .
c . listar . e   .   9   . liste des aretes du pentaedre a decouper    .
c . listso . e   .   6    . liste des sommets du pentaedre a decouper  .
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
      parameter ( nompro = 'CMCP43' )
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
#include "i1i2i3.h"
c
c 0.3. ==> arguments
c
      integer lepent
      integer listar(9), listso(6)
      integer indare, indtri, indtet, indpyr
      integer indptp
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
      integer facpen(nouvpf,5), cofape(nouvpf,5)
      integer fampen(nouvpe), cfapen(nctfpe,nbfpen)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
      integer cf3
#ifdef _DEBUG_HOMARD_
      integer f1, cf1
      integer f2, cf2
      integer f3
      integer f4, cf4
      integer f5, cf5
#endif
      integer noemil, lesnoe(2), lesare(7)
      integer areint(8)
      integer triint(7)
      integer trifad(4,0:2), cotrvo(4,0:2), areqtr(4,0:2)
      integer quafad(4), areqqu(4)
      integer nulofa(5)
      integer tabind(4)
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
      cf3 = cofape(lepent,3)
#ifdef _DEBUG_HOMARD_
      f1 = facpen(lepent,1)
      cf1 = cofape(lepent,1)
      f2 = facpen(lepent,2)
      cf2 = cofape(lepent,2)
      f3 = facpen(lepent,3)
      f4 = facpen(lepent,4)
      cf4 = cofape(lepent,4)
      f5 = facpen(lepent,5)
      cf5 = cofape(lepent,5)
      write(ulsort,90002) 'f1', f1, cf1
      write(ulsort,90002) 'f2', f2, cf2
      write(ulsort,90002) 'f3', f3, cf3
      write(ulsort,90002) 'f4', f4, cf4
      write(ulsort,90002) 'f5', f5, cf5
#endif
c
c 2.2. ==> grandeurs dependant du cas traite
c
c     lesnoe(i) = sommet a joindre au centre de la face quadrangulaire
c                 coupee pour creer l'arete interne i
c
      lesnoe(1) = listso(2)
      lesnoe(2) = listso(5)
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'lesnoe', lesnoe
#endif
c
c 2.3. ==> Triangles et aretes tracees sur les faces coupees
c
c     trifad(1,0) = triangle central de la face 1 : FF4
c     trifad(1,1) = triangle de la face 1 bordant F1 : FF4 + 1/2
c     trifad(1,2) = triangle de la face 1 bordant F2 : FF4 + 2/1
c     areqtr(1,1) : AS2N7
c     areqtr(1,2) : AS5N7
c
c     trifad(2,0) = triangle central de la face 2 : FF5
c     trifad(2,1) = triangle de la face 2 bordant F1 : FF5 + 2/1
c     trifad(2,2) = triangle de la face 2 bordant F2 : FF5 + 1/2
c     areqtr(2,1) : AS2N9
c     areqtr(2,2) : AS5N9
c
c     trifad(3,0) = triangle de la face 3 : FF1 + 0/1
c     trifad(3,1) = triangle de la face 3 autre : FF1 + 1/0
c     areqtr(3,2) : arete commune : AS2N1
c
c     trifad(4,0) = triangle de la face 4 : FF2 + 0/1
c     trifad(4,1) = triangle de la face 4 autre : FF2 + 1/0
c     areqtr(4,2) : arete commune : AS5N4
c
c     quafad(1) = quadrangle de la face 5 : FF3 + 0/1/2/3
c     quafad(2) = quadrangle de la face 5 autre : FF3 + 1/2/3/0
c     quafad(3) = quadrangle de la face 5 autre : FF3 + 2/3/0/1
c     quafad(4) = quadrangle de la face 5 autre : FF3 + 3/0/1/2
c     areqqu(p) : arete commune a quafad(p) et quafad(p+1)
c     areqqu(1) : AN1N0
c     areqqu(2) : AN9N0
c     areqqu(3) : AN4N0
c     areqqu(4) : AN7N0
c
      if ( codret.eq.0 ) then
c
      nulofa(1) = 4
      nulofa(2) = 5
      nulofa(3) = 1
      nulofa(4) = 2
      nulofa(5) = 3
c
      tabind(1) = 3
      tabind(2) = 2
      tabind(3) = 3
      tabind(4) = 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP4B', nompro
#endif
      call cmcp4b ( nulofa, lepent,
     >              i1, i2, i3,
     >              i1, i3, i2,
     >              tabind,
     >              somare,
     >              aretri, nivtri, filtri,
     >              arequa, filqua,
     >              facpen, cofape,
     >              noemil,
     >              niveau,
     >              trifad, cotrvo, areqtr,
     >              quafad, areqqu,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. Creation du noeud interne
c====
c====
c 4. Creation des aretes internes
c    areint(1) : AS2N0
c    areint(2) : AS5N0
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,91000) indare+1, indare+2
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHPA', nompro
#endif
      iaux = 2
      call cmchpa ( indare, iaux,
     >              noemil, lesnoe, areint,
     >              hetare, somare,
     >              filare, merare, famare,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. Creation des 7 triangles internes
c      triint( 1) = FS2N7
c      triint( 2) = FS2N9
c      triint( 3) = FS5N7
c      triint( 4) = FS5N9
c      triint( 5) = FS2N1
c      triint( 6) = FS5N4
c      triint( 7) = FA8
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,92000) indtri+1, indtri+7
#endif
c
      if ( codret.eq.0 ) then
c
      lesare(1) = listar(8)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP4C', nompro
#endif
      call cmcp4c ( indtri, triint,
     >              lesare,
     >              areint, areqtr, areqqu, niveau,
     >              aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              ulsort, langue, codret )
      endif
c
c====
c 6. Creation des pyramides
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,95000) indpyr+1, indpyr+4
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = cf3
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP4D', nompro
#endif
      call cmcp4d ( indpyr, indptp,
     >              lepent,
     >              trifad, cotrvo, triint,
     >              quafad, iaux,
     >              hetpyr, facpyr, cofapy,
     >              filpyr, perpyr, fampyr,
     >              fampen, cfapen,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 600 , iaux = indpyr-3 , indpyr
        write(ulsort,90002) 'facpyr', (facpyr(iaux,jaux),jaux=1,5)
        write(ulsort,90002) 'cofapy', (cofapy(iaux,jaux),jaux=1,5)
  600 continue
      do 601 , iaux = 1 , 4
        write(ulsort,90002) 'pyr 1',
     > (aretri(facpyr(1,iaux),jaux),jaux=1,3)
  601 continue
        write(ulsort,90002) 'pyr 1',
     > (arequa(facpyr(1,5),jaux),jaux=1,4)
#endif
c
      endif
c
c====
c 7. Creation des tetraedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93000) indtet+1, indtet+2
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP4E', nompro
#endif
      call cmcp4e ( indtet, indptp,
     >              lepent,
     >              trifad, cotrvo, triint,
     >              hettet, tritet, cotrte,
     >              filtet, pertet, famtet,
     >              fampen, cfapen,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 700 , iaux = indtet-1 , indtet
        write(ulsort,90002) 'tritet', (tritet(iaux,jaux),jaux=1,4)
        write(ulsort,90002) 'cotrte', (cotrte(iaux,jaux),jaux=1,4)
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
