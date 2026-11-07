      subroutine utora3 ( orient,
     >                    a0, a1, a2, a3,
     >                    coonoe, somare,
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
c    UTilitaire - ORientation d'Aretes d'un paquet de 3
c    --           --            -                     -
c
c  Determine dans quel sens le paquet des aretes (a1,a2,a3) tourne
c  relativement a l'arete a0
c
c  Si a0 s'enfonce dans le plan courant :
c           positif                      negatif
c            a1                             a1
c             .                              .
c             .                              .
c             .                              .
c            a0                             a0
c           .   .                          .   .
c         .       .                      .       .
c       .           .                  .           .
c     a3             a2              a2            a3
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . orient .  s  .   1    .  1 : dans le sens positif                  .
c .        .     .        . -1 : dans le sens negatif                  .
c . a0     . e   .   1    . arete orientant                            .
c . a1-3   . e   .   1    . aretes a placer                            .
c . coonoe . e   .nbnoto*3. coordonnees des noeuds                     .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'UTORA3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer orient
      integer a0, a1, a2, a3
      integer somare(2,nbarto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lenoeu
c
      double precision daux(3)
      double precision v0(3), v1(3), v2(3), v3(3)
      double precision prm1, prm2, prm3
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. Arete definissant l'orientation
c====
c
      lenoeu = somare(1,a0)
      do 21 , iaux = 1 , sdim
        daux(iaux) = coonoe(lenoeu,iaux)
        v0(iaux) = coonoe(somare(2,a0),iaux) - daux(iaux)
   21 continue
c
#ifdef _DEBUG_HOMARD_
          if ( a0.eq.-8 ) then
      write (ulsort,90001) 'origine arete orientante',a0,lenoeu
      write (ulsort,90004) 'sommet origine ',(daux(iaux),iaux=1,sdim)
      write (ulsort,90004) 'arete orientante',(v0(iaux),iaux=1,3)
          endif
#endif
c
c====
c 3. Aretes a positionner
c====
c 3.1. ==> vecteur de l'arete 1
c
      if ( somare(1,a1).eq.lenoeu ) then
        jaux = 2
      else
        jaux = 1
      endif
      do 31 , iaux = 1 , sdim
        v1(iaux) = coonoe(somare(jaux,a1),iaux) - daux(iaux)
   31 continue
c
c 3.2. ==> vecteur de l'arete 2
c
      if ( somare(1,a2).eq.lenoeu ) then
        jaux = 2
      else
        jaux = 1
      endif
      do 32 , iaux = 1 , sdim
        v2(iaux) = coonoe(somare(jaux,a2),iaux) - daux(iaux)
   32 continue
c
c 3.3. ==> vecteur de l'arete 3
c
      if ( somare(1,a3).eq.lenoeu ) then
        jaux = 2
      else
        jaux = 1
      endif
      do 33 , iaux = 1 , sdim
        v3(iaux) = coonoe(somare(jaux,a3),iaux) - daux(iaux)
   33 continue
c
#ifdef _DEBUG_HOMARD_
          if ( a0.eq.-8 ) then
      write (ulsort,90004) 'arete 1',(v1(iaux),iaux=1,3)
      write (ulsort,90004) 'arete 2',(v2(iaux),iaux=1,3)
      write (ulsort,90004) 'arete 3',(v3(iaux),iaux=1,3)
            endif
#endif
c
c====
c 4. calcul des produits mixtes
c  Si a0 s'enfonce dans le plan courant :
c            a1
c             .
c             .
c             .
c            a0
c               .
c                 .
c                   .
c                    a2
c  Le produit mixte (a0,a1,a2) est >0 tant que a2 est "a droite" de a1,
c  comme sur la figure. Il devient <0 quand a2 passe "a gauche".
c  En examinant successivement les 3 produits, on en deduit la
c  position relative de (a1,a2,a3)
c====
c
      call utprmi ( v0, v1, v2, prm1 )
      call utprmi ( v0, v1, v3, prm2 )
      call utprmi ( v0, v2, v3, prm3 )
#ifdef _DEBUG_HOMARD_
      if ( a0.eq.-8 ) then
      write (ulsort,90004) 'produits mixtes',prm1, prm2, prm3
       endif
#endif
c
      if ( ( prm1.ge.0.d0 .and. prm2.le.0.d0 ) .or.
     >     ( prm1.ge.0.d0 .and. prm2.ge.0.d0 .and. prm3.ge.0.d0 ) .or.
     >     ( prm1.le.0.d0 .and. prm2.le.0.d0 .and. prm3.ge.0.d0 ) )
     >       then
        orient =  1
      else
        orient = -1
      endif
#ifdef _DEBUG_HOMARD_
      if ( a0.eq.-8 ) then
      write (ulsort,90002) 'orient',orient
      endif
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
