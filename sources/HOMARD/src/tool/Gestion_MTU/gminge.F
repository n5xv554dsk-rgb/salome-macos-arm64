      subroutine gminge ( ulmess, langdf, nfconf, lfconf )
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
c     Gestion de la Memoire : INitialiation de la GEstion
c     -             -         --                  --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ulmess . e   .   1    . unite logique des messages                 .
c . langdf . e   .   1    . langue des messages par defaut             .
c .        .     .        . 1 : francais                               .
c .        .     .        . 2 : anglais                                .
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur du nom du fichier                 .
c ______________________________________________________________________
c
c .  - interet:
c .       initialisation de la gestion de la memoire des tableaux
c .       entiers, reels et character*8.
c .
c ......................................................................
c .
c .  - description des commons -
c . la structure des communs est identique pour les reels, les
c .   entiers et les character*8.
c .   seul l'intitule rappele le type :
c .   reel ( "r") entier ("i") character*8 ("s")
c .
c . commun  gmreel
c .   rmem  : tableau de travail reel dans lequel seront gerees les
c .           allocations.
c . commun  gmenti
c .   imem  : tableau de travail entier dans lequel seront gerees les
c .           allocations.
c . commun  gmstri
c .   smem  : tableau de travail character*8 dans lequel seront gerees
c .           les allocations.
c .
c . commun  gmtrrl
c .   minmer: valeur entiere memorisant la plus petite dimension
c .           du dernier trou afin de connaitre le passage le plus
c .           delicat rencontre au cours de l'allocation. cette valeur
c .           est calculee apres compression (voir minler)
c .   ntrour: valeur entiere . nombre de trous present dans le tableau
c .           reel
c .   ptrour: tableau entier  contenant les pointeurs repertoriant la
c .           position des trous.
c .   ltrour: tableau entier  contenant la longueur des differents trous
c .   nballr: valeur entiere contenant le nombre de tableaux deja alloue
c .   ptallr: tableau entier  contenant les pointeurs repertoriant la
c .           position des tableaux deja alloues
c .   lgallr: tableau entier  contenant la longueur des differents
c             tableaux deja alloues
c .   totalr: valeur entiere cumulant les demandes successives de
c .           memoire pour les tableaux reels
c .   minler: valeur entiere memorisant la plus petite dimension
c .           du dernier trou. en cas de compression cette valeur
c .           qui sera en general differente de celle de minmer
c .           permettra de connaitre la plus petite taille atteinte
c .           par le dernier trou et donc la taille maximum que peut
c .           atteindre le common (voir gmfin)
c .
c . commun  gmtren
c .   structure rigoureusement identique  a celle de gmtrrl, sa fonction
c .   etant de gerer les trous et les tableaux presents dans le tableau
c .   entier. ses elements se terminent par un "i" au lieu d'un "r".
c .
c . commun  gmtrst
c .   structure rigoureusement identique  a celle de gmtrrl, sa fonction
c .   etant de gerer les trous et les tableaux presents dans le tableau
c .   character*8. ses elements se terminent par un "s" au lieu d'un "r"
c .
c . commun  gmalrl
c .   nommxr: chaine de caractere(*8) contenant le nom du plus grand
c .           tableau associe a minmer
c .   nomalr: tableau de chaines de caracteres contenant le nom associe
c .           a chaque tableau deja alloue.
c .
c . commun  gmalen
c .   structure rigoureusement identique a celle de gmalrl, sa fonction
c .   etant de gerer les chaines de caracteres associees au tableau
c .   entier. ses elements se terminent par un "i" au lieu d'un "r".
c .
c . commun  gmalst
c .   structure rigoureusement identique a celle de gmalrl, sa fonction
c .   etant de gerer les chaines de caracteres associees au tableau
c .   character*8. ses elements se terminent par un "s" au lieu d'un "r"
c .
c . commun gmindf
c .   memorise un indicateur d'utilisation : 0 on initialise,
c .   1 on n'initialise pas
c .
c ......................................................................
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
      parameter ( nompro = 'GMINGE' )
