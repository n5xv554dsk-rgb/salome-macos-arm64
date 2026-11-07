      subroutine ugfino ( motcle, nfichi, lfichi,
     >                    nfconf, lfconf,
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
c Copyright 2020 EDF
c ______________________________________________________________________
c
c but : retourne le nom du fichier correspondant a un mot-cle
c       en faisant la lecture directe dans le fichier de configuration
c
c  note: on s'attend, dans le fichier de configuration, a trouver un
c        nom de fichier nfichi "a la UNIX". Ce nom de fichier est
c        converti par dmnfcv, a la fin de ce sous-programme,
c        pour etre acceptable par le systeme
c        d'exploitation courant (par exemple WINDOWS).
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . motcle . e   . char8  . mot-cle de reperage dans la configuration  .
c . nfichi .  s  . char * . nom du fichier associe                     .
c . lfichi .  s  .    1   . longueur de ce nom                         .
c . nfconf . e   . char * . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur de ce nom                         .
c . ulsort . e   .    1   . unite logique d'impression                 .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . 0 : le nom du fichier est trouve           .
c .        .     .        . 1 : le mot-cle est absent du fichier       .
c .        .     .        . 2 : plusieurs noms existent                .
c .        .     .        . 3 : le mot-cle n'est associe a aucun fichie.
c .        .     .        . 5 : le mot-cle est blanc                   .
c .        .     .        . 7 : impossible de decoder une variable     .
c .        .     .        .     d'environnement                        .
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
      parameter ( nompro = 'UGFINO' )
c
#include "consts.h"
#include "genbla.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer lfconf, lfichi
      integer langue, ulsort, codret
c
      character*(*) motcle
      character*(*) nfconf, nfichi
c
c 0.4. ==> variables locales
c
      integer ideb1, ideb2, ideb3, ideb4
      integer ifin1, ifin2, ifin3, ifin4
      integer ulconf, codre0, codre1, codre2
      integer iaux, jaux, kaux
      integer lgnova, lgnout
c
      integer lgmax
c
      integer lgmoc
      integer lgliga, lgligb
c
      character*400 lignea, ligneb
      character*400 nomvar, nomuti
      character*400 ligbla
      character*8 motloc
      character*1 commen
c
      logical varenv
c
      integer nbmess
      parameter ( nbmess = 10 )
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Dans le fichier de configuration'')'
      texte(1,5) =
     > '(''Aucun fichier n''''est associe au mot-cle :'')'
      texte(1,6) =
     >'(''le mot-cle '',a8,'' est associe a plusieurs fichiers.'')'
      texte(1,7) = '(''le mot-cle '',a8,'' est absent.'')'
c
      texte(2,4) = '(''In the configuration file'')'
      texte(2,5) = '(''No file is connected with the keyword :'')'
      texte(2,6) =
     >'(''the keyword '',a8,'' is connected with several files.'')'
      texte(2,7) = '(''the keyword '',a8,'' is missing.'')'
c
c 1.2. ==> les constantes
c
      codre2 = 0
      lfichi = 0
c
      do 10 iaux = 1 , len(nfichi)
        nfichi (iaux:iaux) = ' '
   10 continue
c
      commen = '#'
c
      do 11 , iaux = 1 , lgmax
        ligbla (iaux:iaux) = ' '
   11 continue
c
c 1.3. ==> initialisation pour ne plus avoir de messages ftnchek
c
      nomvar = ligbla
c
c 1.4. ==> suppression des blancs aux extremites du mot-cle
c
      jaux = min(8,len(motcle))+1
      do 141 , iaux = 1 , min(8,len(motcle))
        if ( motcle (iaux:iaux) .ne. ' ' ) then
          jaux = iaux
          goto 142
        endif
  141 continue
c
  142 continue
c
      kaux = 0
      do 143 , iaux =  min(8,len(motcle)), jaux , -1
        if ( motcle (iaux:iaux) .ne. ' ' ) then
          kaux = iaux
          goto 144
        endif
  143 continue
c
  144 continue
c
      lgmoc = kaux - jaux + 1
      motloc = blan08
c
      if ( lgmoc.gt.0 ) then
        motloc(1:lgmoc) = motcle(jaux:kaux)
        codret = 0
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'Mot_cle : ', motloc
#endif
      else
        codret = 5
      endif
c
c===
c 2. decodage du fichier de configuration
c===
c
      if ( codret.eq.0 ) then
c
      codret = 1
c
c 2.1. ==> ouverture du fichier de configuration
c
      call guoufs ( nfconf, lfconf, ulconf, codre1 )
c
      if ( codre1.ne.0 .and. ulconf.le.0 ) then
        goto 31
      else
        codre1 = 0
      endif
c
      call gurbbu ( ulconf, codre0 )
c
c 2.2. ==> boucle sur les lignes
c
      lgliga = len(lignea)
c
    2 continue
c
      lignea = ligbla
c
      read ( ulconf, 20400, end=31, err=31 ) lignea
c
c 2.2.1. ==> on ne tient pas compte d'une ligne en commentaire
c
      if ( lignea(1:1).eq.commen ) then
        goto 2
      endif
c
c 2.2.2. ==> nettoyage eventuel de la ligne lue (caract. non impr.):
c
      call dmcpch( lignea, lgliga, ligneb, lgligb )
c
c 2.2.3. ==> on ne tient pas compte d'une ligne blanche
c
      if ( lgligb.eq.0 ) then
        goto 2
      endif
c
c 2.2.4. ==> recherche du debut du mot-cle
c
      iaux = index(ligneb,motloc(1:lgmoc))
c
c 2.2.5. ==> Le mot-cle est present
c
      if ( iaux.gt.0 ) then
c
c 2.2.5.1. ==> recherche des positions des mots
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UGFIA3', nompro
#endif
        call ugfia3 ( ligneb,
     >                ideb1, ifin1, ideb2, ifin2,
     >                ideb3, ifin3, ideb4, ifin4,
     >                ulsort, langue, codret )
c
c 2.2.5.7. ==> decodage.
c              On controle que le mot-cle est le bon
c              et place en premier
c              Si oui, on determine le nom du fichier.
c
        if ( lgmoc.ne.ifin1-ideb1+1 .or.
     >       motloc(1:lgmoc).ne.ligneb(ideb1:ifin1) ) then
          goto 2
        endif
c
        if ( lfichi.ne.0 ) then
          write (ulsort,texte(langue,1)) 'Sortie', nompro
          write (ulsort,texte(langue,4))
          write (ulsort,*) nfconf(1:lfconf)
          write (ulsort,texte(langue,6)) motloc(1:lgmoc)
          codret = 2
          goto 31
        else
          if ( ideb3.gt.0 ) then
            ideb4 = ideb3
            ifin4 = ifin3
          else
            ideb4 = ideb2
            ifin4 = ifin2
          endif
c
  270     continue
          if ( ifin4.gt.ideb4+1 .and.
     >         ligneb(ideb4:ideb4+1).eq.'./' ) then
            ideb4 = ideb4+2
            goto 270
          endif
c
          kaux = 0
          varenv = .false.
          lgnova = 0
c
          do 271 , iaux = ideb4, ifin4
c
            if ( ligneb(iaux:iaux).eq.'$' ) then
c
              if ( varenv ) then
                call dmvaen ( nomvar, lgnova, nomuti, lgnout,
     >                        ulsort, langue, codre0 )
                if ( codre0.ne.0 ) then
                  codre2 = 7
                endif
                if ( kaux.lt.len(nfichi) .and. lgnout.gt.0 ) then
                  lgnout = min( len(nfichi)-kaux, lgnout )
                  nfichi(kaux+1:kaux+lgnout) = nomuti(1:lgnout)
                  kaux = kaux + lgnout
                endif
              endif
              varenv = .true.
              lgnova = 0
c
            elseif ( ligneb(iaux:iaux).eq.'.' .or.
     >               ligneb(iaux:iaux).eq.'-' .or.
     >               ligneb(iaux:iaux).eq.'/' ) then
              if ( varenv ) then
                call dmvaen ( nomvar, lgnova, nomuti, lgnout,
     >                        ulsort, langue, codre0 )
                if ( codre0.ne.0 ) then
                  codre2 = 7
                endif
                if ( kaux.lt.len(nfichi) .and. lgnout.gt.0 ) then
                  lgnout = min( len(nfichi)-kaux, lgnout )
                  nfichi(kaux+1:kaux+lgnout) = nomuti(1:lgnout)
                  kaux = kaux + lgnout
                endif
                varenv = .false.
              endif
              if ( kaux.lt.len(nfichi) ) then
                kaux = kaux + 1
                nfichi(kaux:kaux) = ligneb(iaux:iaux)
              endif
c
            else
              if ( varenv ) then
                lgnova = lgnova + 1
                nomvar(lgnova:lgnova) = ligneb(iaux:iaux)
                if ( iaux.eq.ifin4 ) then
                  call dmvaen ( nomvar, lgnova, nomuti, lgnout,
     >                          ulsort, langue, codre0 )
                  if ( codre0.ne.0 ) then
                    codre2 = 7
                  endif
                  if ( kaux.lt.len(nfichi) .and. lgnout.gt.0 ) then
                    lgnout = min( len(nfichi)-kaux, lgnout )
                    nfichi(kaux+1:kaux+lgnout) = nomuti(1:lgnout)
                    kaux = kaux + lgnout
                  endif
                endif
              else
                if ( kaux.lt.len(nfichi) ) then
                  kaux = kaux + 1
                  nfichi(kaux:kaux) = ligneb(iaux:iaux)
                endif
              endif
            endif
c
  271     continue
c
          lfichi = kaux
          if ( codret.eq.1 ) then
            codret = 0
          endif
        endif
c
      endif
c
c 2.2.6. ==> ligne suivante
c
      goto 2
c
c 2.3. ==> fin
c
   31 continue
c
      if ( codre1.eq.0 ) then
        call gufefi ( nfconf, lfconf, codre0 )
      endif
c
      endif
c
c conversion eventuelle du nom du fichier trouve dans le
c fichier de configuration: sous UNIX, dmnfcv ne fait RIEN ...
c                           sous WINDOWS, on change les / en \ ...
c
      if ( lfichi.gt.0 ) then
        call dmnfcv( nfichi, lfichi )
      endif
c
      if ( codret.eq.0 ) then
        if ( codre1.ne.0 ) then
          codret = 1
        endif
      endif
c
      if ( codret.eq.0 ) then
        if ( codre2.ne.0 ) then
          codret = 7
        endif
      endif
c
      if ( codret.eq.0 ) then
        if ( lfichi.le.0 ) then
          codret = 1
        endif
      endif
c
20400 format (a400)
c
c====
c 3. bilan
c====
c
#ifdef _DEBUG_HOMARD_
      if ( codret.ne.0 ) then
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
        write (ulsort,texte(langue,4))
        if ( lfconf.gt.0 .and. len(nfconf).gt.0 ) then
          write (ulsort,*) nfconf(1:min(lfconf,len(nfconf)))
        else
          write (ulsort,*)
        endif
        write (ulsort,texte(langue,7)) motloc
c
      endif
#endif
c
      end
