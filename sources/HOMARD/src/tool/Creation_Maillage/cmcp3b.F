      subroutine cmcp3b ( nulofa, lepent,
     >                    ind11, ind12, ind13,
     >                    ind21, ind22, ind23,
     >                    ind001,
     >                    somare,
     >                    aretri, nivtri, filtri,
     >                    filqua,
     >                    facpen, cofape,
     >                    niveau,
     >                    trifad, cotrvo, areqtr,
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
c    Creation du Maillage - Conformite - decoupage des Pentaedres
c    -           -          -                          -
c                         - cas 3, phase B
c                               -        -
c    Reperage des aretes et des triangles sur les faces externes
c    Remarque : cmcp3b et cmcp3f sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nulofa . e   .   4    . numero local des faces a traiter           .
c . lepent . e   .   1    . pentaedre a decouper                       .
c . indi1  . e   .   1    . i1i2i3 associe a l'arete coupee face i     .
c . indi2  . e   .   1    . i1i2i3 associe a l'arete du cote de pyra   .
c . indi3  . e   .   1    . i1i2i3 associe a l'arete oppose a la pyra  .
c . ind001 . e   .   4    . redirection dans per001                    .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . nivtri . e   . nouvtr . niveau des triangles                       .
c . filtri . e   . nouvtr . premier fils des triangles                 .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . facpen . e   .nouvpf*5. numeros des faces des pentaedres           .
c . cofape . e   .nouvpf*5. codes des faces des pentaedres             .
c . niveau .  s  .   1    . niveau des faces issus du decoupage        .
c . trifad .  s  .(4,0:2) . triangles traces sur les faces decoupees   .
c . cotrvo .  s  .(4,0:2) . code des triangles dans les volumes        .
c . areqtr .  s  .(4,0:2) . aretes tri tracees sur les faces decoupees .
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
      parameter ( nompro = 'CMCP3B' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nouvnb.h"
#include "ope001.h"
#include "demitr.h"
c
c 0.3. ==> arguments
c
      integer lepent, nulofa(4)
      integer ind11(6), ind12(6), ind13(6)
      integer ind21(6), ind22(6), ind23(6)
      integer ind001(4)
      integer somare(2,nouvar)
      integer aretri(nouvtr,3), nivtri(nouvtr), filtri(nouvtr)
      integer filqua(nouvqu)
      integer facpen(nouvpf,5), cofape(nouvpf,5)
      integer niveau
      integer areqtr(4,0:2)
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
#include "impr03.h"
#include "impr04.h"
c
      codret = 0
c
c====
c 2. Triangles et aretes tracees sur les quadrangles coupees en 3
c     On traite les faces du pentaedre coupees en 3 comme suit :
c       La 1ere face est celle qui contient l'arete de F1 coupee.
c     trifad(p,0) : triangle central de ce decoupage
c     trifad(p,1) : triangle bordant l'arete non decoupee qui
c                   appartient a la pyramide
c     trifad(p,2) : triangle bordant l'arete non decoupee qui
c                   n'appartient pas a la pyramide
c     areqtr(p,1) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,1)
c     areqtr(p,2) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,2)
c     areqtr(3/4,0) = fille de l'arete coupee, du cote de la pyramide
c     areqtr(3/4,1) = autre fille
c====
c
c 2.1. ==> Face 1
c
      iaux = facpen(lepent,nulofa(1))
      jaux = cofape(lepent,nulofa(1))
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
      areqtr(3,0) = aretri(trifad(1,1),1)
      areqtr(3,1) = aretri(trifad(1,2),1)
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'Quadrangle = ', iaux,', code =', jaux
      do 2221 , iaux = 0, 2
      write (ulsort,90015) 'trifad(1,0/1/2) =', trifad(1,iaux),
     >             ', aretes', (aretri(trifad(1,iaux),jaux),jaux=1,3)
 2221 continue
      write(ulsort,90006) 'cotrvo(1,0) = ', cotrvo(1,0),
     >                    'cotrvo(1,1) = ', cotrvo(1,1),
     >                    'cotrvo(1,2) = ', cotrvo(1,2)
      write(ulsort,90006) 'areqtr(1,1) = ', areqtr(1,1),
     >                    ' de ',somare(1,areqtr(1,1)),
     >                    ' a ',somare(2,areqtr(1,1))
      write(ulsort,90006) 'areqtr(1,2) = ', areqtr(1,2),
     >                    ' de ',somare(1,areqtr(1,2)),
     >                    ' a ',somare(2,areqtr(1,2))
      write(ulsort,90006) 'areqtr(3,0) = ', areqtr(3,0),
     >                    ' de ',somare(1,areqtr(3,0)),
     >                    ' a ',somare(2,areqtr(3,0))
      write(ulsort,90006) 'areqtr(3,1) = ', areqtr(3,1),
     >                    ' de ',somare(1,areqtr(3,1)),
     >                    ' a ',somare(2,areqtr(3,1))
