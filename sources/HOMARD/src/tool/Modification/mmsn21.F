      subroutine mmsn21 ( disnoe,
     >                    ancnoe, nounoe, hetnoe,
     >                    nouare,
     >                    nbnore, nbp2re, nbimre )
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
c    Modification de Maillage - Suppression des Noeuds P2 - phase 1
c    -               -          -               -       -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . disnoe .   a . nbnoto . indicateurs de disparition des noeuds      .
c . ancnoe .   s . nbnoto . anciens numeros des noeuds conserves       .
c . nounoe .   s .0:nbnoto. nouveaux numeros des noeuds conserves      .
c . hetnoe . e/s  . nbnoto . historique de l'etat des noeuds           .
c . nouare .   s .0:nbarto. nouveaux numeros des aretes conservees     .
c . nbnore .   s .   1    . nombre de noeuds restants                  .
c . nbp2re .   s .   1    . nombre de noeuds p2 restants               .
c . nbimre .   s .   1    . nombre de noeuds internes restants         .
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
cc      character*6 nompro
cc      parameter ( nompro = 'MMSN21' )
c
c 0.2. ==> communs
c
#include "nombar.h"
#include "nombno.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer disnoe(nbnoto)
      integer ancnoe(nbnoto), nounoe(0:nbnoto)
      integer hetnoe(nbnoto)
      integer nbnore, nbp2re, nbimre
      integer nouare(0:nbarto)
c
c 0.4. ==> variables locales
c
      integer iaux
c ______________________________________________________________________
c
c====
c 1. on marque les noeuds P2 comme etant ceux a suprimer
c====
c
      do 11 , iaux = 1 , nbnoto
c
        if ( mod(hetnoe(iaux),10).eq.2 ) then
          disnoe(iaux) = 1
        else
          disnoe(iaux) = 0
        endif
c
   11 continue
c
c====
c 2. suppression des noeuds
c====
c
      call utsuno ( nbnoto, nouvno, disnoe,
     >              hetnoe, ancnoe, nounoe,
     >              nbnore, nbp2re, nbimre )
c
c====
c 3. on garde toutes les aretes
c====
c
      do 31 , iaux = 0 , nbarto
c
        nouare(iaux) = iaux
c
   31 continue
c
      end
