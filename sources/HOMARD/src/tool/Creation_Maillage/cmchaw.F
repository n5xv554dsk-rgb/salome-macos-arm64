      subroutine cmchaw ( indtri, triint,
     >                    lesare,
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
c                         - par 3 Aretes - phase W
c                                 -              -
c    Remarque : cmchap, cmchaq, cmchar et cmchas sont des clones
c               cmchat, cmchau, cmchav et cmchaw sont des clones
c               tous sont similaires
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . triint .  s  .  27    . triangles internes a l'hexaedre            .
c .        .     .        .  1-6 = appuyes sur une arete non decoupee  .
c .        .     .        .   base de face centrale                    .
c .        .     .        .  7-9 = appuyes sur une arete non decoupee  .
c .        .     .        .   non base de face centrale                .
c .        .     .        .  10-21 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee                          .
c .        .     .        .  22-27 = appuyes sur les filles des aretes .
c .        .     .        .   coupees                                  .
c . lesare . e   .   9    . liste des aretes non coupees               .
c .        .     .        .  1-6 = base de la face i                   .
c .        .     .        .  6+i = opposee a la ieme arete decoupee    .
c . trifad . e   .(6,0:2) . triangles traces sur les faces decoupees   .
c . areint . e  .    11   . aretes internes a l'hexaedre               .
c . areqtr . e  .   (6,2) . aretes sur les faces coupees               .
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
      parameter ( nompro = 'CMCHAW' )
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
      integer indtri
      integer niveau
      integer triint(27)
      integer lesare(9)
      integer trifad(6,0:2)
      integer areint(11)
      integer areqtr(6,2)
      integer aretri(nouvtr,3), famtri(nouvtr)
      integer hettri(nouvtr), filtri(nouvtr), pertri(nouvtr)
      integer nivtri(nouvtr)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codetr
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
      codret = 0
c
      codetr = 1
c
c====
c 2. 1-6 : les triangles base de face centrale
c          le i-eme triangle est sur la face i de l'hexaedre
c====
c
      iaux = 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(iaux), areint(7), areint(5),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(iaux), areint(8), areint(4),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(iaux), areint(7), areint(1),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(iaux), areint(8), areint(6),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(iaux), areint(3), areint(7),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(iaux), areint(2), areint(8),
     >              codetr, niveau )
c
c====
c 3. 7-9 : les 3 autres triangles sur des aretes non decoupees
c          la base du i-eme triangle est // a la i-eme arete coupee
c====
c
      indtri = indtri + 1
      iaux = iaux + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(iaux), areint(6), areint(3),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(iaux), areint(2), areint(5),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, lesare(iaux), areint(4), areint(1),
     >              codetr, niveau )
c
c====
c 4. 10-21 : les triangles s'appuyant sur les aretes tracees
c    sur les faces coupees
c    on les range face par face, et dans une face, sommet par sommet
c====
c
      jaux = 1
c face 1, cote du sommet 1
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,1), areint(9),
     >                                      areint(7),
     >              codetr, niveau )
c face 1, autre cote
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,2), areint(5),
     >                                      areint(9),
     >              codetr, niveau )
c
c face 2, cote du sommet 1
      jaux = 2
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,1), areint(4),
     >                                      areint(9),
     >              codetr, niveau )
c face 2, autre cote
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,2), areint(9),
     >                                      areint(8),
     >              codetr, niveau )
c
c face 3, cote du sommet 3
      jaux = 3
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,1), areint(10),
     >                                      areint(7),
     >              codetr, niveau )
c face 3, autre cote
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,2), areint(1),
     >                                      areint(10),
     >              codetr, niveau )
c
c face 4, cote du sommet 3
      jaux = 4
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,1), areint(6),
     >                                      areint(10),
     >              codetr, niveau )
c face 4, autre cote
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,2), areint(10),
     >                                      areint(8),
     >              codetr, niveau )
c
c face 5, cote du sommet 5
      jaux = 5
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,1), areint(11),
     >                                      areint(7),
     >              codetr, niveau )
c face 5, autre cote
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,2), areint(3),
     >                                      areint(11),
     >              codetr, niveau )
c
c face 6, cote du sommet 5
      jaux = 6
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,1), areint(2),
     >                                      areint(11),
     >              codetr, niveau )
c face 6, autre cote
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(jaux,2), areint(11),
     >                                      areint(8),
     >              codetr, niveau )
c
c====
c 5. 22-27 : les triangles s'appuyant sur les filles des aretes coupees
c    . jaux represente la boucle sur les aretes coupees
c    . aretri(trifad(2*jaux,1),i) : la i-eme fille de l'arete coupee
c    . areint(8+jaux) : l'arete entre le noeud de l'arete coupee et
c                       le centre de l'hexaedre
c    . areint(2*jaux-1) : l'arete entre le sommet 1 de l'arete coupee et
c                         le centre de l'hexaedre
c    . areint(2*jaux  ) : l'arete entre le sommet 2 de l'arete coupee et
c                         le centre de l'hexaedre
c====
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, aretri(trifad(2,1),1),
     >              areint(1), areint(9),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, aretri(trifad(2,2),1),
     >              areint(9), areint(2),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, aretri(trifad(4,1),1),
     >              areint(3), areint(10),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, aretri(trifad(4,2),1),
     >              areint(10), areint(4),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, aretri(trifad(6,1),1),
     >              areint(5), areint(11),
     >              codetr, niveau )
c
      iaux = iaux + 1
      indtri = indtri + 1
      triint(iaux) = indtri
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, aretri(trifad(6,2),1),
     >              areint(11), areint(6),
     >              codetr, niveau )
c
#ifdef _DEBUG_HOMARD_
      do 5555 , iaux = 1, 27
      write(ulsort,1789) iaux, triint(iaux),
     >                   ' a1 ',aretri(triint(iaux),1),
     >                   ' a2 ',aretri(triint(iaux),2),
     >                   ' a3 ',aretri(triint(iaux),3)
      if ( iaux.eq.6 .or. iaux.eq.9 .or. iaux.eq.21 ) then
      write(ulsort,*)' '
      endif
 5555 continue
 1789 format('triint(',i2,') = ',i6,' : ',5(a,'=',i6,','))
#endif
c
c===
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
