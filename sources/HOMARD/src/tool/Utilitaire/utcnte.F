      subroutine utcnte ( tritet, cotrte, hettet, famtet,
     >                    filtet, pertet, anctet, noutet,
     >                    noutri, nbtere,
     >                    ancfil, ancper )
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
c    UTilitaire - Compactage de la Numerotation des TEtraedres
c    --           -                -                --
c ______________________________________________________________________
c
c  remarque hyper-importante :
c             quelle que soit l'entite (noeud, arete, triangle ou
c             tetraedre) son ancien numero est toujours superieur ou
c             egal a son numero courant : ancent(i) >= i. En effet, la
c             suppression d'entites entraine des trous dans
c             la numerotation et tout le but des programmes utcnxx est
c             de supprimer ces trous.
c             donc quand on fait tab(i) = tab(ancent(i)), on est certain
c             que tab(ancent(i)) n'a pas encore ete modifie dans
c             la boucle sur i croissant. c'est donc bien la bonne 
c             valeur, c'est-a-dire l'ancienne, que l'on met a la
c             nouvelle place.
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tritet . e/s .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e/s .nouvtf*4. code des 4 triangles des tetraedres        .
c . hettet . e/s . nouvte . historique de l'etat des tetraedres        .
c . famtet . e/s . nouvte . famille des tetraedres                     .
c . filtet . e/s . nouvte . premier fils des tetraedres                .
c . pertet . e/s . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . anctet . e   . nouvte . anciens numeros des tetraedres conserves   .
c . noutet . e   .0:nouvte. nouveaux numeros des tetraedres conserves  .
c . noutri . e   .0:nouvtr. nouveaux numeros des triangles conserves   .
c . nbtere . e   .   1    . nombre de tetraedres restants              .
c . ancfil . aux . nbteto . ancien tableau des fils                    .
c . ancper . aux . nbteto . ancien tableau des peres                   .
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
#include "nouvnb.h"
#include "nombte.h"
c
c 0.3. ==> arguments
c
      integer tritet(nouvtf,4), cotrte(nouvtf,4)
      integer hettet(nouvte),   famtet(nouvte)
      integer pertet(nouvte),   filtet(nouvte)
      integer anctet(nouvte), noutet(0:nouvte)
      integer noutri(0:nouvtr)
      integer ancfil(nbteto), ancper(nbteto)
c
      integer nbtere
c
c 0.4. ==> variables locales
c
      integer letetr, letria
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c a partir de maintenant, on travaille avec le nouveau nombre d'entites
c du maillage, i.e. uniquement le nombre d'entites n'ayant pas ete
c marquees "a disparaitre". il faut neanmoins conserver le nombre
c d'entites avant disparitions pour pouvoir, a la fin des remises a
c jours des numerotations, compacter les tableaux en memoire.
c
c====
c 1. remise a jour des numerotations des tetraedres
c====
c
c 1.1. ==> stockage des anciens tableaux de filiation
c
      do 11 ,letetr = 1 , nbteto
        ancfil(letetr) = filtet(letetr)
        ancper(letetr) = pertet(letetr)
   11 continue
c
c 1.2. ==> transfert
c
      do 12 , letetr = 1 , nbtere
c
        if ( anctet(letetr).ne.letetr ) then
c
          do 121, letria = 1 , 4
           tritet(letetr,letria) = noutri(tritet(anctet(letetr),letria))
           cotrte(letetr,letria) = cotrte(anctet(letetr),letria)
  121    continue
c
          hettet(letetr) = hettet(anctet(letetr))
          famtet(letetr) = famtet(anctet(letetr))
c
        else
c
          do 122, letria = 1 , 4
           tritet(letetr,letria) = noutri(tritet(anctet(letetr),letria))
  122     continue
c
        endif
c
        filtet(letetr) = noutet(ancfil(anctet(letetr)))
        pertet(letetr) = noutet(ancper(anctet(letetr)))
c
   12 continue
c
      end
