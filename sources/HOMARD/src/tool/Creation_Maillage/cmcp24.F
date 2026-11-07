      subroutine cmcp24 ( lepent, listar,
     >                    indare, indtri, indtet,
     >                    indptp,
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
c                         - etat 24 - par les aretes 4 et 8
c                                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .   1    . pentaedre a decouper                       .
c . listar . e   .   9   . liste des aretes du pentaedre a decouper    .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
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
      parameter ( nompro = 'CMCP24' )
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
#include "i1i2i3.h"
c
c 0.3. ==> arguments
c
      integer lepent
      integer listar(9)
      integer indare, indtri, indtet
      integer indptp
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
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer f1, cf1
#ifdef _DEBUG_HOMARD_
      integer f2, cf2
      integer f3, cf3
      integer f4, cf4
      integer f5, cf5
#endif
      integer noemil(2), lesare(1)
      integer areint(1)
      integer triint(6)
      integer trifad(4,0:2), cotrvo(4,0:2), areqtr(4,0:2)
      integer nulofa(4)
      integer niveau
      integer coface
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
#ifdef _DEBUG_HOMARD_
      f2 = facpen(lepent,2)
      cf2 = cofape(lepent,2)
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
      iaux = 4
      jaux = listar(iaux)
      noemil(1) = somare(2,filare(jaux))
c
      iaux = 8
      jaux = listar(iaux)
      noemil(2) = somare(2,filare(jaux))
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'noemil', noemil
#endif
c
c 2.3. ==> Triangles et aretes tracees sur les faces coupees
c
c     trifad(1,0) = triangle central de la face 1 : FF3
c     trifad(1,1) = triangle de la face 1 du cote de S6 : FF3 + 1/2
c     trifad(1,2) = triangle de la face 1 du cote de S4 : FF3 + 2/1
c     areqtr(1,1) : AS3N4
c     areqtr(1,2) : AS1N4
c
c     trifad(2,0) = triangle central de la face 2 : FF5
c     trifad(2,1) = triangle de la face 2 du cote de F2 : FF5 + 1/2
c     trifad(2,2) = triangle de la face 2 du cote de F1 : FF5 + 2/1
c     areqtr(2,1) : AS6N8
c     areqtr(2,2) : AS3N8
c
c     trifad(3,0) = triangle central de la face 3 : FF4
c     trifad(3,1) = triangle de la face 3 du cote de F2 : FF4 + 1/2
c     trifad(3,2) = triangle de la face 3 du cote de F1 : FF4 + 2/1
c     areqtr(3,1) : AS4N8
c     areqtr(3,2) : AS1N8
c
c     trifad(4,0) = triangle 1 de la face 4 : FF2 + 0/1 (FF2D6)
c     trifad(4,1) = triangle 2 de la face 4 : FF2 + 1/0 (FF2D5)
c     areqtr(4,1) : AS5N4
c
c     areqtr(1,0) : AS6N4
c     areqtr(2,0) : AS4N4
c     areqtr(3,0) : AS5N8
c
      if ( codret.eq.0 ) then
c
      nulofa(1) = 3
      nulofa(2) = 5
      nulofa(3) = 4
      nulofa(4) = 2
c
      iaux = 5
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP2B', nompro
#endif
      call cmcp2b ( nulofa, lepent,
     >              i1, i2, i3, iaux,
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
c    noemil(1) : N4
c    noemil(2) : N8
c    areint(1) : AN4N8
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,91000) indare+1, indare+1
#endif
c
      if ( codret.eq.0 ) then
c
      indare = indare + 1
      areint(1) = indare
c
      somare(1,areint(1)) = min ( noemil(1) , noemil(2) )
      somare(2,areint(1)) = max ( noemil(1) , noemil(2) )
c
      famare(areint(1)) = 1
      hetare(areint(1)) = 50
      merare(areint(1)) = 0
      filare(areint(1)) = 0
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'areint(1) = ', areint(1),
     >                   ' de ',somare(1,areint(1)),
     >                   ' a ',somare(2,areint(1))
#endif
c
      endif
c====
c 5. Creation des six triangles internes
c    triint(1) : FA1
c    triint(2) : FS3
c    triint(3) : FS1
c    triint(4) : FS6
c    triint(5) : FS4
c    triint(6) : FS5
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,92000) indtri+1, indtri+6
#endif
c
      if ( codret.eq.0 ) then
c
      lesare(1) = listar(1)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP2C', nompro
#endif
      call cmcp2c ( indtri, triint,
     >              lesare,
     >              areint, areqtr, niveau,
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
c====
c 7. Creation des 6 tetraedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,93000) indtet+1, indtet+6
#endif
c
      if ( codret.eq.0 ) then
c
      coface = per001(5,cf1)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP2E', nompro
#endif
      call cmcp2e ( indtet, indptp,
     >              lepent,
     >              trifad, cotrvo, triint,
     >              f1, coface,
     >              hettet, tritet, cotrte,
     >              filtet, pertet, famtet,
     >              fampen, cfapen,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      do 700 , iaux = indtet-5 , indtet
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
