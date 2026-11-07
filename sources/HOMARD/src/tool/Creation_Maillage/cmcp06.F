      subroutine cmcp06 ( lepent, listar, listso,
     >                    indare, indtri, indtet, indpyr,
     >                    indptp,
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
c                         - etat 06 - par l'arete de triangle 6
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
      parameter ( nompro = 'CMCP06' )
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
#include "ope002.h"
#include "i1i2i3.h"
#include "coftfp.h"
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
      integer nupere, nufami
      integer f1, cf1
      integer f3, cf3
      integer f4, cf4
#ifdef _DEBUG_HOMARD_
      integer f2, cf2
      integer f5, cf5
#endif
      integer noemil, lesnoe(2), lesare(3)
      integer areint(1)
      integer triint(3)
      integer laface(2), coface(2)
      integer trifad(2,0:2), cotrvo(2,0:2), areqtr(2,2)
      integer nulofa(2)
      integer ind001(2)
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
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'listso', listso
#endif
c
c 2.1. ==> grandeurs independantes du cas traite (phase 1)
c          les faces du pentaedre et leurs codes
c
      f1 = facpen(lepent,1)
      cf1 = cofape(lepent,1)
      f3 = facpen(lepent,3)
      cf3 = cofape(lepent,3)
      f4 = facpen(lepent,4)
      cf4 = cofape(lepent,4)
#ifdef _DEBUG_HOMARD_
      f2 = facpen(lepent,2)
      cf2 = cofape(lepent,2)
      f5 = facpen(lepent,5)
      cf5 = cofape(lepent,5)
      write(ulsort,90002) 'f1', f1, cf1
      write(ulsort,90002) 'f2', f2, cf2
      write(ulsort,90002) 'f3', f3, cf3
      write(ulsort,90002) 'f4', f4, cf4
      write(ulsort,90002) 'f5', f5, cf5
      write (ulsort,90015) 'Triangle', f1,
     >                ', aretes', (aretri(f1,jaux),jaux=1,3)
#endif
c
c 2.2. ==> grandeurs dependant du cas traite
c     iaux = numero local de l'arete coupee
c     jaux = numero global de l'arete coupee
c     noemil = noeud milieu de l'arete coupee
c
      iaux = 6
      jaux = listar(iaux)
      noemil = somare(2,filare(jaux))
c
c     lesnoe(1) = sommet a joindre au milieu de l'arete coupee pour
c               definir l'arete interne
      lesnoe(1) = listso(1)
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'noemil', noemil
      write(ulsort,90002) 'lesnoe(1)', lesnoe(1)
#endif
c
c 2.3. ==> Triangles et aretes tracees sur les faces coupees
c     Sens positif : (S1,S2,S3)
c
c     trifad(1,0) = triangle central de la face 1 : FF5
c     trifad(1,1) = triangle de la face 1 du cote de S5 : FF5 + 1/2
c     trifad(1,2) = triangle de la face 1 du cote de S6 : FF5 + 2/1
c     areqtr(1,1) : AS2N6
c     areqtr(1,2) : AS3N6
c
c     trifad(2,0) = triangle 1 de la face 2 : FF2 + 0/1 (FF2D5)
c     trifad(2,1) = triangle 2 de la face 2 : FF2 + 1/0 (FF2D4)
c     areqtr(2,2) : AS4N6
c
      if ( codret.eq.0 ) then
c
      nulofa(1) = 5
      nulofa(2) = 2
c
      ind001(1) = 1
      ind001(2) = 3
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP0B', nompro
#endif
      call cmcp0b ( nulofa, lepent,
     >              i2, i3, i1,
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
c====
c====
c 4. Creation de l'arete interne
c    noemil : N6
c    lesnoe(1) : S1
c    areint(1) : AS1N6
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,91000) indare+1, indare+1
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHPA', nompro
#endif
      iaux = 1
      call cmchpa ( indare, iaux,
     >              noemil, lesnoe, areint,
     >              hetare, somare,
     >              filare, merare, famare,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'areint(1) = ', areint(1),
     >                   ' de ',somare(1,areint(1)),
     >                   ' a ',somare(2,areint(1))
#endif
c
      endif
c
c====
c 5. Creation des trois triangles internes
c    triint(1) : FA2N6
c    triint(2) : FA7N6
c    triint(3) : FA1N6
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,92000) indtri+1, indtri+3
#endif
c
      if ( codret.eq.0 ) then
c
      lesare(1) = listar(2)
      lesare(2) = listar(7)
      lesare(3) = listar(1)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP0C', nompro
#endif
      call cmcp0c ( indtri, triint,
     >              lesare,
     >              areint, areqtr, niveau,
     >              aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 500 , iaux = indtri-2 , indtri
      write (ulsort,90015) 'Triangle', iaux,
     >                ', aretes', (aretri(iaux,jaux),jaux=1,3)
  500 continue
#endif
c
      endif
c
c====
c 6. Creation des deux pyramides
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,95000) indpyr+1, indpyr+2
#endif
c
      if ( codret.eq.0 ) then
c
      laface(1) = f4
      coface(1) = per002(3,cf4)
c
      laface(2) = f3
      coface(2) = per002(3,cf3)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP0D', nompro
#endif
      call cmcp0d ( indpyr, indptp,
     >              lepent,
     >              trifad, cotrvo, triint,
     >              laface, coface,
     >              hetpyr, facpyr, cofapy,
     >              filpyr, perpyr, fampyr,
     >              fampen, cfapen,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 600 , iaux = indpyr-1 , indpyr
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
c 7. Creation du tetraedre
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93000) indtet+1, indtet+1
#endif
c
      if ( codret.eq.0 ) then
c
      nupere = -indptp
      nufami = cfapen(coftfp,fampen(lepent))
c
      coface(1) = per001(6,cf1)
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTET', nompro
#endif
      call cmctet ( tritet, cotrte, famtet,
     >              hettet, filtet, pertet,
     >                  f1, trifad(1,0), triint(3), triint(1),
     >           coface(1), cotrvo(1,0),         1,         6,
     >           nupere, nufami, indtet )
c
#ifdef _DEBUG_HOMARD_
      do 700 , iaux = indtet , indtet
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
