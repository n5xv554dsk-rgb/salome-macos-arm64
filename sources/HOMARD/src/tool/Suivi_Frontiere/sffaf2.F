      subroutine sffaf2 ( nbfrgr, nbfran,
     >                    casfre,
     >                    cacfpo, cacfta, cacfnm,
     >                    calfpo, calfta, calfnm,
     >                    calgpo, calgta, calgnm,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
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
c   Suivi de Frontiere - Frontieres AFfichage - 2
c   -        -           -          --          -
c remarque : sffaf1, sffaf2 et sffaf3 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfrgr . e   .   1    . nombre de liens frontiere/groupe           .
c . nbfran . e   .   1    . nombre de frontieres analytiques           .
c . casfre . e   .13nbfran. caracteristiques des frontieres analytiques.
c .        .     .        . 1 : 1., si cylindre                        .
c .        .     .        .     2., si sphere                          .
c .        .     .        .     3., si cone par  origine, axe et angle .
c .        .     .        .     4., si cone par 2 centres et 2 rayons  .
c .        .     .        .     5., si tore                            .
c .        .     .        . de 2 a 13 :                                .
c .        .     .        . . cylindre : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              8 :     rayon                 .
c .        .     .        . . sphere   : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              8 :     rayon                 .
c .        .     .        . . cone     : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              13 :    angle en degre        .
c .        .     .        . . cone 2   : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              8 :     rayon                 .
c .        .     .        .              9,10,11:xcent2, ycent2, zcent2.
c .        .     .        .              12 :    rayon2                .
c .        .     .        . . tore     : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              8 :     rayon de revolution   .
c .        .     .        .              12 :    rayon primaire        .
c . cacfpo . e   .0:nbfran. pointeurs sur le tableau du nom frontieres .
c . cacfta . e   .10nbfran. taille du nom des frontieres               .
c . cacfnm . e   .10nbfran. nom des frontieres                         .
c . calfpo . e   .0:nbfrgr. pointeurs sur le tableau du nom frontieres .
c . calfta . e   .10nbfrgr. taille du nom des frontieres               .
c . calfnm . e   .10nbfrgr. nom des frontieres                         .
c . calgpo . e   .0:nbfrgr. pointeurs sur le tableau du nom groupes    .
c . calgta . e   .10nbfrgr. taille du nom des groupes                  .
c . calgnm . e   .10nbfrgr. nom des groupes                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'SFFAF2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbfrgr, nbfran
      integer cacfpo(0:nbfran), cacfta(10*nbfran)
      integer calfpo(0:nbfrgr), calfta(10*nbfrgr)
      integer calgpo(0:nbfrgr), calgta(10*nbfrgr)
c
      double precision casfre(13,nbfran)
c
      character*8 cacfnm(10*nbfran)
      character*8 calfnm(10*nbfrgr)
      character*8 calgnm(10*nbfrgr)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nufrgr, nufran, tyfran
      integer lgnom, lgnomf
c
      character*8 nomsur(0:5)
      character*80 nom, nomf
c
      integer nbmess
      parameter ( nbmess = 12 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
      codret = 0
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     >'(''*'',30x,''Liens groupe/frontiere'',30x,''*'')'
      texte(1,5) =
     >'(''*'',30x,''Frontieres analytiques'',30x,''*'')'
      texte(1,6) = '(''* Rayon  : '',g14.7,58x,''*'')'
      texte(1,7) = '(''* Angle  : '',g14.7,58x,''*'')'
c
      texte(2,4) =
     >'(''*'',31x,''Links boundary/group'',31x,''*'')'
      texte(2,5) =
     >'(''*'',31x,''Analytical boundaries'',30x,''*'')'
      texte(2,6) = '(''* Radius:  '',g14.7,58x,''*'')'
      texte(2,7) = '(''* Angle:  '',g14.7,58x,''*'')'
c
#include "impr03.h"
c
 1000 format('* ',a80,' *')
 1100 format(84('*'))
 1101 format(//,84('*'))
 1201 format('* Type : ',a8,66x,'*')
 1202 format('* ',a6,' :  X =',g14.7,' Y =',g14.7,' Z =',g14.7,18x,'*')
c
c====
c 2. Descriptions des frontieres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Descriptions frontieres ; codret', codret
#endif
c
      if ( langue.eq.1 ) then
        nomsur(0) = 'Inconnu '
        nomsur(1) = 'Cylindre'
        nomsur(2) = 'Sphere  '
        nomsur(3) = 'Cone    '
        nomsur(4) = 'Cone    '
        nomsur(5) = 'Tore    '
      else
        nomsur(0) = 'Unknwown'
        nomsur(1) = 'Cylinder'
        nomsur(2) = 'Sphere  '
        nomsur(3) = 'Cone    '
        nomsur(4) = 'Cone    '
        nomsur(5) = 'Torus   '
      endif
c
      write (ulsort,1101)
      write (ulsort,texte(langue,5))
      write (ulsort,1100)
c
      do 21 , nufran = 1 , nbfran
c
c 2.1. ==> Nom de la frontiere
c
        if ( codret.eq.0 ) then
c
        jaux = cacfpo(nufran-1) + 1
c
        lgnom = 0
        do 211 , iaux = jaux , cacfpo(nufran)
          lgnom = lgnom + cacfta(iaux)
  211   continue
c
        endif
c
        if ( codret.eq.0 ) then
c
        call uts8ch ( cacfnm(jaux), lgnom, nom,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
          write (ulsort,1000) nom
        endif
c
c 2.2. ==> Type de la frontiere
c
        tyfran = nint(casfre(1,nufran))
        if ( tyfran.le.-1 .or. tyfran.ge.6 ) then
          tyfran = 0
        endif
        write (ulsort,1201) nomsur(tyfran)
c
        if ( tyfran.gt.0 ) then
          write (ulsort,1202) 'Centre',
     >                        (casfre(iaux,nufran), iaux = 2 , 4 )
          if ( tyfran.eq.1 .or. tyfran.eq.3 .or. tyfran.eq.5 ) then
            write (ulsort,1202) 'Axe   ',
     >                          (casfre(iaux,nufran), iaux = 5 , 7 )
          endif
          if ( tyfran.le.2 ) then
            write (ulsort,texte(langue,6)) casfre(8,nufran)
          elseif ( tyfran.eq.3 ) then
            write (ulsort,texte(langue,7)) casfre(13,nufran)
          elseif ( tyfran.eq.5 ) then
            write (ulsort,texte(langue,6)) casfre(8,nufran)
            write (ulsort,texte(langue,6)) casfre(12,nufran)
          else
            write (ulsort,texte(langue,6)) casfre(8,nufran)
            write (ulsort,1202) 'Centre',
     >                          (casfre(iaux,nufran), iaux = 9 , 11 )
            write (ulsort,texte(langue,6)) casfre(12,nufran)
          endif
        endif
c
        write (ulsort,1100)
c
   21 continue
c
c====
c 3. affichage des liens frontieres/groupe
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. affichage liens ; codret', codret
#endif
c
      write (ulsort,1100)
      write (ulsort,texte(langue,4))
      write (ulsort,1100)
c
      do 31 , nufrgr = 1 , nbfrgr
c
c 3.1. ==> Nom du groupe
c
        if ( codret.eq.0 ) then
c
        jaux = calgpo(nufrgr-1) + 1
c
        lgnom = 0
        do 311 , iaux = jaux , calgpo(nufrgr)
          lgnom = lgnom + calgta(iaux)
  311   continue
c
        call uts8ch ( calgnm(jaux), lgnom, nom,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
          write (ulsort,1000) nom
        endif
c
c 3.2. ==> Nom de la frontiere
c
        if ( codret.eq.0 ) then
c
        jaux = calfpo(nufrgr-1) + 1
c
        lgnomf = 0
        do 321 , iaux = jaux , calfpo(nufrgr)
          lgnomf = lgnomf + calfta(iaux)
  321   continue
c
        call uts8ch ( calfnm(jaux), lgnomf, nomf,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
          write (ulsort,1000) nomf
        endif
c
        write (ulsort,1100)
c
   31 continue
c
c====
c 4. La fin
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
