      subroutine utb05b (  choix, typenh, nbeexa, quadia, qualij,
     >                    nbiter, rafdef, nbvoto, enqinf,
     >                    ulbila,
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
c    UTilitaire - Bilan - option 05 - etape b
c    --           -              --         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .    1   . variantes                                  .
c .        .     .        .   0 : diametres                            .
c .        .     .        .   1 : qualites                             .
c .        .     .        .   2 : qualites par le jacobien normalise   .
c . typenh . e   .    1   . variantes                                  .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nbeexa . e   .   1    . nombre d'entites a examiner                .
c . quadia . e   . nbeexa . qualite/diametre des entites a examiner    .
c . qualij . e   . nbeexa . qualite par le jacobien normalise          .
c . nbiter . e   .   1    . numero de l'iteration courante             .
c . rafdef . e   .   1    . histoire du maillage en raff/dera/modi     .
c . nbvoto . e   .   1    . nombre de volumes                          .
c . enqinf . e   .    *   . liste des entites de qualite infinie       .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB05B' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "enti01.h"
#include "impr02.h"
#include "precis.h"
#include "infini.h"
c
c 0.3. ==> arguments
c
      double precision quadia(*)
      double precision qualij(*)
      double precision valmin, valmax
c
      integer choix, typenh, nbeexa
      integer nbiter, nbvoto
      integer enqinf(*)
c
      integer ulbila, rafdef
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer lechoi, choide, choifi
      integer nbqinf
c
      integer nbclmx
      parameter (nbclmx=50)
      integer histog(nbclmx)
      integer iclass(0:nbclmx)
      double precision rclass(0:nbclmx)
      integer nbclas
c
      character*8 titcou(6)
      character*9 saux09
c
      integer typval, ival(1)
      integer iaux, jaux, kaux
      integer nuroul, lnomfl
      integer difexp
      integer lgmess(nblang,0:2)
      integer nxmd58(nblang,7)
      integer nxmq58(nblang,7)
      integer nxmj58(nblang,7)
c
      double precision xlow
      double precision vamiar, vamaar, valdif, difman, valech
      double precision daux, daux1
      double precision vmax, vmin
c
      character*80 saux80, sau80a
      character*08 mess08(nblang,4)
      character*09 mess09(nblang,0:2)
      character*200 nomflo
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
      character*58 mege58(nblang,0:nbmess)
      character*58 medi58(nblang,nbmess,7)
      character*58 mequ58(nblang,nbmess,7)
      character*58 meqj58(nblang,nbmess,7)
c
      logical consta
c
c 0.5. ==> initialisations
c
      data typval / 2 /
      data xlow / 1.d0 /
c ______________________________________________________________________
c
c====
c 1. Messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.1. ==> Messages generaux
c                    123456789
      mess09(1,0) = 'Diametre '
      mess09(1,1) = 'Qualite  '
      mess09(1,2) = 'Qualite  '
c
      mess09(2,0) = 'Diameter '
      mess09(2,1) = 'Quality  '
      mess09(2,2) = 'Quality  '
c
      texte(1,4) = '(''Nombre de '',a,'' a examiner : '',i8)'
      texte(1,5) = '(''--> valeur arrondie pour le '',a,'' :'',g15.6)'
      texte(1,6) = '(5x,''Nombre de '',a,'' aplatis : '',i8)'
      texte(1,7) = '(5x,''Le '',a,i10,'' est aplati.'')'
c
      texte(2,4) = '(''Number of '',a,'' to be examined : '',i8)'
      texte(2,5) = '(''--> round value for '',a,'' :'',g15.6)'
      texte(2,6) = '(5x,''Number of flat '',a,'': '',i8)'
      texte(2,7) = '(5x,''The '',a,'' #'',i10,'' is flat.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'ulbila', ulbila
#endif
c
c       1234567890123456789012345678901234567890123456789012345678
      mege58(1,0) =
     > 'DIAMETRES DES                                             '
      lgmess(1,0) = 13
      mege58(1,1) =
     > 'QUALITES DES                                              '
      lgmess(1,1) = 12
      mege58(1,2) =
     > 'QUALITES EN JACOBIEN NORMALISE DES                        '
      lgmess(1,2) = 34
      mege58(1,3) =
     > '            Valeur constante :                            '
      mege58(1,4) =
     > 'Remarque : on ne regarde ici que les triangles qui        '
      mege58(1,5) =
     > 'sont de vraies mailles de calcul.                         '
      mege58(1,6) =
     > 'Remarque : on ne regarde ici que les quadrangles qui      '
c
      mege58(2,0) =
     > 'DIAMETERS OF                                              '
      lgmess(2,0) = 12
      mege58(2,1) =
     > 'QUALITY OF                                                '
      lgmess(2,1) = 10
      mege58(2,2) =
     > 'QUALITY WITH SCALED JACOBIAN OF                           '
      lgmess(2,2) = 31
      mege58(2,3) =
     > '              Constant value :                            '
      mege58(2,4) =
     > 'Remark : only triangles which are real calculation        '
      mege58(2,5) =
     > 'meshes are seen here.                                     '
      mege58(2,6) =
     > 'Remark : only quadrangles which are real calculation      '
c
c 1.2. ==> Messages lies aux diametres
c
      medi58(1,1,1) =
     > 'Rappel : le diametre est egal a la longueur du plus       '
      medi58(1,2,1) =
     > 'grand segment que l''on peut tracer dans la maille.        '
c
      medi58(1,1,2) =
     > 'Pour un triangle, c''est la longueur de la plus            '
      medi58(1,2,2) =
     > 'grande arete.                                             '
      nxmd58(1,2) = 2
c
      medi58(1,1,3) =
     > 'Pour un tetraedre, c''est la longueur de la plus           '
      medi58(1,2,3) =
     > 'grande arete.                                             '
      nxmd58(1,3) = 2
c
      medi58(1,1,4) =
     > 'Pour un quadrangle, c''est la plus grande longueur entre   '
      medi58(1,2,4) =
     > 'les aretes et les diagonales.                             '
      nxmd58(1,4) = 2
c
      medi58(1,1,5) =
     > 'Pour une pyramide, c''est la plus grande longueur entre    '
      medi58(1,2,5) =
     > 'les aretes et les diagonales de la base.                  '
      nxmd58(1,5) = 2
c
      medi58(1,1,6) =
     > 'Pour un hexaedre, c''est la plus grande longueur entre     '
      medi58(1,2,6) =
     > 'les aretes et les diagonales.                             '
      nxmd58(1,6) = 2
c
      medi58(1,1,7) =
     > 'Pour un pentaedre, c''est la plus grande longueur entre    '
      medi58(1,2,7) =
     > 'les aretes et les diagonales.                             '
      nxmd58(1,7) = 2
c
      medi58(2,1,1) =
     > 'Note: diameter egals the length of the largest line that  '
      medi58(2,2,1) =
     > 'can be placed in the mesh.                                '
c
      medi58(2,1,2) =
     > 'For a triangle, it is the length of the largest edge.     '
      nxmd58(2,2) = 1
c
      medi58(2,1,3) =
     > 'For a tetradron, it is the length of the largest edge.    '
      nxmd58(2,3) = 1
c
      medi58(2,1,4) =
     > 'For a quadrangle, it is the largest length between edges  '
      medi58(2,2,4) =
     > 'and diagonals.                                            '
      nxmd58(2,4) = 2
c
      medi58(2,1,5) =
     > 'For a pyramid, it is the largest length between edges     '
      medi58(2,2,5) =
     > 'and diagonals of the basis.                               '
      nxmd58(2,5) = 2
c
      medi58(2,1,6) =
     > 'For an hexahedron, it is the largest length between edges '
      medi58(2,2,6) =
     > 'and diagonals.                                            '
      nxmd58(2,6) = 2
c
      medi58(2,1,7) =
     > 'For a prism, it is the largest length between edges and   '
      medi58(2,2,7) =
     > 'diagonals of the basis.                                   '
      nxmd58(2,7) = 2
c
c 1.3. ==> Messages lies aux qualites
c
      mequ58(1,1,2) =
     > 'Rappel : la qualite est egale au rapport du diametre du   '
      mequ58(1,2,2) =
     > 'triangle sur le rayon du cercle inscrit, normalise a 1    '
      mequ58(1,3,2) =
     > 'pour un triangle equilateral.                             '
      nxmq58(1,2) = 3
c
      mequ58(1,1,3) =
     > 'Rappel : la qualite est egale au rapport du diametre du   '
      mequ58(1,2,3) =
     > 'tetraedre sur le rayon de la sphere inscrite,             '
      mequ58(1,3,3) =
     > 'normalise a 1 pour un tetraedre regulier.                 '
      nxmq58(1,3) = 3
c
      mequ58(1,1,4) =
     > 'Rappel : la qualite est egale au rapport du produit de    '
      mequ58(1,2,4) =
     > 'la plus grande longueur des cotes et des diagonales et    '
      mequ58(1,3,4) =
     > 'de la moyenne quadratique des cotes sur la surface        '
      mequ58(1,4,4) =
     > 'minimum des triangles inscrits, normalise a 1 pour        '
      mequ58(1,5,4) =
     > 'pour un carre.                                            '
      nxmq58(1,4) = 5
c
c       123456789012345678901234567890123456789012345678901234
      mequ58(1,1,5) =
     > 'Non definie aujourd''hui.                                  '
      nxmq58(1,5) = 1
c
      mequ58(1,1,6) =
     > 'Rappel : la qualite est egale a la qualite du pire des    '
      mequ58(1,2,6) =
     > '24 tetraedres composant l''hexaedre, normalise a 1         '
      mequ58(1,3,6) =
     > 'pour un cube.                                             '
      nxmq58(1,6) = 3
c
      mequ58(1,1,7) =
     > 'Non definie aujourd''hui.                                  '
      nxmq58(1,7) = 1
c
c       1234567890123456789012345678901234567890123456789012345678
      mequ58(2,1,2) =
     > 'Note: the quality equals the ratio of the diametre        '
      mequ58(2,2,2) =
     > 'of the triangle by the radius of the inscribed circle     '
      mequ58(2,3,2) =
     > 'normalised to 1 for an equilateral triangle.              '
      nxmq58(2,2) = 3
c
      mequ58(2,1,3) =
     > 'Note: the quality equals the ratio of the diametre        '
      mequ58(2,2,3) =
     > 'of the tetradron by the radius of the inscribed sphere    '
      mequ58(2,3,3) =
     > 'normalised to 1 for a regular tetrahedron.                '
      nxmq58(2,3) = 3
c
      mequ58(2,1,4) =
     > 'Note: the quality equals the ratio of the product of      '
      mequ58(2,2,4) =
     > 'the largest edge and diagonals and square mean of edge    '
      mequ58(2,3,4) =
     > 'over minimum surface of inscribed triangles.              '
      mequ58(2,4,4) =
     > 'This valeur is normalised to 1 for a square.              '
      nxmq58(2,4) = 4
c
      mequ58(2,1,5) =
     > 'Not available.                                            '
      nxmq58(2,5) = 1
c
      mequ58(2,1,6) =
     > 'Note: the quality equals the worse quality of the         '
      mequ58(2,2,6) =
     > 'the 24 tetrahedron composing the hexahedron               '
      mequ58(2,3,6) =
     > 'normalised to 1 for a cube.                               '
      nxmq58(2,6) = 3
c
      mequ58(2,1,7) =
     > 'Not available.                                            '
      nxmq58(2,7) = 1
c
c 1.4. ==> Messages lies aux qualites en jacobien normalise
c
      meqj58(1,1,2) =
     > 'Rappel : la qualite est egale au minimum des Jacobiens    '
      meqj58(1,2,2) =
     > 'pour chacun des sommets, normalise a 1 pour               '
      meqj58(1,3,2) =
     > 'un triangle equilateral.                                  '
      nxmj58(1,2) = 3
c
      meqj58(1,1,3) =
     > 'Rappel : la qualite est egale au minimum des Jacobiens    '
      meqj58(1,2,3) =
     > 'pour chacun des sommets, normalise a 1 pour               '
      meqj58(1,3,3) =
     > 'un tetraedre regulier.                                    '
      nxmj58(1,3) = 3
c
      meqj58(1,1,4) =
     > 'Rappel : la qualite est egale au minimum des Jacobiens    '
      meqj58(1,2,4) =
     > 'pour chacun des sommets, normalise a 1 pour un carre.     '
      nxmj58(1,4) = 2
c
      meqj58(1,1,5) =
     > 'Rappel : la qualite est egale au minimum des Jacobiens    '
      meqj58(1,2,5) =
     > 'pour chacun des sommets, normalise a 1 pour               '
      meqj58(1,3,5) =
     > 'une pyramide reguliere.                                   '
      nxmj58(1,5) = 3
c
      meqj58(1,1,6) =
     > 'Rappel : la qualite est egale au minimum des Jacobiens    '
      meqj58(1,2,6) =
     > 'pour chacun des sommets, normalise a 1 pour un cube.      '
      nxmj58(1,6) = 2
c
      meqj58(1,1,7) =
     > 'Rappel : la qualite est egale au minimum des Jacobiens    '
      meqj58(1,2,7) =
     > 'pour chacun des sommets, normalise a 1 pour               '
      meqj58(1,3,7) =
     > 'un pentaedre regulier.                                    '
      nxmj58(1,7) = 3
c
c       1234567890123456789012345678901234567890123456789012345678
      meqj58(2,1,2) =
     > 'Note: the quality equals the minimum of the Jacobian for  '
      meqj58(2,2,2) =
     > 'every node, normalised to 1 for an equilateral triangle.  '
      nxmj58(2,2) = 2
c
      meqj58(2,1,3) =
     > 'Note: the quality equals the minimum of the Jacobian for  '
      meqj58(2,2,3) =
     > 'every node, normalised to 1 for a regular tetrahedron.    '
      nxmj58(2,3) = 2
c
      meqj58(2,1,4) =
     > 'Note: the quality equals the minimum of the Jacobian for  '
      meqj58(2,2,4) =
     > 'every node, normalised to 1 for a square.                 '
      nxmj58(2,4) = 2
c
      meqj58(2,1,5) =
     > 'Note: the quality equals the minimum of the Jacobian for  '
      meqj58(2,2,5) =
     > 'every node, normalised to 1 for a regular pyramid.        '
      nxmj58(2,5) = 2
c
      meqj58(2,1,6) =
     > 'Note: the quality equals the minimum of the Jacobian for  '
      meqj58(2,2,6) =
     > 'every node, normalised to 1 for a cube.                   '
      nxmj58(2,6) = 2
c
      meqj58(2,1,7) =
     > 'Note: the quality equals the minimum of the Jacobian for  '
      meqj58(2,2,7) =
     > 'every node, normalised to 1 for a regular prism.          '
      nxmj58(2,7) = 2
c
10100 format(/,5x,64('*'))
10200 format(  5x,64('*'))
11100 format(/,4x,a,/,4x,a)
11200 format(  5x,'*  ',a58,'  *')
c
      codret = 0
c
c====
c 2. Initialisations
c====
c 2.1. ==> Recherche des types d'impressions a faire
c
      if ( choix.eq.12 ) then
        choide = 1
        choifi = 2
      else
        choide = choix
        choifi = choix
      endif
c
c 2.2. ==> Valeurs extremes pour les aplatissements
c
      vmax = 0.99d0 * vinfpo
      vmin = 1.11d0 * epsima
c
      do 20 , lechoi = choide, choifi
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'lechoi', lechoi
#endif
c
c====
c 3. ecriture de l'entete
c====
c
      saux80 = mege58(langue,lechoi)
      iaux = lgmess(langue,lechoi) + 1
      saux80(iaux+1:iaux+14) = mess14(langue,5,typenh)
      call utlgut ( jaux, saux80,
     >              ulsort, langue, codret )
      do 31 , iaux = 1, jaux
        sau80a(iaux:iaux) = '-'
   31 continue
      write (ulbila,11100) saux80(1:jaux), sau80a(1:jaux)
c
c====
c 4. les extremes
c====
c
c 4.1. ==> Des entites sont aplaties
c
      valmin = vinfpo
      valmax = vinfne
c
      nbqinf = 0
c
      if ( lechoi.le.1 ) then
c
        do 411 , iaux = 1 , nbeexa
cgn      write (ulsort,90114) 'quadia', iaux, quadia(iaux)
          if ( quadia(iaux).gt.vmin .and. quadia(iaux).lt.vmax ) then
            valmin = min ( valmin, quadia(iaux) )
            valmax = max ( valmax, quadia(iaux) )
          else
            nbqinf = nbqinf + 1
            enqinf(nbqinf) = iaux
          endif
  411   continue
c
      else
c
        do 412 , iaux = 1 , nbeexa
cgn      write (ulsort,90114) 'qualij', iaux, qualij(iaux)
          if ( qualij(iaux).gt.vmin .and. qualij(iaux).lt.vmax ) then
            valmin = min ( valmin, qualij(iaux) )
            valmax = max ( valmax, qualij(iaux) )
          else
            nbqinf = nbqinf + 1
            enqinf(nbqinf) = iaux
          endif
  412   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh), nbeexa
