      subroutine cmcp2b ( nulofa, lepent,
     >                    ind11, ind12, ind13, ind001,
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
c                         - cas 2, phase B
c                               -        -
c    Reperage des aretes et des triangles sur les faces externes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nulofa . e   .   4    . numero local des faces a traiter           .
c . lepent . e   .   1    . pentaedre a decouper                       .
c . ind11  . e   .   1    . i1i2i3 associe a l'arete coupee            .
c . ind12  . e   .   1    . i1i2i3 associe a l'arete suivant ind11     .
c . ind13  . e   .   1    . i1i2i3 associe a l'arete precedant ind11   .
c . ind001 . e   .   1    . indice associe a la permutation per001     .
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
      parameter ( nompro = 'CMCP2B' )
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
      integer ind001
      integer aretri(nouvtr,3), nivtri(nouvtr), filtri(nouvtr)
      integer filqua(nouvqu)
      integer facpen(nouvpf,5), cofape(nouvpf,5)
      integer niveau
      integer trifad(4,0:2), cotrvo(4,0:2), areqtr(4,0:2)
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
c    REMARQUE :
c    On raisonne avec un sens de rotation qui est le sens entrant quand
c    on regarde la face triangulaire coupee : (S1,S2,S3) ou (S4,S6,S5)
c
c====
c 2. Triangles et aretes tracees sur le quadrangle qui
c          borde l'arete triangulaire coupee
c     trifad(1,0) : triangle central de ce decoupage
c     trifad(1,1) : triangle suivant le central selon le sens defini
c     trifad(1,2) : triangle precedant le central selon le sens defini
c     cotrvo(1,0/1/2) : futur code du triangle trifad(1,0/1/2) dans la
c                       description des fils
c     areqtr(1,1) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(1,1)
c     areqtr(1,2) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(1,2)
c====
c
      iaux = facpen(lepent,nulofa(1))
      jaux = cofape(lepent,nulofa(1))
      trifad(1,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(1,0) = 4
        trifad(1,1) = trifad(1,0) + 2
        cotrvo(1,1) = 6
        trifad(1,2) = trifad(1,0) + 1
        cotrvo(1,2) = 4
        areqtr(1,1) = aretri(trifad(1,0),3)
        areqtr(1,2) = aretri(trifad(1,0),1)
      else
        cotrvo(1,0) = 2
        trifad(1,1) = trifad(1,0) + 1
        cotrvo(1,1) = 2
        trifad(1,2) = trifad(1,0) + 2
        cotrvo(1,2) = 1
        areqtr(1,1) = aretri(trifad(1,0),1)
        areqtr(1,2) = aretri(trifad(1,0),3)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'Quadrangle = ', iaux,', code =', jaux
      do 2222 , iaux = 0, 2
      write (ulsort,90015) 'trifad(1,0/1/2) =', trifad(1,iaux),
     >             ', aretes', (aretri(trifad(1,iaux),jaux),jaux=1,3)
 2222 continue
      write(ulsort,90006) 'cotrvo(1,0) = ', cotrvo(1,0),
     >                    'cotrvo(1,1) = ', cotrvo(1,1),
     >                    'cotrvo(1,2) = ', cotrvo(1,2)
      write(ulsort,90002) 'areqtr(1,1) = ', areqtr(1,1)
      write(ulsort,90002) 'areqtr(1,2) = ', areqtr(1,2)
#endif
c
c====
c 3. Triangles et aretes tracees sur le quadrangle suivant le premier
c     trifad(2,0) : triangle central de ce decoupage
c     trifad(2,1) : triangle du cote de la face triangulaire coupee
c     trifad(2,2) : triangle du cote de l'autre face triangulaire
c     cotrvo(2,0/1/2) : futur code du triangle trifad(2,0/1/2) dans la
c                       description des fils
c     areqtr(2,1) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(2,1)
c     areqtr(2,2) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(2,2)
c====
c
      iaux = facpen(lepent,nulofa(2))
      jaux = cofape(lepent,nulofa(2))
      trifad(2,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(2,0) = 2
        trifad(2,1) = trifad(2,0) + 1
        cotrvo(2,1) = 4
        trifad(2,2) = trifad(2,0) + 2
        cotrvo(2,2) = 1
        areqtr(2,1) = aretri(trifad(2,0),1)
        areqtr(2,2) = aretri(trifad(2,0),3)
      else
        cotrvo(2,0) = 4
        trifad(2,1) = trifad(2,0) + 2
        cotrvo(2,1) = 1
        trifad(2,2) = trifad(2,0) + 1
        cotrvo(2,2) = 4
        areqtr(2,1) = aretri(trifad(2,0),3)
        areqtr(2,2) = aretri(trifad(2,0),1)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'Quadrangle = ', iaux,', code =', jaux
      do 3333 , iaux = 0, 2
      write (ulsort,90015) 'trifad(2,0/1/2) =', trifad(2,iaux),
     >             ', aretes', (aretri(trifad(2,iaux),jaux),jaux=1,3)
 3333 continue
      write(ulsort,90006) 'cotrvo(2,0) = ', cotrvo(2,0),
     >                    'cotrvo(2,1) = ', cotrvo(2,1),
     >                    'cotrvo(2,2) = ', cotrvo(2,2)
      write(ulsort,90002) 'areqtr(2,1) = ', areqtr(2,1)
      write(ulsort,90002) 'areqtr(2,2) = ', areqtr(2,2)
#endif
c
c====
c 4. Triangles et aretes tracees sur le quadrangle suivant le deuxieme
c     trifad(3,0) : triangle central de ce decoupage
c     trifad(3,1) : triangle du cote de la face triangulaire coupee
c     trifad(3,2) : triangle du cote de l'autre face triangulaire
c     cotrvo(3,0/1/2) : futur code du triangle trifad(3,0/1/2) dans la
c                       description des fils
c     areqtr(3,1) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(3,1)
c     areqtr(3,2) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(3,2)
c====
c
      iaux = facpen(lepent,nulofa(3))
      jaux = cofape(lepent,nulofa(3))
      trifad(3,0) = -filqua(iaux)
      if ( jaux.lt.5 ) then
        cotrvo(3,0) = 2
        trifad(3,1) = trifad(3,0) + 2
        cotrvo(3,1) = 1
        trifad(3,2) = trifad(3,0) + 1
        cotrvo(3,2) = 4
        areqtr(3,1) = aretri(trifad(3,0),3)
        areqtr(3,2) = aretri(trifad(3,0),1)
      else
        cotrvo(3,0) = 4
        trifad(3,1) = trifad(3,0) + 1
        cotrvo(3,1) = 4
        trifad(3,2) = trifad(3,0) + 2
        cotrvo(3,2) = 1
        areqtr(3,1) = aretri(trifad(3,0),1)
        areqtr(3,2) = aretri(trifad(3,0),3)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'Quadrangle = ', iaux,', code =', jaux
      do 4444 , iaux = 0, 2
      write (ulsort,90015) 'trifad(3,0/1/2) =', trifad(3,iaux),
     >             ', aretes', (aretri(trifad(3,iaux),jaux),jaux=1,3)
 4444 continue
      write(ulsort,90006) 'cotrvo(3,0) = ', cotrvo(3,0),
     >                    'cotrvo(3,1) = ', cotrvo(3,1),
     >                    'cotrvo(3,2) = ', cotrvo(3,2)
      write(ulsort,90002) 'areqtr(3,1) = ', areqtr(3,1)
      write(ulsort,90002) 'areqtr(3,2) = ', areqtr(3,2)
#endif
c
c====
c 5. Triangles et aretes tracees sur le triangle coupe en 2
c     trifad(4,0) : triangle suivant le milieu de l'arete coupee
c     trifad(4,1) : triangle precedant le milieu de l'arete coupee
c     cotrvo(4,0/1) : futur code du triangle trifad(p,0/1) dans la
c                     description des fils
c     areqtr(4,2) : arete commune aux deux triangles fils
c====
c
      iaux = facpen(lepent,nulofa(4))
      jaux = cofape(lepent,nulofa(4))
      trifad(4,0) = filtri(iaux) + nutrde(ind11(jaux),ind12(jaux))
      trifad(4,1) = filtri(iaux) + nutrde(ind11(jaux),ind13(jaux))
      areqtr(4,2) = aretri(trifad(4,0),ind13(jaux))
      cotrvo(4,0) = per001(ind001,jaux)
      cotrvo(4,1) = per001(ind001,jaux)
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'Triangle = ', iaux,', code = ', jaux
      do 5555 , iaux = 0, 1
      write (ulsort,90015) 'trifad(4,0/1) =', trifad(4,iaux),
     >             ', aretes', (aretri(trifad(4,iaux),jaux),jaux=1,3)
 5555 continue
      write(ulsort,90006) 'cotrvo(4,0) = ', cotrvo(4,0),
     >                    'cotrvo(4,1) = ', cotrvo(4,1)
      write(ulsort,90002) 'areqtr(4,2) = ', areqtr(4,2)
#endif
c
c====
c 6. Demi-aretes
c     areqtr(1,0) : demi-arete tri, du cote 'suivant'
c     areqtr(2,0) : demi-arete tri, du cote 'precedant'
c     areqtr(3,0) : demi-arete qua, du cote de la face tria coupee
c====
c
      areqtr(1,0) = aretri(trifad(1,1),1)
      areqtr(2,0) = aretri(trifad(1,2),1)
      areqtr(3,0) = aretri(trifad(2,1),1)
#ifdef _DEBUG_HOMARD_
      do 6666 , iaux = 1,3
      write(ulsort,90002) 'areqtr(1/2/3,0) = ', areqtr(iaux,0)
 6666 continue
#endif
c
c====
c 7. niveau des triangles des conformites des faces
c====
c
      niveau = nivtri(trifad(1,0))
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'niveau', niveau
#endif
c
c====
c 7. la fin
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
