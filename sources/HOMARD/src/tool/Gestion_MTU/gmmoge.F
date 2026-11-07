      subroutine gmmoge ( modgm, typarr,
     >                    nenti, nreel, nch08,
     >                    nfconf, lfconf,
     >                    codret )
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
c     Gestion de la Memoire : MOde de GEstion
c     -             -         --      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . modgm  .  s  .    1   . 0 : mode statique                          .
c .        .     .        . 1 : mode semi-dynamique                    .
c .        .     .        . 2 : mode dynamique                         .
c . typarr .  s  .    1   . gere les arrets de gm en cas de probleme   .
c .        .     .        . 0 : arret par le programme ad-hoc          .
c .        .     .        . 1 : code de retour non nul                 .
c . nenti  .  s  .    1   . nombre d'entiers                           .
c . nreel  .  s  .    1   . nombre de reels                            .
c . nresp  .  s  .    1   . nombre de reels simple precision           .
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur du nom du fichier                 .
c . codret .  s  .    1   . 0 : tout va bien                           .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'GMMOGE' )
c
#include "genbla.h"
c
c 0.2. ==> communs
c
#include "gmimpr.h"
#include "gmlang.h"
c
c les communs qui suivent sont ici pour declarer les variables lgxxxx
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      character*(*) nfconf
c
      integer lfconf
      integer modgm
      integer typarr
      integer nenti, nreel, nch08
      integer codret
c
c 0.4. ==> variables locales
c
      integer iaux, nbaux, codre0
      integer lfmode
c
      integer nbtype
      parameter ( nbtype = 3 )
c
      character*8 motcle
      character*200 nfmode
c
      character*5 fmtent
c
#include "motcle.h"
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) =
     >'(''L''''option de la memoire '',a8,'' est absente.'')'
      texte(1,4) = '(''On impose un mode de gestion dynamique.'')'
      texte(1,5) =
     >'(''L''''option de la memoire '',a8,'' est illisible.'')'
      texte(1,6) = '(''On impose 0 valeurs.'')'
      texte(1,7) = '(''Le type '',i8,'' ne convient pas.'')'
      texte(1,8) = '(''Il faut 0 ou 1.'')'
c
      texte(2,10) = '(''The option '',a8,'' is missing.'')'
      texte(2,4) = '(''A dynamic memory management is imposed.'')'
      texte(2,5) = '(''The option '',a8,'' cannot be read.'')'
      texte(2,6) = '(''0 values are imposed.'')'
      texte(2,7) = '(''Type '',i8,'' is not correct.'')'
      texte(2,8) = '(''0 or 1 is needed.'')'
c
c====
c 2. recuperation du mode de gestion de la memoire
c====
c
c 2.1. ==> recherche de l'option de pilotage qui contient le
c          le mode de gestion de la memoire
c
      motcle = mcmogm
      call ugfino ( motcle, nfmode, lfmode,
     >              nfconf, lfconf,
     >              ulsort , langue, codret )
c
c 2.2. ==> si aucune option n'a ete precisee, on passe en mode dynamique
c
      if ( codret.eq.1 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,10)) motcle
        write (ulsort,texte(langue,4))
#endif
c
        modgm = 2
        codret = 0
c
c 2.3. ==> probleme de lecture
c
      elseif ( codret.ne.0 ) then
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,5)) motcle
c
        codret = 1
c
c 2.3. ==> si l'option est dynamique, on y va !
c
      elseif ( nfmode(1:lfmode).eq.'Dynamique' .or.
     >         nfmode(1:lfmode).eq.'DYNAMIQUE' .or.
     >         nfmode(1:lfmode).eq.'dynamique' ) then
c
        modgm = 2
c
c 2.4. ==> si l'option est semi-dynamique, on y va !
c
      elseif ( nfmode(1:lfmode).eq.'Semi-Dynamique' .or.
     >         nfmode(1:lfmode).eq.'SEMI-DYNAMIQUE' .or.
     >         nfmode(1:lfmode).eq.'semi-dynamique' ) then
c
        modgm = 1
c
c 2.5. ==> si l'option est statique, on y va !
c
      elseif ( nfmode(1:lfmode).eq.'Statique' .or.
     >         nfmode(1:lfmode).eq.'STATIQUE' .or.
     >         nfmode(1:lfmode).eq.'statique' ) then
c
        modgm = 0
c
c 2.6. ==> sinon, il y a un probleme
c
      else
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,5)) motcle
        if ( lfmode.gt.0 ) then
          write (ulsort,*) nfmode(1:lfmode)
        else
          write (ulsort,*)
        endif
c
        codret = 1
c
      endif
c
c====
c 3. determination des tailles
c====
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> en mode statique, on met les tailles des parameter
c
      if ( modgm.eq.0 ) then
c
        nenti = lgcomi
        nreel = lgcomr
        nch08 = lgcoms
