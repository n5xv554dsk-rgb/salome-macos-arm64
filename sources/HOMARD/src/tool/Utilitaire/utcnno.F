      subroutine utcnno ( option,
     >                    coonoe,
     >                    hetnoe, famnoe, arenoe, noehom,
     >                    nnoeca, nnoeho,
     >                    nintri,
     >                    ninqua,
     >                    nouare, nounoe, nbnold )
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
c    UTilitaire - Compactage de la Numerotation des NOeuds
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
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . option de pilotage des compactages         .
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : noeuds internes aux triangles         .
c .        .     .        .  3 : noeuds internes aux quadrangles       .
c .        .     .        .  5 : homologues                            .
c .        .     .        .  7 : renumerotation                        .
c . coonoe . e/s .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . e/s . nouvno . historique de l'etat des noeuds            .
c . famnoe . e/s . nouvno . caracteristiques des noeuds                .
c . arenoe . e/s . nouvno . arete liee a un nouveau noeud              .
c . nintri . e/s . nouvtr . noeud interne au triangle                  .
c . ninqua . e/s . nouvqu . noeud interne au quadrangle                .
c . nouare . e   .0:nouvar. nouveaux numeros des aretes conservees     .
c . nounoe . e   .0:nouvno. nouveaux numeros des noeuds conserves      .
c . nbnold . e   .   1    . nombre de noeuds anciens                   .
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
#ifdef _DEBUG_HOMARD_
      character*6 nompro
      parameter ( nompro = 'UTCNNO' )
#endif
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer option
c
      double precision coonoe(nouvno,sdim)
      integer hetnoe(nouvno), famnoe(nouvno)
      integer arenoe(nouvno), noehom(nouvno)
      integer nnoeca(nouvtr), nnoeho(*)
      integer nintri(nouvtr)
      integer ninqua(nouvqu)
      integer nouare(0:*)
      integer nounoe(0:*)
c
      integer nbnold
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lenoeu
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
c 1. remise a jour des numerotations des noeuds
c====
c
      do 10 , lenoeu = 1 , nbnold
c
        if ( nounoe(lenoeu).ne.0 ) then
c
          if ( nounoe(lenoeu).ne.lenoeu ) then
c
            do 11, iaux = 1 , sdim
              coonoe(nounoe(lenoeu),iaux) = coonoe(lenoeu,iaux)
   11       continue
c
            hetnoe(nounoe(lenoeu)) = hetnoe(lenoeu)
            famnoe(nounoe(lenoeu)) = famnoe(lenoeu)
c
          endif
c
          arenoe(nounoe(lenoeu)) = nouare(arenoe(lenoeu))
c
        endif
c
   10 continue
c
c====
c 2. traitement des noeuds internes
c====
c
      if ( mod(option,2).eq.0 ) then
c
        do 21 , iaux = 1 , nouvtr
c
          if ( nintri(iaux).ne.0 ) then
            nintri(iaux) = nounoe(nintri(iaux))
          endif
c
   21   continue
c
      endif
c
      if ( mod(option,3).eq.0 ) then
c
        do 22 , iaux = 1 , nouvqu
c
          if ( ninqua(iaux).ne.0 ) then
            ninqua(iaux) = nounoe(ninqua(iaux))
          endif
c
   22   continue
c
      endif
c
c====
c 3. Traitements des homologues
c====
c
      if ( mod(option,5).eq.0 ) then
c
        do 30 , lenoeu = 1 , nbnold
c
          if ( nounoe(lenoeu).ne.0 ) then
c
            if ( noehom(lenoeu) .ge. 0 ) then
              noehom(nounoe(lenoeu)) =   nounoe(noehom(lenoeu))
            else
              noehom(nounoe(lenoeu)) = - nounoe(abs(noehom(lenoeu)))
            endif
c
          endif
c
   30   continue
c
      endif
c
c====
c 4. traitement des renumerotations
c====
c
      if ( mod(option,7).eq.0 ) then
c
        do 40 , lenoeu = 1 , nbnold
c
          if ( nounoe(lenoeu).ne.0 ) then
            nnoeca(nounoe(lenoeu)) = nnoeca(lenoeu)
            nnoeho(nnoeca(lenoeu)) = lenoeu
          endif
c
   40   continue
c
      endif
c
      end
