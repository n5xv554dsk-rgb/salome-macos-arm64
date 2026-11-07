      subroutine infcas ( nomail, nosolu,
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
c   INformation : Fichiers Champs ASCII
c   --            -        -      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard iteration n .
c . nosolu . e   . char8  . nom de l'objet solution                    .
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
      parameter ( nompro = 'INFCAS' )
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
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "envca1.h"
#include "nomber.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
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
      integer iaux, jaux
c
      integer pcoono, psomar
      integer pnp2ar, phetar, pmerar, pposif, pfacar
      integer phettr, paretr, pnivtr
      integer advotr
      integer phetqu, parequ, pnivqu
      integer ptrite, phette
      integer adnbrn
      integer adnohn, adnocn, adnoin, lgnoin
      integer adtrhn, adtrcn, adtrin, lgtrin
      integer adquhn, adqucn, adquin, lgquin
      integer option
      integer numfic
c
      integer nbcham, nbfonc, nbprof, nblopg
      integer aninch, aninfo, aninpr, adinlg
      integer nrocha, nrocmp, nrotab
c
      integer decanu(-1:7)
c
      character*6 saux06
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
      texte(1,4) = '(a6,'' FICHIER ASCII POUR GRAPHIQUE'')'
      texte(1,5) = '(35(''=''),/)'
      texte(1,10) = '(''Lancement du trace numero'',i3)'
c
      texte(2,4) = '(a6,'' ASCII FILE FOR GRAPHIC'')'
      texte(2,5) = '(29(''=''),/)'
      texte(2,10) = '(''Beginning of writings #'',i3)'
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
c====
c 2. recuperation des pointeurs
c====
c
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
      write (ulsort,*) '2.2. Tableaux ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 3
      call utad01 ( iaux, nhnoeu,
     >                jaux,
     >                jaux,   jaux,   jaux,
     >              pcoono,   jaux,   jaux,  jaux,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 10
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
      call utad02 (   iaux, nharet,
     >              phetar, psomar,   jaux, pmerar,
     >                jaux,   jaux,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        iaux = 22
        call utad02 (   iaux, nhtria,
     >                phettr, paretr,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 22
        call utad02 (   iaux, nhquad,
     >                phetqu, parequ,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        iaux = 2
        call utad02 (   iaux, nhtetr,
     >                phette, ptrite, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.3. ==> les voisinages
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      iaux = 3
      if ( nbteto.ne.0 ) then
        iaux = iaux*5
      endif
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >              advotr,   jaux,
     >                jaux,   jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ===> tableaux lies a la renumerotation
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
      if ( retrac.ne.0 ) then
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
      if ( requac.ne.0 ) then
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
     >                iaux,   iaux,   iaux,
     >                iaux,   iaux,   iaux,
     >                iaux,   iaux,   iaux,
     >                iaux,   iaux,   iaux,   iaux,
     >              nbmapo, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpent, nbpyra,
     >                iaux,   iaux,
     >                iaux,   iaux,
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
c
      endif
c
c 2.5. ===> tableaux lies a la solution eventuelle
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
      if ( codret.eq.0 ) then
c
      if ( nbcham.eq.0 ) then
        codret = 0
        goto 60
      endif
c
      endif
c
c====
c 3. initialisations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. initialisations ; codret = ', codret
#endif
c
      numfic = 0
c
c====
c 4. questions - reponses pour les sorties
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. questions - reponses ; codret = ', codret
#endif
c
   40 continue
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFCA1', nompro
#endif
      call infca1 ( numfic, option,
     >              nbcham, smem(aninch),
     >              nrocha, nrocmp, nrotab,
     >              ulfido, ulenst, ulsost,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( option.eq.0 ) then
        codret = 0
        goto 60
      endif
c
      endif
c
c====
c 5. ecriture des valeurs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. ecriture des valeurs ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFCA2', nompro
#endif
        call infca2 ( numfic,
     >                nbcham, smem(aninch),
     >                nrocha, nrocmp, nrotab,
     >                rmem(pcoono),
     >                imem(adnocn), imem(adtrcn), imem(adqucn),
     >                imem(adnohn), imem(adtrhn), imem(adquhn),
     >                lgnoin, lgtrin, lgquin,
     >                imem(adnoin), imem(adtrin), imem(adquin),
     >                decanu,
     >                ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      goto 40
c
      endif
c
c====
c 6. la fin
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. La fin ; codret = ', codret
#endif
c
   60 continue
c
      write (ulsort,*) ' '
c
c 6.1. ==> message si erreur
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
