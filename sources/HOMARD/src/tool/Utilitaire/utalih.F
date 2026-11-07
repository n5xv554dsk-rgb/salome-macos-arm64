      subroutine utalih ( nohind, codent, nbento, nbcomp, motaux,
     >                    adenin, adensu,
     >                    ulsort, langue, codret)
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
c    UTilitaire - ALlocation de l'Indicateur HOMARD
c    --           --              -          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nohind . e   .  ch8   . nom de l'objet contenant l'indicateur      .
c . codent . e   .   1    . code des entites au sens homard            .
c . nbento . e   .   1    . nombre total d'entites                     .
c . nbcomp . e   .   1    . nombre de composantes du champ             .
c . motaux . e   .  ch8   . branche de l'indicateur                    .
c . adenin .  s  .    1   . adresse de l'indicateur                    .
c . adensu .  s  .    1   . adresse du support de l'indicateur         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'UTALIH' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "enti01.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer codent, nbento, nbcomp
      integer adenin, adensu
c
      character*8 motaux
      character*8 nohind
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre0
      integer iaux
c
      character*14 saux14
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(/,''.. Allocation de la branche sur les : '',a,/,37(''-''))'
c
      texte(2,4) =
     > '(/,''.. Allocation of branch for : '',a,/,24(''-''))'
c
c====
c 2. Allocation
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,codent)
#endif
c
      saux14 = nohind//'.'//suffix(1,codent)(1:5)
c
      call gmaloj ( saux14, ' ', 0, iaux, codre1 )
      call gmecat ( saux14, 1, nbento, codre2 )
      call gmecat ( saux14, 2, nbcomp, codre3 )
      if ( codent.lt.0 ) then
        iaux = 1
      else
        iaux = 2
      endif
      call gmecat ( saux14, 3, iaux, codre4 )
      call gmaloj ( saux14//'.Support', ' ',  nbento, adensu, codre5 )
      iaux = nbento*nbcomp
      call gmaloj ( saux14//'.'//motaux, ' ', iaux, adenin, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5, codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5, codre6 )
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,4)) mess14(langue,3,codent)
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
