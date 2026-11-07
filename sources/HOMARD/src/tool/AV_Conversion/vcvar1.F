      subroutine vcvar1 ( areele, typele, povoar )
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
c    aVant adaptation - Conversion - VOisins des Aretes - phase 1
c     -                 -            --          -              -
c ______________________________________________________________________
c
c but : determine le nombre d'elements 2d ou 3d voisins de chaque arete
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . areele . e   . nbelem . aretes des elements                        .
c .        .     .*nbmaae .                                            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . povoar .  s  .0:nbarto. pointeur des voisins par arete             .
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
#include "referx.h"
c
c 0.2. ==> communs
c
#include "nbutil.h"
#include "nombar.h"
#include "refere.h"
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer areele(nbelem,nbmaae), typele(nbelem)
      integer povoar(0:nbarto)
c
c 0.4. ==> variables locales
c
      integer el, arete, typhom
      integer iaux
      integer nbarel
c ______________________________________________________________________
c
c====
c 1. on passe en revue chaque element
c    si c'est un element 2d ou 3d, on incremente de 1 le nombre
c    d'elements 2d ou 3d voisins de ses aretes
c    selon le type, il n'y a pas le meme nombre d'aretes
c====
c
      do 11 , arete = 1 , nbarto
        povoar(arete) = 0
   11 continue
c
      do 12 , el = 1 , nbelem
c
        typhom = medtrf(typele(el))
        nbarel = nbaref(typhom)
        if ( tyeref(typhom).ne.0 ) then
          nbarel = 0
        endif
c
        do 121 , iaux = 1 , nbarel
         povoar(areele(el,iaux)) = povoar(areele(el,iaux)) + 1
  121   continue
c
   12 continue
c
c====
c 2. on initialise le pointeur dans le tableau des voisins
c    povoar(i) = position du dernier voisin de l'arete i-1
c              = nombre cumule de voisins pour les (i-1) 1eres aretes
c====
c
      povoar(0) = 0
c
      do 21 , arete = 1 , nbarto
        povoar(arete) = povoar(arete) + povoar(arete-1)
   21 continue
c
      nvoare = povoar(nbarto)
c
      do 22 , arete = nbarto , 1 , -1
        povoar(arete) = povoar(arete-1)
   22 continue
c
      end
