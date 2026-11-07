      subroutine utre02 ( typenh, option, norenu,
     >                    nbena0, nbent0, nbenac, nbento,
     >                    adenho, adenca,
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
c    UTilitaire - REnumerotation - 02
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
c . option . e   .   1    . option de pilotage des tailles a modifier  .
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : branche HOMARD                        .
c .        .     .        .  3 : branche Calcul                        .
c . norenu . e   . char8  . nom de la branche Renum du maillage HOMARD .
c . nbena0 . e   .    1   . ancien nbr d'el utiles et contenant entites.
c . nbent0 . e   .    1   . ancien nombre d'entites                    .
c . nbenac . e   .    1   . nombre d'entites actives                   .
c . nbento . e   .    1   . nombre d'entites                           .
c . adenho .   s .    1   . adresse de la numerotation dans HOMARD     .
c . adenca .   s .    1   . adresse de la numerotation dans le calcul  .
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
      parameter ( nompro = 'UTRE02' )
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
      integer nbena0, nbent0, nbenac, nbento
      integer adenho, adenca
c
      character*8 norenu
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2
      integer codre0
      integer un
c
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
     > '(''Modification des renumerotations relatives aux '',a)'
      texte(1,5) = '(''Option :'',i10)'
c
      texte(2,4) = '(''Modifications of renumbering for '',a)'
      texte(2,5) = '(''Option :'',i10)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,texte(langue,5)) option
#endif
c
c 1.2. ==> types d'entites
c
      saux03 = '.'//suffix(3,typenh)(1:2)
c
      codret = 0
c
c====
c 2. Modification
c====
c
      if ( option.ne.0 ) then
c
      un = 1
      iaux = 3 + 2*typenh
c
c 2.1. ==> Branche HOMARD
c
      if ( mod(option,2).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      saux06 = 'nb'//suffix(2,typenh)(1:2)//'a0'
      write(ulsort,*) saux06, ' = ', nbena0
      saux06 = 'nb'//suffix(2,typenh)(1:2)//'ac'
      write(ulsort,*) saux06, ' = ', nbenac
#endif
c
      call gmecat ( norenu, iaux  , nbenac, codre1 )
      call gmmod ( norenu//saux03//'HOMARD',
     >             adenho, nbena0, nbenac, un, un, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 2.2. ==> Branche Calcul
c
      if ( mod(option,3).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      saux06 = 'nb'//suffix(2,typenh)(1:2)//'t0'
      write(ulsort,*) saux06, ' = ', nbent0
      saux06 = 'nb'//suffix(2,typenh)(1:2)//'to'
      write(ulsort,*) saux06, ' = ', nbento
#endif
c
      call gmecat ( norenu, iaux+1, nbento, codre1 )
      call gmmod ( norenu//saux03//'Calcul',
     >             adenca, nbent0, nbento, un, un, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      endif
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write(ulsort,texte(langue,4)) mess14(langue,3,typenh)
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
