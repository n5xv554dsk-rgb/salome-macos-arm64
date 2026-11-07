      subroutine infvec ( nomail, nosolu, action,
     >                    ulfido, ulenst, ulsost,
     >                    lgetco, taetco,
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
c   INformation : Fichiers VECtoriels
c   --            -        ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard iteration n .
c . nosolu . e   . char8  . nom de l'objet solution                    .
c . action . e   . char8  . action en cours                            .
c . ulfido . e   .   1    . unite logique du fichier de donnees correct.
c . ulenst . e   .   1    . unite logique de l'entree standard         .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans les memoires             .
c .        .     .        . 3 : probleme dans les fichiers             .
c .        .     .        . 5 : probleme autre                         .
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
      parameter ( nompro = 'INFVEC' )
c
cfonc      integer nbtych
cfonc      parameter ( nbtych = 5 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "nbfami.h"
#include "envca1.h"
#include "envada.h"
#include "nomber.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      character*8 action
      character*8 nomail, nosolu
c
      integer ulfido, ulenst, ulsost
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nretap, nrsset
      integer iaux, jaux, kaux
      integer ideb, ifin
c
      integer pcoono, adcocs
      integer psomar
      integer pnp2ar, phetar, pmerar
      integer phettr, paretr, pnivtr, adnmtr
      integer advotr, adpptr
      integer advoqu, adppqu
      integer phetqu, parequ, pnivqu, adnmqu
      integer ptrite, phette
      integer pquahe, phethe
      integer pfacpy, phetpy
      integer pfacpe, phetpe
      integer pposif, pfacar
      integer ppovos, pvoiso
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
      integer pfamte, pcfate
      integer pfamhe, pcfahe
      integer pfampy, pcfapy
      integer pfampe, pcfape
      integer ptrav1, ptrav2, ptrav3, ptrav4, ptrav5
      integer ptra11, ptra12, ptra13, ptra14
      integer ptra15, ptra16
      integer ptrac1, ptrab1
      integer adnbrn
      integer adarcn
      integer adnohn, adnocn, adnoin, lgnoin
      integer adtrhn, adtrcn, adtrin, lgtrin
      integer adquhn, adqucn, adquin, lgquin
      integer option, infsup, typcof, typcop, typbor, optnoe
      integer porpay, triedr
      integer numfic
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      integer nbcham, nbfonc, nbprof, nblopg
      integer aninch, aninfo, aninpr, adinlg
      integer nrocha, nrocmp, nrotab
c
      integer decanu(-1:7)
c
      integer nbblfa, nbblvo
c
      double precision anglex, angley, anglez
      double precision xyzmiz(3), xyzmaz(3)
      double precision vafomi, vafoma
c
      logical zoom
c
      character*6 saux06
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1, ntrav2, ntrav3, ntrav4, ntrav5
      character*8 ntra11, ntra12, ntra13, ntra14
      character*8 ntra15, ntra16
      character*8 ntrac1, ntrab1
      character*16 nomcmp
      character*64 nomcha
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
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
      texte(1,4) = '(a6,'' FICHIERS Xfig'')'
      texte(1,5) = '(20(''=''),/)'
      texte(1,6) = '(''Lancement du trace numero'',i3)'
      texte(1,7) = '(''Action en cours : '',a)'
c
      texte(2,4) = '(a6,'' Xfig FILES'')'
      texte(2,5) = '(17(''=''),/)'
      texte(2,6) = '(''Beginning of writings #'',i3)'
      texte(2,7) = '(''Current action : '',a)'
c
#include "impr03.h"
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux06, iaux, codret )
c
c 1.5 ==> le titre
c
      write (ulsort,texte(langue,4)) saux06
      write (ulsort,texte(langue,5))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) action
#endif
c
c====
c 2. recuperation des pointeurs
c====
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c 2.2. ==> tableaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. tableaux ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 3*19
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 ( iaux, nhnoeu,
     >                jaux,
     >                jaux,   jaux,   jaux,
     >              pcoono,   jaux,   jaux, adcocs,
     >              ulsort, langue, codret )
c
      iaux = 2590
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 (   iaux, nharet,
     >              phetar, psomar,   jaux, pmerar,
     >              pfamar, pcfaar,   jaux,
     >              jaux  , pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbftri.ne.0 ) then
