      subroutine cmchak ( nulofa, lehexa,
     >                    somare,
     >                    aretri, nivtri,
     >                    filqua,
     >                    quahex, coquhe,
     >                    niveau, areqtr,
     >                    trifad, cotrvo,
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
c                         - par 3 Aretes - phase K
c                                 -              -
c    Remarque : cmchaa, cmchak et cmchal sont des clones
c               cmchak et cmchal sont symetriques
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nulofa . e   .   6    . numero local des faces a traiter           .
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . quahex . e   .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nouvhf*6. codes des 6 quadrangles des hexaedres      .
c . niveau .  s  .   1    . niveau des faces issus du decoupage        .
c . areqtr .  s  .  (6,2) . aretes tracees sur les faces decoupees     .
c . trifad .  s  .(6,0:2) . triangles traces sur les faces decoupees   .
c . cotrvo .  s  .(6,0:2) . code des triangles dans les volumes        .
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
      parameter ( nompro = 'CMCHAK' )
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
      integer lehexa, nulofa(6)
      integer somare(2,nouvar)
      integer aretri(nouvtr,3), nivtri(nouvtr)
      integer filqua(nouvqu)
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer niveau
      integer areqtr(6,2)
      integer trifad(6,0:2), cotrvo(6,0:2)
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
c            On traite les faces de l'hexaedre coupees en 3 comme suit :
c            . La 1ere et la 2eme partagent la 1ere arete coupee.
c              La 1ere face est celle qui n'a pas de point commun
c              avec la 2eme arete coupee.
c            . La 3eme et la 4eme partagent la 2nde arete coupee.
c              La 3eme face est celle qui n'a pas de point commun
c              avec la 3eme arete coupee.
c            . La 5eme et la 6eme partagent la 3eme arete coupee.
c              La 5eme face est celle qui n'a pas de point commun
c              avec la 1ere arete coupee.
c            On traite les sommets de l'hexaedre comme suit :
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
c====
c
c 2.1. ==> Face 1
c     trifad(1,0) = triangle central de la face 1 : FFi
c     trifad(1,1) = triangle de la face 1 vers le sommet 1 : FFi + 2/1
c     trifad(1,2) = triangle de la face 1 de l'autre cote : FFi + 1/2
c     areqtr(1,1)
c     areqtr(1,2)
      iaux = quahex(lehexa,nulofa(1))
      jaux = coquhe(lehexa,nulofa(1))
      trifad(1,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(1,0) = 4
        trifad(1,2) = trifad(1,0) + 2
        cotrvo(1,2) = 6
        trifad(1,1) = trifad(1,0) + 1
        cotrvo(1,1) = 4
        areqtr(1,2) = aretri(trifad(1,0),3)
        areqtr(1,1) = aretri(trifad(1,0),1)
      else
        cotrvo(1,0) = 2
        trifad(1,2) = trifad(1,0) + 1
        cotrvo(1,2) = 2
        trifad(1,1) = trifad(1,0) + 2
        cotrvo(1,1) = 1
        areqtr(1,2) = aretri(trifad(1,0),1)
        areqtr(1,1) = aretri(trifad(1,0),3)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Face 1'
      write(ulsort,1789) 'laface = ', iaux,'coface = ', jaux
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
c     trifad(2,1) = triangle de la face 2 vers le sommet 1 : FFi + 1/2
c     trifad(2,2) = triangle de la face 2 de l'autre cote : FFi + 2/1
c     areqtr(2,1)
c     areqtr(2,2)
      iaux = quahex(lehexa,nulofa(2))
      jaux = coquhe(lehexa,nulofa(2))
      trifad(2,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(2,0) = 4
        trifad(2,2) = trifad(2,0) + 1
        cotrvo(2,2) = 4
        trifad(2,1) = trifad(2,0) + 2
        cotrvo(2,1) = 6
        areqtr(2,2) = aretri(trifad(2,0),1)
        areqtr(2,1) = aretri(trifad(2,0),3)
      else
        cotrvo(2,0) = 2
        trifad(2,2) = trifad(2,0) + 2
        cotrvo(2,2) = 1
        trifad(2,1) = trifad(2,0) + 1
        cotrvo(2,1) = 2
        areqtr(2,2) = aretri(trifad(2,0),3)
        areqtr(2,1) = aretri(trifad(2,0),1)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Face 2'
      write(ulsort,1789) 'laface = ', iaux,'coface = ', jaux
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
c     trifad(3,1) = triangle de la face 3 vers le sommet 3 : FFi + 1/2
c     trifad(3,2) = triangle de la face 3 de l'autre cote : FFi + 2/1
c     areqtr(3,1)
c     areqtr(3,2)
      iaux = quahex(lehexa,nulofa(3))
      jaux = coquhe(lehexa,nulofa(3))
      trifad(3,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(3,0) = 4
        trifad(3,2) = trifad(3,0) + 2
        cotrvo(3,2) = 6
        trifad(3,1) = trifad(3,0) + 1
        cotrvo(3,1) = 4
        areqtr(3,2) = aretri(trifad(3,0),3)
        areqtr(3,1) = aretri(trifad(3,0),1)
      else
        cotrvo(3,0) = 2
        trifad(3,2) = trifad(3,0) + 1
        cotrvo(3,2) = 2
        trifad(3,1) = trifad(3,0) + 2
        cotrvo(3,1) = 1
        areqtr(3,2) = aretri(trifad(3,0),1)
        areqtr(3,1) = aretri(trifad(3,0),3)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Face 3'
      write(ulsort,1789) 'laface = ', iaux,'coface = ', jaux
      write(ulsort,1789) 'trifad(3,0) = ', trifad(3,0),
     >                   'trifad(3,1) = ', trifad(3,1),
     >                   'trifad(3,2) = ', trifad(3,2)
      write(ulsort,1789) 'cotrvo(3,0) = ', cotrvo(3,0),
     >                   'cotrvo(3,1) = ', cotrvo(3,1),
     >                   'cotrvo(3,2) = ', cotrvo(3,2)
      write(ulsort,1789) '1 = ', aretri(trifad(3,0),1),
     >                   '2 = ', aretri(trifad(3,0),2),
     >                   '3 = ', aretri(trifad(3,0),3)
      write(ulsort,1789) '1 = ', aretri(trifad(3,1),1),
     >                   '2 = ', aretri(trifad(3,1),2),
     >                   '3 = ', aretri(trifad(3,1),3)
      write(ulsort,1789) '1 = ', aretri(trifad(3,2),1),
     >                   '2 = ', aretri(trifad(3,2),2),
     >                   '3 = ', aretri(trifad(3,2),3)
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
c     trifad(4,1) = triangle de la face 4 vers le sommet 3 : FFi + 1/2
c     trifad(4,2) = triangle de la face 4 de l'autre cote : FFi + 2/1
c     areqtr(4,1)
c     areqtr(4,2)
      iaux = quahex(lehexa,nulofa(4))
      jaux = coquhe(lehexa,nulofa(4))
      trifad(4,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(4,0) = 4
        trifad(4,2) = trifad(4,0) + 1
        cotrvo(4,2) = 4
        trifad(4,1) = trifad(4,0) + 2
        cotrvo(4,1) = 6
        areqtr(4,2) = aretri(trifad(4,0),1)
        areqtr(4,1) = aretri(trifad(4,0),3)
      else
        cotrvo(4,0) = 2
        trifad(4,2) = trifad(4,0) + 2
        cotrvo(4,2) = 1
        trifad(4,1) = trifad(4,0) + 1
        cotrvo(4,1) = 2
        areqtr(4,2) = aretri(trifad(4,0),3)
        areqtr(4,1) = aretri(trifad(4,0),1)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Face 4'
      write(ulsort,1789) 'laface = ', iaux,'coface = ', jaux
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
c 2.5. ==> Face 5
c     trifad(5,0) = triangle central de la face 5 : FFi
c     trifad(5,1) = triangle de la face 5 du cote du sommet 5 : FFi + 1/2
c     trifad(5,2) = triangle de la face 5 de l'autre cote : FFi + 2/1
c     areqtr(5,1)
c     areqtr(5,2)
      iaux = quahex(lehexa,nulofa(5))
      jaux = coquhe(lehexa,nulofa(5))
      trifad(5,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(5,0) = 4
        trifad(5,2) = trifad(5,0) + 2
        cotrvo(5,2) = 6
        trifad(5,1) = trifad(5,0) + 1
        cotrvo(5,1) = 4
        areqtr(5,2) = aretri(trifad(5,0),3)
        areqtr(5,1) = aretri(trifad(5,0),1)
      else
        cotrvo(5,0) = 2
        trifad(5,2) = trifad(5,0) + 1
        cotrvo(5,2) = 2
        trifad(5,1) = trifad(5,0) + 2
        cotrvo(5,1) = 1
        areqtr(5,2) = aretri(trifad(5,0),1)
        areqtr(5,1) = aretri(trifad(5,0),3)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Face 5'
      write(ulsort,1789) 'laface = ', iaux,'coface = ', jaux
      write(ulsort,1789) 'trifad(5,0) = ', trifad(5,0),
     >                   'trifad(5,1) = ', trifad(5,1),
     >                   'trifad(5,2) = ', trifad(5,2)
      write(ulsort,1789) 'cotrvo(5,0) = ', cotrvo(5,0),
     >                   'cotrvo(5,1) = ', cotrvo(5,1),
     >                   'cotrvo(5,2) = ', cotrvo(5,2)
      write(ulsort,1789) 'areqtr(5,1) = ', areqtr(5,1),
     >                   ' de ',somare(1,areqtr(5,1)),
     >                   ' a ',somare(2,areqtr(5,1))
      write(ulsort,1789) 'areqtr(5,2) = ', areqtr(5,2),
     >                   ' de ',somare(1,areqtr(5,2)),
     >                   ' a ',somare(2,areqtr(5,2))
#endif
c
c 2.6. ==> Face 6
c     trifad(6,0) = triangle central de la face 6 : FFi
c     trifad(6,1) = triangle de la face 6 du cote du sommet 5 : FFi + 1/2
c     trifad(6,2) = triangle de la face 6 de l'autre cote : FFi + 2/1
c     areqtr(6,1)
c     areqtr(6,2)
      iaux = quahex(lehexa,nulofa(6))
      jaux = coquhe(lehexa,nulofa(6))
      trifad(6,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(6,0) = 4
        trifad(6,2) = trifad(6,0) + 1
        cotrvo(6,2) = 4
        trifad(6,1) = trifad(6,0) + 2
        cotrvo(6,1) = 6
        areqtr(6,2) = aretri(trifad(6,0),1)
        areqtr(6,1) = aretri(trifad(6,0),3)
      else
        cotrvo(6,0) = 2
        trifad(6,2) = trifad(6,0) + 2
        cotrvo(6,2) = 1
        trifad(6,1) = trifad(6,0) + 1
        cotrvo(6,1) = 2
        areqtr(6,2) = aretri(trifad(6,0),3)
        areqtr(6,1) = aretri(trifad(6,0),1)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'Face 6'
      write(ulsort,1789) 'laface = ', iaux,'coface = ', jaux
      write(ulsort,1789) 'trifad(6,0) = ', trifad(6,0),
     >                   'trifad(6,1) = ', trifad(6,1),
     >                   'trifad(6,2) = ', trifad(6,2)
      write(ulsort,1789) 'cotrvo(6,0) = ', cotrvo(6,0),
     >                   'cotrvo(6,1) = ', cotrvo(6,1),
     >                   'cotrvo(6,2) = ', cotrvo(6,2)
      write(ulsort,1789) 'areqtr(6,1) = ', areqtr(6,1),
     >                   ' de ',somare(1,areqtr(6,1)),
     >                   ' a ',somare(2,areqtr(6,1))
      write(ulsort,1789) 'areqtr(6,2) = ', areqtr(6,2),
     >                   ' de ',somare(1,areqtr(6,2)),
     >                   ' a ',somare(2,areqtr(6,2))
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