c
#include "genbla.h"
#include "gelggt.h"
c
#include "gmgmve.h"
c
#include "gmmaxt.h"
#include "gmptrd.h"
#include "gmmatc.h"
#include "gmlgen.h"
c
c 0.2. ==> communs
c
#include "gmtail.h"
#include "gmtyge.h"
#include "gmtyar.h"
#include "gmindf.h"
c
#include "envex1.h"
#include "gmcoer.h"
#include "gmimpr.h"
#include "gmlang.h"
#include "gmopim.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "gmtrrl.h"
#include "gmtren.h"
#include "gmtrst.h"
c
#include "gmalrl.h"
#include "gmalen.h"
#include "gmalst.h"
c
#include "gmadui.h"
#include "gmadur.h"
#include "gmadus.h"
c
#include "gmindi.h"
#include "gmindr.h"
#include "gminds.h"
c
#include "gmtenb.h"
#include "gmteno.h"
c
c 0.3. ==> arguments
c
      character *(*) nfconf
c
      integer ulmess, langdf, lfconf
c
c 0.4. ==> variables locales
c
#include "gedita.h"
c
      integer iaux, code
c
      integer ad0, ad1, ntrou0, i
      integer nenti, nreel, nch08
      integer guimp, gmimp, raison
      integer codret
c
      character *200 nfdico
c
      integer lfdico, nfois
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
#include "motcle.h"
c
c 0.5. ==> initialisations
c
      data nfois / 1 /
c ______________________________________________________________________
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      if ( langdf.ge.1 .and. langdf.le.nblang ) then
        langue = langdf
      else
        langue = 1
      endif
      write (ulmess,texte(langue,1)) 'Entree', nompro
#endif
c
      texte(1,4) = '(/,''La gestion de la memoire est statique.'')'
      texte(1,5) =
     > '(/,''La gestion de la memoire est semi-dynamique.'')'
      texte(1,6) = '(/,''La gestion de la memoire est dynamique.'')'
      texte(1,7) = '(/,a12,/,''... Adresse du commun : '',i19)'
      texte(1,8) = '(''... Adresse de la memoire : '',i15)'
      texte(1,9) = '(''... Place reservee : '',i15)'
      texte(1,10) = '(/,''Programmes du gestionnaire de memoire :'')'
      texte(1,11) =
     > '(''. Version : '',i11,/,''. Sous-version : '',i6)'
c
      texte(2,4) = '(/,''A static memory management is used.'')'
      texte(2,5) =
     >        '(/,''A semi-dynamic memory management is used.'')'
      texte(2,6) = '(/,''A dynamic memory management is used.'')'
      texte(2,7) = '(/,a12,/,''... Common address : '',i19)'
      texte(2,8) = '(''... Memory address : '',i15)'
      texte(2,9) = '(''... Reserved space : '',i15)'
      texte(2,10) = '(/,''Programms of memory manager :'')'
      texte(2,11) = '(''. Version : '',i11,/,''. Release : '',i6)'
c
c====
c 1. mise en place
c====
cgn       write (*,*) 'nfois = ', nfois
c
c 1.1. ==> On commence par arreter brutalement s'il y a une erreur
c          avant la connaissance de l'option retenue
c
      typarr = 0
c
      if ( nfois.le.1 ) then
        nfois = nfois + 1
c
c pour les cas ou tout se passe mal, on initialise
c pour entrer dans ugstop dans des conditions moins catastrophiques:
c
        modgm = 1
        ntroui = 0
        nballi = 0
        totali = 0
        imem(1) = 0
        ntrour = 0
        nballr = 0
        totalr = 0
        rmem(1) = 0.0d0
        ntrous = 0
        nballs = 0
        totals = 0
        write(smem(1),'(i8)') 0
      endif
c
c 1.2. ==> initialisation du numero d'unite logique associee aux
c          messages du gestionnaire de memoire et de la langue associee
c          par defaut
c
      call gmmess (ulmess)
c
      call gmlanm (langdf)
c
c 1.3. ==> initialisation de l'option supplementaire d'impression :
c          rien par defaut
c
      imprgm = 1
c
c 1.4. ==> recuperation du nom du fichier qui contient le
c          dictionnaire des objets structures
c
#ifdef _DEBUG_HOMARD_
      write (*,texte(langue,3)) 'UGFINO', nompro
