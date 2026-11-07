      subroutine pcsiar ( nbfop2, profho, vap2ho,
     >                    hetare, somare, np2are, filare )
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
c    interpolation iso-p2 sur les noeuds lors du decoupage des ARetes
c                  -                                           --
c remarque : pcs2ar et pcsiar sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop2 . e   .    1   . nombre de fonctions P2                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vap2ho . es  . nbfop2*. variables iso-p2 numerotation homard       .
c .        .     . nbnoto .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
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
#include "nombno.h"
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(nbnoto)
      integer hetare(nbarto), somare(2,nbarto), np2are(nbarto)
      integer filare(nbarto)
c
      double precision vap2ho(nbfop2,*)
c
c 0.4. ==> variables locales
c
      integer larete, a1, a2, sm, s1, s2, m1, m2, nuv
c ______________________________________________________________________
c
c====
c 1. interpolation pour les aretes qui viennent d'etre decoupees
c====
c
      do 10 , larete = 1, nbarto
c
        if ( hetare(larete).eq.2 ) then
c
c         recuperation des aretes filles
c
          a1 = filare(larete)
          a2 = a1 + 1
c
c         recuperation des sommets de l'arete
c
          s1 = somare(1,larete)
          s2 = somare(2,larete)
c
c         recuperation du nouveau noeud sommet
c
          sm = np2are(larete)
c
          if ( profho(s1).eq.1 .and. profho(s2).eq.1 .and.
     >         profho(sm).eq.1 ) then
c
c         recuperation des nouveaux noeuds milieux
c
            m1 = np2are(a1)
            m2 = np2are(a2)
            profho(m1) = 1
            profho(m2) = 1
c
c         interpolation p1 : interpolee (ui,i=1,2) = 1/2 (u1+u2)
c
            do 11, nuv = 1, nbfop2
c
              vap2ho(nuv,m1) =
     >        unsde * ( vap2ho(nuv,s1) + vap2ho(nuv,sm) )
              vap2ho(nuv,m2) =
     >        unsde * ( vap2ho(nuv,s2) + vap2ho(nuv,sm) )
c
   11       continue
c
          endif
c
        endif
c
   10 continue
c
      end
