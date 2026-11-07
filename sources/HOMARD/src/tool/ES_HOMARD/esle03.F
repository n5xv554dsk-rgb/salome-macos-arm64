      subroutine esle03 ( idfmed,
     >                    nbnoto, sdim, coonoe, dimcst,
     >                    coocst,
     >                    ulsort, langue, codret)
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
c  Entree-Sortie : LEcture - 03
c  -      -        --        --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nbnoto . e   .   1    . nombre total de noeuds                     .
c . sdim   . e   .   1    . dimension du maillage HOMARD               .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . dimcst . e   .    1   . dimension de la coordonnee constante       .
c .        .     .        . eventuelle, 0 si toutes varient            .
c . coocst .  s  .   11   . 1 : coordonnee constante eventuelle        .
c .        .     .        . 2, 3, 4 : xmin, ymin, zmin                 .
c .        .     .        . 5, 6, 7 : xmax, ymax, zmax                 .
c .        .     .        . 8, 9, 10 : -1 si constant, max-min sinon   .
c .        .     .        . 11 : max des (max-min)                     .
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
      parameter ( nompro = 'ESLE03' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer nbnoto, sdim, dimcst
c
      double precision coonoe(nbnoto,sdim)
      double precision coocst(11)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
      integer numdt, numit
c
      double precision daux
c
      character*64 novals
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
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
      texte(1,5) = '(''... Coordonnes extremes'')'
      texte(1,4) =
     > '(''Direction '',a1,'' : mini = '',g12.5,'' maxi = '',g12.5)'
c
      texte(2,5) = '(''... Extreme coordinates'')'
      texte(2,4) =
     > '(a1,''direction '','' : mini = '',g12.5,'' maxi = '',g12.5)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5))
#endif
c
#include "esimpr.h"
c
c====
c 2. Si une des coordonnees est constante, lecture de la valeur
c    sous forme de valeur scalaire
c====
c
      if ( dimcst.gt.0 ) then
c
        novals = blan64
c                       1234567890123
        novals(1:13) = 'Dim_Constante'
c
        numdt = ednodt
        numit = ednoit
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'MPRRVR', nompro
#endif
        call mprrvr ( idfmed, novals, numdt, numit,
     >                daux, codret )
c
        if ( codret.eq.0 ) then
        coocst(1) = daux
        endif
c
      endif
c
c====
c 3. Les extrema
c====
c 3.1. ==> La fonction de calcul
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMMCO', nompro
#endif
      call utmmco ( coocst(2), coocst(5), coocst(8),
     >              nbnoto, sdim, coonoe,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2. ==> Un rangement different si la coordonnee X ou Y est constante
c
      if ( codret.eq.0 ) then
c
      if ( dimcst.eq.1 ) then
c
c 3.2.1. ==> x est constant : il faut decaler y en z et x en y,
c                             puis affecter la constante a x
c
        coocst(10) = coocst(9)
        coocst(9) = coocst(8)
        coocst(7) = coocst(6)
        coocst(6) = coocst(5)
        coocst(4) = coocst(3)
        coocst(3) = coocst(2)
        coocst(8) = -1.d0
        coocst(5) = coocst(1)
        coocst(2) = coocst(1)
c
      elseif ( dimcst.eq.2 ) then
c
c 3.2.2. ==> y est constant : il faut decaler y en z,
c                             puis affecter la constante a y
c
        coocst(10) = coocst(9)
        coocst(7) = coocst(6)
        coocst(4) = coocst(3)
        coocst(9) = -1.d0
        coocst(6) = coocst(1)
        coocst(3) = coocst(1)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,4)) 'x', coocst(2), coocst(5)
      write (ulsort,texte(langue,4)) 'y', coocst(3), coocst(6)
      write (ulsort,texte(langue,4)) 'z', coocst(4), coocst(7)
      endif
#endif
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
