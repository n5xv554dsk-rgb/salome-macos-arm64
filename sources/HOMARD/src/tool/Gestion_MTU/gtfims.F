      subroutine gtfims ( numero )
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
c                                       premiere creation le 30.12.88 gn
c ______________________________________________________________________
c
c    'Gestion du Temps : FIn de Mesure de Section'
c     -          -       --     -         -
c
c ______________________________________________________________________
c
c Remarque : en encadrant ce sous-programme par les appels a la fonction
c            de base dmtemp, on ne prend pas en compte les temps
c            necessaires a ce sous-programme lui-meme. Cela occasionne
c            obligatoirement une erreur si on compare le temps total
c            a la somme des temps particuliers, mais cela permet d'avoir
c            une bonne precision dans la mesure de chaque section.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numero . e   .    1   . numero de la section a mesurer             .
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
      parameter ( nompro = 'GTFIMS' )
c
#include "genbla.h"
#include "gtnbse.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer numero
c
c 0.4. ==> variables locales
c
      double precision tuser, tsyst
c
      integer iaux
      integer ulsort, langue
c
#include "gtdita.h"
c
      integer nbmess
      parameter ( nbmess = 10 )
c
      character*80 texte(nblang,nbmess)
c
c====
c 1. initialisation des messages
c====
c
#include "impr01.h"
c
c====
c 2. mesure du temps ecoule depuis le dernier appel a dmtemp
c====
c
      call dmtemp ( tuser, tsyst )
c
c====
c 3. recuperation de l'information
c====
c
      call gttabl ( 1, nbsep1, nbrapp, ouvert, titsec, tpscpu )
c
      langue = nbrapp(-3)
      ulsort = nbrapp(0)
c
c====
c 4. cumul des temps
c====
c
c 4.1. ==> on incremente tous les compteurs de temps de calcul
c         correspondants a des sections ouvertes
c
      do 4 , iaux = 1 , nbsep1
c
        if ( ouvert (iaux) ) then
          tpscpu (iaux) = tpscpu (iaux) + tuser
        endif
c
    4 continue
c
c 4.2. ==> on cumule le temps d'attente systeme
c
      tpscpu(0) = tpscpu(0) + tsyst
c
c====
c 5. gestion de la section
c====
c
c 5.1. ==> verification du numero
c
      if ( numero.lt.1 .or. numero.gt.nbsect ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,51000) numero, nbsect
        iaux = 1
        call gtstop ( nompro , ulsort , iaux )
      endif
c
51000 format(
     >  'On veut finir la mesure de temps pour la section',i9,'.',
     >/,'C''est impossible. Il faut un numero entre 1 et',i9,'.',/)
c
c 5.2. ==> etait-ce deja ouvert ?
c
      if ( .not. ouvert(numero) ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,52000) numero
        iaux = 1
        call gtstop ( nompro , ulsort , iaux )
      endif
c
52000 format(
     >  'On veut finir la mesure de temps pour la section',i8,'.',
     >/,'Or elle n''a jamais ete commencee ...',/)
c
c 5.3. ==> c'est bon, on peut fermer
c
      ouvert (numero) = .false.
c
c====
c 6. on archive l'information
c====
c
      call gttabl ( 0, nbsep1, nbrapp, ouvert, titsec, tpscpu )
c
c====
c 7. nouvel appel a dmtemp pour ignorer le plus possible le temps
c    mis par ce programme de mesure
c====
c
      call dmtemp ( tuser, tsyst )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
