      subroutine utvga1 ( nbnoto, nbarto, nvosom,
     >                    somare, povoso )
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
c    UTilitaire - voisinage ARetes-Noeuds - phase 1
c    --                     --     -              -
c ______________________________________________________________________
c
c       determine le nombre d'aretes voisines de chaque sommet
c       les eventuels noeuds milieux d'arete sont ignores.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbnoto . e   .   1    . nombre de noeuds total                     .
c . nbarto . e   .   1    . nombre d'aretes total                      .
c . nvosom .  s  .   1    . nombre cumule d'aretes voisines de noeud   .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
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
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer nbnoto, nbarto, nvosom
c
      integer somare(2,nbarto)
      integer povoso(0:nbnoto)
c
c 0.4. ==> variables locales
c
      integer lenoeu, larete
c ______________________________________________________________________
c
c====
c 1. on passe en revue chaque arete et on incremente de 1
c    le nombre de voisins de ses sommets
c====
c
#ifdef _DEBUG_HOMARD_
cgn        print *,'nbnoto = ',nbnoto
cgn        print *,'nbarto = ',nbarto
#endif
      do 11 , lenoeu = 0 , nbnoto
         povoso(lenoeu) = 0
   11 continue
c
      do 12 , larete = 1 , nbarto
#ifdef _DEBUG_HOMARD_
cgn        print *,'larete = ', larete
cgn        print *,'sommets = ', somare(1,larete), somare(2,larete)
#endif
c
        povoso(somare(1,larete)) = povoso(somare(1,larete)) + 1
        povoso(somare(2,larete)) = povoso(somare(2,larete)) + 1
c
   12 continue
c
c====
c 2. on initialise le pointeur dans le tableau des voisins
c
c    au depart :
c    povoso(0) = 0
c    povoso(i) = nombre d'aretes voisines du noeud i
c
c    a l'arrivee :
c    povoso(0) = 0
c    povoso(i) = position de la derniere voisine du noeud i-1
c              = nombre cumule de voisines pour les (i-1) 1ers noeuds
c
c    a la fin de cette partie, pour les noeuds au milieu des aretes
c    le pointeur est le meme que celui du noeud qui le suit.
c====
c
      do 21 , lenoeu = 1 , nbnoto
#ifdef _DEBUG_HOMARD_
cgn        print *,'povoso(',lenoeu,') = ',povoso(lenoeu)
#endif
         povoso(lenoeu) = povoso(lenoeu-1) + povoso(lenoeu)
   21 continue
c
      nvosom = povoso(nbnoto)
c
      do 22 , lenoeu = nbnoto , 1 , -1
         povoso(lenoeu) = povoso(lenoeu-1)
#ifdef _DEBUG_HOMARD_
cgn        print *,'povoso(',lenoeu,') = ',povoso(lenoeu)
#endif
   22 continue
c
      end
