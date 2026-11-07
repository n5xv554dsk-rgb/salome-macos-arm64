      subroutine utinit ( nfconf, lfconf, messag, nbrmes,
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
c       UTilitaire : INITialisation
c       --           ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur du nom du fichier                 .
c . messag . e   . char40 . message d'en tete des listes               .
c . nbrmes . e   .   1    . nombres de messages                        .
c . ulsort .  s  .   1    . numero d'unite logique de la liste standard.
c . langue . es  .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        .  0 : pas de probleme                       .
c .        .     .        .  2x : probleme dans les memoires           .
c .        .     .        .  3 : probleme dans le decodage du fichier  .
c .        .     .        .      de configuration                      .
c .        .     .        .  3x : probleme dans les fichiers           .
c .        .     .        .  5 : deuxieme appel au programme           .
c .        .     .        .  7 : impossible de decoder le $HOME        .
c .        .     .        . 11 : date d'autorisation depassee          .
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
      parameter ( nompro = 'UTINIT' )
c
#include "nblang.h"
c
      integer nbcar
      parameter ( nbcar = 6 )
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*(*) nfconf
c
      integer lfconf
c
      integer ulsort, langue, codret
c
      integer nbrmes
      character*40 messag(nblang,nbrmes)
c
c 0.4. ==> variables locales
c
#include "consts.h"
#include "motcle.h"
#include "nuvers.h"
#include "webweb.h"
c
      integer lfsort
      integer guimp, gmimp, raison
      integer iaux, jaux, kaux
      integer ulsost, ulmess
      integer numann, datheu
      integer lgcar(nbcar)
c
      character*8 motcle
      character*50 nomare, nomais, typmac, noarch, systre, systve
      character*48 ladate
      character*200 nfsort
c
      character*40 blabla
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les messages
c====
c
#include "impr01.h"
c
      texte(1,4) = '(//,''1. INITIALISATIONS'')'
      texte(1,5) = '(18(''=''),/)'
      texte(1,7) = '(/,''Ce calcul date du '',a48)'
      texte(1,8) = '(''Il a eu lieu sur '',a)'
      texte(1,9) = '(''. type de machine : '',a  )'
      texte(1,10) = '(''. systeme d''''exploitation : '',a)'
      texte(1,11) = '(''                 release : '',a )'
      texte(1,12) = '(''                 version : '',a ,//)'
c
      texte(2,4) = '(//,''1. INITIALISATIONS'')'
      texte(2,5) = '(18(''=''),/)'
      texte(2,7) = '(/,''This computation ran '',a48)'
      texte(2,8) = '(''It was done on '',a)'
      texte(2,9) = '(''. machine type : '',a)'
      texte(2,10) = '(''. operating system : '',a)'
      texte(2,11) = '(''           release : '',a)'
      texte(2,12) = '(''           version : '',a,//)'
c
51001 format (
     >   15x,'..........................................')
51101 format (
     >   15x,':........................................:')
51002 format (
     >   15x,':                                        :')
51003 format (15x,':',a40,':')
51004 format (//)
51011 format (
     >   'Copyright 1996 EDF',
     > /,'Copyright 2015 EDF',
     > /,'Copyright ',i4,' EDF',
     > /,'------------------',/)
51012 format (
     >   15x,':         H O M A R D     ',a8  ,'       :')
c
      spropb = blan08(1:6)
c
c====
c 2. premier appel de uginit pour initialisation du gestionnaire
c    d'unites logiques
c    remarque : au premier appel, ulsort n'a pas besoin d'etre
c               initialise
c====
c
      codret = 0
c
      if ( langue.le.0 .or. langue.gt.nblang ) then
        langue = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Appel de UGINIT par ', nompro
#endif
      call uginit ( ulsort, langue, nfconf, lfconf, codret )
c
      if ( codret.eq.0 ) then
c
      call gusost ( ulsost )
c
      endif
c
c====
c 3. le fichier associe a la sortie standard
c====
#ifdef _DEBUG_HOMARD_
      write (*,*) '3. sortie standard ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> le nom de ce fichier
c
      motcle = mclist
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Appel de UGFINO par ', nompro
#endif
      call ugfino ( motcle, nfsort, lfsort,
     >              nfconf, lfconf,
     >              ulsost, langue, codret )
c
      if ( codret.ne.0 .and. codret.ne.1 ) then
        guimp = 1
        gmimp = 0
        raison = 1
        call ugstop (nompro, ulsost, guimp, gmimp, raison)
      endif
c
c 3.2. ==> l'unite logique associee a cette liste
c          on redirige sur la sortie standard si le fichier
c          n'a pas ete mentionne dans la configuration, sinon
c          on ouvre le fichier correspondant.
c
      if ( codret.eq.1 .or. lfsort.le.0 ) then
c
        ulsort = ulsost
        codret = 0
c
      else
c
        call guoufs ( nfsort, lfsort, ulsort, codret )
        if ( codret.ne.0 ) then
          guimp = 1
          gmimp = 0
          raison = 1
          call ugstop (nompro, ulsost, guimp, gmimp, raison)
        endif
c
        call gurbbu ( ulsort, codret )
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
      endif
#endif
c
c====
c 4. l'environnement
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. environnement ; codret = ', codret
#endif
c
c 4.1. ==> la langue
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (*,texte(1,3)) 'UTINLA', nompro
#endif
      call utinla ( nfconf, lfconf,
     >              ulsort, langue, codret )
      endif
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (*,texte(1,3)) 'GULANM', nompro
#endif
      call gulanm ( langue, codret )
      endif
c
c 4.2. ==> les dates et types de machines
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (*,texte(langue,3)) 'UTDHCO', nompro
#endif
      call utdhco ( numann, datheu )
c
#ifdef _DEBUG_HOMARD_
      write (*,texte(langue,3)) 'UTDHLG', nompro
#endif
      call utdhlg ( ladate, langue )
c
#ifdef _DEBUG_HOMARD_
      write (*,texte(langue,3)) 'DMMACH', nompro
#endif
      call dmmach ( nomare, nomais, typmac,
     >              noarch, systre, systve,
     >              lgcar )
c
      endif
c
c====
c 5. en-tete
c====
#ifdef _DEBUG_HOMARD_
      write (*,*) '5. en-tete ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 5.1. ==> debut de l'en-tete
c
      ulmess = ulsort
c
      write (ulmess,51011) numann
      write (ulmess,51001)
      write (ulmess,51002)
      write (ulmess,51012) nuvers
      write (ulmess,51002)
      write (ulmess,51101)
      write (ulmess,51002)
c
c recopie prudente du message (40 caracteres utiles a priori)
c dans blabla :
c
      do 511 , jaux = 1 , nbrmes
        call dmcpch( messag(langue,jaux), 40, blabla, kaux )
        write (ulmess,51003) blabla
  511 continue
c
      write (ulmess,51002)
      write (ulmess,51101)
      write (ulmess,51002)
c
      call dmcpch( weba, 40, blabla, kaux )
      write (ulmess,51003) blabla
      if ( langue.eq.2 ) then
        call dmcpch( web2, 40, blabla, kaux )
        write (ulmess,51003) blabla
      endif
      write (ulmess,51002)
      write (ulmess,51101)
c
      write (ulsort,texte(langue,7)) ladate
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) nomare(1:lgcar(1))
      write (ulsort,texte(langue,9)) typmac(1:lgcar(3))
      write (ulsort,texte(langue,10)) noarch(1:lgcar(4))
      write (ulsort,texte(langue,11)) systre(1:lgcar(5))
      write (ulsort,texte(langue,12)) systve(1:lgcar(6))
#endif
c
c 5.2. ==> fin de l'en-tete
c
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5))
      endif
c
      endif
c
c====
c 6. second appel de uginit pour initialisation du gestionnaire
c    de mesures de temps calcul et de memoire
c====
#ifdef _DEBUG_HOMARD_
      write (*,*) '6. second appel de uginit ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UGINIT', nompro
#endif
      call uginit ( ulsort, langue, nfconf, lfconf, codret )
c
      endif
c
c====
c 7. acquisition des noms des fichiers utiles au calcul
c====
#ifdef _DEBUG_HOMARD_
      write (*,*) '7. noms des fichiers ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFIAC', nompro
#endif
      call utfiac ( nfconf, lfconf, ulsort, langue, codret )
c
      endif
c
c====
c 8. bilan
c====
#ifdef _DEBUG_HOMARD_
      write (*,*) '8. bilan ; codret = ', codret
#endif
c
      if ( codret.ne.0  ) then
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
