      subroutine utntet ( letetr, niveau,
     >                    tritet, pertet, pthepe,
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
c     UTilitaire : Niveau d'un TETraedre
c     --           -           ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letetr . e   .  1     . numero du tetraedre a examiner             .
c . niveau .  s  .  1     . niveau                                     .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . pertet . e   . nbteto . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . pthepe . e   .    *   . si i <= nbheco : numero de l'hexaedre      .
c .        .     .        . si non : numero du pentaedre               .
c . nivtri . e   . nbtrto . niveau dans le raffinement/deraffinement   .
c . nivqua . e   . nbquto . niveau dans le raffinement/deraffinement   .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c .____________________________________________________________________.
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
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      double precision niveau
c
      integer letetr
      integer nivtri(nbtrto), nivqua(nbquto)
      integer tritet(nbtecf,4), pertet(nbteto), pthepe(*)
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
cgn      write(*,90002) 'nbtema, nbtecf, nbteto', nbtema, nbtecf, nbteto
cgn      write(*,90002) 'letetr', letetr
c
c 1.1. ==> Du maillage initial
c
      if ( letetr.le.nbtema ) then
c
        niveau = 0.d0
c
c 1.2. ==> Au dela
c
      else
c
c 1.2.1. ==> Si le tetraedre est decrit par faces :
c            le plus haut niveau de ses faces
c
        if ( letetr.le.nbtecf ) then
c
          lafac1 = tritet(letetr,1)
          lafac2 = tritet(letetr,2)
          lafac3 = tritet(letetr,3)
          lafac4 = tritet(letetr,4)
          jaux = max(nivtri(lafac1),nivtri(lafac2),
     >               nivtri(lafac3),nivtri(lafac4))
c
c 1.2.2. ==> Si le tetraedre est decrit par aretes :
c            son niveau est le niveau du pere augmente d'un cran
c
        else
c
          iaux = pertet(letetr)
          lepere = pthepe(-iaux)
cgn      write(*,90002) 'iaux, lepere', iaux, lepere
cgn      write(*,90002) 'nbheco', nbheco
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
c 1.2.3. ==> Si le tetraedre est de conformite, on prend le niveau
c            intermediaire immediatement inferieur
c
        if ( letetr.gt.nbtepe ) then
          niveau = niveau - 0.5d0
        endif
c
      endif
cgn      write(*,90004) '==> niveau',niveau
c
      end
