      subroutine utad13 ( option, ncfami,
     >                    adnufa, adnofa,
     >                    adgrpo, adgrtl, adgrtb,
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
c    UTilitaire - ADresses - phase 13
c    --           --               --
c ______________________________________________________________________
c   Recuperation des adresses des tableaux pour MC_Fam
c   Remarque : le code de retour en entree ne doit pas etre ecrase
c              brutalement ; il doit etre cumule avec les operations
c              de ce programme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . option de pilotage des adresses a recuperer.
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .   2 : numero des familles                  .
c .        .     .        .   3 : nom des familles                     .
c .        .     .        .   5 : groupes                              .
c . ncfami . e   . char8  . nom de la branche MC_Fam                   .
c . adnufa .  s  .   1    . numero des familles                        .
c . adnofa .  s  .   1    . nom des familles                           .
c . adgrpo .  s  .   1    . pointeurs des groupes                      .
c . adgrtl .  s  .   1    . taille des groupes                         .
c . adgrtb .  s  .   1    . table des groupes                          .
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
      parameter ( nompro = 'UTAD13' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 ncfami
c
      integer option
      integer adnufa, adnofa
      integer adgrpo, adgrtl, adgrtb
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
      integer codre1, codre2, codre3
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
      texte(1,4) = '(''Adresses relatives aux entites'')'
      texte(1,5) = '(''Option :'',i10)'
c
      texte(2,4) = '(''Adresses for entities'')'
      texte(2,5) = '(''Option :'',i10)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) option
      call dmflsh (iaux)
#endif
c
c====
c 2. recuperation des adresses
c====
c
      if ( option.gt.0 ) then
c
c 2.1. ==> Numero des familles
c
      if ( mod(option,2).eq.0 ) then
c
        call gmadoj ( ncfami//'.Numero', adnufa, iaux, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
c 2.2. ==> Nom des familles
c
      if ( mod(option,3).eq.0 ) then
c
        call gmadoj ( ncfami//'.Nom', adnofa, iaux, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
c 2.3. ==> Groupes
c
      if ( mod(option,5).eq.0 ) then
c
        call gmadoj ( ncfami//'.Groupe.Pointeur', adgrpo, iaux, codre1 )
        call gmadoj ( ncfami//'.Groupe.Taille',  adgrtl, iaux, codre2 )
        call gmadoj ( ncfami//'.Groupe.Table',  adgrtb, iaux, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