cgn      if ( lechoi.ne.1 ) then
      write (ulsort,90004) mess09(langue,lechoi)//'min', valmin
cgn      endif
      write (ulsort,90004) mess09(langue,lechoi)//'max', valmax
#endif
c
c 4.2. ==> Des entites sont aplaties
c
      if ( nbqinf.gt.0 ) then
c
      write (ulbila,texte(langue,6)) mess14(langue,3,typenh), nbqinf
      do 42 , iaux = 1 , nbqinf
        write (ulbila,texte(langue,7)) mess14(langue,1,typenh),
     >                                 enqinf(iaux)
   42 continue
c
      endif
c
c 4.3. ==> Est-ce constant ?
c
      if ( valmax.le.epsima ) then
        consta = .true.
      else
        if ( (valmax-valmin)/valmax.le.1.d-6 ) then
          consta = .true.
        else
          consta = .false.
        endif
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,99001) 'consta', consta
#endif
c
c====
c 5. arrondis des valeurs extremes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. arrondis ; codret', codret
#endif
c
      if ( .not.consta ) then
c
c 5.1. ==> Programme de calcul des arrondis
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARRO', nompro
#endif
      call utarro ( valmin, valmax, vamiar, vamaar,
     >              ulsort, langue, codret )
c
      endif
