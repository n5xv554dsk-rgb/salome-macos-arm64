      subroutine utfia1 ( nbfich, lgtanf,
     >                    nfconf, lfconf, ulsort, langue, codret )
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
c  but : fait le decompte des fichiers du calcul et de la longueur
c        des noms (UNIX, ou autre OS) de ces fichiers
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfich .  s  .    1   . nombre de fichiers dans la configuration   .
c . lgtanf .  s  .    1   . longueur tableau des noms de fichiers      .
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur du nom du fichier                 .
c . ulsort . e   .    1   . unite logique d'impression                 .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme de decodage des noms          .
c .        .     .        . 7 : impossible de decoder le $HOME         .
c .        .     .        .   : (ou une autre variable d'environnement).
c .        .     .        . 9 : probleme avec le fichier               .
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
      parameter ( nompro = 'UTFIA1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbfich, lgtanf
      integer lfconf
      integer ulsort, langue, codret
c
      character*(*) nfconf
c
c 0.4. ==> variables locales
c
      integer ulconf
      integer codre0, codre1
      integer iaux, jaux, kaux
      integer ideb1, ideb2, ideb3, ideb4, ideb5
      integer ifin1, ifin2, ifin3, ifin4, ifin5
      integer lgnova, lgnout
c
      integer lgmax
c
      character*400 ligne, ligbla
      character*400 nomvar, nomuti
      character*1 commen
c
      logical varenv
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      parameter ( lgmax = 400 )
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr03.h"
c
c 1.1. ==> constantes
c
      codre0 = 0
c
      commen = '#'
c
      do 1 , iaux = 1 , lgmax
        ligbla (iaux:iaux) = ' '
    1 continue
c
c 1.2. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Dans le fichier de configuration'')'
      texte(1,5) = '(''Le mot-cle a plus de 8 caracteres :'')'
      texte(1,6) = '(''Le nom d''''objet a plus de 8 caracteres :'')'
      texte(1,7) =
     > '(''L''''information supplementaire a plus de 8 caracteres :''
     > )'
c
      texte(2,4) = '(''In the configuration file'')'
      texte(2,5) =
     > '(''The size of the keyword is greater than 8 :'')'
      texte(2,6) =
     > '(''The size of the object name is greater than 8 :'')'
      texte(2,7) =
     > '(''The size of the supplementary information is greater than
     >8 :'')'
c
c 1.3. ==> initialisation pour ne plus avoir de messages ftnchek
c
      nomvar = ligbla
c
c====
c 2. ouverture du fichier de configuration
c====
c
      nbfich = 0
      lgtanf = 0
c
      if ( codret.eq.0 ) then
      call guoufs ( nfconf, lfconf, ulconf, codret )
      endif
c
      if ( codret.eq.0 ) then
      call gurbbu ( ulconf, codret )
      if ( codret.ne.0 ) then
        codret = 9
      endif
      else
        codret = 9
      endif
c
c====
c 3. comptage du nombre de fichiers enregistres et de la longueur
c    cumulee de leurs noms
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. comptage ; codret = ', codret
#endif
c
30000 format (a400)
c
      if ( codret.eq.0 ) then
c
   30 continue
c
      ligne = ligbla
c
      read ( ulconf, 30000, end=40, err=40 ) ligne
c
c nettoyage eventuel de la ligne lue (caract. non impr.):
c
      call dmcpch( ligne, len(ligne), ligne, jaux )
c
c 3.1. ==> on ne tient compte ni des lignes blanches, ni
c            des commentaires
c
      if ( ligne.eq.ligbla .or. ligne(1:1).eq.commen ) then
c
        goto 30
c
      else
c
c 3.2. ==> recherche des positions des mots
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UGFIA3', nompro
#endif
        call ugfia3 ( ligne,
     >                ideb1, ifin1, ideb2, ifin2,
     >                ideb3, ifin3, ideb4, ifin4,
     >                ulsort, langue, codret )
        codre0 = max(codre0, codret)
c
c 3.3. ==> archivage des informations
c
c 3.3.1. ==> controle
c
c 3.3.1.1. ==> le mot-cle a au plus 8 caracteres.
c
        if ( (ifin1-ideb1).gt.7 ) then
          write (ulsort,texte(langue,1)) 'Sortie', nompro
          write (ulsort,texte(langue,4))
          write (ulsort,*) nfconf(1:lfconf)
          write (ulsort,*) ligne
          write (ulsort,texte(langue,5))
          write (ulsort,*) ligne(ideb1:ifin1)
          codre0 = 3
        endif
