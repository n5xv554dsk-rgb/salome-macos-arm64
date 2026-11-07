      subroutine cmch63 ( lehexa, listar, listso,
     >                    indare, indtri, indpyr,
     >                    indptp,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    filqua,
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
c                         - par 1 Arete - etat 63
c                                              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . listar . e   .   12   . liste des aretes de l'hexaedre a decouper  .
c . listso . e   .    8   . liste des sommets de l'hexaedre a decouper .
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
      parameter ( nompro = 'CMCH63' )
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
#include "cofpfh.h"
c
c 0.3. ==> arguments
c
      integer lehexa
      integer listar(12), listso(8)
      integer indare, indtri, indpyr
      integer indptp
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
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
      integer iaux, jaux
      integer nlarco, nuarco
      integer noemil, somm(2)
      integer areint(2)
      integer areqtr(2,2)
      integer triint(5)
      integer f1, f2, f3, f4, f5, f6
      integer cf1, cf2, cf3, cf4, cf5, cf6
      integer trifad(2,0:2), cotrvo(2,0:2)
      integer niveau
      integer laface, coface
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
c 1.1. ==> messages
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
c 1.2. ==> grandeurs independantes du cas traite (phase 1)
c          les faces de l'hexaedre et leurs codes
c
      f1 = quahex(lehexa,1)
      f2 = quahex(lehexa,2)
      f3 = quahex(lehexa,3)
      f4 = quahex(lehexa,4)
      f5 = quahex(lehexa,5)
      f6 = quahex(lehexa,6)
      cf1 = coquhe(lehexa,1)
      cf2 = coquhe(lehexa,2)
      cf3 = coquhe(lehexa,3)
      cf4 = coquhe(lehexa,4)
      cf5 = coquhe(lehexa,5)
      cf6 = coquhe(lehexa,6)
c
c 1.3. ==> grandeurs dependant du cas traite
c     nlarco = numero local de l'arete coupee
      nlarco = 3
c
c     nuarco = numero global de l'arete coupee
      nuarco = listar(nlarco)
c
c     noemil = noeud milieu de l'arete coupee
      noemil = somare(2,filare(nuarco))
c
c     somm(1) = sommet a joindre au milieu de l'arete coupee pour
c               definir la 1ere arete interne
      somm(1) = listso(6)
c     somm(2) = sommet a joindre au milieu de l'arete coupee pour
c               definir la 2nde arete interne
      somm(2) = listso(7)
#ifdef _DEBUG_HOMARD_
      write(ulsort,2000) 'listso', listso
      write(ulsort,2000) 'nuarco', nuarco
      write(ulsort,2000) 'noemil', noemil
      write(ulsort,2001) 'somm(1)', somm(1),'somm(2)', somm(2)
 2000 format(a,10i10)
 2001 format(a,i10,', ',a,i10)
#endif
c
c 2.2.6. ==> Triangles et aretes tracees sur les faces coupees en 3
c            L'arete coupee s'appuie sur deux faces de l'hexaedre.
c            trifad(1,*)  se rapporte a celle de plus petit numero local
c            trifad(2,*)  se rapporte a celle de plus grand numero local
c     trifad(p,0) : triangle central de ce decoupage
c     trifad(p,1) : triangle contenant le sommet de l'arete coupee qui a
c                   le plus petit numero local
c     trifad(p,2) : triangle contenant le sommet de l'arete coupee qui a
c                   le plus petit numero local
c     cotrvo(p,0/1/2) : futur code du triangle trifad(p,0/1/2) dans la
c                       description de la pyramide
c     areqtr(p,1) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,1)
c     areqtr(p,2) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,2)
c
c     trifad(1,0) = triangle central de la face 1 : FF1
c     trifad(1,1) = triangle de la face 1 du cote de S2 : FF1 + 1/2
c     trifad(1,2) = triangle de la face 1 du cote de S3 : FF1 + 2/1
c     areqtr(1,1) : AS1N3
c     areqtr(1,2) : AS4N3
      laface = f1
      coface = cf1
      trifad(1,0) = -filqua(laface)
      if ( coface.lt.5 ) then
        cotrvo(1,0) = 2
        trifad(1,1) = trifad(1,0) + 1
        cotrvo(1,1) = 2
        trifad(1,2) = trifad(1,0) + 2
        cotrvo(1,2) = 1
        areqtr(1,1) = aretri(trifad(1,0),1)
        areqtr(1,2) = aretri(trifad(1,0),3)
      else
        cotrvo(1,0) = 4
        trifad(1,1) = trifad(1,0) + 2
        cotrvo(1,1) = 6
        trifad(1,2) = trifad(1,0) + 1
        cotrvo(1,2) = 4
        areqtr(1,1) = aretri(trifad(1,0),3)
        areqtr(1,2) = aretri(trifad(1,0),1)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'laface = ', laface,', coface = ', coface
      write(ulsort,1789) 'trifad(1,0) = ', trifad(1,0),
     >                   'trifad(1,1) = ', trifad(1,1),
     >                   'trifad(1,2) = ', trifad(1,2)
      write(ulsort,1789) 'cotrvo(1,0) = ', cotrvo(1,0),
     >                   'cotrvo(1,1) = ', cotrvo(1,1),
     >                   'cotrvo(1,2) = ', cotrvo(1,2)
      write(ulsort,1789) 'areqtr(1,1) = ', areqtr(1,1),
     >                   ' de ',somare(1,areqtr(1,1)),
     >                   ' a ',somare(2,areqtr(1,1))
      write(ulsort,1789) 'areqtr(1,2) = ', areqtr(1,2),
     >                   ' de ',somare(1,areqtr(1,2)),
     >                   ' a ',somare(2,areqtr(1,2))
