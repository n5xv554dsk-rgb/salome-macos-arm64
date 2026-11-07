      subroutine pcma21 ( choixd, deltac,
     >                    nbnoto, nbelem, famnoe, coonoe,
     >                    famnzz, nbno3d,
     >                    typele, noeele,
     >                    nu3dno, famn3d, coon3d,
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
c    aPres adaptation - Conversion de MAillage - 2D/3D - phase 1
c     -                 -             --         -             -
c    Creation des noeuds supplementaires
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choixd . e   .   1    . choix sur le calcul de delta coordonnes :  .
c .        .     .        . 1 : coordonnees initiales (defaut)         .
c .        .     .        . 2 : valeur imposee                         .
c .        .     .        . 3 : moyenne arithmetique des mini/maxi en  .
c .        .     .        .     (x,y) des mailles                      .
c .        .     .        . 4 : moyenne geometrique des mini/maxi en   .
c .        .     .        .     (x,y) des mailles                      .
c .        .     .        . 5 : ecart initial, divise par 2**nivsup    .
c . deltac . e   .   1    . valeur de delta si impose (choixd=1)       .
c . nbnoto . e   .   1    . nombre de noeuds du maillage externe       .
c . nbelem . e   .   1    . nombre d'elements du maillage externe      .
c . famnoe . e   . nbnoto . famille des noeuds                         .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . famnzz . e   .   1    . famille du noeud memorisant cooinf et coosup   .
c . nbno3d . e   .   1    . nombre de noeuds du maillage 3d            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . nu3dno .  s  . nbnoto . numero du calcul des noeuds                .
c . famn3d .  s  . nbno3d . famille des noeuds  du maillage 3d         .
c . coon3d .  s  .nbno3d*3. coordonnees des noeuds du maillage 3d      .
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
      parameter ( nompro = 'PCMA21' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "meddc0.h"
#include "envca1.h"
#include "envada.h"
c
c 0.3. ==> arguments
c
      integer choixd
      integer nbnoto, nbelem, famnzz, nbno3d
      integer nu3dno(nbnoto)
      integer famnoe(nbnoto), famn3d(nbno3d)
      integer typele(nbelem), noeele(nbelem,*)
c
      double precision deltac
      double precision coon3d(nbno3d,3)
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer iaux1, iaux2
c
      double precision cooinf, coosup
      double precision daux, daux1, daux2
      double precision minx, miny, maxx, maxy
c
      character*1 saux01
c
      integer nbmess
      parameter ( nbmess = 20 )
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
     >'(''Nombre de noeuds attendus pour le maillage 2D :'',i10)'
      texte(1,6) =
     >'(''Nombre de noeuds trouves pour le maillage 2D  :'',i10)'
      texte(1,7) = '(''Recherche du noeud de la famille '',i8)'
      texte(1,8) = '(''Aucun noeud n''''est de la famille '',i8)'
      texte(1,9) = '(''Impossible de retrouver cooinf et coosup.'')'
      texte(1,10) =
     > '(''Maille en '',a1,'' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(1,11) = '(''Choix du calcul de delta '',a1,'' :'',i8)'
      texte(1,12) = '(''Ce choix est inconnu.'')'
      texte(1,13) = '(''Delta '',a1,'' initial.'')'
      texte(1,14) = '(''Delta '',a1,'' impose.'')'
      texte(1,15) =
     >'(''D'',a1,'' = moyenne arithmetique des mini/maxi des mailles'')'
      texte(1,16) =
     > '(''D'',a1,'' = moyenne geometrique des mini/maxi des mailles'')'
      texte(1,17) = '(''D'',a1,'' = D initial / 2**nivsup'')'
c
      texte(2,4) =
     > '(a1,''direction '','' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(2,5) =
     > '(''Expected number of nodes for the 2D mesh :'',i10)'
      texte(2,6) =
     > '(''Found number of nodes for the 2D mesh    :'',i10)'
      texte(2,7) = '(''Searching for node with family # '',i8)'
      texte(2,8) = '(''No node belongs to family # '',i8)'
      texte(2,9) = '(''cooinf and coosup cannot be found.'')'
      texte(2,10) =
     > '(''Mesh along '',a1,'' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(2,11) = '(''Choice for delta '',a1,'' calculation :'',i8)'
      texte(2,12) = '(''This choice is unknown :'',i8)'
      texte(2,13) = '(''Initial Delta '',a1,''.'')'
      texte(2,14) = '(''Imposed Delta '',a1,''.'')'
      texte(2,15) =
     > '(''D'',a1,'' = arithmetic mean of mini/maxi of meshes'')'
      texte(2,16) =
     > '(''D'',a1,'' = geometric mean of mini/maxi of meshes'')'
      texte(2,17) = '(''D'',a1,'' = initial / 2**nivsup'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'maextr', maextr
#endif
      if ( maextr.eq.1 ) then
        saux01 = 'X'
        iaux1 = 2
        iaux2 = 3
      elseif ( maextr.eq.2 ) then
        saux01 = 'Y'
        iaux1 = 1
        iaux2 = 3
      elseif ( maextr.eq.3 ) then
        saux01 = 'Z'
        iaux1 = 1
        iaux2 = 2
      else
        codret = 1
      endif
c
c====
c 2. Quelle epaisseur ?
c====
c 2.1. ==> recuperation des cotes initiales des faces inferieures et
c          superieures, en examinant le noeud supplementaire :
c               ( x = cooinf , y = coosup )
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) famnzz
#endif
c
      do 21 , iaux = 1 , nbnoto
c
        if ( famnoe(iaux).eq.famnzz ) then
c
          cooinf = coonoe(iaux,1)
          coosup = coonoe(iaux,2)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,4)) saux01, cooinf, coosup
#endif
          goto 210
c
        endif
c
   21 continue
c
      write (ulsort,texte(langue,8)) famnzz
      write (ulsort,texte(langue,9))
      codret = 12
c
  210 continue
c
      endif
c
c 2.2. ==> recherche eventuelle des tailles mini/maxi des mailles, selon
c          les axes perpendicalaires a la direction d'extrusion
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. recherche ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) saux01, choixd
#endif
c
      if ( choixd.eq.3 .or. choixd.eq.4 ) then
c
        if ( codret.eq.0 ) then
c
c 2.2.1. ==> initialisation des extrema pour la premiere maille trouvee
c
        do 221 , iaux = 1 , nbelem
c
          if ( typele(iaux).eq.edqua4 ) then
c
            daux1 =
     >    abs(coonoe(noeele(iaux,2),iaux1)-coonoe(noeele(iaux,1),iaux1))
            daux2 =
     >    abs(coonoe(noeele(iaux,3),iaux1)-coonoe(noeele(iaux,2),iaux1))
          maxx = max ( daux1, daux2 )
            minx = maxx
c
            daux1 =
     >    abs(coonoe(noeele(iaux,2),iaux2)-coonoe(noeele(iaux,1),iaux2))
            daux2 =
     >    abs(coonoe(noeele(iaux,3),iaux2)-coonoe(noeele(iaux,2),iaux2))
            maxy = max ( daux1, daux2 )
            miny = maxy
            goto 222
c
          endif
c
  221   continue
c
  222   continue
c
c 2.2.2. ==> parcours de toutes les mailles
c            on teste la non nullite au millionieme de l'ecart initial
c            entre le dessus et le dessous, divise par
c            10 puissance le niveau superieur atteint
c
        daux = 1.d-6*(coosup-cooinf)/10.d0**nivsup
c
        do 223 , iaux = 1 , nbelem
c
          if ( typele(iaux).eq.edqua4 ) then
c
            daux1 =
     >    abs(coonoe(noeele(iaux,2),iaux1)-coonoe(noeele(iaux,1),iaux1))
            daux2 =
     >    abs(coonoe(noeele(iaux,3),iaux1)-coonoe(noeele(iaux,2),iaux1))
c
            maxx = max ( maxx, daux1, daux2 )
            if ( daux1.gt.daux ) then
              minx = min ( minx, daux1 )
            else
              minx = min ( minx, daux2 )
            endif
c
            daux1 =
     >    abs(coonoe(noeele(iaux,2),iaux2)-coonoe(noeele(iaux,1),iaux2))
            daux2 =
     >    abs(coonoe(noeele(iaux,3),iaux2)-coonoe(noeele(iaux,2),iaux2))
            maxy = max ( maxy, daux1, daux2 )
            if ( daux1.gt.daux ) then
              miny = min ( miny, daux1 )
            else
              miny = min ( miny, daux2 )
            endif
c
          endif
c
  223   continue
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) '1', minx, maxx
        write (ulsort,texte(langue,10)) '2', miny, maxy
#endif
c
        endif
c
      endif
c
c====
c 3. les noeuds de depart sont dans le plan cooinf
c    on cree leur correspondant dans le plan coosup
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Noeuds de depart ; codret', codret
#endif
c
c 3.0. ==> Calcul de l'ecart cooinf<-->coosup
c
      if ( codret.eq.0 ) then
c
      if ( choixd.ge.1 .and. choixd.le.5 ) then
        write (ulsort,texte(langue,12+choixd)) saux01
      else
        write (ulsort,texte(langue,11)) saux01, choixd
        write (ulsort,texte(langue,12))
        codret = 1
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( choixd.eq.1 ) then
        daux = coosup - cooinf
      elseif ( choixd.eq.2 ) then
        daux = deltac
      elseif ( choixd.eq.3 ) then
        daux = (minx+miny+maxx+maxy) * 0.25d0
      elseif ( choixd.eq.4 ) then
        daux = (minx*miny*maxx*maxy) ** 0.25d0
      elseif ( choixd.eq.5 ) then
        write (ulsort,90002) 'nivinf, nivsup',nivinf, nivsup
        daux = ( coosup - cooinf ) / 2.d0**nivsup
      endif
c
      coosup = cooinf + daux
      write (ulsort,texte(langue,4)) saux01, cooinf, coosup
c
      jaux = 0
c
      do 31 , iaux = 1 , nbnoto
c
        if ( famnoe(iaux).eq.famnzz ) then
c
          nu3dno(iaux) = 0
c
        else
c
          jaux = jaux + 1
          coon3d(jaux,iaux1) = coonoe(iaux,1)
          coon3d(jaux,iaux2) = coonoe(iaux,2)
          coon3d(jaux,maextr) = cooinf
          famn3d(jaux) = famnoe(iaux)
          nu3dno(iaux) = jaux
c
          kaux = jaux + nbnoto - 1
          coon3d(kaux,iaux1) = coonoe(iaux,1)
          coon3d(kaux,iaux2) = coonoe(iaux,2)
          coon3d(kaux,maextr) = coosup
          famn3d(kaux) = famnoe(iaux)
c
        endif
c
   31 continue
c
      if ( kaux.ne.nbno3d ) then
        write (ulsort,texte(langue,5)) nbno3d
        write (ulsort,texte(langue,6)) jaux
        codret = 3
      endif
c
      endif
c
c====
c 4. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. fin ; codret = ', codret
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
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