c
c 5.2. ==> Ajustement en fonction du traitement
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'Arrondi min', vamiar
      write (ulsort,90004) 'Arrondi max', vamaar
#endif
c
      if ( lechoi.eq.0 .or. lechoi.eq.2 ) then
        vamiar = max(vamiar,0.d0)
      elseif ( lechoi.eq.1 ) then
        vamiar = max(vamiar,1.d0)
      endif
c
      if ( lechoi.eq.2 ) then
        vamaar = min(vamaar,1.d0)
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'Arrondi min final', vamiar
      write (ulsort,90004) 'Arrondi max final', vamaar
#endif
c
      endif
c
      endif
c
c====
c 6. Creation des classes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Creation des classes ; codret', codret
#endif
c
      if ( .not.consta ) then
c
c 6.1 ==> Gestion de l'ordre de grandeur
c         C'est un probleme qui se pose pour le diametre en fonction des
c         unites qui ont ete utilisees.
c
      if ( codret.eq.0 ) then
c
      valdif = ( vamaar - vamiar ) * 0.99999999d0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPD10', nompro
#endif
      call utpd10 ( valdif, difman, difexp,
     >              ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'valdif', valdif
      write (ulsort,90004) '==> difman', difman
      write (ulsort,90002) '==> difexp', difexp
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( difexp.le.0 ) then
        valech = 10.d0**(1-difexp)
      elseif ( difexp.ge.4 ) then
        valech = 10.d0**(2-difexp)
      else
        valech = 1.d0
      endif
      daux = valdif*valech
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'valech', valech
      write (ulsort,90004) 'daux=valdif*valech', daux
#endif
c
      endif
c
c 6.2 ==> Les classes
c
      if ( codret.eq.0 ) then
c
      if ( daux.le.1.d0 ) then
c
        nbclas = 20
        daux1 = 0.05d0/valech
c
      elseif ( daux.le.2.d0 ) then
c
        nbclas = 40
        daux1 = 0.05d0/valech
c
      elseif ( daux.le.2.5d0 ) then
c
        nbclas = 50
        daux1 = 0.05d0/valech
c
      elseif ( daux.le.4.d0 ) then
c
        nbclas = 40
        daux1 = 0.10d0/valech
c
      elseif ( daux.le.5.d0 ) then
c
        nbclas = 50
        daux1 = 0.10d0/valech
c
      elseif ( daux.le.7.5d0 ) then
c
        nbclas = 30
        daux1 = 0.25d0/valech
c
      elseif ( daux.le.10.d0 ) then
c
        nbclas = 40
        daux1 = 0.25d0/valech
c
      elseif ( daux.le.15.d0 ) then
c
        nbclas = 30
        daux1 = 0.50d0/valech
c
      elseif ( daux.le.20.d0 ) then
c
        nbclas = 40
        daux1 = 0.50d0/valech
c
      elseif ( daux.le.50.d0 ) then
c
        nbclas = 25
        daux1 = 2.00d0/valech
c
      elseif ( daux.le.100.d0 ) then
c
        nbclas = 50
        daux1 = 2.00d0/valech
c
      else
c
        nbclas = nbclmx
        daux1 = (vamaar-vamiar) / dble(nbclas)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbclas', nbclas
      write (ulsort,90004) 'daux1', daux1
#endif
      rclass(0) = vamiar
      do 62 , iaux = 1 , nbclas
        rclass(iaux) = rclass(iaux-1) + daux1
        if ( rclass(iaux).ge.vamaar ) then
          jaux = iaux
          goto 620
        endif
   62 continue
      jaux = nbclas
  620 continue
      nbclas = jaux
c
      endif
c
#ifdef _DEBUG_HOMARD_
      do 6999 , iaux = 0 , nbclas
        write (ulsort,90114) 'rclass', iaux, rclass(iaux)
 6999 continue
#endif
c
      endif
c
c====
c 7. ecriture sur le fichier d'information
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. ecriture ; codret', codret
#endif
c 7.1. ==> ecriture de l'entete
c
      if ( codret.eq.0 ) then
c
      write (ulbila,10100)
c
      if ( lechoi.eq.0 ) then
c
        write (ulbila,11200) medi58(langue,1,1)
        write (ulbila,11200) medi58(langue,2,1)
        do 710 , iaux = 1, nxmd58(langue,typenh)
          write (ulbila,11200) medi58(langue,iaux,typenh)
  710   continue
c
      elseif ( lechoi.eq.1 ) then
c
        do 711 , iaux = 1, nxmq58(langue,typenh)
          write (ulbila,11200) mequ58(langue,iaux,typenh)
  711   continue
c
      else
c
        do 712 , iaux = 1, nxmj58(langue,typenh)
          write (ulbila,11200) meqj58(langue,iaux,typenh)
  712   continue
c
      endif
c
      if ( nbvoto.ne.0 ) then
        if ( typenh.eq.2 .or. typenh.eq.4 ) then
          write (ulbila,11200) mege58(langue,typenh+2)
          write (ulbila,11200) mege58(langue,5)
        endif
      endif
c
      endif
c
c 7.2. ==> message si constant
c
      if ( codret.eq.0 ) then
c
      if ( consta ) then
c
        write (ulbila,10200)
        write (mege58(langue,3)(32:42),'(f11.4)') valmin
        write (ulbila,11200) mege58(langue,3)
        write (ulbila,10200)
c
      endif
c
      endif
c
c====
c 8. sortie pour xmgrace et ecriture de la table
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. ecriture ; codret', codret
#endif
c
      if ( .not.consta ) then
c
c 8.1. ==> Ouverture du fichier
c
      if ( codret.eq.0 ) then
c
      if ( lechoi.eq.0 ) then
        saux09 = 'diam.'//suffix(2,typenh)(1:4)
      elseif ( lechoi.eq.1 ) then
        saux09 = 'qual.'//suffix(2,typenh)(1:4)
      else
        saux09 = 'quaj.'//suffix(2,typenh)(1:4)
      endif
      iaux = 2
      jaux = -1
      if ( rafdef.eq.31 ) then
        kaux = 1
      else
        kaux = nbiter
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTULBI', nompro
#endif
      call utulbi ( nuroul, nomflo, lnomfl,
     >                iaux, saux09, kaux, jaux,
     >              ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90003) 'nomflo', nomflo
#endif
c
      endif
c
c 8.2. ==> Ecriture
c
      if ( codret.eq.0 ) then
c
      mess08(1,2) = ' des '//mess14(langue,3,typenh)(1:3)
      mess08(1,3) = mess14(langue,3,typenh)(4:11)
      mess08(1,4) = mess14(langue,3,typenh)(12:13)//'     '
c
      mess08(2,2) = ' of '//mess14(langue,3,typenh)(1:4)
      mess08(2,3) = mess14(langue,3,typenh)(5:12)
      mess08(2,4) = mess14(langue,3,typenh)(13:14)//'      '
c
      titcou(1) = mess09(langue,lechoi)(1:8)
      titcou(2) = mess08(langue,2)
      titcou(3) = mess08(langue,3)
      titcou(4) = mess08(langue,4)
      titcou(5) = titcou(1)
c
      iaux = nuroul
      if ( lechoi.le.1 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCRHI / quadia', nompro
#endif
        call utcrhi ( nbclas, rclass, iclass, histog,
     >                nbeexa, typval, quadia, ival,
     >                titcou, xlow, ulbila, iaux,
     >                ulsort, langue, codret )
      else
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTCRHI / qualij', nompro
#endif
        call utcrhi ( nbclas, rclass, iclass, histog,
     >                nbeexa, typval, qualij, ival,
     >                titcou, xlow, ulbila, iaux,
     >                ulsort, langue, codret )
        endif
c
      endif
c
c 8.3. ==> Fermeture du fichier
c
      if ( codret.eq.0 ) then
c
      call gufeul ( nuroul , codret)
c
      endif
c
      endif
c
   20 continue
c
c====
c 9. la fin
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
