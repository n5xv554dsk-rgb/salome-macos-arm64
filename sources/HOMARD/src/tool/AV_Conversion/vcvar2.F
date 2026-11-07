      subroutine vcvar2 ( areele, typele, vofaar, povoar )
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
c    aVant adaptation - Conversion - VOisins des Aretes - phase 2
c     -                 -            --          -              -
c ______________________________________________________________________
c
c but : determine les elements 1d, 2d ou 3d voisins de chaque arete
c    ce travail suppose que l'on ne garde du maillage de calcul
c    que des triangles et des tetraedres.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . areele . e   . nbelem . aretes des elements                        .
c .        .     .*nbmaae .                                            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . vofaar .  s  . nvoare . voisins des aretes en stockage morse       .
c . povoar . e/s .0:nbarto. pointeur des voisins par arete             .
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
      integer vofaar(nvoare), povoar(0:nbarto)
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
c    si c'est un element 2d ou 3d, on indique qu'il est
c    le voisin de ses aretes
c    selon le type, il n'y a pas le meme nombre d'aretes
c
c    au depart :
c    povoar(i) = position du dernier voisin de l'arete i-1
c              = nombre cumule de voisins pour les (i-1) 1eres aretes
c    a l'arrivee :
c    povoar(i) = position du dernier voisin de l'arete i
c              = nombre cumule de voisins pour les i premieres aretes
c====
c
      do 11 , el = 1 , nbelem
c
        typhom = medtrf(typele(el))
        nbarel = nbaref(typhom)
        if ( tyeref(typhom).ne.0 ) then
          nbarel = 0
        endif
c
        do 121 , iaux = 1 , nbarel
          arete = areele(el,iaux)
          povoar(arete) = povoar(arete) + 1
          vofaar(povoar(arete)) = el
  121   continue
c
   11 continue
c
      end
