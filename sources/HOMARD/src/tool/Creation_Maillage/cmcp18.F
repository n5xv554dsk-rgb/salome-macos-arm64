      subroutine cmcp18 ( lepent, listar,
     >                    indtri, indtet, indpyr,
     >                    indptp,
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
c                         - etat 18 - par l'arete de quadrangle 8
c                                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .   1    . pentaedre a decouper                       .
c . listar . e   .   9   . liste des aretes du pentaedre a decouper    .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
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
      parameter ( nompro = 'CMCP18' )
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
#include "ope001.h"
#include "cofpfp.h"
c
c 0.3. ==> arguments
c
      integer lepent
      integer listar(9)
      integer indtri, indtet, indpyr
      integer indptp
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
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer f1, cf1
      integer f2, cf2
      integer f3, cf3
#ifdef _DEBUG_HOMARD_
      integer f4, cf4
      integer f5, cf5
#endif
      integer lesare(2)
      integer tab1(4), tab2(4)
      integer triint(2)
      integer trifad(2,0:2), cotrvo(2,0:2), areqtr(2,2)
      integer nulofa(2)
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
      f1 = facpen(lepent,1)
      cf1 = cofape(lepent,1)
      f2 = facpen(lepent,2)
      cf2 = cofape(lepent,2)
      f3 = facpen(lepent,3)
      cf3 = cofape(lepent,3)
#ifdef _DEBUG_HOMARD_
      cf4 = cofape(lepent,4)
      f4 = facpen(lepent,4)
      cf5 = cofape(lepent,5)
      f5 = facpen(lepent,5)
      write(ulsort,90002) 'f1', f1, cf1
      write(ulsort,90002) 'f2', f2, cf2
      write(ulsort,90002) 'f3', f3, cf3
      write(ulsort,90002) 'f4', f4, cf4
      write(ulsort,90002) 'f5', f5, cf5
#endif
c
c 2.2. ==> Triangles et aretes tracees sur les quadrangles coupes
c
c     trifad(1,0) = triangle central de la face 1 : FF5
c     trifad(1,1) = triangle de la face 1 du cote de F1 : FF5 + 1/2
c     trifad(1,2) = triangle de la face 1 du cote de F2 : FF5 + 2/1
c     areqtr(1,1) : AS3N8
c     areqtr(1,2) : AS6N8
c
c     trifad(2,0) = triangle central de la face 1 : FF4
c     trifad(2,1) = triangle de la face 1 du cote de F1 : FF4 + 1/2
c     trifad(2,2) = triangle de la face 1 du cote de F2 : FF4 + 2/1
c     areqtr(2,1) : AS1N8
c     areqtr(2,2) : AS1N8
c
      if ( codret.eq.0 ) then
c
      nulofa(1) = 5
      nulofa(2) = 4
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP1B', nompro
#endif
      call cmcp1b ( nulofa, lepent,
     >              aretri, nivtri,
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
c====
c====
c 4. Creation de l'arete interne
c====
c====
c 5. Creation des deux triangles internes
c    triint(1) : le triangle interne du cote de F1
c    triint(2) : le triangle interne du cote de F2
c    triint(1) : FA1N8
c    triint(2) : FA4N8
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,92000) indtri+1, indtri+2
#endif
c
      if ( codret.eq.0 ) then
c
      lesare(1) = listar(1)
      lesare(2) = listar(4)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP1C', nompro
#endif
      call cmcp1c ( indtri, triint,
     >              lesare,
     >              areqtr, niveau,
     >              aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              ulsort, langue, codret )
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
      iaux = -indptp
      jaux = cfapen(cofpfp,fampen(lepent))
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYR', nompro
#endif
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >                triint(1),           1,
     >              trifad(1,0), cotrvo(1,0),
     >                triint(2),           1,
     >              trifad(2,0), cotrvo(2,0),
     >                       f3,         cf3,
     >              iaux,  jaux,   indpyr )
c
#ifdef _DEBUG_HOMARD_
      do 600 , iaux = indpyr , indpyr
        write (ulsort,90015) 'Pyra', iaux,
     >                ', faces', (facpyr(iaux,jaux),jaux=1,5)
        write (ulsort,90015) 'Pyra', iaux,
     >                ', codes', (cofapy(iaux,jaux),jaux=1,5)
  600 continue
#endif
c
c====
c 7. Creation des 2 tetraedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93000) indtet+1, indtet+2
#endif
c
      if ( codret.eq.0 ) then
c
      tab1(1) = f1
      tab2(1) = per001(5,cf1)
c
      tab1(2) = f2
      tab2(2) = per001(5,cf2)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP1E', nompro
#endif
      call cmcp1e ( indtet, indptp,
     >              lepent,
     >              trifad, cotrvo, triint,
     >              tab1, tab2,
     >              hettet, tritet, cotrte,
     >              filtet, pertet, famtet,
     >              fampen, cfapen,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 700 , iaux = indtet-1 , indtet
        write (ulsort,90015) 'Tetra', iaux,
     >                ', faces', (tritet(iaux,jaux),jaux=1,4)
        write (ulsort,90015) 'Tetra', iaux,
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