#endif
      call ugfino ( mcdico, nfdico, lfdico,
     >              nfconf, lfconf,
     >              ulsort , langdf, coergm )
c
      if ( coergm.ne.0 .and. lfdico.gt.0 ) then
        guimp = 1
        gmimp = 0
        raison = 1
        call ugstop( nompro, ulsort, guimp, gmimp, raison)
      endif
c
c 1.5. ==> mode de gestion de la memoire
c
#ifdef _DEBUG_HOMARD_
      write (*,texte(langue,3)) 'GMMOGE', nompro
#endif
c
      call gmmoge ( modgm, typarr,
     >              nenti, nreel, nch08,
     >              nfconf, lfconf,
     >              coergm )
c
      if ( coergm.ne.0 ) then
         guimp = 1
         gmimp = 0
         raison = 1
         call ugstop( nompro, ulsort, guimp, gmimp, raison)
      endif
c
c 1.6. ==> initialisations et memorisation
c
#ifdef _DEBUG_HOMARD_
      write (*,texte(langue,3)) 'DMSIZE', nompro
#endif
      call dmsize(tentie,treel,tchain)
c
      if (modgm.eq.2) then
        ntrou0 = 0
        do 16 , i = 1 , 8
          admem(i) = 0
   16   continue
      else
        ntrou0 = 1
      endif
c
c====
c 2. valeurs non definies
c====
c
#ifdef _DEBUG_HOMARD_
      write (*,texte(langue,3)) 'DMINDF', nompro
#endif
      call dmindf ( iindef, rindef, sindef )
c
      lindef = 0
c
c====
c 3. initialisations globales
c====
c
c 3.1. ==> aucun tableau n'est encore alloue
c
      do 31 , iaux = 1 , maxtab
c
         nomali(iaux) = sindef
         ptalli(iaux) = iindef
         lgalli(iaux) = iindef
         adui(iaux)   = iindef
c
         nomalr(iaux) = sindef
         ptallr(iaux) = iindef
         lgallr(iaux) = iindef
         adur(iaux)   = iindef
c
         nomals(iaux) = sindef
         ptalls(iaux) = iindef
         lgalls(iaux) = iindef
         adus(iaux)   = iindef
c
   31 continue
c
c 3.2. ==> aucun trou n'est encore present
c
      do 32 , iaux = 1 , maxtrs
c
         ptroui(iaux) = iindef
         ltroui(iaux) = iindef
c
         ptrour(iaux) = iindef
         ltrour(iaux) = iindef
c
         ptrous(iaux) = iindef
         ltrous(iaux) = iindef
c
   32 continue
c
c 3.3. ==> initialisation du nombre de tableaux temporaires alloues
c
      mxtbtp = 0
c
c    NB: il y a 3 types possibles d'objets simples, et maxtab objets
c        simples au maximum dans chaque type. Par ailleurs, il y a
c        au maximum nobjx objets structures.
c
      do 33 iaux = 1 , (3*maxtab) + nobjx
         numete(iaux) = 0
         nomalt(iaux) = sindef
   33 continue
c
c====
c 4. initialisation associee aux grandeurs entieres
c====
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Etape 4 ; entier'
#endif
c
      call dmloci (imem,ad0)
c
      if ( modgm.eq.0) then
        ad1 = ad0
        coergm = 0
        iaux = nenti - ptrdeb + 1
      elseif ( modgm.eq.1) then
        call gbalme('i',nenti+ptrdeb,ad1)
        iaux = nenti
      else
        ad1 = 0
        coergm = 0
        iaux = nenti - ptrdeb + 1
      endif
c
      if ( coergm.ne.0) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
        write (ulsort,*) ' allocation de ',nenti,' entiers'
        write (ulsort,*) ' impossible '
        call ugstop( nompro,ulsort,1,1,1)
      endif
c
      adcom(1) = ad0
      admem(1) = ad1
CGN   imem(0) = iindef
      imem(1) = nenti
      ntroui    = ntrou0
      ptroui(1) = ptrdeb
      ltroui(1) = iaux
c
      minmei    = ltroui(1)
      minlei    = ltroui(1)
      nommxi    = '        '
      nballi    = 0
      totali    = nenti - iaux
