      subroutine vcvos2 ( noeele, typele, povoso, voisom,
     >                    nvosom, nbelem, nbmane, nbnoto )
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
c    aVant adaptation - Conversion - VOisins des Sommets - phase 2
c     -                 -            --          -               -
c ______________________________________________________________________
c
c but : determine les elements 0d, 1d, 2d ou 3d voisins de
c       chaque sommet pour un maillage a la table de connectivite
c       du type med
c
c attention : tout est fait en numerotation du calcul pour les noeuds,
c             c'est-a-dire avec la numerotation initiale
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . noeele . e   . nbelem . noeuds des elements                        .
c .        .     .*nbmane .                                            .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . povoso . e/s .0:nbnoto. pointeur des voisins par sommet            .
c . voisom .  s  . nvosom . voisins des sommets en stockage morse      .
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
#include "refere.h"
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer nbelem, nbmane, nbnoto
      integer noeele(nbelem,nbmane), typele(nbelem)
      integer nvosom
      integer voisom(nvosom), povoso(0:nbnoto)
c
c 0.4. ==> variables locales
c
      integer el, sommet, typhom
      integer iaux
      integer nbsoma
c ______________________________________________________________________
c
c====
c 1. on passe en revue chaque maille et on indique qu'il est
c    le voisin de ses sommets
c    selon le type, les sommets ne sont pas ranges au meme endroit
c
c    au depart :
c    povoso(i) = position du dernier voisin du sommet i-1
c              = nombre cumule de voisins pour les (i-1) 1ers sommets
c    a l'arrivee :
c    povoso(i) = position du dernier voisin du sommet i
c              = nombre cumule de voisins pour les i premiers sommets
c====
c
      do 11 , el = 1 , nbelem
c
        typhom = medtrf(typele(el))
        nbsoma = nbnref(typhom,1)
        if ( tyeref(typhom).ne.0 ) then
          nbsoma = 0
        endif
c
        do 111 , iaux = 1 , nbsoma
          sommet = noeele(el,iaux)
          povoso(sommet) = povoso(sommet) + 1
          voisom(povoso(sommet)) = el
  111   continue
c
   11 continue
c
      end
