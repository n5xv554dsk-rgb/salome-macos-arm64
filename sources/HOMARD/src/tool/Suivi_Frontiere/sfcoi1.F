      subroutine sfcoi1 ( nbfran, casfre,
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
c   Suivi de Frontiere : COnversions Initiales - phase 1
c   --                   --          -                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfran . e   .   1    . nombre de frontieres analytiques           .
c . casfre . es  .13nbfran. caracteristiques des frontieres analytiques.
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
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              8 :     rayon                 .
c .        .     .        .              9,10,11:xcent2, ycent2, zcent2.
c .        .     .        .              12 :    rayon2                .
c .        .     .        .              13 :    angle en degre/radian .
c .        .     .        . . tore     : 2,3,4 : xcentr, ycentr, zcentr.
c .        .     .        .              5,6,7 : xaxe, yaxe, zaxe      .
c .        .     .        .              8 :     rayon de revolution   .
c .        .     .        .              12 :    rayon primaire        .
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
      parameter ( nompro = 'SFCOI1' )
c
#include "nblang.h"
#include "consta.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "precis.h"
c
c 0.3. ==> arguments
c
      integer nbfran
c
      double precision casfre(13,nbfran)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer tyfran
c
      double precision epsid2
      double precision daux
      double precision xa, ya, za, ra
      double precision xb, yb, zb, rb
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
      character*24 messag(nblang,4)
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
      texte(1,4) = '(''Nombre de frontiere(s) analytique(s) :'',i8)'
      texte(1,5) = '(''Type de la frontiere : '',a)'
      texte(1,6) = '(''La definition de l''''axe est invalide.'')'
c
      texte(2,4) = '(''Number of analytical boundarie(s):'',i8)'
      texte(2,5) = '(''Type of boundary: '',a)'
      texte(2,6) = '(''The definition of the axis is not valid.'')'
c
#include "impr03.h"
c                    123456789012345678901234
      messag(1,1) = 'Cylindre                '
      messag(1,2) = 'Sphere                  '
      messag(1,3) = 'Cone (origine-axe-angle)'
      messag(1,4) = 'Cone (2 centres+rayons) '
c
      messag(2,1) = 'Cylindre                '
      messag(2,2) = 'Sphere                  '
      messag(2,3) = 'Cone (o-axis-angle)     '
      messag(2,4) = 'Cone (2 centres+radius) '
c
      codret = 0
c
      epsid2 = max(1.d-14,epsima)
c
c====
c 2. boucle sur les frontieres enregistrees
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbfran
#endif
c
      do 20 , iaux = 1 , nbfran
c
        if ( codret.eq.0 ) then
c
        tyfran = nint(casfre(1,iaux))
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) messag(langue,tyfran)
#endif
c
c 2.1. ==> Creation de l'origine, de l'axe et de l'angle pour un cone
c          defini par deux rayons.
c
        if ( tyfran.eq.4 ) then
c
c
c         o
c         !    .
c         !        .
c       RA!            .
c         !                o
c         !              RB!   .
c         !                !       .
c         A----------------B----------O
c
c   Thales : RA/RB = AO/BO  ==> BO = AB*RB/(RA-RB)
c   Angle  : tg(alpha) = RA/AO
c
c 2.1.1. ==> Positionnement de A vers B, avec RA>RB
c
          if ( casfre(8,iaux) .gt. casfre(12,iaux) ) then
            xa = casfre( 2,iaux)
            ya = casfre( 3,iaux)
            za = casfre( 4,iaux)
            ra = casfre( 8,iaux)
            xb = casfre( 9,iaux)
            yb = casfre(10,iaux)
            zb = casfre(11,iaux)
            rb = casfre(12,iaux)
          else
            xa = casfre( 9,iaux)
            ya = casfre(10,iaux)
            za = casfre(11,iaux)
            ra = casfre(12,iaux)
            xb = casfre( 2,iaux)
            yb = casfre( 3,iaux)
            zb = casfre( 4,iaux)
            rb = casfre( 8,iaux)
          endif
cgn          write (ulsort,90004) 'A', xa, ya, za
cgn          write (ulsort,90004) 'B', xb, yb, zb
c
c 2.1.2. ==> Axe : relie les deux centres, de A vers B
c            L'axe est normalise
c
          casfre(5,iaux) = xb - xa
          casfre(6,iaux) = yb - ya
          casfre(7,iaux) = zb - za
          daux = sqrt(casfre(5,iaux)**2
     >              + casfre(6,iaux)**2
     >              + casfre(7,iaux)**2)
          casfre(5,iaux) = casfre(5,iaux)/daux
          casfre(6,iaux) = casfre(6,iaux)/daux
          casfre(7,iaux) = casfre(7,iaux)/daux
c
c 2.1.3. ==> Origine : mise dans le centre
c
cgn          write (ulsort,90004) 'AB', daux
          daux = daux * rb / (ra-rb)
cgn          write (ulsort,90004) 'AB* rb / (ra-rb)', daux
          casfre(2,iaux) = xb + daux*casfre(5,iaux)
          casfre(3,iaux) = yb + daux*casfre(6,iaux)
          casfre(4,iaux) = zb + daux*casfre(7,iaux)
c
c 2.1.4. ==> Angle en radian
c
cgn          write (ulsort,90004) 'AO',sqrt((casfre(2,iaux)-xa)**2
cgn     >                   + (casfre(3,iaux)-ya)**2
cgn     >                   + (casfre(4,iaux)-za)**2 )
          daux = ra / sqrt((casfre(2,iaux)-xa)**2
     >                   + (casfre(3,iaux)-ya)**2
     >                   + (casfre(4,iaux)-za)**2 )
          casfre(13,iaux) = atan(daux)
#ifdef _DEBUG_HOMARD_
          write (ulsort,90004) 'X centre', casfre( 2,iaux)
          write (ulsort,90004) 'Y centre', casfre( 3,iaux)
          write (ulsort,90004) 'Z centre', casfre( 4,iaux)
          write (ulsort,90004) 'X axe   ', casfre(5,iaux)
          write (ulsort,90004) 'Y axe   ', casfre(6,iaux)
          write (ulsort,90004) 'Z axe   ', casfre(7,iaux)
          write (ulsort,90004) 'Angle   ', casfre(13,iaux)*180.d0/pi
#endif
c
        endif
c
c 2.2. ==> Normalisation de l'axe
c
        if ( tyfran.eq.1 .or. tyfran.eq.3 ) then
c
          daux = casfre(5,iaux)**2
     >         + casfre(6,iaux)**2
     >         + casfre(7,iaux)**2
          if ( daux.le.epsid2 ) then
            write (ulsort,texte(langue,6))
            codret = 22
          else
            daux = 1.d0/sqrt(daux)
            casfre(5,iaux) = casfre(5,iaux)*daux
            casfre(6,iaux) = casfre(6,iaux)*daux
            casfre(7,iaux) = casfre(7,iaux)*daux
          endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,90004) 'X axe   ', casfre(5,iaux)
          write (ulsort,90004) 'Y axe   ', casfre(6,iaux)
          write (ulsort,90004) 'Z axe   ', casfre(7,iaux)
#endif
c
        endif
c
c 2.3. ==> Angle en degre/radian
c
        if ( tyfran.eq.3 ) then
c
          casfre(13,iaux) = casfre(13,iaux)*pi/180.d0
#ifdef _DEBUG_HOMARD_
          write (ulsort,90004) 'Angle   ', casfre(13,iaux)*180.d0/pi
#endif
c
        endif
c
        endif
c
   20 continue
c
c====
c 3. La fin
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
