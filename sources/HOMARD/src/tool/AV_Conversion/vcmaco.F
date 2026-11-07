      subroutine vcmaco ( modhom, typcce, eleinc,
     >                    tyconf, maext0,
     >                    nocman, nohman, typnom,
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
c    aVant adaptation - Conversion de MAillage - COnnectivite
c     -                 -             --         --
c ______________________________________________________________________
c
c    cette conversion suppose que l'on ne garde du maillage
c    que les elements suivants :
c    . 0D : mailles-points
c    . 1D : poutres
c    . 2D : triangles, quadrangles
c    . 3D : tetraedres, hexaedres, pentaedres, pyramides.
c    le degre est 1 ou 2, mais il est le meme pour toutes les mailles.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . modhom . e   .    1   . mode de fonctionnement de homard           .
c .        .     .        . -5 : executable du suivi de frontiere      .
c .        .     .        . -4 : exec. de l'interface apres adaptation .
c .        .     .        . -3 : exec. de l'interface avant adaptation .
c .        .     .        . -2 : executable de l'information           .
c .        .     .        . -1 : executable de l'adaptation            .
c .        .     .        .  0 : executable autre                      .
c .        .     .        .  1 : homard pur                            .
c .        .     .        .  2 : information                           .
c .        .     .        .  3 : modification de maillage sans adaptati.
c .        .     .        .  4 : interpolation de la solution          .
c . typcce . e   .   1    . type du code de calcul en entree           .
c . eleinc . e   .   1    . elements incompatibles                     .
c .        .     .        . 0 : on bloque s'il y en a                  .
c .        .     .        . 1 : on les ignore s'il y en a              .
c . tyconf . e   .   1    .  0 : conforme (defaut)                     .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2                    .
c .        .     .        .  2 : non-conforme avec 1 seul noeud        .
c .        .     .        .      pendant par arete                     .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
c . maext0 . e   .   1    . maillage extrude                           .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : selon X                                .
c .        .     .        . 2 : selon Y                                .
c .        .     .        . 3 : selon Z (cas de Saturne ou Neptune)    .
c . nocman . e   . char*8 . nom de l'objet maillage calcul iteration n .
c . nohman . es  . char*8 . nom de l'objet maillage homard iteration n .
c . typnom . e   .    1   . type du nom de l'objet maillage            .
c .        .     .        . 0 : le nom est a creer automatiquement     .
c .        .     .        . 1 : le nom est impose par l'appel          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . autre : probleme                           .
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
      parameter ( nompro = 'VCMACO' )
c
#include "nblang.h"
#include "referx.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "dicfen.h"
#include "envca1.h"
#include "envca2.h"
c
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "nombsr.h"
#include "nomest.h"
#include "nbfami.h"
c
#include "rfamed.h"
c
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer modhom, typcce, eleinc, tyconf, maext0
      integer typnom
c
      character*8 nocman, nohman
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer lgnoig
      integer adnoig
      integer pnoemp, phetmp
      integer pcoono, phetno, pareno
      integer psomar
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer phetar, pfilar, pmerar, adars2
      integer phettr, pfiltr, ppertr, pnivtr, paretr, adnmtr
      integer phetqu, pfilqu, pperqu, pnivqu, parequ, adnmqu
      integer ptrite, pcotrt, phette, pfilte, pperte
      integer pquahe, pcoquh, phethe, pfilhe, pperhe, adnmhe
      integer pfacpy, pcofay, phetpy, pfilpy, pperpy
      integer pfacpe, pcofap, phetpe, pfilpe, pperpe
      integer pnp2ar
      integer hfmdel, hnoeel
      integer dimcst
      integer nbpqt, pinftb
c
      integer pcexno, pcexmp, pcexar
      integer pcextr, pcexqu
      integer pcexte, pcexhe, pcexpy, pcexpe
c
      integer adnbrn
      integer adnohn, adnocn, adnoic
      integer admphn, admpcn, admpic
      integer adarhn, adarcn, adaric
      integer adtrhn, adtrcn, adtric
      integer adquhn, adqucn, adquic
      integer adtehn, adtecn, adteic
      integer adhehn, adhecn, adheic
      integer adpyhn, adpycn, adpyic
      integer adpehn, adpecn, adpeic
c
      integer pfamen, pfamee, pnoeel, ptypel, pcoonc
      integer pnuele, pnunoe
c
      integer ptrav1, ptrav2, ptrav3, ptrav4, ptrav5
c
      integer iaux, jaux, kaux, paux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8, codre0
      integer nbnomb, adnomb
      integer voarno, vofaar, vovoar, vovofa
      integer decanu(-1:7)
      integer nbardb, cpt, nbarne, rbarne
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
      character*8 ntrav1, ntrav2, ntrav3, ntrav4, ntrav5
      character*9 saux09
c
      logical existe
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
cmdc ---------------- MAILLES DOUBLES DEBUT --------------
cmd      integer nbelnw, nbtenw
cmd      character*80 nomfic
cmd      logical maildb
cmd      integer adpoin, adtail, adtabl
cmd      integer adnumf
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
      texte(1,4) = '(5x,''Estimation du nombre d''''aretes :'')'
      texte(1,5) = '(7x,''Passage numero'',i5)'
      texte(1,6) = '(5x,''Type de logiciel inconnu :'',i10,/)'
      texte(1,7) = '(5x,''Conversion '',a18,'' ---> HOMARD'',/)'
      texte(1,8) =
     > '(/,5x,i10,'' autres elements.'',/,5x,''Cela est interdit ...'')'
      texte(1,10) ='(/,''On '',a,'' les elements incompatibles.'')'
c
      texte(2,4) = '(5x,''Estimation of the number of edges:'')'
      texte(2,5) = '(7x,''Pass #'',i5)'
      texte(2,6) = '(5x,''This kind of software is unknown:'',i10,/)'
      texte(2,7) = '(5x,''Conversion '',a18,'' ---> HOMARD'',/)'
      texte(2,8) =
     > '(/,5x,i10,'' other elements.'',/,5x,''This is forbidden ...'')'
      texte(2,10) ='(/,''Incompatible elements are '',a)'
c
#include "impr03.h"
c
      typcca = typcce
c
#include "mslve4.h"
c
#ifdef _DEBUG_HOMARD_
      if ( eleinc.eq.0 ) then
        write (ulsort,texte(langue,10)) 'bloque'
      else
        write (ulsort,texte(langue,10)) 'ignore'
      endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typcce', typcce
      write (ulsort,90002) 'tyconf', tyconf
      write (ulsort,90002) 'maext0', maext0
#endif
c
c====
c 2. controle des elements a faces quadrangulaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. faces quadrangulaires ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAURQ', nompro
#endif
c
      call utaurq ( modhom, eleinc,
     >              nocman,
     >              nbelig,
     >              ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbelig', nbelig
#endif
c
      endif
c
c====
c 3. recuperation des donnees du maillage d'entree
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. recuperation donnees ; codret', codret
#endif
c
c 3.1. ==> les noms des structures
#ifdef _DEBUG_HOMARD_
      call gmprsx( nompro, nocman)
cgn      call gmprsx( nompro, nocman//'.ConnNoeu')
cgn      call gmprsx( nompro, nocman//'.ConnNoeu.Noeuds')
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMC', nompro
#endif
      call utnomc ( nocman,
     >              sdimca, mdimca,
     >               degre, mailet, maconf, homolo, hierar,
     >              nbnomb,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret)
c
      endif
c
c 3.2. ==> les principales constantes
c
      if ( codret.eq.0 ) then
c
      call gmliat ( ncnoeu, 1, nbnoto, codre1 )
      call gmliat ( ncnoeu, 2, nctfno, codre2 )
      call gmliat ( ncnoeu, 3, dimcst, codre3 )
      call gmliat ( nccono, 1, nbelem, codre4 )
      call gmliat ( nccono, 2, nbmane, codre5 )
      call gmadoj ( ncnomb, adnomb, iaux, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNBMC', nompro
#endif
      call utnbmc ( imem(adnomb),
     >              nbmaae, nbmafe, nbmnei,
     >              numano, numael,
     >              nbma2d, nbma3d,
     >              nbmapo, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpent, nbpyra,
     >              nbfmed, nbfmen, ngrouc,
     >              nbequi,
     >              nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >              ulsort, langue, codret )
c
      endif
c
c 3.3. ==> les adresses
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD11', nompro
#endif
      iaux = 510510
      call utad11 ( iaux, ncnoeu, nccono,
     >              pcoonc, pfamen, pnunoe,   jaux,
     >              ptypel, pfamee, pnoeel, pnuele,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD12', nompro
#endif
      iaux = 7
      jaux = -1
      call utad12 ( iaux, jaux,
     >              nccoex, pcexno,
     >              ulsort, langue, codret )
c
      endif
c
cmdc ---------------- MAILLES DOUBLES DEBUT --------------
cmdc 3.4. ==> menage des mailles dupliquees
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
cmd      if ( maildb ) then
cmdc
cmdcgn#ifdef _DEBUG_HOMARD_
cmd      write (ulsort,*) 'MENAGE'
cmd#endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd      call gmadoj ( ncfami//'.Numero', adnumf, iaux, codret )
cmdc
cmd      endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdcgn      call gmprsx(nompro,ncfami)
cmdcgn      call gmprsx(nompro,ncfami//'.Numero')
cmdcgn      call gmprsx(nompro,ncfami//'.Groupe')
cmdcgn      call gmprsx(nompro,ncfami//'.Groupe.Pointeur')
cmdcgn      call gmprsx(nompro,ncfami//'.Groupe.Taille')
cmdcgn      call gmprsx(nompro,ncfami//'.Groupe.Table')
cmdc
cmdcgn#ifdef _DEBUG_HOMARD_
cmd      write (ulsort,texte(langue,3)) 'UTRPTC', nompro
cmd#endif
cmd      call utrptc ( ncfami//'.Groupe',
cmd     >              iaux, jaux,
cmd     >              adpoin, adtail, adtabl,
cmd     >              ulsort, langue, codret )
cmdc
cmd      endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd      call gmalot ( ntrav1, 'entier  ', nbelem, ptrav1, codre1 )
cmd      iaux = 2*nbfmed
cmd      call gmalot ( ntrav2, 'entier  ',   iaux, ptrav2, codre2 )
cmdc
cmd      codre0 = min ( codre1, codre2 )
cmd      codret = max ( abs(codre0), codret,
cmd     >               codre1, codre2 )
cmdc
cmd      endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmdcgn      call gmprsx ( nompro, nccono//'.Noeuds')
cmdcgn      write(ulsort,90003) 'norete', norete
cmdcgn      write(ulsort,90002) 'nbeled', nbelem
cmdcgn      write(ulsort,90002) 'nbtetd', nbtetr
cmdcgn#ifdef _DEBUG_HOMARD_
cmd      write (ulsort,texte(langue,3)) 'VCMMEN', nompro
cmd#endif
cmd      call vcmmen
cmd     >        ( nbelem, nbelnw,
cmd     >          nbtetr, nbtenw,
cmd     >          imem(pnoeel), imem(pfamee), imem(ptypel), imem(pnuele),
cmd     >          imem(adnumf),
cmd     >          imem(adpoin), imem(adtail), smem(adtabl),
cmd     >          imem(ptrav1), imem(ptrav2), imem(ptrav2+nbfmed),
cmd     >          ulsort, langue, codret )
cmdc
cmd      endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd      call gmmod ( nccono//'.Noeuds',
cmd     >             pnoeel, nbelem, nbelnw, nbmane, nbmane, codre1 )
cmd      call gmmod ( nccono//'.Type',
cmd     >             ptypel, nbelem, nbelnw, 1, 1, codre2 )
cmd      call gmmod ( nccono//'.FamilMED',
cmd     >             pfamee, nbelem, nbelnw, 1, 1, codre3 )
cmd      call gmmod ( nccono//'.NumeExte',
cmd     >             pnuele, nbelem, nbelnw, 1, 1, codre4 )
cmd      call gmecat ( nccono, 1, nbelnw, codre5 )
cmdc
cmd      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
cmd      codret = max ( abs(codre0), codret,
cmd     >               codre1, codre2, codre3, codre4, codre5 )
cmdc
cmd      endif
cmdc
cmd      if ( codret.eq.0 ) then
cmdc
cmd      nbelem = nbelnw
cmd      numael = numael - nbtetr + nbtenw
cmd      imem(adnomb+4) = numael
cmd      nbtetr = nbtenw
cmd      imem(adnomb+14) = nbtetr
cmdc
cmd      endif
cmd      if ( codret.eq.0 ) then
cmdc
cmd      call gmlboj ( ntrav1 , codre1  )
cmd      call gmlboj ( ntrav2 , codre2  )
cmdc
cmd      codre0 = min ( codre1, codre2 )
cmd      codret = max ( abs(codre0), codret,
cmd     >               codre1, codre2 )
cmdc
cmd      endif
cmdc
cmd      endif
cmdc
cmdc ---------------- MAILLES DOUBLES FIN ----------------
c
c====
c 4. preliminaires
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. preliminaires ; codret', codret
#endif
c
c 4.1.==> initialisations
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTINEI', nompro
#endif
      call utinei ( modhom,
     >              ulsort, langue, codret )
c
      endif
c
c 4.2. ==> allocation de la tete du maillage HOMARD
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAHMA', nompro
#endif
      iaux = 1
      rafdef = 0
      if ( dimcst.eq.0 ) then
        sdim = sdimca
      else
        sdim = sdimca - 1
      endif
      if ( (nbtetr+nbhexa+nbpent+nbpyra).gt.0 ) then
        mdim = 3
      elseif ( (nbtria+nbquad).gt.0 ) then
        mdim = 2
      else
        mdim = 1
      endif
      typsfr = 0
      maextr = maext0
      call utahma ( nohman, typnom, iaux,
     >                sdim,   mdim,  degre, mailet, maconf,
     >              homolo, hierar, rafdef,
     >              nbmane, typcca, typsfr, maextr,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret )
c
      endif
c
c 4.3. ==> renumerotation
c
      if ( codret.eq.0 ) then
c
      iaux = 25
      call gmecat ( norenu, 19, iaux, codre1 )
      call gmaloj ( norenu//'.Nombres', ' ', iaux, adnbrn, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 4.4. ==> les caracteristiques du maillage de calcul
c
      if ( codret.eq.0 ) then
c
      imem(adnbrn+9) = nbelem
      imem(adnbrn+10) = nbmaae
      imem(adnbrn+11) = nbmafe
      imem(adnbrn+12) = nbmane
      imem(adnbrn+13) = nbmapo
      imem(adnbrn+14) = nbsegm
      imem(adnbrn+15) = nbtetr
      imem(adnbrn+16) = nbtria
      imem(adnbrn+17) = nbquad
      imem(adnbrn+18) = numael
      imem(adnbrn+19) = numano
      imem(adnbrn+22) = nbhexa
      imem(adnbrn+23) = nbpyra
      imem(adnbrn+24) = nbpent
c
c 4.5. ==> nombre total de mailles-points, de tetraedres, d'hexaedres,
c          de pentaedres, de pyramides
c
      nbmpto = nbmapo
      nbteto = nbtetr
      nbtecf = nbteto
      nbteca = 0
      nbheto = nbhexa
      nbhecf = nbheto
      nbheca = 0
      nbpeto = nbpent
      nbpecf = nbpeto
      nbpeca = 0
      nbpyto = nbpyra - nbelig
      nbpycf = nbpyto
      nbpyca = 0
c
c 4.6. ==> initialisation des nombres reels de familles
c
      nbfnoe = 0
      nbfmpo = 0
      nbfare = 0
      nbftri = 0
      nbfqua = 0
      nbftet = 0
      nbfhex = 0
      nbfpyr = 0
      nbfpen = 0
c
      endif
c
c====
c 5. traitement des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. traitement des noeuds ; codret', codret
#endif
c
c 5.1. ==> nombres
c
      if ( codret.eq.0 ) then
c
      rsnoac = numano
      rsnoto = nbnoto
c
      endif
c
c 5.2. ==> allocation des tableaux
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nhnoeu, 1, nbnoto, codre1 )
      call gmecat ( nhnoeu, 2, 0, codre2 )
      lgnoig = 4
      call gmecat ( nhnoeu, 3, lgnoig, codre3 )
      call gmecat ( nhnoeu, 4, 0, codre4 )
      call gmaloj ( nhnoeu//'.InfoGene', ' ', lgnoig, adnoig, codre5 )
      call gmaloj ( nhnoeu//'.HistEtat', ' ', nbnoto, phetno, codre6 )
      iaux = sdim * nbnoto
      call gmaloj ( nhnoeu//'.Coor', ' ', iaux, pcoono, codre7 )
      call gmaloj ( nhnoeu//'.AretSupp', ' ', nbnoto, pareno, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      call gmalot ( ntrav1, 'entier  ', nbnoto, ptrav1, codre1 )
      call gmalot ( ntrav2, 'entier  ', nbnoto, ptrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2  )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_no', nompro
#endif
      iaux = -1
      kaux = 2310
      call utre01 ( iaux, kaux, norenu, rsnoac, rsnoto,
     >              adnohn, adnocn, adnoic,
     >              ulsort, langue, codret)
c
      endif
c
c 5.3. ==> les informations generales
c
      if ( codret.eq.0 ) then
        smem(adnoig) = 'm       '
        smem(adnoig+1) = 'x       '
        smem(adnoig+2) = 'y       '
        smem(adnoig+3) = 'z       '
      endif
c
c 5.5. ==> traitement des noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.5. traitement noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMNOE', nompro
#endif
      call vcmnoe ( eleinc, imem(pfamen), imem(pnoeel), imem(ptypel),
     >              dimcst, rmem(pcoonc),
     >              imem(adnohn), imem(adnocn),
     >              rmem(pcoono), imem(phetno), imem(pcexno),
     >              imem(ptrav1), imem(ptrav2),
     >              ulsort, langue, codret )
c
      endif
cgn      call gmprsx ( nompro , norenu//'.NoHOMARD' )
cgn      call gmprsx ( nompro , norenu//'.NoCalcul' )
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codret )
c
      imem(adnbrn) = nbnois
      imem(adnbrn+1) = nbnoei
      imem(adnbrn+2) = nbnomp
      imem(adnbrn+3) = nbnop1
      imem(adnbrn+4) = nbnop2
      imem(adnbrn+5) = nbnoim
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nhnoeu, 2, dimcst, codre1 )
      call gmcpoj ( ncnoeu//'.CoorCons', nhnoeu//'.CoorCons', codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 6. determination des elements 0d, 1d, 2d ou 3d voisins des sommets
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. traitement mailles ; codret', codret
#endif
c
c 6.1. ==> comptage du nombre d'elements pour chaque sommet
c          et determination des pointeurs par sommets sur "voisom",
c          ranges dans la structure "povoso"
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'PtTabEnt', 0, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = nbnoto + 1
      call gmaloj ( ntrav1//'.Pointeur', ' ', iaux, ppovos, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCVOS1', nompro
#endif
      call vcvos1 ( imem(pnoeel), imem(ptypel), imem(ppovos),
     >              nvosom, nbelem, nbmane, nbnoto )
      imem(adnbrn+21) = nvosom
c
      endif
c
c 6.2. ==> reperage des voisins : la structure voisom contient la
c          liste des elements 1d, 2d ou 3d voisins de chaque sommet
c          (allocation du tableau des voisins a une taille egale
c           au nombre cumule de voisins des sommets)
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( ntrav1//'.Table', ' ', nvosom, pvoiso, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCVOS2', nompro
#endif
      call vcvos2 ( imem(pnoeel), imem(ptypel), imem(ppovos),
     >              imem(pvoiso), nvosom, nbelem, nbmane, nbnoto )
c
      endif
cgn      call gmprsx ( nompro, ntrav1 )
cgn      call gmprsx ( nompro, ntrav1//'.Pointeur' )
cgn      call gmprsx ( nompro, ntrav1//'.Table' )
c
c====
c 7. prise en compte des mailles-points
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. traitement mailles-points ; codret',
     >                  codret
#endif
c
c 7.1. ==> memorisation du nombre de mailles-points
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nhmapo, 1, nbmpto, codret )
c
      endif
c
c 7.2. ==> allocation des tableaux
c
      rsmpto = nbmpto
      if ( nbmpto.ne.0 ) then
        rsmpac = numael
      else
        rsmpac = 0
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      jaux = 2
      kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_mp', nompro
#endif
      call utal02 ( iaux, jaux,
     >              nhmapo, nbmpto, kaux,
     >              phetmp, pnoemp,   paux,   paux,
     >                paux,   paux,
     >                paux,   paux,   paux,
     >                paux,   paux,   paux,
     >              ulsort, langue, codret )
c
      iaux = nbmpto * nctfmp
      call gmaloj ( nccoex//'.Point', ' ', iaux  , pcexmp, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_mp', nompro
#endif
      iaux = 0
      kaux = 2310
      call utre01 ( iaux, kaux, norenu, rsmpac, rsmpto,
     >              admphn, admpcn, admpic,
     >              ulsort, langue, codret)
c
      endif
c
c 7.3. ==> remplissage des tableaux
c     e : ntrav1 : voisom, voisinage des sommets
c     e : ntrav2 : povoso, pointeur sur ntrav1=voisom
c
      if ( nbmpto.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMMPO', nompro
#endif
        call vcmmpo
     >          ( imem(pnoemp), imem(phetmp), imem(pcexmp),
     >            imem(adnocn), imem(admphn), imem(admpcn),
     >            imem(pfamee), imem(ptypel),
     >            imem(ppovos), imem(pvoiso),
     >            ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 8. etablissement d'une table de connectivite par arete
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. connectivite par arete ; codret',codret
#endif
c
c 8.1. ==> allocation des tableaux
c      la structure ntrav3 contiendra la table de connectivite par
c      arete pour les elements 2d ou 3d. on la dimensionne au plus
c      large en tenant compte du nombre maximum d'arete par element
c      2d ou 3d du maillage
c      ici, seuls sont concernes les triangles, les quadrangles,
c      les tetraedres, les pentaedres et les hexaedres
c      c'est le tableau areele
c      la structure ntrav4 contiendra le numero de la premiere arete
c      partant d'un sommet donne ; c'est le tableau preare.
c      pour dimensionner les tableaux lies aux aretes, on donne
c      une estimation du nombre total par le maximum possible
c
      if ( codret.eq.0 ) then
c
      iaux = nbelem*nbmaae
      call gmalot ( ntrav3, 'entier  ', iaux  , ptrav3, codre1 )
      call gmalot ( ntrav4, 'entier  ', nbnoto, ptrav4, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 8.2. ==> estimation du nombre d'aretes
c
      if ( codret.eq.0 ) then
c
      nbar00 = nbsegm + 3*nbtria + 4*nbquad
     >       + 6*nbtetr + 8*nbpyra + 12*nbhexa + 9*nbpent
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbar00 initial', nbar00
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMAR0', nompro
#endif
      call vcmar0 ( imem(adnohn), imem(adnocn),
     >              imem(pnoeel), imem(ptypel),
     >              imem(ppovos), imem(pvoiso),
     >              nbardb,
     >              ulsort, langue, codret )
c
      nbar00 = nbar00 - nbardb/2
c
      if ( nbsegm.ne.0 ) then
        rbar00 = nbar00
        rsarac = numael
      else
        rbar00 = 0
        rsarac = 0
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbar00, rbar00, rsarac',
     >                      nbar00, rbar00, rsarac
#endif
c
      cpt = 1
c
      endif
c
c 8.3. ==> allocations
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 30
      if ( degre.eq.2 ) then
        jaux = jaux*13
      endif
      if ( nbelig.ne.0 ) then
        jaux = jaux*17
      endif
      kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_ar', nompro
#endif
      call utal02 ( iaux, jaux,
     >              nharet, nbar00, kaux,
     >              phetar, psomar, pfilar, pmerar,
     >                paux,   paux,
     >                paux, pnp2ar, adars2,
     >                paux,   paux,   paux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = nbar00 * nctfar
      call gmaloj ( nccoex//'.Arete', ' ', iaux  , pcexar, codre1 )
      call gmalot ( ntrav5, 'entier  ', rbar00, ptrav5, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_ar', nompro
#endif
      iaux = 1
      kaux = 2310
      call utre01 ( iaux, kaux, norenu, rsarac, rbar00,
     >              adarhn, adarcn, adaric,
     >              ulsort, langue, codret)
c
      endif
c
c 8.4. ==> etablissement de la table et initialisation des tableaux
c            lies aux aretes
c
   84 continue
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbar00, rbar00', nbar00, rbar00
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMARE', nompro
#endif
      call vcmare
     >        ( imem(ptrav3), imem(psomar), imem(pnp2ar),
     >          imem(phetar), imem(pfilar), imem(pmerar),
     >          imem(pcexar), imem(pareno), imem(adars2),
     >          imem(adnohn), imem(adnocn), imem(adarhn),
     >          imem(adarcn), imem(pfamee), imem(pnoeel),
     >          imem(ptypel), imem(ppovos), imem(pvoiso),
     >          imem(ptrav4),
     >          arsmed, deamed, imem(ptrav5),
     >          imem(ptrav2),
     >          ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '--> nbarto', nbarto
#endif
c
      endif
c
c 8.5. ==> si l'estimation est trop courte, on augmente
c
      if ( codret.eq.0 ) then
c
      if ( nbarto.lt.0 ) then
c
        nbarne = int(1.3d0*dble(nbar00))
        rbarne = int(1.3d0*dble(rbar00))
        cpt = cpt + 1
c
      else
c
        nbarne = nbarto
        rbarne = rsarto
        cpt = 0
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbarne, rbarne', nbarne, rbarne
#endif
c
      endif
c
c 8.6. ==> connaissant le vrai nombre d'aretes, on ajuste les tableaux
c          somare, nareho, nareca, hetare, filare, merare
c          a leurs vraies tailles
c          de plus, on desalloue les tableaux ne servant plus a rien
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8.6 apres vcmare ; codret', codret
#endif
c
      if ( rsarto.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02_ar', nompro
#endif
      iaux = 1
      jaux = 3
      call utre02 ( iaux, jaux, norenu,
     >                kaux, rbar00,   kaux, rbarne,
     >              adarhn, adarcn,
     >              ulsort, langue, codret)
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      jaux = 30
      if ( degre.eq.2 ) then
        jaux = jaux*13
      endif
      if ( nbelig.ne.0 ) then
        jaux = jaux*17
      endif
      kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_ar', nompro
#endif
      call utad06 ( iaux, jaux, kaux, nharet,
     >              nbar00, nbarne,      0,      0,
     >              phetar, psomar, pfilar, pmerar,
     >                paux,
     >                paux, pnp2ar, adars2,
     >                paux,   paux,   paux,   paux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmmod ( nccoex//'.Arete',
     >             pcexar, nbar00, nbarne, nctfar, nctfar, codre1 )
      call gmmod ( ntrav5,
     >             ptrav5, rbar00, rbarne, 1, 1, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 8.7. ==> si l'estimation est trop courte, on recommence
c
      if ( codret.eq.0 ) then
c
      if ( cpt.gt.0 ) then
c
        write (ulsort,texte(langue,4))
        write (ulsort,texte(langue,5)) cpt
        nbar00 = nbarne
        rbar00 = rbarne
        goto 84
c
      endif
c
      endif
c
c 8.8. ==> menage
c
      if ( codret.eq.0 ) then
c
      call gmsgoj ( ntrav1 , codre1 )
      call gmlboj ( ntrav2 , codre2 )
      call gmlboj ( ntrav4 , codre3 )
      call gmlboj ( ntrav5 , codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 9. etablissement d'une table de connectivite par face
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. connectivite par face ; codret', codret
#endif
c
c 9.1. ==> determination des elements 2d ou 3d voisins des aretes
c
c 9.1.1. ==> comptage du nombre d'elements pour chaque arete
c
      if ( codret.eq.0 ) then
c
      iaux = nbarto + 1
      call gmalot ( ntrav2, 'entier  ', iaux  , ptrav2, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCVAR1', nompro
#endif
      call vcvar1 ( imem(ptrav3), imem(ptypel), imem(ptrav2) )
      imem(adnbrn+20) = nvoare
c
      endif
c
c 9.1.2. ==> reperage des voisins
c      allocation du tableau des voisins a une taille
c          egale au nombre cumule de voisins des aretes
c      en sortie :
c      la structure ntrav1 contient la liste des elements 2d ou 3d
c      voisins de chaque arete ; c'est le tableau vofaar
c      la structure ntrav2 contient les pointeurs sur vofaar ; c'est
c      le tableau povoar
c
      if ( codret.eq.0 ) then
      call gmalot ( ntrav1, 'entier  ', nvoare, ptrav1, codret )
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCVAR2', nompro
#endif
      call vcvar2 ( imem(ptrav3), imem(ptypel), imem(ptrav1),
     >              imem(ptrav2) )
c
      endif
c
c 9.2. ==> allocation des tableaux
c      la structure ntrite contiendra la table de connectivite par
c      face. on la dimmensionne au plus large en tenant compte du
c      nombre maximum de face par element 3d du maillage ; c'est le
c      tableau areele.
c      la structure ntrav4 contiendra le numero de la premiere face
c      partant d'une arete donnee ; c'est le tableau prefac.
c      pour dimensionner les tableaux lies aux faces, on donne
c      une estimation du nombre total par le maximum possible.
c
c 9.2.1. ==> on verifie qu'il y a assez de place avant de se lancer
c
      if ( codret.eq.0 ) then
c
      nbtr00 = nbtria + 4*nbtetr + 4*nbpyra + 2*nbpent
      if ( nbtria.ne.0 ) then
        rbtr00 = nbtr00
        rstrac = numael
      else
        rbtr00 = 0
        rstrac = 0
      endif
c
      nbqu00 = nbquad + 6*nbhexa + nbpyra + 3*nbpent
      if ( nbquad.ne.0 ) then
        rbqu00 = nbqu00
        rsquac = numael
      else
        rbqu00 = 0
        rsquac = 0
      endif
c
      rsteto = nbteto
      if ( nbteto.ne.0 ) then
        rsteac = numael
      else
        rsteac = 0
      endif
c
      rsheto = nbheto
      if ( nbheto.ne.0 ) then
        rsheac = numael
      else
        rsheac = 0
      endif
c
      rspyto = nbpyto
      if ( nbpyto.ne.0 ) then
        rspyac = numael
      else
        rspyac = 0
      endif
c
      rspeto = nbpeto
      if ( nbpeto.ne.0 ) then
        rspeac = numael
      else
        rspeac = 0
      endif
c
      endif
c
c 9.2.2. ==> allocation
c
      if ( codret.eq.0 ) then
c
c 9.2.2.1. ==> pour les triangles, dans deux cas :
c            . il y en a (quelle bonne idee)
c            . il n'y en a pas, mais les quadrangles decoupes par
c              conformite pourraient en produire ; on cree le tableau
c              de sauvegarde des codes externes
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.1. triangles ; codret', codret
      write (ulsort,90002) 'nbtr00, nbqu00', nbtr00, nbqu00
#endif
c
      if ( nbtr00.ne.0 ) then
c
        if ( mod(mailet,3).eq.0 ) then
          if ( mod(mailet,2).ne.0 ) then
            mailet = mailet * 2
          endif
        endif
c
        iaux = 2
        jaux = 330
        if ( mod(mailet,2).eq.0 ) then
          jaux = jaux * 19
        endif
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_tr', nompro
#endif
        call utal02 ( iaux, jaux,
     >                nhtria, nbtr00, kaux,
     >                phettr, paretr, pfiltr, ppertr,
     >                paux  ,   paux,
     >                pnivtr,   paux,   paux,
     >                adnmtr,   paux, paux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbtr00.ne.0 .or. nbqu00.ne.0 ) then
c
        iaux = nbtr00 * nctftr
        call gmaloj ( nccoex//'.Trian', ' ', iaux  , pcextr, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
c 9.2.2.2. ==> pour les quadrangles, dans un cas :
c            . il y en a (quelle bonne idee)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.2. quadrangles ; codret', codret
      write (ulsort,90002) 'nbqu00', nbqu00
#endif
c
      if ( nbqu00.ne.0 ) then
c
        iaux = 4
        jaux = 330
        if ( mod(mailet,3).eq.0 ) then
          jaux = jaux * 19
        endif
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_qu', nompro
#endif
        call utal02 ( iaux, jaux,
     >                nhquad, nbqu00, kaux,
     >                phetqu, parequ, pfilqu, pperqu,
     >                paux  ,   paux,
     >                pnivqu,   paux,   paux,
     >                adnmqu,   paux, paux,
     >                ulsort, langue, codret )
c
        iaux = nbqu00 * nctfqu
        call gmaloj ( nccoex//'.Quadr', ' ', iaux  , pcexqu, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
c 9.2.2.3. ==> pour les tetraedres, dans un cas :
c            . il y en a (quelle bonne idee)
c            . il n'y en a pas, mais les hexaedres decoupes par
c              conformite pourraient en produire ; on cree le tableau
c              de sauvegarde des codes externes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.3. tetraedres ; codret', codret
      write (ulsort,90002) 'nbteto', nbteto
#endif
c
      if ( nbteto.ne.0 ) then
c
        iaux = 3
        jaux = 390
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_te', nompro
#endif
        call utal02 ( iaux, jaux,
     >                nhtetr, nbteto, kaux,
     >                phette, ptrite, pfilte, pperte,
     >                paux  ,   paux,
     >                paux  , pcotrt,   paux,
     >                  paux,   paux, paux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 .or. ( nbheto.ne.0 .and. tyconf.eq.-1 ) ) then
c
        iaux = nbteto * nctfte
        call gmaloj ( nccoex//'.Tetra', ' ', iaux  , pcexte, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
c 9.2.2.4. ==> pour les hexaedres, dans un cas :
c            . il y en a (quelle bonne idee)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.4. hexaedres ; codret', codret
      write (ulsort,90002) 'nbheto', nbheto
#endif
      if ( nbheto.ne.0 ) then
c
        iaux = 6
        jaux = 390
        if (  mod(mailet,5).eq.0 ) then
          jaux = jaux*19
        endif
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_he', nompro
#endif
        call utal02 ( iaux, jaux,
     >                nhhexa, nbheto, kaux,
     >                phethe, pquahe, pfilhe, pperhe,
     >                paux  ,   paux,
     >                paux  , pcoquh,   paux,
     >                adnmhe,   paux, paux,
     >                ulsort, langue, codret )
c
        iaux = nbheto * nctfhe
        call gmaloj ( nccoex//'.Hexae', ' ', iaux  , pcexhe, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
c 9.2.2.5. ==> pour les pyramides, dans un cas :
c            . il y en a (quelle bonne idee)
c            . il n'y en a pas, mais les hexaedres decoupes par
c              conformite pourraient en produire ; on cree le tableau
c              de sauvegarde des codes externes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.5. pyramides ; codret', codret
      write (ulsort,90002) 'nbpyto', nbpyto
      write (ulsort,90002) 'nbheto', nbheto
      write (ulsort,90002) 'tyconf', tyconf
#endif
      if ( nbpyto.ne.0 ) then
c
        iaux = 5
        jaux = 390
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_py', nompro
#endif
        call utal02 ( iaux, jaux,
     >                nhpyra, nbpyto, kaux,
     >                phetpy, pfacpy, pfilpy, pperpy,
     >                paux  ,   paux,
     >                paux  , pcofay,   paux,
     >                  paux,   paux, paux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 .or. ( nbheto.ne.0 .and. tyconf.eq.-1 ) ) then
c
        iaux = nbpyto * nctfpy
        call gmaloj ( nccoex//'.Pyram', ' ', iaux  , pcexpy, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
c 9.2.2.6. ==> pour les pentaedres, 1 seul cas : il y en a
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.6. pentaedres ; codret', codret
      write (ulsort,90002) 'nbpeto', nbpeto
#endif
      if ( nbpeto.ne.0 ) then
c
        iaux = 7
        jaux = 390
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_pe', nompro
#endif
        call utal02 ( iaux, jaux,
     >                nhpent, nbpeto, kaux,
     >                phetpe, pfacpe, pfilpe, pperpe,
     >                paux  ,   paux,
     >                paux  , pcofap,   paux,
     >                  paux,   paux, paux,
     >                ulsort, langue, codret )
c
        iaux = nbpeto * nctfpe
        call gmaloj ( nccoex//'.Penta', ' ', iaux  , pcexpe, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
c 9.2.2.7. ==> la renumerotation des faces 2D
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.7. ren. faces 2D ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_tr', nompro
#endif
      iaux = 2
      jaux = 2310
      call utre01 ( iaux, jaux, norenu, rstrac, rbtr00,
     >              adtrhn, adtrcn, adtric,
     >              ulsort, langue, codret)

      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_qu', nompro
#endif
      iaux = 4
      if ( nbqu00.eq.0 ) then
      jaux = 2310
        kaux = 0
      else
        kaux = rsquac
      endif
      call utre01 ( iaux, jaux, norenu,   kaux, rbqu00,
     >              adquhn, adqucn, adquic,
     >              ulsort, langue, codret)

      endif
c
c 9.2.2.8. ==> la renumerotation des tetraedres
c              remarque : on alloue meme en l'absence de tetraedres
c                         car on utilise les attributs par la suite !
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.8. ren. tetraedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_te', nompro
#endif
      iaux = 3
      jaux = 2310
      call utre01 ( iaux, jaux, norenu, rsteac, rsteto,
     >              adtehn, adtecn, adteic,
     >              ulsort, langue, codret)

      endif
c
c 9.2.2.9. ==> la renumerotation des pyramides
c              remarque : on alloue meme en l'absence de pyramides
c                         car on utilise les attributs par la suite !
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.9. ren. pyramides ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_py', nompro
#endif
      iaux = 5
      jaux = 2310
      call utre01 ( iaux, jaux, norenu, rspyac, rspyto,
     >              adpyhn, adpycn, adpyic,
     >              ulsort, langue, codret)
c
      endif
c
c 9.2.2.10. ==> la renumerotation des hexaedres
c               remarque : on alloue meme en l'absence de hexaedres
c                          car on utilise les attributs par la suite !
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.10. ren. hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_he', nompro
#endif
      iaux = 6
      jaux = 2310
      call utre01 ( iaux, jaux, norenu, rsheac, rsheto,
     >              adhehn, adhecn, adheic,
     >              ulsort, langue, codret)

      endif
c
c 9.2.2.11. ==> la renumerotation des pentaedres
c               remarque : on alloue meme en l'absence de pentaedres
c                          car on utilise les attributs par la suite !
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.2.2.11. ren. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01_pe', nompro
#endif
      iaux = 7
      jaux = 2310
      call utre01 ( iaux, jaux, norenu, rspeac, rspeto,
     >              adpehn, adpecn, adpeic,
     >              ulsort, langue, codret)
c
      endif
c
c 9.2.2.12. ==> des tableaux de travail
c
      iaux = 2*nbarto
      call gmalot ( ntrav4, 'entier  ', iaux, ptrav4, codre1 )
      iaux = 2*max(rbtr00,rbqu00)
      call gmalot ( ntrav5, 'entier  ', iaux, ptrav5, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 9.3. ==> etablissement de la table et initialisation des faces
c
c     rappel pour vcmfac :
c     e : ntrav1 : vofaar, voisinage des aretes
c     e : ntrav2 : povoar, pointeur sur ntrav1=vofaar
c     e : ntrav3 : areele, table de connectivite par arete
c     a : ntrav4 : prefac, premiere face s'appuyant sur une arete
c     a : ntrav5 : dejavu, controle des doublons
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMFAC', nompro
#endif
      call vcmfac
     >        ( imem(paretr), imem(phettr),
     >          imem(pfiltr), imem(ppertr), imem(pnivtr),
     >          imem(adnmtr),
     >          imem(pcextr), imem(adtrhn), imem(adtrcn),
     >          imem(parequ), imem(phetqu),
     >          imem(pfilqu), imem(pperqu), imem(pnivqu),
     >          imem(adnmqu),
     >          imem(pcexqu), imem(adquhn), imem(adqucn),
     >          imem(ptrite), imem(phette),
     >          imem(pfilte), imem(pperte),
     >          imem(pcexte), imem(adtehn), imem(adtecn),
     >          imem(pquahe), imem(phethe),
     >          imem(pfilhe), imem(pperhe), imem(adnmhe),
     >          imem(pcexhe), imem(adhehn), imem(adhecn),
     >          imem(pfacpe), imem(phetpe),
     >          imem(pfilpe), imem(pperpe),
     >          imem(pcexpe), imem(adpehn), imem(adpecn),
     >          imem(pfacpy), imem(phetpy),
     >          imem(pfilpy), imem(pperpy),
     >          imem(pcexpy), imem(adpyhn), imem(adpycn),
     >          imem(ptrav3), imem(pnoeel), imem(ptypel), imem(pfamee),
     >          imem(ptrav1), imem(ptrav2), imem(ptrav4), imem(ptrav5),
     >          imem(psomar), imem(adnohn), imem(adnocn),
     >          ulsort, langue, codret )
c
      endif
c
c 9.4. ==> connaissant le vrai nombre de faces, on ajuste les tableaux
c          a leurs vraies tailles
c          de plus, on desalloue les tableaux ne servant plus a rien
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.4. apres vcmfac ; codret', codret
#endif
c
c 9.4.1. ==> triangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.4.1. triangles ; codret', codret
      write (ulsort,90002) 'nbtr00, nbtrto', nbtr00, nbtrto
      write (ulsort,90002) 'rbtr00, rstrto', rbtr00, rstrto
#endif
c
      if ( nbtr00.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 2
        jaux = 330
        if ( mod(mailet,2).eq.0 ) then
          jaux = jaux*19
        endif
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_tr', nompro
#endif
        call utad06 ( iaux, jaux, kaux, nhtria,
     >                nbtr00, nbtrto,      0,      0,
     >                phettr, paretr, pfiltr, ppertr,
     >                  paux,
     >                pnivtr,   paux,   paux,
     >                adnmtr,   paux,   paux,   paux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmmod ( nccoex//'.Trian',
     >               pcextr, nbtr00, nbtrto, nctftr, nctftr, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
      endif
c
      if ( rbtr00.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02_tr', nompro
#endif
      iaux = 2
      jaux = 3
      call utre02 ( iaux, jaux, norenu,
     >                kaux, rbtr00,   kaux, rstrto,
     >              adtrhn, adtrcn,
     >              ulsort, langue, codret)
c
      endif
c
      endif
c
c 9.4.2. ==> quadrangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9.4.2. quadrangles ; codret', codret
      write (ulsort,90002) 'nbqu00, nbquto', nbqu00, nbquto
      write (ulsort,90002) 'rbqu00, rsquto', rbqu00, rsquto
#endif
c
      if ( nbqu00.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 4
        jaux = 330
        if ( mod(mailet,3).eq.0 ) then
          jaux = jaux*19
        endif
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD06_qu', nompro
#endif
        call utad06 ( iaux, jaux, kaux, nhquad,
     >                nbqu00, nbquto,      0,      0,
     >                phetqu, parequ, pfilqu, pperqu,
     >                  paux,
     >                pnivqu,   paux,   paux,
     >                adnmqu,   paux,   paux,   paux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmmod ( nccoex//'.Quadr',
     >               pcexqu, nbqu00, nbquto, nctfqu, nctfqu, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
      endif
c
      if ( rbqu00.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02_qu', nompro
#endif
      iaux = 4
      jaux = 3
      call utre02 ( iaux, jaux, norenu,
     >                kaux, rbqu00,   kaux, rsquto,
     >              adquhn, adqucn,
     >              ulsort, langue, codret)
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, norenu//'.QuCalcul')
      call gmprsx (nompro, norenu//'.QuHOMARD')
      call gmprsx (nompro, nhquad//'.ConnDesc' )
      call gmprsx (nompro, nhquad//'.HistEtat')
      call gmprsx (nompro, nhquad//'.Fille' )
      call gmprsx (nompro, nhquad//'.Mere')
      call gmprsx (nompro, nhquad//'.Niveau' )
      call gmprsx (nompro, nccoex//'.Quadr')
#endif
c
c====
c 10. orientation des aretes et des faces du calcul et code des faces
c     dans les volumes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. orientation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCORIE', nompro
#endif
      call vcorie
     >        ( eleinc, imem(pnoeel), imem(ptrav3), imem(ptypel),
     >          imem(psomar), imem(paretr), imem(parequ),
     >          imem(adnohn), imem(adarhn), imem(adtrhn), imem(adquhn),
     >          imem(pcexar),
     >          imem(ptrite), imem(pcotrt), imem(adtehn),
     >          imem(pquahe), imem(pcoquh), imem(adhehn),
     >          imem(pfacpe), imem(pcofap), imem(adpehn),
     >          imem(pfacpy), imem(pcofay), imem(adpyhn),
     >          ulsort, langue, codret )
c
      endif
c
c 10.2. ==> menage
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10.2. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre1 )
      call gmlboj ( ntrav2 , codre2 )
      call gmlboj ( ntrav3 , codre3 )
      call gmlboj ( ntrav4 , codre4 )
      call gmlboj ( ntrav5 , codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
c====
c 11. reperage des eventuelles non conformites
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11. non conformites ; codret', codret
      write (ulsort,90002) 'tyconf', tyconf
#endif
c
      nbtrri = 0
      nbquri = 0
c
      if ( tyconf.gt.0 .or. tyconf.eq.-2 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
cgn        call gmprsx (nompro, nccoex//'.Arete' )
      call gmprsx (nompro, nharet//'.ConnDesc' )
      call gmprsx (nompro, nhtria//'.ConnDesc' )
      call gmprsx (nompro, nhquad//'.ConnDesc' )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMNCO', nompro
#endif
c
        call vcmnco ( nohman,
     >                nhnoeu, nharet, nhtria, nhquad, nhvois,
     >                imem(pnoemp),
     >                rmem(pcoono), imem(phetno), imem(pareno),
     >                imem(pcexno), imem(adnohn), imem(adnocn),
     >                imem(psomar), imem(phetar), imem(pnp2ar),
     >                imem(pmerar), imem(pfilar), imem(adars2),
     >                imem(pcexar), imem(adarhn), imem(adarcn),
     >                imem(phettr), imem(paretr),
     >                imem(pfiltr), imem(ppertr),
     >                imem(phetqu), imem(parequ),
     >                imem(pfilqu), imem(pperqu),
     >                imem(pcexqu), imem(adquhn), imem(adqucn),
     >                imem(pquahe), imem(pcoquh),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
cgn        call gmprsx (nompro, nccoex//'.Arete' )
cgn      call gmprsx (nompro, nhnoeu//'.AretSupp')
cgn        call gmprsx (nompro, nharet//'.ConnDesc' )
cgn        call gmprsx (nompro, nharet//'.HistEtat' )
cgn        call gmprsx (nompro, nharet//'.Fille' )
cgn        call gmprsx (nompro, nharet//'.Mere' )
cgn      call gmprsx (nompro, nhtria//'.ConnDesc' )
cgn      call gmprsx (nompro, nhquad//'.ConnDesc' )
#endif
c
        endif
c
      endif
c
c====
c 12. determination des voisinages
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '12. voisinages ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( homolo.ne.0 ) then
        voarno = 2
      else
        voarno = 0
      endif
      vofaar = 2
      vovoar = 0
      vovofa = 2
c
#ifdef _DEBUG_HOMARD_
cgn      call gmprsx ('Volumes dans '//nompro,nohman//'.Volume')
      if ( nbtrto.gt.0 ) then
      call gmprsx ('nhtria dans '//nompro, nhtria)
      call gmprot ('Triangle ConnDesc', nhtria//'.ConnDesc',
     >              1, min(10,nbtrto) )
      call gmprsx ('InfoSupp', nhtria//'.InfoSupp')
      endif
      if ( nbquto.gt.0 ) then
      call gmprsx ('nhquad dans '//nompro, nhquad)
      call gmprot ('Quadrangle ConnDesc', nhquad//'.ConnDesc',
     >              1, min(10,nbquto) )
      call gmprsx ('InfoSupp', nhquad//'.InfoSupp')
      endif
      if ( nbteto.gt.0 ) then
      call gmprsx ('nhtetr dans '//nompro, nhtetr)
      endif
      if ( nbheto.gt.0 ) then
      call gmprsx ('nhhexa dans '//nompro, nhhexa)
      endif
      if ( nbpeto.gt.0 ) then
      call gmprsx ('nhpent dans '//nompro, nhpent)
      endif
      if ( nbpyto.gt.0 ) then
      call gmprsx ('nhpyra dans '//nompro, nhpyra)
      call gmprsx ('ConnDesc', nhpyra//'.ConnDesc')
      call gmprsx ('InfoSupp', nhpyra//'.InfoSupp')
      endif
cgn      call gmprsx ('nhpyra dans '//nompro,nhpyra)
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nohman, nhvois,
     >              voarno, vofaar, vovoar, vovofa,
     >              ppovos, pvoiso,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 13. mise a jour des numerotations
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '13. numerotations ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 13.1. ==> Decalage des numerotations (cf. eslmm2)
c
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
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'decanu', decanu
#endif
#ifdef _DEBUG_HOMARD_
cgn      call gmprot (nompro, ncnoeu//'.NumeExte' , 1, 20 )
cgn      call gmprot (nompro, ncnoeu//'.NumeExte' , nbnoto-20, nbnoto )
cgn      call gmprot (nompro, nccono//'.NumeExte' , 1, 20 )
cgn      call gmprot (nompro, nccono//'.NumeExte' , nbelem-20, nbelem )
cgn      call gmprsx (nompro, nccono//'.NumeExte' )
#endif
c
c 13.2. ==> Traitement
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMREN', nompro
#endif
      call vcmren  ( imem(adnohn), imem(adnocn), imem(adnoic),
     >               imem(admphn), imem(admpcn), imem(admpic),
     >               imem(adarhn), imem(adarcn), imem(adaric),
     >               imem(adtrhn), imem(adtrcn), imem(adtric),
     >               imem(adquhn), imem(adqucn), imem(adquic),
     >               imem(adtehn), imem(adtecn), imem(adteic),
     >               imem(adpyhn), imem(adpycn), imem(adpyic),
     >               imem(adhehn), imem(adhecn), imem(adheic),
     >               imem(adpehn), imem(adpecn), imem(adpeic),
     >               imem(pnunoe), imem(pnuele), decanu,
     >               ulsort, langue, codret )
cgn      call gmprsx (nompro//'-apres vcmren', norenu//'.InfoSupE.Tab4')
cgn      call gmprsx (nompro//'-apres vcmren', norenu//'.TrHOMARD')
cgn      call gmprsx (nompro//'-apres vcmren', norenu//'.TrCalcul')
cgn      call gmprsx (nompro//'-apres vcmren', norenu//'.InfoSupE.Tab5')
cgn      call gmprsx (nompro//'-apres vcmren', norenu//'.QuHOMARD')
cgn      call gmprsx (nompro//'-apres vcmren', norenu//'.QuCalcul')
c
#ifdef _DEBUG_HOMARD_
      call gmprot (nompro, norenu//'.NoHOMARD' , 1, 20 )
      call gmprot (nompro, norenu//'.NoHOMARD' , rsnoac-20, rsnoac )
      call gmprot (nompro, norenu//'.MPHOMARD' , 1, 20 )
      call gmprot (nompro, norenu//'.MPHOMARD' , rsmpac-20, rsmpac )
      call gmprot (nompro, norenu//'.ArHOMARD' , 1 , 20 )
      call gmprot (nompro, norenu//'.ArHOMARD' , rsarac-20, rsarac )
      call gmprot (nompro, norenu//'.TrHOMARD' , 1, 20 )
      call gmprot (nompro, norenu//'.TrHOMARD' , rstrac-20, rstrac )
      call gmprot (nompro, norenu//'.QuHOMARD' , 1, 20 )
      call gmprot (nompro, norenu//'.QuHOMARD' , rsquac-20, rsquac )
      call gmprot (nompro, norenu//'.TeHOMARD' , 1, 20 )
      call gmprot (nompro, norenu//'.TeHOMARD' , rsteac-20, rsteac )
      call gmprot (nompro, norenu//'.HeHOMARD' , 1, 20 )
      call gmprot (nompro, norenu//'.HeHOMARD' , rsheac-20, rsheac )
      call gmprot (nompro, nccono//'.NumeExte' , 1, 20 )
      call gmprot (nompro, nccono//'.NumeExte' , nbelem-20, nbelem )
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( rsteac.eq.0 .and. rsheac.eq.0 .and. rspyac.eq.0 ) then
        rseutc = rstrac + rsquac
        rsevca = nbtria + nbquad
        rsevto = rstrto + rsquto
      else
        rseutc = rsteac + rsheac + rspyac
        rsevca = nbtetr + nbhexa + nbpyra
        rsevto = rsteto + rsheto + rspyto
      endif
c
      imem(adnbrn+6) = rseutc
      imem(adnbrn+7) = rsevca
      imem(adnbrn+8) = rsevto
c
      endif
c
c====
c 14. sauvegarde des informations generales, au sens
c     du module de calcul associe
c     attention : il faut faire des copies et non pas des attachements
c                 car la structure generale de l'objet "maillage de
c                 calcul" est detruite apres la phase de conversion.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '14. sauvegarde ; codret', codret
      if ( codret.eq.0 ) then
      write (ulsort,*) 'Avant copie de ncinfo'
      call gmprsx (nompro,ncinfo)
      call gmprsx (nompro,ncinfo//'.Pointeur')
      call gmprsx (nompro,ncinfo//'.Taille')
      call gmprsx (nompro,ncinfo//'.Table')
      endif
      call dmflsh (iaux)
#endif
c
c 14.1. ==> a-t-on defini des informations generales en externe ?
c 14.1.1. ==> branche principale
c
      if ( codret.eq.0 ) then
c
      call gmobal ( ncinfo, codret )
c
      if ( codret.eq.0 ) then
        existe = .false.
      elseif ( codret.eq.1 ) then
        codret = 0
        existe = .true.
      else
        codret = 2
      endif
c
      endif
c
c 14.1.2. ==> verification de l'existence des differentes branches
c
      do 141 , iaux = 1 , 3
c
        if ( codret.eq.0 ) then
c
        if ( existe ) then
c
c                     123456789
          if ( iaux.eq.1 ) then
            saux09 = '.Pointeur'
          elseif ( iaux.eq.1 ) then
            saux09 = '.Taille  '
          else
            saux09 = '.Table   '
          endif
          call gmobal ( ncinfo//saux09, codret )
          if ( codret.eq.0 ) then
            existe = .false.
          elseif ( codret.eq.2 ) then
            codret = 0
          else
            codret = 2
          endif
c
        endif
c
        endif
c
  141 continue
c
c 14.2. ==> copie des differentes branches et des attributs
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '14.2. Copie ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( existe ) then
c
      call gmliat ( ncinfo, 1, iaux , codre1 )
      call gmliat ( ncinfo, 2, jaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nhsupe, 7, iaux, codre1 )
      call gmecat ( nhsupe, 8, iaux, codre2 )
      call gmecat ( nhsups, 3, jaux, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmcpoj ( ncinfo//'.Pointeur', nhsupe//'.Tab7', codre1 )
      call gmcpoj ( ncinfo//'.Taille',   nhsupe//'.Tab8', codre2 )
      call gmcpoj ( ncinfo//'.Table',    nhsups//'.Tab3', codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ncinfo//'.Table', pinftb, jaux, codre1 )
      call gmliat ( ncinfo, 1, iaux, codre2 )
      nbpqt = iaux - 1
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 142 , iaux = 1, nbpqt
c
        jaux = pinftb + 10*(iaux-1)
cgn        write (ulsort,90064) jaux, '%'//smem(jaux)//'%'
c
        if ( ( smem(jaux).ne.'NomCo   ' ) .and.
     >       ( smem(jaux).ne.'UniteCo ' ) .and.
     >       ( smem(jaux).ne.'NOMAMD  ' ) .and.
     >       ( smem(jaux).ne.'SATURNE ' ) ) then
c
          kaux = min(80,len(titre))
cgn        write (ulsort,90002) 'longueur', kaux
          call uts8ch ( smem(jaux), kaux, titre,
     >                  ulsort, langue, codret )
cgn        write (ulsort,*) 'recuperation de titre =', titre
c
        endif
c
  142 continue
c
      endif
c
      endif
c
      endif
c
c====
c 15. transfert des elements ignores
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '15. elements ignores ; codret', codret
      write (ulsort,90002) 'nbelig', nbelig
      call dmflsh(iaux)
#endif
c
      if ( nbelig.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nhelig, 1, nbelig, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( degre.eq.1 ) then
          iaux = nbelig * 5
        else
          iaux = nbelig * 13
        endif
        call gmaloj ( nhelig//'.ConnNoeu', ' ', iaux ,  hnoeel, codre1 )
        call gmaloj ( nhelig//'.FamilMED', ' ', nbelig, hfmdel, codre2 )
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
      write (ulsort,texte(langue,3)) 'VCMAIG', nompro
#endif
        call vcmaig
     >         ( imem(hfmdel), imem(hnoeel),
     >           imem(ptypel), imem(pfamee), imem(pnoeel),
     >           imem(adnohn),
     >           ulsort, langue, codret )
c
        endif
cgn        call gmprsx (nompro, nhelig )
cgn        call gmprsx (nompro, nhelig//'.ConnNoeu' )
cgn        call gmprsx (nompro, nhelig//'.FamilMED' )
c
      endif
c
c====
c 16. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '16. fin ; codret', codret
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
