      subroutine utcntr ( option,
     >                    hettri, famtri, decfac, nivtri,
     >                    filtri, pertri,
     >                    pentri, nintri, homtri,
     >                    ntreca, ntreho,
     >                    anctri, noutri, nouare, aretri,
     >                    nbtrre,
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
c    UTilitaire - Compactage de la Numerotation des TRiangles
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
c .        .     .        .  5 : homologues                            .
c .        .     .        .  7 : renumerotation                        .
c .        .     .        . 11 : relation volu/face pour l'extrusion   .
c . hettri . e/s . nouvtr . historique de l'etat des triangles         .
c . famtri . e/s . nouvtr . famille des triangles                      .
c . decfac . e/s . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . nivtri . e/s . nouvtr . niveau des triangles                       .
c . filtri . e/s . nouvtr . premier fils des triangles                 .
c . pertri . e/s . nouvtr . pere des triangles                         .
c . pentri . e/s . nouvtr . pentaedre sur un triangle de la face avant .
c . nintri . e/s . nouvtr . noeud interne au triangle                  .
c . homtri . e/s . nouvtr . ensemble des triangles homologues          .
c . anctri . e   . nouvtr . anciens numeros des triangles conserves    .
c . noutri . e   .0:nouvtr. nouveaux numeros des triangles conserves   .
c . nouare . e   .0:nouvar. nouveaux numeros des aretes conservees     .
c . aretri . e/s .nouvtr*3. numeros des 3 aretes des triangles         .
c . nbtrre . e   .   1    . nombre de triangles restants               .
c . ancfil . aux . nbtrto . ancien tableau des fils                    .
c . ancper . aux . nbtrto . ancien tableau des peres                   .
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
      character*6 nompro
      parameter ( nompro = 'UTCNTR' )
c
c 0.2. ==> communs
c
#include "nomber.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbtrre
c
      integer decfac(-nbquto:nbtrto)
      integer hettri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer filtri(nouvtr), pertri(nouvtr)
      integer pentri(nouvtr), nintri(nouvtr), homtri(nouvtr)
      integer ntreca(nouvtr), ntreho(retrac)
      integer anctri(nouvtr), noutri(0:nouvtr)
      integer nouare(0:nouvar),  aretri(nouvtr,3)
      integer ancfil(nbtrto), ancper(nbtrto)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer letria, larete
c
c 0.5. ==> initialisations
c
c====
c 1. messages
c====
c
#include "impr03.h"
c
cgn        print 90002,nompro//' - option',option
cgn        print 90002,'nbtrre',nbtrre
cgn        print 90002,'retrac',retrac
cgn        print 91020,anctri
c
c ______________________________________________________________________
c
c a partir de maintenant, on travaille avec le nouveau nombre d'entites
c du maillage, i.e. uniquement le nombre d'entites n'ayant pas ete
c marquees "a disparaitre". il faut neanmoins conserver le nombre
c d'entites avant disparitions pour pouvoir, a la fin des remises a
c jours des numerotations, compacter les tableaux en memoire.
c
c Remarque : si on est parti d'un macro-maillage non conforme,
c            certains triangles ont des peres adoptifs de numero
c            negatif. Il ne faut pas transferer leur numero
c            Le cas des peres negatif parce que quadrangle de conformite
c            n'existe plus a ce stade : ces triangles ont ete detruits
c            en amont
c
c====
c 1. remise a jour des numerotations des triangles
c    reconstruction des correspondances directes
c====
c
c 1.1. ==> stockage des anciens tableaux de filiation
c
      do 11 ,letria = 1 , nbtrto
        ancfil(letria) = filtri(letria)
        ancper(letria) = pertri(letria)
   11 continue
c
c 1.2. ==> transfert
c
      do 12 , letria = 1 , nbtrre
c
        do 121, larete = 1 , 3
          aretri(letria,larete) = nouare(aretri(anctri(letria),larete))
  121   continue
c
        if ( anctri(letria).ne.letria ) then
c
          hettri(letria) = hettri(anctri(letria))
          famtri(letria) = famtri(anctri(letria))
          decfac(letria) = decfac(anctri(letria))
          nivtri(letria) = nivtri(anctri(letria))
c
        endif
c
        filtri(letria) = noutri(ancfil(anctri(letria)))
        if ( ancper(anctri(letria)).gt.0 ) then
          pertri(letria) = noutri(ancper(anctri(letria)))
        else
          pertri(letria) = ancper(anctri(letria))
        endif
c
   12 continue
c
c 1.3. ==> traitement des noeuds internes
c
      if ( mod(option,2).eq.0 ) then
c
        do 13 , letria = 1 , nbtrre
c
          if ( anctri(letria).ne.letria ) then
            nintri(letria) = nintri(anctri(letria))
          endif
c
   13   continue
c
      endif
c
c 1.4. ==> traitement des homologues
c
      if ( mod(option,5).eq.0 ) then
c
        do 14 , letria = 1 , nbtrre
          if ( homtri(anctri(letria)) .ge. 0 ) then
            homtri(letria) =   noutri(homtri(anctri(letria)))
          else
            homtri(letria) = - noutri(abs(homtri(anctri(letria))))
          endif
   14   continue
c
      endif
c
c 1.5. ==> traitement des renumerotations
c
      if ( mod(option,7).eq.0 ) then
c
        do 151 , iaux = 1 , retrac
          ntreho(iaux) = 0
  151   continue
c
        do 152 , letria = 1 , nbtrre
c
          if ( anctri(letria).ne.letria ) then
            ntreca(letria) = ntreca(anctri(letria))
          endif
          if ( ntreca(letria).gt.0 ) then
            ntreho(ntreca(letria)) = letria
          endif
c
  152   continue
c
      endif
c
c 1.6. ==> traitement des pentaedres pour l'extrusion
c
      if ( mod(option,11).eq.0 ) then
c
        do 16 , letria = 1 , nbtrre
c
          if ( anctri(letria).ne.letria ) then
            pentri(letria) = pentri(anctri(letria))
          endif
c
   16   continue
c
      endif
c
      end
