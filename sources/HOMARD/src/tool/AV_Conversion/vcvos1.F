      subroutine vcvos1 ( noeele, typele, povoso,
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
c    aVant adaptation - Conversion - VOisins des Sommets - phase 1
c     -                 -            --          -               -
c ______________________________________________________________________
c
c but : determine le nombre d'elements 0d, 1d, 2d ou 3d voisins de
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
c . povoso .  s  .0:nbnoto. pointeur des voisins par sommet            .
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
      integer povoso(0:nbnoto)
c
c 0.4. ==> variables locales
c
      integer el, noeud, typhom
      integer iaux
      integer nbsoma
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'nbnoto', nbnoto
      write (*,90002) 'nbelem', nbelem
#endif
c ______________________________________________________________________
c
c====
c 1. on passe en revue chaque maille et on incremente de 1
c    le nombre de voisins de ses sommets
c    a la fin de cette partie, ni pour les noeuds au milieu des aretes
c    ni pour les noeuds internes aux mailles, on ne definit de voisin
c====
c
      do 11 , noeud = 1 , nbnoto
        povoso(noeud) = 0
   11 continue
c
      do 12 , el = 1 , nbelem
#ifdef _DEBUG_HOMARD_
        if ( el.le.0 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
        typhom = medtrf(typele(el))
        nbsoma = nbnref(typhom,1)
        if ( tyeref(typhom).ne.0 ) then
          nbsoma = 0
        endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (*,*) 'typele(',el,') = ',typele(el)
        write (*,*) '==> typhom = ',typhom,', nbsoma = ',nbsoma
        endif
#endif
c
        do 121 , iaux = 1 , nbsoma
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (*,90007) 'noeele',el,iaux,noeele(el,iaux)
        endif
#endif
          povoso(noeele(el,iaux)) = povoso(noeele(el,iaux)) + 1
  121   continue
c
   12 continue
c
c====
c 2. on initialise le pointeur dans le tableau des voisins
c    povoso(i) = position du dernier voisin du noeud i-1
c              = nombre cumule de voisins pour les (i-1) premiers noeuds
c    a la fin de cette partie, pour les noeuds au milieu des aretes ou
c    pour les noeuds internes aux mailles, le pointeur est le meme que
c    celui affecte au noeud qui le suit.
c====
c
      povoso(0) = 0
c
      do 21 , noeud = 1 , nbnoto
        povoso(noeud) = povoso(noeud) + povoso(noeud-1)
   21 continue
c
      nvosom = povoso(nbnoto)
c
      do 22 , noeud = nbnoto , 1 , -1
        povoso(noeud) = povoso(noeud-1)
   22 continue
c
      end
