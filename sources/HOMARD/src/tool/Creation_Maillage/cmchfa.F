      subroutine cmchfa ( facdec, cofdec, facnde, cofnde,
     >                    niveau, noefac,
     >                    quabas, arefad,
     >                    trifad, cotrvo, areqtr,
     >                    lehexa, nulofa,
     >                    somare, aretri, nivtri,
     >                    arequa, filqua,
     >                    quahex, coquhe,
     >                    tabaux,
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
c                         - par 1 Face - utilitaire A
c                                 -                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . facnde .  s  .   1    . numero global de la face non decoupee      .
c . cofnde .  s  .   1    . code de la face non decoupee dans l'hexa.  .
c . facdec .  s  .   1    . numero global de la face decoupee          .
c . cofdec .  s  .   1    . code de la face decoupee dans l'hexaedre   .
c . niveau .  s  .   1    . niveau des triangle de conformite des faces.
c . noefac .  s  .   1    . noeud central de la face decoupee en 4     .
c . quabas .  s  .   4    . quadrangles fils de la face coupee en 4    .
c .        .     .        . quabas(p) = base de la pyramide fille p    .
c . arefad .  s  .   4    . aretes tracees sur la face coupee en 4     .
c .        .     .        . arefad(p) est l'arete commune aux pyramides.
c .        .     .        . filles numero p et p+1                     .
c . trifad .  s  .(4,0:2) . triangles sur les faces de conformite      .
c .        .     .        . trifad(p,0) : triangle central du decoupage.
c .        .     .        . trifad(p,1) : tria. bordant la pyramide p  .
c .        .     .        . trifad(p,2) : tria. bordant la pyramide p+1.
c . cotrvo .  s  .(4,0:2) . futur codes des triangles trifad dans la   .
c .        .     .        . description des tetraedres                 .
c . areqtr .  s  .  (4,2) . arete interne au quadrangle de bord et     .
c .        .     .        . bordant le triangle trifad(p,i)            .
c . lehexa . e   .   1    . numero global d'hexaedre                   .
c . nulofa . e   .   1    . numero local de la face couppe en 4        .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . nivtri . e   . nouvtr . niveau des triangles                       .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . quahex . e   .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nouvhf*6. codes des 6 quadrangles des hexaedres      .
c . tabaux . e   .    4   . numeros locaux des faces coupees en 3,     .
c .        .     .        . dans l'ordre des pyramides p/p1+1          .
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
      parameter ( nompro = 'CMCHFA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nouvnb.h"
#include "comp07.h"
#include "defiqu.h"
c
c 0.3. ==> arguments
c
      integer facdec, cofdec, facnde, cofnde
      integer niveau, noefac
      integer quabas(4)
      integer arefad(4), areqtr(4,2)
      integer trifad(4,0:2), cotrvo(4,0:2)
      integer lehexa, nulofa
      integer somare(2,nouvar)
      integer aretri(nouvtr,3), nivtri(nouvtr)
      integer arequa(nouvqu,4), filqua(nouvqu)
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer tabaux(4)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
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
#ifdef _DEBUG_HOMARD_
 1789 format(5(a,i5,', '))
 1792 format(2(a,i1,a,i5,', '))
#endif
c
      codret = 0
c
c====
c 2. La face coupee en 4 et son code dans l'hexaedre
c    La face non coupee et son code dans l'hexaedre
c====
c
      facdec = quahex(lehexa,nulofa)
      cofdec = coquhe(lehexa,nulofa)
      facnde = quahex(lehexa,coen07(nulofa))
      cofnde = coquhe(lehexa,coen07(nulofa))
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'facdec = ', facdec, 'cofdec = ', cofdec
      write(ulsort,1789) 'facnde = ', facnde, 'cofnde = ', cofnde
#endif
c
c====
c 3. Noeud central de la face coupee en 4
c====
c
      iaux = filqua(facdec)
      noefac = somare(2,arequa(iaux,2))
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'noefac = ', noefac
#endif
c
c====
c 4. Quadrangles fils de la face coupee en 4
c    quabas(p) est la base de la pyramide fille numero p
c    filqua(facdec) + defiqJ(cofdec) : J-eme fils du quadrangle
c    Attention : la regle de numerotation locale des quadrangles quabas
c                est celle des pyramides ; on part du sommet de plus
c                petit numero local et on tourne en entrant dans
c                l'hexaedre. Pour les fils du quadrangle, on part de la
c                plus petite arete locale et on tourne dans le meme sens
c                D'ou l'eventuel decalage selon les faces
c====
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'defiq1 = ', defiq1(cofdec)
      write(ulsort,1789) 'defiq2 = ', defiq2(cofdec)
      write(ulsort,1789) 'defiq3 = ', defiq3(cofdec)
      write(ulsort,1789) 'defiq4 = ', defiq4(cofdec)
#endif
      if ( nulofa.eq.1 .or. nulofa.eq.3 .or. nulofa.eq.6 ) then
        quabas(1) = filqua(facdec) + defiq2(cofdec)
        quabas(2) = filqua(facdec) + defiq3(cofdec)
        quabas(3) = filqua(facdec) + defiq4(cofdec)
        quabas(4) = filqua(facdec) + defiq1(cofdec)
      else
        quabas(1) = filqua(facdec) + defiq1(cofdec)
        quabas(2) = filqua(facdec) + defiq2(cofdec)
        quabas(3) = filqua(facdec) + defiq3(cofdec)
        quabas(4) = filqua(facdec) + defiq4(cofdec)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'Fils aine = ', filqua(facdec)
      write(ulsort,1789) 'quabas(1) = ', quabas(1),
     >                   'arete 1 = ', arequa(quabas(1),1),
     >                   ' de ',somare(1,arequa(quabas(1),1)),
     >                   ' a ',somare(2,arequa(quabas(1),1))
      write(ulsort,1789) 'quabas(2) = ', quabas(2),
     >                   'arete 1 = ', arequa(quabas(2),1),
     >                   ' de ',somare(1,arequa(quabas(2),1)),
     >                   ' a ',somare(2,arequa(quabas(2),1))
      write(ulsort,1789) 'quabas(3) = ', quabas(3),
     >                   'arete 1 = ', arequa(quabas(3),1),
     >                   ' de ',somare(1,arequa(quabas(3),1)),
     >                   ' a ',somare(2,arequa(quabas(3),1))
      write(ulsort,1789) 'quabas(4) = ', quabas(4),
     >                   'arete 1 = ', arequa(quabas(4),1),
     >                   ' de ',somare(1,arequa(quabas(4),1)),
     >                   ' a ',somare(2,arequa(quabas(4),1))
#endif
c
c====
c 5. Aretes tracees sur la face coupee en 4
c    arefad(p) est l'arete commune aux pyramides filles numero p et p+1
c====
c
      if ( cofdec.lt.5 ) then 
       arefad(1) = arequa(quabas(1),2)
       arefad(2) = arequa(quabas(2),2)
       arefad(3) = arequa(quabas(3),2)
       arefad(4) = arequa(quabas(4),2)
      else
       arefad(1) = arequa(quabas(2),2)
       arefad(2) = arequa(quabas(3),2)
       arefad(3) = arequa(quabas(4),2)
       arefad(4) = arequa(quabas(1),2)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'arefad(1) = ', arefad(1),
     >                   ' de ',somare(1,arefad(1)),
     >                   ' a ',somare(2,arefad(1))
      write(ulsort,1789)
     >                   'arefad(2) = ', arefad(2),
     >                   ' de ',somare(1,arefad(2)),
     >                   ' a ',somare(2,arefad(2))
      write(ulsort,1789)
     >                   'arefad(3) = ', arefad(3),
     >                   ' de ',somare(1,arefad(3)),
     >                   ' a ',somare(2,arefad(3))
      write(ulsort,1789)
     >                   'arefad(4) = ', arefad(4),
     >                   ' de ',somare(1,arefad(4)),
     >                   ' a ',somare(2,arefad(4))
#endif
c
c====
c 6. Triangles et aretes tracees sur les faces coupees en 3
c            Chaque quadrangle de bord qui est decoupe en 3 triangles
c            borde deux pyramides consecutives : p et p+1
c     trifad(p,0) : triangle central de ce decoupage
c     trifad(p,1) : triangle bordant la pyramide p
c     trifad(p,2) : triangle bordant la pyramide p+1
c     cotrvo(p,0) : futur code du triangle trifad(p,0) dans la
c                   description du tetraedre p
c     cotrvo(p,1) : futur code du triangle trifad(p,1) dans la
c                   description de la pyramide p
c     cotrvo(p,2) : futur code du triangle trifad(p,2) dans la
c                   description de la pyramide p+1
c     areqtr(p,1) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,1)
c     areqtr(p,2) : arete interne au quadrangle de bord et bordant le
c                   triangle trifad(p,2)
c====
c
      do 61 , iaux = 1 , 4
        jaux = quahex(lehexa,tabaux(iaux))
        kaux = coquhe(lehexa,tabaux(iaux))
        trifad(iaux,0) = -filqua(jaux)
        if ( kaux.lt.5 ) then
          cotrvo(iaux,0) = 4
          trifad(iaux,1) = trifad(iaux,0) + 1
          cotrvo(iaux,1) = 3
          trifad(iaux,2) = trifad(iaux,0) + 2
          cotrvo(iaux,2) = 2
          areqtr(iaux,1) = aretri(trifad(iaux,0),1)
          areqtr(iaux,2) = aretri(trifad(iaux,0),3)
        else
          cotrvo(iaux,0) = 2
          trifad(iaux,1) = trifad(iaux,0) + 2
          cotrvo(iaux,1) = 5
          trifad(iaux,2) = trifad(iaux,0) + 1
          cotrvo(iaux,2) = 6
          areqtr(iaux,1) = aretri(trifad(iaux,0),3)
          areqtr(iaux,2) = aretri(trifad(iaux,0),1)
        endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) ' '
      write(ulsort,1789) 'face = ', jaux,', code = ', kaux
      write(ulsort,1792) 'trifad(',iaux,',0) = ', trifad(iaux,0)
      write(ulsort,1792) 'trifad(',iaux,',1) = ', trifad(iaux,1),
     >                   'trifad(',iaux,',2) = ', trifad(iaux,2)
      write(ulsort,1792) 'cotrvo(',iaux,',0) = ', cotrvo(iaux,0),
     >                   'cotrvo(',iaux,',1) = ', cotrvo(iaux,1),
     >                   'cotrvo(',iaux,',2) = ', cotrvo(iaux,2)
      write(ulsort,1789) 'areqtr(',iaux,'1) = ', areqtr(iaux,1),
     >                   ' de ',somare(1,areqtr(iaux,1)),
     >                   ' a ',somare(2,areqtr(iaux,1))
      write(ulsort,1789) 'areqtr(',iaux,'2) = ', areqtr(iaux,2),
     >                   ' de ',somare(1,areqtr(iaux,2)),
     >                   ' a ',somare(2,areqtr(iaux,2))
#endif
   61 continue
c
c====
c 7. niveau = niveau des quadrangles des conformites des faces
c====
c     
      niveau = nivtri(trifad(1,0))
#ifdef _DEBUG_HOMARD_
      write(ulsort,1789) 'niveau = ', niveau
#endif
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
