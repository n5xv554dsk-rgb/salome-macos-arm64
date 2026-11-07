      subroutine utfia2 ( nbfich, lgtanf,
     >                    nomref,
     >                    lgnofi, poinno, nomufi, nomstr, infsup,
     >                    nfconf, lfconf, ulsort, langue, codret )
c
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
c  but : acquerir les noms des fichiers concernes par un calcul
c
c  note: on s'attend, dans le fichier de configuration, a trouver des
c        noms de fichiers "a la UNIX". Ces noms de fichiers sont
c        convertis par dmnfcv, a la fin de ce sous-programme,
c        pour etre acceptables par le systeme
c        d'exploitation courant (par exemple WINDOWS).
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfich . e   .    1   . nombre de fichiers dans la configuration   .
c . lgtanf . e   .    1   . longueur tableau des noms de fichiers      .
c . nomref .  s  . nbfich . nom de reference des fichiers              .
c . lgnofi .  s  . nbfich . longueurs des noms  des fichiers           .
c . poinno .  s  .0:nbfich. pointeur dans le tableau des noms          .
c . nomufi .  s  . lgtanf . noms des fichiers                          .
c . nomstr .  s  . nbfich . nom terminaux des objets stockes           .
c . infsup .  s  . nbfich . informations supplementaires               .
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur du nom du fichier                 .
c . ulsort . e   .    1   . unite logique d'impression                 .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme de decodage des noms          .
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
      parameter ( nompro = 'UTFIA2' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer nbfich, lgtanf
      integer lfconf
      integer lgnofi(nbfich), poinno(0:nbfich)
      integer ulsort, langue, codret
c
      character*(*) nfconf
      character*8 nomref(nbfich), nomufi(lgtanf), nomstr(nbfich)
      character*8 infsup(nbfich)
c
c 0.4. ==> variables locales
c
      integer ulconf
      integer codre0
      integer iaux, jaux, kaux
      integer ideb1, ideb2, ideb3, ideb4, ideb5
      integer ifin1, ifin2, ifin3, ifin4, ifin5
      integer lgnova, lgnout
c
      integer lgmax
c
      integer nrofic
c
      character*400 ligne, ligbla, ligaux
      character*400 nomvar, nomuti
      character*8 motcle
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
c
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
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
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.3. ==> initialisation pour ne plus avoir de messages ftnchek
c
      nomvar = ligbla
c
c 1.4. ==> ouverture du fichier de configuration
c
      call guoufs ( nfconf, lfconf, ulconf, codret )
c
      if ( codret.eq.0 ) then
        call gurbbu ( ulconf, codret )
      endif
c
c====
c 2.  lecture par une boucle sur les lignes
c     remarque : les verifications ont ete faites dans la premiere
c     phase traitee par utfia1
c====
c
      nrofic = 0
      poinno(nrofic) = 0
c
    2 continue
c
      ligne = ligbla
c
      read ( ulconf, 20400, end=30, err=30 ) ligne
c
c nettoyage eventuel de la ligne lue (caract. non impr.):
c
      call dmcpch( ligne, len(ligne), ligne, jaux )
c
c 2.1. ==> on ne tient compte ni des lignes blanches, ni
c            des commentaires
c
      if ( ligne.eq.ligbla .or. ligne(1:1).eq.commen ) then
c
        goto 2
c
      else
c
c 2.2. ==> recherche des positions des mots
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UGFIA3', nompro
#endif
        call ugfia3 ( ligne,
     >                ideb1, ifin1, ideb2, ifin2,
     >                ideb3, ifin3, ideb4, ifin4,
     >                ulsort, langue, codret )
c
        endif
c
c 2.3. ==> archivage
c
        if ( codret.eq.0 ) then
c
        nrofic = nrofic + 1
c
c 2.3.1. ==> mot-cle
c
        motcle = blan08
        motcle(1:ifin1+1-ideb1) = ligne(ideb1:ifin1)
        nomref(nrofic) = motcle
c
c 2.3.2. ==> nom de l'objet eventuellement
c
        if ( ideb3.gt.0 ) then
          motcle = blan08
          motcle(1:ifin2+1-ideb2) = ligne(ideb2:ifin2)
          nomstr(nrofic) = motcle
        endif
c
c 2.3.3. ==> informations supplementaires eventuellement
c
        if ( ideb4.gt.0 ) then
          motcle = blan08
          motcle(1:ifin4+1-ideb4) = ligne(ideb4:ifin4)
          infsup(nrofic) = motcle
        endif
c
c 2.3.4. ==> decodage
c
        if ( ideb3.gt.0 ) then
          ideb5 = ideb3
          ifin5 = ifin3
        else
          ideb5 = ideb2
          ifin5 = ifin2
        endif
c
  230   continue
        if ( ifin5.gt.ideb5+1 .and.
     >       ligne(ideb5:ideb5+1).eq.'./' ) then
          ideb5 = ideb5+2
          goto 230
        endif
c
c       on explore tous les caracteres
c
        kaux = 0
        varenv = .false.
        lgnova = 0
        ligaux = ligbla
c
        do 231 , iaux = ideb5, ifin5
c
          if ( ligne(iaux:iaux).eq.'$' ) then
c
            if ( varenv ) then
              call dmvaen ( nomvar, lgnova, nomuti, lgnout,
     >                      ulsort, langue, codre0 )
              if ( codre0.ne.0 ) then
                codre0 = 7
              endif
              if ( kaux.lt.len(ligaux) .and. lgnout.gt.0 ) then
                lgnout = min( len(ligaux)-kaux, lgnout )
                ligaux(kaux+1:kaux+lgnout) = nomuti(1:lgnout)
                kaux = kaux + lgnout
              endif
            endif
            varenv = .true.
            lgnova = 0
c
          elseif ( ligne(iaux:iaux).eq.'.' .or.
     >             ligne(iaux:iaux).eq.'-' .or.
     >             ligne(iaux:iaux).eq.'/' ) then
            if ( varenv ) then
              call dmvaen ( nomvar, lgnova, nomuti, lgnout,
     >                      ulsort, langue, codre0 )
              if ( codre0.ne.0 ) then
                codre0 = 7
              endif
              if ( kaux.lt.len(ligaux) .and. lgnout.gt.0 ) then
                lgnout = min( len(ligaux)-kaux, lgnout )
                ligaux(kaux+1:kaux+lgnout) = nomuti(1:lgnout)
                kaux = kaux + lgnout
              endif
              varenv = .false.
            endif
            if ( kaux.lt.len(ligaux) ) then
              kaux = kaux + 1
              ligaux(kaux:kaux) = ligne(iaux:iaux)
            endif
c
          else
            if ( varenv ) then
              lgnova = lgnova + 1
              nomvar(lgnova:lgnova) = ligne(iaux:iaux)
              if ( iaux.eq.ifin5 ) then
                call dmvaen ( nomvar, lgnova, nomuti, lgnout,
     >                        ulsort, langue, codre0 )
                if ( codre0.ne.0 ) then
                  codre0 = 7
                endif
                if ( kaux.lt.len(ligaux) .and. lgnout.gt.0 ) then
                  lgnout = min( len(ligaux)-kaux, lgnout )
                  ligaux(kaux+1:kaux+lgnout) = nomuti(1:lgnout)
                  kaux = kaux + lgnout
                endif
              endif
            else
              if ( kaux.lt.len(ligaux) ) then
                kaux = kaux + 1
                ligaux(kaux:kaux) = ligne(iaux:iaux)
              endif
            endif
c
          endif
c
          codret = max ( codret , codre0 )
c
  231   continue
c
c conversion eventuelle du nom du fichier trouve dans le
c fichier de configuration: sous UNIX, dmnfcv ne fait RIEN ...
c                           sous WINDOWS, on change les / en \ ...
c
        if ( kaux.gt.0 ) then
          call dmnfcv( ligaux, kaux )
        endif
c
c 2.3.4. ==> archivage
c
        iaux = poinno(nrofic-1) + 1
        call utchs8 ( ligaux, kaux, nomufi(iaux),
     >                ulsort, langue, codre0 )
        if ( codre0.ne.0 ) then
          codret = 3
        endif
c
        lgnofi(nrofic) = kaux
c
        if ( mod(kaux,8).eq.0 ) then
          iaux = kaux/8
        else
          iaux = ((kaux-mod(kaux,8))/8) + 1
        endif
c
        poinno(nrofic) = poinno(nrofic-1) + iaux
c
        endif
c
c 2.4. ==> ligne suivante
c
      endif
c
      goto 2
c
c====
c 3. fin
c====
c
   30 continue
c
      if ( codret.eq.0 ) then
        call gufefi ( nfconf, lfconf, codret )
      endif
c
20400 format (a400)
c
      end
