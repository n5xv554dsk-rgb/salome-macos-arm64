      subroutine pcma22 ( nbnoto, nbelem,
     >                    nbtr3d, nbqu3d, nbhe3d, nbpe3d, nbele3,
     >                    fameel, typele, noeele,
     >                    fame3d, type3d, noee3d,
     >                    faminf, famsup, nu3dno,
     >                    nparrc, npqurc,
     >                    arerec, quarec, tabaux,
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
c    aPres adaptation - Conversion de MAillage - 2D/3D - phase 2
c     -                 -             --         -             -
c    Creation des mailles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbnoto . e   .   1    . nombre de noeuds du maillage externe       .
c . nbtr3d . e   .   1    . nombre de triangles du maillage 3d         .
c . nbqu3d . e   .   1    . nombre de quadrangles du maillage 3d       .
c . nbhe3d . e   .   1    . nombre d'hexaedres du maillage 3d          .
c . nbpe3d . e   .   1    . nombre de pentaedres du maillage 3d        .
c . nbelem . e   .   1    . nombre d'elements du maillage externe      .
c . nu3dno . e   . nbnoto . numero du calcul des noeuds                .
c . fameel . e   . nbelem . famille med des elements                   .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . fame3d .  s  . nbele3 . famille med des elements du maillage 3d    .
c . type3d .  s  . nbele3 . type des elements du maillage 3d           .
c . noee3d .  s  . nbele3 . noeuds des elements du maillage 3d         .
c .        .     .*nbman3 .                                            .
c . faminf . e   .   1    . famille med des quad de la face inferieure .
c . famsup . e   .   1    . famille med des quad de la face superieure .
c . nu3dno . e   . nbnoto . numero du calcul des noeuds                .
c . nparrc . es  .   1    . nombre de paires d'aretes a recoller       .
c . npqurc .   s .   1    . nombre de paires de quadrangles a recoller .
c . arerec . e   .2*nparrc. paires des aretes a recoller               .
c . quarec .  s  .   2**  . paires des quadrangles a recoller          .
c . tabaux .  a  . nbarto . tableau auxiliaire                         .
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
      parameter ( nompro = 'PCMA22' )
c
#include "nblang.h"
#include "consts.h"
#include "fracti.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "meddc0.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbnoto
      integer nbtr3d, nbqu3d, nbhe3d, nbpe3d, nbele3
      integer nbelem
      integer faminf, famsup
      integer fameel(nbelem), typele(nbelem), noeele(nbelem,*)
      integer fame3d(nbele3), type3d(nbele3), noee3d(nbele3,*)
      integer nu3dno(nbnoto)
c
      integer nparrc, npqurc
      integer arerec(2,*), quarec(2,*)
      integer tabaux(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer el, nuel3d
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
      texte(1,4) = '(''Maille numero :'',i10,'', de noeuds '',8i10)'
      texte(1,5) = '(i1,'' noeud(s) sont dans le plan zinf.'')'
      texte(1,6) = '(''Pour un '',a,'', il en faudrait '',a)'
      texte(1,7) = '(''Famille de la face '',a,'' : '',i6)'
      texte(1,8) = '(''Famille du '',a,i10,'' : '',i6)'
      texte(1,9) =
     >'(''Nombre de '',a,'' attendus pour le maillage 3D :'',i10)'
      texte(1,10) =
     >'(''Nombre de '',a,'' trouves pour le maillage 3D  :'',i10)'
c
      texte(2,4) = '(''Mesh # :'',i10,'', with nodes '',8i10)'
      texte(2,5) = '(i1,'' node(s) are in zinf plane.'')'
      texte(2,6) = '(''For '',a,'', '',a,'' were expected.'')'
      texte(2,7) = '(''Family for '',a,'' face : '',i6)'
      texte(2,8) = '(''Family for '',a,'' #'',i10,'' : '',i6)'
      texte(2,9) =
     > '(''Expected number of '',a,'' for the 3D mesh :'',i10)'
      texte(2,10) =
     > '(''Found number of '',a,'' for the 3D mesh    :'',i10)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbele3', nbele3
#endif
      nuel3d = 0
c
c====
c 2. transformations des quadrangles en hexaedres
c      Convention MED des hexaedres :
c
c             1                   4
c             --------------------
c            /                   /.
c           /                   / .
c          /                   /  .
c         /                   /   .
c       2 -------------------- 3  .
c         .                  .    .
c         .                  .    .
c         .    5             .    . 8
c         .                  .   /
c         .                  .  /
c         .                  . /
c         .                  ./
c         --------------------
c         6                  7
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c    . Les noeuds (5,6,7,8) sont translates de (1,2,3,4)
c    . Le triedre (12,15,14) est direct
c
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. quad -> hexa ; codret', codret
      write (ulsort,90002) 'nbhe3d', nbhe3d
#endif
c
      if ( nbhe3d.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
      do 21 , el = 1 , nbelem
c
        if ( typele(el).eq.edqua4 ) then
c
          nuel3d = nuel3d + 1
          do 211 , iaux = 1 , 4
            noee3d(nuel3d,iaux)   = nu3dno(noeele(el,iaux)) + nbnoto - 1
            noee3d(nuel3d,iaux+4) = nu3dno(noeele(el,iaux))
  211     continue
          fame3d(nuel3d) = fameel(el)
          type3d(nuel3d) = edhex8
c
        endif
c
   21 continue
c
      if ( nuel3d.ne.nbhe3d ) then
        write (ulsort,texte(langue,9))  mess14(langue,3,9), nbhe3d
        write (ulsort,texte(langue,10)) mess14(langue,3,9), nuel3d
        codret = 2
      endif
c
      endif
c
      endif
c
c====
c 3. transformations des triangles en pentaedres
c      Convention MED des pentaedres :
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. tria -> pent ; codret', codret
      write (ulsort,90002) 'nbpe3d', nbpe3d
#endif
c
      if ( nbpe3d.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
      do 31 , el = 1 , nbelem
c
        if ( typele(el).eq.edtri3 ) then
c
          nuel3d = nuel3d + 1
          do 311 , iaux = 1 , 3
            noee3d(nuel3d,iaux)   = nu3dno(noeele(el,iaux)) + nbnoto - 1
            noee3d(nuel3d,iaux+3) = nu3dno(noeele(el,iaux))
  311     continue
          fame3d(nuel3d) = fameel(el)
          type3d(nuel3d) = edpen6
c
        endif
c
   31 continue
c
      if ( (nuel3d-nbhe3d).ne.nbpe3d ) then
        write (ulsort,texte(langue,9))  mess14(langue,3,9), nbpe3d
        write (ulsort,texte(langue,10)) mess14(langue,3,9),
     >                                  nuel3d-nbhe3d
        codret = 3
      endif
c
      endif
c
      endif
c
c====
c 4. creation des quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. creation quadrangles ; codret', codret
#endif
c
      if ( nbqu3d.ne.0 ) then
c
c 4.1. ==> transformations des segments en quadrangles de bord
c
      if ( codret.eq.0 ) then
c
      do 41 , el = 1 , nbelem
c
        if ( typele(el).eq.edseg2 ) then
          nuel3d = nuel3d + 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nuel3d', nuel3d
        write (ulsort,90015) 'noeele(',el,') = ',
     >                       noeele(el,1), noeele(el,2)
        write (ulsort,90015) 'nu3dno(noeele(',el,')) = ',
     >                       nu3dno(noeele(el,1)), nu3dno(noeele(el,2))
#endif
c
          noee3d(nuel3d,1) = nu3dno(noeele(el,1))
          noee3d(nuel3d,2) = nu3dno(noeele(el,2))
          noee3d(nuel3d,3) = nu3dno(noeele(el,2)) + nbnoto - 1
          noee3d(nuel3d,4) = nu3dno(noeele(el,1)) + nbnoto - 1
          fame3d(nuel3d) = fameel(el)
          type3d(nuel3d) = edqua4
          if ( nparrc.gt.0 ) then
            tabaux(el) = nuel3d - nbhe3d
          endif
c
        endif
c
   41 continue
c
      endif
c
c 4.2. ==> creation des quadrangles des faces inf et sup
c          deux faces paralleles doivent tourner en sens inverse ...
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) 'inf', faminf
      write (ulsort,texte(langue,7)) 'sup', famsup
#endif
c
      do 42 , el = 1 , nbelem
c
        if ( typele(el).eq.edqua4 ) then
c
          nuel3d = nuel3d + 1
          noee3d(nuel3d,1) = nu3dno(noeele(el,4))
          noee3d(nuel3d,2) = nu3dno(noeele(el,3))
          noee3d(nuel3d,3) = nu3dno(noeele(el,2))
          noee3d(nuel3d,4) = nu3dno(noeele(el,1))
          fame3d(nuel3d) = faminf
          type3d(nuel3d) = edqua4
c
          nuel3d = nuel3d + 1
          noee3d(nuel3d,1) = nu3dno(noeele(el,1)) + nbnoto - 1
          noee3d(nuel3d,2) = nu3dno(noeele(el,2)) + nbnoto - 1
          noee3d(nuel3d,3) = nu3dno(noeele(el,3)) + nbnoto - 1
          noee3d(nuel3d,4) = nu3dno(noeele(el,4)) + nbnoto - 1
          fame3d(nuel3d) = famsup
          type3d(nuel3d) = edqua4
c
        endif
c
   42 continue
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( (nuel3d-nbhe3d-nbpe3d).ne.(nbqu3d+nbtr3d) ) then
        write (ulsort,texte(langue,9)) mess14(langue,3,8), nbqu3d+nbtr3d
        write (ulsort,texte(langue,10))
     >    mess14(langue,3,8), nuel3d-nbhe3d-nbpe3d
        codret = 444
      endif
c
      endif
c
      endif
c
c====
c 5. creation des triangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. creation triangles ; codret', codret
#endif
c
      if ( nbtr3d.ne.0 ) then
c
c 5.1. ==> creation des triangles des faces inf et sup
c          deux faces paralleles doivent tourner en sens inverse ...
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) 'inf', faminf
      write (ulsort,texte(langue,7)) 'sup', famsup
#endif
c
      do 51 , el = 1 , nbelem
c
        if ( typele(el).eq.edtri3 ) then
c
          nuel3d = nuel3d + 1
          noee3d(nuel3d,1) = nu3dno(noeele(el,1))
          noee3d(nuel3d,2) = nu3dno(noeele(el,2))
          noee3d(nuel3d,3) = nu3dno(noeele(el,3))
          fame3d(nuel3d) = faminf
          type3d(nuel3d) = edtri3
c
          nuel3d = nuel3d + 1
          noee3d(nuel3d,1) = nu3dno(noeele(el,3)) + nbnoto - 1
          noee3d(nuel3d,2) = nu3dno(noeele(el,2)) + nbnoto - 1
          noee3d(nuel3d,3) = nu3dno(noeele(el,1)) + nbnoto - 1
          fame3d(nuel3d) = famsup
          type3d(nuel3d) = edtri3
c
        endif
c
   51 continue
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( (nuel3d-nbhe3d-nbpe3d).ne.(nbqu3d+nbtr3d) ) then
        write (ulsort,texte(langue,9)) mess14(langue,3,8), nbqu3d+nbtr3d
        write (ulsort,texte(langue,10))
     >    mess14(langue,3,8), nuel3d-nbhe3d-nbpe3d
        codret = 555
      endif
c
      endif
c
      endif
c
c====
c 6. transfert des recollements des segments vers les quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. transfert ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 61 , iaux = 1 , nparrc
c
        quarec(1,iaux) = tabaux(arerec(1,iaux))
        quarec(2,iaux) = tabaux(arerec(2,iaux))
c
   61 continue
c
      npqurc = nparrc
      nparrc = 0
c
      endif
c
c====
c 7. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. fin ; codret', codret
      call dmflsh (iaux)
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
