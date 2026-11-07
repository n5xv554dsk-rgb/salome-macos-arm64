      subroutine utad03 ( option, nhenti,
     >                    nbenci, nbenrc, numead,
     >                    adenra, adenrb,
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
c    UTilitaire - ADresses - phase 03
c    --           --               --
c ______________________________________________________________________
c   Recuperation d'informations pour le recollement non conforme
c   d'une entite HOM_Enti
c   Remarque : le code de retour en entree ne doit pas etre ecrase
c              brutalement ; il doit etre cumule avec les operations
c              de ce programme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . option de pilotage des infos. a recuperer  .
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : nombre de non conformites initiales   .
c .        .     .        .  3 : nbre d'entites / recollement unitaire .
c .        .     .        .  5 : numero de la mere adoptive            .
c .        .     .        .  7 : aretes recouvrant une autre           .
c .        .     .        . 11 : aretes recouvertes par une autre      .
c . nhenti . e   . char8  . nom de l'objet decrivant l'entite          .
c . nbenci .   s .    1   . nombre de non conformites initiales        .
c . nbenrc .   s .    1   . nombre d'entites par recollement unitaire  .
c . numead .   s .   1    . numero de la mere adoptive                 .
c . adenra .   s .  1     . liste des entites recouvrant une autre     .
c . adenrb .   s .  1     . liste des entites recouvertes par une autre.
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'UTAD03' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nhenti
c
      integer option
      integer nbenci, nbenrc, numead
      integer adenra, adenrb
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codava
      integer codre0
      integer codre1, codre2, codre3, codre4, codre5
      logical existe
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
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Adresses relatives aux recollements'')'
      texte(1,5) = '(''Option :'',i10)'
      texte(1,6) = '(''Codes de retour'',20i3)'
c
      texte(2,4) = '(''Adresses for glue'')'
      texte(2,5) = '(''Option :'',i10)'
      texte(2,6) = '(''Error codes'',20i3)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) option
      call gmprsx (nompro,nhenti//'.Recollem')
      call dmflsh (iaux)
#endif
c
      codava = codret
      codret = 0
c
c====
c 2. Structure generale
c====
c
      call gmobal ( nhenti//'.Recollem', codre0 )
      if ( codre0.eq.0 ) then
        nbenci = 0
        nbenrc = -1
        numead = 0
        existe = .false.
      elseif ( codre0.eq.1 ) then
        existe = .true.
      else
        nbenci = -1
        existe = .false.
        codret = max ( abs(codre0), codret )
      endif
c
c====
c 3. Nombre de non conformites initiales
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Nbr non conformites init ; codret = ', codret
#endif
c
      if ( option.gt.0 ) then
c
      if ( mod(option,2).eq.0 ) then
c
        if ( existe ) then
c
          call gmliat ( nhenti//'.Recollem', 1, nbenci, codre1 )
c
          codret = max ( abs(codre1), codret )
c
        endif
c
      endif
c
      endif
c
c====
c 4. Recherche des informations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Recherche informations ; codret = ', codret
#endif
c
      if ( option.gt.0 ) then
c
c 4.1. ==> Nombre d'entites par recollement unitaire
c
      if ( mod(option,3).eq.0 ) then
c
        if ( existe ) then
c
          call gmliat ( nhenti//'.Recollem', 2, nbenrc, codre2 )
c
          codret = max ( abs(codre2), codret )
c
        else
c
          if ( mod(option,2).ne.0 ) then
            codret = max ( 41, codret )
          endif
c
        endif
c
      endif
c
c 4.2. ==> Numero de la mere adoptive
c          Remarque : si la structure n'existe pas, on renvoie 0 pour
c          ne pas perturber le reste
c
      if ( mod(option,5).eq.0 ) then
c
        if ( existe ) then
c
          call gmliat ( nhenti//'.Recollem', 3, numead, codre3 )
c
          codret = max ( abs(codre3), codret )
c
        else
c
          numead = 0
c
        endif
c
      endif
c
c 4.3. ==> liste des entites recouvrant une autre
c
      if ( mod(option,7).eq.0 ) then
c
        if ( existe ) then
c
          call gmadoj ( nhenti//'.Recollem.ListeA',
     >                  adenra, iaux, codre4 )
c
          codret = max ( abs(codre4), codret )
c
        else
c
          if ( mod(option,2).ne.0 ) then
            codret = max ( 43, codret )
          endif
c
        endif
c
      endif
c
c 4.4. ==> Liste des entites recouvertes par une autre
c
      if ( mod(option,11).eq.0 ) then
c
        if ( existe ) then
c
          call gmadoj ( nhenti//'.Recollem.ListeB',
     >                  adenrb, iaux, codre5 )
c
          codret = max ( abs(codre5), codret )
c
        else
c
          if ( mod(option,2).ne.0 ) then
            codret = max ( 44, codret )
          endif
c
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
      write (ulsort,texte(langue,5)) option
      write (ulsort,texte(langue,2)) codret
      if ( existe ) then
        write (ulsort,texte(langue,6)) codre0,
     >                            codre1, codre2, codre3, codre4, codre5
c
      else
c
      codret = codava
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
