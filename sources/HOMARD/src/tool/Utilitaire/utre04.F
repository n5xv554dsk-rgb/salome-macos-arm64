      subroutine utre04 ( typenh, option,
     >                    norenu,
     >                    lgenin, adenin,
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
c    UTilitaire - REnumerotation - 04
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
c . option . e   .   1    . option de pilotage des adresses a chercher .
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        . 11 : branche InfoSupE associee             .
c .        .     .        . Si option<0, on controle avant de chercher .
c .        .     .        . les adresses que le tableau est vraiment   .
c .        .     .        . alloue ; il faut donc decoder les attributs.
c .        .     .        . avant les adresses                         .
c . norenu . e   . char8  . nom de la branche Renum du maillage HOMARD .
c . lgenin .   s .    1   . longueur de la numer. init dans le calcul n.
c . adenin .   s .    1   . adresse de la numer. init dans le calcul n .
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
      parameter ( nompro = 'UTRE04' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh, option
      integer lgenin, adenin
c
      character*8 norenu
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      character*1 saux01
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
     > '(''Adresses des renumerotations relatives aux '',a)'
      texte(1,5) = '(''Option :'',i10)'
      texte(1,10) = '(''Erreur dans l''''adresse de InfoSupe'')'
c
      texte(2,4) = '(''Adresses of renumbering for '',a)'
      texte(2,5) = '(''Option :'',i10)'
      texte(2,10) = '(''Error in address of InfoSupe'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,texte(langue,5)) option
#endif
c
c 1.2. ==> types d'entites
c
      codret = 0
c
      if ( option.ne.0 ) then
c
c====
c 2. Recuperation
c====
c
      iaux = 3 + 2*typenh
c
      if ( mod(option,11).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmliat ( norenu//'.InfoSupE', typenh+2, lgenin, codret )
c
        endif
c
        if ( lgenin.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        write(saux01,'(i1)') typenh+2
        call gmadoj ( norenu//'.InfoSupE.Tab'//saux01,
     >                adenin, jaux, codret )
c
        endif
c
        endif
c
        if ( codret.ne.0 ) then
          codret = 5
        endif
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
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,texte(langue,5+codret))
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
