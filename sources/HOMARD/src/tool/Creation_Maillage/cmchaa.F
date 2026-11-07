      subroutine cmchaa ( nulofa, lehexa,
     >                    somare,
     >                    aretri, nivtri,
     >                    filqua,
     >                    quahex, coquhe,
     >                    niveau, areqtr,
     >                    trifad, cotrvo,
     >                    ulsort, langue, codret )
c
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
c                         - par 2 Aretes - phase A
c                                 -              -
c    Remarque : cmchaa, cmchak et cmchal sont des clones
c               cmchak et cmchal sont symetriques
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nulofa . e   .   4    . numero local des faces a traiter           .
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . quahex . e   .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nouvhf*6. codes des 6 quadrangles des hexaedres      .
c . niveau .  s  .   1    . niveau des faces issus du decoupage        .
c . areqtr .  s  .  (4,2) . aretes tracees sur les faces decoupees     .
c . trifad .  s  .(4,0:2) . triangles traces sur les faces decoupees   .
c . cotrvo .  s  .(4,0:2) . code des triangles dans les volumes        .
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
      parameter ( nompro = 'CMCHAA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer lehexa, nulofa(4)
      integer somare(2,nouvar)
      integer aretri(nouvtr,3), nivtri(nouvtr)
      integer filqua(nouvqu)
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer niveau
      integer areqtr(4,2)
      integer trifad(4,0:2), cotrvo(4,0:2)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
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
#ifdef _DEBUG_HOMARD_
 1789 format(5(a,i5,', '))
#endif
c
      codret = 0
c
c====
c 2. Triangles et aretes tracees sur les faces coupees en 3
c            La premiere pyramide s'appuie sur celle des 2 faces de
c            l'hexaedre qui est non decoupee et de plus petit numero
c            local. Le positionnement de la pyramide a defini une
c            orientation de sa face quadrangulaire.
c            On traite les faces de l'hexaedre coupees en 3 comme suit :
c            . la 1ere et la 2eme partagent la 1ere arete coupee
c            . la 3eme et la 4eme partagent la 2nde arete coupee
c            Le choix de la 1ere est tel que l'ordre 1/2 corresponde a
c            l'orientation de la pyramide numero 1.
c            . Pour 2 aretes en vis-a-vis :
c              Le choix de la 3eme est tel que l'ordre 3/4 corresponde a
c              l'orientation de la pyramide numero 1.
c            . Pour 2 aretes non en vis-a-vis :
c              Le choix de la 3eme est tel que l'ordre 3/4 corresponde a
c              l'orientation de la pyramide numero 2.
c     trifad(p,0) : triangle central de ce decoupage
c     . Pour 2 aretes en vis-a-vis :
c       trifad(p,1) : triangle bordant l'arete non decoupee qui
c                     appartient a la pyramide 1
c       trifad(p,2) : triangle bordant l'arete non decoupee qui
c                     appartient a la pyramide 2
c      . Pour 2 aretes non en vis-a-vis :
c       trifad(p,1) : triangle ayant une arete commune a une pyramide
c       trifad(p,2) : triangle sans arete commune avec une pyramide
c     cotrvo(p,0/1/2) : futur code du triangle trifad(p,0/1/2) dans la
c                       description du tetraedre voisin
c     areqtr(p,1) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,1)
c     areqtr(p,2) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,2)
c====
c
c 2.1. ==> Face 1
c     trifad(1,0) = triangle central de la face 1 : FFi
c     . Pour 2 aretes en vis-a-vis :
c       trifad(1,1) = triangle de la face 1 bordant PYR1 : FFi + 1/2
c       trifad(1,2) = triangle de la face 1 bordant PYR2 : FFi + 2/1
c      . Pour 2 aretes non en vis-a-vis :
c       trifad(1,1) = triangle de la face 1 du cote de PYR1 : FFi + 1/2
c       trifad(1,2) = triangle de la face 1 de l'autre cote : FFi + 2/1
c     areqtr(1,1)
c     areqtr(1,2)
      iaux = quahex(lehexa,nulofa(1))
      jaux = coquhe(lehexa,nulofa(1))
      trifad(1,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(1,0) = 4
        trifad(1,1) = trifad(1,0) + 1
        cotrvo(1,1) = 4
        trifad(1,2) = trifad(1,0) + 2
        cotrvo(1,2) = 6
        areqtr(1,1) = aretri(trifad(1,0),1)
        areqtr(1,2) = aretri(trifad(1,0),3)
      else
        cotrvo(1,0) = 2
        trifad(1,1) = trifad(1,0) + 2
        cotrvo(1,1) = 1
        trifad(1,2) = trifad(1,0) + 1
        cotrvo(1,2) = 2
        areqtr(1,1) = aretri(trifad(1,0),3)
        areqtr(1,2) = aretri(trifad(1,0),1)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'laface = ', iaux,', coface = ', jaux
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
c 2.2. ==> Face 2
c     trifad(2,0) = triangle central de la face 2 : FFi
c     . Pour 2 aretes en vis-a-vis :
c       trifad(2,1) = triangle de la face 2 bordant PYR1 : FFi + 2/1
c       trifad(2,2) = triangle de la face 2 bordant PYR2 : FFi + 1/2
c      . Pour 2 aretes non en vis-a-vis :
c       trifad(2,1) = triangle de la face 2 du cote de PYR1 : FFi + 2/1
c       trifad(2,2) = triangle de la face 2 de l'autre cote : FFi + 1/2
c     areqtr(2,1)
c     areqtr(2,2)
      iaux = quahex(lehexa,nulofa(2))
      jaux = coquhe(lehexa,nulofa(2))
      trifad(2,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(2,0) = 4
        trifad(2,1) = trifad(2,0) + 2
        cotrvo(2,1) = 6
        trifad(2,2) = trifad(2,0) + 1
        cotrvo(2,2) = 4
        areqtr(2,1) = aretri(trifad(2,0),3)
        areqtr(2,2) = aretri(trifad(2,0),1)
      else
        cotrvo(2,0) = 2
        trifad(2,1) = trifad(2,0) + 1
        cotrvo(2,1) = 2
        trifad(2,2) = trifad(2,0) + 2
        cotrvo(2,2) = 1
        areqtr(2,1) = aretri(trifad(2,0),1)
        areqtr(2,2) = aretri(trifad(2,0),3)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'laface = ', iaux,', coface = ', jaux
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
c 2.3. ==> Face 3
c     trifad(3,0) = triangle central de la face 3 : FFi
c     . Pour 2 aretes en vis-a-vis :
c       trifad(3,1) = triangle de la face 3 bordant PYR1 : FFi + 1/2
c       trifad(3,2) = triangle de la face 3 bordant PYR2 : FFi + 2/1
c      . Pour 2 aretes non en vis-a-vis :
c       trifad(3,1) = triangle de la face 3 du cote de PYR2 : FFi + 1/2
c       trifad(3,2) = triangle de la face 3 de l'autre cote : FFi + 2/1
c     areqtr(3,1)
c     areqtr(3,2)
      iaux = quahex(lehexa,nulofa(3))
      jaux = coquhe(lehexa,nulofa(3))
      trifad(3,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(3,0) = 4
        trifad(3,1) = trifad(3,0) + 1
        cotrvo(3,1) = 4
        trifad(3,2) = trifad(3,0) + 2
        cotrvo(3,2) = 6
        areqtr(3,1) = aretri(trifad(3,0),1)
        areqtr(3,2) = aretri(trifad(3,0),3)
      else
        cotrvo(3,0) = 2
        trifad(3,1) = trifad(3,0) + 2
        cotrvo(3,1) = 1
        trifad(3,2) = trifad(3,0) + 1
        cotrvo(3,2) = 2
        areqtr(3,1) = aretri(trifad(3,0),3)
        areqtr(3,2) = aretri(trifad(3,0),1)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'laface = ', iaux,', coface = ', jaux
      write(ulsort,1789) 'trifad(3,0) = ', trifad(3,0),
     >                   'trifad(3,1) = ', trifad(3,1),
     >                   'trifad(3,2) = ', trifad(3,2)
      write(ulsort,1789) 'cotrvo(3,0) = ', cotrvo(3,0),
     >                   'cotrvo(3,1) = ', cotrvo(3,1),
     >                   'cotrvo(3,2) = ', cotrvo(3,2)
      write(ulsort,1789) 'areqtr(3,1) = ', areqtr(3,1),
     >                   ' de ',somare(1,areqtr(3,1)),
     >                   ' a ',somare(2,areqtr(3,1))
      write(ulsort,1789) 'areqtr(3,2) = ', areqtr(3,2),
     >                   ' de ',somare(1,areqtr(3,2)),
     >                   ' a ',somare(2,areqtr(3,2))
#endif
c
c 2.4. ==> Face 4
c     trifad(4,0) = triangle central de la face 4 : FFi
c     . Pour 2 aretes en vis-a-vis :
c       trifad(4,1) = triangle de la face 4 bordant PYR1 : FFi + 2/1
c       trifad(4,2) = triangle de la face 4 bordant PYR2 : FFi + 1/2
c      . Pour 2 aretes non en vis-a-vis :
c       trifad(4,1) = triangle de la face 4 du cote de PYR2 : FFi + 2/1
c       trifad(4,2) = triangle de la face 4 de l'autre cote : FFi + 1/2
c     areqtr(4,1)
c     areqtr(4,2)
      iaux = quahex(lehexa,nulofa(4))
      jaux = coquhe(lehexa,nulofa(4))
      trifad(4,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(4,0) = 4
        trifad(4,1) = trifad(4,0) + 2
        cotrvo(4,1) = 6
        trifad(4,2) = trifad(4,0) + 1
        cotrvo(4,2) = 4
        areqtr(4,1) = aretri(trifad(4,0),3)
        areqtr(4,2) = aretri(trifad(4,0),1)
      else
        cotrvo(4,0) = 2
        trifad(4,1) = trifad(4,0) + 1
        cotrvo(4,1) = 2
        trifad(4,2) = trifad(4,0) + 2
        cotrvo(4,2) = 1
        areqtr(4,1) = aretri(trifad(4,0),1)
        areqtr(4,2) = aretri(trifad(4,0),3)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'laface = ', iaux,', coface = ', jaux
      write(ulsort,1789) 'trifad(4,0) = ', trifad(4,0),
     >                   'trifad(4,1) = ', trifad(4,1),
     >                   'trifad(4,2) = ', trifad(4,2)
      write(ulsort,1789) 'cotrvo(4,0) = ', cotrvo(4,0),
     >                   'cotrvo(4,1) = ', cotrvo(4,1),
     >                   'cotrvo(4,2) = ', cotrvo(4,2)
      write(ulsort,1789) 'areqtr(4,1) = ', areqtr(4,1),
     >                   ' de ',somare(1,areqtr(4,1)),
     >                   ' a ',somare(2,areqtr(4,1))
      write(ulsort,1789) 'areqtr(4,2) = ', areqtr(4,2),
     >                   ' de ',somare(1,areqtr(4,2)),
     >                   ' a ',somare(2,areqtr(4,2))
#endif
c
c====
c 3. grandeurs independantes du cas traite (phase 2)
c====
c     niveau = niveau des triangles des conformites des faces
      niveau = nivtri(trifad(1,0))
#ifdef _DEBUG_HOMARD_
      write(ulsort,3000) niveau
 3000 format('niveau =',i3)
#endif
c
c====
c 4. la fin
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
