      subroutine pcs1pe ( nbfop1, profho,
     >                    somare,
     >                    aretri, arequa,
     >                    tritet, cotrte,
     >                    facpen, cofape, arepen,
     >                    filpen, hetpen, fppyte,
     >                    facpyr, cofapy, arepyr,
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
c    interpolation p1 sur les noeuds lors du decoupage des PEntaedres
c                   -                                      --
c remarque : on devrait optimiser cela car si le pentaedre etait dans
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
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. codes des faces des pentaedres             .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
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
#include "fracte.h"
c
c 0.2. ==> communs
c
#include "nombar.h"
#include "nombno.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer nbfop1
      integer profho(nbnoto)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto), filpen(nbpeto)
      integer fppyte(2,nbpeco)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      double precision vap1ho(nbfop1,*)
c
c 0.4. ==> variables locales
c
      integer lepent, lepen0
      integer listar(9), listso(6)
      integer etapen
      integer sm, nuv
      integer iaux
c
      double precision daux
c ______________________________________________________________________
c
c====
c 1. interpolation p1 pour les pentaedres qui viennent d'etre decoupes
c    avec creation d'un noeud central. Ce noeud est au barycentre
c    des 6 sommets du pentaedre pere. Donc on prend la moyenne de la
c    fonction sur ces 6 noeuds.
c====
c
      if ( nbfop1.ne.0 ) then
c
      do 10 , lepen0 = 1, nbpeto
c
        lepent = lepen0
c
        etapen = mod(hetpen(lepent),100)
cgn         if ( etapen.gt.0 .and. etapen.ne.80 ) then
cgn          write(6,*) lepent,hetpen(lepent)
cgn          endif
cgn          write(6,*) lepent,hetpen(lepent)
cgn          write(6,*) (facpen(lepent,iaux),iaux=1,5)
cgn          write(6,*) (cofape(lepent,iaux),iaux=1,5)
c
        if ( ( etapen.ge.31 .and. etapen.le.36 ) .or.
     >       ( etapen.ge.51 .and. etapen.le.52 ) ) then
cgn          write(6,*) lepent,hetpen(lepent)
c
c         les aretes et les sommets du pentaedre
c
          call utaspe ( lepent,
     >                  nbquto, nbpecf, nbpeca,
     >                  somare, arequa,
     >                  facpen, cofape, arepen,
     >                  listar, listso )
cgn          write(6,*) listso
c
c         tous les noeuds doivent etre dans le profil
c
          do 101 , iaux = 1 , 6
            if ( profho(listso(iaux)).ne.1 ) then
              goto 10
            endif
  101     continue
c
c         recherche du noeud central
c
          iaux = lepent
          call utnmpe ( iaux, sm,
     >                  somare, aretri, arequa,
     >                  tritet, cotrte,
     >                  facpen, cofape, filpen, fppyte,
     >                  facpyr, cofapy )
c
c         le noeud central est a ajouter dans le profil
c
          profho(sm) = 1
c
c         interpolation = 1/6 (u1+u2+u3...u6)
c
          do 102 , nuv = 1, nbfop1
c
            daux = 0.d0
            do 103 , iaux = 1 , 6
              daux = daux + vap1ho(nuv,listso(iaux))
  103       continue
            vap1ho(nuv,sm) = unssix * daux
c
  102     continue
c
        endif
c
   10 continue
c
      endif
c
      end
