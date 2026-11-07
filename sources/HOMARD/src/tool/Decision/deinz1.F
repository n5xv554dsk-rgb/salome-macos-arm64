      subroutine deinz1 ( option,
     >                    rayon,
     >                    xcen, ycen, zcen,
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
c     phase 1 : sphere
c           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . 1 : raffinement, -1 : deraffinement        .
c . rayon  . e   .    1   . caracteristiques de la sphere              .
c . xcen   .     .        .                                            .
c . ycen   .     .        .                                            .
c . zcen   .     .        .                                            .
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
      parameter ( nompro = 'DEINZ1' )
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
      double precision rayon, xcen, ycen, zcen
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
      double precision rext2
      double precision xcenlo, ycenlo, zcenlo
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
      texte(1,4) = '(''Zone spherique'')'
      texte(1,8) = '(''Prise en compte du noeud '',i10,3g15.7)'
c
      texte(2,4) = '(''Spherical zone'')'
      texte(2,8) = '(''OK for node # '',i10,3g15.7)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,90004) 'Rayon', rayon
      write (ulsort,90004) 'X centre', xcen
      write (ulsort,90004) 'Y centre', ycen
      write (ulsort,90004) 'Z centre', zcen
      write (ulsort,*) 'sdim =',sdim,', dimcst =',dimcst
      if ( dimcst.ne.0 ) then
      write (ulsort,90004) saux01(dimcst)//' constant', coocst(dimcst+1)
      endif
#endif
c
c 1.2 ==> Carre du rayon
c
      rext2 = rayon*rayon
cgn      write (ulsort,90004) '==> rext2', rext2
c
c====
c 2. Du vrai 3D
c====
c
      if ( sdim.eq.3 ) then
c
        do 21 , iaux = 1, nbnoto
c
          daux = ( coonoe(iaux,1)-xcen ) * ( coonoe(iaux,1)-xcen )
     >         + ( coonoe(iaux,2)-ycen ) * ( coonoe(iaux,2)-ycen )
     >         + ( coonoe(iaux,3)-zcen ) * ( coonoe(iaux,3)-zcen )
c
          if ( daux.le.rext2 ) then
#ifdef _DEBUG_HOMARD_
            write(ulsort,texte(langue,8)) iaux,
     >          coonoe(iaux,1), coonoe(iaux,2), coonoe(iaux,3)
#endif
            nozone(iaux) = option
          endif
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
          xcenlo = xcen
          ycenlo = ycen
          zcenlo = zcen
          jaux = 4
        elseif ( dimcst.eq.1 .or. maextr.eq.1 ) then
          xcenlo = ycen
          ycenlo = zcen
          zcenlo = xcen
          jaux = 2
        elseif ( dimcst.eq.2 .or. maextr.eq.2 ) then
          xcenlo = xcen
          ycenlo = zcen
          zcenlo = ycen
          jaux = 3
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,90004) 'xcenlo', xcenlo
      write (ulsort,90004) 'ycenlo', ycenlo
      write (ulsort,90004) 'zcenlo', zcenlo
#endif
c
        do 31 , iaux = 1, nbnoto
c
          daux = ( coonoe(iaux,1)-xcenlo ) * ( coonoe(iaux,1)-xcenlo )
     >         + ( coonoe(iaux,2)-ycenlo ) * ( coonoe(iaux,2)-ycenlo )
     >         + ( coocst(jaux)-zcenlo ) * ( coocst(jaux)-zcenlo )
c
          if ( daux.le.rext2 ) then
#ifdef _DEBUG_HOMARD_
            write(ulsort,texte(langue,8)) iaux,
     >          coonoe(iaux,1), coonoe(iaux,2)
#endif
            nozone(iaux) = option
          endif
c
   31   continue
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
