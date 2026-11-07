      subroutine pcs2p1 ( nbfop2, profho, vap2ho,
     >                    np2are,
     >                    listso, listno,
     >                    nbarco, nuaret )
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c    interpolation p2 sur les noeuds - decoupage des Pentaedres - 1
c                   -                                -            -
c    Les milieux des aretes joignant les centres des quadrangles
c   (decoupage en 8)
c remarque : pcs2p1 et pcsip1 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop2 . e   .    1   . nombre de fonctions P2                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vap2ho . es  . nbfop2*. variables p2 numerotation homard           .
c .        .     . nbnoto .                                            .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . listso . e   .    6   . Liste des sommets ordonnes du pentaedre    .
c . listno . e   .    9   . Liste des noeuds ordonnees du pentaedre    .
c . nbarco . e   .   1    . nombre d'aretes concernees                 .
c . nuaret . e   . nbarco . numero des aretes a traiter                .
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
#include "fracta.h"
#include "fractc.h"
#include "fractf.h"
#include "fractg.h"
c
c 0.2. ==> communs
c
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(*)
      integer np2are(nbarto)
      integer listso(6), listno(9)
      integer nbarco, nuaret(nbarco)
c
      double precision vap2ho(nbfop2,*)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer listns(15)
      integer sm, nuv
      integer iaux1, iaux2, iaux3, iaux4
c ______________________________________________________________________
c
#include "impr03.h"
c
c====
c
      do 10 , iaux = 1 , nbarco
c
c====
c 2. Les sommets de l'arete du quadrangle
c====
c
      if ( iaux.eq.1 ) then
        iaux1 = 1
        iaux2 = 4
      elseif ( iaux.eq.2 ) then
        iaux1 = 2
        iaux2 = 5
      else
        iaux1 = 3
        iaux2 = 6
      endif
c
      listns(1) = listso(iaux1)
      listns(2) = listso(iaux2)
c
c====
c 3. Les sommets de la face opposee
c====
c
      if ( iaux.eq.1 ) then
        iaux1 = 2
        iaux2 = 3
        iaux3 = 5
        iaux4 = 6
      elseif ( iaux.eq.2 ) then
        iaux1 = 3
        iaux2 = 1
        iaux3 = 6
        iaux4 = 4
      else
        iaux1 = 1
        iaux2 = 2
        iaux3 = 4
        iaux4 = 5
      endif
c
      listns(3) = listso(iaux1)
      listns(4) = listso(iaux2)
      listns(5) = listso(iaux3)
      listns(6) = listso(iaux4)
c
c====
c 4. Les noeuds du plan du point
c====
c
      if ( iaux.eq.1 ) then
        iaux1 = 1
        iaux2 = 2
        iaux3 = 4
        iaux4 = 5
      elseif ( iaux.eq.2 ) then
        iaux1 = 2
        iaux2 = 3
        iaux3 = 5
        iaux4 = 6
      else
        iaux1 = 3
        iaux2 = 1
        iaux3 = 6
        iaux4 = 4
      endif
c
      listns( 7) = listno(iaux1)
      listns( 8) = listno(iaux2)
      listns( 9) = listno(iaux3)
      listns(10) = listno(iaux4)
c
c====
c 5. Les noeuds de l'arete en face
c====
c
      if ( iaux.eq.1 ) then
        iaux1 = 8
        iaux2 = 9
      elseif ( iaux.eq.2 ) then
        iaux1 = 9
        iaux2 = 7
      else
        iaux1 = 7
        iaux2 = 8
      endif
c
      listns(11) = listno(iaux1)
      listns(12) = listno(iaux2)
c
c====
c 6. Le noeud le plus proche
c====
c
      listns(13) = listno(6+iaux)
c
c====
c 7. Les noeuds les plus eloignes
c====
c
      if ( iaux.eq.1 ) then
        iaux1 = 3
        iaux2 = 6
      elseif ( iaux.eq.2 ) then
        iaux1 = 1
        iaux2 = 4
      else
        iaux1 = 2
        iaux2 = 5
      endif
c
      listns(14) = listno(iaux1)
      listns(15) = listno(iaux2)
c
c====
c 8. Interpolation
c====
c
cgn      write(1,90002) 'arete', nuaret(iaux)
      sm = np2are(nuaret(iaux))
cgn      write(1,90002) 'sm', sm
      profho(sm) = 1
c
      do 81 , nuv = 1, nbfop2
c
        vap2ho(nuv,sm) = - unsqu * ( vap2ho(nuv,listns(1))
     >                             + vap2ho(nuv,listns(2)) )
     >                   - trssz * ( vap2ho(nuv,listns(3))
     >                             + vap2ho(nuv,listns(4))
     >                             + vap2ho(nuv,listns(5))
     >                             + vap2ho(nuv,listns(6)) )
     >                   + unsqu * ( vap2ho(nuv,listns(7))
     >                             + vap2ho(nuv,listns(8))
     >                             + vap2ho(nuv,listns(9))
     >                             + vap2ho(nuv,listns(10))
     >                             + vap2ho(nuv,listns(11))
     >                             + vap2ho(nuv,listns(12)) )
     >                   + unsde * vap2ho(nuv,listns(13))
     >                   + unshu * ( vap2ho(nuv,listns(14))
     >                             + vap2ho(nuv,listns(15)) )
cgn        write(1,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
   81 continue
c
   10 continue
c
      end
