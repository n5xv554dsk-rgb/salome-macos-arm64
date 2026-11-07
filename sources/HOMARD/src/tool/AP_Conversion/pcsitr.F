      subroutine pcsitr ( nbfop2, profho, vap2ho,
     >                    hettri, aretri, filtri,
     >                    somare, np2are )
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
c    interpolation iso-p2 sur les noeuds - decoupage des TRiangles
c                  -                                     --
c remarque : on devrait optimiser cela car si le triangle etait dans
c            un etat de decoupage similaire, on recalcule une valeur
c            qui est deja presente
c remarque : pcs2tr et pcsitr sont des clones
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
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
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
#include "demitr.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(nbnoto)
      integer hettri(nbtrto), aretri(nbtrto,3), filtri(nbtrto)
      integer somare(2,nbarto), np2are(nbarto)
c
      double precision vap2ho(nbfop2,*)
c
c 0.4. ==> variables locales
c
      integer typdec
      integer iaux1, iaux2, iaux3
      integer letria, letri0
      integer ff, nuv, af1, af2, af3
      integer m1, m2, m3
      integer inloc
      integer listno(6)
c
c     f1hp = Fils 1er du triangle en numerotation Homard a l'it. N+1
c
      integer f1hp
c
      logical afaire
c
c 0.5. ==> initialisations
c ______________________________________________________________________
cgn       write (*,*) 'PCSITR'
c
      do 10 , letri0 = 1, nbtrto
c
        letria = letri0
c
cgn      write (1,90002) 'Triangle', letria
c====
c 1. liste des noeuds concernes et type de decoupage
c====
c
        call pcs0tr ( letria, profho,
     >                hettri, aretri,
     >                somare, np2are,
     >                afaire, listno, typdec )
cgn      write (1,90002) 'typdec', typdec
c
        if ( afaire ) then
c
c====
c 2. le triangle vient d'etre decoupe en 4 triangles alors
c    qu'il ne l'etait pas a l'iteration precedente
c          . en standard : etat 4
c          . avec bascule pour le suivi de frontiere : etat 6, 7 ou 8
c    Remarque : regarder cmrdtr pour les conventions
c====
c
        if ( typdec.ge.4 ) then
c
c           recuperation du triangle fils aine
c           c'est le central si pas de basculement
c
          f1hp = filtri(letria)
c
c           recuperation des aretes internes au triangle decoupe
c           . pour un decoupage standard, ce sont les trois du triangle
c           central
c           . avec une bascule, il y a eu modification du fils aine
c           et du frere de rang connu par l'etat du triangle, inloc.
c           l'arete basculee est celle commune a ces deux triangles. les
c           deux autres aretes sont celles de rang inloc dans la
c           description des deux triangles modifies.
c
          if ( typdec.eq.4 ) then
            af1 = aretri(f1hp,1)
            af2 = aretri(f1hp,2)
            af3 = aretri(f1hp,3)
c
          else
            inloc = typdec - 5
            af3 = 0
            do 21 , iaux1 = 1 , 3
              iaux3 = aretri(f1hp+inloc,iaux1)
              do 211 , iaux2 = 1 , 3
                if ( iaux3.eq.aretri(f1hp,iaux2) ) then
                  af3 = iaux3
                endif
  211         continue
   21       continue
            af1 = aretri(f1hp      ,inloc)
            af2 = aretri(f1hp+inloc,inloc)
          endif
c
c           recuperation des noeuds milieux sur ces aretes internes
c
          m1 = np2are(af1)
          m2 = np2are(af2)
          m3 = np2are(af3)
          profho(m1) = 1
          profho(m2) = 1
          profho(m3) = 1
c
c         interpolation p1 : interpolee (ui,i=1,2) = 1/2 (u1+u2)
c
          do 22 , nuv = 1, nbfop2
c
            vap2ho(nuv,m1) =
     >      unsde * ( vap2ho(nuv,listno(5)) + vap2ho(nuv,listno(6)) )
            vap2ho(nuv,m2) =
     >      unsde * ( vap2ho(nuv,listno(4)) + vap2ho(nuv,listno(6)) )
            vap2ho(nuv,m3) =
     >      unsde * ( vap2ho(nuv,listno(4)) + vap2ho(nuv,listno(5)) )
c
   22     continue
c
c====
c 3. le triangle vient d'etre decoupe en 2
c====
c
        elseif ( typdec.eq.1 .or. typdec.eq.2 .or. typdec.eq.3 ) then
c
c 3.1. ==> le triangle vient d'etre decoupe en 2 par l'arete numero 1
c
          if ( typdec.eq.1 ) then
c
c         recuperation d'un triangle fils
c
            ff = filtri(letria) + nutrde(1,2)
c
c         recuperation du nouveau noeud milieu
c
            m1 = np2are(aretri(ff,3))
            profho(m1) = 1
c
c         interpolation p1 : interpolee (ui,i=1,2) = 1/2 (u1+u2)
c
            do 31 , nuv = 1, nbfop2
c
              vap2ho(nuv,m1) =
     >        unsde * ( vap2ho(nuv,listno(5)) + vap2ho(nuv,listno(6)) )
c
   31       continue
c
c 3.2. ==> le triangle vient d'etre decoupe en 2 par l'arete numero 2
c
          elseif ( typdec.eq.2 ) then
c
c           recuperation d'un triangle fils
c
            ff = filtri(letria) + nutrde(2,1)
c
c           recuperation du nouveau noeud milieu
c
            m2 = np2are(aretri(ff,3))
            profho(m2) = 1
c
c           interpolation p1 : interpolee (ui,i=1,2) = 1/2 (u1+u2)
c
            do 32 , nuv = 1, nbfop2
c
              vap2ho(nuv,m2) =
     >        unsde * ( vap2ho(nuv,listno(4)) + vap2ho(nuv,listno(6)) )
c
   32       continue
c
c 3.3. ==> le triangle vient d'etre decoupe en 2 par l'arete numero 3
c
          elseif ( typdec.eq.3 ) then
c
c           recuperation d'un triangle fils
c
            ff = filtri(letria) + nutrde(3,1)
c
c           recuperation du nouveau noeud milieu
c
            m3 = np2are(aretri(ff,2))
            profho(m3) = 1
c
c           interpolation p1 : interpolee (ui,i=1,2) = 1/2 (u1+u2)
c
            do 33 , nuv = 1, nbfop2
c
              vap2ho(nuv,m3) =
     >        unsde * ( vap2ho(nuv,listno(4)) + vap2ho(nuv,listno(5)) )
c
   33       continue
c
          endif
c
        endif
c
        endif
c
   10 continue
c
      end
