      subroutine pcs2te ( nbfop2, profho, vap2ho,
     >                    tritet, cotrte, aretet,
     >                    hettet, filtet,
     >                    somare, np2are,
     >                    aretri )
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
c    interpolation p2 sur les noeuds - decoupage des TEtraedres
c                   -                                --
c ______________________________________________________________________
c attention : il faut passer ce programme avant le traitement des
c             nouveaux noeuds sur les triangles coupes, sinon les
c             valeurs sur les noeuds des diagonales seront inconnues
c remarque : on devrait optimiser cela car si le tetraedre etait dans
c            un etat de decoupage de conformite similaire, on recalcule
c            une valeur qui est deja presente
c remarque : pcs2te et pcsite sont des clones
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
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
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
#include "fractf.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(nbnoto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto), filtet(nbteto)
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3)
c
      double precision vap2ho(nbfop2,*)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer letetr, adiag
      integer sm, nuv
      integer listar(6), listno(10)
c
      logical afaire
c ______________________________________________________________________
c
#include "impr03.h"
cgn       write (1,90002) 'PCS2TE, nbfop2', nbfop2
c
      do 10 , letetr = 1, nbteto
c
c====
c 1. interpolation p2 pour un tetraedre qui vent d'etre decoupe
c    les seuls cas interessants sont ceux ou un noeud est cree a
c    l'interieur du tetraedre, donc quand il y a une diagonale.
c====
c
        iaux = letetr
        call pcs0te ( iaux, profho,
     >                tritet, cotrte, aretet,
     >                hettet, filtet,
     >                aretri,
     >                somare, np2are,
     >                afaire, listar, listno, adiag )
c
c====
c 2. le tetraedre vient d'etre decoupe et le champ est present
c    interpolation au noeud milieu de la diagonale
c====
c
        if ( afaire ) then
c
          sm = np2are(adiag)
          profho(sm) = 1
cgn        write(1,90002) 'dans pcs2te, f1hp =', f1hp
cgn        write(1,90002) 'sm =', sm
c
c           interpolation p2 c
c
c           interpolee (ui,i=1,10) = -1/8 (ui,i=1,4) + 1/4 (ui,i=5,10)
c
          do 22 , nuv = 1, nbfop2
c
            vap2ho(nuv,sm) =
     >      unsqu * ( vap2ho(nuv,listno(5)) + vap2ho(nuv,listno(6))
     >              + vap2ho(nuv,listno(7)) + vap2ho(nuv,listno(8))
     >              + vap2ho(nuv,listno(9)) + vap2ho(nuv,listno(10)) )
     >    - unshu * ( vap2ho(nuv,listno(1)) + vap2ho(nuv,listno(2))
     >              + vap2ho(nuv,listno(3)) + vap2ho(nuv,listno(4)) )
cgn        write(1,90014) sm, vap2ho(nuv,sm)
c
   22     continue
c
        endif
c
   10 continue
c
      end
