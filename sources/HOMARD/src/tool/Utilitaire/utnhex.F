      subroutine utnhex ( lehexa, niveau,
     >                    quahex, perhex,
     >                    nivqua )
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
c     UTilitaire : Niveau d'un HEXaedre
c     --           -           ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .  1     . numero de l'hexaedre a examiner            .
c . niveau .  s  .  1     . niveau                                     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . perhex . e   . nbheto . pere des hexaedres                         .
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
#include "nombqu.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      double precision niveau
c
      integer lehexa
      integer quahex(nbhecf,6), perhex(nbheto)
      integer nivqua(nbquto)
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
cgn      write(*,90002) 'nbhema, nbhecf, nbheto', nbhema, nbhecf, nbheto
cgn      write(*,90002) 'nbheco', nbheco
c
c====
c 1. Du maillage initial
c====
c
      if ( lehexa.le.nbhema ) then
c
        niveau = 0.d0
c
c====
c 2. Au dela
c====
c
      else
c
c 2.1. ==> Si l'hexaedre est decrit par faces :
c            le plus haut niveau de ses faces
c
        if ( lehexa.le.nbhecf ) then
c
          lafac1 = quahex(lehexa,1)
          lafac2 = quahex(lehexa,2)
          lafac3 = quahex(lehexa,3)
          lafac4 = quahex(lehexa,4)
          lafac5 = quahex(lehexa,5)
          lafac6 = quahex(lehexa,6)
          jaux = max(nivqua(lafac1),nivqua(lafac2),nivqua(lafac3),
     >               nivqua(lafac4),nivqua(lafac5),nivqua(lafac6))
c
c 2.2. ==> Si l'hexaedre est decrit par aretes :
c            son niveau est le niveau du pere augmente d'un cran
c
        else
c
          iaux = perhex(lehexa)
c
          if ( iaux.gt.0 ) then
            lepere = iaux
          else
            write(*,90002) 'lehexa, iaux', lehexa, iaux
            write(*,*) 'arret dans utnhex'
            STOP
          endif
cgn      write(*,90002) 'iaux, lepere', iaux, lepere
c
          if ( iaux.gt.0 ) then
c
            lafac1 = quahex(lepere,1)
            lafac2 = quahex(lepere,2)
            lafac3 = quahex(lepere,3)
            lafac4 = quahex(lepere,4)
            lafac5 = quahex(lepere,5)
            lafac6 = quahex(lepere,6)
            jaux = max(nivqua(lafac1),nivqua(lafac2),nivqua(lafac3),
     >                 nivqua(lafac4),nivqua(lafac5),nivqua(lafac6))
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
c 3. Si l'hexaedre est de conformite, on prend le niveau
c            intermediaire immediatement inferieur
c====
c
        if ( lehexa.gt.nbhepe ) then
          niveau = niveau - 0.5d0
        endif
c
      endif
cgn      write(*,90004) '==> niveau',niveau
c
      end
