      subroutine utfaa1 ( nbarto, nbtrto, nbquto,
     >                    nbaral, nbtral, nbqual,
     >                    aretri, arequa,
     >                    nbfaar, posifa )
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
c    UTilitaire - voisinage FAce-Aretes - phase 1
c    --                     --   -              -
c ______________________________________________________________________
c
c       determine le nombre de faces voisines de chaque arete
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbarto . e   .   1    . nombre d'aretes a examiner                 .
c . nbtrto . e   .   1    . nombre de triangles a examiner             .
c . nbquto . e   .   1    . nombre de quadrangles a examiner           .
c . nbaral . e   .   1    . nombre d'aretes pour les allocations       .
c . nbtral . e   .   1    . nombre de triangles pour les allocations   .
c . nbqual . e   .   1    . nombre de quadrangles pour les allocations .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nbfaar .  s  .   1    . nombre cumule de faces par arete           .
c . posifa .  s  .0:nbarto. pointeur sur tableau facare                .
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
c 0.3. ==> arguments
c
      integer nbarto, nbtrto, nbquto, nbfaar
      integer nbaral, nbtral, nbqual
      integer aretri(nbtral,3), arequa(nbqual,4)
      integer posifa(0:nbaral)
c
c 0.4. ==> variables locales
c
      integer laface, larete
c ______________________________________________________________________
c
c====
c 1. on passe en revue chaque face et on incremente de 1 le nombre de
c    faces voisines de ses 3 aretes
c
c    au depart :
c    posifa(0) = 0
c    posifa(i) = 0
c
c    a l'arrivee :
c    posifa(0) = 0
c    posifa(i) = nombre de faces voisines de l'arete i
c====
c
      do 11 , larete = 0 , nbarto
        posifa(larete) = 0
   11 continue
c
      do 12 , laface = 1 , nbtrto
        posifa(aretri(laface,1)) = posifa(aretri(laface,1)) + 1
        posifa(aretri(laface,2)) = posifa(aretri(laface,2)) + 1
        posifa(aretri(laface,3)) = posifa(aretri(laface,3)) + 1
   12 continue
c
      do 13 , laface = 1 , nbquto
        posifa(arequa(laface,1)) = posifa(arequa(laface,1)) + 1
        posifa(arequa(laface,2)) = posifa(arequa(laface,2)) + 1
        posifa(arequa(laface,3)) = posifa(arequa(laface,3)) + 1
        posifa(arequa(laface,4)) = posifa(arequa(laface,4)) + 1
   13 continue
c
c====
c 2. on initialise le pointeur dans le tableau des voisins
c
c    au depart :
c    posifa(0) = 0
c    posifa(i) = nombre de faces voisines de l'arete i
c
c    a l'arrivee :
c    posifa(0) = 0
c    posifa(i) = position de la derniere voisine de l'arete i-1
c              = nombre cumule de voisines pour les (i-1) 1eres aretes
c====
c
      do 21 , larete = 1 , nbarto
        posifa(larete) = posifa(larete) + posifa(larete-1)
   21 continue
c
      nbfaar = posifa(nbarto)
c
      do 22 , larete = nbarto , 1 , -1
        posifa(larete) = posifa(larete-1)
   22 continue
c
      end
