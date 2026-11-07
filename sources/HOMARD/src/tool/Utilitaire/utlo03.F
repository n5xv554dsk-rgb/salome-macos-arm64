      subroutine utlo03 ( motcle, option, ulsort, langue, codret )
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
c   UTilitaire : Lectures des Options - 03
c   --           -            -         --
c ______________________________________________________________________
c
c but : decoder le texte relatif au type de raffinement ou deraffinement
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . motcle . e   . char*8 . mot-cle a decoder                          .
c . option .  s  .   1    . A. raffinement :                           .
c .        .     .        . -1 : uniforme                              .
c .        .     .        .  0 : pas de raffinement                    .
c .        .     .        .  1 : libre (defaut)                        .
c .        .     .        .  2 : libre homogene en type d'element      .
c .        .     .        . B. deraffinement :                         .
c .        .     .        . -1 : uniforme                              .
c .        .     .        .  0 : pas de deraffinement                  .
c .        .     .        .  1 : libre (defaut)                        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 6 : impossible de decoder les options      .
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
      parameter ( nompro = 'UTLO03' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 motcle
c
      integer option
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
      integer loptio
      integer nbrmin, nbrmax
c
      character*200 noptio
c
      integer nbmess
      parameter ( nbmess = 15 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
c 1.1. ==> tout va bien
c
      codret = 0
c
c 1.2. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "utlo00.h"
#include "utlo02.h"
c
      nbrmin = 0
      nbrmax = 1
c
c====
c 2. options textuelles
c====
c
c 2.1. ==> recherche du texte associe au mot-cle
c          code de retour de utfino :
c             0 : pas de probleme
c             1 : la configuration est perdue
c             2 : pas de nom dans la base
c     remarque : on recupere le texte en majuscule
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFIN2', nompro
#endif
      call utfin2 ( motcle, iaux, noptio, loptio,
     >              nbrmin, nbrmax,
     >              ulsort, langue, codre0)
c
c 2.2. ==> decodage de l'option
c
      if ( codre0.eq.0 ) then
c
#include "utlo03.h"
c
        if ( loptio.eq.2 ) then
c
          if ( noptio(1:loptio).eq.'NO' ) then
            option = 0
          else
            codre0 = 5
          endif
c
        elseif ( loptio.eq.3 ) then
c
          if ( noptio(1:loptio).eq.'NON' ) then
            option = 0
          else
            codre0 = 5
          endif
c
        elseif ( loptio.eq.4 ) then
c
          if ( noptio(1:loptio).eq.'FREE' ) then
            option = 1
          else
            codre0 = 5
          endif
c
        elseif ( loptio.eq.5 ) then
c
          if ( noptio(1:loptio).eq.'LIBRE' ) then
            option = 1
          else
            codre0 = 5
          endif
c
        elseif ( loptio.eq.7 ) then
c
          if ( noptio(1:loptio).eq.'UNIFORM' ) then
            option = -1
          else
            codre0 = 5
          endif
c
        elseif ( loptio.eq.8 ) then
c
          if ( noptio(1:loptio).eq.'UNIFORME' ) then
            option = -1
          else
            codre0 = 5
          endif
c
        elseif ( loptio.eq.14 ) then
c
          if ( noptio(1:loptio).eq.'LIBRE_HOMOGENE' .or.
     >         noptio(1:loptio).eq.'LIBRE-HOMOGENE' ) then
            option = 2
          else
            codre0 = 5
          endif
c
        elseif ( loptio.eq.16 ) then
c
          if ( noptio(1:loptio).eq.'FREE_HOMOGENEOUS' .or.
     >         noptio(1:loptio).eq.'FREE-HOMOGENEOUS' ) then
            option = 2
          else
            codre0 = 5
          endif
c
        else
          codre0 = 5
        endif
c
      elseif ( codre0.eq.2 ) then
        codre0 = 0
c
      elseif ( codre0.ne.3 ) then
        codre0 = 6
c
      endif
c
#include "utlo01.h"
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
