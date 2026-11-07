      subroutine utvoh0 ( coosom, volume )
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
c   UTilitaire : VOlume Hexaedre - 0
c   --           --     -          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coosom . e   .   3*8  . coordonnees des noeuds                     .
c . volume .  s  .    1   . Volume de l'hexaedre                       .
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
c 0.3. ==> arguments
c
      double precision coosom(3,8)
      double precision volume
c
c 0.4. ==> variables locales
c
      integer iaux
c
      double precision volcou
      double precision v12(3), v13(3), v14(3), v15(3)
      double precision v16(3), v17(3), v18(3)
c
c====
c 1. le volume de l'hexaedre est la somme des volumes des 6 tetraedres
c    que l'on obtient en coupant les quadrangles en 2 triangles
c    on rappelle que le volume d'un tetraedre est egale au sixieme
c    de la valeur absolue du produit mixte de trois des vecteurs
c    representant les aretes.
c         vn = v1xv2 --> volume = 1/6 * produit mixte (v1,v2,v3)
c====
c
      do 11 , iaux = 1 , 3
c
        v12(iaux) = coosom(iaux,2) - coosom(iaux,1)
        v13(iaux) = coosom(iaux,3) - coosom(iaux,1)
        v14(iaux) = coosom(iaux,4) - coosom(iaux,1)
        v15(iaux) = coosom(iaux,5) - coosom(iaux,1)
        v16(iaux) = coosom(iaux,6) - coosom(iaux,1)
        v17(iaux) = coosom(iaux,7) - coosom(iaux,1)
        v18(iaux) = coosom(iaux,8) - coosom(iaux,1)
c
   11 continue
c
      call utprmi ( v18, v13, v12, volcou )
c      write(*,*) 'volume du premier tetraedre', volcou
      volume = abs(volcou)
c
      call utprmi ( v18, v12, v15, volcou )
c      write(*,*) 'volume du deuxieme tetraedre', volcou
      volume = volume + abs(volcou)
c
      call utprmi ( v18, v15, v16, volcou )
c      write(*,*) 'volume du troisieme tetraedre', volcou
      volume = volume + abs(volcou)
c
      call utprmi ( v18, v16, v17, volcou )
c      write(*,*) 'volume du quatrieme tetraedre', volcou
      volume = volume + abs(volcou)
c
      call utprmi ( v18, v17, v14, volcou )
c      write(*,*) 'volume du cinquieme tetraedre', volcou
      volume = volume + abs(volcou)
c
      call utprmi ( v18, v14, v13, volcou )
c      write(*,*) 'volume du sixieme tetraedre', volcou
      volume = volume + abs(volcou)
c
      volume = unssix * volume
c
      end
