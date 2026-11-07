      subroutine pcs1qu ( nbfop1, profho,
     >                    somare,
     >                    hetqua, arequa, filqua,
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
c    interpolation p1 sur les noeuds lors du decoupage des QUadrangles
c                   -                                      --
c remarque : on devrait optimiser cela car si le quadrangle etait dans
c            un etat de decoupage avec presence de noeud central, on
c            recalcule une valeur qui est deja presente
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop1 . e   .    1   . nombre de fonctions P1                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
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
#include "fractc.h"
c
c 0.2. ==> communs
c
#include "nombar.h"
#include "nombno.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer nbfop1
      integer profho(nbnoto)
      integer somare(2,nbarto)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
c
      double precision vap1ho(nbfop1,*)
c
c 0.4. ==> variables locales
c
      integer lequad
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
      integer sm, nuv
      integer iaux
c
cgn      double precision TTT(2)
cgn      integer lglist
cgn      parameter ( lglist = 15)
cgn      integer listno(lglist)
c ______________________________________________________________________
c
c====
c 1. interpolation p1 pour les quadrangles qui viennent d'etre decoupes
c    on a une valeur a mettre sur le noeud central. Ce noeud est
c    au barycentre des 4 sommets du quadrangle pere. Donc on prend la
c    moyenne de la fonction sur ces 4 noeuds.
c====
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
cgn          print *,'Avant passage dans PCS1QU'
cgn      do 888 , nuv=1,13
cgn        sm = listno(nuv)
cgn        print 1786,sm,vap1ho(nbfop1,sm)
cgn        ttt(1)=min(ttt(1),vap1ho(nbfop1,sm))
cgn        ttt(2)=max(ttt(2),vap1ho(nbfop1,sm))
cgn 888  continue
cgn      print *,'minimum sur les 13 noeuds ',ttt(1)
cgn      print *,'maximum sur les 13 noeuds ',ttt(2)
c
      if ( nbfop1.ne.0 ) then
c
      do 10 , lequad = 1, nbquto
c
cgn      if ( lequad.eq.17127 .or. lequad.eq.17198 ) then
cgn      print 1789,lequad,hetqua(lequad)
cgn      print 1788,arequa(lequad,1),arequa(lequad,2),
cgn     >arequa(lequad,3),arequa(lequad,4)
cgn      endif
cgn 1789 format('Quadrangle ',i6,' ==> etat = ',i3)
cgn 1788 format('Arete 1 : ',i6,' ; Arete 2 : ',i6,
cgn     > ,' ; Arete 3 : ',i6,' ; Arete 4 : ',i6)
cgn 1787 format('Sommet milieu : ',i6)
cgn 1786 format('Valeur sur le sommet ',i6,' : ',g14.5)
c
        iaux = mod(hetqua(lequad),100)
        if ( iaux.eq.4 .or. ( iaux.ge.41 .and. iaux.le.44 ) ) then
c
c         les aretes et les sommets du quadrangle
c
          a1 = arequa(lequad,1)
          a2 = arequa(lequad,2)
          a3 = arequa(lequad,3)
          a4 = arequa(lequad,4)
c
          call utsoqu ( somare, a1, a2, a3, a4,
     >                  sa1a2, sa2a3, sa3a4, sa4a1 )
c
c         tous les noeuds doivent etre dans le profil
c
          if ( profho(sa1a2).eq.1 .and. profho(sa2a3).eq.1 .and.
     >         profho(sa3a4).eq.1 .and. profho(sa4a1).eq.1 ) then
c
c           recherche du noeud central
c
            iaux = lequad
            call utnmqu ( iaux, sm,
     >                    somare, arequa, filqua )
c
c           le noeud central est a ajouter dans le profil
c
            profho(sm) = 1
c
cgn      if ( lequad.eq.17127 .or. lequad.eq.17198 ) then
cgn      print 1787,sm
cgn      print 1786,sa1a2,vap1ho(nbfop1,sa1a2)
cgn      print 1786,sa2a3,vap1ho(nbfop1,sa2a3)
cgn      print 1786,sa3a4,vap1ho(nbfop1,sa3a4)
cgn      print 1786,sa4a1,vap1ho(nbfop1,sa4a1)
cgn      endif
c
c           interpolation = 1/4 (u1+u2+u3+u4)
c
            do 101 , nuv = 1, nbfop1
c
              vap1ho(nuv,sm) = unsqu * ( vap1ho(nuv,sa1a2)
     >                                 + vap1ho(nuv,sa2a3)
     >                                +  vap1ho(nuv,sa3a4)
     >                                +  vap1ho(nuv,sa4a1) )
c
  101       continue
c
          endif
c
        endif
c
   10 continue
c
cgn      print 1786,25003,vap1ho(nbfop1,25003)
cgn      print 1786,25006,vap1ho(nbfop1,25006)
cgn      ttt(1) = 1.d4
cgn      ttt(2) = -1.d4
cgn          print *,'Apres passage dans PCS1QU'
cgn      do 889 , nuv=1,15
cgn        sm = listno(nuv)
cgn        print 1786,sm,vap1ho(nbfop1,sm)
cgn        ttt(1)=min(ttt(1),vap1ho(nbfop1,sm))
cgn        ttt(2)=max(ttt(2),vap1ho(nbfop1,sm))
cgn 889  continue
cgn      print *,'minimum sur les 15 noeuds ',ttt(1)
cgn      print *,'maximum sur les 15 noeuds ',ttt(2)
c
      endif
c
      end
