      subroutine cmcp51 ( lepent, listar, listso,
     >                    indnoe, indare, indtri, indtet,
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
c                         - etat 51 - par la face F1
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
      parameter ( nompro = 'CMCP51' )
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
#include "ope001.h"
c
c 0.3. ==> arguments
c
      integer lepent
      integer listar(9), listso(6)
      integer indnoe, indare, indtri, indtet
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
      integer f2, cf2
#ifdef _DEBUG_HOMARD_
      integer f1, cf1
      integer f3, cf3
      integer f4, cf4
      integer f5, cf5
#endif
      integer lesnoe(6), lesare(7)
      integer areint(8)
      integer triint(15)
      integer trifad(4,0:3), cotrvo(4,0:3), areqtr(4,0:3)
      integer nulofa(4)
      integer ind001(0:3)
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
      f2 = facpen(lepent,2)
      cf2 = cofape(lepent,2)
#ifdef _DEBUG_HOMARD_
      f1 = facpen(lepent,1)
      cf1 = cofape(lepent,1)
      f3 = facpen(lepent,3)
      cf3 = cofape(lepent,3)
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
c     iaux = numero local de l'arete coupee
c     jaux = numero global de l'arete coupee
c     noemil = noeud milieu de l'arete coupee
c
      iaux = 1
      jaux = listar(iaux)
      lesnoe(4) = somare(2,filare(jaux))
c
      iaux = 2
      jaux = listar(iaux)
      lesnoe(5) = somare(2,filare(jaux))
c
      iaux = 3
      jaux = listar(iaux)
      lesnoe(6) = somare(2,filare(jaux))
c
c     lesnoe(i) = sommet a joindre au centre du pentaedre pour creer
c                 l'arete interne i
c
      lesnoe(1) = listso(4)
      lesnoe(2) = listso(5)
      lesnoe(3) = listso(6)
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'lesnoe', lesnoe
#endif
c
c 2.3. ==> Triangles et aretes tracees sur les faces coupees
c
c     trifad(1,0) = triangle central de la face 1 : FF3
c     trifad(1,1) = triangle de la face 1 voisin de F4 : FF3 + 1/2
c     trifad(1,2) = triangle de la face 1 voisin de F5 : FF3 + 2/1
c     areqtr(1,1) : AS4N1
c     areqtr(1,2) : AS6N1
c     areqtr(1,0) : AS1N1
c     areqtr(1,3) : AS3N1
c
c     trifad(2,0) = triangle central de la face 2 : FF4
c     trifad(2,1) = triangle de la face 2 voisin de F5 : FF4 + 2/1
c     trifad(2,2) = triangle de la face 2 voisin de F3 : FF4 + 1/2
c     areqtr(2,1) : AS5N2
c     areqtr(2,2) : AS4N2
c     areqtr(2,0) : AS2N2
c     areqtr(2,3) : AS1N2
c
c     trifad(3,0) = triangle central de la face 3 : FF5
c     trifad(3,1) = triangle de la face 3 voisin de F3 : FF5 + 2/1
c     trifad(3,2) = triangle de la face 3 voisin de F4 : FF5 + 1/2
c     areqtr(3,1) : AS6N3
c     areqtr(3,2) : AS5N3
c     areqtr(3,0) : AS3N3
c     areqtr(3,3) : AS2N3
c
c     trifad(4,0) = triangle central de la face decoupee : FF1
c     trifad(4,1) = triangle de la face voisin de F4 et F3 : FF1 + 1/2/3
c     trifad(4,2) = triangle de la face voisin de F5 et F4 : FF1 + 2/3/1
c     trifad(4,3) = triangle de la face voisin de F3 et F5 : FF1 + 3/1/2
c     areqtr(4,1) : arete de trifad(4,1) : AN1N2
c     areqtr(4,2) : arete de trifad(4,2) : AN2N3
c     areqtr(4,3) : arete de trifad(4,3) : AN1N3
c
      if ( codret.eq.0 ) then
c
      nulofa(1) = 3
      nulofa(2) = 4
      nulofa(3) = 5
      nulofa(4) = 1
c
      ind001(0) = 5
      ind001(1) = 1
      ind001(2) = 3
      ind001(3) = 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP5B', nompro
#endif
      call cmcp5b ( nulofa, lepent,
     >              i1, i2, i3, ind001,
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
c    areint(1) : AS4N0
c    areint(2) : AS5N0
c    areint(3) : AS6N0
c    areint(4) : AN1N0
c    areint(5) : AN2N0
c    areint(6) : AN3N0
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,98000) indnoe+1, indnoe+1
      write (ulsort,91000) indare+1, indare+6
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHPB', nompro
#endif
      iaux = 6
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
c 5. Creation des 15 triangles internes
c      triint( 1) = FS4N12
c      triint( 2) = FS5N23
c      triint( 3) = FS6N13
c      triint( 4) = FN1N2
c      triint( 5) = FN2N3
c      triint( 6) = FN1N3
c      triint( 7) = FA4
c      triint( 8) = FA5
c      triint( 9) = FA6
c      triint(10) = FS4N1
c      triint(11) = FS5N2
c      triint(12) = FS6N3
c      triint(13) = FS6N1
c      triint(14) = FS4N2
c      triint(15) = FS5N3
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,92000) indtri+1, indtri+15
#endif
c
      if ( codret.eq.0 ) then
c
      lesare(1) = listar(4)
      lesare(2) = listar(5)
      lesare(3) = listar(6)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP5C', nompro
#endif
      call cmcp5c ( indtri, triint,
     >              lesare,
     >              areint, areqtr, niveau,
     >              aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 500 , iaux = indtri-14 , indtri
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
      iaux = 2
c
      jaux = per001(6,cf2)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP5E', nompro
#endif
      call cmcp5e ( indtet, indptp,
     >              lepent,
     >              trifad, cotrvo, triint,
     >              iaux, f2, jaux,
     >              hettet, tritet, cotrte,
     >              filtet, pertet, famtet,
     >              fampen, cfapen,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 700 , iaux = indtet-10 , indtet
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
