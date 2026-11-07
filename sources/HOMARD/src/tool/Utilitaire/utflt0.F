      subroutine utflt0 ( somare, aretes,
     >                    champ, flux,
     >                    ulsort, langue, codret )
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
c    UTilitaire - FLux a travers un Triangle - 0
c    --           --                -          -
c Calcule le flux d'une grandeur a travers un triangle par la somme
c de la grandeur le long des aretes
c Variante de utfltr quand le champ est deja une circulation
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c . aretes . e   .   3    . numeros des 3 aretes du triangle           .
c . champ  . e   .   3    . champ sur les 3 aretes du triangle         .
c . flux   .  s  . 1      . le flux                                    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'UTFLT0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer somare(2,*)
      integer aretes(3)
c
      double precision champ(3)
      double precision flux
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer orient(3)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. Orientations des aretes
c====
c
      call utorat ( somare,
     >              aretes(1), aretes(2), aretes(3),
     >              orient(1), orient(2), orient(3) )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '. Aretes      ', aretes
      write (ulsort,90002) '. Orientations', orient
#endif
c
c====
c 3. Parcours des aretes
c====
c
      flux = 0.d0
c
      do 31 , iaux = 1 , 3
c
cgn      write (ulsort,90004) 'champ',champ(iaux),orient(iaux)*champ(iaux)
        flux = flux + dble(orient(iaux))*champ(iaux)
c
   31 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) '==> Flux', flux
#endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
