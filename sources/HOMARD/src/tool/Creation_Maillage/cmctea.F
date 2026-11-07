      subroutine cmctea ( aretet, famtet,
     >                    hettet, filtet, pertet,
     >                    naret1, naret2, naret3, naret4,
     >                    naret5, naret6,
     >                    nupere, famill, nutetr )
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
c    Creation du Maillage - Creation d'un TEtraedre par ses Aretes
c    -           -          -             --                -
c ______________________________________________________________________
c
c but : creation effective d'un tetraedre etant donne :
c       - le numero du tetraedre
c       - les numero globaux des aretes
c       - le numero du pere
c       - la famille a attribuer
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . aretet . es  .nouvta*6. numeros des 6 aretes des tetraedres        .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . nareti . e   . 1      . arete de numero local i dans le tetraedre  .
c . nupere . e   . 1      . numero du pere du tetraedre                .
c . famill . e   . 1      . famille a attribuer au tetraedre           .
c . nutetr . e   . 1      . numero du tetraedre a creer                .
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
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer aretet(nouvta,6), famtet(nouvte)
      integer hettet(nouvte), filtet(nouvte), pertet(nouvte)
      integer naret1, naret2, naret3, naret4
      integer naret5, naret6
      integer nupere, famill, nutetr
c
c 0.4. ==> variables locales
c
      integer iaux
c ______________________________________________________________________
c
c====
c 1. creation effective d'un tetraedre
c====
c
#ifdef _DEBUG_HOMARD_
#include "impr03.h"
      write (1,90015) 'Tetraedre', nutetr,
     >                ', aretes', naret1, naret2, naret3, naret4,
     >                            naret5, naret6
#endif
      iaux = nutetr - nouvtf
      aretet(iaux,1) = naret1
      aretet(iaux,2) = naret2
      aretet(iaux,3) = naret3
      aretet(iaux,4) = naret4
      aretet(iaux,5) = naret5
      aretet(iaux,6) = naret6
c
      famtet(nutetr) = famill
c
      hettet(nutetr) = 5500
      filtet(nutetr) = 0
      pertet(nutetr) = nupere
c
      end
