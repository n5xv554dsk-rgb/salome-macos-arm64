      subroutine utcnar ( somare, hetare, famare, decare,
     >                    filare, merare, arehom, np2are,
     >                    aretri, arequa,
     >                    posifa, facare,
     >                    ancare, nouare, nounoe,
     >                    nbtrre, nbqure, nbarre,
     >                    ancfil, ancmer )
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
c    UTilitaire - Compactage de la Numerotation des ARetes
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
c . somare . e/s .2*nouvar. numeros des extremites d'arete             .
c . hetare . e/s . nouvar . historique de l'etat des aretes            .
c . decare . e/s .0:nbarto. table des decisions sur les aretes         .
c . famare . e/s . nouvar . famille des aretes                         .
c . filare . e/s . nouvar . premiere fille des aretes                  .
c . merare . e/s . nouvar . mere des aretes                            .
c . arehom . e   . nouvar . ensemble des aretes homologues             .
c . np2are . e/s . nouvar . numero des noeuds p2 milieux d'aretes      .
c . aretri . e/s .nouvtr*3. numeros des 3 aretes des triangles         .
c . arequa . e/s .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . posifa . e/s .0:nbarto. pointeur sur tableau facare                .
c . facare . e/s . nbfaar . liste des faces contenant une arete        .
c . ancare . e   . nouvar . anciens numeros des aretes conservees      .
c . nouare . e   .0:nouvar. nouveaux numeros des aretes conservees     .
c . nounoe . e   .0:nouvno. nouveaux numeros des noeuds conserves      .
c . nbtrre . e   .   1    . nombre de triangles restants               .
c . nbqure . e   .   1    . nombre de quadrangles restants             .
c . nbarre . e   .   1    . nombre d'aretes restantes                  .
c . ancfil . aux . nbarto . ancien tableau des filles                  .
c . ancmer . aux . nbarto . ancien tableau des meres                   .
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
#include "nombar.h"
#include "envca1.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer nbtrre, nbqure, nbarre
c
      integer somare(2,nouvar), hetare(nouvar)
      integer famare(nouvar), decare(0:nbarto)
c
      integer filare(nouvar), merare(nouvar)
      integer arehom(nouvar)
      integer np2are(nouvar)
c
      integer aretri(nouvtr,3), arequa(nouvqu,4)
      integer posifa(0:nbarto), facare(nbfaar)
c
      integer ancare(nouvar), nouare(0:nouvar)
      integer nounoe(0:nouvno)
c
      integer ancfil(nbarto), ancmer(nbarto)
c
c 0.4. ==> variables locales
c
      integer larete
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
c 1. remise a jour des numerotations des aretes
c    reconstruction des correspondances directes
c====
c
c 1.1. ==> stockage des anciens tableaux de filiation
c
      do 11 ,larete = 1 , nbarto
        ancfil(larete) = filare(larete)
        ancmer(larete) = merare(larete)
   11 continue
c
c 1.2. ==> transfert
c
      do 12 , larete = 1 , nbarre
c
        somare(1,larete) = nounoe(somare(1,ancare(larete)))
        somare(2,larete) = nounoe(somare(2,ancare(larete)))
c
        if ( ancare(larete).ne.larete ) then
c
          hetare(larete) = hetare(ancare(larete))
          famare(larete) = famare(ancare(larete))
          decare(larete) = decare(ancare(larete))
c
        endif
c
        filare(larete) = nouare(ancfil(ancare(larete)))
        merare(larete) = nouare(ancmer(ancare(larete)))
c
        if ( degre .eq. 2 ) then
          np2are(larete) = nounoe(np2are(ancare(larete)))
        endif
c
   12 continue
c
c 1.3. ==> traitement des homologues
c
      if ( homolo.ge.2 ) then
c
        do 13 , larete = 1 , nbarre
          if ( arehom(ancare(larete)) .ge. 0 ) then
            arehom(larete) =   nouare(arehom(ancare(larete)))
          else
            arehom(larete) = - nouare(abs(arehom(ancare(larete))))
          endif
   13   continue
c
      endif
c
c====
c 2. reconstruction des correspondances inverses
c====
c
      call utfaa1 ( nbarre, nbtrre, nbqure,
     >              nouvar, nouvtr, nouvqu,
     >              aretri, arequa,
     >              nbfaar, posifa )
c
      call utfaa2 ( nbtrre, nbqure,
     >              nouvtr, nouvqu,
     >              aretri, arequa,
     >              nbfaar, posifa, facare )
c
      end
