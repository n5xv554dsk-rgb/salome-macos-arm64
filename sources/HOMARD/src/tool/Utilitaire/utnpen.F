      subroutine utnpen ( lepent, niveau,
     >                    facpen, perpen,
     >                    nivtri, nivqua )
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
c     UTilitaire : Niveau d'un PENtaedre
c     --           -           ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .  1     . numero du pentaedre a examiner             .
c . niveau .  s  .  1     . niveau                                     .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . perpen . e   . nbpeto . pere des pentaedres                        .
c . nivtri . e   . nbtrto . niveau dans le raffinement/deraffinement   .
c . nivqua . e   . nbquto . niveau dans le raffinement/deraffinement   .
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
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      double precision niveau
c
      integer lepent
      integer facpen(nbpecf,5), perpen(nbpeto)
      integer nivtri(nbtrto), nivqua(nbquto)
c
c 0.4. ==> variables locales
c
      integer lafac1, lafac2, lafac3, lafac4, lafac5
      integer lepere
      integer iaux, jaux
c
c 0.5. ==> initialisations
c
#include "impr03.h"
c
cgn      write(*,90002) 'nbpema, nbpecf, nbpeto', nbpema, nbpecf, nbpeto
cgn      write(*,90002) 'nbheco', nbheco
c
c====
c 1. Du maillage initial
c====
c
      if ( lepent.le.nbpema ) then
c
        niveau = 0.d0
c
c====
c 2. Au dela
c====
c
      else
c
c 2.1. ==> Si le pentaedre est decrit par faces :
c            le plus haut niveau de ses faces
c
        if ( lepent.le.nbpecf ) then
c
          lafac1 = facpen(lepent,1)
          lafac2 = facpen(lepent,2)
          lafac3 = facpen(lepent,3)
          lafac4 = facpen(lepent,4)
          lafac5 = facpen(lepent,5)
          jaux = max(nivtri(lafac1),nivtri(lafac2),
     >               nivqua(lafac3),nivqua(lafac4),nivqua(lafac5))
c
c 2.2. ==> Si le pentaedre est decrit par aretes :
c            son niveau est le niveau du pere augmente d'un cran
c
        else
c
          iaux = perpen(lepent)
c
          if ( iaux.gt.0 ) then
            lepere = iaux
          else
            write(*,90002) 'lepent, iaux', lepent, iaux
            write(*,*) 'arret dans utnpen'
            STOP
          endif
cgn      write(*,90002) 'iaux, lepere', iaux, lepere
c
          if ( iaux.gt.0 ) then
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
c====
c 3. Si le pentaedre est de conformite, on prend le niveau
c            intermediaire immediatement inferieur
c====
c
        if ( lepent.gt.nbpepe ) then
          niveau = niveau - 0.5d0
        endif
c
      endif
cgn      write(*,90004) '==> niveau',niveau
c
      end
