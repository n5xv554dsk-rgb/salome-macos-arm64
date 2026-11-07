      subroutine inqur1 ( nomail, nosolu,
     >                    ulfido, ulenst, ulsost,
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
c   INformation : QUestions / Reponses - phase 1
c   --            --          -                -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard iteration n .
c . nosolu . e   . char8  . nom de l'objet solution                    .
c . ulfido . e   .   1    . unite logique du fichier de donnees correct.
c . ulenst . e   .   1    . unite logique de l'entree standard         .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
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
      parameter ( nompro = 'INQUR1' )
c
#include "nblang.h"
#include "consts.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "inmess.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "meddc0.h"
#include "envca1.h"
#include "nombmp.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "nomber.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      character*8 nomail, nosolu
c
      integer ulfido, ulenst, ulsost
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer tbiaux(1)
c
      integer pcoono, phetno, pareno
      integer pnoemp, phetmp
      integer psomar, pposif, pfacar, phetar, pfilar
      integer pmerar
      integer phettr, paretr, pfiltr, ppertr, pnivtr, adpetr, adnmtr
      integer phetqu, parequ, pfilqu, pperqu, pnivqu, adhequ, adnmqu
      integer ptrite, pcotrt, parete, phette, pfilte, pperte, adtes2
      integer pquahe, pcoquh, parehe, phethe, pfilhe, pperhe, adhes2
      integer adnmhe
      integer pfacpy, pcofay, parepy, phetpy, pfilpy, pperpy, adpys2
      integer pfacpe, pcofap, parepe, phetpe, pfilpe, pperpe, adpes2
      integer advotr, advoqu
      integer adpptr, adppqu
      integer pnp2ar
      integer pfamno, pcfano
      integer pfammp
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
      integer pfamte
      integer pfamhe
      integer pfampy
      integer pfampe
      integer adhono, admpho, adhoar, adhotr, adhoqu
c
      integer adnohn, adnocn, adnoin, lgnoin
      integer admphn, admpcn, admpin, lgmpin, admpcs
      integer adarhn, adarcn, adarin, lgarin, adarcs
      integer adtrhn, adtrcn, adtrin, lgtrin, adtrcs
      integer adquhn, adqucn, adquin, lgquin, adqucs
      integer adtehn, adtecn, adtein, lgtein, adtecs
      integer adhehn, adhecn, adhein, lghein, adhecs
      integer adpyhn, adpycn, adpyin, lgpyin, adpycs
      integer adpehn, adpecn, adpein, lgpein, adpecs
c
      integer nbcham, nbpafo, nbprof, nblopg
      integer aninch, aninpf, aninpr, adinlg
c
      integer numero, numdeb, numfin
      integer adnbrn
      integer nbmapo, nbsegm, nbtria, nbtetr,
     >        nbquad, nbhexa, nbpent, nbpyra
      integer decanu(-1:7)
      integer voarno, vofaar, vovoar, vovofa
      integer lgtate, adptte, adtate
      integer lgtahe, adpthe, adtahe
      integer lgtapy, adptpy, adtapy
      integer lgtape, adptpe, adtape
c
      logical extrus
c
      character*2 choix
      character*8 saux08
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntramp, ntraar, ntratr, ntraqu
      character*8 ntrate, ntrahe, ntrapy, ntrape
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
#include "inmes0.h"
c
#include "impr03.h"
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
      if ( codret.eq.0 ) then
c
      if ( typcca.eq.26 .or .typcca.eq.46 ) then
        extrus = .false.
      elseif ( maextr.ne.0 .and. rafdef.eq.0 ) then
        extrus = .true.
      else
        extrus = .false.
      endif
c
      endif
c
c 2.2. ==> tableaux
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro//' - nhtria.InfoSupp', nhtria//'.InfoSupp' )
      call gmprsx ( nompro//' - nhquad.InfoSupp', nhquad//'.InfoSupp' )
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 210
      if ( homolo.ge.1 ) then
        iaux = iaux*11
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 (   iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono, pareno, adhono,  jaux,
     >              ulsort, langue, codret )
c
      if ( nbmpto.ne.0 ) then
c
        iaux = 14
        if ( homolo.ge.2 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_mp', nompro
#endif
        call utad02 (   iaux, nhmapo,
     >                phetmp, pnoemp,   jaux,   jaux,
     >                pfammp,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, admpho,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      iaux = 7770
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
      if ( homolo.ge.2 ) then
        iaux = iaux*29
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 (   iaux, nharet,
     >              phetar, psomar, pfilar, pmerar,
     >              pfamar, pcfaar,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux, adhoar,   jaux,
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
          if ( homolo.ge.3 ) then
            iaux = iaux*29
          endif
          if ( extrus ) then
            iaux = iaux*13
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 (   iaux, nhtria,
     >                phettr, paretr, pfiltr, ppertr,
     >                pfamtr, pcfatr,   jaux,
     >                pnivtr, adpetr,   jaux,
     >                adnmtr, adhotr,   jaux,
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
          if ( homolo.ge.3 ) then
            iaux = iaux*29
          endif
          if ( extrus ) then
            iaux = iaux*13
          endif
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 (   iaux, nhquad,
     >                phetqu, parequ, pfilqu, pperqu,
     >                pfamqu, pcfaqu,   jaux,
     >                pnivqu, adhequ,   jaux,
     >                adnmqu, adhoqu,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
        iaux = 2730
        if ( nbteh1.gt.0 .or. nbteh2.gt.0 .or. nbteh3.gt.0 .or.
     >       nbteh4.gt.0 .or.
     >       nbtep0.gt.0 .or. nbtep1.gt.0 .or. nbtep2.gt.0 .or.
     >       nbtep3.gt.0 .or. nbtep4.gt.0 .or. nbtep5.gt.0 .or.
     >       nbtedh.gt.0 .or. nbtedp.gt.0 ) then
          iaux = iaux*17
        endif
        if ( nbteca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
        call utad02 (   iaux, nhtetr,
     >                phette, ptrite, pfilte, pperte,
     >                pfamte,   jaux,   jaux,
     >                  jaux, pcotrt, adtes2,
     >                  jaux,   jaux, parete,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
        iaux = 2730
        if ( nbheco.ne.0 ) then
          iaux = iaux*17
        endif
        if ( mod(mailet,5).eq.0 ) then
          iaux = iaux*19
        endif
        if ( nbheca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 (   iaux, nhhexa,
     >                phethe, pquahe, pfilhe, pperhe,
     >                pfamhe,   jaux,   jaux,
     >                  jaux, pcoquh, adhes2,
     >                adnmhe,   jaux, parehe,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 ) then
c
        iaux = 2730
        if ( nbpyh1.gt.0 .or. nbpyh2.gt.0 .or. nbpyh3.gt.0 .or.
     >       nbpyh4.gt.0 .or.
     >       nbpyp0.gt.0 .or. nbpyp1.gt.0 .or. nbpyp2.gt.0 .or.
     >       nbpyp3.gt.0 .or. nbpyp4.gt.0 .or. nbpyp5.gt.0 .or.
     >       nbpydh.gt.0 .or. nbpydp.gt.0 ) then
          iaux = iaux*17
        endif
        if ( nbpyca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
        call utad02 (   iaux, nhpyra,
     >                phetpy, pfacpy, pfilpy, pperpy,
     >                pfampy,   jaux,   jaux,
     >                  jaux, pcofay, adpys2,
     >                  jaux,   jaux, parepy,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
        iaux = 2730
        if ( nbpeco.ne.0 ) then
          iaux = iaux*17
        endif
        if ( nbpeca.gt.0 ) then
          iaux = iaux*31
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 (   iaux, nhpent,
     >                phetpe, pfacpe, pfilpe, pperpe,
     >                pfampe,   jaux,   jaux,
     >                  jaux, pcofap, adpes2,
     >                  jaux,   jaux, parepe,
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
      voarno = 0
      vofaar = 0
      vovoar = 2
      vovofa = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nomail, nhvois,
     >              voarno, vofaar, vovoar, vovofa,
     >                jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nhvois)
      call gmprsx (nompro,nhvois//'.Vol/Tri')
      call gmprsx (nompro,nhvois//'.PyPe/Tri')
      call gmprsx (nompro,nhvois//'.Vol/Qua')
      call gmprsx (nompro,nhvois//'.PyPe/Qua')
#endif
c
c    Remarque : on passe en deux fois pour ne pas avoir un nombre
c               trop grand en 32 bits ...
      iaux = 3
      if ( nbteto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*5
      endif
      if ( nbheto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*7
      endif
      if ( nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*13*17
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04 - phase 1', nompro
#endif
      call utad04 (   iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >              advotr, advoqu,
     >                jaux,   jaux, adpptr, adppqu,
     >              lgtate, adptte, adtate,
     >              lgtahe, adpthe, adtahe,
     >              lgtapy, adptpy, adtapy,
     >              lgtape, adptpe, adtape,
     >              ulsort, langue, codret )
      iaux = 1
      if ( nbteto.ne.0 ) then
        iaux = iaux*19
      endif
      if ( nbheto.ne.0 ) then
        iaux = iaux*23
      endif
      if ( nbpyto.ne.0 ) then
        iaux = iaux*29
      endif
      if ( nbpeto.ne.0 ) then
        iaux = iaux*31
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04 - phase 2', nompro
#endif
      call utad04 (   iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >              advotr, advoqu,
     >                jaux,   jaux, adpptr, adppqu,
     >              lgtate, adptte, adtate,
     >              lgtahe, adpthe, adtahe,
     >              lgtapy, adptpy, adtapy,
     >              lgtape, adptpe, adtape,
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ==> renumerotation
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro//' - PeCalcul', norenu//'.PeCalcul' )
      call gmprsx ( nompro//' - PeHOMARD', norenu//'.PeHOMARD' )
      call gmprsx ( nompro//' - HeCalcul', norenu//'.HeCalcul' )
      call gmprsx ( nompro//' - HeHOMARD', norenu//'.HeHOMARD' )
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_no', nompro
#endif
      iaux = -1
      jaux = 210
      call utre03 (   iaux,   jaux, norenu,
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
      call utre04 (   iaux,   jaux, norenu,
     >              lgnoin, adnoin,
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
      call utre03 (   iaux,   jaux, norenu,
     >              rempac, rempto, admphn, admpcn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE04_mp', nompro
#endif
      iaux = 0
      jaux = -11
      call utre04 (   iaux,   jaux, norenu,
     >              lgmpin, admpin,
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
      call utre03 (   iaux,   jaux, norenu,
     >              rearac, rearto, adarhn, adarcn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE04_ar', nompro
#endif
      iaux = 1
      jaux = -11
      call utre04 (   iaux,   jaux, norenu,
     >              lgarin, adarin,
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
      call utre03 (   iaux,   jaux, norenu,
     >              retrac, retrto, adtrhn, adtrcn,
     >              ulsort, langue, codret)
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
      call utre04 (   iaux,   jaux, norenu,
     >              lgtrin, adtrin,
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
      call utre03 (   iaux,   jaux, norenu,
     >              reteac, reteto, adtehn, adtecn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE04_te', nompro
#endif
      iaux = 3
      jaux = -11
      call utre04 (   iaux,   jaux, norenu,
     >              lgtein, adtein,
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
      call utre03 (   iaux,   jaux, norenu,
     >              requac, requto, adquhn, adqucn,
     >              ulsort, langue, codret)
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
      call utre04 (   iaux,   jaux, norenu,
     >              lgquin, adquin,
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
      call utre03 (   iaux,   jaux, norenu,
     >              repyac, repyto, adpyhn, adpycn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE04_py', nompro
#endif
      iaux = 5
      jaux = -11
      call utre04 (   iaux,   jaux, norenu,
     >              lgpyin, adpyin,
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
      call utre03 (   iaux,   jaux, norenu,
     >              reheac, reheto, adhehn, adhecn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE04_he', nompro
#endif
      iaux = 6
      jaux = -11
      call utre04 (   iaux,   jaux, norenu,
     >              lghein, adhein,
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
      call utre03 (   iaux,   jaux, norenu,
     >              repeac, repeto, adpehn, adpecn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE04_pe', nompro
#endif
      iaux = 7
      jaux = -11
      call utre04 (   iaux,   jaux, norenu,
     >              lgpein, adpein,
     >              ulsort, langue, codret)
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
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'decanu', decanu
#endif
c
      endif
c
c 2.5. ==> Profils
c
      if ( rempac.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR05 mapo', nompro
#endif
        call utpr05 ( iaux, -1, tbiaux,
     >                rempac, jaux,
     >                imem(admphn), imem(admpcn), decanu(0),
     >                lgmpin, imem(admpin), tbiaux,
     >                ntramp, saux08,
     >                admpcs,   jaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      if ( rearac.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR05 aret', nompro
#endif
        call utpr05 ( iaux, -1, tbiaux,
     >                rearac, jaux,
     >                imem(adarhn), imem(adarcn), decanu(1),
     >                lgarin, imem(adarin), tbiaux,
     >                ntraar, saux08,
     >                adarcs,   jaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      if ( retrac.ne.0 ) then
c
        if ( .not.extrus ) then
c
          if ( codret.eq.0 ) then
c
          iaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR05 tria', nompro
#endif
          call utpr05 ( iaux, -1, tbiaux,
     >                  retrac, jaux,
     >                  imem(adtrhn), imem(adtrcn), decanu(2),
     >                  lgtrin, imem(adtrin), tbiaux,
     >                  ntratr, saux08,
     >                  adtrcs,   jaux,
     >                  ulsort, langue, codret )
c
          endif
c
        else
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro//' - TrCalcul', norenu//'.TrCalcul' )
      call gmprsx ( nompro//' - TrHOMARD', norenu//'.TrHOMARD' )
      call gmprsx ( nompro//' - PeCalcul', norenu//'.PeCalcul' )
      call gmprsx ( nompro//' - PeHOMARD', norenu//'.PeHOMARD' )
#endif
          iaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR06 tria', nompro
#endif
          call utpr06 ( iaux,
     >                  retrac,   jaux,
     >                  imem(adpetr), imem(adtrhn),
     >                  imem(adpehn), imem(adpecn),
     >                  ntratr, saux08,
     >                  adtrcs,   jaux,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
cgn      call gmprsx ( nompro//' - profil triangle', ntratr )
cgn      call gmprsx ( nompro//' - pentri', nhtria//'.InfoSupp' )
c
      if ( requac.ne.0 ) then
c
        if ( .not.extrus ) then
c
          if ( codret.eq.0 ) then
c
          iaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR05 quad', nompro
#endif
          call utpr05 ( iaux, -1, tbiaux,
     >                  requac, jaux,
     >                  imem(adquhn), imem(adqucn), decanu(4),
     >                  lgquin, imem(adquin), tbiaux,
     >                  ntraqu, saux08,
     >                  adqucs,   jaux,
     >                  ulsort, langue, codret )
c
          endif
c
        else
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro//' - QuCalcul', norenu//'.QuCalcul' )
      call gmprsx ( nompro//' - QuHOMARD', norenu//'.QuHOMARD' )
      call gmprsx ( nompro//' - HeCalcul', norenu//'.HeCalcul' )
      call gmprsx ( nompro//' - HeHOMARD', norenu//'.HeHOMARD' )
#endif
          iaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR06 quad', nompro
#endif
          call utpr06 ( iaux,
     >                  requac, jaux,
     >                  imem(adhequ), imem(adquhn),
     >                  imem(adhehn), imem(adhecn),
     >                  ntraqu, saux08,
     >                  adqucs,   jaux,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
cgn      call gmprsx ( nompro//' - profil quadrangle', ntraqu )
cgn      call gmprsx ( nompro//' - hexqua', nhquad//'.InfoSupp' )
c
      if ( reteac.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR05 tetr', nompro
#endif
        call utpr05 ( iaux, -1, tbiaux,
     >                reteac, jaux,
     >                imem(adtehn), imem(adtecn), decanu(3),
     >                lgtein, imem(adtein), tbiaux,
     >                ntrate, saux08,
     >                adtecs,   jaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      if ( repyac.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR05 pyra', nompro
#endif
        call utpr05 ( iaux, -1, tbiaux,
     >                repyac, jaux,
     >                imem(adpyhn), imem(adpycn), decanu(5),
     >                lgpyin, imem(adpyin), tbiaux,
     >                ntrapy, saux08,
     >                adpycs,   jaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      if ( reheac.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR05 hexa', nompro
#endif
        call utpr05 ( iaux, -1, tbiaux,
     >                reheac, jaux,
     >                imem(adhehn), imem(adhecn), decanu(6),
     >                lghein, imem(adhein), tbiaux,
     >                ntrahe, saux08,
     >                adhecs,   jaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      if ( repeac.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR05 pent', nompro
#endif
        call utpr05 ( iaux, -1, tbiaux,
     >                repeac, jaux,
     >                imem(adpehn), imem(adpecn), decanu(7),
     >                lgpein, imem(adpein), tbiaux,
     >                ntrape, saux08,
     >                adpecs,   jaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 2.5. ===> tableaux lies a la solution eventuelle
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nosolu)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
      call utcaso ( nosolu,
     >              nbcham, nbpafo, nbprof, nblopg,
     >              aninch, aninpf, aninpr, adinlg,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. questions - reponses
c====
c
      if ( codret.eq.0 ) then
c
   30 continue
c
c 3.1. ==> choix
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INQUR2', nompro
#endif
c
      call inqur2 ( choix, numdeb, numfin,
     >              ulfido, ulenst, ulsost,
     >              ulsort, langue, codret )
c
      if ( codret.ne.0 ) then
        codret = 0
        goto 30
      endif
c
c 3.2. ==> sortie
c
      if ( choix.eq.'q ' ) then
c
        goto 40
c
      else
c
c 3.3. ==> description d'entites
c
        if ( numdeb.gt.0 ) then
c
        do 33 , iaux = numdeb, numfin
c
          numero = iaux
c
c 3.3.1. ==> informations sur un noeud
c
          if ( choix.eq.'no' .or.
     >         choix.eq.'NO' ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFONO', nompro
#endif
            call infono ( choix, numero,
     >      rmem(pcoono), imem(phetno), imem(pareno), imem(pfamno),
     >      imem(adnohn), imem(adnocn),
     >      imem(adhono),
     >      imem(pnoemp),
     >      imem(psomar), imem(phetar), imem(pposif), imem(pfacar),
     >      imem(phettr), imem(phetqu),
     >      imem(phette), imem(phetpy), imem(phethe), imem(phetpe),
     >      lgtate, imem(adptte), imem(adtate),
     >      lgtahe, imem(adpthe), imem(adtahe),
     >      lgtapy, imem(adptpy), imem(adtapy),
     >      lgtape, imem(adptpe), imem(adtape),
     >      nbpafo, smem(aninpf),
     >      ulsost,
     >      ulsort, langue, codret )
c
c 3.3.2. ==> informations sur une maille-point
c
          elseif ( choix.eq.'mp' .or.
     >             choix.eq.'MP' .or.
     >             choix.eq.'E ' ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOMP', nompro
#endif
            call infomp ( choix, numero,
     >      imem(pnoemp), imem(phetmp),
     >      imem(pfammp),
     >      imem(admphn), imem(admpcn), imem(admpcs),
     >      rmem(pcoono),
     >      nbpafo, smem(aninpf),
     >      ulsost,
     >      ulsort, langue, codret )
c
c 3.3.4. ==> informations sur une arete
c
          elseif ( choix.eq.'ar' .or.
     >             choix.eq.'AR' .or.
     >             choix.eq.'E ' ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOAR', nompro
#endif
            call infoar ( choix, numero,
     >      imem(psomar), imem(pposif), imem(pfacar),
     >      imem(phetar), imem(pfilar), imem(pmerar), imem(pnp2ar),
     >      imem(pfamar), imem(pcfaar),
     >      imem(adarhn), imem(adarcn), imem(adarcs),
     >      imem(adhoar),
     >      rmem(pcoono),
     >      imem(phettr), imem(phetqu),
     >      imem(phette), imem(phetpy), imem(phethe), imem(phetpe),
     >      lgtate, imem(adptte), imem(adtate),
     >      lgtahe, imem(adpthe), imem(adtahe),
     >      lgtapy, imem(adptpy), imem(adtapy),
     >      lgtape, imem(adptpe), imem(adtape),
     >      nbpafo, smem(aninpf),
     >      ulsost,
     >      ulsort, langue, codret )
c
c 3.3.5. ==> informations sur un triangle
c
          elseif ( choix.eq.'tr' .or.
     >             choix.eq.'TR' .or.
     >             choix.eq.'E' ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOTR', nompro
#endif
            call infotr ( choix, numero,
     >      imem(paretr), imem(phettr), imem(advotr), imem(adpptr),
     >      imem(pnivtr), imem(pfiltr), imem(ppertr), imem(adnmtr),
     >      imem(pfamtr),
     >      imem(adtrhn), imem(adtrcn), imem(adtrcs),
     >      imem(adhotr),
     >      imem(psomar), imem(pnp2ar), imem(phetar),
     >      imem(pposif), imem(pfacar),
     >      rmem(pcoono),
     >      imem(phetqu), imem(pnivqu), imem(pfilqu),
     >      imem(phette), imem(phetpy), imem(phetpe),
     >      extrus, imem(adpetr), imem(adpecn),
     >      nbpafo, smem(aninpf),
     >      ulsost,
     >      ulsort, langue, codret )
c
c 3.3.6. ==> informations sur un quadrangle
c
          elseif ( choix.eq.'qu' .or.
     >             choix.eq.'QU' .or.
     >             choix.eq.'E' ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOQU', nompro
#endif
            call infoqu ( choix, numero,
     >      imem(parequ), imem(phetqu), imem(advoqu), imem(adppqu),
     >      imem(pnivqu), imem(pfilqu), imem(pperqu), imem(adnmqu),
     >      imem(pfamqu),
     >      imem(adquhn), imem(adqucn), imem(adqucs),
     >      imem(adhoqu),
     >      imem(psomar), imem(pnp2ar), imem(phetar),
     >      imem(pposif), imem(pfacar),
     >      rmem(pcoono),
     >      imem(phettr), imem(pnivtr), imem(adtrcn),
     >      imem(phetpy), imem(phethe), imem(phetpe),
     >      extrus, imem(adhequ), imem(adhecn),
     >      nbpafo, smem(aninpf),
     >      ulsost,
     >      ulsort, langue, codret )
c
c 3.3.7. ==> informations sur un tetraedre
c
          elseif ( choix.eq.'te' .or.
     >             choix.eq.'TE' .or.
     >             choix.eq.'E' ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOTE', nompro
#endif
            call infote ( choix, numero,
     >      imem(ptrite), imem(pcotrt), imem(parete),
     >      imem(phette), imem(pfilte), imem(pperte), imem(adtes2),
     >      imem(pfamte),
     >      imem(adtehn), imem(adtecn), imem(adtecs),
     >      imem(phetar), imem(psomar), imem(pnp2ar), rmem(pcoono),
     >      imem(phettr), imem(paretr), imem(pnivtr),
     >      imem(pnivqu),
     >      imem(phethe), imem(pquahe), imem(pfilhe), imem(adhes2),
     >      imem(phetpy), imem(adpycn),
     >      imem(phetpe), imem(pfacpe), imem(pfilpe), imem(adpes2),
     >      imem(advotr), imem(adpptr),
     >      imem(advoqu), imem(adppqu),
     >      nbpafo, smem(aninpf),
     >      ulsost,
     >      ulsort, langue, codret )
c
c 3.3.8. ==> informations sur une pyramide
c
          elseif ( choix.eq.'py' .or.
     >             choix.eq.'PY' .or.
     >             choix.eq.'E' ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOPY', nompro
#endif
            call infopy ( choix, numero,
     >      imem(pfacpy), imem(pcofay), imem(parepy),
     >      imem(phetpy), imem(pfilpy), imem(pperpy), imem(adpys2),
     >      imem(pfampy),
     >      imem(adpyhn), imem(adpycn), imem(adpycs),
     >      imem(phetar), imem(psomar), imem(pnp2ar), rmem(pcoono),
     >      imem(phettr), imem(paretr), imem(pnivtr),
     >      imem(phetqu), imem(pnivqu),
     >      imem(phette), imem(adtecn),
     >      imem(phethe), imem(pquahe), imem(pfilhe), imem(adhes2),
     >      imem(phetpe), imem(pfacpe), imem(pfilpe), imem(adpes2),
     >      imem(advotr), imem(adpptr),
     >      imem(advoqu), imem(adppqu),
     >      nbpafo, smem(aninpf),
     >      ulsost,
     >      ulsort, langue, codret )
c
c 3.3.9. ==> informations sur un hexaedre
c
          elseif ( choix.eq.'he' .or.
     >             choix.eq.'HE' .or.
     >             choix.eq.'E' ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOHE', nompro
#endif
            call infohe ( choix, numero,
     >      imem(pquahe), imem(pcoquh), imem(parehe),
     >      imem(phethe), imem(pfilhe), imem(pperhe), imem(adhes2),
     >      imem(pfamhe),
     >      imem(adhehn), imem(adhecn), imem(adhecs),
     >      imem(phetar), imem(psomar), imem(pnp2ar), rmem(pcoono),
     >      imem(phetqu), imem(parequ), imem(pnivqu),
     >      imem(phette), imem(adtecn),
     >      imem(phetpy), imem(adpycn),
     >      imem(phetpe),
     >      imem(advotr), imem(adpptr),
     >      imem(advoqu), imem(adppqu),
     >      nbpafo, smem(aninpf),
     >      ulsost,
     >      ulsort, langue, codret )
c
c 3.3.10. ==> informations sur un pentaedre
c
          elseif ( choix.eq.'pe' .or.
     >             choix.eq.'PE' .or.
     >             choix.eq.'E' ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOPE', nompro
#endif
            call infope ( choix, numero,
     >      imem(pfacpe), imem(pcofap), imem(parepe),
     >      imem(phetpe), imem(pfilpe), imem(pperpe), imem(adpes2),
     >      imem(pfampe),
     >      imem(adpehn), imem(adpecn), imem(adpecs),
     >      imem(phetar), imem(psomar), imem(pnp2ar), rmem(pcoono),
     >      imem(phettr), imem(pnivtr),
     >      imem(phetqu), imem(parequ), imem(pnivqu),
     >      imem(phette), imem(adtecn),
     >      imem(phethe),
     >      imem(phetpy), imem(adpycn),
     >      imem(advotr), imem(adpptr),
     >      imem(advoqu), imem(adppqu),
     >      nbpafo, smem(aninpf),
     >      ulsost,
     >      ulsort, langue, codret )
c
          endif
c
c 3.3.11. ==> sortie en cas d'erreur
c
          if ( codret.ne.0 ) then
            goto 40
          endif
c
   33   continue
c
c 3.4. ==> qualite des entites
c
        else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFQEN', nompro
#endif
          call infqen ( choix, numfin,
     >                  rmem(pcoono), imem(psomar),
     >                  imem(phettr), imem(paretr),
     >                  imem(pfamtr), imem(pcfatr),
     >                  imem(phetqu), imem(parequ),
     >                  imem(pfamqu), imem(pcfaqu),
     >                  imem(ptrite), imem(pcotrt), imem(parete),
     >                  imem(phette),
     >                  imem(pquahe), imem(pcoquh), imem(parehe),
     >                  imem(phethe),
     >                  imem(pfacpy), imem(pcofay), imem(parepy),
     >                  imem(phetpy),
     >                  imem(pfacpe), imem(pcofap), imem(parepe),
     >                  imem(phetpe),
     >                  imem(adtrcn), imem(adqucn), imem(adtecn),
     >                  ulsost,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
      goto 30
c
      endif
c
c====
c 4. fin
c====
c
   40 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '40 continue avec codret', codret
#endif
c
      if ( rempac.ne.0 .and. codret.eq.0 ) then
        call gmlboj ( ntramp, codret )
      endif
      if ( rearac.ne.0 .and. codret.eq.0 ) then
        call gmlboj ( ntraar, codret )
      endif
      if ( retrac.ne.0 .and. codret.eq.0 ) then
        call gmlboj ( ntratr, codret )
      endif
      if ( requac.ne.0 .and. codret.eq.0 ) then
        call gmlboj ( ntraqu, codret )
      endif
      if ( reteac.ne.0 .and. codret.eq.0 ) then
        call gmlboj ( ntrate, codret )
      endif
      if ( repyac.ne.0 .and. codret.eq.0 ) then
        call gmlboj ( ntrapy, codret )
      endif
      if ( reheac.ne.0 .and. codret.eq.0 ) then
        call gmlboj ( ntrahe, codret )
      endif
      if ( repeac.ne.0 .and. codret.eq.0 ) then
        call gmlboj ( ntrape, codret )
      endif
c
c 4.1. ==> message si erreur
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
