      subroutine utvga2 ( nbnoto, nbarto, nvosom,
     >                    somare, povoso, voisom )
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
c    UTilitaire - voisinage ARetes-Noeuds - phase 2
c    --                     --     -              -
c ______________________________________________________________________
c
c       determine les aretes voisines de chaque sommet
c       les eventuels noeuds milieux d'arete sont ignores.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbnoto . e   .   1    . nombre de noeuds total                     .
c . nbarto . e   .   1    . nombre d'aretes total                      .
c . nvosom . e   .   1    . nombre cumule d'aretes voisines de noeud   .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . povoso . es  .0:nbnoto. pointeur des voisins par sommet            .
c . voisom .  s  . nvosom . aretes voisines de chaque noeud            .
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
      integer nbnoto, nbarto, nvosom
c
      integer somare(2,nbarto)
      integer povoso(0:nbnoto), voisom(nvosom)
c
c 0.4. ==> variables locales
c
      integer larete, sommet
c ______________________________________________________________________
c
c====
c 1. on passe en revue chaque arete et on indique qu'elle est
c    la voisine de ses sommets
c
c    au depart :
c    povoso(i) = position du dernier voisin du sommet i-1
c              = nombre cumule de voisins pour les (i-1) 1ers sommets
c    a l'arrivee :
c    povoso(i) = position du dernier voisin du sommet i
c              = nombre cumule de voisins pour les i premiers sommets
c====
#ifdef _DEBUG_HOMARD_
cgn        print *,'nbarto = ',nbarto
#endif
c
      do 11 , larete = 1 , nbarto
c
#ifdef _DEBUG_HOMARD_
cgn        print *,'larete = ', larete
cgn        print *,'sommets = ', somare(1,larete), somare(2,larete)
#endif
c
        sommet = somare(1,larete)
#ifdef _DEBUG_HOMARD_
cgn        print *,'povoso(',sommet,') = ',povoso(sommet)
#endif
        povoso(sommet) = povoso(sommet) + 1
        voisom(povoso(sommet)) = larete
c
        sommet = somare(2,larete)
#ifdef _DEBUG_HOMARD_
cgn        print *,'povoso(',sommet,') = ',povoso(sommet)
#endif
        povoso(sommet) = povoso(sommet) + 1
        voisom(povoso(sommet)) = larete
c
   11 continue
c
      end
