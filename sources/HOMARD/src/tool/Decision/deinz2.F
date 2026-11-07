      subroutine deinz2 ( option,
     >                    rext, rint,
     >                    haut,
     >                    xaxe, yaxe, zaxe,
     >                    xbas, ybas, zbas,
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
c     phase 2 : boite cylindrique/tuyau
c           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . 1 : raffinement, -1 : deraffinement        .
c . rext   . e   .    1   . caracteristiques du cylindre/tuyau         .
c . rint   .     .        . Si <0 : cylindre                           .
c . haut   .     .        .                                            .
c .x,y,zaxe.     .        .                                            .
c .x,y,zbas.     .        .                                            .
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
      parameter ( nompro = 'DEINZ2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
#include "nombno.h"
#include "precis.h"
c
c 0.3. ==> arguments
c
      integer option
      integer dimcst
      integer nozone(nbnoto)
c
      double precision rext, rint
      double precision haut
      double precision xaxe, yaxe, zaxe
      double precision xbas, ybas, zbas
      double precision coonoe(nbnoto,sdim)
      double precision coocst(11)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      double precision epsid2
      double precision daux
      double precision vect1(3), vect2(3)
      double precision rint2, rext2
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
c 1.1. ==> Les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Zone cylindrique'')'
      texte(1,5) = '(''Zone tuyau'')'
      texte(1,8) = '(''Prise en compte du noeud '',i10,3g15.7)'
      texte(1,9) = '(''La definition de l''''axe est invalide.'')'
c
      texte(2,4) = '(''Cylindrical zonek'')'
      texte(2,5) = '(''Zone as a brick'')'
      texte(2,8) = '(''OK for node # '',i10,3g15.7)'
      texte(2,9) = '(''The definition of the axis is not valid.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      if ( rint.lt.0 ) then
        write (ulsort,texte(langue,4))
      else
        write (ulsort,texte(langue,5))
        write (ulsort,90004) 'Rint', rint
      endif
      write (ulsort,90004) 'Rext', rext
      write (ulsort,90004) 'Hauteur', haut
      write (ulsort,90004) 'Xaxe', xaxe
      write (ulsort,90004) 'Yaxe', yaxe
      write (ulsort,90004) 'Zaxe', zaxe
      write (ulsort,90004) 'Xbas', xbas
      write (ulsort,90004) 'Ybas', ybas
      write (ulsort,90004) 'Zbas', zbas
cgn      write (ulsort,*) 'sdim =',sdim,', dimcst =',dimcst
      if ( dimcst.ne.0 ) then
      write (ulsort,90004) saux01(dimcst)//' constant', coocst(dimcst+1)
      endif
#endif
c
c 1.2 ==> Carre des rayons
c
      rext2 = rext*rext
cgn      write (ulsort,90004) '==> rext2', rext2
      if ( rint.ge.0 ) then
        rint2 = rint*rint
cgn        write (ulsort,90004) '==> rint2', rint2
      endif
c
c====
c 2. Normalisation du vecteur de l'axe
c====
c
      daux = xaxe*xaxe + yaxe*yaxe + zaxe*zaxe
c
      epsid2 = max(1.d-14,epsima)
      if ( daux.le.epsid2 ) then
        write (ulsort,texte(langue,9))
        codret = 2
      else
        daux = 1.d0 / sqrt( daux )
        vect1(1) = xaxe * daux
        vect1(2) = yaxe * daux
        vect1(3) = zaxe * daux
      endif
c
c====
c 3. Du vrai 3D
c====
c
      if ( sdim.eq.3 ) then
c
        if ( codret.eq.0 ) then
c
        do 31 , iaux = 1, nbnoto
c
c          controle du positionnement sur l'axe :
c          la distance a la base est egale au produit
c          scalaire (base-M)xVecteur-axe
c
          daux = ( coonoe(iaux,1)-xbas ) * vect1(1)
     >         + ( coonoe(iaux,2)-ybas ) * vect1(2)
     >         + ( coonoe(iaux,3)-zbas ) * vect1(3)
c
          if ( daux.lt.0.d0 .or. daux.gt.haut ) then
            goto 31
          endif
c
c           controle du rayon :
c           la distance a l'axe est egale a la norme du
c           produit vectoriel (base-M)xVecteur-axe
c
          vect2(1) = (coonoe(iaux,2)-ybas)*vect1(3)
     >             - (coonoe(iaux,3)-zbas)*vect1(2)
          vect2(2) = (coonoe(iaux,3)-zbas)*vect1(1)
     >             - (coonoe(iaux,1)-xbas)*vect1(3)
          vect2(3) = (coonoe(iaux,1)-xbas)*vect1(2)
     >             - (coonoe(iaux,2)-ybas)*vect1(1)
          daux = vect2(1)*vect2(1)
     >         + vect2(2)*vect2(2)
     >         + vect2(3)*vect2(3)
c
          if ( daux.lt.rint2 .or. daux.gt.rext2 ) then
            goto 31
          endif
c
#ifdef _DEBUG_HOMARD_
          write(ulsort,texte(langue,8)) iaux,
     >    coonoe(iaux,1), coonoe(iaux,2), coonoe(iaux,3)
#endif
          nozone(iaux) = option
c
   31   continue
c
        endif
c
c====
c 4. Du vrai 2D ou du 2D defini dans un espace 3D
c    . Avec du vrai 2D, on part du principe que Z est nul
c    . Avec du 2D immerge, on repere
c    . On verifie que la coordonnee constante est compatible,
c      avec une certaine tolerance
c====
c
      else
c
        codret = 40
c
      endif
c
c====
c 5. la fin
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
