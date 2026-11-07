      subroutine vcms21 ( nbno3d, famnoe, coonoe, coocst,
     >                    nbno2d, nustno, nu2dno,
     >                    famn2d, coon2d, famnzz,
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
c    aVant adaptation - Conversion de Maillage -
c     -                 -             -
c                       Saturne 2D - phase 1 - Neptune 2D
c                       -       -          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbno3d . e   .   1    . nombre de noeuds du maillage 3d            .
c . famnoe . e   . nbno3d . famille des noeuds                         .
c . coonoe . e   . nbno3d . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . coocst . e   .   11   . 1 : coordonnee constante eventuelle        .
c .        .     .        . 2, 3, 4 : xmin, ymin, zmin                 .
c .        .     .        . 5, 6, 7 : xmax, ymax, zmax                 .
c .        .     .        . 8, 9, 10 : -1 si constant, max-min sinon   .
c .        .     .        . 11 : max des (max-min)                     .
c . nbno2d . e   .   1    . nombre de noeuds du maillage 2d            .
c . nustno .  s  . nbno2d . numero saturne/neptune des noeuds du calcul.
c . nu2dno .  s  . nbno3d . numero du calcul des noeuds saturne/neptune.
c . famn2d .  s  . nbno2d . famille des noeuds  du maillage 2d         .
c . coon2d .  s  .nbno2d*2. coordonnees des noeuds du maillage 2d      .
c . famnzz .  s  .   1    . famille du noeud memorisant cooinf et zsup .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'VCMS21' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer nbno3d, nbno2d
      integer nustno(nbno2d), nu2dno(nbno3d)
      integer famnoe(nbno3d), famn2d(nbno2d), famnzz
c
      double precision coocst(11)
      double precision coon2d(nbno2d,2)
      double precision coonoe(nbno3d,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer iaux1, iaux2
c
      double precision daux
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
      texte(1,4) =
     > '(''Direction '',a1,'' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(1,5) =
     >'(''Nombre de noeuds pour le maillage 3D          :'',i10)'
      texte(1,6) =
     >'(''Nombre de noeuds attendus pour le maillage 2D :'',i10)'
      texte(1,7) =
     >'(''Nombre de noeuds trouves pour le maillage 2D  :'',i10)'
      texte(1,8) = '(''==> epaisseur maximale = '',g13.5)'
      texte(1,9) = '(''==> coordonnee '',a3,'' ='',g13.5)'
c
      texte(2,4) =
     > '(a1,''direction '','' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(2,5) =
     > '(''Number of nodes for the 3D mesh         :'',i10)'
      texte(2,6) =
     > '(''Expected number of nodes for the 2D mesh:'',i10)'
      texte(2,7) =
     > '(''Found number of nodes for the 2D mesh   :'',i10)'
      texte(2,8) = '(''==> maximal thickness:'',g13.5)'
      texte(2,9) = '(''==> '',a3,'' coordinate:'',g13.5)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'maextr', maextr
      write (ulsort,90002) 'nbno2d', nbno2d
#endif
c
      if ( maextr.eq.1 ) then
        iaux1 = 2
        iaux2 = 3
      elseif ( maextr.eq.2 ) then
        iaux1 = 1
        iaux2 = 3
      elseif ( maextr.eq.3 ) then
        iaux1 = 1
        iaux2 = 2
      else
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,4)) 'x', coocst(2), coocst(5)
      write (ulsort,texte(langue,4)) 'y', coocst(3), coocst(6)
      write (ulsort,texte(langue,4)) 'z', coocst(4), coocst(7)
      write (ulsort,texte(langue,8)) coocst(10)
      write (ulsort,texte(langue,9)) 'inf', coocst(maextr+1)
      write (ulsort,texte(langue,9)) 'sup', coocst(maextr+4)
      endif
#endif
c
c====
c 2. classement des noeuds
c    on retient tous ceux qui sont dans le plan cooinf
c    on teste la proximite de cooinf au millionieme de l'epaisseur
c    on ne remplit le tableau que si on n'a pas depasse le maximum
c    de l'allocation pour eviter les plantages parasites
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. classement des noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nbno3d
      write (ulsort,texte(langue,6)) nbno2d-1
#endif
c
      do 21 , iaux = 1 , nbno3d
        nu2dno(iaux) = 0
   21 continue
c
      daux = coocst(10)*1.d-6
c
      jaux = 0
c
      do 22 , iaux = 1 , nbno3d
c
        if ( abs(coonoe(iaux,maextr)-coocst(maextr+1)).le.daux ) then
c
          jaux = jaux + 1
          if ( jaux.le.(nbno2d-1) ) then
            coon2d(jaux,1) = coonoe(iaux,iaux1)
            coon2d(jaux,2) = coonoe(iaux,iaux2)
            famn2d(jaux) = famnoe(iaux)
            nustno(jaux) = iaux
            nu2dno(iaux) = jaux
          endif
c
        endif
c
   22 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) jaux
#endif
      if ( jaux.ne.(nbno2d-1) ) then
        write (ulsort,texte(langue,4)) 'x', coocst(2), coocst(5)
        write (ulsort,texte(langue,4)) 'y', coocst(3), coocst(6)
        write (ulsort,texte(langue,4)) 'z', coocst(4), coocst(7)
        write (ulsort,texte(langue,6)) nbno2d-1
        write (ulsort,texte(langue,7)) jaux
        codret = 2
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nbno2d-1
#endif
c
c====
c 3. creation d'un noeud supplementaire pour conserver les cotes des
c    faces inferieures et superieures : ( x = cooinf , y = zsup )
c    on utilise une famille qui n'existe pas dans le maillage fourni.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Noeud supplementaire ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      jaux = nbno2d - 1
      famnzz = 0
c
   30 continue
c
      famnzz = famnzz + 1
c
      do 31 , iaux = 1 , jaux
c
        if ( famn2d(iaux).eq.famnzz ) then
          goto 30
        endif
c
   31 continue
c
      coon2d(nbno2d,1) = coocst(maextr+1)
      coon2d(nbno2d,2) = coocst(maextr+4)
      famn2d(nbno2d) = famnzz
      nustno(nbno2d) = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90024) 'Noeud supplementaire', nbno2d,
     >                     coocst(maextr+1), coocst(maextr+4)
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
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
