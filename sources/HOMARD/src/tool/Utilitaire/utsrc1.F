      subroutine utsrc1 ( nbtafo, nbento,
     >                    profil, vafott, vafosc )
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
c    UTilitaire - Solution - Renumeration du Calcul - option 1
c    --           -          -               -               -
c  remarque : utsrc1 et utsrc3 sont des clones
c             1 : double precision
c             3 : entier
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbtafo . e   .    1   . nombre de tableaux de la fonction          .
c . nbento . e   .    1   . nombre d'entites                           .
c . profil . e   . nbento . pour chaque entite :                       .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vafott .   a . nbtafo*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
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
      integer profil(nbento)
c
      double precision vafott(nbtafo,*)
      double precision vafosc(nbtafo,*)
c
c 0.4. ==> variables locales
c
      integer nuv
      integer iaux, jaux
c ______________________________________________________________________
c
c====
c 1. on compacte
c====
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (1,*)'UTSRC1'
      write (1,90002)' nbtafo', nbtafo
      write (1,90002)' nbento', nbento
#endif
      do 11 , nuv = 1, nbtafo
cgn      write (1,*)'Composante', nuv
        jaux = 0
        do 111, iaux = 1, nbento
cgn      write (1,90112) 'profil',iaux, profil(iaux)
          if ( profil(iaux).gt.0 ) then
            jaux = jaux + 1
            vafosc(nuv,jaux) = vafott(nuv,iaux)
cgn      write (1,90124) ' vafott',nuv,iaux,vafott(nuv,iaux)
          endif
  111   continue
   11 continue
c
      end
