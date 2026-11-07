      subroutine pcmafa ( nocmap, nohmap,
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
c    aPres adaptation - Conversion de MAillage - FAmilles
c     -                 -             --         --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocmap . e   . char8  . nom de l'objet maillage de calcul iter. n+1.
c . nohmap . e   . char8  . nom de l'objet maillage homard iter. n+1   .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'PCMAFA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "nbutil.h"
#include "nombsr.h"
#include "nbfami.h"
c
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*8 nocmap, nohmap
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
c
      integer adhono, admpho, adhoar, adhotr, adhoqu
      integer pfamno, pcfano
      integer pfammp, pcfamp
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
      integer pfamte, pcfate
      integer pfamhe, pcfahe
      integer pfampy, pcfapy
      integer pfampe, pcfape
      integer adeqpo, adeqin
      integer adeqno, adeqmp, adeqar, adeqtr, adeqqu
      integer adeqte, adeqhe
      integer nbeqnn, nbeqmn, nbeqan, nbeqtn, nbeqqn
c
      integer ptypel
c
      integer rvnoac, adnohp, rvnoto, adnocp
      integer rvmpac, admphp, rvmpto, admpcp
      integer rvarac, adarhp, rvarto, adarcp
      integer rvtrac, adtrhp, rvtrto, adtrcp
      integer rvquac, adquhp, rvquto, adqucp
      integer rvteac, adtehp, rvteto, adtecp
      integer rvheac, adhehp, rvheto, adhecp
      integer rvpyac, adpyhp, rvpyto, adpycp
      integer rvpeac, adpehp, rvpeto, adpecp
c
      integer adnomb
c
      integer iaux, jaux
      integer iaux1, iaux2, iaux3, iaux4, iaux5, iaux6, iaux7,iaux8
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8, codre9
      integer codre0
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 nhnofa, nhmpfa, nharfa, nhtrfa, nhqufa
      character*8 nhtefa, nhhefa, nhpyfa, nhpefa
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,7) = '(5x,''Conversion HOMARD ----> '',a18,/)'
c
      texte(2,7) = '(5x,''Conversion HOMARD ----> '',a18,/)'
c
#include "impr03.h"
c
c====
c 2. structure generale
c====
c
c 2.1. ==> Nom des structures
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nohmap,
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
c 2.2. ==> Verification du type de calcul
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Verification ; codret', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
#include "mslve4.h"
      endif
