      subroutine utfaa2 ( nbtrto, nbquto,
     >                    nbtral, nbqual,
     >                    aretri, arequa,
     >                    nbfaar, posifa, facare )
c
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
c    UTilitaire - voisinage FAce-Aretes - phase 2
c    --                     --   -              -
c ______________________________________________________________________
c
c       determine les faces voisines de chaque arete
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbtrto . e   .   1    . nombre de triangles a examiner             .
c . nbquto . e   .   1    . nombre de quadrangles a examiner           .
c . nbtral . e   .   1    . nombre de triangles pour les allocations   .
c . nbqual . e   .   1    . nombre de quadrangles pour les allocations .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nbfaar . e   .   1    . nombre cumule de faces par arete           .
c . posifa . e/s .0:nbaret. pointeur sur tableau facare                .
c . facare .  s  . nbfaar . liste des faces contenant une arete        .
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
      integer nbtrto, nbquto, nbfaar
      integer nbtral, nbqual
      integer aretri(nbtral,3), arequa(nbqual,4)
      integer posifa(0:*), facare(nbfaar)
c
c 0.4. ==> variables locales
c
      integer laface, larete
c ______________________________________________________________________
c
c====
c 1. on passe en revue chaque face et on indique qu'elle est voisine de
c    ses aretes : on incremente le pointeur posifa(i) et on
c    memorise la face dans facare a la place posifa(i) :
c    . pour un triangle, c'est le numero HOMARD du triangle
c    . pour un quadrangle, c'est l'oppose du numero HOMARD du quadrangle
c
c    au depart :
c    posifa(0) = 0
c    posifa(i) = position de la derniere voisine de l'arete i-1
c              = nombre cumule de voisines pour les (i-1) 1eres aretes
c
c    a l'arrivee :
c    posifa(0) = 0
c    posifa(i) = position de la derniere voisine de l'arete i
c              = nombre cumule de voisines pour les i premieres aretes
c====
c
      do 11 , laface = 1 , nbtrto
c
         larete = aretri(laface,1)
         posifa(larete) = posifa(larete) + 1
         facare(posifa(larete)) = laface
c
         larete = aretri(laface,2)
         posifa(larete) = posifa(larete) + 1
         facare(posifa(larete)) = laface
c
         larete = aretri(laface,3)
         posifa(larete) = posifa(larete) + 1
         facare(posifa(larete)) = laface
c
   11 continue
c
      do 12 , laface = 1 , nbquto
c
         larete = arequa(laface,1)
         posifa(larete) = posifa(larete) + 1
         facare(posifa(larete)) = -laface
c
         larete = arequa(laface,2)
         posifa(larete) = posifa(larete) + 1
         facare(posifa(larete)) = -laface
c
         larete = arequa(laface,3)
         posifa(larete) = posifa(larete) + 1
         facare(posifa(larete)) = -laface
c
         larete = arequa(laface,4)
         posifa(larete) = posifa(larete) + 1
         facare(posifa(larete)) = -laface
c
   12 continue
c
      end
