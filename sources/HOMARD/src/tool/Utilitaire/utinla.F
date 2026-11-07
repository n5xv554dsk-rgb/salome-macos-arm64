      subroutine utinla ( nfconf, lfconf,
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
c       UTilitaire : INitialisation de la LAngue
c       --           --                   --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur du nom du fichier                 .
c . ulsort .  s  .   1    . numero d'unite logique de la liste standard.
c . langue . es  .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
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
      parameter ( nompro = 'UTINLA' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      character*(*) nfconf
c
      integer lfconf
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
c
      integer loptio
c
      character*8 motcle
      character*200 noptio
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      if ( langue.le.0 .or. langue.gt.nblang ) then
        langue = 1
      endif
c
c====
c 1. les messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,20) = '(/,''Fichier de configuration :'')'
      texte(1,4) = '(''Decodage du parametre : '',a8)'
      texte(1,5) = '(''La langue par defaut est utilisee.'')'
      texte(1,6) = '(''Erreur de decodage.'')'
      texte(1,7) = '(''Aucune langue n''''est associe.'')'
      texte(1,8) = '(''Plusieurs langues sont definies.'')'
      texte(1,9) = '(''Il est absent du fichier.'')'
      texte(1,10) = '(''Desole, cette langue est inconnue :'')'
c
      texte(2,20) = '(/,''Configuration file :'')'
      texte(2,4) = '(''Uncoding of parameter '',a8)'
      texte(2,5) = '(''The default language is used.'')'
      texte(2,6) = '(''Error during uncoding.'')'
      texte(2,7) = '(''No language is connected to.'')'
      texte(2,8) = '(''Several languages are defined.'')'
      texte(2,9) = '(''It is missing.'')'
      texte(2,10) = '(''Sorry, this language is unknown.'')'
c
c====
c 2. decodage de la langue choisie
c====
c
c 2.1. ==> recherche du mot-cle
c
      motcle = mclang
      call ugfino ( motcle, noptio, loptio,
     >              nfconf, lfconf,
     >              ulsort, langue, codret)
c
c 2.2. ==> recherche du type de langue
c
      if ( codret.eq.0 ) then
c
        if ( loptio.eq.6 ) then
c
          if ( noptio(1:loptio).eq.'French' .or.
     >         noptio(1:loptio).eq.'french' .or.
     >         noptio(1:loptio).eq.'FRENCH' ) then
c
            langue = 1
c
          else
            codret = 10
c
          endif
c
        elseif ( loptio.eq.8 ) then
c
          if ( noptio(1:loptio).eq.'Francais' .or.
     >         noptio(1:loptio).eq.'francais' .or.
     >         noptio(1:loptio).eq.'FRANCAIS' ) then
c
            langue = 1
c
          else
            codret = 10
c
          endif
c
        elseif ( loptio.eq.7 ) then
c
          if ( noptio(1:loptio).eq.'Anglais' .or.
     >         noptio(1:loptio).eq.'anglais' .or.
     >         noptio(1:loptio).eq.'ANGLAIS' .or.
     >         noptio(1:loptio).eq.'English' .or.
     >         noptio(1:loptio).eq.'english' .or.
     >         noptio(1:loptio).eq.'ENGLISH' ) then
c
            langue = 2
c
          else
            codret = 10
c
          endif
c
        endif
c
      elseif ( codret.eq.1 ) then
        codret = 9
c
      elseif ( codret.eq.2 ) then
        codret = 8
c
      elseif ( codret.eq.3 ) then
        codret = 7
c
      else
        codret = 6
c
      endif
c
c 2.3. ==> messages d'erreur eventuels
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,2)) codret
#endif
c
      if ( codret.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,20))
        if ( lfconf.gt.0 .and. len(nfconf).gt.0 ) then
          write (ulsort,*) nfconf(1:lfconf)
        else
          write (ulsort,*)
        endif
        write (ulsort,texte(langue,4)) motcle
        write (ulsort,texte(langue,codret))
        if ( codret.eq.9 ) then
          if ( loptio.gt.0 ) then
            write (ulsort,*) noptio(1:loptio)
          else
            write (ulsort,*)
          endif
        endif
        write (ulsort,texte(langue,5))
#endif
        codret = 0
c
      endif
c
      end
