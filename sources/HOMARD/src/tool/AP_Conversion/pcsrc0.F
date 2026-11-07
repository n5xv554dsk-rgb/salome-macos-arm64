      subroutine pcsrc0 ( nbtafo, nbento,
     >                    profho, nensho,
     >                    vafoho, vafosc )
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
c    aPres adaptation - conversion de Solution -
c     -                               -
c                       Renumeration du Calcul - option 0
c                       -               -               -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbtafo . e   .    1   . nombre de tableaux de la fonction          .
c . nbento . e   .    1   . nombre d'entites homard                    .
c . profho . e   . nbento . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . nensho . e   . nbento . numero des entites en sortie pour homard   .
c . vafoho . e   . nbtafo*. variables numerotation homard              .
c .        .     . nbento .                                            .
c . vafosc .  s  . nbtafo*. variables en sortie pour le calcul         .
c .        .     .   *    .                                            .
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
      integer nbtafo, nbento
      integer profho(nbento)
      integer nensho(nbento)
c
      double precision vafoho(nbtafo,*)
      double precision vafosc(nbtafo,*)
c
c 0.4. ==> variables locales
c
      integer nuv
      integer iaux, jaux
c ______________________________________________________________________
c
c====
c 1. on trie les valeurs dans la numerotation du calcul en sortie
c====
c
#include "impr03.h"
c
      do 11 , nuv = 1, nbtafo
c
        jaux = 0
        do 111 , iaux = 1, nbento
          if ( profho(iaux).gt.0 ) then
            jaux = jaux + 1
            vafosc(nuv,jaux) = vafoho(nuv,nensho(iaux))
          endif
cgn          if ( vafoho(nuv,nensho(iaux)).gt.1.d5 ) then
cgn          write(1,90014) iaux,vafoho(nuv,nensho(iaux))
cgn          endif
  111   continue
c
   11 continue
c
      end
