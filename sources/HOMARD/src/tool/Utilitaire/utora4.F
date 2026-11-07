      subroutine utora4 ( orient,
     >                    a0, a1, a2, a3, a4,
     >                    coonoe, somare,
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
c    UTilitaire - ORientation d'Aretes d'un paquet de 4
c    --           --            -                     -
c
c  Determine dans quel sens le paquet des aretes (a1,a2,a3,a4) tourne
c  relativement a l'arete a0
c
c  Si a0 s'enfonce dans le plan courant :
c           positif                      negatif
c            a1                             a1
c             .                              .
c             .                              .
c             .                              .
c            a0                             a0
c           .   .                          .   .
c         .       .                      .       .
c       .           .                  .           .
c     a3             a2              a2            a3
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . orient .  s  .   4    . orient(1) = 1, puis numeros des aretes dans.
c .        .     .        . le sens positif                            .
c . a0     . e   .   1    . arete orientant                            .
c . a1-4   . e   .   1    . aretes a placer                            .
c . coonoe . e   .nbnoto*3. coordonnees des noeuds                     .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'UTORA3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer orient(4)
      integer a0, a1, a2, a3, a4
      integer somare(2,nbarto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
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
      orient(1) = 1
c
c====
c 2. Positionnement des 3 premieres aretes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTORA3 123', nompro
#endif
      call utora3 ( iaux,
     >              a0, a1, a2, a3,
     >              coonoe, somare,
     >              ulsort, langue, codret )
c
c====
c 3. Si les 3 premieres aretes tournent dans le sens positif, 3 cas :
c          a1                       a1                       a1
c           .   a4                   .                        .
c           .  .                     .                        .
c           . .                      .                        .
c          a0                       a0               a4......a0
c         .   .                    ..  .                    .   .
c       .       .                . .     .                .       .
c     .           .            .  .        .            .           .
c   a3             a2        a3  a4         a2        a3            a2
c====
c
      if ( iaux.ge.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTORA3 124', nompro
#endif
        call utora3 ( jaux,
     >                a0, a1, a2, a4,
     >                coonoe, somare,
     >                ulsort, langue, codret )
c
        if ( jaux.le.0 ) then
c
          orient(2) = 4
          orient(3) = 2
          orient(4) = 3
c
        else
c
          orient(2) = 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTORA3 234', nompro
#endif
          call utora3 ( kaux,
     >                  a0, a2, a3, a4,
     >                  coonoe, somare,
     >                  ulsort, langue, codret )
c
          if ( kaux.le.0 ) then
            orient(3) = 4
            orient(4) = 3
          else
            orient(3) = 3
            orient(4) = 4
          endif
c
        endif
c
c====
c 4. Si les 3 premieres aretes tournent dans le sens negatif, 3 cas :
c          a1                       a1                       a1
c           .   a4                   .                        .
c           .  .                     .                        .
c           . .                      .                        .
c          a0                       a0               a4......a0
c         .   .                    ..  .                    .   .
c       .       .                . .     .                .       .
c     .           .            .  .        .            .           .
c   a2             a3        a2  a4         a3        a2            a3
c====
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTORA3 134', nompro
#endif
        call utora3 ( jaux,
     >                a0, a1, a3, a4,
     >                coonoe, somare,
     >                ulsort, langue, codret )
c
        if ( jaux.le.0 ) then
c
          orient(2) = 4
          orient(3) = 3
          orient(4) = 2
c
        else
c
          orient(2) = 3
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTORA3 234', nompro
#endif
          call utora3 ( kaux,
     >                  a0, a2, a3, a4,
     >                  coonoe, somare,
     >                  ulsort, langue, codret )
c
          if ( kaux.ge.0 ) then
            orient(3) = 4
            orient(4) = 2
          else
            orient(3) = 2
            orient(4) = 4
          endif
c
        endif
c
      endif
c
c====
c 5. la fin
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
