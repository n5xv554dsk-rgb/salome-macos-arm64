      subroutine cmchaf ( indtri, triint,
     >                    lesare, tab1,
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
c                         - par 2 Aretes - phase F
c                                 -              -
c    Remarque : cmchaf, cmchah sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . triint .  s  .  22    . triangles internes a l'hexaedre            .
c .        .     .        .  1-4 = bordant la pyramide 1               .
c .        .     .        .  5-7 = bordant la pyramide 2               .
c .        .     .        .  8,9,10 = s'appuyant sur les 3 autres      .
c .        .     .        .           aretes non decoupees             .
c .        .     .        .  11-18 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee                          .
c .        .     .        .  19-22 = appuyes sur les filles des aretes .
c .        .     .        .   coupees                                  .
c . lesare . e   .  10    . liste des aretes de l'hexaedre utiles      .
c .        .     .        .  1-4 = les aretes de la pyramide 1         .
c .        .     .        .  5-7 = les aretes de la pyramide 2         .
c .        .     .        .  8 = arete non decoupee, entre face 1 et 3 .
c .        .     .        .  9 = arete non decoupee, entre face 1 et 4 .
c .        .     .        .  10 = arete non decoupee, entre face 2 et 3.
c .        .     .        .  Pour 8, 9, 10, le signe de lesare(i)      .
c .        .     .        .  definit l'ordre des aretes 2 et 3         .
c . tab1   . e   .    2   . numeros magiques des aretes dans areint    .
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
      parameter ( nompro = 'CMCHAF' )
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
      integer tab1(2)
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
      integer aret2, aret3
      integer codetr
      integer nuarl2(2,2,2), nuarl3(2,2,2)
      integer tbar2(8), tbar3(8)
c
      logical prem
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
c         tbar2 contient les numeros locaux des 2-emes aretes pour les
c               triangles crees a partir des faces coupees
c         tbar3 contient les numeros locaux des 3-emes aretes pour les
c               triangles crees a partir des faces coupees
c
      data tbar2 / 9, 1, 10,  2, 7, 9,  8, 10 /
      data tbar3 / 3, 9,  5, 10, 9, 5, 10,  3 /
c
      data prem / .true. /
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
c 1.2. ==> indirection pour les numeros locaux des aretes definissant
c          les triangles s'appuyant sur les filles des aretes coupees
c       nuarl2(i,j,k) pour la 2eme arete du triangle
c       nuarl3(i,j,k) pour la 3eme arete du triangle
c       i : numero de la face d'exploration
c       j : numero de l'arete coupee
c       k : numero du code retenu
c
      if ( prem ) then
c
        nuarl2(1,1,1) =  4
        nuarl3(1,1,1) =  9
        nuarl2(2,1,1) =  9
        nuarl3(2,1,1) =  8
        nuarl2(1,1,2) =  9
        nuarl3(1,1,2) =  4
        nuarl2(2,1,2) =  8
        nuarl3(2,1,2) =  9
c
        nuarl2(1,2,1) =  6
        nuarl3(1,2,1) = 10
        nuarl2(2,2,1) = 10
        nuarl3(2,2,1) =  7
        nuarl2(1,2,2) = 10
        nuarl3(1,2,2) =  6
        nuarl2(2,2,2) =  7
        nuarl3(2,2,2) = 10
c
        prem = .false.
c
      endif
c
c====
c 2. 1-4 : les triangles de la pyramide 1
c    triint(i) = triangle bordant la pyramide 1 et contenant les aretes
c    areint(i) et areint(i+1)
c====
c
      do 21 , iaux = 1 , 4
c
        jaux = per1a4(1,iaux)
c
        indtri = indtri + 1
        triint(iaux) = indtri
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri, lesare(iaux), areint(iaux), areint(jaux),
     >                codetr, niveau )
c
   21 continue