c
        iaux = 37
        if ( nbtrto.ne.0 ) then
          iaux = iaux*154
          if ( mod(mailet,2).eq.0 ) then
            iaux = iaux*19
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 (   iaux, nhtria,
     >                phettr, paretr,   jaux,   jaux,
     >                pfamtr, pcfatr,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                adnmtr,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
        iaux = 5698
        if ( mod(mailet,3).eq.0 ) then
          iaux = iaux*19
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 (   iaux, nhquad,
     >                phetqu, parequ,   jaux,   jaux,
     >                pfamqu, pcfaqu,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                adnmqu,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
        iaux = 518
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        call utad02 (   iaux, nhtetr,
     >                phette, ptrite, jaux  , jaux,
     >                pfamte, pcfate,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
        iaux = 518
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 (   iaux, nhhexa,
     >                phethe, pquahe, jaux  , jaux,
     >                pfamhe, pcfahe,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 ) then
c
        iaux = 518
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        call utad02 (   iaux, nhpyra,
     >                phetpy, pfacpy, jaux  , jaux,
     >                pfampy, pcfapy,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
        iaux = 518
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 (   iaux, nhpent,
     >                phetpe, pfacpe, jaux  , jaux,
     >                pfampe, pcfape,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.3. ==> les voisinages
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. voisinages ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nomail, nhvois,
     >                iaux,   jaux,   jaux,   jaux,
     >              ppovos, pvoiso,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      iaux = 3
      if ( nbteto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*5
      endif
      if ( nbheto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*7
      endif
      if ( nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*221
      endif
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >              advotr, advoqu,
     >                jaux,   jaux, adpptr, adppqu,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ===> tableaux lies a la renumerotation
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. renumerotation ; codret', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,norenu)
      call gmprsx (nompro,norenu//'.Nombres')
      call gmprsx (nompro,norenu//'.TrHOMARD')
      call gmprsx (nompro,norenu//'.TrCalcul')
      call gmprsx (nompro,norenu//'.InfoSupE')
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_no', nompro
#endif
      iaux = -1
      jaux = 210
      call utre03 ( iaux, jaux, norenu,
     >              renoac, renoto, adnohn, adnocn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE04_no', nompro
#endif
      iaux = -1
      jaux = -11
      call utre04 ( iaux, jaux, norenu,
     >              lgnoin, adnoin,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_ar', nompro
#endif
      iaux = 1
      jaux = -21
      call utre03 ( iaux, jaux, norenu,
     >                kaux, rearto,   kaux, adarcn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( nbtrac.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTRE03_tr', nompro
#endif
        iaux = 2
        jaux = -210
        call utre03 ( iaux, jaux, norenu,
     >                retrac, retrto, adtrhn, adtrcn,
     >                ulsort, langue, codret)
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE04_tr', nompro
#endif
        iaux = 2
        jaux = -11
        call utre04 ( iaux, jaux, norenu,
     >                lgtrin, adtrin,
     >                ulsort, langue, codret)
c
       endif
c
      endif
c
      if ( nbquac.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTRE03_qu', nompro
#endif
        iaux = 4
        jaux = -210
        call utre03 ( iaux, jaux, norenu,
     >                requac, requto, adquhn, adqucn,
     >                ulsort, langue, codret)
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE04_qu', nompro
#endif
        iaux = 4
        jaux = -11
        call utre04 ( iaux, jaux, norenu,
     >                lgquin, adquin,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
      if ( codret.eq.0 ) then
c
cgn      call gmprsx ( nompro, norenu//'.Nombres' )
      call gmadoj ( norenu//'.Nombres', adnbrn, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNBMH', nompro
#endif
      call utnbmh ( imem(adnbrn),
     >              nbnois, nbnoei, nbnomp,
     >              nbnop1, nbnop2, nbnoim,
     >                iaux,   iaux,   iaux,
     >              nbelem, nbmaae, nbmafe, nbmane,
     >              nbmapo, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpent, nbpyra,
     >              numano, numael,
     >              nvoare, nvosom,
     >              ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbmapo', nbmapo
      write(ulsort,90002) 'nbsegm', nbsegm
      write(ulsort,90002) 'nbtria', nbtria
      write(ulsort,90002) 'nbtetr', nbtetr
      write(ulsort,90002) 'nbquad', nbquad
      write(ulsort,90002) 'nbhexa', nbhexa
      write(ulsort,90002) 'nbpent', nbpent
      write(ulsort,90002) 'nbpyra', nbpyra
#endif
c
      decanu(-1) = 0
      decanu(3) = 0
      decanu(2) = nbtetr
      decanu(1) = nbtetr + nbtria
      decanu(0) = nbtetr + nbtria + nbsegm
      decanu(4) = nbtetr + nbtria + nbsegm + nbmapo
      decanu(6) = nbtetr + nbtria + nbsegm + nbmapo + nbquad
      decanu(5) = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa
      decanu(7) = nbtetr + nbtria + nbsegm + nbmapo + nbquad + nbhexa
     >          + nbpyra
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'decanu', decanu
#endif
c
      endif
c
c 2.5. ===> tableaux lies a la solution eventuelle
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.5. Solution ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nosolu)
      call gmprsx (nompro,nosolu//'.InfoCham')
      call gmprsx (nompro,nosolu//'.InfoPaFo')
      call gmprsx (nompro,nosolu//'.InfoProf')
      call gmprsx (nompro,nosolu//'.InfoLoPG')
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCASO', nompro
#endif
      call utcaso ( nosolu,
     >              nbcham, nbfonc, nbprof, nblopg,
     >              aninch, aninfo, aninpr, adinlg,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. initialisations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. initialisations ; codret', codret
#endif
c
      numfic = 0
c
c====
c 4. questions - reponses pour les sorties
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. questions - reponses ; codret', codret
#endif
c
   40 continue
c
c 4.1. ==> choix de la sortie, des angles de vue, des couleurs, etc.
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFVE1', nompro
#endif
      call infve1 ( option,
     >              typcof, typcop, typbor, optnoe,
     >              porpay, triedr,
     >              anglex, angley, anglez,
     >              zoom, xyzmiz, xyzmaz,
     >              vafomi, vafoma,
     >              rmem(adcocs+1), rmem(adcocs+4), rmem(adcocs+7),
     >              nbcham, smem(aninch),
     >              nomcha, nomcmp, nrocha, nrocmp, nrotab,
     >              ulfido, ulenst, ulsost,
     >              ulsort, langue, codret )
c
      endif
c
c 4.2. ==> traitement des options
c
      if ( codret.eq.0 ) then
c
      if ( option.eq.0 ) then
        codret = 0
        goto 80
      else
        if ( option.lt.0 ) then
          iaux = -option
        else
          iaux = mod(option,100)
        endif
        if ( iaux.le.7 ) then
          infsup = iaux - 1
        elseif ( iaux.eq.8 ) then
          infsup = 531
        else
          infsup = 462
        endif
      endif
c
      endif
c
c====
c 5. preparatifs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. preparatifs ; codret', codret
      write (ulsort,90002) 'option', option
#endif
c
c 5.1. ==> recherche des blocs connexes
c
      if ( option.lt.0 ) then
c
c 5.1.1. ==> adresses
c
        if ( codret.eq.0 ) then
c
        iaux = nbquto + 1 + nbtrto
        call gmalot ( ntrac1, 'entier  ', iaux, ptrac1, codre1 )
c
        iaux = nbteto + nbheto + nbpeto + nbpyto
        call gmalot ( ntrab1, 'entier  ', iaux, ptrab1, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = max ( nbtrac + nbquac,
     >               nbteac + nbheac + nbpyac + nbpeac )
        call gmalot ( ntrav1, 'entier  ', iaux, ptrav1, codre1 )
        call gmalot ( ntrav2, 'entier  ', nbnoto, ptrav2, codre2 )
        call gmalot ( ntrav3, 'entier  ', nbarto, ptrav3, codre3 )
        iaux = nbquto + nbtrto + 1
        call gmalot ( ntrav4, 'entier  ', iaux, ptrav4, codre4 )
        iaux = nbquto + nbtrto + 1
        call gmalot ( ntrav5, 'entier  ', iaux, ptrav5, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        jaux = nbquto + nbtrto + 1
        call gmalot ( ntra11, 'entier  ', jaux, ptra11, codre1 )
        call gmalot ( ntra12, 'entier  ', nbnoto, ptra12, codre2 )
        call gmalot ( ntra13, 'entier  ', nbarto, ptra13, codre3 )
        jaux = nbquto + nbtrto
        call gmalot ( ntra14, 'entier  ', jaux, ptra14, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        call gmalot ( ntra15, 'entier  ', nbarto, ptra15, codre1 )
        call gmalot ( ntra16, 'entier  ', nbarto, ptra16, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
c 5.1.2. ==> traitement
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '51.2. traitement ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        if ( nbteto.gt.0 .or. nbheto.gt.0 .or.
     >       nbpyto.gt.0 .or. nbpeto.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          jaux = ulsort
#else
          jaux = 0
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11B', nompro
#endif
          call utb11b ( nbblvo,
     >                  imem(phetar), imem(psomar),
     >                  imem(phettr), imem(paretr),
     >                  imem(phetqu), imem(parequ),
     >                  imem(phette), imem(ptrite),
     >                  imem(phethe), imem(pquahe),
     >                  imem(phetpy), imem(pfacpy),
     >                  imem(phetpe), imem(pfacpe),
     >                  imem(ppovos), imem(pvoiso),
     >                  imem(pposif), imem(pfacar),
     >                  imem(advotr), imem(adpptr),
     >                  imem(advoqu), imem(adppqu),
     >                  imem(pfamar), imem(pcfaar),
     >                  imem(pfamtr), imem(pcfatr),
     >                  imem(pfamqu), imem(pcfaqu),
     >                  imem(pfamte), imem(pcfate),
     >                  imem(pfamhe), imem(pcfahe),
     >                  imem(pfampy), imem(pcfapy),
     >                  imem(pfampe), imem(pcfape),
     >                  imem(ptrav1), imem(ptrav2),
     >                  imem(ptrav3), imem(ptrav5),
     >                  imem(ptra11), imem(ptra12),
     >                  imem(ptra13), imem(ptra14),
     >                  imem(ptra15), imem(ptra16),
     >                  imem(ptrab1),
     >                  jaux, ulsort, langue, codret )
c
          endif
c
        else
          nbblvo = 0
        endif
c
        if ( codret.eq.0 ) then
c
c       on examine toutes les faces actives du calcul
c
        jaux = nbquto + nbtrto
        do 51 ,iaux = 0, jaux
          imem(ptrav4+iaux) = 1
   51   continue
        imem(ptrav4+nbquto) = 0
        iaux = 2
#ifdef _DEBUG_HOMARD_
        jaux = ulsort
#else
        jaux = 0
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11C', nompro
#endif
        call utb11c ( nbblfa, iaux, imem(ptrav4),
     >                imem(phetar), imem(psomar),
     >                imem(phettr), imem(paretr),
     >                imem(phetqu), imem(parequ),
     >                imem(ppovos), imem(pvoiso),
     >                imem(pposif), imem(pfacar),
     >                imem(pfamar), imem(pcfaar),
     >                imem(pfamtr), imem(pcfatr),
     >                imem(pfamqu), imem(pcfaqu),
     >                imem(ptrav1), imem(ptrav2), imem(ptrav3),
     >                imem(ptra15), imem(ptra16),
     >                imem(ptrac1),
     >                jaux, ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmlboj ( ntrav1, codre1 )
        call gmlboj ( ntrav2, codre2 )
        call gmlboj ( ntrav3, codre3 )
        call gmlboj ( ntrav4, codre4 )
        call gmlboj ( ntrav5, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        call gmlboj ( ntra11, codre1 )
        call gmlboj ( ntra12, codre2 )
        call gmlboj ( ntra13, codre3 )
        call gmlboj ( ntra14, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        call gmlboj ( ntra15, codre1 )
        call gmlboj ( ntra16, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
      endif
cgn      call gmprsx (nompro,ntrac1)
cgn      call gmprsx (nompro,ntrab1)
c
      endif
c
c 5.2. ==> recherche des niveaux des volumes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.2. niveaux des volumes ; codret', codret
#endif
c
      if ( option.gt.100 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = nbteto + nbheto + nbpeto + nbpyto
        call gmalot ( ntrab1, 'entier  ', iaux, ptrab1, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFVE7', nompro
#endif
        call infve7 ( imem(ptrab1),
     >                imem(pnivtr), imem(pnivqu),
     >                imem(ptrite), imem(pquahe),
     >                imem(pfacpy), imem(pfacpe),
     >                ulsort, langue, codret )
c
        endif
cgn       call gmprsx(nompro,ntrab1)
c
      endif
c
c 5.3. ==> allocation des tableaux :
c
c          Les aretes :
c          . Les aretes isolees sont visualisables.
c          . Si on a demande de tracer les bords, on les represente.
c          "nbarvi" est le nombre d'aretes visualisables
c          tableau nnarvi(6,nbarvi) :
c             1 : niveau de l'arete a afficher
c             2 : numero HOMARD de l'arete
c             3, 4 : numero des 2 noeuds
c             5 : 0, si isolee, 1 si bord
c             6 : numero de l'eventuel noeud P2
c
c          Les faces :
c          En dimension 2, toutes les faces actives sont visualisables.
c          En dimension 3, seules les faces de bord d'elements 3D actifs
c          ou les faces isolees sont visualisables.
c          "nbtrvi" est le nombre de triangles visualisables
c          tableau nntrvi(9,nbtrvi) :
c             2 : numero HOMARD du triangle
c             3, 4, 5 : numeros des noeuds p1
c             6 : famille du triangle
c             7, 8, 9 : numeros des noeuds p2
c             10 : numero du noeud interne
c
c          "nbquvi" est le nombre de quadrangles visualisables
c          tableau nnquvi(11,nbquvi) :
c             2 : numero HOMARD du quadrangle
c             3, 4, 5, 6 : numeros des noeuds p1
c             7 : famille du quadrangle
c             8, 9, 10, 11 : numeros des noeuds p2
c             12 : numero du noeud interne
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.3. allocation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
c     tableau auxiliaire tabaux pour infve2
      iaux = max(nbfare,nbftri,nbfqua)
      call gmalot ( ntrav1, 'entier  ', iaux, ptrav1, codre1 )
c
c     tableau auxiliaire tbaux2 pour infve2
      iaux = nbquto + 1 + max(nbarto,nbtrto)
      call gmalot ( ntrav2, 'entier  ', iaux, ptrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 6. Trace pour tous les blocs ou tous les niveaux
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. trace ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( option.lt.0 ) then
c
        ideb = 1
        if ( nbteto.gt.0 .or. nbheto.gt.0 .or.
     >       nbpyto.gt.0 .or. nbpeto.gt.0 ) then
          ifin = nbblvo
        else
          ifin = nbblfa
        endif
c
      elseif ( option.gt.100 ) then
c
        ideb = nivinf
        ifin = nivsup
c
      else
c
        ideb = 0
        ifin = 0
c
      endif
c
      do 61 , iaux = ideb , ifin
c
        if ( codret.eq.0 ) then
c
        if ( option.lt.0 ) then
          jaux = iaux
          kaux = -1
        elseif ( option.gt.100 ) then
          jaux = 0
          kaux = iaux
        else
          jaux = 0
          kaux = -1
        endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) jaux
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFVE0', nompro
#endif
        call infve0 ( action, jaux, kaux, numfic,
     >                infsup, typcof, typcop, typbor, optnoe, porpay,
     >                zoom, triedr,
     >                nbcham, smem(aninch),
     >                nomcha, nomcmp, nrocha, nrocmp, nrotab,
     >                rmem(pcoono),
     >                imem(psomar), imem(pnp2ar),
     >                imem(phetar), imem(pmerar),
     >                imem(pposif), imem(pfacar),
     >                imem(paretr), imem(phettr), imem(pnivtr),
     >                imem(adnmtr),
     >                imem(advotr), imem(adpptr),
     >                imem(pfamtr),
     >                imem(parequ), imem(phetqu), imem(pnivqu),
     >                imem(adnmqu),
     >                imem(advoqu), imem(adppqu),
     >                imem(pfamqu),
     >                imem(adnocn),
     >                imem(adarcn), imem(adtrcn), imem(adqucn),
     >                imem(adnohn), imem(adtrhn), imem(adquhn),
     >                lgnoin, lgtrin, lgquin,
     >                imem(adnoin), imem(adtrin), imem(adquin),
     >                decanu,
     >                anglex, angley, anglez,
     >                xyzmiz, xyzmaz, vafomi, vafoma,
     >                imem(ptrav1), imem(ptrav2),
     >                imem(ptrac1), imem(ptrab1),
     >                ulsost,
     >                ulsort, langue, codret )
c
        endif
c
   61 continue
c
      endif
c
c====
c 7. menage
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. menage ; codret', codret
#endif
c
c 7.1. ==> suppression des tableaux temporaires
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      if ( option.lt.0 ) then
c
        call gmlboj ( ntrac1, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
      if ( option.gt.100 ) then
c
        call gmlboj ( ntrab1, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
      endif
c
c 7.2. ==> nouveau trace
c
      if ( codret.eq.0 ) then
c
      goto 40
c
      endif
c
c====
c 8. la fin
c====
c
   80 continue
c
      write (ulsort,*) ' '
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
c=======================================================================
      endif
c=======================================================================
c
      end
