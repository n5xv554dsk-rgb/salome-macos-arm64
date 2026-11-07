      subroutine cmchac ( indtri, triint,
     >                    lesare, tab1, tab2,
     >                    trifad, areint, areqtr, niveau,
     >                    aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
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
c                         - par 2 Aretes - phase C
c                                 -              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . triint .  s  .  22    . triangles internes a l'hexaedre            .
c .        .     .        .  1-4 = bordant la pyramide 1               .
c .        .     .        .  5-8 = bordant la pyramide 2               .
c .        .     .        .  9-10 = s'appuyant sur les 2 autres aretes .
c .        .     .        .         non decoupees                      .
c .        .     .        .  11-14 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee, du cote de la pyramide 1.
c .        .     .        .  15-18 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee, du cote de la pyramide 2.
c .        .     .        .  19-22 = appuyes sur les filles des aretes .
c .        .     .        .   coupees                                  .
c . lesare . e   .  10    . liste des aretes de l'hexaedre utiles      .
c .        .     .        .  1-4 = les aretes de la pyramide 1         .
c .        .     .        .  5-8 = les aretes de la pyramide 2         .
c .        .     .        .  9 = arete non decoupee, entre face 2 et 3 .
c .        .     .        .  10 = arete non decoupee, entre face 4 et 1.
c . tab1,2 . e   .    4   . numeros magiques des aretes dans areint    .
c . trifad . e   .(4,0:2) . triangles traces sur les faces decoupees   .
c . areint . e  .    10   . aretes internes a l'hexaedre               .
c . areqtr . e  .   (4,2) . aretes sur les faces coupees               .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . famtri . es  . nouvtr . famille des triangles                      .
c . areint . e   .   10   . aretes internes creees                     .
c . niveau . e   . 1      . niveau a attribuer aux triangles           .
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
      parameter ( nompro = 'CMCHAC' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nouvnb.h"
#include "ope1a4.h"
c
c 0.3. ==> arguments
c
      integer indtri
      integer niveau
      integer triint(22)
      integer lesare(10)
      integer tab1(4), tab2(4)
      integer trifad(4,0:2)
      integer areint(10)
      integer areqtr(4,2)
      integer aretri(nouvtr,3), famtri(nouvtr)
      integer hettri(nouvtr), filtri(nouvtr), pertri(nouvtr)
      integer nivtri(nouvtr)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer codetr
      integer tb1(8), tb2(8)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data tb1 / 9, 2, 10,  4, 8, 9,  6, 10 /
      data tb2 / 4, 9,  2, 10, 9, 6, 10,  8 /
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
      codret = 0
c
      codetr = 1
c
c====
c 2. Les triangles de la pyramide 1, puis de la pyramide 2
c     par convention, le niveau est le meme que les triangles fils
c     sur l'exterieur
c====
c
      do 21 , iaux = 1 , 4
c
        jaux = per1a4(-1,iaux)
c
c 2.1. ==> les triangles bordant la pyramide 1
c    triint(1) = triangle bordant la pyramide 1 selon l'arete areint(1)
c    triint(2) = triangle bordant la pyramide 1 selon l'arete areint(2)
c     idem pour 3 et 4
c
        indtri = indtri + 1
        triint(iaux) = indtri
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri, lesare(iaux), areint(jaux), areint(iaux),
     >                codetr, niveau )
c
c 2.2. ==> les triangles bordant la pyramide 2
c    triint(5) = triangle bordant la pyramide 2 selon l'arete areint(5)
c     idem pour 6, 7 et 8
c
        kaux = iaux + 4
        indtri = indtri + 1
        triint(kaux) = indtri
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri, lesare(kaux), areint(kaux),areint(jaux+4),
     >                codetr, niveau )
c
c 2.3. ==> les triangles s'appuyant sur l'arete interne a la face
c          coupee, du cote de la pyramide 1
c
        kaux = iaux + 10
        indtri = indtri + 1
        triint(kaux) = indtri
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri, areqtr(iaux,1), areint(tb1(iaux)),
     >                                        areint(tb2(iaux)),
     >                codetr, niveau )
c
c 2.4. ==> les triangles s'appuyant sur l'arete interne a la face
c          coupee, du cote de la pyramide 2
c
        kaux = iaux + 14
        indtri = indtri + 1
        triint(kaux) = indtri
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri, areqtr(iaux,2), areint(tb1(iaux+4)),
     >                                        areint(tb2(iaux+4)),
     >                codetr, niveau )
c
   21 continue
c
c====
c 3. Les triangles s'appuyant sur les 2 aretes non decoupees
c    triint(9) = triangle s'appuyant sur l'arete non decoupee, situee
c                entre les faces 2 et 3 dans l'ordre choisi dans CMCH3x
c    triint(10) = triangle s'appuyant sur l'arete non decoupee, situee
c                entre les faces 4 et 1 dans l'ordre choisi dans CMCH3x
c====
c
      indtri = indtri + 1
      triint(9) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(9), areint(6), areint(2),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(10) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(10), areint(4),areint(8),
     >              codetr, niveau )
c
c====
c 4. Les triangles s'appuyant sur les filles des aretes coupees
c    . iaux represente les pyramides
c    . jaux represente la boucle sur les faces
c====
c
      kaux = 0
c
      do 41 , iaux = 1 , 2
c
        do 411 , jaux = 2 , 3
c
          kaux = kaux + 1
          indtri = indtri + 1
          triint(kaux+18) = indtri
          call cmctri ( aretri, famtri, hettri,
     >                  filtri, pertri, nivtri,
     >                  indtri, aretri(trifad(jaux,iaux),1),
     >                  tab1(kaux), tab2(kaux),
     >                  codetr, niveau )
c
  411   continue
c
   41 continue
c
#ifdef _DEBUG_HOMARD_
      do 4333 , iaux = 1, 22
      write(ulsort,1789) iaux, triint(iaux),
     >                   ' a1 ',aretri(triint(iaux),1),
     >                   ' a2 ',aretri(triint(iaux),2),
     >                   ' a3 ',aretri(triint(iaux),3)
 4333 continue
 1789 format('triint(',i2,') = ',i6,' : ',5(a,'=',i6,','))
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