#endif
c
c 2.2. ==> Face 2
c
      iaux = facpen(lepent,nulofa(2))
      jaux = cofape(lepent,nulofa(2))
      trifad(2,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(2,0) = 4
        trifad(2,1) = trifad(2,0) + 1
        cotrvo(2,1) = 4
        trifad(2,2) = trifad(2,0) + 2
        cotrvo(2,2) = 6
        areqtr(2,1) = aretri(trifad(2,0),1)
        areqtr(2,2) = aretri(trifad(2,0),3)
      else
        cotrvo(2,0) = 2
        trifad(2,1) = trifad(2,0) + 2
        cotrvo(2,1) = 1
        trifad(2,2) = trifad(2,0) + 1
        cotrvo(2,2) = 2
        areqtr(2,1) = aretri(trifad(2,0),3)
        areqtr(2,2) = aretri(trifad(2,0),1)
      endif
      areqtr(4,0) = aretri(trifad(2,1),1)
      areqtr(4,1) = aretri(trifad(2,2),1)
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'Quadrangle = ', iaux,', code =', jaux
      do 2222 , iaux = 0, 2
      write (ulsort,90015) 'trifad(2,0/1/2) =', trifad(2,iaux),
     >             ', aretes', (aretri(trifad(2,iaux),jaux),jaux=1,3)
 2222 continue
      write(ulsort,90006) 'cotrvo(2,0) = ', cotrvo(2,0),
     >                   'cotrvo(2,1) = ', cotrvo(2,1),
     >                   'cotrvo(2,2) = ', cotrvo(2,2)
      write(ulsort,90006) 'areqtr(2,1) = ', areqtr(2,1),
     >                   ' de ',somare(1,areqtr(2,1)),
     >                   ' a ',somare(2,areqtr(2,1))
      write(ulsort,90006) 'areqtr(2,2) = ', areqtr(2,2),
     >                   ' de ',somare(1,areqtr(2,2)),
     >                   ' a ',somare(2,areqtr(2,2))
      write(ulsort,90006) 'areqtr(4,0) = ', areqtr(4,0),
     >                    ' de ',somare(1,areqtr(4,0)),
     >                    ' a ',somare(2,areqtr(4,0))
      write(ulsort,90006) 'areqtr(4,1) = ', areqtr(4,1),
     >                    ' de ',somare(1,areqtr(4,1)),
     >                    ' a ',somare(2,areqtr(4,1))
#endif
c
c====
c 3. Triangles et aretes tracees sur les triangles coupes en 2
c     On traite les faces du pentaedre coupees en 3 comme suit :
c       La 1ere face est F1.
c     trifad(p,0) : triangle bordant la pyramide
c     trifad(p,1) : triangle autre
c     areqtr(p,2) : arete commune aux deux triangles fils
c====
c 3.1. ==> Face 3
c
      iaux = facpen(lepent,nulofa(3))
      jaux = cofape(lepent,nulofa(3))
      trifad(3,0) = filtri(iaux) + nutrde(ind11(jaux),ind12(jaux))
      trifad(3,1) = filtri(iaux) + nutrde(ind11(jaux),ind13(jaux))
      areqtr(3,2) = aretri(trifad(3,0),ind13(jaux))
c
      cotrvo(3,0) = per001(ind001(1),jaux)
      cotrvo(3,1) = per001(ind001(2),jaux)
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'Triangle = ', iaux,', code =', jaux
      do 3331 , iaux = 0, 1
      write (ulsort,90015) 'trifad(3,0/1) =', trifad(3,iaux),
     >             ', aretes', (aretri(trifad(3,iaux),jaux),jaux=1,3)
 3331 continue
      write(ulsort,90006) 'cotrvo(3,0) = ', cotrvo(3,0),
     >                    'cotrvo(3,1) = ', cotrvo(3,1)
      write(ulsort,90006) 'areqtr(3,2) = ', areqtr(3,2),
     >                    ' de ',somare(1,areqtr(3,2)),
     >                    ' a ',somare(2,areqtr(3,2))
#endif
c
c 3.2. ==> Face 4
c
      iaux = facpen(lepent,nulofa(4))
      jaux = cofape(lepent,nulofa(4))
      trifad(4,0) = filtri(iaux) + nutrde(ind21(jaux),ind22(jaux))
      trifad(4,1) = filtri(iaux) + nutrde(ind21(jaux),ind23(jaux))
      areqtr(4,2) = aretri(trifad(4,0),ind23(jaux))

      cotrvo(4,0) = per001(ind001(3),jaux)
      cotrvo(4,1) = per001(ind001(4),jaux)
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'Triangle = ', iaux,', code =', jaux
      do 3332 , iaux = 0, 1
      write (ulsort,90015) 'trifad(4,0/1) =', trifad(4,iaux),
     >             ', aretes', (aretri(trifad(4,iaux),jaux),jaux=1,3)
 3332 continue
      write(ulsort,90006) 'cotrvo(4,0) = ', cotrvo(4,0),
     >                    'cotrvo(4,1) = ', cotrvo(4,1)
      write(ulsort,90006) 'areqtr(4,2) = ', areqtr(4,2),
     >                    ' de ',somare(1,areqtr(4,2)),
     >                    ' a ',somare(2,areqtr(4,2))
#endif
c
c====
c 4. niveau des triangles des conformites des faces
c====
c
      niveau = nivtri(trifad(1,0))
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'niveau', niveau
#endif
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
