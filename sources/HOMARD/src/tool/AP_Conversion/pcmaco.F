      subroutine pcmaco ( modhom,
     >                    nocmap, nomail, nomamd, lnomam,
     >                    nospec,
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
c    aPres adaptation - Conversion de MAillage - COnnectivite
c     -                 -             --         --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . modhom . e   .    1   . mode de fonctionnement de homard           .
c .        .     .        .  1 : homard pur                            .
c .        .     .        .  2 : information                           .
c .        .     .        .  3 : modification de maillage sans adaptati.
c .        .     .        .  4 : interpolation de la solution          .
c . nocmap .   s . char8  . nom de l'objet maillage de calcul iter. n+1.
c . nomail . e   . char8  . nom de l'objet maillage homard iter. n+1   .
c . nomamd . e   . char64 . nom med du maillage iteration n+1          .
c . lnomam . e   .   1    . longueur de nomamd                         .
c . nospec .   s . char8  . nom de l'objet memorisant les specificites .
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
      parameter ( nompro = 'PCMACO' )
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
#include "envca1.h"
#include "envada.h"
c
#include "nbutil.h"
#include "nombno.h"
#include "nombar.h"
#include "nombmp.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "nombsr.h"
#include "nbfami.h"
#include "dicfen.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer modhom
      integer lnomam
c
      character*8 nocmap, nomail
      character*64 nomamd
      character*8 nospec
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer pcoono, adcocs, phetno, pancno
      integer pnoemp, phetmp
      integer psomar, phetar, pfilar, pmerar, pnp2ar
      integer paretr, phettr, ppertr, pfiltr, pnivtr, adnmtr
      integer parequ, phetqu, pperqu, pfilqu, pnivqu, adnmqu
      integer ptrite, pcotrt, parete, phette
      integer pquahe, pcoquh, parehe, phethe, adnmhe
      integer advotr, adpptr
      integer advoqu, adppqu
      integer pfacpy, pcofay, parepy, phetpy
      integer pfacpe, pcofap, parepe, phetpe
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer pfamno, pcfano
      integer pfammp, pcfamp
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
      integer pfamte, pcfate
      integer pfamhe, pcfahe
      integer pfampy, pcfapy
      integer pfampe, pcfape
      integer hfmdel, hnoeel
      integer dimcst
c
      integer adnbrp
      integer adnocp, adnohp
      integer admpcp, admphp
      integer adarcp, adarhp
      integer adtrcp, adtrhp
      integer adtecp, adtehp
      integer adqucp, adquhp
      integer adhecp, adhehp
      integer adpycp, adpyhp
      integer adpecp, adpehp
c
      integer adnomb
      integer pfamen, pfamee, pnoeel, ptypel, pcoonc
      integer pinfpt, pinftb
      integer nparrc, nptrrc, npqurc
      integer npterc, npherc, npperc, nppyrc
      integer adarrc, adtrrc, adqurc
      integer adterc, adherc, adperc, adpyrc
      integer lgtrc1, lgtrc2, lgtrc3
      integer lgtrc4, lgtrc5, lgtrc6, lgtrc7
      integer ptrav4
      integer nbanci, nbenrc, numead
      integer adarra, adarrb
      integer adtrra
      integer adqura
c
      integer iaux,  jaux, kaux, laux
      integer codre1, codre2, codre3, codre4
      integer codre0
      integer nbele0, un
      integer nonexm
      integer nbpqt
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 nhqufa
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
      character*8 ntrav1, ntrav2, ntrav3, ntrav4
c
      character*8 heurus
      character*9 dateus
      character*32 saux32
c
      logical noeord
      logical existe
      logical deraff
      logical cforme
c
      integer nbmess
      parameter ( nbmess = 30 )
      character*80 texte(nblang,nbmess)
c
cmdc ---------------- MAILLES DOUBLES DEBUT --------------
cmd      character*80 nomfic
cmd      integer nbele1, nbtenw
cmd      logical maildb
cmd      integer adpoin, adtail, adtabl
cmd      integer adnumf
cmd      integer ptrav5
cmd      character*8 ntrav5
cmdc ---------------- MAILLES DOUBLES FIN ----------------
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
      texte(1,8) =
     > '(5x,''Caracteristiques du maillage apres conversion :'',/)'
c
      texte(2,7) = '(5x,''Conversion HOMARD ----> '',a18,/)'
      texte(2,8) =
     > '(5x,''Characteristics of the mesh after conversion :'',/)'
c
#include "impr03.h"
c
#include "impr06.h"
c
      un = 1
c
c====
c 2. recuperation des pointeurs
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. recuperation donnees ; codret', codret
#endif
c
c 2.1. ==> on alloue la future renumerotation
c          remarque : on la supprime si elle existait ; cela arrive
c                     dans les cas de modifications de maillage
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nomail//'.RenuMail', codre0 )
c
      if ( codre0.eq.1 ) then
        call gmlboj ( nomail//'.RenuMail', codret )
      elseif ( codre0.ne.0 ) then
        codret = 2
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( nomail//'.RenuMail', ' ', 0, iaux, codret )
c
      endif
c
c 2.2. ==> structure generale
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. ==> structure gale ; codret', codret
      call dmflsh (iaux)
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nomail)
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
      if ( codret.eq.0 ) then
#include "mslve4.h"
      endif
c
      if ( codret.eq.0 ) then
c
      if ( ( rafdef.eq.3 .or. rafdef.eq.4 ) .and. nbiter .gt.1 ) then
        deraff = .true.
      else
        deraff = .false.
      endif
c
      if ( maconf.eq.-1 .or. maconf.eq.0 ) then
        cforme = .true.
      else
        cforme = .false.
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,99001) 'cforme', cforme
#endif
c
      nonexm = 1
      if ( ( typcca.eq.36 ) .or. ( typcca.eq.56 ) ) then
        nonexm = nonexm*2
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nonexm', nonexm
#endif
c
      endif
c
c 2.3. ==> tableaux
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. ==> tableaux ; codret', codret
      call dmflsh(iaux)
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 42
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono,   jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( deraff ) then
        call gmadoj ( nhnoeu//'.Deraffin', pancno, iaux, codre1 )
        call gmalot ( ntrav4, 'entier', nbnoto, ptrav4, codre2)
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
      endif
c
      call gmliat ( nhnoeu, 2, dimcst, codre0 )
      codret = max ( abs(codre0), codret )
c
      if ( nbmpto.ne.0 ) then
c
        iaux = 518
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_mp', nompro
#endif
        call utad02 (   iaux, nhmapo,
     >                phetmp, pnoemp,   jaux,  jaux,
     >                pfammp, pcfamp,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      iaux = 518
      if ( .not. cforme ) then
        iaux = iaux*15
      endif
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 (   iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >              pfamar, pcfaar,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbftri.ne.0 ) then
c
        iaux = 37
        if ( nbtrto.ne.0 ) then
          iaux = iaux*2310
          if ( mod(mailet,2).eq.0 ) then
            iaux = iaux*19
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 (   iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                pfamtr, pcfatr,   jaux,
     >                pnivtr,   jaux,   jaux,
     >                adnmtr,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfqua.ne.0 ) then
c
        iaux = 37
        if ( nbquto.ne.0 ) then
          iaux = iaux*2310
          if ( mod(mailet,3).eq.0 ) then
            iaux = iaux*19
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 (   iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                pfamqu, pcfaqu,   jaux,
     >                pnivqu,   jaux,   jaux,
     >                adnmqu,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbftet.ne.0 ) then
c
cgn        write(ulsort,90002) 'nbtecf, nbteca', nbtecf, nbteca
        iaux = 37
        if ( nbteto.ne.0 ) then
          iaux = iaux*182
          if ( nbteca.gt.0 ) then
            iaux = iaux*31
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        call utad02 (   iaux, nhtetr,
     >                phette, ptrite,   jaux,  jaux,
     >                pfamte, pcfate,   jaux,
     >                  jaux, pcotrt,   jaux,
     >                  jaux,   jaux, parete,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfhex.ne.0 ) then
c
        iaux = 37
        if ( nbheto.ne.0 ) then
          iaux = iaux*182
          if ( mod(mailet,5).eq.0 ) then
            iaux = iaux*19
          endif
          if ( nbheca.gt.0 ) then
            iaux = iaux*31
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 (   iaux, nhhexa,
     >                phethe, pquahe,   jaux,  jaux,
     >                pfamhe, pcfahe,   jaux,
     >                  jaux, pcoquh,   jaux,
     >                adnmhe,   jaux, parehe,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfpyr.ne.0 ) then
c
        iaux = 37
        if ( nbpyto.ne.0 ) then
          iaux = iaux*182
          if ( nbpyca.gt.0 ) then
            iaux = iaux*31
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        call utad02 (   iaux, nhpyra,
     >                phetpy, pfacpy,   jaux,  jaux,
     >                pfampy, pcfapy,   jaux,
     >                  jaux, pcofay,   jaux,
     >                  jaux,   jaux, parepy,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfpen.ne.0 ) then
c
        iaux = 37
        if ( nbpeto.ne.0 ) then
          iaux = iaux*182
          if ( nbpeca.gt.0 ) then
            iaux = iaux*31
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 (   iaux, nhpent,
     >                phetpe, pfacpe,   jaux,  jaux,
     >                pfampe, pcfape,   jaux,
     >                  jaux, pcofap,   jaux,
     >                  jaux,   jaux, parepe,
     >                ulsort, langue, codret )
c
      endif
c
      call gmliat ( nhsups, 2, iaux, codre1 )
      call gmliat ( nhsupe, 9, nbfmed, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      ngrouc = iaux / 10
cgn      print *,nompro,'nbfmed, ngrouc ',nbfmed, ngrouc
c
      endif
c
c 2.4. ==> les voisinages des noeuds
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 0
      kaux = 0
      laux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nomail, nhvois,
     >                iaux,   jaux,   kaux,   laux,
     >              ppovos, pvoiso,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 3
      if ( nbteto.ne.0 ) then
        iaux = iaux*5
        if ( nbpyto.ne.0 .or. nbpeto.ne.0 ) then
          iaux = iaux*13
        endif
      endif
      if ( nbheto.ne.0 ) then
        iaux = iaux*7
        if ( nbpyto.ne.0 .or. nbpeto.ne.0 ) then
          iaux = iaux*17
        endif
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
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
c 2.5. ==> nombre d'equivalences
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.5. equivalences ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( homolo.eq.0 ) then
        nbequi = 0
      else
        call gmliat ( nhsups, 5, iaux, codret )
        if ( codret.eq.0 ) then
        if ( mod(iaux,33).eq.0 ) then
          nbequi = iaux / 33
        else
          codret = 3
        endif
        endif
      endif
c
      endif
c
c====
c 3. Particularites des logiciels associes
c    Il faut le faire maintenant, avant d'avoir converti le maillage
c    du format HOMARD au format MED. En effet, ces programmes vont
c    modifier/creer les familles med associes. Or cela est transfere au
c    maillage de calcul par le programme pcmac1.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Particularites ; codret', codret
      call dmflsh(iaux)
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typcca', typcca
#endif
c
c 3.1. ==> Creation des boites pour Athena
c
      if ( typcca.eq.16 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Boites pour Athena ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nhquad//'.Famille', nhqufa, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCFAAT', nompro
#endif
      call pcfaat ( typcca,
     >              nhsupe, nhsups, nhqufa,
     >              imem(phetar), imem(psomar),
     >              imem(phettr), imem(paretr),
     >              imem(phetqu), imem(parequ),
     >              imem(pperqu), imem(pnivqu),
     >              imem(ppovos), imem(pvoiso),
     >              imem(pposif), imem(pfacar),
     >              imem(pfamar), imem(pcfaar),
     >              imem(pfamtr), imem(pcfatr),
     >              imem(pfamqu), pcfaqu,
     >              ulsort, langue, codret )
c attention : il est normal que l'on passe pcfaqu et pas imem(pcfaqu)
c
      endif
c
      endif
c
c 3.2. ==> Elements a recoller pour le non conforme
c
      if ( .not. cforme ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Recoller non conforme ;  codret', codret
      call dmflsh(iaux)
#endif
c
c 3.2.1. ==> Copie des tableaux des etats : les numeros vont etre
c            modifies temporairement ; il faut pouvoir les restituer
c            apres la conversion
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      call gmcpal ( nharet//'.HistEtat', ntrav1, iaux, jaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrto.ne.0 ) then
c
        call gmcpal ( nhtria//'.HistEtat', ntrav2, iaux, jaux, codret )
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbquto.ne.0 ) then
c
        call gmcpal ( nhquad//'.HistEtat', ntrav3, iaux, jaux, codret )
c
      endif
c
      endif
c
c 3.2.2. ==> Recuperation du recollement initial
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.2. recollement initial ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD03_ar', nompro
#endif
      iaux = 462
      call utad03 ( iaux, nharet,
     >              nbanci, nbenrc,  jaux,
     >              adarra, adarrb,
     >              ulsort, langue, codret )
c
      if ( nbtrto.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD03_tr', nompro
#endif
        if ( nbtrri.eq.0 ) then
          iaux = 5
        else
          iaux = 35
        endif
        call utad03 ( iaux, nhtria,
     >                jaux,  jaux, numead,
     >                adtrra,  jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD03_qu', nompro
#endif
        if ( nbquri.eq.0 ) then
          iaux = 5
        else
          iaux = 35
        endif
        call utad03 ( iaux, nhquad,
     >                jaux,  jaux, numead,
     >                adqura,  jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 3.2.3. ==> Creation de la structure de memorisation des recollements
c            Remarque : on dimensionne surement trop grand car tout ne
c                       donne pas lieu a recollement, mais tant pis
c            Remarque : on initialise a 0 pour la suite
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.3. creation structure ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL41', nompro
#endif
      call utal41 ( typcca, nonexm, nbanci, nbenrc,
     >              nbarto, nbarde,
     >              nbtrri, nbtrde,
     >              nbquri, nbqude,
     >              nbpeac, nbpyac,
     >              nospec,
     >              adarrc, adtrrc, adqurc,
     >              adterc, adherc, adperc, adpyrc,
     >              lgtrc1, lgtrc2, lgtrc3,
     >              lgtrc4, lgtrc5, lgtrc6, lgtrc7,
     >              ulsort, langue, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'apres utal41'
      write (ulsort,90002) 'lgtrc1', lgtrc1
      write (ulsort,90002) 'lgtrc2', lgtrc2
      write (ulsort,90002) 'lgtrc3', lgtrc3
      write (ulsort,90002) 'lgtrc4', lgtrc4
      write (ulsort,90002) 'lgtrc5', lgtrc5
      write (ulsort,90002) 'lgtrc6', lgtrc6
      write (ulsort,90002) 'lgtrc7', lgtrc7
#endif
c
      if ( codret.eq.0 ) then
c
      jaux = adarrc + 2*lgtrc1 - 1
      do 3231 , iaux = adarrc, jaux
        imem(iaux) = 0
 3231 continue
c
      jaux = adtrrc + 2*lgtrc2 - 1
      do 3232 , iaux = adtrrc, jaux
        imem(iaux) = 0
 3232 continue
c
      jaux = adqurc + 2*lgtrc3 - 1
      do 3233 , iaux = adqurc, jaux
        imem(iaux) = 0
 3233 continue
c
      jaux = adterc + 3*lgtrc4 - 1
      do 3234 , iaux = adterc, jaux
        imem(iaux) = 0
 3234 continue
c
      jaux = adherc + 3*lgtrc5 - 1
      do 3235 , iaux = adherc, jaux
        imem(iaux) = 0
 3235 continue
c
      jaux = adperc + 3*lgtrc6 - 1
      do 3236 , iaux = adperc, jaux
        imem(iaux) = 0
 3236 continue
c
      jaux = adpyrc + 3*lgtrc7 - 1
      do 3237 , iaux = adpyrc, jaux
        imem(iaux) = 0
 3237 continue
c
      endif
c
c 3.2.4. ==> Prise en compte du futur recollement
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.4. futur recollement ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAR0', nompro
      call dmflsh(iaux)
#endif
      call pcmar0 ( nonexm,
     >              imem(phetar), imem(pfilar), imem(pmerar),
     >              imem(pfamar), imem(pposif), imem(pfacar),
     >              imem(paretr), imem(phettr), imem(pnivtr),
     >              imem(pfamtr), imem(ppertr), imem(pfiltr),
     >              imem(parequ), imem(phetqu), imem(pnivqu),
     >              imem(pfamqu), imem(pperqu), imem(pfilqu),
     >              imem(phette),
     >              imem(phethe),
     >              imem(phetpy),
     >              imem(advotr), imem(adpptr),
     >              imem(advoqu), imem(adppqu),
     >              nbanci, nbenrc, numead,
     >              imem(adarra), imem(adtrra), imem(adqura),
     >              nparrc, nptrrc, npqurc,
     >              npterc, npherc, npperc, nppyrc,
     >              imem(adarrc), imem(adtrrc), imem(adqurc),
     >              imem(adterc), imem(adherc),
     >              imem(adperc), imem(adpyrc),
     >              ulsort, langue, codret )
c
      endif
c
c 3.2.5. ==> Redimensionnement
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.5. Redimensionnement ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'au debut de 3.2.5'
      write (ulsort,90002) 'lgtrc1, nparrc', lgtrc1, nparrc
      write (ulsort,90002) 'lgtrc2, nptrrc', lgtrc2, nptrrc
      write (ulsort,90002) 'lgtrc3, npqurc', lgtrc3, npqurc
      write (ulsort,90002) 'lgtrc4, npterc', lgtrc4, npterc
      write (ulsort,90002) 'lgtrc5, npherc', lgtrc5, npherc
      write (ulsort,90002) 'lgtrc6, nptrrc+npqurc', lgtrc6,
     > nptrrc+npqurc
      write (ulsort,90002) 'lgtrc7, nptrrc+npqurc', lgtrc7,
     > nptrrc+npqurc
#endif
c
      call gmecat ( nospec, 1, nparrc, codre1 )
      call gmmod ( nospec//'.Tab1', adarrc,
     >             2, 2, lgtrc1, nparrc, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      call gmecat ( nospec, 2, nptrrc, codre1 )
      call gmmod ( nospec//'.Tab2', adtrrc,
     >             2, 2, lgtrc2, nptrrc, codre2 )
      call gmecat ( nospec, 3, npqurc, codre3 )
      call gmmod ( nospec//'.Tab3', adqurc,
     >             2, 2, lgtrc3, npqurc, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      call gmecat ( nospec, 4, npterc, codre1 )
      call gmmod ( nospec//'.Tab4', adterc,
     >             3, 3, lgtrc4, npterc, codre2 )
      call gmecat ( nospec, 5, npherc, codre3 )
      call gmmod ( nospec//'.Tab5', adherc,
     >             3, 3, lgtrc5, npherc, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      if ( nbpeac.gt.0 ) then
        call gmecat ( nospec, 6, nptrrc+npqurc, codre1 )
        call gmmod ( nospec//'.Tab6', adperc,
     >               3, 3, lgtrc6, nptrrc+npqurc, codre2 )
      else
        codre1 = 0
        codre2 = 0
      endif
      if ( nbpyac.gt.0 ) then
        call gmecat ( nospec, 7, nptrrc+npqurc, codre3 )
        call gmmod ( nospec//'.Tab7', adpyrc,
     >               3, 3, lgtrc7, nptrrc+npqurc, codre4 )
      else
        codre3 = 0
        codre4 = 0
      endif
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
cgn      call gmprsx (nompro,nospec)
cgn      call gmprsx (nompro,nospec//'.Tab1')
cgn      call gmprsx (nompro,nospec//'.Tab2')
cgn      call gmprsx (nompro,nospec//'.Tab3')
cgn      call gmprsx (nompro,nospec//'.Tab4')
cgn      call gmprsx (nompro,nospec//'.Tab5')
cgn      call gmprsx (nompro,nospec//'.Tab6')
cgn      call gmprsx (nompro,nospec//'.Tab7')
c
      endif
c
      endif
c
c====
c 4. preliminaires
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. preliminaires ; codret', codret
      call dmflsh(iaux)
#endif
c
c 4.1. ==> nombres caracteristiques
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhelig, 1, nbelig, codret )
c
      endif
c
c 4.2. ==> on n'ordonne pas les noeuds
c
c      noeord = .true.
      noeord = .false.
c
c====
c 5. Calcul du nombre d'entites pour le calcul.
c    . Pour les noeuds, il y en a tout le temps et leur nombre
c      est egal au nombre de noeuds.
c    . Pour les aretes, les triangles ou les quadrangles, il est
c      impossible d'avoir une estimation correcte a cause de la
c      conformite qui fait apparaitre ou disparaitre des mailles.
c      On appelle donc un programme qui fait le decompte.
c    . Pour les mailles 3D, c'ets simple : il y a equivalence
c      entre maille active et maille qui sera du calcul ensuite.
c    Une fois ces estimations faites, on peut deduire le nombre
c    total de mailles de calcul.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'au debut de 5. ; codret', codret
#endif
c
c 5.1. ==> estimation du nombre d'elements du maillage de calcul
c
      nbele0 = nbelig
c
c 5.2. ==> les noeuds
c
      rsnoac = nbnoto
      rsnoto = nbnoto
      rsnois = nbnois
      rsnoei = nbnoei
      rsnomp = nbnomp
      rsnop1 = nbnop1
      rsnop2 = nbnop2
      rsnoim = nbnoim
c
c 5.3. ==> les mailles-points
c
      if ( codret.eq.0 ) then
c
      if ( nbmpto.eq.0 ) then
        rsmpto = 0
      else
        rsmpto = nbmpto
      endif
c
      nbele0 = nbele0 + rsmpto
c
      endif
c
c 5.4. ==> les aretes
c
      if ( codret.eq.0 ) then
c
      if ( nbarac.eq.0 ) then
        rsarto = 0
      elseif ( mod(nonexm,2).eq.0 ) then
        rsarto = 0
      else
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAA0', nompro
#endif
        call pcmaa0 ( rsarto,
     >                imem(phetar),
     >                imem(pfamar), imem(pcfaar),
     >                ulsort, langue, codret )
      endif
c
      nbele0 = nbele0 + rsarto
c
      endif
c
c 5.5. ==> les triangles
c
      if ( codret.eq.0 ) then
c
      if ( nbtrac.eq.0 ) then
        rstrto = 0
      else
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAT0', nompro
#endif
        call pcmat0 ( rstrto,
     >                imem(phettr),
     >                imem(pfamtr), imem(pcfatr),
     >                ulsort, langue, codret )
      endif
c
      nbele0 = nbele0 + rstrto
c
      endif
c
c 5.6. ==> les quadrangles
c
      if ( codret.eq.0 ) then
c
      if ( nbquac.eq.0 ) then
        rsquto = 0
      else
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAQ0', nompro
#endif
        call pcmaq0 ( rsquto,
     >                imem(phetqu),
     >                imem(pfamqu), imem(pcfaqu),
     >                ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'rsquto', rsquto
#endif
      endif
c
      nbele0 = nbele0 + rsquto
c
      endif
c
c 5.8. ==> les tetraedres
c
      if ( codret.eq.0 ) then
c
      if ( nbteac.eq.0 ) then
        rsteto = 0
      else
        rsteto = nbteto
      endif
c
      nbele0 = nbele0 + rsteto
c
      endif
c
c 5.9. ==> les hexaedres
c
      if ( codret.eq.0 ) then
c
      if ( nbheac.eq.0 ) then
        rsheto = 0
      else
        rsheto = nbheto
      endif
c
      nbele0 = nbele0 + rsheto
c
      endif
c
c 5.10. ==> les pyramides
c
      if ( codret.eq.0 ) then
c
      if ( nbpyac.eq.0 ) then
        rspyto = 0
      else
        rspyto = nbpyto
      endif
c
      nbele0 = nbele0 + rspyto
c
      endif
c
c 5.11. ==> les pentaedres
c
      if ( codret.eq.0 ) then
c
      if ( nbpeac.eq.0 ) then
        rspeto = 0
      else
        rspeto = nbpeto
      endif
c
      nbele0 = nbele0 + rspeto
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,18)) mess14(langue,3,13), nbele0
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'apres les 5.3.x ; codret', codret
      call dmflsh(iaux)
#endif
c
c====
c 6. allocation des tableaux pour le maillage de sortie
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. allocation des tableaux ; codret', codret
#endif
c
c 6.1. ==> allocation de l'objet de tete
c          remarque : pour le moment, ncfron n'est pas alloue
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      jaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'sdimca, mdimca', sdimca, mdimca
      write (ulsort,90002) 'nbnoto, nctfno, nbele0, nbmane',
     >                      nbnoto, nctfno, nbele0, nbmane
      write (ulsort,texte(langue,3)) 'UTACMA', nompro
#endif
      call utacma ( nocmap, iaux, typcca,
     >              sdimca, mdimca,
     >               degre, mailet, maconf, homolo, hierar,
     >              nbnoto, nctfno, nbele0, nbmane,  jaux,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret )
c
      endif
c
c 6.2. ==> tableaux de correspondance entre les numerotations
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'au debut de 6.2 ; codret', codret
#endif
c
c 6.2.1 ==> les noeuds
c
      if ( codret.eq.0 ) then
c
      iaux = -1
      kaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_no', nompro
#endif
      call utre01 ( iaux, kaux,
     >              norenu, rsnoac, rsnoto,
     >              adnohp, adnocp, laux,
     >              ulsort, langue, codret)
c
      endif
c
c 6.2.2. ==> les mailles-points
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      if ( rsmpto.eq.0 ) then
        jaux = 0
      else
        jaux = nbele0
      endif
      kaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_mp', nompro
#endif
      call utre01 ( iaux, kaux, norenu,   jaux, rsmpto,
     >              admphp, admpcp, laux,
     >              ulsort, langue, codret)
c
      endif
c
c 6.2.3. ==> les aretes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_ar', nompro
#endif
      iaux = 1
      if ( rsarto.eq.0 ) then
        jaux = 0
      else
        jaux = nbele0
      endif
      kaux = 210
      call utre01 ( iaux, kaux, norenu,   jaux, rsarto,
     >              adarhp, adarcp, laux,
     >              ulsort, langue, codret)
c
      endif
c
c 6.2.4. ==> les triangles
c
      if ( codret.eq.0 ) then
c
      iaux = 2
      if ( rstrto.eq.0 ) then
        jaux = 0
      else
        jaux = nbele0
      endif
      kaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_tr', nompro
#endif
      call utre01 ( iaux, kaux, norenu,   jaux, rstrto,
     >              adtrhp, adtrcp, laux,
     >              ulsort, langue, codret)
c
      endif
c
c 6.2.5. ==> les quadrangles
c
      if ( codret.eq.0 ) then
c
      iaux = 4
      if ( rsquto.eq.0 ) then
        jaux = 0
      else
        jaux = nbele0
      endif
      kaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_qu', nompro
#endif
      call utre01 ( iaux, kaux, norenu,   jaux, rsquto,
     >              adquhp, adqucp, laux,
     >              ulsort, langue, codret)
c
      endif
c
c 6.2.6. ==> les tetraedres
c
      if ( codret.eq.0 ) then
c
      iaux = 3
      if ( rsteto.eq.0 ) then
        jaux = 0
      else
        jaux = nbele0
      endif
      kaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_te', nompro
#endif
      call utre01 ( iaux, kaux, norenu,   jaux, rsteto,
     >              adtehp, adtecp, laux,
     >              ulsort, langue, codret)
c
      endif
c
c 6.2.7. ==> les hexaedres
c
      if ( codret.eq.0 ) then
c
      iaux = 6
      if ( rsheto.eq.0 ) then
        jaux = 0
      else
        jaux = nbele0
      endif
      kaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_he', nompro
#endif
      call utre01 ( iaux, kaux, norenu,   jaux, rsheto,
     >              adhehp, adhecp, laux,
     >              ulsort, langue, codret)
c
      endif
c
c 6.2.8. ==> les pyramides
c
      if ( codret.eq.0 ) then
c
      iaux = 5
      if ( rspyto.eq.0 ) then
        jaux = 0
      else
        jaux = nbele0
      endif
      kaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_py', nompro
#endif
      call utre01 ( iaux, kaux, norenu,   jaux, rspyto,
     >              adpyhp, adpycp, laux,
     >              ulsort, langue, codret)
c
      endif
c
c 6.2.9. ==> les pentaedres
c
      if ( codret.eq.0 ) then
c
      iaux = 7
      if ( rspeto.eq.0 ) then
        jaux = 0
      else
        jaux = nbele0
      endif
      kaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_pe', nompro
#endif
      call utre01 ( iaux, kaux, norenu,   jaux, rspeto,
     >              adpehp, adpecp, laux,
     >              ulsort, langue, codret)
c
      endif
c
c 6.2.10. ==> les nombres
c
      if ( codret.eq.0 ) then
c
      iaux = 25
      call gmecat ( norenu, 19, iaux, codre1 )
      call gmaloj ( norenu//'.Nombres', ' ', iaux, adnbrp, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'apres les 6.2.x ; codret', codret
      call dmflsh(iaux)
#endif
c
c 6.3. ==> structure de donnees de type externe : on prend large pour
c          le nombre de mailles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.3. structure externe ; codret', codret
      call dmflsh(iaux)
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = nbnoto * sdimca
      call gmaloj ( ncnoeu//'.Coor', ' ', iaux, pcoonc, codre1 )
      call gmaloj ( ncnoeu//'.FamilMED', ' ', nbnoto, pfamen, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      call gmecat ( ncnoeu, 3, dimcst, codre1 )
      call gmcpoj ( nhnoeu//'.CoorCons', ncnoeu//'.CoorCons', codre2 )
      call gmadoj ( nhnoeu//'.CoorCons', adcocs, iaux, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      call gmaloj ( nccono//'.FamilMED', ' ', nbele0, pfamee, codre1 )
      iaux = nbele0*nbmane
      call gmaloj ( nccono//'.Noeuds', ' ', iaux  , pnoeel, codre2 )
      call gmaloj ( nccono//'.Type', ' ', nbele0, ptypel, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 6.4. ==> transfert des mailles ignorees
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.4. ==> transfert ignores ; codret', codret
      write (ulsort,90002) 'nbelig', nbelig
      call dmflsh(iaux)
#endif
c
      if ( nbelig.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
cgn      call gmprsx (nompro, nhelig )
cgn      call gmprsx (nompro, nhelig//'.ConnNoeu' )
cgn      call gmprsx (nompro, nhelig//'.FamilMED' )
c
        call gmadoj ( nhelig//'.ConnNoeu', hnoeel, iaux, codre1 )
        call gmadoj ( nhelig//'.FamilMED', hfmdel, iaux, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTINEI', nompro
#endif
        call utinei ( modhom,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
c
c====
c 7. impressions
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. impressions ; codret', codret
      call dmflsh(iaux)
#endif
cgn      call gmprsx (nompro, nhnofa//'.EntiFamm')
cgn      call gmprsx (nompro, nhmpfa//'.EntiFamm')
cgn      call gmprsx (nompro, nharfa//'.EntiFamm')
cgn      call gmprsx (nompro, nhtrfa//'.EntiFamm')
cgn      call gmprsx (nompro, nhqufa//'.EntiFamm')
cgn      call gmprsx (nompro, nhtefa//'.EntiFamm')
cgn      call gmmess(6)
cgn      call gmprsx (nompro, nhtrfa//'.Codes')
cgn      call gmprsx (nompro, nhqufa//'.Codes')
cgn      ulsort = 6
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
c
#endif
c
c====
c 8. conversion vraie
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. conversion vraie ; codret', codret
      call dmflsh(iaux)
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAC1', nompro
#endif
      call pcmac1 ( nbele0,
     >   rmem(pcoono), imem(phetno), imem(pancno), imem(ptrav4),
     >   imem(pnoemp), imem(phetmp),
     >   imem(psomar), imem(pnp2ar), imem(phetar),
     >   imem(paretr), imem(phettr), imem(adnmtr),
     >   imem(parequ), imem(phetqu), imem(adnmqu),
     >   imem(ptrite), imem(pcotrt), imem(parete), imem(phette),
     >   imem(pquahe), imem(pcoquh), imem(parehe), imem(phethe),
     >   imem(adnmhe),
     >   imem(pfacpy), imem(pcofay), imem(parepy), imem(phetpy),
     >   imem(pfacpe), imem(pcofap), imem(parepe), imem(phetpe),
     >   imem(pfamno), imem(pcfano), imem(pfammp), imem(pcfamp),
     >   imem(pfamar), imem(pcfaar),
     >   imem(pfamtr), imem(pcfatr), imem(pfamqu), imem(pcfaqu),
     >   imem(pfamte), imem(pcfate), imem(pfamhe), imem(pcfahe),
     >   imem(pfampy), imem(pcfapy), imem(pfampe), imem(pcfape),
     >   imem(adnocp), imem(adnohp), imem(admpcp), imem(admphp),
     >   imem(adarcp), imem(adarhp),
     >   imem(adtrcp), imem(adtrhp), imem(adqucp), imem(adquhp),
     >   imem(adtecp), imem(adtehp), imem(adhecp), imem(adhehp),
     >   imem(adpycp), imem(adpyhp), imem(adpecp), imem(adpehp),
     >   dimcst, rmem(adcocs), rmem(pcoonc), imem(pfamen),
     >   imem(pfamee), imem(pnoeel), imem(ptypel),
     >   imem(hfmdel), imem(hnoeel),
     >   noeord, deraff,
     >   ulsort, langue, codret )
c
      endif
c
c====
c 9. finitions
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. finitions ; codret', codret
      call dmflsh(iaux)
#endif
c
c 9.1. ==> maintenant que l'on connait le vrai nombre de mailles au sens
c          du calcul, on raccourcit eventuellement les tableaux
c
c 9.1.1. ==> les eventuelles mailles-points
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.1.1. mailles-points ; codret', codret
      write (ulsort,90002) 'nbmpto', nbmpto
      write (ulsort,90002) 'rsmpac', rsmpac
      call dmflsh(iaux)
#endif
c
      if ( rsmpto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 0
        jaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02_mp', nompro
#endif
        call utre02 ( iaux,  jaux, norenu,
     >                nbele0, rsmpto, rsmpac, rsmpto,
     >                admphp, admpcp,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 9.1.2. ==> les aretes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.1.2. aretes ; codret', codret
      write (ulsort,90002) 'nbarto', nbarto
      call dmflsh(iaux)
#endif
c
      if ( rsarto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 1
        jaux = 6
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTRE02_ar', nompro
#endif
        call utre02 ( iaux,  jaux, norenu,
     >                nbele0, rsarto, rsarac, rsarto,
     >                adarhp, adarcp,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 9.1.3. ==> les eventuels triangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.1.3. triangles ; codret', codret
      write (ulsort,90002) 'nbele0', nbele0
      write (ulsort,90002) 'nbtrto', nbtrto
      call dmflsh(iaux)
#endif
c
      if ( rstrto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 2
        jaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02_tr', nompro
#endif
        call utre02 ( iaux,  jaux, norenu,
     >                nbele0, rstrto, rstrac, rstrto,
     >                adtrhp, adtrcp,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 9.1.4. ==> les eventuels quadrangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.1.4. quadrangles ; codret', codret
      write (ulsort,90002) 'nbele0', nbele0
      write (ulsort,90002) 'rsquac', rsquac
      write (ulsort,90002) 'nbquto', nbquto
      write (ulsort,90002) 'rsquto', rsquto
      call dmflsh(iaux)
#endif
c
      if ( rsquto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 4
        jaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02_qu', nompro
#endif
        call utre02 ( iaux,  jaux, norenu,
     >                nbele0, rsquto, rsquac, rsquto,
     >                adquhp, adqucp,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 9.1.5. ==> les eventuels tetraedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.1.5. tetraedres ; codret', codret
      write (ulsort,90002) 'nbteto', nbteto
      call dmflsh(iaux)
#endif
c
      if ( rsteto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 3
        jaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02_te', nompro
#endif
        call utre02 ( iaux,  jaux, norenu,
     >                nbele0, rsteto, rsteac, rsteto,
     >                adtehp, adtecp,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 9.1.6. ==> les eventuelles pyramides
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.1.6. pyramides ; codret', codret
      write (ulsort,90002) 'nbpyto', nbpyto
      call dmflsh(iaux)
#endif
c
      if ( rspyto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 5
        jaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02_py', nompro
#endif
        call utre02 ( iaux,  jaux, norenu,
     >                nbele0, rspyto, rspyac, rspyto,
     >                adpyhp, adpycp,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 9.1.7. ==> les eventuels hexaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.1.7. hexaedres ; codret', codret
      write (ulsort,90002) 'nbheto', nbheto
      call dmflsh(iaux)
#endif
c
      if ( rsheto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 6
        jaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02_he', nompro
#endif
        call utre02 ( iaux,  jaux, norenu,
     >                nbele0, rsheto, rsheac, rsheto,
     >                adhehp, adhecp,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 9.1.8. ==> les eventuels pentaedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.1.8. pentaedres ; codret', codret
      write (ulsort,90002) 'nbpeto', nbpeto
      call dmflsh(iaux)
#endif
c
      if ( rspeto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 7
        jaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02_pe', nompro
#endif
        call utre02 ( iaux,  jaux, norenu,
     >                nbele0, rspeto, rspeac, rspeto,
     >                adpehp, adpecp,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 9.1.9. ==> les descriptions des mailles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.1.9. mailles ; codret', codret
      write (ulsort,90002) 'nbele0, nbelem, nbmane',
     >                      nbele0,nbelem,nbmane
      call dmflsh(iaux)
#endif
c
      if ( codret.eq.0 ) then
c
      call gmmod ( nccono//'.FamilMED',
     >             pfamee, nbele0, nbelem, un, un, codre1 )
      call gmmod ( nccono//'.Type',
     >             ptypel, nbele0, nbelem, un, un, codre2 )
      call gmmod ( nccono//'.Noeuds',
     >             pnoeel, nbele0, nbelem, nbmane, nbmane, codre3 )
      call gmecat ( nccono, 1, nbelem, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
cgn      call gmprsx (nompro//' - 8.1.9',nccono)
cgn      call gmprsx (nompro//' - 8.1.9',nccono//'.Type')
cgn      call gmprsx (nompro//' - 8.1.9',nccono//'.Noeuds')
c
c 9.2. ==> les caracteristiques du maillage de calcul
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2. carac. mail de calcul ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adnbrp) = rsnois
      imem(adnbrp+1) = rsnoei
      imem(adnbrp+2) = rsnomp
      imem(adnbrp+3) = rsnop1
      imem(adnbrp+4) = rsnop2
      imem(adnbrp+5) = rsnoim
      imem(adnbrp+6) = rseutc
      imem(adnbrp+7) = rsevca
      imem(adnbrp+8) = rsevto
      imem(adnbrp+9) = nbelem
      imem(adnbrp+10) = nbmaae
      imem(adnbrp+11) = nbmafe
      imem(adnbrp+12) = nbmane
      imem(adnbrp+13) = nbmapo
      imem(adnbrp+14) = nbsegm
      imem(adnbrp+15) = nbtetr
      imem(adnbrp+16) = nbtria
      imem(adnbrp+17) = nbquad
      imem(adnbrp+18) = numael
      imem(adnbrp+19) = numano
      imem(adnbrp+20) = nvoare
      imem(adnbrp+21) = nvosom
      imem(adnbrp+22) = nbhexa
      imem(adnbrp+23) = nbpyra
      imem(adnbrp+24) = nbpent
c
      endif
c
c 9.3. ==> Les nombres
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ncnomb, adnomb, iaux, codret )
c
      endif
cgn      print *,nbmaae, nbmafe, nbmnei, numano, numael
cgn      print *,nbmapo,nbsegm,nbtria,nbtetr
cgn      print *,nbelig,nbquad,nbhexa,nbpent,nbpyra
c
      if ( codret.eq.0 ) then
c
      imem(adnomb)    = nbmaae
      imem(adnomb+1)  = nbmafe
      imem(adnomb+2)  = nbmnei
      imem(adnomb+3)  = numano
      imem(adnomb+4)  = numael
      imem(adnomb+5)  = nbtria + nbquad
      imem(adnomb+6)  = nbtetr + nbhexa + nbpent + nbpyra
      imem(adnomb+11) = nbmapo
      imem(adnomb+12) = nbsegm
      imem(adnomb+13) = nbtria
      imem(adnomb+14) = nbtetr
      imem(adnomb+15) = nbelig
      imem(adnomb+16) = nbquad
      imem(adnomb+17) = nbhexa
      imem(adnomb+18) = nbpent
      imem(adnomb+19) = nbpyra
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ncnomb )
#endif
c
      endif
c
c 9.4. ==> date et heure
c
      if ( codret.eq.0 ) then
c
      call utdhus ( dateus, heurus )
c
      endif
c
cmdc ---------------- MAILLES DOUBLES DEBUT --------------
cmdc
cmdc 3.4.1. ==> Lecture du numero de la couche en cours
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd      nomfic = 'nrc.dat'
cmd      inquire ( file = nomfic, exist = maildb )
cmdc
cmd      endif
cmdc
cmd                   if ( maildb ) then
cmdc
cmd      nbele0 = nbelem
cmd      nbele1 = nbele0 + nbtetr
cmdcgn      write(ulsort,90002) 'nbele0', nbele0
cmdcgn      write(ulsort,90002) 'nbele1', nbele1
cmdcgn      write(ulsort,90002) 'nbfmed', nbfmed
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd      call gmadoj ( nhsupe//'.Tab5', adpoin, iaux, codre1 )
cmd      call gmadoj ( nhsupe//'.Tab6', adtail, iaux, codre2 )
cmd      call gmadoj ( nhsups//'.Tab2', adtabl, iaux, codre3 )
cmd      call gmadoj ( nhsupe//'.Tab9', adnumf, iaux, codre4 )
cmdc
cmd      codre0 = min ( codre1, codre2, codre3, codre4 )
cmd      codret = max ( abs(codre0), codret,
cmd     >               codre1, codre2, codre3, codre4 )
cmdc
cmd      endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd      iaux = 3*nbfmed
cmd      call gmalot ( ntrav5, 'entier  ', iaux, ptrav5, codret )
cmdc
cmd      endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd      call gmmod ( nccono//'.FamilMED',
cmd     >             pfamee, nbele0, nbele1, un, un, codre1 )
cmd      call gmmod ( nccono//'.Type',
cmd     >             ptypel, nbele0, nbele1, un, un, codre2 )
cmd      call gmmod ( nccono//'.Noeuds',
cmd     >             pnoeel, nbele0, nbele1, nbmane, nbmane, codre3 )
cmd      call gmecat ( nccono, 1, nbelem, codre4 )
cmdc
cmd      codre0 = min ( codre1, codre2, codre3, codre4 )
cmd      codret = max ( abs(codre0), codret,
cmd     >               codre1, codre2, codre3, codre4 )
cmdc
cmd      endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd#ifdef _DEBUG_HOMARD_
cmd      write (ulsort,texte(langue,3)) 'PCMMEN', nompro
cmd#endif
cmd      call pcmmen ( nbele0, nbele1, nbtenw,
cmd     >              imem(pnoeel), imem(pfamee), imem(ptypel),
cmd     >              imem(adnumf),
cmd     >              imem(adpoin), imem(adtail), smem(adtabl),
cmd     >              imem(ptrav5), imem(ptrav5+2*nbfmed),
cmd     >              ulsort, langue, codret )
cmdc
cmd      endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd      nbtetr = nbtetr + nbtenw
cmd      nbelem = nbele0 + nbtenw
cmdc
cmd      call gmmod ( nccono//'.FamilMED',
cmd     >             pfamee, nbele1, nbelem, un, un, codre1 )
cmd      call gmmod ( nccono//'.Type',
cmd     >             ptypel, nbele1, nbelem, un, un, codre2 )
cmd      call gmmod ( nccono//'.Noeuds',
cmd     >             pnoeel, nbele1, nbelem, nbmane, nbmane, codre3 )
cmd      call gmecat ( nccono, 1, nbelem, codre4 )
cmdc
cmd      codre0 = min ( codre1, codre2, codre3, codre4 )
cmd      codret = max ( abs(codre0), codret,
cmd     >               codre1, codre2, codre3, codre4 )
cmdc
cmd      imem(adnbrp+15) = nbtetr
cmd      imem(adnomb+6)  = nbtetr + nbhexa + nbpent + nbpyra
cmd      imem(adnomb+14) = nbtetr
cmdc
cmd      endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd      call gmlboj ( ntrav5, codret )
cmdc
cmd      endif
cmdc
cmd      endif
cmdc ---------------- MAILLES DOUBLES FIN ----------------
c
c====
c 10. impression des nombres d'entites du maillage de calcul
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. impression ; codret', codret
      call dmflsh(iaux)
#endif
      if ( codret.eq.0 ) then
c
      iaux = 0
      if ( langue.eq.1 ) then
c                 12345678901234567890123456789012
        saux32 = 'apres conversion                '
      else
        saux32 = 'after the conversion            '
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTINMA', nompro
#endif
      call utinma ( iaux, saux32,
     >              sdimca, mdimca,  degre,
     >              nbnoto, nbnop1, nbnop2, nbnoim,
     >              nbnois, nbnomp,
     >              nbnoei, nbelem,
     >              nbmapo, nbsegm, nbtria, nbquad,
     >              nbtetr, nbhexa, nbpyra, nbpent,
     >              nbelig,
     >              nbmane, nbmaae, nbmafe,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 11. sauvegarde des informations generales, au sens du module de
c     calcul associe
c     on peut faire des attachements car le maillage homard n'est
c     jamais detruit.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11. sauvegarde ; codret', codret
      call dmflsh(iaux)
#endif
c
c 11.1. ==> a-t-on defini des informations en externe ?
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhsupe//'.Tab7', codret )
c
      if ( codret.eq.0 ) then
        existe = .false.
      elseif ( codret.eq.2 ) then
        codret = 0
        existe = .true.
      else
        codret = 2
      endif
c
      endif
c
c 11.2. ==> copie des differents attributs
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11.2. copie des attributs ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( existe ) then
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhsupe, 7, iaux , codre1 )
      call gmliat ( nhsups, 3,  jaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( ncinfo, 1, iaux , codre1 )
      call gmecat ( ncinfo, 2,  jaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      endif

      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      call gmprsx (nompro//' 11.2', ncinfo )
      call gmprsx (nompro//' 11.2', ncinfo//'.Pointeur' )
      call gmprsx (nompro//' 11.2', ncinfo//'.Taille' )
      call gmprsx (nompro//' 11.2', ncinfo//'.Table' )
c
      endif
#endif
c
c 11.3. ==> copie des differentes branches
c          attention : il faut faire des copies et non pas des
c          attachements car le contenu est modifie ensuite dans
c          certains cas
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11.3. copie des branches ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( existe ) then
c
      if ( codret.eq.0 ) then
c
      call gmcpoj ( nhsupe//'.Tab7',
     >              ncinfo//'.Pointeur', codre1 )
      call gmcpoj ( nhsupe//'.Tab8',
     >              ncinfo//'.Taille', codre2 )
      call gmcpoj ( nhsups//'.Tab3',
     >              ncinfo//'.Table', codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(typcca-6,10).eq.0 ) then
c
        call gmadoj ( ncinfo//'.Pointeur', pinfpt, iaux, codre1 )
        call gmadoj ( ncinfo//'.Table'   , pinftb, iaux, codre2 )
        call gmliat ( ncinfo, 1, iaux, codre3 )
        nbpqt = iaux - 1
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
      endif
c
c 11.4. ==> changement du nom du maillage
c
      if ( codret.eq.0 ) then
c
      do 1114 , iaux = 1, nbpqt
c
        jaux = pinftb + 10*(iaux-1)
cgn        write (ulsort,90064) jaux, '%'//smem(jaux)//'%'
c
c 2.1. Repere et noms des coordonnees
c
        if ( smem(jaux).eq.'NOMAMD  ' ) then
c
          call utchs8 ( nomamd, lnomam, smem(jaux+1),
     >                  ulsort, langue, codret )
c
        endif
c
 1114 continue
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      call gmprsx (nompro, ncinfo )
      call gmprsx (nompro, ncinfo//'.Pointeur' )
      call gmprsx (nompro, ncinfo//'.Taille' )
      call gmprsx (nompro, ncinfo//'.Table' )
c
      endif
#endif
c
      endif
c
      endif
c
c====
c 12. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '12. Menage ; codret', codret
#endif
c
c 12.1. ==> Structure dediee au deraffinement
c
      if ( codret.eq.0 ) then
c
      if ( deraff ) then
c
      call gmlboj ( ntrav4, codret )
c
      endif
c
      endif
c
c 12.2. ==> Recuperation des sauvegardes dans le cas non conforme
c
      if ( .not. cforme ) then
c
c 12.2.1. ==> Suppression des mailles temporaires dans les
c             renumerotations
c
        if ( codret.eq.0 ) then
c
cgn      call gmprsx (nompro,nospec//'.Tab1')
cgn      call gmprsx (nompro,nospec//'.Tab3')
cgn      call gmprsx (nompro,nospec//'.Tab5')
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'PCMAR1', nompro
#endif
        call pcmar1 ( imem(adarcp),
     >                imem(adtrcp), imem(adqucp),
     >                imem(adtecp), imem(adhecp),
     >                imem(adpecp), imem(adpycp),
     >                nparrc, nptrrc, npqurc,
     >                imem(adarrc), imem(adtrrc), imem(adqurc),
     >                imem(adterc), imem(adherc),
     >                imem(adperc), imem(adpyrc),
     >                ulsort, langue, codret )
c
        endif
c
cgn      call gmprsx (nompro,nospec)
cgn      call gmprsx (nompro,nospec//'.Tab1')
cgn      call gmprsx (nompro,nospec//'.Tab2')
cgn      call gmprsx (nompro,nospec//'.Tab3')
cgn      call gmprsx (nompro,nospec//'.Tab4')
cgn      call gmprsx (nompro,nospec//'.Tab5')
cgn      call gmprsx (nompro,nospec//'.Tab6')
cgn      call gmprsx (nompro,nospec//'.Tab7')
c
c 12.2.2. ==> Recopie des historiques et familles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '12.2.2. Copie hist/fami - codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        call gmcpoj ( ntrav1, nharet//'.HistEtat', codre1 )
        call gmlboj ( ntrav1, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        if ( nbtrto.ne.0 ) then
c
          call gmcpoj ( ntrav2, nhtria//'.HistEtat', codre1 )
          call gmlboj ( ntrav2, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
c
        endif
c
        if ( nbquto.ne.0 ) then
c
          call gmcpoj ( ntrav3, nhquad//'.HistEtat', codre1 )
          call gmlboj ( ntrav3, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
c
        endif
c
        endif
c
      endif
c
c====
c 13. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '13. la fin ; codret', codret
      call dmflsh(iaux)
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      call gmprsx ( nompro , nhnoeu )
      if ( nbmapo.gt.0 ) then
        call gmprsx ( nompro , nhmapo )
      endif
      call gmprsx ( nompro , nharet )
      if ( nbtrto.gt.0 ) then
        call gmprsx ( nompro , nhtria )
      endif
      if ( nbquto.gt.0 ) then
        call gmprsx ( nompro , nhquad )
      endif
      if ( nbteto.gt.0 ) then
        call gmprsx ( nompro , nhtetr )
      endif
      if ( nbheto.gt.0 ) then
       call gmprsx ( nompro , nhhexa )
      endif
      if ( nbpyto.gt.0 ) then
        call gmprsx ( nompro , nhpyra )
      endif
      if ( nbpeto.gt.0 ) then
        call gmprsx ( nompro , nhpent )
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
