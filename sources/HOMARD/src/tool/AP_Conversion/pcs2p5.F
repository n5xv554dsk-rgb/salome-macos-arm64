      subroutine pcs2p5 ( nbfop2, profho, vap2ho,
     >                    np2are,
     >                    etapen,
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
c    interpolation p2 sur les noeuds - decoupage des Pentaedres - 5
c                   -                                -            -
c    D'un milieu d'arete a un sommet
c remarque : pcs2p5 et pcsip5 sont des clones
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
c . etapen . e   .    1   . etat du pentaedre a traiter                .
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
      integer etapen
      integer listso(6), listno(9)
      integer nbarco, nuaret(nbarco)
c
      double precision vap2ho(nbfop2,*)
c
c 0.4. ==> variables locales
c
cgn      integer iaux
      integer iaux1(6)
      integer listns(15)
      integer sm, nuv
c
c ______________________________________________________________________
c
#include "impr03.h"
c
cgn      write(1,90002) 'listso', (listso(iaux),iaux=1,6)
cgn      write(1,90002) 'listno', (listno(iaux),iaux=1,9)
c
cgn      write(1,90002) 'Aretes', (nuaret(iaux),iaux=1,nbarco)
c
c====
c 2. Les 2 sommets de l'arete coupee
c 2. Les 4 autres sommets
c====
c
      if ( etapen.eq.1 ) then
        iaux1(1) = 3
        iaux1(2) = 1
        iaux1(3) = 2
        iaux1(4) = 4
        iaux1(5) = 5
        iaux1(6) = 6
      elseif ( etapen.eq.2 ) then
        iaux1(1) = 1
        iaux1(2) = 2
        iaux1(3) = 3
        iaux1(4) = 4
        iaux1(5) = 5
        iaux1(6) = 6
      elseif ( etapen.eq.3 ) then
        iaux1(1) = 2
        iaux1(2) = 3
        iaux1(3) = 1
        iaux1(4) = 4
        iaux1(5) = 5
        iaux1(6) = 6
      elseif ( etapen.eq.4 ) then
        iaux1(1) = 6
        iaux1(2) = 4
        iaux1(3) = 5
        iaux1(4) = 1
        iaux1(5) = 2
        iaux1(6) = 3
      elseif ( etapen.eq.5 ) then
        iaux1(1) = 4
        iaux1(2) = 5
        iaux1(3) = 6
        iaux1(4) = 1
        iaux1(5) = 2
        iaux1(6) = 3
      else
        iaux1(1) = 5
        iaux1(2) = 6
        iaux1(3) = 4
        iaux1(4) = 1
        iaux1(5) = 2
        iaux1(6) = 3
      endif
c
      listns(1) = listso(iaux1(1))
      listns(2) = listso(iaux1(2))
      listns(3) = listso(iaux1(3))
      listns(4) = listso(iaux1(4))
      listns(5) = listso(iaux1(5))
      listns(6) = listso(iaux1(6))
cgn      write(1,90002) 'listns 1-6', (listns(iaux),iaux=1,6)
c
c====
c 3. Les noeuds
c    7 : le noeud milieu de l'arete coupee
c    8, 9 : les 2 autres noeuds sur la face triangulaire coupee
c    10 : le noeud translate sur l'autre face triangulaire
c    11, 12 : les 2 autres noeuds sur l'autre face triangulaire
c====
c
      iaux1(1) = etapen
      if ( etapen.eq.1 ) then
        iaux1(2) = 2
        iaux1(3) = 3
        iaux1(4) = 4
        iaux1(5) = 5
        iaux1(6) = 6
      elseif ( etapen.eq.2 ) then
        iaux1(2) = 3
        iaux1(3) = 1
        iaux1(4) = 5
        iaux1(5) = 6
        iaux1(6) = 4
      elseif ( etapen.eq.3 ) then
        iaux1(2) = 1
        iaux1(3) = 2
        iaux1(4) = 6
        iaux1(5) = 4
        iaux1(6) = 5
      elseif ( etapen.eq.4 ) then
        iaux1(2) = 5
        iaux1(3) = 6
        iaux1(4) = 1
        iaux1(5) = 2
        iaux1(6) = 3
      elseif ( etapen.eq.5 ) then
        iaux1(2) = 6
        iaux1(3) = 4
        iaux1(4) = 2
        iaux1(5) = 3
        iaux1(6) = 1
      else
        iaux1(2) = 4
        iaux1(3) = 5
        iaux1(4) = 3
        iaux1(5) = 2
        iaux1(6) = 1
      endif
c
      listns( 7) = listno(iaux1(1))
      listns( 8) = listno(iaux1(2))
      listns( 9) = listno(iaux1(3))
      listns(10) = listso(iaux1(4))
      listns(11) = listso(iaux1(5))
      listns(12) = listso(iaux1(6))
cgn      write(1,90002) 'listns 7-12', (listns(iaux),iaux=7,12)
c
c====
c 4. Les noeuds
c    13 : le noeud milieu de l'arete quadrangulaire opposee
c    14, 15 : les 2 autres noeuds sur la face quadrangulaire coupee
c====
c
      if ( etapen.eq.1 .or. etapen.eq.4 ) then
        iaux1(1) = 8
        iaux1(2) = 9
        iaux1(3) = 7
      elseif ( etapen.eq.2 .or. etapen.eq.5 ) then
        iaux1(1) = 9
        iaux1(2) = 8
        iaux1(3) = 7
      else
        iaux1(1) = 7
        iaux1(2) = 8
        iaux1(3) = 9
      endif
c
      listns(13) = listno(iaux1(1))
      listns(14) = listno(iaux1(2))
      listns(15) = listno(iaux1(3))
cgn      write(1,90002) 'listns 13-15', (listns(iaux),iaux=13,15)
c
c====
c 5. Interpolation
c====
c
      sm = np2are(nuaret(1))
cgn        write(1,90002) 'sm',sm
c
      profho(sm) = 1
c
      do 51 , nuv = 1, nbfop2
c
cgn        write(1,*) 'vap2ho=',(vap2ho(nuv,listns(iaux)),iaux=1,15)
        vap2ho(nuv,sm) = unshu * ( vap2ho(nuv,listns(8))
     >                           + vap2ho(nuv,listns(9))
     >                           - vap2ho(nuv,listns(1))
     >                           - vap2ho(nuv,listns(2)) )
     >                 + trssz * ( vap2ho(nuv,listns(10))
     >                           + vap2ho(nuv,listns(14))
     >                           + vap2ho(nuv,listns(15))
     >                           - vap2ho(nuv,listns(3))
     >                           - vap2ho(nuv,listns(4))
     >                           - vap2ho(nuv,listns(5))
     >                           - vap2ho(nuv,listns(6)) )
     >                 + unssz * vap2ho(nuv,listns(7))
     >                 + trshu * ( vap2ho(nuv,listns(11))
     >                           + vap2ho(nuv,listns(12))
     >                           + vap2ho(nuv,listns(13)) )
cgn        write(1,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
   51 continue
c
      end
