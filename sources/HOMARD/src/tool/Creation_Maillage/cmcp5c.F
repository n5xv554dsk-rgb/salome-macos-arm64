      subroutine cmcp5c ( indtri, triint,
     >                    lesare,
     >                    areint, areqtr, niveau,
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
c    Creation du Maillage - Conformite - decoupage des Pentaedres
c    -           -          -                          -
c                         - cas 5, phase C
c                               -        -
c    Construction des triangles internes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . triint .  s  .  15    . triangles internes au pentaedre            .
c .        .     .        .  1-3 = milieu/milieu et sommet face opposee.
c .        .     .        .  4-6 = milieu/milieu et noeud central      .
c .        .     .        .  7-9 = arete face oppose et noeud central  .
c .        .     .        . 10-15 = appuyes sur une arete interne a    .
c .        .     .        .        une face quadrangulaire coupee      .
c . lesare . e   .   3    . liste des aretes du pentaedre utiles       .
c .        .     .        .  1-3 = arete face oppose                   .
c . areint . e  .    6    . aretes internes au pentaedre               .
c . areqtr . e   .(4,0:3) . aretes tracees sur les faces decoupees     .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . famtri . es  . nouvtr . famille des triangles                      .
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
      parameter ( nompro = 'CMCP5C' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nouvnb.h"
#include "ope1a3.h"
c
c 0.3. ==> arguments
c
      integer indtri
      integer niveau
      integer triint(15)
      integer lesare(3)
      integer areint(6)
      integer areqtr(4,0:3)
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
c 2. Les triangles entre les aretes tracees sur la face coupee et
c    les sommets de la face opposee
c====
c
      do 21 , iaux = 1 , 3
c
        jaux = per1a3(1,iaux)
c
        indtri = indtri + 1
        triint(iaux) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_123', nompro
#endif
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri,
     >                areqtr(iaux,1), areqtr(4,iaux), areqtr(jaux,2),
     >                codetr, niveau )
c
   21 continue
c
c====
c 3. Les triangles entre les aretes tracees sur la face coupee et
c    le noeud central
c====
c
      do 31 , iaux = 1 , 3
c
        jaux = per1a3(1,iaux)
c
        indtri = indtri + 1
        triint(iaux+3) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_456', nompro
#endif
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri,
     >                areint(iaux+3), areqtr(4,iaux), areint(jaux+3),
     >                codetr, niveau )
c
   31 continue
c
c====
c 4. Les triangles s'appuyant sur les 3 aretes de la face non decoupee
c====
c
      do 41 , iaux = 1 , 3
c
        jaux = per1a3(-1,iaux)
c
        indtri = indtri + 1
        triint(iaux+6) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_789', nompro
#endif
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri,
     >                areint(iaux), lesare(iaux), areint(jaux),
     >                codetr, niveau )
c
   41 continue
c
c====
c 5. Les triangles s'appuyant sur les aretes tracees sur
c    les quadrangles coupes
c====
c
      do 511 , iaux = 1 , 3
c
        indtri = indtri + 1
        triint(iaux+9) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_10-11-12', nompro
#endif
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri,
     >                areint(iaux), areqtr(iaux,1), areint(iaux+3),
     >                codetr, niveau )
c
  511 continue
c
      do 512 , iaux = 1 , 3
c
        jaux = per1a3(-1,iaux)
c
        indtri = indtri + 1
        triint(iaux+12) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_13-14-15', nompro
#endif
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri,
     >                areint(iaux+3), areqtr(iaux,2), areint(jaux),
     >                codetr, niveau )
c
  512 continue
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
