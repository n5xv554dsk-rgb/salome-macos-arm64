      subroutine utcnpe ( facpen, cofape, hetpen, fampen,
     >                    filpen, perpen, ancpen, noupen,
     >                    noutri, nouqua, nbpere,
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
c    UTilitaire - Compactage de la Numerotation des Pentaedres
c    --           -                -                --
c ______________________________________________________________________
c
c  remarque hyper-importante :
c             quelle que soit l'entite (noeud, arete, tria/quad ou
c             pentaedre) son ancien numero est toujours superieur ou
c             egal a son numero courant : ancent(i) >= i. En effet, la
c             suppression d'entites entraine des trous dans
c             la numerotation et tout le but des programmes utcnxx est
c             de supprimer ces trous.
c             donc quand on fait tab(i) = tab(ancent(i)), on est certain
c             que tab(ancent(i)) n'a pas encore ete modifie dans
c             la boucle sur i croissant. c'est donc bien la bonne
c             valeur, c'est-a-dire l'ancienne, que l'on met a la
c             nouvelle place.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . facpen . e/s .nouvpf*5. numeros des 5 faces des pentaedres         .
c . cofape . e/s .nouvpf*5. code des 5 faces des pentaedres            .
c . hetpen . e/s . nouvpe . historique de l'etat des pentaedres        .
c . fampen . e/s . nouvpe . famille des pentaedres                     .
c . filpen . e/s . nouvpe . premier fils des pentaedres                .
c . perpen . e/s . nouvpe . pere des pentaedres                        .
c . ancpen . e   . nouvpe . anciens numeros des pentaedres conserves   .
c . noupen . e   .0:nouvpe. nouveaux numeros des pentaedres conserves  .
c . noutri . e   .0:nouvtr. nouveaux numeros des triangles conserves   .
c . nouqua . e   .0:nouvqu. nouveaux numeros des quadrangles conserves .
c . nbpere . e   .   1    . nombre de pentaedres restants              .
c . ancfil . aux . nbpeto . ancien tableau des fils                    .
c . ancper . aux . nbpeto . ancien tableau des peres                   .
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
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer facpen(nouvpf,5), cofape(nouvpf,5)
      integer hetpen(nouvpe),   fampen(nouvpe)
      integer perpen(nouvpe),   filpen(nouvpe)
      integer ancpen(nouvpe), noupen(0:nouvpe)
      integer noutri(0:nouvtr)
      integer nouqua(0:nouvqu)
      integer ancfil(nbpeto), ancper(nbpeto)
c
      integer nbpere
c
c 0.4. ==> variables locales
c
      integer lepent
      integer iaux
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
c 1. remise a jour des numerotations des pentaedres
c====
c
c 1.1. ==> stockage des anciens tableaux de filiation
c
      do 11 ,lepent = 1 , nbpeto
        ancfil(lepent) = filpen(lepent)
        ancper(lepent) = perpen(lepent)
   11 continue
c
c 1.2. ==> transfert
c
      do 12 , lepent = 1 , nbpere
c
        if ( ancpen(lepent).ne.lepent ) then
c
          do 1211, iaux = 1, 2
           facpen(lepent,iaux) = noutri(facpen(ancpen(lepent),iaux))
           cofape(lepent,iaux) = cofape(ancpen(lepent),iaux)
 1211    continue
          do 1212, iaux = 3, 5
           facpen(lepent,iaux) = nouqua(facpen(ancpen(lepent),iaux))
           cofape(lepent,iaux) = cofape(ancpen(lepent),iaux)
 1212    continue
c
          hetpen(lepent) = hetpen(ancpen(lepent))
          fampen(lepent) = fampen(ancpen(lepent))
c
        else
c
          do 1221, iaux = 1, 2
           facpen(lepent,iaux) = noutri(facpen(ancpen(lepent),iaux))
 1221     continue
          do 1222, iaux = 3, 5
           facpen(lepent,iaux) = nouqua(facpen(ancpen(lepent),iaux))
 1222     continue
c
        endif
c
        filpen(lepent) = noupen(ancfil(ancpen(lepent)))
        perpen(lepent) = noupen(ancper(ancpen(lepent)))
c
   12 continue
c
      end