c
c====
c 3. 5-7 : les 3 autres triangles de la pyramide 2 : les suivants apres
c    triint(1) dans l'ordre entrant de la pyramide
c====
c
      indtri = indtri + 1
      triint(5) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(5), areint(1), areint(5),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(6) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(6), areint(5), areint(6),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(7) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(7), areint(6), areint(2),
     >              codetr, niveau )
c
c====
c 4. Les triangles s'appuyant sur les 4 aretes non decoupees
c    triint(8) = triangle s'appuyant sur l'arete non decoupee, situee
c                entre les faces 1 et 3 dans l'ordre choisi dans CMCHxx
c    triint(9) = triangle s'appuyant sur l'arete non decoupee, situee
c                entre les faces 1 et 4 dans l'ordre choisi dans CMCHxx
c    triint(10) = triangle s'appuyant sur l'arete non decoupee, situee
c                entre les faces 2 et 3 dans l'ordre choisi dans CMCHxx
c====
c
      indtri = indtri + 1
      triint(8) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(8), areint(7), areint(8),
     >              codetr, niveau )
c
      if ( lesare(9).gt.0 ) then
        iaux = lesare(9)
        jaux = areint(3)
        kaux = areint(7)
      else
        iaux = -lesare(9)
        jaux = areint(7)
        kaux = areint(3)
      endif
      indtri = indtri + 1
      triint(9) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, iaux, jaux, kaux,
     >              codetr, niveau )
c
      if ( lesare(10).gt.0 ) then
        iaux = lesare(10)
        jaux = areint(8)
        kaux = areint(5)
      else
        iaux = -lesare(10)
        jaux = areint(5)
        kaux = areint(8)
      endif
      indtri = indtri + 1
      triint(10) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, iaux, jaux, kaux,
     >              codetr, niveau )
c
c====
c 5. 11-18 : les triangles s'appuyant sur les aretes tracees
c    sur les faces coupees
c====
c
      do 51 , iaux = 1 , 4
c
c 5.1. ==> les triangles s'appuyant sur l'arete interne a la face
c          coupee, du cote de la pyramide
c
        kaux = iaux + 10
        indtri = indtri + 1
        triint(kaux) = indtri
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri, areqtr(iaux,1), areint(tbar2(iaux)),
     >                                        areint(tbar3(iaux)),
     >                codetr, niveau )
c
c 5.1. ==> les triangles s'appuyant sur l'arete interne a la face
c          coupee, de l'autre cote
c
        kaux = iaux + 14
        indtri = indtri + 1
        triint(kaux) = indtri
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri, areqtr(iaux,2), areint(tbar2(iaux+4)),
     >                                        areint(tbar3(iaux+4)),
     >                codetr, niveau )
c
   51 continue
c
c====
c 6. 19-22 : les triangles s'appuyant sur les filles des aretes coupees
c    . iaux represente les pyramides
c    . jaux represente la boucle sur les aretes coupees
c====
c
      kaux = 0
c
      do 61 , iaux = 1 , 2
c
        do 611 , jaux = 1 , 2
c
          aret2 = areint(nuarl2(iaux,jaux,tab1(jaux)))
          aret3 = areint(nuarl3(iaux,jaux,tab1(jaux)))
c
          kaux = kaux + 1
          indtri = indtri + 1
          triint(kaux+18) = indtri
          call cmctri ( aretri, famtri, hettri,
     >                  filtri, pertri, nivtri,
     >                  indtri, aretri(trifad(jaux+1,iaux),1),
     >                  aret2, aret3,
     >                  codetr, niveau )

  611   continue
c
   61 continue
c
#ifdef _DEBUG_HOMARD_
      do 6666 , iaux = 1, 22
      write(ulsort,1789) iaux, triint(iaux),
     >                   ' a1 ',aretri(triint(iaux),1),
     >                   ' a2 ',aretri(triint(iaux),2),
     >                   ' a3 ',aretri(triint(iaux),3)
 6666 continue
 1789 format('triint(',i2,') = ',i6,' : ',5(a,'=',i6,','))
#endif
c
c===
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