#endif
c
c     trifad(2,0) = triangle central de la face 2 : FF4
c     trifad(2,1) = triangle de la face 2 du cote de S2 : FF4 + 2/1
c     trifad(2,2) = triangle de la face 2 du cote de S3 : FF4 + 1/2
c     areqtr(2,1) : AS5N3
c     areqtr(2,2) : AS8N3
      laface = f4
      coface = cf4
      trifad(2,0) = -filqua(laface)
      if ( coface.lt.5 ) then
        cotrvo(2,0) = 2
        trifad(2,1) = trifad(2,0) + 2
        cotrvo(2,1) = 1
        trifad(2,2) = trifad(2,0) + 1
        cotrvo(2,2) = 1
        areqtr(2,1) = aretri(trifad(2,0),3)
        areqtr(2,2) = aretri(trifad(2,0),1)
      else
        cotrvo(2,0) = 4
        trifad(2,1) = trifad(2,0) + 1
        cotrvo(2,1) = 4
        trifad(2,2) = trifad(2,0) + 2
        cotrvo(2,2) = 4
        areqtr(2,1) = aretri(trifad(2,0),1)
        areqtr(2,2) = aretri(trifad(2,0),3)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'laface = ', laface,', coface = ', coface
      write(ulsort,1789) 'trifad(2,0) = ', trifad(2,0),
     >                   'trifad(2,1) = ', trifad(2,1),
     >                   'trifad(2,2) = ', trifad(2,2)
      write(ulsort,1789) 'cotrvo(2,0) = ', cotrvo(2,0),
     >                   'cotrvo(2,1) = ', cotrvo(2,1),
     >                   'cotrvo(2,2) = ', cotrvo(2,2)
      write(ulsort,1789) 'areqtr(2,1) = ', areqtr(2,1),
     >                   ' de ',somare(1,areqtr(2,1)),
     >                   ' a ',somare(2,areqtr(2,1))
      write(ulsort,1789) 'areqtr(2,2) = ', areqtr(2,2),
     >                   ' de ',somare(1,areqtr(2,2)),
     >                   ' a ',somare(2,areqtr(2,2))
#endif
c
c 1.4. ==> grandeurs independantes du cas traite (phase 2)
c
c     niveau = niveau des triangles des conformites des faces
      niveau = nivtri(trifad(1,0))
#ifdef _DEBUG_HOMARD_
      write(ulsort,1400) niveau
 1400 format('niveau =',i3)
#endif
c
c====
c 2. Creation des deux aretes internes
c    noemil : N3
c    somm(1) : S6
c    somm(2) : S7
c    areint(1) : AS6N3
c    areint(2) : AS7N3
c====
c
      if ( codret.eq.0 ) then
c
      do 21 , iaux = 1 , 2
c
        indare = indare + 1
        areint(iaux) = indare
