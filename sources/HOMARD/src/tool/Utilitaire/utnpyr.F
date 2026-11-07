      subroutine utnpyr ( lapyra, niveau,
     >                    facpyr, perpyr, pphepe,
     >                    nivtri, nivqua,
     >                    quahex, facpen )
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
c     UTilitaire : Niveau d'une PYRamide
c     --           -            ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lapyra . e   .  1     . numero de la pyramide a examiner           .
c . niveau .  s  .  1     . niveau                                     .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . perpyr . e   . nbpyto . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . pphepe . e   .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . nivtri . e   . nbtrto . niveau dans le raffinement/deraffinement   .
c . nivqua . e   . nbquto . niveau dans le raffinement/deraffinement   .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
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
c 0.2. ==> communs
c
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
c
c 0.3. ==> arguments
c
      double precision niveau
c
      integer lapyra
      integer facpyr(nbpycf,5), perpyr(nbpyto), pphepe(*)
      integer nivtri(nbtrto), nivqua(nbquto)
      integer quahex(nbhecf,6)
      integer facpen(nbpecf,5)
c
c 0.4. ==> variables locales
c
      integer lafac1, lafac2, lafac3, lafac4, lafac5, lafac6
      integer lepere
      integer iaux, jaux
c
c 0.5. ==> initialisations
c
#include "impr03.h"
c
c====
c 1. Determination du niveau
c====
c
cgn      write(*,90002) 'nbpyma, nbpycf, nbpyto', nbpyma, nbpycf, nbpyto
cgn      write(*,90002) 'nbheco', nbheco
c
c 1.1. ==> Du maillage initial
c
      if ( lapyra.le.nbpyma ) then
c
        niveau = 0.d0
c
c 1.2. ==> Au dela
c
      else
c
c 1.2.1. ==> Si la pyramide est decrit par faces :
c            le plus haut niveau de ses faces
c
        if ( lapyra.le.nbpycf ) then
c
          lafac1 = facpyr(lapyra,1)
          lafac2 = facpyr(lapyra,2)
          lafac3 = facpyr(lapyra,3)
          lafac4 = facpyr(lapyra,4)
          lafac5 = facpyr(lapyra,5)
          jaux = max(nivtri(lafac1),nivtri(lafac2),
     >               nivtri(lafac3),nivtri(lafac4),
     >               nivqua(lafac5))
c
c 1.2.2. ==> Si la pyramide est decrit par aretes :
c            son niveau est le niveau du pere augmente d'un cran
c
        else
c
          iaux = perpyr(lapyra)
          lepere = pphepe(-iaux)
cgn      write(*,90002) 'iaux, lepere', iaux, lepere
c
          if ( -iaux.le.nbheco ) then
c
            lafac1 = quahex(lepere,1)
            lafac2 = quahex(lepere,2)
            lafac3 = quahex(lepere,3)
            lafac4 = quahex(lepere,4)
            lafac5 = quahex(lepere,5)
            lafac6 = quahex(lepere,6)
            jaux = max(nivqua(lafac1),nivqua(lafac2),nivqua(lafac3),
     >                 nivqua(lafac4),nivqua(lafac5),nivqua(lafac6))
          else
c
            lafac1 = facpen(lepere,1)
            lafac2 = facpen(lepere,2)
            lafac3 = facpen(lepere,3)
            lafac4 = facpen(lepere,4)
            lafac5 = facpen(lepere,5)
            jaux = max(nivtri(lafac1),nivtri(lafac2),
     >                 nivqua(lafac3),nivqua(lafac4),nivqua(lafac5))
c
          endif
c
          jaux = jaux + 1
c
        endif
c
cgn      write(*,90002) '==> jaux',jaux
        niveau = dble(jaux)
c
c 1.2.3. ==> Si la pyramide est de conformite, on prend le niveau
c            intermediaire immediatement inferieur
c
        if ( lapyra.gt.nbpype ) then
          niveau = niveau - 0.5d0
        endif
c
      endif
cgn      write(*,90004) '==> niveau',niveau
c
      end