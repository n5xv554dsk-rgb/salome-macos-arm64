      subroutine pcsiqu ( nbfop2, profho, vap2ho,
     >                    hetqua, arequa, filqua,
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
c    interpolation iso-p2 sur les noeuds - decoupage des QUadrangles
c                  -                                     --
c remarque : on devrait optimiser cela car si le quadrangle etait dans
c            un etat de decoupage similaire, on recalcule une valeur
c            qui est deja presente
c remarque : pcs2qu et pcsiqu sont des clones
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
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
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
#include "fracta.h"
#include "fractc.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(nbnoto)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3)
c
      double precision vap2ho(nbfop2,*)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lequad
      integer typdec, etanp1
      integer s1, s2, noemi
      integer sm, nuv
c
      integer listar(4), listno(8)
      integer nbain, areint(4)
c
c     f1hp = Fils 1er du quadrangle en numerotation Homard a l'it. N+1
      integer f1hp
c
      logical afaire
c
c 0.5. ==> initialisations
c
#include "impr03.h"
c ______________________________________________________________________
cgn       write (1,*) 'PCSIQU'
cgn 1789 format(a,10i4)
cgn 1791 format(8g12.5)
c
      do 10 , lequad = 1, nbquto
c
c====
c 1. interpolation iso-p2 pour un quadrangle qui vient d'etre decoupe
c====
c
        iaux = lequad
        call pcs0qu ( iaux, profho,
     >                hetqua, arequa,
     >                somare, np2are,
     >                afaire, listar, listno, typdec, etanp1 )
c
cgn       write (1,90002) 'quad/typdec', lequad, typdec
        if ( afaire ) then
c
          f1hp = filqua(lequad)
c
c====
c 2. L'eventuel noeud central
c====
c
          if ( typdec.eq.4 .or.
     >       ( etanp1.ge.41 .and. etanp1.le.44 ) ) then
c
            if ( typdec.eq.4 ) then
              sm = somare(2,arequa(f1hp,2))
            else
              sm = somare(2,arequa(f1hp,3))
            endif
            profho(sm) = 1
cgn        write(6,1789) 'f1hp =', f1hp
cgn        write(6,1789) 'sm =', sm
c
c         interpolation = 1/4 (u5+u6+u7+u8)
c
cgn 1789 format( 4g13.5)
            do 21, nuv = 1, nbfop2
cgn        write(6,1791) vap2ho(nuv,listno(5)), vap2ho(nuv,listno(6))
cgn     >              , vap2ho(nuv,listno(7)), vap2ho(nuv,listno(8))
c
              vap2ho(nuv,sm) = + unsqu * ( vap2ho(nuv,listno(5))
     >                                   + vap2ho(nuv,listno(6))
     >                                   + vap2ho(nuv,listno(7))
     >                                   + vap2ho(nuv,listno(8)) )
cgn        write(6,1791) vap2ho(nuv,sm)
c
   21       continue
c
          endif
c
c====
c 3. Les noeuds sur les aretes internes
c====
c 3.1. Recherche des aretes internes
c      voir cmrdqu, cmcdq2, cmcdq3 et cmcdq5 pour les conventions
c
          nbain = 0
          if ( typdec.eq.4) then
            do 311 , iaux = 0, 3
              nbain = nbain + 1
              areint(nbain) = arequa(f1hp+iaux,2)
  311       continue
          elseif ( typdec.eq.21 .or. typdec.eq.22 ) then
            nbain = nbain + 1
            areint(nbain) = arequa(f1hp,4)
          elseif ( typdec.ge.31 .and. typdec.le.34 ) then
            nbain = nbain + 1
            areint(nbain) = aretri(-f1hp,1)
            nbain = nbain + 1
            areint(nbain) = aretri(-f1hp,3)
          elseif ( typdec.ge.41 .and. typdec.le.44 ) then
            nbain = nbain + 1
            areint(nbain) = arequa(f1hp,3)
            nbain = nbain + 1
            areint(nbain) = arequa(f1hp,4)
            nbain = nbain + 1
            areint(nbain) = arequa(f1hp+1,3)
          endif
cgn        write(1,90002) 'nbain', nbain, (areint(iaux),iaux=1,nbain)
c
c 3.2. ==> les valeurs sur les noeuds
c
          do 32 , iaux = 1 , nbain
c
            s1 = somare(1,areint(iaux))
            s2 = somare(2,areint(iaux))
            noemi = np2are(areint(iaux))
            profho(noemi) = 1
c
            do 321, nuv = 1 , nbfop2
c
              vap2ho(nuv,noemi) = unsde * ( vap2ho(nuv,s1)
     >                                    + vap2ho(nuv,s2) )
cgn        write(*,*) 'vap2ho(nuv,',noemi,') =',vap2ho(nuv,noemi)
c
  321       continue
c
   32     continue
c
        endif
c
   10 continue
c
      end
