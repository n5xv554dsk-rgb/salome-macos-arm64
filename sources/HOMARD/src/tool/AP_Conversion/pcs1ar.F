      subroutine pcs1ar ( nbfop1, profho,
     >                    hetare, somare, filare,
     >                    vap1ho )
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
c    interpolation p1 sur les noeuds lors du decoupage des ARetes
c                   -                                      --
c remarque : pcs1ar et pcsmar sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop1 . e   .    1   . nombre de fonctions P1                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . vap1ho . es  . nbfop1*. variables p1 numerotation homard           .
c .        .     . nbnoto .                                            .
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
c
c 0.2. ==> communs
c
#include "nombar.h"
#include "nombno.h"
c
c 0.3. ==> arguments
c
      integer nbfop1
      integer profho(nbnoto)
      integer hetare(nbarto), somare(2,nbarto), filare(nbarto)
c
      double precision vap1ho(nbfop1,*)
c
c 0.4. ==> variables locales
c
      integer larete, nuv, s1, s2, sm
c
cgn      double precision TTT(2)
cgn      integer lglist
cgn      parameter ( lglist = 15)
cgn      integer listno(lglist)
c ______________________________________________________________________
c
c====
c 1. interpolation p1 pour les aretes qui viennent d'etre decoupees
c====
c
cgn      listno( 1) = 16358
cgn      listno( 2) = 14604
cgn      listno( 3) = 16395
cgn      listno( 4) = 17054
cgn      listno( 5) = 16394
cgn      listno( 6) = 17072
cgn      listno( 7) = 22390
cgn      listno( 8) = 22395
cgn      listno( 9) = 22414
cgn      listno(10) = 22393
cgn      listno(11) = 22418
cgn      listno(12) = 22415
cgn      listno(13) = 22417
cgn      listno(14) = 25003
cgn      listno(15) = 25006
cgn      ttt(1) = 1.d4
cgn      ttt(2) = -1.d4
cgn          print *,'Avant passage dans PCS1AR'
cgn      do 888 , nuv=1,6
cgn        s1 = listno(nuv)
cgn        print 1786,s1,vap1ho(nbfop1,s1)
cgn        ttt(1)=min(ttt(1),vap1ho(nbfop1,s1))
cgn        ttt(2)=max(ttt(2),vap1ho(nbfop1,s1))
cgn 888  continue
cgn      print *,'minimum sur les 6 noeuds ',ttt(1)
cgn      print *,'maximum sur les 6 noeuds ',ttt(2)
cgn          write(*,*) 'nbfop1 =', nbfop1
c
      if ( nbfop1.ne.0 ) then
c
      do 1000, larete = 1, nbarto
c
cgn      if ( larete.eq.34918 .or. larete.eq.32464 ) then
cgn      print 1789,larete,hetare(larete)
cgn      print 1788,somare(1,larete),somare(2,larete)
cgn      endif
cgn 1789 format('Arete ',i6,' ==> etat = ',i3)
cgn 1788 format('Sommet 1 : ',i6,' ; Sommet 2 : ',i6)
cgn 1787 format('Sommet milieu : ',i6)
cgn 1786 format('Valeur sur le sommet ',i6,' : ',g14.5)
c
        if ( hetare(larete).eq.2 ) then
c
c         recuperation des sommets de l'arete
c
          s1 = somare(1,larete)
          s2 = somare(2,larete)
cgn          write(*,1784) s1, profho(s1)
cgn          write(*,1784) s2, profho(s2)
cgn 1784 format('Noeud',i3,' :',i2)
c
          if ( profho(s1).eq.1 .and. profho(s2).eq.1 ) then
c
c           recuperation du nouveau noeud sommet
c
            sm = somare(2,filare(larete))
            profho(sm) = 1
cgn          write(*,1784) sm, profho(sm)
cgn      if ( larete.eq.34918 .or. larete.eq.32464 ) then
cgn      print 1787,sm
cgn      print 1786,s1,vap1ho(nbfop1,s1)
cgn      print 1786,s2,vap1ho(nbfop1,s2)
cgn      endif
c
c           interpolation : interpolee (ui,i=1,2) = 1/2 (u1+u2)
c
            do 11, nuv = 1, nbfop1
c
              vap1ho(nuv,sm) = unsde
     >                       * ( vap1ho(nuv,s1) + vap1ho(nuv,s2) )
c
   11       continue
c
          endif
c
        endif
c
 1000 continue
cgn      print 1786,22414,vap1ho(nbfop1,22414)
cgn      print 1786,22390,vap1ho(nbfop1,22390)
cgn      ttt(1) = 1.d4
cgn      ttt(2) = -1.d4
cgn          print *,'Apres passage dans PCS1AR'
cgn      do 889 , nuv=1,13
cgn        s1 = listno(nuv)
cgn        print 1786,s1,vap1ho(nbfop1,s1)
cgn        ttt(1)=min(ttt(1),vap1ho(nbfop1,s1))
cgn        ttt(2)=max(ttt(2),vap1ho(nbfop1,s1))
cgn 889  continue
cgn      print *,'minimum sur les 13 noeuds ',ttt(1)
cgn      print *,'maximum sur les 13 noeuds ',ttt(2)
c
      endif
c
      end
