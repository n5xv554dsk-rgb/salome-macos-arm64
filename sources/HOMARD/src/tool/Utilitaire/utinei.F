      subroutine utinei ( modhom,
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
c    UTilitaire - INitialisation des Elements Ignores
c    --           --                 -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . modhom . e   .    1   . mode de fonctionnement de homard           .
c .        .     .        . -5 : executable du suivi de frontiere      .
c .        .     .        . -4 : exec. de l'interface apres adaptation .
c .        .     .        . -3 : exec. de l'interface avant adaptation .
c .        .     .        . -2 : executable de l'information           .
c .        .     .        . -1 : executable de l'adaptation            .
c .        .     .        .  0 : executable autre                      .
c .        .     .        .  1 : homard pur                            .
c .        .     .        .  2 : information                           .
c .        .     .        .  3 : modification de maillage sans adaptati.
c .        .     .        .  4 : interpolation de la solution          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : presence de quadrangles                .
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
      parameter ( nompro = 'UTINEI' )
c
#include "nblang.h"
#include "consts.h"
c
#include "referx.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "refere.h"
#include "refert.h"
c
c 0.3. ==> arguments
c
      integer modhom
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. a priori, tout va bien
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      codret = 0
c
c====
c 2. Controle des compatibilites
c    . pour l'adaptation, on accepte tout sauf les pyramides
c====
c
      if ( modhom.ne.1 .and. modhom.ne.-1 ) then
c
        tyeref(tyhpy1) = 0
        tyeref(tyhpy2) = 0
c
      endif
c
c===
c 3. bilan
c===
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
