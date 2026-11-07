      subroutine utcnqu ( option,
     >                    hetqua, famqua, decfac, nivqua,
     >                    filqua, perqua,
     >                    hexqua, ninqua,
     >                    nqueca, nqueho,
     >                    ancqua, nouqua, nouare, arequa,
     >                    nbqure,
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
c    UTilitaire - Compactage de la Numerotation des QUadrangles
c    --           -                -                --
c ______________________________________________________________________
c
c  remarque hyper-importante :
c             quelle que soit l'entite (noeud, arete, triangle,
c             quadrangle ou tetraedre) son ancien numero est toujours
c             superieur ou egal a son numero courant : ancent(i) >= i.
c             En effet, la suppression d'entites entraine des trous dans
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
c .        .     .        .  3 : noeuds internes aux quadrangles       .
c .        .     .        .  5 : homologues                            .
c .        .     .        .  7 : renumerotation                        .
c .        .     .        . 11 : relation volu/face pour l'extrusion   .
c . hetqua . e/s . nouvqu . historique de l'etat des quadrangles       .
c . famqua . e/s . nouvqu . famille des quadrangles                    .
c . decfac . e/s . -nbquto. decision sur les faces (tria. + qua.)      .
c .        .     . :nbtrto.                                            .
c . nivqua . e/s . nouvqu . niveau des quadrangles                     .
c . filqua . e/s . nouvqu . premier fils des quadrangles               .
c . perqua . e/s . nouvqu . pere des quadrangles                       .
c . hexqua . e/s . nbquto . hexaedre sur un quadrangle de la face avant.
c . ninqua . e/s . nouvqu . noeud interne au quadrangle                .
c . ancqua . e   . nouvqu . anciens numeros des quadrangles conserves  .
c . nouqua . e   .0:nouvqu. nouveaux numeros des quadrangles conserves .
c . nouare . e   .0:nouvar. nouveaux numeros des aretes conservees     .
c . arequa . e/s .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . nbqure . e   .   1    . nombre de quadrangles restants             .
c . ancfil . aux . nbquto . ancien tableau des fils                    .
c . ancper . aux . nbquto . ancien tableau des peres                   .
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
      parameter ( nompro = 'UTCNQU' )
#endif
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
      integer nbqure
c
      integer decfac(-nbquto:nbtrto)
      integer hetqua(nouvqu), famqua(nouvqu)
      integer nivqua(nouvqu)
      integer filqua(nouvqu), perqua(nouvqu)
      integer hexqua(nouvqu), ninqua(nouvqu)
      integer nqueca(nouvqu), nqueho(requac)
      integer ancqua(nouvqu), nouqua(0:nouvqu)
      integer nouare(0:nouvar), arequa(nouvqu,4)
      integer ancfil(nbquto), ancper(nbquto)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lequad, larete
c
c 0.5. ==> initialisations
c
c====
c 1. messages
c====
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
        write (1,*) 'entree de ',nompro
        do 1105 , lequad = 1 , nouvqu
          write (1,90001) 'quadrangle', lequad,
     >    arequa(lequad,1), arequa(lequad,2),
     >    arequa(lequad,3), arequa(lequad,4)
 1105   continue
#endif
c ______________________________________________________________________
c
cgn      do 300 , lequad = 1 , nbqure
cgn        if ( ancqua(lequad).eq.1 .or. ancqua(lequad).eq.3 .or.
cgn     >       ancqua(lequad).eq.4 .or. ancqua(lequad).eq.5 .or.
cgn     >       ancqua(lequad).eq.6) then
cgn       write(1,*),'ancqua(',lequad,') =',ancqua(lequad)
cgn       write(1,*),'filqua(ancqua(',lequad,')) =',
cgn     >filqua(ancqua(lequad)),nouqua(filqua(ancqua(lequad)))
cgn       write(1,*),'perqua(ancqua(',lequad,')) =',
cgn     >perqua(ancqua(lequad)),nouqua(perqua(ancqua(lequad)))
cgn       write(1,*),' '
cgn        endif
cgn  300 continue
c
c a partir de maintenant, on travaille avec le nouveau nombre d'entites
c du maillage, i.e. uniquement le nombre d'entites n'ayant pas ete
c marquees "a disparaitre". il faut neanmoins conserver le nombre
c d'entites avant disparitions pour pouvoir, a la fin des remises a
c jours des numerotations, compacter les tableaux en memoire.
c
c Remarque : si on est parti d'un macro-maillage non conforme,
c            certains quadrangles ont des peres adoptifs de numero
c            negatif. Il ne faut pas transferer leur numero
c
c====
c 1. remise a jour des numerotations des quadrangles
c    reconstruction des correspondances directes
c====
c
c 1.1. ==> stockage des anciens tableaux de filiation
c
      do 11 ,lequad = 1 , nbquto
        ancfil(lequad) = filqua(lequad)
        ancper(lequad) = perqua(lequad)
   11 continue
