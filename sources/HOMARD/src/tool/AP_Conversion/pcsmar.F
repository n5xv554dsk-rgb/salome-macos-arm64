      subroutine pcsmar ( nbfop2, profho,
     >                    somare, np2are,
     >                    vap2ho )
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
c    Modification de degre
c    -
c    interpolation p1 sur les noeuds lors du decoupage des ARetes
c                                                          --
c remarque : pcs1ar et pcsmar sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop2 . e   .    1   . nombre de fonctions P2                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . vap2ho . es  . nbfop2*. variables p2 numerotation homard           .
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
      integer nbfop2
      integer profho(nbnoto)
      integer somare(2,nbarto), np2are(nbarto)
c
      double precision vap2ho(nbfop2,*)
c
c 0.4. ==> variables locales
c
      integer larete, nuv, s1, s2, sm
c ______________________________________________________________________
c
#include "impr03.h"
c
c====
c 1. interpolation p1 pour toutes les aretes
c====
c
      if ( nbfop2.ne.0 ) then
c
      do 1000, larete = 1, nbarto
c
c         recuperation des sommets de l'arete
c
          s1 = somare(1,larete)
          s2 = somare(2,larete)
cgn          write(*,90001) 'profil de', s1, profho(s1)
cgn          write(*,90001) 'profil de', s2, profho(s2)
c
          if ( profho(s1).eq.1 .and. profho(s2).eq.1 ) then
c
c           recuperation du nouveau noeud sommet
c
            sm = np2are(larete)
            profho(sm) = 1
cgn          write(*,90001) '==> profil de', sm, profho(sm)
c
c           interpolation : interpolee (ui,i=1,2) = 1/2 (u1+u2)
c
            do 11, nuv = 1, nbfop2
c
              vap2ho(nuv,sm) = unsde
     >                       * ( vap2ho(nuv,s1) + vap2ho(nuv,s2) )
c
   11       continue
c
        endif
c
 1000 continue
c
      endif
c
      end