c
c 3.3.1.2. ==> le nom d'objet, s'il existe, a au plus 8 caracteres.
c
        if ( ideb3.gt.0 ) then
          if ( (ifin2-ideb2).gt.7 ) then
            write (ulsort,texte(langue,1)) 'Sortie', nompro
            write (ulsort,texte(langue,4))
            write (ulsort,*) nfconf(1:lfconf)
            write (ulsort,*) ligne
            write (ulsort,texte(langue,6))
            write (ulsort,*) ligne(ideb2:ifin2)
            codre0 = 3
          endif
        endif
c
c 3.3.1.3. ==> l'information supplementaire, si elle existe,
c              a au plus 8 caracteres.
c
        if ( ideb4.gt.0 ) then
          if ( (ifin4-ideb4).gt.7 ) then
            write (ulsort,texte(langue,1)) 'Sortie', nompro
            write (ulsort,texte(langue,4))
            write (ulsort,*) nfconf(1:lfconf)
            write (ulsort,*) ligne
            write (ulsort,texte(langue,7))
            write (ulsort,*) ligne(ideb4:ifin4)
            codre0 = 3
          endif
        endif
c
c 3.3.2. ==> decodage
c
          if ( ideb3.gt.0 ) then
            ideb5 = ideb3
            ifin5 = ifin3
          else
            ideb5 = ideb2
            ifin5 = ifin2
          endif
c
  330     continue
          if ( ifin5.gt.ideb5+1 .and.
     >         ligne(ideb5:ideb5+1).eq.'./' ) then
            ideb5 = ideb5+2
            goto 330
          endif
c
c         on explore tous les caracteres
c
          kaux = 0
          varenv = .false.
          lgnova = 0
c
          do 331 , iaux = ideb5, ifin5
c
            if ( ligne(iaux:iaux).eq.'$' ) then
c
              if ( varenv ) then
                call dmvaen ( nomvar, lgnova, nomuti, lgnout,
     >                        ulsort, langue, codre1 )
                if ( codre1.ne.0 .and. codre0.eq.0 ) then
                  codre0 = 7
                endif
                kaux = kaux + max(0,lgnout)
              endif
              varenv = .true.
              lgnova = 0
c
            elseif ( ligne(iaux:iaux).eq.'.' .or.
     >               ligne(iaux:iaux).eq.'-' .or.
     >               ligne(iaux:iaux).eq.'/' ) then
              if ( varenv ) then
                call dmvaen ( nomvar, lgnova, nomuti, lgnout,
     >                        ulsort, langue, codre1 )
                if ( codre1.ne.0 .and. codre0.eq.0 ) then
                  codre0 = 7
                endif
                kaux = kaux + max(0,lgnout)
                varenv = .false.
              endif
              kaux = kaux + 1
c
            else
              if ( varenv ) then
                lgnova = lgnova + 1
                nomvar(lgnova:lgnova) = ligne(iaux:iaux)
                if ( iaux.eq.ifin5 ) then
                  call dmvaen ( nomvar, lgnova, nomuti, lgnout,
     >                          ulsort, langue, codre1 )
                  if ( codre1.ne.0 .and. codre0.eq.0 ) then
                    codre0 = 7
                  endif
                  kaux = kaux + max(0,lgnout)
                endif
              else
                kaux = kaux + 1
              endif
            endif
c
  331     continue
c
c 3.3.2.3. ==> Cumul des longueurs
c
        if ( mod(kaux,8).eq.0 ) then
          lgtanf = lgtanf + (kaux/8)
        else
          lgtanf = lgtanf + ((kaux-mod(kaux,8))/8) + 1
        endif
c
        nbfich = nbfich + 1
c
      endif
c
c 3.4. ==> ligne suivante
c
      goto 30
c
      endif
c
c====
c 4. fin
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. fin ; codret = ', codret
#endif
c
   40 continue
c
      if ( codret.eq.0 ) then
        call gufefi ( nfconf, lfconf, codret )
        if ( codret.ne.0 ) then
          codret = 9
        endif
      endif
c
      if ( codret.eq.0 .and. codre0.ne.0 ) then
        codret = codre0
      endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
