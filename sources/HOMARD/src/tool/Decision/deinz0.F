      subroutine deinz0 ( option,
     >                    xmin, xmax,
     >                    ymin, ymax,
     >                    zmin, zmax,
     >                    coonoe, dimcst, coocst,
     >                    nozone,
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
c traitement des DEcisions - INitialisation de l'indicateur
c                --          --
c                                defini par des Zones de raffinement
c                                               -
c     phase 0 : boite parallelepipedique
c           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . 1 : raffinement, -1 : deraffinement        .
c .xmin/max. e   .    1   . caracteristiques du parallelepipede        .
c .ymin/max.     .        .                                            .
c .zmin/max.     .        .                                            .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c . dimcst . e   .    1   . dimension de la coordonnee constante       .
c .        .     .        . eventuelle, 0 si toutes varient            .
c . coocst . e   .   11   . 1 : coordonnee constante eventuelle        .
c .        .     .        . 2, 3, 4 : xmin, ymin, zmin                 .
c .        .     .        . 5, 6, 7 : xmax, ymax, zmax                 .
c .        .     .        . 8, 9, 10 : -1 si constant, max-min sinon   .
c .        .     .        . 11 : max des (max-min)                     .
c . nozone . aux . nbnoto . auxiliaire pour le transfert zone/noeud    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEINZ0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
c
c 0.3. ==> arguments
c
      integer option
      integer dimcst
      integer nozone(nbnoto)
c
      double precision xmin, xmax, ymin, ymax, zmin, zmax
      double precision coonoe(nbnoto,sdim)
      double precision coocst(11)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      double precision daux
      double precision xminlo, xmaxlo, yminlo, ymaxlo, zminlo, zmaxlo
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
#ifdef _DEBUG_HOMARD_
      character*1 saux01(3)
      data saux01 / 'X', 'Y', 'Z' /
#endif
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Zone parellepipedique'')'
      texte(1,5) = '(''Prise en compte du noeud '',i10,3g15.7)'
c
      texte(2,4) = '(''Zone as a brick'')'
      texte(2,5) = '(''OK for node # '',i10,3g15.7)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,90034) 'Xmin', xmin, 'Xmax', xmax
      write (ulsort,90034) 'Ymin', ymin, 'Ymax', ymax
      write (ulsort,90034) 'Zmin', zmin, 'Zmax', zmax
      write (ulsort,90002) 'sdim', sdim
      write (ulsort,90002) 'dimcst', dimcst
      if ( dimcst.ne.0 ) then
      write (ulsort,90004) saux01(dimcst)//' constant', coocst(dimcst+1)
      endif
      write (ulsort,90002) 'maextr', maextr
#endif
c
c====
c 2. Du vrai 3D
c====
c
      if ( sdim.eq.3 ) then
c
        do 21 , iaux = 1, nbnoto
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,90004) 'X', coonoe(iaux,1), xmin, xmax
        write(ulsort,90004) 'Y', coonoe(iaux,2), ymin, ymax
        write(ulsort,90004) 'Z', coonoe(iaux,3), zmin, zmax
#endif
          if ( coonoe(iaux,1).lt.xmin ) then
            goto 21
          elseif ( coonoe(iaux,1).gt.xmax ) then
            goto 21
          elseif ( coonoe(iaux,2).lt.ymin ) then
            goto 21
          elseif ( coonoe(iaux,2).gt.ymax ) then
            goto 21
          elseif ( coonoe(iaux,3).lt.zmin ) then
            goto 21
          elseif ( coonoe(iaux,3).gt.zmax ) then
            goto 21
          endif
#ifdef _DEBUG_HOMARD_
          write(ulsort,texte(langue,5)) iaux,
     >    coonoe(iaux,1), coonoe(iaux,2), coonoe(iaux,3)
#endif
          nozone(iaux) = option
c
   21   continue
c
c====
c 3. Du vrai 2D ou du 2D defini dans un espace 3D
c    . Avec du vrai 2D, on part du principe que Z est nul
c    . Avec du 2D immerge, on repere
c    . On verifie que la coordonnee constante est compatible,
c      avec une certaine tolerance
c====
c
      else
c
        if ( ( dimcst.eq.0 .or. dimcst.eq.3 ) .and.
     >       ( maextr.eq.0 .or. maextr.eq.3 ) ) then
          xminlo = xmin
          xmaxlo = xmax
          yminlo = ymin
          ymaxlo = ymax
          zminlo = zmin
          zmaxlo = zmax
          jaux = 4
          daux = max(coocst(8), coocst(9))
        elseif ( dimcst.eq.1 .or. maextr.eq.1 ) then
          xminlo = ymin
          xmaxlo = ymax
          yminlo = zmin
          ymaxlo = zmax
          zminlo = xmin
          zmaxlo = xmax
          jaux = 2
          daux = max(coocst(9), coocst(10))
        elseif ( dimcst.eq.2 .or. maextr.eq.2 ) then
          xminlo = xmin
          xmaxlo = xmax
          yminlo = zmin
          ymaxlo = zmax
          zminlo = ymin
          zmaxlo = ymax
          jaux = 3
          daux = max(coocst(10), coocst(8))
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,90034) 'Xminlo', xminlo, 'Xmaxlo', xmaxlo
      write (ulsort,90034) 'Yminlo', yminlo, 'Ymaxlo', ymaxlo
      write (ulsort,90034) 'Zminlo', zminlo, 'Zmaxlo', zmaxlo
#endif
c
        daux = 1.d-4*daux
        if ( zminlo.gt.coocst(jaux)+daux .or.
     >       zmaxlo.lt.coocst(jaux)-daux ) then
          goto 310
        endif
c
        do 31 , iaux = 1, nbnoto
c
          if ( coonoe(iaux,1).lt.xminlo ) then
            goto 31
          elseif ( coonoe(iaux,1).gt.xmaxlo ) then
            goto 31
          elseif ( coonoe(iaux,2).lt.yminlo ) then
            goto 31
          elseif ( coonoe(iaux,2).gt.ymaxlo ) then
            goto 31
          endif
#ifdef _DEBUG_HOMARD_
          write(ulsort,texte(langue,5)) iaux,
     >             coonoe(iaux,1), coonoe(iaux,2)
#endif
          nozone(iaux) = option
c
   31   continue
c
  310   continue
c
      endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
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