c
c 1.2. ==> transfert
c
      do 12 , lequad = 1 , nbqure
c
        do 121, larete = 1 , 4
          arequa(lequad,larete) = nouare(arequa(ancqua(lequad),larete))
  121   continue
c
        if ( ancqua(lequad).ne.lequad ) then
c
          hetqua(lequad)  = hetqua(ancqua(lequad))
          famqua(lequad)  = famqua(ancqua(lequad))
cgn          print *,'-lequad, -ancqua(lequad)',-lequad, -ancqua(lequad)
          decfac(-lequad) = decfac(-ancqua(lequad))
          nivqua(lequad)  = nivqua(ancqua(lequad))
c
        endif
c
        filqua(lequad) = nouqua(ancfil(ancqua(lequad)))
        if ( ancper(ancqua(lequad)).gt.0 ) then
          perqua(lequad) = nouqua(ancper(ancqua(lequad)))
        else
          perqua(lequad) = ancper(ancqua(lequad))
        endif
c
   12 continue
c
c 1.3. ==> traitement des noeuds internes
c
      if ( mod(option,3).eq.0 ) then
c
        do 13 , lequad = 1 , nbqure
c
          if ( ancqua(lequad).ne.lequad ) then
            ninqua(lequad) = ninqua(ancqua(lequad))
          endif
c
   13   continue
c
      endif
c
c 1.4. ==> traitement des homologues
c
cgn      if ( mod(option,5).eq.0 ) then
cgn      do 301 , lequad = 1 , nbqure
cgn        if ( lequad.eq.1 .or. lequad.eq.4 .or.
cgn     >       lequad.eq.3 .or. lequad.eq.6 .or.
cgn     >       lequad.eq.5) then
cgn       write(1,*),'ancqua(',lequad,') =',ancqua(lequad)
cgn       write(1,*),'filqua(',lequad,') =',filqua(lequad)
cgn       write(1,*),'perqua(',lequad,') =',perqua(lequad)
cgn       write(1,*),' '
cgn        endif
cgn  301 continue
cgn      endif
c
c 1.5. ==> traitement des renumerotations
c
      if ( mod(option,7).eq.0 ) then
c
        do 151 , iaux = 1 , requac
          nqueho(iaux) = 0
  151   continue
c
        do 152 , lequad = 1 , nbqure
c
          if ( ancqua(lequad).ne.lequad ) then
            nqueca(lequad) = nqueca(ancqua(lequad))
          endif
          nqueho(nqueca(lequad)) = lequad
c
  152   continue
c
      endif
c
c 1.6. ==> traitement des hexaedres pour l'extrusion
c
      if ( mod(option,11).eq.0 ) then
c
        do 16 , lequad = 1 , nbqure
c
          if ( ancqua(lequad).ne.lequad ) then
            hexqua(lequad) = hexqua(ancqua(lequad))
          endif
c
   16   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
        write (1,*) 'sortie de ',nompro
        do 1103 , lequad = 1 , nouvqu
          write (1,90001) 'quadrangle', lequad,
     >    arequa(lequad,1), arequa(lequad,2),
     >    arequa(lequad,3), arequa(lequad,4)
 1103   continue
#endif
      end
