      subroutine utashe ( lehexa,
     >                    nbquto, nbhecf, nbheca,
     >                    somare, arequa,
     >                    quahex, coquhe, arehex,
     >                    listar, listso )
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
c   UTilitaire :  Aretes et Sommets d'un HExaedre
c   --            -         -            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . numero du hexaedre a analyser              .
c . nbquto . e   .  1     . nombre total de quadrangles                .
c . nbhecf . e   .  1     . nombre d'hexaedres decrits par faces       .
c . nbheca . e   .  1     . nombre d'hexaedres decrits par aretes      .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . listar .  s  .  12    . les 12 aretes de l'hexaedre                .
c . listso .  s  .   8    . liste des sommets de l'hexaedre            .
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
      integer lehexa
      integer nbquto, nbhecf, nbheca
c
      integer somare(2,*)
      integer arequa(nbquto,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
c
      integer listar(12), listso(8)
c
c 0.4. ==> variables locales
c
      integer iaux
c ______________________________________________________________________
c
#include "impr03.h"
c
c====
c 1. Les aretes de l'hexaedre
c====
c
      if ( lehexa.le.nbhecf ) then
c
        call utarhe ( lehexa,
     >                nbquto, nbhecf,
     >                arequa, quahex, coquhe,
     >                listar )
c
      else
c
        do 11 , iaux = 1 , 12
          listar(iaux) = arehex(lehexa-nbhecf,iaux)
   11   continue
c
      endif
cgn      if ( lehexa.le.-210803 ) then
cgn      write(1,*) 'listar en sortie de utashe'
cgn      write(1,91010) listar
cgn      endif
c
c====
c 2. les sommets de l'hexaedre
c====
c
      call utsohe ( somare, listar, listso )
c
      end