c
c====
c 5. initialisation des grandeurs reelles
c====
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Etape 5 ; reel'
#endif
c
      call dmlocr (rmem,ad0)
c
      if ( modgm.eq.0) then
        ad1 = ad0
        coergm = 0
        iaux = nreel - ptrdeb + 1
      elseif ( modgm.eq.1) then
        call gbalme('r',nreel+ptrdeb,ad1)
        iaux = nreel
      else
        ad1 = 0
        coergm = 0
        iaux = nreel - ptrdeb + 1
      endif
c
      if ( coergm.ne.0) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,*) ' allocation de ',nreel,' reels'
        write (ulsort,*) ' impossible '
        call ugstop( nompro,ulsort,1,1,1)
      endif
c
      adcom(2) = ad0
      admem(2) = ad1
CGN   rmem(0) = rindef
      rmem(1) = dble(nreel)
      ntrour    = ntrou0
      ptrour(1) = ptrdeb
      ltrour(1) = iaux
c
      minmer    = ltrour(1)
      minler    = ltrour(1)
      nommxr    = '        '
      nballr    = 0
      totalr    = nreel - iaux
c
c====
c 6. initialisation associee aux grandeurs character*8
c====
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Etape 6 ; caracteres'
#endif
c
      call dmlocs (smem,ad0)
c
      if ( modgm.eq.0) then
        ad1 = ad0
        coergm = 0
        iaux = nch08 - ptrdeb + 1
      elseif ( modgm.eq.1) then
        call gbalme('s',nch08+ptrdeb,ad1)
        iaux = nch08
      else
        ad1 = 0
        coergm = 0
        iaux = nch08 - ptrdeb + 1
      endif
c
      if ( coergm.ne.0) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,*) ' allocation de ',nch08,' ch*8'
        write (ulsort,*) ' impossible '
        call ugstop( nompro,ulsort,1,1,1)
      endif
c
      adcom(3) = ad0
      admem(3) = ad1
CGN   write(smem(0),'(i8)') sindef
      write(smem(1),'(i8)') nch08
      ntrous    = ntrou0
      ptrous(1) = ptrdeb
      ltrous(1) = iaux
c
      minmes    = ltrous(1)
      minles    = ltrous(1)
      nommxs    = '        '
      nballs    = 0
      totals    = nch08 - iaux
c
c====
c 8. initialisation des tables des types d'objet structure
c====
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Etape 8 ; objet structure'
#endif
c
      call gbitos ( nfdico, lfdico, coergm)
c
      if (coergm.ne.0) then
        write (ulsort,*) nompro,' -> gbitos -> coergm : ',coergm
        call ugstop( nompro,ulsort,1,1,1)
      endif
c
c====
c 9.  on archive l'information pour le gestionnaire global
c====
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Etape 9 ; archivage'
#endif
c
      code = 1
      call ugtabl ( code, tabges, ulsort)
c
      tabges(3) = 1
c
      code = 0
      call ugtabl ( code, tabges, ulsort)
c
c====
c 10. Impression recapitulative
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,modgm+4))
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10))
      write (ulsort,texte(langue,11)) nuvegm, nusvgm
c
      if ( modgm.le.1 ) then
c
         iaux = imem(1)
         write (ulsort,texte(langue,7)) 'Entiers     ', adcom(1)
         write (ulsort,texte(langue,8)) admem(1)
         write (ulsort,texte(langue,9)) iaux
c
         iaux = int(rmem(1))
         write (ulsort,texte(langue,7)) 'Reels       ', adcom(2)
         write (ulsort,texte(langue,8)) admem(2)
         write (ulsort,texte(langue,9)) iaux
c
         read(smem(1),'(i8)') iaux
         write (ulsort,texte(langue,7)) 'Caracteres*8', adcom(3)
         write (ulsort,texte(langue,8)) admem(3)
         write (ulsort,texte(langue,9)) iaux
c
      else
c
         write (ulsort,texte(langue,7)) 'Entiers     ', adcom(1)
c
         write (ulsort,texte(langue,7)) 'Reels       ', adcom(2)
c
         write (ulsort,texte(langue,7)) 'Caracteres*8', adcom(3)
c
      endif
#endif
c
c====
c 11. la fin
c====
c
      codret = coergm
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
