      subroutine cmch84 ( lehexa, listar, listso,
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
c                         - par 3 Aretes - etat 84
c                                               --
c    Decoupage par les aretes 2, 8 et 9
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
      parameter ( nompro = 'CMCH84' )
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
      integer lehexa
      integer listar(12), listso(8)
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
      integer iaux
      integer lesnoe(11), lesare(9)
      integer nulofa(6)
      integer areint(11)
      integer areqtr(6,2)
      integer triint(27)
      integer trifad(6,0:2), cotrvo(6,0:2)
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
c      lesnoe(2) = S1
c      lesnoe(3) = S8
c      lesnoe(4) = S3
c      lesnoe(5) = S6
c      lesnoe(6) = S5
c      lesnoe(7) = S7
c      lesnoe(8) = S2
c      lesnoe( 9) = N2
c      lesnoe(10) = N8
c      lesnoe(11) = N9
c====
c     lesnoe(i) = sommet a joindre au centre de l'hexaedre pour
c                 definir la ieme arete interne
      lesnoe(1) = listso(4)
      lesnoe(2) = listso(1)
      lesnoe(3) = listso(8)
      lesnoe(4) = listso(3)
      lesnoe(5) = listso(6)
      lesnoe(6) = listso(5)
      lesnoe(7) = listso(7)
      lesnoe(8) = listso(2)
c
c     iaux = numero local de la 1ere arete coupee
c
      iaux = 2
c
c     lesnoe(9) = noeud milieu de la 1ere arete coupee
      lesnoe(9) = somare(2,filare(listar(iaux)))
#ifdef _DEBUG_HOMARD_
      write(ulsort,2001) listar(iaux),
     > filare(listar(iaux)), filare(listar(iaux))+1
      write(ulsort,2002) lesnoe(9)
 2001 format('arete 1 = ',i10,', de filles',2i10)
 2002 format('lesnoe(9)',i10)
#endif
c
c     iaux = numero local de la 2eme arete coupee 
c
      iaux = 8
c
c     lesnoe(10) = noeud milieu de la 2eme arete coupee
      lesnoe(10) = somare(2,filare(listar(iaux)))
#ifdef _DEBUG_HOMARD_
      write(ulsort,2003) listar(iaux),
     > filare(listar(iaux)), filare(listar(iaux))+1
      write(ulsort,2004) lesnoe(10)
 2003 format('arete 2 = ',i10,', de filles',2i10)
 2004 format('lesnoe(10)',i10)
#endif
c
c     iaux = numero local de la 3eme arete coupee 
c
      iaux = 9
c
c     lesnoe(11) = noeud milieu de la 3eme arete coupee
      lesnoe(11) = somare(2,filare(listar(iaux)))
#ifdef _DEBUG_HOMARD_
      write(ulsort,2005) listar(iaux),
     > filare(listar(iaux)), filare(listar(iaux))+1
      write(ulsort,2006) lesnoe(11)
 2005 format('arete 3 = ',i10,', de filles',2i10)
 2006 format('lesnoe(11)',i10)
#endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,2100) lesnoe(1), lesnoe(2),
     >                   lesnoe(3), lesnoe(4),
     >                   lesnoe(5), lesnoe(6),
     >                   lesnoe(7), lesnoe(8)
 2100 format('lesnoe(1)',i10,', lesnoe(2) = ',i10,
     >     /,'lesnoe(3)',i10,', lesnoe(4) = ',i10,
     >     /,'lesnoe(5)',i10,', lesnoe(6) = ',i10,
     >     /,'lesnoe(7)',i10,', lesnoe(8) = ',i10)
#endif
c
c  Triangles et aretes tracees sur les faces coupees en 3
c            On traite les faces de l'hexaedre coupees en 3 comme suit :
c            . la 1ere et la 2eme partagent la 1ere arete coupee
c              La 1ere face est celle qui n'a pas de point commun
c              avec la 2eme arete coupee.
c            . la 3eme et la 4eme partagent la 2nde arete coupee
c              La 3eme face est celle qui n'a pas de point commun
c              avec la 3eme arete coupee.
c            . la 5eme et la 6eme partagent la 3eme arete coupee
c              La 5eme face est celle qui n'a pas de point commun
c              avec la 1ere arete coupee.
c            . le 1er et le 2eme sommet sont les extremites de la 1ere
c              arete coupee ; le 1er est celui appartenant a
c              la 3eme face.
c            . le 3eme et le 4eme sommet sont les extremites de la 2eme
c              arete coupee ; le 3eme est celui appartenant a
c              la 5eme face.
c            . le 5eme et le 6eme sommet sont les extremites de la 3eme
c              arete coupee ; le 5eme est celui appartenant a
c              la 1ere face.
c            . le 7eme sommet est le dernier sommet de la 1ere face
c            . le 8eme sommet est le dernier sommet de la 2eme face
c     Sur la p-eme face :
c     trifad(p,0) : triangle central de ce decoupage
c     trifad(p,1) : triangle bordant l'arete non decoupee du cote du
c                   sommet de plus petit numero dans lesnoe
c     trifad(p,2) : triangle bordant l'arete non decoupee du cote du
c                   sommet de grand petit numero dans lesnoe
c     cotrvo(p,0/1/2) : futur code du triangle trifad(p,0/1/2) dans la
c                       description du tetraedre voisin
c     areqtr(p,1) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,1)
c     areqtr(p,2) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,2)
c
c     trifad(1,0) = triangle central de la face 1 : FF3
c     trifad(1,1) = triangle de la face 1 vers le sommet 1 : FF3 + 1/2
c     trifad(1,2) = triangle de la face 1 de l'autre cote : FF3 + 2/1
c     areqtr(1,1) : AS7N2
c     areqtr(1,2) : AS6N2
c
c     trifad(2,0) = triangle central de la face 2 : FF1
c     trifad(2,1) = triangle de la face 2 vers le sommet 1 : FF1 + 2/1
c     trifad(2,2) = triangle de la face 2 de l'autre cote : FF1 + 1/2
c     areqtr(2,1) : AS3N2
c     areqtr(2,2) : AS2N2
c
c     trifad(3,0) = triangle central de la face 3 : FF5
c     trifad(3,1) = triangle de la face 3 vers le sommet 3 : FF5 + 1/2
c     trifad(3,2) = triangle de la face 3 de l'autre cote : FF5 + 2/1
c     areqtr(3,1) : AS7N8
c     areqtr(3,2) : AS4N8
c
c     trifad(4,0) = triangle central de la face 4 : FF4
c     trifad(4,1) = triangle de la face 4 vers le sommet 3 : FF4 + 2/1
c     trifad(4,2) = triangle de la face 4 de l'autre cote : FF4 + 1/2
c     areqtr(4,1) : AS5N8
c     areqtr(4,2) : AS2N8
c
c     trifad(5,0) = triangle central de la face 5 : FF6
c     trifad(5,1) = triangle de la face 5 vers le sommet 5 : FF6 + 2/1
c     trifad(5,2) = triangle de la face 5 de l'autre cote : FF6 + 1/2
c     areqtr(5,1) : AS7N9
c     areqtr(5,2) : AS8N9
c
c     trifad(6,0) = triangle central de la face 6 : FF2
c     trifad(6,1) = triangle de la face 6 vers le sommet 5 : FF2 + 1/2
c     trifad(6,2) = triangle de la face 6 de l'autre cote : FF2 + 2/1
c     areqtr(6,1) : AS1N9
c     areqtr(6,2) : AS2N9
c
      nulofa(1) = 3
      nulofa(2) = 1
      nulofa(3) = 5
      nulofa(4) = 4
      nulofa(5) = 6
      nulofa(6) = 2
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHAL', nompro
#endif
      call cmchal ( nulofa, lehexa,
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
c 3. Creation du noeud interne et des onze aretes internes
c    noecen : N0
c    areint( 1) : AS4N0
c    areint( 2) : AS1N0
c    areint( 3) : AS8N0
c    areint( 4) : AS3N0
c    areint( 5) : AS6N0
c    areint( 6) : AS5N0
c    areint( 7) : AS7N0
c    areint( 8) : AS2N0
c    areint( 9) : AN2N0
c    areint(10) : AN8N0
c    areint(11) : AN9N0
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHAB', nompro
      write (ulsort,3001) indnoe+1
 3001 format('.. noeud',i10)
      write (ulsort,3002) indare+1, indare+11
 3002 format('.. aretes de',i10,' a',i10)
#endif
      iaux = 11
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
c    triint( 1) : FA10
c    triint( 2) : FA3
c    triint( 3) : FA7
c    triint( 4) : FA4
c    triint( 5) : FA12
c    triint( 6) : FA1
c    triint( 7) : FA11
c    triint( 8) : FA5
c    triint( 9) : FA4
c    triint(10) : FS7N2
c    triint(11) : FS6N2
c    triint(12) : FS3N2
c    triint(13) : FS2N2
c    triint(14) : FS7N8
c    triint(15) : FS4N8
c    triint(16) : FS5N8
c    triint(17) : FS2N8
c    triint(18) : FS7N9
c    triint(19) : FS8N9
c    triint(20) : FS1N9
c    triint(21) : FS2N9
c    triint(22) : FS4N2
c    triint(23) : FS1N2
c    triint(24) : FS8N8
c    triint(25) : FS3N8
c    triint(26) : FS6N9
c    triint(27) : FS5N9
c====
c
      if ( codret.eq.0 ) then
c
      lesare( 1) = listar(10)
      lesare( 2) = listar(3)
      lesare( 3) = listar(7)
      lesare( 4) = listar(6)
      lesare( 5) = listar(12)
      lesare( 6) = listar(1)
      lesare( 7) = listar(11)
      lesare( 8) = listar(5)
      lesare( 9) = listar(4)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHAQ', nompro
      write (ulsort,4000) indtri+1, indtri+2
 4000 format('.. triangles de',i10,' a',i10)
#endif
      call cmchaq ( indtri, triint,
     >              lesare,
     >              trifad, areint, areqtr, niveau,
     >              aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. Creation des dix-huit tetraedres
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHAN', nompro
      write (ulsort,5000) indtet+1, indtet+18
 5000 format('.. tetraedres de',i10,' a',i10)
#endif
c
      iaux = 84
      call cmchan ( lehexa, iaux, indtet, indptp,
     >              trifad, cotrvo, triint,
     >              hettet, tritet, cotrte,
     >              filtet, pertet, famtet,
     >              famhex, cfahex,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 6. la fin
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