c
        somare(1,areint(iaux)) = min ( noemil , somm(iaux) )
        somare(2,areint(iaux)) = max ( noemil , somm(iaux) )
c
        famare(areint(iaux)) = 1
        hetare(areint(iaux)) = 50
        merare(areint(iaux)) = 0
        filare(areint(iaux)) = 0
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'areint(iaux) = ', areint(iaux),
     >                   ' de ',somare(1,areint(iaux)),
     >                   ' a ',somare(2,areint(iaux))
#endif
c
   21 continue
c
      endif
c
c====
c 3. Creation des cinq triangles internes
c    areqtr(1,1) : AS1N3
c    areqtr(1,2) : AS4N3
c    areqtr(2,1) : AS5N3
c    areqtr(2,2) : AS8N3
c    areint(1) : AS6N3
c    areint(2) : AS7N3
c    triint(1) : le triangle contenant l'arete areqtr(1,1)
c    triint(3) : le triangle contenant l'arete areqtr(1,2)
c    triint(2) : le triangle contenant l'arete areqtr(2,1)
c    triint(4) : le triangle contenant l'arete areqtr(2,2)
c    triint(5) : le triangle qui s'appuie sur l'arete opposee a l'arete
c                coupee ; il ne touche donc pas les faces coupees
c    triint(1) : FN3A5
c    triint(2) : FN3A7
c    triint(3) : FN3A9
c    triint(4) : FN3A12
c    triint(5) : FN3A10
c     par convention, le niveau est le meme que les triangles fils
c     sur l'exterieur
c====
c
      iaux = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_63', nompro
      write (ulsort,3000) indtri+1, indtri+5
 3000 format('.. triangles de',i10,' a',i10)
#endif
      triint(1) = indtri + 1
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(1), listar( 5), areqtr(1,1), areint(1),
     >              iaux, niveau )
c
      triint(2) = indtri + 2
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(2), listar( 7), areqtr(1,2), areint(2),
     >              iaux, niveau )
c
      triint(3) = indtri + 3
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(3), listar( 9), areqtr(2,1), areint(1),
     >              iaux, niveau )
c
      triint(4) = indtri + 4
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(4), listar(12), areint(2), areqtr(2,2),
     >              iaux, niveau )
c
      triint(5) = indtri + 5
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(5), listar(10), areint(1), areint(2),
     >              iaux, niveau )
c
      indtri = triint(5)
c
c====
c 4. Creation des quatre pyramides
c    Elles arrivent dans l'ordre de numerotation locale de leur
c    quadrangle dans l'hexaedre
c     trifad(1,0) : FF1
c     trifad(1,1) : FF1 + 1/2
c     trifad(1,2) : FF1 + 2/1
c     trifad(2,0) : FF4
c     trifad(2,1) : FF4 + 2/1
c     trifad(2,2) : FF4 + 1/2
c    triint(1) : FN3A5
c    triint(2) : FN3A7
c    triint(3) : FN3A9
c    triint(4) : FN3A12
c    triint(5) : FN3A10
c====
c
      jaux = cfahex(cofpfh,famhex(lehexa))
      iaux = -indptp
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYR_63', nompro
      write (ulsort,4000) indpyr+1, indpyr+4
 4000 format('.. pyramides de',i10,' a',i10)
#endif
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trifad(1,1), cotrvo(1,1),
     >              trifad(2,1), cotrvo(2,1),
     >                triint(3),           3,
     >                triint(1),           6,
     >                       f2,         cf2,
     >              iaux,  jaux,   indpyr )
c
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trifad(1,0), cotrvo(1,0),
     >                triint(1),           3,
     >                triint(5),           3,
     >                triint(2),           6,
     >                       f3,         cf3,
     >              iaux,  jaux,   indpyr )
c
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >               trifad(1,2), cotrvo(1,2),
     >                triint(2),           3,
     >                triint(4),           3,
     >              trifad(2,2), cotrvo(2,2),
     >                       f5,         cf5,
     >              iaux,  jaux,   indpyr )
c
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >                triint(3),           5,
     >              trifad(2,0), cotrvo(2,0),
     >                triint(4),           5,
     >                triint(5),           6,
     >                       f6,         cf6,
     >              iaux,  jaux,   indpyr )
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
