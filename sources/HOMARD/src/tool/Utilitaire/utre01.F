      subroutine utre01 ( typenh, option,
     >                    norenu, nbelem, nbento,
     >                    adenho, adenca, adenic,
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
c    UTilitaire - REnumerotation - 01
c    --           --               --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : segments                             .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . option . e   .   1    . option de pilotage                         .
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : nombre d'entites actives              .
c .        .     .        .  3 : nombre d'entites                      .
c .        .     .        .  5 : branche HOMARD                        .
c .        .     .        .  7 : branche Calcul                        .
c .        .     .        . 11 : branche InfoSupE associee             .
c . norenu . e   . char8  . nom de la branche Renum du maillage HOMARD .
c . nbelem . e   .    1   . nbr d'elements utiles et contenant entites .
c . nbento . e   .    1   . nombre d'entites                           .
c . adenho .   s .    1   . adresse de la numerotation dans HOMARD     .
c . adenca .   s .    1   . adresse de la numerotation dans le calcul  .
c . adenic .   s .    1   . adresse de la numerotation dans le calcul  .
c .        .     .        . supplementaire (InfoSupE)                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 6 : probleme d'ecriture                    .
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
      parameter ( nompro = 'UTRE01' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "enti01.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh, option
      integer nbelem, nbento
      integer adenho, adenca, adenic
c
      character*8 norenu
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4
      integer codre0
c
      character*1 saux01
      character*3 saux03
#ifdef _DEBUG_HOMARD_
      character*6 saux06
#endif
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Allocations des renumerotations relatives aux '',a)'
      texte(1,5) = '(''Attributs impossibles a ecrire.'')'
      texte(1,6) = '(''Allocations impossibles.'')'
c
      texte(2,4) = '(''Allocations of renumbering for '',a)'
      texte(2,5) = '(''Attributes cannot be written.'')'
      texte(2,6) = '(''Allocations cannot be done.'')'
c
#ifdef _DEBUG_HOMARD_
      if ( typenh.gt.0 ) then
c
      write(ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write(ulsort,*) 'nbelem = ', nbelem
      saux06 = 'nb'//suffix(2,typenh)(1:2)//'to'
      write(ulsort,*) saux06, ' = ', nbento
c
      endif
#endif
c
c 1.2. ==> types d'entites
c
      saux03 = '.'//suffix(3,typenh)(1:2)
cgn      if (saux03(2:3).eq.'Ar' )then
cgn        write(ulsort,*) 'glop'
cgn      endif
c
c====
c 2. Les attributs
c====
c
      iaux = 3 + 2*typenh
c
      if ( mod(option,2).eq.0 ) then
        call gmecat ( norenu, iaux  , nbelem, codre1 )
      else
        codre1 = 0
      endif
c
      if ( mod(option,3).eq.0 ) then
        call gmecat ( norenu, iaux+1, nbento, codre2 )
      else
        codre2 = 0
      endif
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
      if ( codret.ne.0 ) then
        codret = 1
      endif
c
c====
c 3. Allocations
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Allocations ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(option,5).eq.0 .and. nbelem.ne.0 ) then
        call gmaloj ( norenu//saux03//'HOMARD', ' ',
     >                nbelem, adenho, codre1 )
      else
        codre1 = 0
      endif
c
      if ( mod(option,7).eq.0 .and. nbento.ne.0 ) then
        call gmaloj ( norenu//saux03//'Calcul', ' ',
     >                nbento, adenca, codre2 )
      else
        codre2 = 0
      endif
c
      if ( mod(option,11).eq.0 .and. nbento.ne.0 ) then
        write(saux01,'(i1)') typenh+2
        call gmaloj ( norenu//'.InfoSupE.Tab'//saux01, ' ',
     >                nbento, adenic, codre3 )
        call gmecat ( norenu//'.InfoSupE', typenh+2, nbento, codre4 )
      else
        codre3 = 0
        codre4 = 0
      endif
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
      if ( codret.ne.0 ) then
        codret = 2
      endif
c
      endif
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
      write(ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write(ulsort,texte(langue,4+codret))
      call gmprsx (nompro,norenu)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
