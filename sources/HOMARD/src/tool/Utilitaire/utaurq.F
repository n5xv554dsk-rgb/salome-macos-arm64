      subroutine utaurq ( modhom, eleinc,
     >                    nocman,
     >                    nbelig,
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
c    UTilitaire - AUtorisation de Raffinement des Quadrangles
c    --           --              -               -
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
c . eleinc . e   .   1    . elements incompatibles                     .
c .        .     .        . 0 : on bloque s'il y en a                  .
c .        .     .        . 1 : on les ignore s'il y en a              .
c . nocman . e   . char*8 . nom de l'objet maillage calcul iteration n .
c . nbelig .  s  .    1   . nombre d'elements elimines                 .
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
      parameter ( nompro = 'UTAURQ' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer modhom, eleinc
      integer nbelig
c
      character*8 nocman
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer adnomb
      integer sdimca, mdimca
      integer degre, mailet, maconf, homolo, hierar, nbnomb
      integer nbpyra
c
      character*7 saux07
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
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
      texte(1,4) = '(/,''Maillage de calcul : '',a)'
      texte(1,5) = '(''Mode HOMARD :'',i3)'
      texte(1,6) = '(''Ce maillage comporte'',i8,1x,a)'
      texte(1,7) = '(''Elimination de'',i8,1x,a)'
      texte(1,8) =
     > '(5x,''Nombre de '',a,'' a '',a,'' :'',i8)'
      texte(1,9) =
     > '(''Cela est incompatible avec ce raffinement.'',/)'
      texte(1,10) ='(/,''On '',a,'' les mailles incompatibles.'')'
c
      texte(2,4) = '(/,''Calculation mesh : '',a)'
      texte(2,5) = '(''HOMARD mode :'',i3)'
      texte(2,6) = '(''This mesh contains'',i8,1x,a)'
      texte(2,7) = '(''Elimination of'',i8,1x,a)'
      texte(2,8) = '(5x,''Number of '',a,'' '',a,'' :'',i8)'
      texte(2,9) = '(''It is forbidden with this refinement.'')'
      texte(2,10) ='(/,''Incompatible meshes are '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) modhom
      if ( eleinc.eq.0 ) then
        write (ulsort,texte(langue,10)) 'bloque'
      else
        write (ulsort,texte(langue,10)) 'ignore'
      endif
#endif
c
c====
c 2. Recherche du nombre de pyramides
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMC', nompro
#endif
      call utnomc ( nocman,
     >              sdimca, mdimca,
     >               degre, mailet, maconf, homolo, hierar,
     >              nbnomb,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret)
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ncnomb, adnomb, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      nbpyra = imem(adnomb+19)
c
      endif
c
c====
c 3. determination du nombre de mailles a eliminer
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. determination ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nbpyra, mess14(langue,3,5)
#endif
c
      if ( modhom.eq.1 .or. modhom.eq.-1 ) then
        nbelig = nbpyra
      else
        nbelig = 0
      endif
c
      endif
c
c====
c 4. diagnostic
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. diagnostic ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nbelig, mess14(langue,3,5)
#endif
c
      if ( nbelig.ne.0 ) then
c
c 4.1. ==> messages
c
        if ( eleinc.eq.0 ) then
          saux07 = 'bloquer'
        else
          saux07 = 'ignorer'
        endif
c
        write (ulsort,texte(langue,8))mess14(langue,3,5),saux07,nbelig
        write (ulsort,*) ' '
c
c 4.2. ==> Si on bloque en presence de telles mailles
c
        if ( eleinc.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,4)) nocman
#endif
          write (ulsort,texte(langue,9))
          codret = 2
c
        endif
c
      endif
c
      endif
c
c===
c 5. la fin
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
