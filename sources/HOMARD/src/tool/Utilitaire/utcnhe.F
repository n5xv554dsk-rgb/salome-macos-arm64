      subroutine utcnhe ( quahex, coquhe, hethex, famhex,
     >                    filhex, perhex, ninhex,
     >                    anchex, nouhex,
     >                    nouqua, nbhere,
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
c    UTilitaire - Compactage de la Numerotation des Hexaedres
c    --           -                -                --
c ______________________________________________________________________
c
c  remarque hyper-importante :
c             quelle que soit l'entite (noeud, arete, quadrangle ou
c             hexaedre) son ancien numero est toujours superieur ou
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
c . quahex . e/s .nouvhf*6. numeros des 4 quadrangles des hexaedres    .
c . coquhe . e/s .nouvhf*6. code des 4 quadrangles des hexaedres       .
c . hethex . e/s . nouvhe . historique de l'etat des hexaedres         .
c . famhex . e/s . nouvhe . famille des hexaedres                      .
c . filhex . e/s . nouvhe . premier fils des hexaedres                 .
c . perhex . e/s . nouvhe . pere des hexaedres                         .
c . ninhex . e/s . nouvhe . noeud interne a l'hexaedre                 .
c . anchex . e   . nouvhe . anciens numeros des hexaedres conserves    .
c . nouhex . e   .0:nouvhe. nouveaux numeros des hexaedres conserves   .
c . nouqua . e   .0:nouvqu. nouveaux numeros des quadrangles conserves .
c . nbhere . e   .   1    . nombre de hexaedres restants               .
c . ancfil . aux . nbheto . ancien tableau des fils                    .
c . ancper . aux . nbheto . ancien tableau des peres                   .
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
#include "envca1.h"
#include "nouvnb.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer quahex(nouvhf,6), coquhe(nouvhf,6)
      integer hethex(nouvhe),   famhex(nouvhe)
      integer perhex(nouvhe),   filhex(nouvhe), ninhex(nouvhe)
      integer anchex(nouvhe), nouhex(0:nouvhe)
      integer nouqua(0:nouvqu)
      integer ancfil(nbheto), ancper(nbheto)
c
      integer nbhere
c
c 0.4. ==> variables locales
c
      integer lehexa, lequad
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
#include "impr03.h"
c====
c 1. stockage des anciens tableaux de filiation
c====
c
      do 11 ,lehexa = 1 , nbheto
        ancfil(lehexa) = filhex(lehexa)
        ancper(lehexa) = perhex(lehexa)
   11 continue
c
c====
c 2. transfert
c====
c
      do 21 , lehexa = 1 , nbhere
c
        if ( anchex(lehexa).ne.lehexa ) then
c
          do 211, lequad = 1 , 6
           quahex(lehexa,lequad) = nouqua(quahex(anchex(lehexa),lequad))
           coquhe(lehexa,lequad) = coquhe(anchex(lehexa),lequad)
  211    continue
c
          hethex(lehexa) = hethex(anchex(lehexa))
          famhex(lehexa) = famhex(anchex(lehexa))
c
        else
c
          do 212, lequad = 1 , 6
           quahex(lehexa,lequad) = nouqua(quahex(anchex(lehexa),lequad))
  212     continue
c
        endif
c
        filhex(lehexa) = nouhex(ancfil(anchex(lehexa)))
        perhex(lehexa) = nouhex(ancper(anchex(lehexa)))
c
   21 continue
c
c====
c 3. traitement des eventuels noeuds internes
c====
c
      if ( mod(mailet,5).eq.0 ) then
c
        do 31 , lehexa = 1 , nbhere
c
          if ( anchex(lehexa).ne.lehexa ) then
            ninhex(lehexa) = ninhex(anchex(lehexa))
          endif
c
   31   continue
c
      endif
c
      end