c
c 3.2. ==> en mode semi-dynamique, on lit les tailles
c
      elseif ( modgm.eq.1 ) then
c
        do 32 , iaux = 1 , nbtype
c
c 3.2.1. ==> recherche du motcle dans le fichier de configuration
c
          if ( iaux.eq.1 ) then
            motcle = mcgmen
          elseif ( iaux.eq.2 ) then
            motcle = mcgmre
          elseif ( iaux.eq.3 ) then
            motcle = mcgmc8
          endif
c
          call ugfino ( motcle, nfmode, lfmode,
     >                  nfconf, lfconf,
     >                  ulsort , langue, codre0 )
c
c 3.2.2. ==> si aucune taille n'a ete precisee, on met 0
c
          if ( codre0.eq.1 ) then
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,1)) 'Sortie', nompro
            write (ulsort,texte(langue,10)) motcle
            write (ulsort,texte(langue,6))
#endif
c
            nbaux = 0
            codre0 = 0
c
c 3.2.3. ==> probleme de lecture
c
          elseif ( codre0.ne.0 ) then
c
            write (ulsort,texte(langue,1)) 'Sortie', nompro
            write (ulsort,texte(langue,5)) motcle
c
            nbaux = 0
c
c 3.2.4. ==> decodage
c
          else
c
            if ( lfmode.gt.0 .and. lfmode.lt.100 ) then
c
              fmtent = '(I  )'
              if ( lfmode.lt.10 ) then
                write(fmtent(3:3),'(i1)') lfmode
              else
                write(fmtent(3:4),'(i2)') lfmode
              endif
              read ( nfmode,fmtent) nbaux
c
            else
              write (ulsort,texte(langue,1)) 'Sortie', nompro
              write (ulsort,texte(langue,5)) motcle
              codre0 = 3
              nbaux = 0
            endif
c
          endif
c
c 3.2.5. ==> bilan
c
          if ( iaux.eq.1 ) then
            nenti = max(0, nbaux )
          elseif ( iaux.eq.2 ) then
            nreel = max(0, nbaux )
          elseif ( iaux.eq.3 ) then
            nch08 = max(0, nbaux )
          endif
c
          codret = max ( codret, abs(codre0) )
c
   32   continue
c
c 3.3. ==> en mode dynamique, on met des tailles nulles
c
      else
c
        nenti = 0
        nreel = 0
        nch08 = 0
c
      endif
c
      endif
c
c====
c 4. type d'arret
c====
c
      if ( codret.eq.0 ) then
c
c 4.1. ==> recherche de l'option de pilotage qui contient le
c          le type d'arret de la gestion de la memoire
c
        motcle = mcgmta
        call ugfino ( motcle, nfmode, lfmode,
     >                nfconf, lfconf,
     >                ulsort , langue, codre0 )
c
c 4.2. ==> si aucune option n'a ete precisee, on arretera brutalement
c
        if ( codre0.eq.1 ) then
c
          typarr = 0
c
c 4.3. ==> probleme de lecture
c
        elseif ( codre0.ne.0 ) then
c
          write (ulsort,texte(langue,1)) 'Sortie', nompro
          write (ulsort,texte(langue,10)) motcle
          write (ulsort,texte(langue,5))
c
          typarr = 0
          codret = 1
c
c 4.4. ==> decodage
c
        else
c
          if ( lfmode.gt.0 .and. lfmode.lt.100 ) then
c
            fmtent = '(I  )'
            if ( lfmode.lt.10 ) then
              write(fmtent(3:3),'(i1)') lfmode
            else
              write(fmtent(3:4),'(i2)') lfmode
            endif
            read ( nfmode,fmtent) typarr
c
          else
            write (ulsort,texte(langue,1)) 'Sortie', nompro
            write (ulsort,texte(langue,10)) motcle
            if ( lfmode.gt.0 ) then
              write (ulsort,*) nfmode(1:lfmode)
            else
              write (ulsort,*)
            endif
            write (ulsort,texte(langue,8))
            typarr = 0
            codret = 1
          endif
c
        endif
c
c 4.5. ==> verification
c
        if ( typarr.lt.0 .or. typarr.gt.1 ) then
          write (ulsort,texte(langue,1)) 'Sortie', nompro
          write (ulsort,texte(langue,10)) motcle
          write (ulsort,texte(langue,7)) typarr
          write (ulsort,texte(langue,8))
          typarr = 0
          codret = 1
        endif
c
      endif
c
c====
c 5. en mode semi-dynamique : le mode de gestion passe en dynamique
c    si toutes les valeurs sont nulles
c====
c
      if ( codret.eq.0 ) then
c
        if ( modgm.eq.1 ) then
c
          if ( (nenti.eq.0) .and.
     >         (nreel.eq.0) .and.
     >         (nch08.eq.0) ) then
c
            modgm = 2
c
          endif
c
        endif
c
      endif
c
      end
