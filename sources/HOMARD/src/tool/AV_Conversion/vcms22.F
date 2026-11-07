      subroutine vcms22 ( maextr,
     >                    nbnoto, nbelem,
     >                    nbse2d, nbtr2d, nbqu2d, nbele2,
     >                    nu2dno, coonoe,
     >                    fameel, typele, noeele,
     >                    fame2d, type2d, noee2d,
     >                    faminf, famsup,
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
c                       Saturne 2D - phase 2 - Neptune 2D
c                       -       -          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . maextr . e   .   1    . maillage extrude                           .
c .        .     .        . 0 : non (defaut)                           .
c .        .     .        . 1 : selon X                                .
c .        .     .        . 2 : selon Y                                .
c .        .     .        . 3 : selon Z (cas de Saturne ou Neptune)    .
c . nbnoto . e   .   1    . nombre de noeuds du maillage externe       .
c . nbse2d . e   .   1    . nombre de segments du maillage 2d          .
c . nbtr2d . e   .   1    . nombre de triangles du maillage 2d         .
c . nbqu2d . e   .   1    . nombre de quadrangles du maillage 2d       .
c . nbelem . e   .   1    . nombre d'elements du maillage externe      .
c . nu2dno . e   . nbnoto . numero du calcul des noeuds saturne/neptune.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . fameel . e   . nbelem . famille med des elements                   .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . fame2d .  s  . nbele2 . famille med des elements du maillage 2d    .
c . type2d .  s  . nbele2 . type des elements du maillage 2d           .
c . noee2d .  s  . nbele2 . noeuds des elements du maillage 2d         .
c .        .     .*nbman2 .                                            .
c . faminf .  s  .   1    . famille med des quad de la face inferieure .
c . famsup .  s  .   1    . famille med des quad de la face superieure .
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
      parameter ( nompro = 'VCMS22' )
c
#include "nblang.h"
#include "consta.h"
#include "consts.h"
#include "fractc.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "infini.h"
#include "meddc0.h"
#include "impr02.h"
#include "op0123.h"
c
c 0.3. ==> arguments
c
      integer maextr
      integer nbnoto
      integer nbse2d, nbtr2d, nbqu2d, nbele2
      integer nbelem
      integer faminf, famsup
      integer nu2dno(nbnoto)
      integer fameel(nbelem), typele(nbelem), noeele(nbelem,*)
      integer fame2d(nbele2), type2d(nbele2), noee2d(nbele2,*)
c
      double precision coonoe(nbnoto,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer iaux1, iaux2
      integer tbiaux(4)
      integer el, nuel2d
      integer numloc(4)
c
      character*1 saux01
c
      double precision xymil(2)
      double precision v1(2), vn(2)
      double precision daux1, daux2
      double precision epsilo
      double precision daux(0:4)
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
      texte(1,4) = '(''Maille numero :'',i10,'', de noeuds '',8i10)'
      texte(1,5) = '(i1,'' noeud(s) sont dans le plan cooinf.'')'
      texte(1,6) = '(''Pour un '',a,'', il en faudrait '',a)'
      texte(1,7) = '(''Famille de la face '',a,'' : '',i6)'
      texte(1,8) = '(''Famille du '',a,i10,'' : '',i6)'
      texte(1,9) =
     >'(''Nombre de '',a,'' attendus pour le maillage 2D :'',i10)'
      texte(1,10) =
     >'(''Nombre de '',a,'' trouves pour le maillage 2D  :'',i10)'
      texte(1,11) = '(''Element '',i10,'' ('',a,''), numloc = '',4i10)'
c
      texte(2,4) = '(''Mesh # :'',i10,'', with nodes '',8i10)'
      texte(2,5) = '(i1,'' node(s) are in cooinf plane.'')'
      texte(2,6) = '(''For '',a,'', '',a,'' were expected.'')'
      texte(2,7) = '(''Family for '',a,'' face : '',i6)'
      texte(2,8) = '(''Family for '',a,'' #'',i10,'' : '',i6)'
      texte(2,9) =
     > '(''Expected number of '',a,'' for the 2D mesh :'',i10)'
      texte(2,10) =
     > '(''Found number of '',a,'' for the 2D mesh    :'',i10)'
      texte(2,11) = '(''Element '',i10,'' ('',a,''), numloc = '',4i10)'
c
#include "impr03.h"
c
      codret = 0
c
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
      nuel2d = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'maextr', maextr
      write (ulsort,90002) 'nbelem', nbelem
      write (ulsort,90002) 'nbele2', nbele2
      write (ulsort,90002) 'nbse2d', nbse2d
      write (ulsort,90002) 'nbqu2d', nbqu2d
      write (ulsort,90002) 'nbtr2d', nbtr2d
#endif
c
      epsilo = 1.d-10 * pi
c
c====
c 2. transformations des quadrangles en segments
c    Attention a les mettre avant les quadrangles pour respecter
c    les conventions ...
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. quad -> segm ; codret', codret
#endif
c
      faminf = 1
      famsup = 1
c
      do 21 , el = 1 , nbelem
c
        if ( codret.eq.0 ) then
c
        if ( typele(el).eq.edqua4 ) then
c
c 2.1. ==> recherche des noeuds dans le plan cooinf
c
          jaux = 0
          do 211 , iaux = 1 , 4
            if ( nu2dno(noeele(el,iaux)).ne.0 ) then
              jaux = jaux + 1
              numloc(jaux) = noeele(el,iaux)
              if ( jaux.eq.1 ) then
                kaux = iaux
              else
                laux = iaux
              endif
            endif
  211     continue
c
#ifdef _DEBUG_HOMARD_
      if ( jaux.gt.0 .and. el.lt.1 ) then
      write (ulsort,texte(langue,11)) el, 'quad',
     >                               (numloc(iaux),iaux=1,jaux)
      endif
#endif
c
c 2.2. ==> si exactement 2 noeuds sont dans le plan, on cree le segment
c          Le segment est cree avec les noeuds dans l'ordre
c          d'apparition dans la connectivite du quadrangle. Cela
c          permettra a la reconstitution du quadrangle apres adaptation
c          de retrouver la meme orientation de la face.
c          attention au retournemnt eventuel ...
c
          if ( jaux.eq.2 ) then
c
            nuel2d = nuel2d + 1
            if ( kaux.eq.1 .and. laux.eq.4 ) then
              iaux = numloc(2)
              numloc(2) = numloc(1)
              numloc(1) = iaux
            endif
            noee2d(nuel2d,1) = nu2dno(numloc(1))
            noee2d(nuel2d,2) = nu2dno(numloc(2))
            fame2d(nuel2d) = fameel(el)
            type2d(nuel2d) = edseg2
c
c 2.3. ==> si exactement 4 noeuds sont dans ce plan, c'est la face
c          inferieure. On memorise le numero de famille
c
          elseif ( jaux.eq.4 ) then
c
            if ( faminf.eq.1 ) then
              faminf = fameel(el)
            else
              if ( fameel(el).ne.faminf ) then
                write (ulsort,texte(langue,7)) 'inf', faminf
                write (ulsort,texte(langue,8))
     >          mess14(langue,1,4), el, fameel(el)
                codret = 23
              endif
            endif
c
c 2.4. ==> si exactement 4 noeuds sont dans l'autre plan, c'est la face
c          superieure. On memorise le numero de famille
c
          elseif ( jaux.eq.0 ) then
c
            if ( famsup.eq.1 ) then
              famsup = fameel(el)
            else
              if ( fameel(el).ne.famsup ) then
                write (ulsort,texte(langue,7)) 'sup', famsup
                write (ulsort,texte(langue,8))
     >          mess14(langue,1,4), el, fameel(el)
                codret = 24
              endif
            endif
c
c 2.5. ==> sinon, c'est louche ...
c
          else
c
            write (ulsort,texte(langue,4)) el,(noeele(el,iaux),iaux=1,4)
            write (ulsort,texte(langue,5)) jaux
            write (ulsort,texte(langue,6)) mess14(langue,1,4),
     >                                     '0, 2 ou 4'
c
          endif
c
        endif
c
        endif
c
   21 continue
c
      if ( codret.eq.0 ) then
c
cgn      write (ulsort,90002) 'nuel2d', nuel2d
cgn      write (ulsort,90002) 'nbse2d', nbse2d
      if ( nuel2d.ne.nbse2d ) then
        write (ulsort,texte(langue,9)) mess14(langue,3,1), nbse2d
        write (ulsort,texte(langue,10))
     >    mess14(langue,3,1), nuel2d-nbse2d
        codret = 222
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) 'inf', faminf
      write (ulsort,texte(langue,7)) 'sup', famsup
#endif
c
c====
c 3. transformations des hexaedres en quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. hexa -> quad ; codret', codret
#endif
c
      if ( nbqu2d.ne.0 ) then
c
      do 31 , el = 1 , nbelem
c
        if ( codret.eq.0 ) then
c
        if ( typele(el).eq.edhex8 ) then
c
c 3.1. ==> recherche des noeuds dans le plan cooinf
c
cgn       write (ulsort,90012) 'noeele',el,(noeele(el,iaux),iaux=1,8)
          jaux = 0
          do 311 , iaux = 1 , 8
            if ( nu2dno(noeele(el,iaux)).ne.0 ) then
              jaux = jaux + 1
              numloc(jaux) = noeele(el,iaux)
            endif
  311     continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'jaux', jaux
      if ( nuel2d.eq.nbse2d.or. nuel2d.eq.988.or.nuel2d.eq.987 ) then
      write (ulsort,texte(langue,11)) el, 'hexa',
     >                               (numloc(iaux),iaux=1,jaux)
      write (ulsort,90004) 'X',(coonoe(numloc(iaux),1),iaux = 1,jaux)
      write (ulsort,90004) 'Y',(coonoe(numloc(iaux),2),iaux = 1,jaux)
      write (ulsort,90004) 'Z',(coonoe(numloc(iaux),3),iaux = 1,jaux)
      endif
#endif
c
c 3.2. ==> si exactement 4 noeuds sont dans ce plan, creation du
c          quadrangle asssocie
c          attention a bien ranger les noeuds pour ne pas croiser !
c          pour cela, on les positionne en fonction de leur milieu :
c
c                                 Y
c                                 .
c                                 .
c                         4...............3
c                         .       .       .
c                         .       .       .
c                         .       .       .
c                         ........M...........> X
c                         .       .       .
c                         .       .       .
c                         .       .       .
c                         1...............2
c
c
          if ( jaux.eq.4 ) then
c
c           Le milieu du quadrangle
c
            xymil(1) = 0.d0
            xymil(2) = 0.d0
            do 313 , iaux = 1 , 4
              xymil(1) = xymil(1) + coonoe(numloc(iaux),iaux1)
              xymil(2) = xymil(2) + coonoe(numloc(iaux),iaux2)
  313       continue
            xymil(1) = unsqu * xymil(1)
            xymil(2) = unsqu * xymil(2)
cgn            write (ulsort,90004) 'xymil', xymil
c
c           Le vecteur entre le milieu et le premier noeud
c
            v1(1) = coonoe(numloc(1),iaux1) - xymil(1)
            v1(2) = coonoe(numloc(1),iaux2) - xymil(2)
            daux1 = sqrt(v1(1)**2+v1(2)**2)
            v1(1) = v1(1)/daux1
            v1(2) = v1(2)/daux1
cgn            write (ulsort,90004) 'v1', v1
c
c           Les angles entre le segment (milieu,noeud 1) et
c           (milieu,noeud suivant)
c
            do 314 , iaux = 2 , 4
              vn(1) = coonoe(numloc(iaux),iaux1) - xymil(1)
              vn(2) = coonoe(numloc(iaux),iaux2) - xymil(2)
              daux1 = sqrt(vn(1)**2+vn(2)**2)
              vn(1) = vn(1)/daux1
              vn(2) = vn(2)/daux1
cgn            write (ulsort,*) ' '
cgn            write (ulsort,90114) 'vn', iaux,vn
              daux1 = v1(1)*vn(1) + v1(2)*vn(2)
              daux2 = v1(1)*vn(2) - v1(2)*vn(1)
cgn        write (ulsort,90114) 'p scal', iaux, daux1
cgn        write (ulsort,90114) 'p vect', iaux, daux2
c
              if ( (daux1+1.d0).le.zeroma ) then
                daux(iaux) = pi
              else
                daux(iaux) = acos(daux1)
              endif
              if ( daux2.le.0.d0 ) then
                daux(iaux) = deuxpi - daux(iaux)
              endif
  314       continue
#ifdef _DEBUG_HOMARD_
      if ( nuel2d.lt.1 ) then
        write (ulsort,90004) 'angles', daux(2), daux(3), daux(4)
      endif
#endif
c
c           Classement des angles
c
            daux1 = min(daux(2), daux(3), daux(4))
            daux2 = max(daux(2), daux(3), daux(4))
cgn        write (ulsort,90004) 'angles min', daux1
cgn        write (ulsort,90004) 'angles max', daux2
            tbiaux(1) = 1
            do 315 , iaux = 2 , 4
              if ( abs(daux(iaux)-daux1).le.epsilo ) then
                tbiaux(2) = iaux
              endif
              if ( abs(daux(iaux)-daux2).le.epsilo ) then
                tbiaux(4) = iaux
              endif
  315       continue
c
            tbiaux(3) = fp0123(tbiaux(2)-1, tbiaux(4)-1) + 1
cgn      write (ulsort,90002) 'tbiaux final  ', tbiaux
c
c           Transfert de la connectivite
c
            nuel2d = nuel2d + 1
            do 316 , iaux = 1 , 4
              noee2d(nuel2d,iaux) = nu2dno(numloc(tbiaux(iaux)))
  316       continue
            fame2d(nuel2d) = fameel(el)
            type2d(nuel2d) = edqua4
#ifdef _DEBUG_HOMARD_
      if ( nuel2d.lt.1 ) then
        write (ulsort,90015) 'typele(',nuel2d,') = ',type2d(nuel2d)
        do 32221 , iaux = 1 , 4
          write (ulsort,90007)
     >    '    noeele',nuel2d,iaux,noee2d(nuel2d,iaux)
32221   continue
      endif
#endif
c
          else
            write (ulsort,texte(langue,4)) el,(noeele(el,iaux),iaux=1,8)
            write (ulsort,texte(langue,5)) jaux
            write (ulsort,texte(langue,6)) mess14(langue,1,9), '4'
c             a changer un jour
            codret = 31
          endif
c
        endif
c
        endif
c
   31 continue
c
      if ( codret.eq.0 ) then
c
cgn      write (ulsort,90002) 'nuel2d', nuel2d
cgn      write (ulsort,90002) 'nbqu2d', nbqu2d
cgn      write (ulsort,90002) 'nuel2d-nbse2d', nuel2d-nbse2d
      if ( (nuel2d-nbse2d).ne.nbqu2d ) then
        write (ulsort,texte(langue,9))  mess14(langue,3,4), nbqu2d
        write (ulsort,texte(langue,10)) mess14(langue,3,4),
     >                                  nuel2d-nbse2d
        codret = 333
      endif
c
      endif
c
      endif
c
c====
c 4. transformations des pentaedres en triangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. pent -> tria ; codret', codret
#endif
c
      if ( nbtr2d.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
      do 41 , el = 1 , nbelem
c
        if ( typele(el).eq.edpen6 ) then
c
c 4.1. ==> recherche des noeuds dans le plan cooinf
c
          jaux = 0
          do 411 , iaux = 1 , 6
            if ( nu2dno(noeele(el,iaux)).ne.0 ) then
              jaux = jaux + 1
              numloc(jaux) = noeele(el,iaux)
            endif
  411     continue
c
#ifdef _DEBUG_HOMARD_
      if ( jaux.gt.0 ) then
      write (ulsort,texte(langue,11)) el, 'pent',
     >                               (numloc(iaux),iaux=1,jaux)
      endif
#endif
c
c 4.2. ==> si exactement 3 noeuds sont dans ce plan, creation du
c          triangle asssocie
c
          if ( jaux.eq.3 ) then
c
            nuel2d = nuel2d + 1
            noee2d(nuel2d,1) = nu2dno(numloc(3))
            noee2d(nuel2d,2) = nu2dno(numloc(2))
            noee2d(nuel2d,3) = nu2dno(numloc(1))
            fame2d(nuel2d) = fameel(el)
            type2d(nuel2d) = edtri3
c
          else
            write (ulsort,texte(langue,4)) el,(noeele(el,iaux),iaux=1,8)
            write (ulsort,texte(langue,5)) jaux
            write (ulsort,texte(langue,6)) mess14(langue,1,9), '4'
c             a changer un jour
            codret = 42
          endif
c
        endif
c
   41 continue
c
      if ( codret.eq.0 ) then
c
cgn      write (ulsort,90002) 'nuel2d', nuel2d
cgn      write (ulsort,90002) 'nbtr2d', nbtr2d
cgn      write (ulsort,90002) 'nuel2d-nbse2d-nbqu2d', nuel2d-nbse2d-nbqu2d
      if ( (nuel2d-nbse2d-nbqu2d).ne.nbtr2d ) then
        write (ulsort,texte(langue,9))  mess14(langue,3,2), nbtr2d
        write (ulsort,texte(langue,10)) mess14(langue,3,2),
     >                                  nuel2d-nbse2d-nbqu2d
        codret = 444
      endif
c
      endif
c
      endif
c
      endif
c
c====
c 5. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. fin ; codret', codret
#endif
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