#endif
c
c 2.3. ==> Nom des structures des familles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. structures familles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nhnoeu//'.Famille', nhnofa, codre1 )
      call gmnomc ( nhmapo//'.Famille', nhmpfa, codre2 )
      call gmnomc ( nharet//'.Famille', nharfa, codre3 )
      call gmnomc ( nhtria//'.Famille', nhtrfa, codre4 )
      call gmnomc ( nhquad//'.Famille', nhqufa, codre5 )
      call gmnomc ( nhtetr//'.Famille', nhtefa, codre6 )
      call gmnomc ( nhhexa//'.Famille', nhhefa, codre7 )
      call gmnomc ( nhpyra//'.Famille', nhpyfa, codre8 )
      call gmnomc ( nhpent//'.Famille', nhpefa, codre9 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8, codre9 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8, codre9 )
c
      endif
c
c====
c 3. Recuperation des pointeurs
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. recup. des pointeurs ; codret', codret
#endif
c
c 3.1.==> tableaux
c
      if ( codret.eq.0 ) then
c
      iaux = 7
      if ( homolo.ge.1 ) then
        iaux = iaux*11
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 ( iaux, nhnoeu,
     >                jaux,
     >              pfamno, pcfano,   jaux,
     >                jaux,   jaux, adhono,   jaux,
     >              ulsort, langue, codret )
c
      if ( rsmpto.ne.0 ) then
c
        iaux = 259
        if ( homolo.ge.2 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_mp', nompro
#endif
        call utad02 ( iaux, nhmapo,
     >                  jaux,   jaux, jaux  , jaux,
     >                pfammp, pcfamp,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                jaux  , admpho,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      iaux = 259
      if ( homolo.ge.2 ) then
        iaux = iaux*29
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 ( iaux, nharet,
     >                jaux,   jaux,   jaux,   jaux,
     >              pfamar, pcfaar,   jaux,
     >              jaux  ,   jaux,   jaux,
     >              jaux  , adhoar,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbftri.ne.0 ) then
c
        iaux = 37
        if ( rstrto.ne.0 ) then
          iaux = iaux*7
          if ( homolo.ge.3 ) then
            iaux = iaux*29
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 ( iaux, nhtria,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamtr, pcfatr,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                jaux  , adhotr,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfqua.ne.0 ) then
c
        iaux = 37
        if ( rsquto.ne.0 ) then
          iaux = iaux*7
          if ( homolo.ge.3 ) then
            iaux = iaux*29
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 ( iaux, nhquad,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamqu, pcfaqu,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                jaux  , adhoqu,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbftet.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        iaux = 37
        if ( rsteto.ne.0 ) then
          iaux = iaux*7
        endif
        call utad02 ( iaux, nhtetr,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamte, pcfate,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfhex.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        iaux = 37
        if ( rsheto.ne.0 ) then
          iaux = iaux*7
        endif
        call utad02 ( iaux, nhhexa,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamhe, pcfahe,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfpyr.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        iaux = 37
        if ( rspyto.ne.0 ) then
          iaux = iaux*7
        endif
        call utad02 ( iaux, nhpyra,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfampy, pcfapy,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfpen.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        iaux = 37
        if ( rspeto.ne.0 ) then
          iaux = iaux*7
        endif
        call utad02 ( iaux, nhpent,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfampe, pcfape,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                jaux  ,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.2. ==> homologues
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. homologues ; codret', codret
#endif
c
c 3.3. ==> tableaux de renumerotation
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. renumerotation ; codret', codret
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
     >              rvnoac, rvnoto, adnohp, adnocp,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_mp', nompro
#endif
      iaux = 0
      jaux = -210
      call utre03 ( iaux, jaux, norenu,
     >              rvmpac, rvmpto, admphp, admpcp,
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
      jaux = -210
      call utre03 ( iaux, jaux, norenu,
     >              rvarac, rvarto, adarhp, adarcp,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_tr', nompro
#endif
      iaux = 2
      jaux = -210
      call utre03 ( iaux, jaux, norenu,
     >              rvtrac, rvtrto, adtrhp, adtrcp,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_te', nompro
#endif
      iaux = 3
      jaux = -210
      call utre03 ( iaux, jaux, norenu,
     >              rvteac, rvteto, adtehp, adtecp,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_qu', nompro
#endif
      iaux = 4
      jaux = -210
      call utre03 ( iaux, jaux, norenu,
     >              rvquac, rvquto, adquhp, adqucp,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_py', nompro
#endif
      iaux = 5
      jaux = -210
      call utre03 ( iaux, jaux, norenu,
     >              rvpyac, rvpyto, adpyhp, adpycp,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_he', nompro
#endif
      iaux = 6
      jaux = -210
      call utre03 ( iaux, jaux, norenu,
     >              rvheac, rvheto, adhehp, adhecp,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_pe', nompro
#endif
      iaux = 7
      jaux = -210
      call utre03 ( iaux, jaux, norenu,
     >              rvpeac, rvpeto, adpehp, adpecp,
     >              ulsort, langue, codret)
c
      endif
c
c 3.4. ==> maillage de calcul
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. maillage de calcul ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call utnomc ( nocmap,
     >              iaux1, iaux2,
     >              iaux3, iaux4, iaux5, iaux6, iaux7,
     >              iaux8,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD11', nompro
#endif
      iaux = 7
      call utad11 ( iaux, ncnoeu, nccono,
     >                jaux,   jaux,   jaux,   jaux,
     >              ptypel,   jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
c 3.5. ==> impression
c
      if ( codret.eq.0 ) then
c
      iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECFE', nompro
#endif
      call utecfe ( iaux,
     >              imem(pfamno), imem(pcfano),
     >              imem(pfammp), imem(pcfamp),
     >              imem(pfamar), imem(pcfaar),
     >              imem(pfamtr), imem(pcfatr),
     >              imem(pfamqu), imem(pcfaqu),
     >              imem(pfamte), imem(pcfate),
     >              imem(pfamhe), imem(pcfahe),
     >              imem(pfampy), imem(pcfapy),
     >              imem(pfampe), imem(pcfape),
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 5. Les equivalences
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Les equivalences ; codret', codret
#endif
c
      if ( homolo.ne.0 ) then
c
c 5.1. ==> estimation de la longueur des listes
c          c'est une estimation car on ne fait pas de difference
c          entre les vrais et les faux homolgues de l'axe
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ1', nompro
#endif
        call pcceq1 ( imem(pcfano), imem(pfamno), imem(adnohp),
     >                imem(pcfamp), imem(pfammp), imem(admphp),
     >                imem(pcfaar), imem(pfamar), imem(adarhp),
     >                imem(pcfatr), imem(pfamtr), imem(adtrhp),
     >                imem(pcfaqu), imem(pfamqu), imem(adquhp),
     >                imem(ptypel),
     >                ulsort, langue, codret )
c
        endif
c
c 5.2. ==> allocation des nouveaux tableaux
c
        if ( codret.eq.0 ) then
c
        nbeqte = 0
        nbeqhe = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTACME', nompro
#endif
        call utacme ( ncequi,
     >                nbequi,
     >                nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >                nbeqte, nbeqhe,
     >                adeqpo, adeqin,
     >                adeqno, adeqmp, adeqar, adeqtr, adeqqu,
     >                adeqte, adeqhe,
     >                ulsort, langue, codret )
c
        endif
c
c 5.3. ==> creation des listes
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ3', nompro
#endif
        call pcceq3 ( imem(pcfano), imem(pfamno),
     >                imem(adnohp), imem(adnocp),
     >                imem(pcfamp), imem(pfammp),
     >                imem(admphp), imem(admpcp),
     >                imem(pcfaar), imem(pfamar),
     >                imem(adarhp), imem(adarcp),
     >                imem(pcfatr), imem(pfamtr),
     >                imem(adtrhp), imem(adtrcp),
     >                imem(pcfaqu), imem(pfamqu),
     >                imem(adquhp), imem(adqucp),
     >                imem(ptypel),
     >                imem(adhono), imem(admpho),
     >                imem(adhoar), imem(adhotr), imem(adhoqu),
     >                imem(adeqpo),
     >                imem(adeqno), imem(adeqmp),
     >                imem(adeqar), imem(adeqtr), imem(adeqqu),
     >                nbeqnn, nbeqmn, nbeqan, nbeqtn, nbeqqn,
     >                ulsort, langue, codret )
c
        endif
c
c 5.4. ==> modification des longueurs des tableaux
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD07', nompro
#endif
        call utad07 ( ncequi,
     >                nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >                nbeqnn, nbeqmn, nbeqan, nbeqtn, nbeqqn,
     >                adeqno, adeqmp, adeqar, adeqtr, adeqqu,
     >                adeqte, adeqhe,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 6. sauvegarde des informations sur les familles, au sens
c    du module de calcul associe
c    on peut faire des attachements car le maillage homard n'est
c    jamais detruit.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. sauvegarde familles ; codret', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nhsupe )
      call gmprsx (nompro, nhsupe//'.Tab3' )
      call gmprsx (nompro, nhsupe//'.Tab4' )
      call gmprsx (nompro, nhsupe//'.Tab5' )
      call gmprsx (nompro, nhsupe//'.Tab6' )
      call gmprsx (nompro, nhsupe//'.Tab9' )
      call gmprsx (nompro, nhsups )
      call gmprsx (nompro, nhsups//'.Tab2' )
      call gmprsx (nompro, nhsups//'.Tab4' )
#endif
c
c 6.1. ==> Allocations
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( ncfami//'.Groupe'  , ' ', 0, iaux, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
c 6.2. ==> Attributs
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.2. Attributs lecture ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhsupe, 5, iaux3, codre1 )
      call gmliat ( nhsups, 2, iaux4, codre2 )
      call gmliat ( nhsupe, 9, nbfmed, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.2. Attributs ecriture ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      ngrouc = iaux4/10
      call gmecat ( ncfami//'.Groupe', 1, iaux3, codre1 )
      call gmecat ( ncfami//'.Groupe', 2, iaux4, codre2 )
      call gmecat ( ncfami, 1, nbfmed, codre3 )
      call gmecat ( ncfami, 2, ngrouc, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c 6.3. ==> Attachements
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.3. ==> Attachements ; codret', codret
      write (ulsort,90002) 'nbfmed', nbfmed
      write (ulsort,90002) 'ngrouc', ngrouc
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbfmed.ne.0 ) then
c
        if ( ngrouc.gt.0 ) then
c
          call gmatoj ( ncfami//'.Groupe.Pointeur',
     >                  nhsupe//'.Tab5', codre1 )
          call gmatoj ( ncfami//'.Groupe.Taille',
     >                  nhsupe//'.Tab6', codre2 )
          call gmatoj ( ncfami//'.Groupe.Table',
     >                  nhsups//'.Tab2', codre3 )
c
          codre0 = min ( codre1, codre2, codre3 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3 )
cgn      write (ulsort,*) codre1, codre2, codre3
c
        endif
c
        call gmatoj ( ncfami//'.Numero',
     >                nhsupe//'.Tab9', codre1 )
        call gmatoj ( ncfami//'.Nom',
     >                nhsups//'.Tab4', codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
cgn      write (ulsort,*) codre1, codre2
c
      endif
c
      endif
c
c====
c 7. sauvegarde des informations sur les equivalences, au sens
c    du module de calcul associe
c    on peut faire des attachements car le maillage homard n'est
c    jamais detruit.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. sauvegarde equivalences ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( homolo.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nhsups//'.Tab5' )
#endif
c
      call gmobal ( ncequi//'.InfoGene', codret )
c
      if ( codret.eq.2 ) then
        codret = 0
        call gmlboj ( ncequi//'.InfoGene', codret )
      elseif ( codret.ne.0 ) then
        codret = 2
      endif
c
      if ( codret.eq.0 ) then
      call gmatoj ( ncequi//'.InfoGene',
     >              nhsups//'.Tab5', codret )
      endif
c
      endif
c
      endif
c
c====
c 8. Les nombres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. Les nombres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ncnomb, adnomb, iaux, codret )
c
      endif
cgn      print *,nbfmed, ngrouc
cgn      print *,nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
c
      if ( codret.eq.0 ) then
c
      imem(adnomb+21) = nbfmed
cgn      imem(adnomb+22) = nattrc
      imem(adnomb+23) = ngrouc
      imem(adnomb+30) = nbequi
      imem(adnomb+31) = nbeqno
      imem(adnomb+32) = nbeqmp
      imem(adnomb+33) = nbeqar
      imem(adnomb+34) = nbeqtr
      imem(adnomb+35) = nbeqqu
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ncnomb )
      call dmflsh (iaux)
#endif
c
      endif
c
c====
c 9. la fin
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. la fin ; codret', codret
#endif
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
