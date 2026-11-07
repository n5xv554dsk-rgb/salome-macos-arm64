      subroutine pcsovr ( nocson, nocsop,
     >                    nomail, norenn, nosvmn,
     >                    option,
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
c    aPres adaptation - Conversion de Solution VRaie
c     -                 -             -        --
c ______________________________________________________________________
c remarque : en principe, tous les cas de figure sont couverts ...
c            mais c'est tellement alambique que je prefere mettre un
c            code de retour non nul au cas ou ...
c            comme disait le quotidien de mon enfance :
c            "On peut etre trop petit ou trop grand,
c             on n'est jamais trop prudent."
c                                          La Montagne - 1972
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocsop .   s . char8  . nom de l'objet solution iteration n+1      .
c . nocson . e   . char8  . nom de l'objet solution iteration n        .
c . nomail . e   . char8  . nom de l'objet maillage homard iter. n+1   .
c . norenn . e   . char8  . nom de l'objet renumerotation iteration n  .
c . nosvmn . e   . char8  . nom de l'objet contenant les sauvegardes   .
c .        .     .        . du maillage n                              .
c . option . e   .    1   . option du traitement                       .
c .        .     .        . -1 : Pas de changement dans le maillage    .
c .        .     .        .  0 : Adaptation complete                   .
c .        .     .        .  1 : Modification de degre                 .
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
      parameter ( nompro = 'PCSOVR' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "envada.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "nomber.h"
#include "nombsr.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nocsop, nocson
      character*8 nomail, norenn, nosvmn
c
      integer option
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer codre1, codre2, codre3
      integer codre0
c
      integer nbcham, nbpafo, nbprof, nblopg
      integer phetno, pcoono, pancno
      integer phetar, psomar, pnp2ar, pfilar, pancar
      integer phettr, paretr, pfiltr, ppertr, panctr, adpetr
      integer phetqu, parequ, pfilqu, pperqu, pancqu, adhequ
      integer phette, ptrite, pcotrt, parete, pfilte, pmerte, pancte
      integer phethe, pquahe, pcoquh, parehe, pfilhe, pmerhe, panche
      integer adhes2
      integer phetpy, pfacpy, pcofay, parepy, pfilpy, pmerpy, pancpy
      integer phetpe, pfacpe, pcofap, parepe, pfilpe, pmerpe, pancpe
      integer adpes2
      integer pcfaar, pcfatr, pcfaqu
      integer pfamar, pfamtr, pfamqu, pfamte, pfamhe, pfampy, pfampe
c
      integer adnbrn, adnbrp
      integer adnohp, adnocp
      integer         adarcp
      integer         adtrcp
      integer         adqucp
      integer         adtecp
      integer         adhecp
      integer         adpycp
      integer         adpecp
      integer adnohn, adnocn, adnoin, lgnoin
      integer admphn, admpcn, admpin, lgmpin
      integer adarhn, adarcn, adarin, lgarin
      integer adtrhn, adtrcn, adtrin, lgtrin
      integer adquhn, adqucn, adquin, lgquin
      integer adtehn, adtecn, adtein, lgtein
      integer adhehn, adhecn, adhein, lghein
      integer adpyhn, adpycn, adpyin, lgpyin
      integer adpehn, adpecn, adpein, lgpein
c
      integer aninch, aninpf, aninpr, aninlg
      integer apinch, apinpf, apinpr, apinlg
      integer npprof, approf, nbproi
      integer nplopg, aplopg, nblpgi
      integer nnfopa, tnpgpf, anobfo, antyge
      integer npfopa, typgpf, apobfo, aptyge
      integer typint
      integer nbpara
      integer nrpafo
      integer nrfonc
      integer adtr1i, adtr1s
      integer adtra2, adtrav, nbtrav
      integer nrpass
c
      integer typgeo, ngauss, carsup
c
      integer nbanar, adafar, adaear
      integer nbantr, adaftr, adaetr
      integer nbanqu, adafqu, adaequ
      integer nbante, adafte, adaete
      integer nbanhe, adafhe, adaehe, adaihe
      integer nbanpy, adafpy, adaepy
      integer nbanpe, adafpe, adaepe, adaipe
      integer         pafatr
c
      integer tbiaux(1)
      integer nbmapo, nbsegm, nbtria, nbtetr,
     >        nbquad, nbhexa, nbpent, nbpyra
      integer decanu(-1:7)
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 nnpafo, nppafo
      character*8 ntrav1, ntrav2
      character*8 ntrava
      character*8 liprof
      character*8 lilopg
      character*8 tbsaux(1)
c
      logical deraff
      logical extrus
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Solution a l''''iteration '',a,'' : '')'
      texte(1,5) = '(''Nombre de paquets de fonctions : '', i3)'
      texte(1,7) = '(5x,''Conversion HOMARD ----> '',a18,/)'
      texte(1,8) = '(/,''Champs sur les '',a)'
      texte(1,9) = '(/,''Champs aux noeuds par element sur les '',a)'
      texte(1,10) = '(/,''Champs aux points de Gauss des '',a)'
      texte(1,11) = '(/,''Champs aux points de Gauss des '',a)'
      texte(1,12) = '(''Paquet de fonction '',a,'' numero : '',i3)'
      texte(1,13) = '(''... fonction numero : '',i3)'
c
      texte(2,4) = '(''Solution at iteration '',a,'' : '')'
      texte(2,5) = '(''Number of packs of functions : '', i3)'
      texte(2,7) = '(5x,''Conversion HOMARD ----> '',a18,/)'
      texte(2,8) = '(/,''Fields over '',a)'
      texte(2,9) = '(/,''Fields based on nodes per element for '',a)'
      texte(2,10) = '(/,''Fields based on Gauss points for '',a)'
      texte(2,11) = '(/,''Fields based on Gauss points for '',a)'
      texte(2,12) = '(''Function pack '',a,'' # : '',i3)'
      texte(2,13) = '(''.. Function # : '',i3)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
#endif
c
c 1.2. ==> nombre de parametres a enregistrer par fonction
c
      nbpara = 26
c
#ifdef _DEBUG_HOMARD_
10000 format(43('='))
      write (ulsort,10000)
      write (ulsort,texte(langue,4)) 'n'
      call gmprsx (nompro, nocson )
      call gmprsx (nompro, nocson//'.InfoCham' )
      call gmprsx (nompro, '%%%%%%%9' )
      call gmprsx (nompro, '%%%%%%%9.Nom_Comp' )
      call gmprsx (nompro, '%%%%%%%9.Cham_Ent' )
      call gmprsx (nompro, '%%%%%%%9.Cham_Car' )
cgn      call gmprsx (nompro, '%%%%%%10' )
cgn      call gmprsx (nompro, '%%%%%%10.Nom_Comp' )
cgn      call gmprsx (nompro, '%%%%%%10.Cham_Ent' )
cgn      call gmprsx (nompro, '%%%%%%11' )
cgn      call gmprsx (nompro, '%%%%%%11.Nom_Comp' )
cgn      call gmprsx (nompro, '%%%%%%11.Cham_Ent' )
cgn      call gmprsx (nompro, '%%%%%%%8' )
cgn      call gmprsx (nompro, '%%%%%%%8.Cham_Ent' )
cgn      call gmprsx (nompro, '%%%%%%%8.Cham_Car' )
cgn      call gmprsx (nompro, '%%%%%%%9' )
cgn      call gmprsx (nompro, '%%%%%%%9.Cham_Ent' )
cgn      call gmprsx (nompro, '%%%%%%%9.Cham_Car' )
      call gmprsx (nompro, nocson//'.InfoPaFo' )
      call gmprsx (nompro, '%%%%%%13' )
      call gmprsx (nompro, '%%%%%%13.Fonction' )
      call gmprsx (nompro, '%%%%%%12' )
cgn      call gmprsx (nompro, '%%%%%%19.Fonction' )
cgn      call gmprsx (nompro, '%%%%%%18' )
cgn      call gmprsx (nompro, '%%%%%%18.InfoPrPG' )
cgn      call gmprsx (nompro, nocson//'.InfoProf' )
      write (ulsort,10000)
#endif
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
#include "mslve4.h"
      endif
c
      if ( codret.eq.0 ) then
c
        if ( ( rafdef.eq.3 .or. rafdef.eq.4 ) .and. nbiter.gt.0 ) then
          deraff = .true.
        else
          deraff = .false.
        endif
c
        if ( typcca.eq.26 .or .typcca.eq.46 ) then
          extrus = .false.
        elseif ( maextr.ne.0 ) then
          extrus = .true.
        else
          extrus = .false.
        endif
c
      endif
c
c 2.2. ==> les tableaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2 ==> les tableaux ; codret', codret
#endif
c
c 2.2.1. ==> tableaux lies a la solution
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCASO', nompro
#endif
      call utcaso ( nocson,
     >              nbcham, nbpafo, nbprof, nblopg,
     >              aninch, aninpf, aninpr, aninlg,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nbpafo
#endif
c
      endif
c
c 2.2.2. ==> les renumerotations
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2.2 ==> renumerotations ; codret', codret
#endif
c
c 2.2.2.1. ==> la renumerotation a l'iteration n
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( norenn//'.Nombres', adnbrn, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNBMH', nompro
#endif
      call utnbmh ( imem(adnbrn),
     >              renois, renoei, renomp,
     >              renop1,   iaux,   iaux,
     >                iaux,   iaux,   iaux,
     >                iaux,   iaux,   iaux,   iaux,
     >              nbmapo, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpent, nbpyra,
     >                iaux,   iaux,
     >                iaux,   iaux,
     >              ulsort, langue, codret )
c
      reno1i = renois + renoei + renomp + renop1
c
c cf. eslmm2
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
      write(ulsort,90002) 'nbmapo', nbmapo
      write(ulsort,90002) 'nbsegm', nbsegm
      write(ulsort,90002) 'nbtria', nbtria
      write(ulsort,90002) 'nbtetr', nbtetr
      write(ulsort,90002) 'nbquad', nbquad
      write(ulsort,90002) 'nbhexa', nbhexa
      write(ulsort,90002) 'nbpent', nbpent
      write(ulsort,90002) 'nbpyra', nbpyra
      write(ulsort,90002) 'decanu', decanu
#endif
c
      endif
c
c 2.2.2.2. ==> la renumerotation a l'iteration n+1
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( norenu//'.Nombres', adnbrp, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      rsnois = imem(adnbrp)
      rsnoei = imem(adnbrp+1)
      rsnomp = imem(adnbrp+2)
      rsnop1 = imem(adnbrp+3)
      rsnop2 = imem(adnbrp+4)
      rsnoim = imem(adnbrp+5)
      rseutc = imem(adnbrp+6)
c
      endif
c
c 2.2.3. ==> les tableaux generaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2.3 tableaux generaux ; codret', codret
#endif
c
c 2.2.3.1. ==> pour les noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)' 2.2.3.1. noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 6
      call utad01 (   iaux, nhnoeu,
     >              phetno,
     >                jaux,   jaux,   jaux,
     >              pcoono,   jaux,   jaux,  jaux,
     >              ulsort, langue, codret )
c
      if ( deraff .or.
     >    ( option.eq.1 .and. degre.eq.1 ) ) then
        call gmadoj ( nhnoeu//'.Deraffin', pancno, iaux, codre0 )
        codret = max ( abs(codre0), codret )
      else
        pancno = 1
      endif
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '. apres noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_no_new', nompro
#endif
      iaux = -1
      jaux = 210
      call utre03 ( iaux, jaux, norenu,
     >              rsnoac, rsnoto, adnohp, adnocp,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_no_old', nompro
#endif
      iaux = -1
      jaux = 210
      call utre03 ( iaux, jaux, norenn,
     >              renoac, renoto, adnohn, adnocn,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE04_no_old', nompro
#endif
      iaux = -1
      jaux = 11
      call utre04 ( iaux, jaux, norenn,
     >              lgnoin, adnoin,
     >              ulsort, langue, codret)
c
      endif
c
c 2.2.3.2. ==> pour les aretes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)' 2.2.3.2. aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD97_ar', nompro
#endif
      iaux = 1
      jaux = 1
      call utad97 (   iaux,   jaux, deraff, extrus,
     >              nharet, norenu, norenn, nosvmn,
     >              phetar, psomar,   kaux, pfilar,   kaux,
     >              pfamar, pcfaar, pnp2ar,   kaux,
     >              nbanar, pancar,
     >              adafar, adaear,   kaux,   kaux,
     >              rsarto, adarcp,
     >              rearac, rearto, adarhn, adarcn,
     >              lgarin, adarin,
     >              ulsort, langue, codret )
c
      endif
c
c
c 2.2.3.3. ==> pour les triangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)' 2.2.3.3. triangles ; codret', codret
#endif
c
      if ( nbtrto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD97_tr', nompro
#endif
        iaux = 2
        jaux = 1
        call utad97 (   iaux,   jaux, deraff, extrus,
     >                nhtria, norenu, norenn, nosvmn,
     >                phettr, paretr,   kaux, pfiltr, ppertr,
     >                pfamtr, pcfatr, adpetr,   kaux,
     >                nbantr, panctr,
     >                adaftr, adaetr, pafatr,   kaux,
     >                rstrto, adtrcp,
     >                retrac, retrto, adtrhn, adtrcn,
     >                lgtrin, adtrin,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 2.2.3.4. ==> pour les tetraedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)' 2.2.3.4. tetraedres ; codret', codret
#endif
c
      if ( nbteto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD97_te', nompro
#endif
        iaux = 3
        jaux = 1
        call utad97 (   iaux,   jaux, deraff, extrus,
     >                nhtetr, norenu, norenn, nosvmn,
     >                phette, ptrite, parete, pfilte, pmerte,
     >                pfamte,   kaux, pcotrt,   kaux,
     >                nbante, pancte,
     >                adafte, adaete,   kaux,   kaux,
     >                rsteto, adtecp,
     >                reteac, reteto, adtehn, adtecn,
     >                lgtein, adtein,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 2.2.3.5. ==> pour les quadrangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)' 2.2.3.5. quadrangles ; codret', codret
#endif
c
      if ( nbquto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD97_qu', nompro
#endif
        iaux = 4
        jaux = 1
        call utad97 (   iaux,   jaux, deraff, extrus,
     >                nhquad, norenu, norenn, nosvmn,
     >                phetqu, parequ,   kaux, pfilqu, pperqu,
     >                pfamqu, pcfaqu, adhequ,   kaux,
     >                nbanqu, pancqu,
     >                adafqu, adaequ,   kaux,   kaux,
     >                rsquto, adqucp,
     >                requac, requto, adquhn, adqucn,
     >                lgquin, adquin,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 2.2.3.6. ==> pour les pyramides
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)' 2.2.3.6. pyramides ; codret', codret
#endif
c
      if ( nbpyto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD97_py', nompro
#endif
        iaux = 5
        jaux = 1
        call utad97 (   iaux,   jaux, deraff, extrus,
     >                nhpyra, norenu, norenn, nosvmn,
     >                phetpy, pfacpy, parepy, pfilpy, pmerpy,
     >                pfampy,   kaux, pcofay,   kaux,
     >                nbanpy, pancpy,
     >                adafpy, adaepy,   kaux,   kaux,
     >                rspyto, adpycp,
     >                repyac, repyto, adpyhn, adpycn,
     >                lgpyin, adpyin,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 2.2.3.7. ==> pour les hexaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)' 2.2.3.7. hexaedres ; codret', codret
#endif
c
      if ( nbheto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD97_He', nompro
#endif
        iaux = 6
        if ( nbheco.eq.0 ) then
          jaux = 1
        else
          jaux = 2
        endif
        call utad97 (   iaux,   jaux, deraff, extrus,
     >                nhhexa, norenu, norenn, nosvmn,
     >                phethe, pquahe, parehe, pfilhe, pmerhe,
     >                pfamhe,   kaux, pcoquh, adhes2,
     >                nbanhe, panche,
     >                adafhe, adaehe,   kaux, adaihe,
     >                rsheto, adhecp,
     >                reheac, reheto, adhehn, adhecn,
     >                lghein, adhein,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 2.2.3.8. ==> pour les pentaedres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)' 2.2.3.8. pentaedres ; codret', codret
#endif
c
      if ( nbpeto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD97_Pe', nompro
#endif
        iaux = 7
        if ( nbpeco.eq.0 ) then
          jaux = 1
        else
          jaux = 2
        endif
        call utad97 (   iaux,   jaux, deraff, extrus,
     >                nhpent, norenu, norenn, nosvmn,
     >                phetpe, pfacpe, parepe, pfilpe, pmerpe,
     >                pfampe,   kaux, pcofap, adpes2,
     >                nbanpe, pancpe,
     >                adafpe, adaepe,   kaux, adaipe,
     >                rspeto, adpecp,
     >                repeac, repeto, adpehn, adpecn,
     >                lgpein, adpein,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
cgn      call gmprsx(nompro,norenn//'.InfoSupE')
cgn      call gmprsx(nompro,norenn//'.InfoSupE.Tab3')
cgn      call gmprsx(nompro,norenn//'.InfoSupE.Tab4')
cgn      call gmprsx(nompro,norenn//'.InfoSupE.Tab6')
cgn      call gmprsx(nompro,norenn//'.TrCalcul')
cgn      call gmprsx(nompro,norenn//'.TrHOMARD')
cgn      call gmprsx(nompro,norenn//'.QuCalcul')
cgn      call gmprsx(nompro,norenn//'.QuHOMARD')
c====
c 3. allocations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. allocation ; codret', codret
#endif
c
c 3.1. ==> allocation de l'objet de tete
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALSO', nompro
#endif
      call utalso ( nocsop,
     >              nbcham, nbpafo, nbprof, nblopg,
     >              apinch, apinpf, apinpr, apinlg,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2. ==> copie des caracteristiques des champs
c
      if ( codret.eq.0 ) then
c
      call gmcpgp ( nocson//'.InfoCham',
     >              nocsop//'.InfoCham', codre1 )
      call gmadoj ( nocsop//'.InfoCham', apinch, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
cgn      call gmprsx (nompro, nocsop )
cgn      call gmprsx (nompro, nocsop//'.InfoCham' )
cgn      call gmprsx('1er champ :', smem(apinch))
cgn      call gmprsx ('  Fonction      Profil        LocaPG ',
cgn     >             smem(apinch)//'.Cham_Car')
cgn      if ( nbcham.ge.2 ) then
cgn        call gmprsx('2nd champ :', smem(apinch+1))
cgn        call gmprsx ('  Fonction      Profil        LocaPG ',
cgn     >               smem(apinch+1)//'.Cham_Car')
c
      endif
c
c 3.3. ==> allocation d'une memorisation des profils eventuels
c          on alloue 3 fois plus grand pour tenir compte des
c          eventuelles mailles de conformite
c
      if ( codret.eq.0 ) then
c
      npprof = 0
c
cgn      write (ulsort,90002) 'nbprof', nbprof
      nbproi = 3*nbprof
      call gmalot ( liprof, 'chaine  ', nbproi, approf, codret )
c
      endif
c
c 3.4. ==> allocation d'une memorisation des localisations de points
c          de Gauss eventuelles
c          on alloue 3 fois plus grand pour tenir compte des
c          eventuelles mailles de conformite
c
      if ( codret.eq.0 ) then
c
      nplopg = 0
c
cgn      write (ulsort,90002) 'nbpafo =', nbpafo
      nblpgi = 3*nbpafo
      call gmalot ( lilopg, 'chaine  ', nblpgi, aplopg, codret )
c
      endif
c
c 3.5. ==> allocation d'une memorisation des tableaux temporaires
c
      if ( codret.eq.0 ) then
c
      iaux = 20*nbpafo
      call gmalot ( ntrava, 'chaine  ', iaux, adtrav, codret )
c
      endif
c
c====
c 4. On classe les paquets de fonctions ainsi :
c     . la premiere serie traite les champs aux noeuds par element
c     . la seconde serie traite les autres champs
c     Cela est indispensable pour pouvoir traiter les interpolations
c     des champs exprimes aux points de Gauss dans le cas ou ils
c     sont lies aux champs aux noeuds par elements : ils ont besoin des
c     valeurs actualisees de leurs projection aux noeuds par element
c
c    Pour chaque paquet de fonctions :
c      tnpgpf : type geometrique associe
c      ngauss : nombre de points de gauss
c      carsup : caracteristiques du support
c                1, si aux noeuds par elements
c                2, si aux points de Gauss, associe avec
c                   un champ aux noeuds par elements
c                3, si aux points de Gauss autonome
c                0, sinon
c      typint : type d'interpolation
c                0, si automatique
c                aux noeuds : 1 si degre 1, 2 si degre 2, 3 si iso-P2
c                par element : 0 si intensif, 1 si extensif
c
c     La liste allouee ici contient donc les noms des paquets de
c     fonctions dans l'ordre du traitement. Cela occupe les nbpafo
c     premieres cases.
c     Dans les nbpafo cases suivantes, on memorise le paquet associe
c     dans le cas de champs aux noeuds par elements ou aux points
c     de Gauss.
c
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. classement ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 2*nbpafo
      call gmalot ( ntrav2, 'chaine  ', iaux, adtra2, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      jaux = adtra2
c
      do 41 , nrpass = 1 , 2
cgn          write (ulsort,90002) '== NRPASS ====', nrpass
c
        do 411 , nrpafo = 1 , nbpafo
c
          if ( codret.eq.0 ) then
c
          nnpafo = smem(aninpf+nrpafo-1)
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,12)) nnpafo, nrpafo
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
          call utcapf ( nnpafo,
     >                  nnfopa, tnpgpf, ngauss, carsup, typint,
     >                  anobfo, antyge,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,90002) 'nnfopa', nnfopa
          write (ulsort,90002) 'tnpgpf', tnpgpf
          write (ulsort,90002) 'carsup', carsup
          write (ulsort,90002) 'typint', typint
          write (ulsort,*) (smem(anobfo+iaux),' ',iaux=0,nnfopa)
          endif
#endif
c
          if ( nrpass.eq.1 .and. carsup.eq.1 ) then
            iaux = 1
          elseif ( nrpass.eq.2 .and.
     >           ( carsup.eq.0 .or. carsup.eq.2 .or. carsup.eq.3) ) then
            iaux = 1
          else
            iaux = 0
          endif
cgn          write (ulsort,90002) '===> iaux', iaux
          if ( iaux.ne.0 ) then
            smem(jaux) = nnpafo
cc            smem(jaux+nbpafo) = smem(anobfo+nnfopa)
            jaux = jaux + 1
          endif
c
          endif
c
  411   continue
c
   41 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, ntrav2 )
#endif
c
c====
c 5. Exploration des divers paquets de fonctions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Exploration ; codret', codret
#endif
c
      do 50 , nrpafo = 1 , nbpafo
c
        nbtrav = 0
c
c 5.1. ==> caracterisation du paquet de fonctions courant
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.1. caracterisation ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        nnpafo = smem(adtra2+nrpafo-1)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) ' '
        write (ulsort,texte(langue,12)) nnpafo, nrpafo
#endif
c
#ifdef _DEBUG_HOMARD_
c        write (ulsort,10000)
        write (ulsort,texte(langue,12)) 'n', nrpafo
        call gmprsx (nompro, nnpafo )
c      couple (nom objet Fonction, nom objet Fonction associe eventuel)
cgn        call gmprsx (
cgn     >   'couples (objet Fonction, objet Fonction associe eventuel) :',
cgn     >    nnpafo//'.Fonction' )
cgn        call gmprsx (nompro, nnpafo//'.TypeSuAs' )
        if ( nrpafo.eq.-1 ) then
          call gmprsx (nompro, '%%%%%%15' )
        elseif ( nrpafo.eq.-2 ) then
          call gmprsx (nompro, '%%%%%%16' )
        elseif ( nrpafo.eq.-3 ) then
          call gmprsx (nompro, '%%%%%%17' )
        endif
cgn        call gmprsx (nompro, '%%%%%%%9' )
cgn        call gmprsx (nompro, '%%%%%%%9.InfoPrPG' )
cgn        call gmprsx (nompro, '%%%%%%14.ListEnti' )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
        call utcapf ( nnpafo,
     >                nnfopa, tnpgpf, ngauss, carsup, typint,
     >                anobfo, antyge,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,90002) 'nnfopa', nnfopa
        write (ulsort,90002) 'tnpgpf', tnpgpf
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,90002) 'typint', typint
        write (ulsort,*)
     >'couples (objet Fonction, objet Fonction associe eventuel) :'
        write (ulsort,*) (smem(anobfo+iaux),' ',iaux=0,nnfopa)
        call gmprsx ('1ere fonction du paquet', smem(anobfo) )
        call gmprsx ('  Profil        LocaPG        F. Associee',
     >               smem(anobfo)//'.InfoPrPG' )
        endif
#endif
c
        endif
c
c 5.2. ==> creation du paquet pour la solution en sortie
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.2. creation ; codret', codret
#endif
c 5.2.1. ==> allocation d'un nouveau paquet
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALPF', nompro
#endif
        npfopa = 0
        typgpf = tnpgpf
        call utalpf ( nppafo,
     >                npfopa, typgpf, ngauss, carsup, typint,
     >                apobfo, aptyge,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'Le paquet ',nppafo,' est cree :'
        call gmprsx (nompro, nppafo )
#endif
c
        endif
c
c 5.2.2. ==> memorisation
c
        if ( codret.eq.0 ) then
c
        smem(apinpf+nrpafo-1) = nppafo
        smem(adtra2+nrpafo-1+nbpafo) = nppafo
c
        endif
c
c 5.3. ==> copie eventuelle des types associes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.3. copie ; codret', codret
#endif
c
        if ( typgpf.lt.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMOPF', nompro
#endif
          iaux = 5
          jaux = abs(typgpf)
          call utmopf ( nppafo, iaux,
     >                  jaux, tbsaux, imem(antyge),
     >                  nnpafo,
     >                  npfopa, typgpf, ngauss, carsup, typint,
     >                  apobfo,
     >                  ulsort, langue, codret )
c
          endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,*) (smem(apobfo+iaux),iaux=0,npfopa),nompro
        endif
#endif
c
        endif
c
c 5.4. ==> Pour un champ aux points de Gauss avec lien sur des
c          elements aux noeuds, memorisation du paquet associe
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.4. paquet associe ; codret', codret
#endif
c
        if ( carsup.eq.2 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMOPF', nompro
#endif
          iaux = 4
          call utmopf ( nppafo, iaux,
     >                  nbpafo, smem(adtra2), tbiaux,
     >                  nnpafo,
     >                  npfopa, typgpf, ngauss, carsup, typint,
     >                  apobfo,
     >                  ulsort, langue, codret )
c
          endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,*) (smem(apobfo+iaux),iaux=0,npfopa),nompro
        endif
#endif
c
        endif
c
c 5.5. ==> stockage des informations liees aux fonctions du paquet
c          adtr1i : caracteristiques entieres des fonctions :
c                   anc/nou, typcha, typgeo, typass, ngauss, etc.
c          adtr1s : caracteristiques caracteres des fonctions
c                   nom fonc., nom fonc. n, nom fonc. p, etc.
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.5. stockage ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        iaux = nbpara*nnfopa*3
        call gmalot ( ntrav1, 'entier  ', iaux, adtr1i, codre1 )
        smem(adtrav) = ntrav1
        call gmalot ( ntrav1, 'chaine  ', iaux, adtr1s, codre2 )
        smem(adtrav+1) = ntrav1
        nbtrav = 2
cgn        print *,nompro,' 5.4 nbtrav = ', nbtrav
cgn        print *,(' ',smem(adtrav+iaux-1),iaux=1,nbtrav)
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
      write (ulsort,texte(langue,3)) 'PCFORE', nompro
      call gmprsx (nompro,smem(anobfo+nnfopa-1))
      call gmprsx (nompro,smem(anobfo+nnfopa-1)//'.InfoCham')
cgn      call gmprsx (nompro,'%%%%%%%8')
cgn      call gmprsx (nompro,'%%%%%%%8.Nom_Comp')
cgn      call gmprsx (nompro,'%%%%%%%8.Cham_Ent')
cgn      call gmprsx (nompro,'%%%%%%%8.Cham_Car')
cgn      call gmprsx (nompro,smem(anobfo+nnfopa-1)//'.InfoPrPG')
#endif
        call pcfore ( option, extrus,
     >                nnfopa, anobfo,
     >                npfopa, nppafo,
     >                nbpara, imem(adtr1i), smem(adtr1s),
     >                nbtrav, smem(adtrav),
     >                adpetr, adhequ,
     >                adnohn, admphn, adarhn, adtrhn, adquhn,
     >                adtehn, adpyhn, adhehn, adpehn,
     >                adnocn, admpcn, adarcn, adtrcn, adqucn,
     >                adtecn, adpycn, adhecn, adpecn,
     >                adnoin, admpin, adarin, adtrin, adquin,
     >                adtein, adpyin, adhein, adpein,
     >                lgnoin, lgmpin, lgarin, lgtrin, lgquin,
     >                lgtein, lgpyin, lghein, lgpein,
     >                decanu,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,90002) 'Apres PCFORE, npfopa', npfopa
cgn        write (ulsort,10000)
cgn        call gmprsx (nompro,smem(adtrav))
cgn        call gmprsx (nompro,smem(adtrav+1))
        write (ulsort,texte(langue,12)) 'p', nrpafo
        call gmprsx (nompro, nppafo )
        call gmprsx (nompro, nppafo//'.Fonction' )
cgn        call gmprsx (nompro, nppafo//'.TypeSuAs' )
        endif
#endif
c
c 5.6. ==> mise a jour selon le support de chaque fonction du paquet
cgn        print *,nompro,' 5.6 nbtrav = ', nbtrav
cgn        print *,(' ',smem(adtrav+iaux-1),iaux=1,nbtrav)
cgn        call gmprsx (nompro, '%%%%%%25' )
cgn        call gmprsx (nompro, '%%%%%%26' )
cgn        call gmprsx (nompro, '%%%%%%28' )
cgn        call gmprsx (nompro, '%%%%%%29' )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.6. mise a jour ; codret', codret
#endif
c
        do 56 , nrfonc = 1 , nnfopa
c
c 5.6.1. ==> le type de support
c
          if ( codret.eq.0 ) then
c
          typgeo = imem(adtr1i-1+nbpara*(nrfonc-1)+3)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) '=============================='
          write (ulsort,texte(langue,13)) nrfonc
          write (ulsort,90002) 'typgeo', typgeo
#endif
c
          endif
c
          iaux = nrfonc
c
c 5.6.2. ==> sur les noeuds
c
          if ( typgeo.eq.0 ) then
c
            if ( codret.eq.0 ) then
c
            write (ulsort,texte(langue,8)) mess14(langue,3,-1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSONO', nompro
#endif
            call pcsono ( renop1, renoto, typint, deraff, option,
     >                    nbpara, imem(adtr1i), smem(adtr1s), iaux,
     >                    imem(phetno), imem(pancno),
     >                    imem(adnohn), imem(adnocn), imem(adnohp),
     >                    imem(phetar), imem(psomar), imem(pfilar),
     >                    imem(pnp2ar),
     >                    imem(phettr), imem(paretr), imem(pfiltr),
     >                    imem(phetqu), imem(parequ), imem(pfilqu),
     >                    imem(ptrite), imem(pcotrt), imem(parete),
     >                    imem(pfilte), imem(phette),
     >                    imem(pquahe), imem(pcoquh), imem(parehe),
     >                    imem(pfilhe), imem(phethe), imem(adhes2),
     >                    imem(pfacpe), imem(pcofap), imem(parepe),
     >                    imem(pfilpe), imem(phetpe), imem(adpes2),
     >                    imem(pfacpy), imem(pcofay), imem(parepy),
     >                    ulsort, langue, codret )
c
            endif
c
c 5.6.3. ==> sur les aretes
c
          elseif ( typgeo.eq.edseg2 .or. typgeo.eq.edseg3 ) then
c
            if ( codret.eq.0 ) then
c
            write (ulsort,texte(langue,8+carsup)) mess14(langue,3,1)
cgn          print *,'sur les aretes, avec carsup = ', carsup
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSOAR', nompro
#endif
            call pcsoar ( typint, deraff,
     >                    nbpara, imem(adtr1i), smem(adtr1s), iaux,
     >                    imem(phetar), imem(pancar), imem(pfilar),
     >                    imem(psomar),
     >                    rmem(pcoono),
     >                    imem(phettr), imem(paretr), imem(pfiltr),
     >                    imem(phetqu), imem(parequ), imem(pfilqu),
     >                    nbanar, imem(adafar),
     >                    imem(adarcn), imem(adarcp),
     >                    ulsort, langue, codret )
c
            endif
c
c 5.6.4. ==> sur les triangles
c
          elseif ( typgeo.eq.edtri3 .or. typgeo.eq.edtri6 ) then
c
            if ( codret.eq.0 ) then
c
            write (ulsort,texte(langue,8+carsup)) mess14(langue,3,2)
cgn          print *,'sur les triangles, avec carsup = ', carsup
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSOTR', nompro
#endif
            call pcsotr ( typint, deraff, option,
     >                    nbpara, imem(adtr1i), smem(adtr1s), iaux,
     >                    imem(phettr), imem(panctr), imem(pfiltr),
     >                    nbantr, imem(adaftr), imem(adaetr),
     >                    imem(adtrcn), imem(adtrcp),
     >                    ulsort, langue, codret )
c
            endif
c
c 5.6.5. ==> sur les quadrangles
c
          elseif ( typgeo.eq.edqua4 .or. typgeo.eq.edqua8 ) then
c
            if ( codret.eq.0 ) then
c
            write (ulsort,texte(langue,8+carsup)) mess14(langue,3,4)
cgn          print *,'sur les quadrangles, avec carsup = ', carsup
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'PCSOQU', nompro
#endif
            call pcsoqu ( typint, deraff, option,
     >                    nbpara, imem(adtr1i), smem(adtr1s), iaux,
     >                    rmem(pcoono),
     >                    imem(psomar),
     >                    imem(paretr),
     >                    imem(parequ),
     >                    imem(phetqu), imem(pancqu), imem(pfilqu),
     >                    nbanqu, imem(adafqu), imem(adaequ),
     >                    imem(adqucn), imem(adqucp),
     >                    nbantr, imem(pafatr),
     >                    imem(adtrcn), imem(adtrcp),
     >                    ulsort, langue, codret )
c
            endif
c
c 5.6.6. ==> sur les tetraedres
c
          elseif ( typgeo.eq.edtet4 .or. typgeo.eq.edte10 ) then
c
            if ( codret.eq.0 ) then
c
            write (ulsort,texte(langue,8+carsup)) mess14(langue,3,3)
cgn          print *,'sur les tetraedres, avec carsup = ', carsup
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSOTE', nompro
#endif
            call pcsote ( typint, deraff,
     >                    nbpara, imem(adtr1i), smem(adtr1s), iaux,
     >                    imem(phette), imem(pancte), imem(pfilte),
     >                    nbante, imem(adafte), imem(adaete),
     >                    imem(adtecn), imem(adtecp),
     >                    ulsort, langue, codret )
c
            endif
c
c
c 5.6.7. ==> sur les hexaedres
c
          elseif ( typgeo.eq.edhex8 .or. typgeo.eq.edhe20  ) then
c
            if ( codret.eq.0 ) then
c
            write (ulsort,texte(langue,8+carsup)) mess14(langue,3,6)
cgn          print *,'sur les hexaedres, avec carsup = ', carsup
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSOHE', nompro
#endif
            call pcsohe ( typint, deraff,
     >                    nbpara, imem(adtr1i), smem(adtr1s), iaux,
     >                    rmem(pcoono),
     >                    imem(psomar),
     >                    imem(paretr),
     >                    imem(parequ),
     >                    imem(ptrite), imem(pcotrt), imem(parete),
     >                    imem(pquahe), imem(pcoquh), imem(parehe),
     >                    imem(pfacpy), imem(pcofay), imem(parepy),
     >                    imem(phethe), imem(panche), imem(pfilhe),
     >                    imem(adhes2),
     >                    nbanhe,
     >                    imem(adafhe), imem(adaehe), imem(adaihe),
     >                    imem(adhecn), imem(adhecp),
     >                    imem(adtecn), imem(adtecp),
     >                    imem(adpycn), imem(adpycp),
     >                    ulsort, langue, codret )
c
            endif
c
c 5.6.8. ==> sur les pentaedres
c
          elseif ( typgeo.eq.edpen6 .or. typgeo.eq.edpe15 ) then
c
            if ( codret.eq.0 ) then
c
            write (ulsort,texte(langue,8+carsup)) mess14(langue,3,7)
cgn          print *,'sur les pentaedres, avec carsup = ', carsup
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSOPE', nompro
#endif
            call pcsope ( typint, deraff,
     >                    nbpara, imem(adtr1i), smem(adtr1s), iaux,
     >                    rmem(pcoono),
     >                    imem(psomar),
     >                    imem(paretr),
     >                    imem(parequ),
     >                    imem(ptrite), imem(pcotrt), imem(parete),
     >                    imem(pfacpe), imem(pcofap), imem(parepe),
     >                    imem(pfacpy), imem(pcofay), imem(parepy),
     >                    imem(phetpe), imem(pancpe), imem(pfilpe),
     >                    imem(adpes2),
     >                    nbanpe,
     >                    imem(adafpe), imem(adaepe), imem(adaipe),
     >                    imem(adpecn), imem(adpecp),
     >                    imem(adtecn), imem(adtecp),
     >                    imem(adpycn), imem(adpycp),
     >                    ulsort, langue, codret )
c
            endif
c
c 5.6.9. ==> sur les pyramides
c
cgn          elseif ( typgeo.eq.edpyr5 .or. typgeo.eq.edpy13 ) then
c
cgn            if ( codret.eq.0 ) then
c
cgn            write (ulsort,texte(langue,8+carsup)) mess14(langue,3,5)
cgn          print *,'sur les pyramides, avec carsup = ', carsup
cgn            codret = 568
c
cgn            endif
c
          endif
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,texte(langue,12)) 'p', nrpafo
          endif
#endif
c
   56   continue
c
c 5.7. ==> mise a jour
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.7. mise a jour ; codret', codret
#endif
c
c 5.7.1. ==> recuperation des caracteristiques du paquet de fonctions p
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
        call utcapf ( nppafo,
     >                npfopa, typgpf, ngauss, carsup, typint,
     >                apobfo, aptyge,
     >                ulsort, langue, codret )
c
        endif
c
c 5.7.2. ==> mise a jour des caracteristiques des profils
cgn      write(ulsort,93020)'5.7.2',(smem(adtr1s+iaux-1),iaux=1,7)
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCAPR', nompro
#endif
        call pccapr ( npfopa, npprof, smem(approf),
     >                nbpara, imem(adtr1i), smem(adtr1s),
     >                ulsort, langue, codret )
c
        endif
c
c 5.7.3. ==> mise a jour des localisations des points de Gauss
cgn      write(ulsort,93020)'5.7.3 - debut',(smem(adtr1s+iaux-1),iaux=1,7)
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCAPG', nompro
#endif
        call pccapg ( npfopa, nplopg, smem(aplopg),
     >                nbpara, imem(adtr1i), smem(adtr1s),
     >                ulsort, langue, codret )
c
        endif
c
c 5.7.4. ==> mise a jour des caracteristiques du paquet de fonctions
cgn      write(ulsort,93020)'5.7.4',(smem(adtr1s+iaux-1),iaux=1,7)
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCAPF', nompro
#endif
        call pccapf ( nppafo, npfopa, nbcham, smem(apinch),
     >                nbpara, imem(adtr1i), smem(adtr1s),
     >                option,
     >                ulsort, langue, codret )
c
        endif
c
c 5.8. ==> menage
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.8. menage ; codret', codret
      write (ulsort,90002) 'nombre de tableaux', nbtrav
#endif
c
        do 58 , iaux = 1 , nbtrav
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90003) 'tableau ', smem(adtrav+iaux-1)
#endif
c
          call gmobal ( smem(adtrav+iaux-1) , jaux )
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'jaux', jaux
cgn          if ( smem(adtrav+iaux-1).eq.'%%%%%%41')then
cgn          call gmprsx ( nompro, smem(adtrav+iaux-1))
cgn        endif
#endif
c
          if ( jaux.eq.1 ) then
            call gmsgoj ( smem(adtrav+iaux-1) , codret )
          elseif ( jaux.eq.2 ) then
            call gmlboj ( smem(adtrav+iaux-1) , codret )
          else
            codret = -1
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'codret', codret
#endif
c
          endif
c
   58   continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'entre 58 et 50 continue ; codret', codret
#endif
c
   50 continue
c
c====
c 6. finitions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. finitions ; codret', codret
#endif
c
c 6.1. ==> menage de la solution en entree desormais inutile et des
c          tableaux de travail
c
      do 61 , iaux = 1 , nbpafo
c
        if ( codret.eq.0 ) then
c
        call gmsgoj ( smem(adtra2+iaux-1) , codret )
c
        endif
c
   61 continue
c
      if ( codret.eq.0 ) then
c
      call gmsgoj ( nocson , codre1 )
      call gmlboj ( ntrava , codre2 )
      call gmlboj ( ntrav2 , codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 6.2. ==> memorisation des profils
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.2. profils ; codret', codret
#endif
c
      if ( npprof.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro//' liste des profils', liprof )
#endif
        if ( codret.eq.0 ) then
        call gmmod ( liprof, approf, nbproi, npprof, 1, 1, codret )
        endif
c
        if ( codret.eq.0 ) then
        call gmecat ( nocsop, 3, npprof, codre1 )
        call gmcpgp ( liprof, nocsop//'.InfoProf', codre2 )
        call gmlboj ( liprof, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
        endif
c
      endif
c
c 6.3. ==> memorisation des localisations de points de Gauss
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.3. Gauss ; codret', codret
      write (ulsort,90002) 'nplopg', nplopg
#endif
c
      if ( nplopg.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, lilopg )
#endif
        if ( codret.eq.0 ) then
        call gmmod ( lilopg, approf, nblpgi, nplopg, 1, 1, codret )
        endif
c
        if ( codret.eq.0 ) then
        call gmecat ( nocsop, 4, nplopg, codre1 )
        call gmcpgp ( lilopg, nocsop//'.InfoLoPG', codre2 )
        call gmlboj ( lilopg, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
cgn      write (ulsort,10000)
      write (ulsort,texte(langue,4)) 'p'
      call gmprsx (nompro//' apres 6.3', nocsop )
cgn      call gmprsx (nompro, nocsop//'.InfoCham' )
cgn      call gmprsx('1er champ :', smem(apinch))
cgn      call gmprsx ('  Fonction      Profil        LocaPG ',
cgn     >             smem(apinch)//'.Cham_Car')
cgn      if ( nbcham.ge.2 ) then
cgn        call gmprsx('2nd champ :', smem(apinch+1))
cgn        call gmprsx ('  Fonction      Profil        LocaPG ',
cgn     >               smem(apinch+1)//'.Cham_Car')
cgn      endif
cgn        call gmprsx ('  Profil        LocaPG        F. Associee',
cgn     >               '%%%%%%20.InfoPrPG' )
cgn      call gmprsx (nompro, '%%%%%%%9' )
cgn      call gmprsx (nompro, '%%%%%%%9.Nom_Comp' )
cgn      call gmprsx (nompro, '%%%%%%%9.Cham_Ent' )
cgn      call gmprsx (nompro, '%%%%%%%9.Cham_Car' )
cgn      call gmprsx (nompro, '%%%%%%10' )
cgn      call gmprsx (nompro, '%%%%%%10.Nom_Comp' )
cgn      call gmprsx (nompro, '%%%%%%10.Cham_Ent' )
cgn      call gmprsx (nompro, '%%%%%%11' )
cgn      call gmprsx (nompro, '%%%%%%11.Nom_Comp' )
cgn      call gmprsx (nompro, '%%%%%%11.Cham_Ent' )
cgn      call gmprsx (nompro, '%%%%%%%8' )
cgn      call gmprsx (nompro, '%%%%%%%8.Cham_Ent' )
cgn      call gmprsx (nompro, '%%%%%%%8.Cham_Car' )
cgn      call gmprsx (nompro, '%%%%%%%9' )
cgn      call gmprsx (nompro, '%%%%%%%9.Cham_Ent' )
cgn      call gmprsx (nompro, '%%%%%%%9.Cham_Car' )
cgn      call gmprsx (nompro, nocsop//'.InfoPaFo' )
cgn      call gmprsx (nompro, '%%%%%%16' )
cgn      call gmprsx (nompro, '%%%%%%16.Fonction' )
cgn      call gmprsx (nompro, '%%%%%%24' )
cgn      call gmprsx (nompro, '%%%%%%24.ValeursR' )
cgn      call gmprsx (nompro, '%%%%%%24.InfoCham' )
cgn      call gmprsx (nompro, '%%%%%%16' )
cgn      call gmprsx (nompro, '%%%%%%16.Fonction' )
cgn      call gmprsx (nompro, '%%%%%%23' )
cgn      call gmprsx (nompro, '%%%%%%23.ValeursR' )
cgn      call gmprsx (nompro, '%%%%%%23.InfoCham' )
cgn      call gmprsx (nompro, nocsop//'.InfoProf' )
cgncgn      write (ulsort,10000)
      endif
#endif
c
c====
c 7. la fin
c====
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
