      subroutine utre03 ( typenh, option,
     >                    norenu,
     >                    nbenac, nbento, adenho, adenca,
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
c    UTilitaire - REnumerotation - 03
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
c .        .     .        .  2 : nombre d'entites actives              .
c .        .     .        .  3 : nombre d'entites                      .
c .        .     .        .  5 : branche HOMARD                        .
c .        .     .        .  7 : branche Calcul                        .
c .        .     .        . Si option<0, on controle avant de chercher .
c .        .     .        . les adresses que le tableau est vraiment   .
c .        .     .        . alloue ; il faut donc decoder les attributs.
c .        .     .        . avant les adresses                         .
c . norenu . e   . char8  . nom de la branche Renum du maillage HOMARD .
c . nbenac . es  .    1   . nombre d'entites actives                   .
c . nbento . es  .    1   . nombre d'entites                           .
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
      parameter ( nompro = 'UTRE03' )
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
      integer nbenac, nbento
      integer adenho, adenca
c
      character*8 norenu
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
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
     > '(''Adresses des renumerotations relatives aux '',a)'
      texte(1,5) = '(''Option :'',i10)'
      texte(1,6) = '(''Erreur dans le decodage de nbenac'')'
      texte(1,7) = '(''Erreur dans le decodage de nbento'')'
      texte(1,8) = '(''Erreur dans l''''adresse de EnHOMARD'')'
      texte(1,9) = '(''Erreur dans l''''adresse de EnCalcul'')'
c
      texte(2,4) = '(''Adresses of renumbering for '',a)'
      texte(2,5) = '(''Option :'',i10)'
      texte(2,6) = '(''Error while uncoding nbenac'')'
      texte(2,7) = '(''Error while uncodin nbento'')'
      texte(2,8) = '(''Error in address of EnHOMARD'')'
      texte(2,9) = '(''Error in address of EnCalcul'')'
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
c 2. Recuperation
c====
c
      if ( option.ne.0 ) then
c
      iaux = 3 + 2*typenh
c
c 2.1. ==> Nombre d'entites actives
c
      if ( codret.eq.0 ) then
c
      if ( mod(option,2).eq.0 .or.
     >     mod(option,5).eq.0 .or. mod(option,7).eq.0 ) then
c
      call gmliat ( norenu, iaux  , nbenac, codret )
      if ( codret.ne.0 ) then
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      saux06 = 'nb'//suffix(2,typenh)(1:2)//'ac'
      write (ulsort,*) '==> ', saux06, ' = ', nbenac
      endif
#endif
c
      endif
c
      endif
c
c 2.2. ==> Nombre d'entites
c
      if ( codret.eq.0 ) then
c
      if ( mod(option,3).eq.0 ) then
c
      call gmliat ( norenu, iaux+1, nbento, codret )
      if ( codret.ne.0 ) then
        codret = 2
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      saux06 = 'nb'//suffix(2,typenh)(1:2)//'to'
      write (ulsort,*) '==> ', saux06, ' = ', nbento
      endif
#endif
c
      endif
c
      endif
c
c 2.3. ==> Branche HOMARD
c
      if ( codret.eq.0 ) then
c
      if ( mod(option,5).eq.0 ) then
c
      if ( option.gt.0 .or.
     >     ( option.lt.0 .and. nbenac.gt.0 ) ) then
        call gmadoj ( norenu//saux03//'HOMARD', adenho, jaux, codret )
        if ( codret.ne.0 ) then
          codret = 3
        endif
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      saux06 = 'ad'//suffix(2,typenh)(1:2)//'ho'
      write (ulsort,*) '==> ', saux06, ' = ', adenho
      endif
#endif
      endif
c
      endif
c
      endif
c
c 2.4. ==> Branche Calcul
c
      if ( codret.eq.0 ) then
c
      if ( mod(option,7).eq.0 ) then
c
      jaux = 0
      if ( option.gt.0 ) then
        jaux = 1
      elseif ( mod(option,2).lt.0 .and.
     >         nbento.gt.0 .and. nbenac.gt.0 ) then
        jaux = 1
      elseif ( option.lt.0 .and. nbenac.gt.0 ) then
        jaux = 1
      endif
c
      if ( jaux.gt.0 ) then
        call gmadoj ( norenu//saux03//'Calcul', adenca, jaux, codret )
        if ( codret.ne.0 ) then
          codret = 4
        endif
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      saux06 = 'ad'//suffix(2,typenh)(1:2)//'ca'
      write (ulsort,*) '==> ', saux06, ' = ', adenca
      endif
#endif
      endif
c
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
