      subroutine pcs2p6 ( nbfop2, profho, vap2ho,
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
c    interpolation p2 sur les noeuds - decoupage des Pentaedres - 6
c                   -                                -            -
c    D'un milieu de face a un sommet
c remarque : pcs2p6 et pcsip6 sont des clones
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
      integer iaux, jaux
      integer iaux1(6)
      integer listns(15)
      integer sm, nuv
c
c ______________________________________________________________________
c
#include "impr03.h"
c
cgn      write(1,90002) 'listso', (listso(jaux),jaux=1,6)
cgn      write(1,90002) 'listno', (listno(jaux),jaux=1,9)
c
cgn      write(1,90002) 'Aretes', (nuaret(iaux),iaux=1,nbarco)
c
      do 10 , iaux = 1 , nbarco
c
c====
c 2. Reperage du sommet a relier
c====
c
        if ( etapen.eq.43 ) then
          jaux = 2 + 3*(iaux-1)
        elseif ( etapen.eq.44 ) then
          jaux = 3 + 3*(iaux-1)
        else
          jaux = 1 + 3*(iaux-1)
        endif
c
        listns(1) = listso(jaux)
cgn        write(1,90002) 'sommet a relier', listns(1)
c
c====
c 3. Les sommets
c    2, 3 : les 2 autres sommets de la face triangulaire du cote du
c           sommet a relier
c    4 : le sommet semblable sur la face opposee
c    5, 6 : les 2 derniers sommets
c====
c
        if ( jaux .eq.1 ) then
          iaux1(1) = 2
          iaux1(2) = 3
          iaux1(3) = 4
          iaux1(4) = 5
          iaux1(5) = 6
        elseif ( jaux .eq.2 ) then
          iaux1(1) = 3
          iaux1(2) = 1
          iaux1(3) = 5
          iaux1(4) = 4
          iaux1(5) = 6
        elseif ( jaux .eq.3 ) then
          iaux1(1) = 1
          iaux1(2) = 2
          iaux1(3) = 6
          iaux1(4) = 4
          iaux1(5) = 5
        elseif ( jaux .eq.4 ) then
          iaux1(1) = 5
          iaux1(2) = 6
          iaux1(3) = 1
          iaux1(4) = 2
          iaux1(5) = 3
        elseif ( jaux .eq.5 ) then
          iaux1(1) = 6
          iaux1(2) = 4
          iaux1(3) = 2
          iaux1(4) = 3
          iaux1(5) = 1
        elseif ( jaux .eq.6 ) then
          iaux1(1) = 4
          iaux1(2) = 5
          iaux1(3) = 3
          iaux1(4) = 1
          iaux1(5) = 2
        endif
c
        listns(2) = listso(iaux1(1))
        listns(3) = listso(iaux1(2))
        listns(4) = listso(iaux1(3))
        listns(5) = listso(iaux1(4))
        listns(6) = listso(iaux1(5))
cgn        write(1,90002) 'listns 2-6', (listns(jaux),jaux=2,6)
c
c====
c 4. Les noeuds des faces triangulaires
c    7 : le noeud milieu de l'arete coupee, du cote du sommet a relier
c    8, 9 : les deux autres noeuds, sur la face tria proche
c    10 : le noeud milieu sur l'autre face triangulaire opposee
c    11, 12 : les deux autres noeuds sur la face opposee
c====
c
        if ( jaux .eq.1 ) then
          iaux1(1) = 3
          iaux1(2) = 1
          iaux1(3) = 2
          iaux1(4) = 6
          iaux1(5) = 4
          iaux1(6) = 5
         elseif ( jaux .eq.2 ) then
          iaux1(1) = 1
          iaux1(2) = 2
          iaux1(3) = 3
          iaux1(4) = 4
          iaux1(5) = 5
          iaux1(6) = 6
        elseif ( jaux .eq.3 ) then
          iaux1(1) = 2
          iaux1(2) = 3
          iaux1(3) = 1
          iaux1(4) = 5
          iaux1(5) = 6
          iaux1(6) = 4
        elseif ( jaux .eq.4 ) then
          iaux1(1) = 6
          iaux1(2) = 4
          iaux1(3) = 5
          iaux1(4) = 3
          iaux1(5) = 1
          iaux1(6) = 2
        elseif ( jaux .eq.5 ) then
          iaux1(1) = 4
          iaux1(2) = 5
          iaux1(3) = 6
          iaux1(4) = 1
          iaux1(5) = 2
          iaux1(6) = 3
        elseif ( jaux .eq.6 ) then
          iaux1(1) = 5
          iaux1(2) = 6
          iaux1(3) = 4
          iaux1(4) = 2
          iaux1(5) = 3
          iaux1(6) = 1
        endif
c
        listns( 7) = listno(iaux1(1))
        listns( 8) = listno(iaux1(2))
        listns( 9) = listno(iaux1(3))
        listns(10) = listno(iaux1(4))
        listns(11) = listno(iaux1(5))
        listns(12) = listno(iaux1(6))
cgn      write(1,90002) 'listns 7-12', (listns(jaux),jaux=7,12)
c
c====
c 5. Les noeuds des faces quadrangulaires
c    13, 14 : les noeuds milieux, sur la face quadrangulaire coupee
c    15 : le noeud milieu de l'arete parallelle a la face coupee
c====
c
        if ( jaux .eq.1 .or. listns(1).eq.4 ) then
          iaux1(1) = 8
          iaux1(2) = 9
          iaux1(3) = 7
         elseif ( jaux .eq.2 .or. listns(1).eq.5 ) then
          iaux1(1) = 9
          iaux1(2) = 7
          iaux1(3) = 8
        elseif ( jaux .eq.3 .or. listns(1).eq.6 ) then
          iaux1(1) = 7
          iaux1(2) = 8
          iaux1(3) = 9
        endif
c
        listns(13) = listno(iaux1(1))
        listns(14) = listno(iaux1(2))
        listns(15) = listno(iaux1(3))
cgn      write(1,90002) 'listns 13-15', (listns(jaux),jaux=13,15)
c
c====
c 6. Interpolation
c====
c
        sm = np2are(nuaret(iaux))
cgn        write(1,90002) 'sm',sm
c
        profho(sm) = 1
c
        do 61 , nuv = 1, nbfop2
c
          vap2ho(nuv,sm) = trssz * ( vap2ho(nuv,listns(7))
     >                             + vap2ho(nuv,listns(13))
     >                             + vap2ho(nuv,listns(14))
     >                             - vap2ho(nuv,listns(1))
     >                             - vap2ho(nuv,listns(2))
     >                             - vap2ho(nuv,listns(3))
     >                             - vap2ho(nuv,listns(4)) )
     >                   + unshu * ( vap2ho(nuv,listns(11))
     >                             + vap2ho(nuv,listns(12))
     >                             - vap2ho(nuv,listns(5))
     >                             - vap2ho(nuv,listns(6)) )
     >                   + trshu * ( vap2ho(nuv,listns(8))
     >                             + vap2ho(nuv,listns(9))
     >                             + vap2ho(nuv,listns(15)) )
     >                   + unssz * vap2ho(nuv,listns(10))
cgn          write(1,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
   61   continue
c
   10 continue
c
      end
