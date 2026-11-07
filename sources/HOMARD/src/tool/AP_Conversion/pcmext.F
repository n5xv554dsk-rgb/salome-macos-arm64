      subroutine pcmext ( lgopti, taopti,
     >                    lgetco, taetco,
     >                    ulsort, langue, codret)
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
c    aPres adaptation - Conversion de Maillage EXTrude
c     -                 -             -        ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'PCMEXT' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "envex1.h"
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nretap, nrsset
      integer iaux, jaux, kaux, laux
      integer tbiaux(1)
      integer codre1, codre2
      integer codre0
      integer ptrav1, ptrav2
      integer pcoono, pareno, phetno, adcocs
      integer psomar, phetar, pfilar, pmerar, pnp2ar
      integer paretr, phettr, pfiltr, ppertr, pnivtr, adpetr, adnmtr
      integer parequ, phetqu, pfilqu, pperqu, pnivqu, adhequ, adnmqu
      integer phette, ptrite, pcotrt, parete, pfilte, pperte, pancte
      integer phethe, pquahe, pcoquh, parehe, pfilhe, pperhe, panche
      integer adnmhe
      integer phetpy, pfacpy, pcofay, parepy, pfilpy, pperpy, pancpy
      integer phetpe, pfacpe, pcofap, parepe, pfilpe, pperpe, pancpe
      integer pposif, pfacar
      integer pfamno, pcfano
      integer pfammp, pcfamp
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
      integer pfamte
      integer pfamhe, pcfahe
      integer pfampe, pcfape
      integer pfampy
      integer pancqu
      integer panctr
      integer pancar
      integer pancno
      integer adhono, adhoar, adhotr, adhoqu
      integer indnoe, indare, indtri, indqua
      integer indhex, indpen
      integer option, optio2
c
      integer nbnoan, nbnono
      integer nbaran, nbarno
      integer nbtran, nbtrno
      integer nbquan, nbquno
      integer nbtean, nbteno
      integer nbhean, nbheno
      integer nbpyan, nbpyno
      integer nbpean, nbpeno
      integer voarno, vofaar, vovoar, vovofa
c
      character*6 saux
      character*8 typobs
      character*8 nomail
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1, ntrav2
      character*9 saux09
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
      if ( taopti(11).eq.26 ) then
        saux09 = 'SATURNE  '
      elseif ( taopti(11).eq.46 ) then
        saux09 = 'NEPTUNE  '
      else
        if ( langue.eq.1 ) then
          saux09 = 'EXTRUSION'
        else
          saux09 = 'EXTRUSION'
        endif
      endif
c
      texte(1,4) =
     > '(/,a6,1x,'''//saux09//' - PASSAGE DU MAILLAGE 2D EN 3D'')'
      texte(1,5) = '(47(''=''),/)'
c
      texte(2,4) = '(/,a6,1x,'''//saux09//' - FROM 2D MESH TO 3D'')'
      texte(2,5) = '(37(''=''),/)'
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5 ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
      codret = 0
c
#include "impr03.h"
c
c====
c 2. les structures de base
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. structures de base ; codret', codret
#endif
c
c 2.1. ==> Le maillage homard a l'iteration n+1
c
      if ( codret.eq.0 ) then
c
      typobs = mchmap
      iaux = 0
      call utosno ( typobs, nomail, iaux, ulsort, langue, codret )
c
      endif
c
c 2.2. ==> structure generale
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. structure gale ; codret', codret
#endif
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
cgn      call gmprot ( nompro, nharet//'.Famille.EntiFamm',1,26)
cgn      call gmprot ( nompro, nharet//'.Famille.EntiFamm',27,118)
c
c====
c 3. (re)allocation des tableaux avec les nouvelles dimensions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. reallocation ; codret', codret
#endif
c
c 3.1. ==> Nombres ancien/nouveau
c
      if ( codret.eq.0 ) then
c
c     les noeuds sont dupliques
c     Remarque : on suppose du P1 simple
      indnoe = nbnoto
      nbnoan = nbnoto
      nbnono = 2*nbnoto
c
c     . si conforme : les aretes actives sont dupliquees
c     . si non conforme : toutes les aretes sont dupliquees
c     . A chaque noeud, on en construit une
      indare = nbarto
      nbaran = nbarto
      nbarno = nbarto + nbnoto
      if ( ( maconf.eq.0 ) .or. ( maconf.eq.-1 ) ) then
        nbarno = nbarno + nbarac
      else
        nbarno = nbarno + nbarto
      endif
c
c     . Les triangles actifs sont dupliques
      indtri = nbtrto
      nbtran = nbtrto
      nbtrno = nbtrto + nbtrac
c
c     . Les quadrangles actif sont dupliques
c     . si conforme : a chaque arete active, on en construit un
c     . si non conforme : a chaque arete, on en construit un
      indqua = nbquto
      nbquan = nbquto
      nbquno = nbquto + nbquac
      if ( ( maconf.eq.0 ) .or. ( maconf.eq.-1 ) ) then
        nbquno = nbquno + nbarac
      else
        nbquno = nbquno + nbarto
      endif
c
      nbtean = 0
      nbteno = 0
c
c     . Chaque quadrangle actif du maillage 2D produit un hexaedre
      indhex = 0
      nbhean = 0
      nbheno = nbquac
c
c     . Chaque triangle actif du maillage 2D produit un pentaedre
      indpen = 0
      nbpean = 0
      nbpeno = nbtrac
c
      nbpyan = 0
      nbpyno = 0
c
      endif
c
c 3.2. ==> noeuds
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. ==> noeuds, codret', codret
      write (ulsort,90002) 'nbnoan', nbnoan
      write (ulsort,90002) 'nbnono', nbnono
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 210
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD05', nompro
#endif
      call utad05 ( iaux, jaux, nhnoeu,
     >              nbnoan, nbnono, sdim,
     >              phetno,
     >              pfamno,
     >              pcoono, pareno, adhono, pancno,
     >              ulsort, langue, codret )
c
      call gmecat ( nhnoeu, 1, nbnono, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
c 3.3. ==> Les entites
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. ==> entites, codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      option = 0
      optio2 = 1
      iaux = 0
      if ( nbquan.eq.0 ) then
        kaux = 0
        laux = 0
      else
        kaux = nbquan
        laux = nbquno
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD98', nompro
#endif
      call utad98 ( nomail, option, optio2,
     >              nbaran, nbarno,
     >              nbtran, nbtrno,
     >                kaux,   laux,
     >                iaux,   iaux,   iaux,   iaux,
     >                iaux,   iaux,   iaux,   iaux,
     >                iaux,   iaux,   iaux,   iaux,
     >                iaux,   iaux,   iaux,   iaux,
     >              phetar, psomar, pfilar, pmerar, pancar,
     >              pnp2ar, adhoar,
     >              phettr, paretr, pfiltr, ppertr, panctr,
     >              pnivtr, adpetr, adnmtr, adhotr,
     >              phetqu, parequ, pfilqu, pperqu, pancqu,
     >              pnivqu, adhequ, adnmqu, adhoqu,
     >              phette, ptrite, pcotrt, parete,
     >              pfilte, pperte, pancte,
     >              phethe, pquahe, pcoquh, parehe,
     >              pfilhe, pperhe, panche, adnmhe,
     >              phetpy, pfacpy, pcofay, parepy,
     >              pfilpy, pperpy, pancpy,
     >              phetpe, pfacpe, pcofap, parepe,
     >              pfilpe, pperpe, pancpe,
     >              pfamar, pfamtr, pfamqu,
     >              pfamte, pfamhe, pfampy, pfampe,
     >              ulsort, langue, codret )
c
c 3.5. ==> Allocations pour les quadrangles, s'il n'y en avait pas
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.5. quadrangles ; codret', codret
      write (ulsort,90002) 'nbquno', nbquno
#endif
      if ( nbquan.eq.0 ) then
c
        iaux = 4
        jaux = 2
        call utad08 (   iaux,   jaux, nhquad,
     >                ulsort, langue, codret )
c
        iaux = 4
        jaux = 2310
        if (  mod(mailet,5).eq.0 ) then
          jaux = jaux*19
        endif
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_qu', nompro
#endif
        call utal02 ( iaux, jaux,
     >                nhquad, nbquno, kaux,
     >                phetqu, parequ, pfilqu, pperqu,
     >                pfamqu,   laux,
     >                pnivqu,   laux,   laux,
     >                adnmqu,   laux,   laux,
     >                ulsort, langue, codret )
c
      endif
c
c 3.6. ==> Allocations pour les hexaedres, s'il y en aura
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.6. hexaedres ; codret', codret
      write (ulsort,90002) 'nbheno', nbheno
#endif
      if ( nbheno.ne.0 ) then
c
        iaux = 6
        jaux = 2730
        if (  mod(mailet,5).eq.0 ) then
          jaux = jaux*19
        endif
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_he', nompro
#endif
        call utal02 ( iaux, jaux,
     >                nhhexa, nbheno, kaux,
     >                phethe, pquahe, pfilhe, pperhe,
     >                pfamhe,   laux,
     >                  laux, pcoquh,   laux,
     >                adnmhe,   laux,   laux,
     >                ulsort, langue, codret )
c
      endif
c
c 3.7. ==> Allocations pour les pentaedres, s'il y en aura
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.7. pentaedres ; codret', codret
      write (ulsort,90002) 'nbpeno', nbpeno
#endif
      if ( nbpeno.ne.0 ) then
c
c
        iaux = 7
        jaux = 2730
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_pe', nompro
#endif
        call utal02 ( iaux, jaux,
     >                nhpent, nbpeno, kaux,
     >                phetpe, pfacpe, pfilpe, pperpe,
     >                pfampe,   laux,
     >                  laux, pcofap,   laux,
     >                  laux,   laux,   laux,
     >                ulsort, langue, codret )
c
      endif
c
c 3.8. ==> Rearrangement des coordonnees
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.8. coordonnees ; codret', codret
#endif
c
c 3.8.1. ==> Dimension du tableau des coordonnees
c
      if ( codret.eq.0 ) then
c
      call gmmod ( nhnoeu//'.Coor',
     >             pcoono, nbnono, nbnono, 2, 3, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
c 3.8.2. ==> Si l'extrusion a lieu selon X, on decale
c            les coordonnees Y et Z
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'taopti(39)', taopti(39)
#endif
c
      if ( codret.eq.0 ) then
c
      if ( taopti(39).eq.1 ) then
c
        jaux = pcoono - 1
        kaux = pcoono - 1 +   nbnono
        laux = pcoono - 1 + 2*nbnono
        do 382 , iaux = 1 , nbnoto
          rmem(laux+iaux) = rmem(kaux+iaux)
          rmem(kaux+iaux) = rmem(jaux+iaux)
  382   continue
c
c 3.8.3. ==> Si l'extrusion a lieu selon Y, on decale la coordonnee Z
c
      elseif ( taopti(39).eq.2 ) then
c
        jaux = pcoono - 1 +   nbnono
        kaux = pcoono - 1 + 2*nbnono
        do 383 , iaux = 1 , nbnoto
          rmem(kaux+iaux) = rmem(jaux+iaux)
  383   continue
c
      endif
#ifdef _DEBUG_HOMARD_
      call gmprsx ('coor des noeuds :', nhnoeu//'.Coor')
#endif
c
      endif
c
c====
c 4. Adresses pour les familles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. familles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 133
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      call utad01 (   iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >                jaux,   jaux,   jaux, adcocs,
     >              ulsort, langue, codret )
c
      if ( nbfmpo.ne.0 ) then
c
        iaux = 259
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD02_mp', nompro
#endif
        call utad02 (   iaux, nhmapo,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfammp, pcfamp,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      iaux = 259
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 (   iaux, nharet,
     >                jaux,   jaux,   jaux,   jaux,
     >              pfamar, pcfaar,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbftri.ne.0 ) then
c
        iaux = 37
        if ( nbtrno.ne.0 ) then
          iaux = iaux*7
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 (   iaux, nhtria,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamtr, pcfatr,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfqua.ne.0 ) then
c
        iaux = 37
        if ( nbquno.ne.0 ) then
          iaux = iaux*7
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 (   iaux, nhquad,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamqu, pcfaqu,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfhex.ne.0 ) then
c
        iaux = 37
        if ( nbheno.ne.0 ) then
          iaux = iaux*7
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
        call utad02 (   iaux, nhhexa,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfamhe, pcfahe,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbfpen.ne.0 ) then
c
        iaux = 37
        if ( nbpeno.ne.0 ) then
          iaux = iaux*7
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
        call utad02 (   iaux, nhpent,
     >                  jaux,   jaux,   jaux,   jaux,
     >                pfampe, pcfape,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECFE', nompro
#endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      iaux = 1
      call utecfe ( iaux,
     >              imem(pfamno), imem(pcfano),
     >              imem(pfammp), imem(pcfamp),
     >              imem(pfamar), imem(pcfaar),
     >              imem(pfamtr), imem(pcfatr),
     >              imem(pfamqu), imem(pcfaqu),
     >                    tbiaux,       tbiaux,
     >              imem(pfamhe), imem(pcfahe),
     >                    tbiaux,       tbiaux,
     >              imem(pfampe), imem(pcfape),
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 5. Tableaux de travail
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Tableaux de travail ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 2*nbnoto
      call gmalot ( ntrav1, 'entier  ',   iaux, ptrav1, codre1 )
      iaux = 2*nbarto
      call gmalot ( ntrav2, 'entier  ',   iaux, ptrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 6. Duplication des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Duplication des noeuds ; codret', codret
      write (ulsort,90002) 'indnoe', indnoe
      write (ulsort,90002) 'indare', indare
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMEX0', nompro
#endif
      call pcmex0 ( indnoe, indare, nbnono, nbarno,
     >              rmem(adcocs),
     >              imem(phetno), rmem(pcoono), imem(pareno),
     >              imem(pfamno), imem(pcfano),
     >              imem(phetar), imem(psomar),
     >              imem(pfilar), imem(pmerar),
     >              imem(pfamar),
     >              imem(ptrav1),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro//' - noeuds :', nhnoeu)
      call gmprsx ('coor des noeuds :', nhnoeu//'.Coor')
      call gmprsx ('famille des noeuds :', nhnoeu//'.Famille.EntiFamm')
      call gmprsx (nompro//' - extrusion noeuds :', ntrav1)
      call gmprsx (nompro//' - aretes :', nharet)
      call gmprsx (nompro//' - somare :', nharet//'.ConnDesc')
      call gmprsx ('famille des aretes :', nharet//'.Famille.EntiFamm')
#endif
c
      endif
c
c====
c 7. Duplication des aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. Duplication des aretes ; codret', codret
      write (ulsort,90002) 'indare', indare
      write (ulsort,90002) 'indqua', indqua
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMEX1', nompro
#endif
      call pcmex1 ( indare, indqua, nbnono, nbarno, nbquno,
     >              rmem(pcoono),
     >              imem(phetar), imem(psomar),
     >              imem(pfilar), imem(pmerar),
     >              imem(pfamar), imem(pcfaar),
     >              imem(phetqu), imem(parequ),
     >              imem(pfilqu), imem(pperqu), imem(pnivqu),
     >              imem(pfamqu), imem(pcfaqu),
     >              imem(ptrav1), imem(ptrav2),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro//' - aretes :', nharet)
      call gmprsx (nompro//' - somare :', nharet//'.ConnDesc')
      call gmprsx ('famille des aretes :', nharet//'.Famille.EntiFamm')
      call gmprsx (nompro//' - extrusion aretes :', ntrav2)
      call gmprsx (nompro//' - quad :', nhquad)
      call gmprsx (nompro//' - arequa :', nhquad//'.ConnDesc')
      call gmprsx ('famille des quad :', nhquad//'.Famille.EntiFamm')
#endif
c
      endif
c
c====
c 8. Duplication des triangles actifs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. Duplication des tria ; codret', codret
      write (ulsort,90002) 'indtri', indtri
      write (ulsort,90002) 'indpen', indpen
      write (ulsort,90002) 'nbtrac', nbtrac
#endif
c
      if ( nbtrac.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMEX2', nompro
#endif
        call pcmex2 ( indtri, indpen,
     >                nbarno, nbtrno, nbquno, nbpeno,
     >                imem(phettr), imem(paretr),
     >                imem(pfiltr), imem(ppertr), imem(pnivtr),
     >                imem(pfamtr), imem(pcfatr), imem(adpetr),
     >                imem(parequ), imem(pnivqu),
     >                imem(pfamqu), imem(pcfaqu),
     >                imem(phetpe), imem(pfacpe), imem(pcofap),
     >                imem(pfilpe), imem(pperpe),
     >                imem(pfampe),
     >                imem(psomar),
     >                imem(ptrav2),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
cgn      call gmprsx (nompro//' - tria :', nhtria)
cgn      call gmprsx (nompro//' - aretri :', nhtria//'.ConnDesc')
cgn      call gmprsx ('famille des tria :', nhtria//'.Famille.EntiFamm')
cgn      call gmprsx (nompro//' - pent :', nhpent)
      call gmprsx (nompro//' - facpen :', nhpent//'.ConnDesc')
      call gmprsx (nompro//' - cofape :', nhpent//'.InfoSupp')
      call gmprsx ('famille des pent :', nhpent//'.Famille.EntiFamm')
#endif
c
        endif
c
      endif
c
c====
c 9. Duplication des quadrangles actifs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. Duplication des quad ; codret', codret
      write (ulsort,90002) 'indqua', indqua
      write (ulsort,90002) 'indhex', indhex
      write (ulsort,90002) 'nbquac', nbquac
#endif
c
      if ( nbquac.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMEX3', nompro
#endif
        call pcmex3 ( indqua, indhex, nbarno, nbquno, nbheno,
     >                imem(phetqu), imem(parequ),
     >                imem(pfilqu), imem(pperqu), imem(pnivqu),
     >                imem(pfamqu), imem(pcfaqu), imem(adhequ),
     >                imem(pquahe), imem(pcoquh),
     >                imem(phethe), imem(pfilhe), imem(pperhe),
     >                imem(pfamhe),
     >                imem(psomar),
     >                imem(ptrav2),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
cgn      call gmprsx (nompro//' - quad :', nhquad)
      call gmprsx (nompro//' - arequa :', nhquad//'.ConnDesc')
      call gmprsx ('famille des quad :', nhquad//'.Famille.EntiFamm')
cgn      call gmprsx (nompro//' - hexa :', nhhexa)
      call gmprsx (nompro//' - quahex :', nhhexa//'.ConnDesc')
      call gmprsx (nompro//' - coquhe :', nhhexa//'.InfoSupp')
      call gmprsx ('famille des hexa :', nhhexa//'.Famille.EntiFamm')
#endif
c
        endif
c
      endif
c
c====
c 10. mise a jour avec les nouvelles dimensions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. mise a jour ; codret', codret
#endif
c
c 10.1 ==> Controle
c
      if ( codret.eq.0 ) then
c
      if ( indnoe.ne.nbnono ) then
        codret = 811
      elseif ( indare.ne.nbarno ) then
        codret = 812
      elseif ( indtri.ne.nbtrno ) then
        codret = 813
      elseif ( indqua.ne.nbquno ) then
        codret = 814
      elseif ( indhex.ne.nbheno ) then
        codret = 815
      elseif ( indpen.ne.nbpeno ) then
        codret = 816
      endif
c
      if ( codret.ne.0 ) then
c
      write (ulsort,90002) 'indnoe, nbnono', indnoe, nbnono
      write (ulsort,90002) 'indare, nbarno', indare, nbarno
      write (ulsort,90002) 'indtri, nbtrno', indtri, nbtrno
      write (ulsort,90002) 'indqua, nbquno', indqua, nbquno
      write (ulsort,90002) 'indhex, nbheno', indhex, nbheno
      write (ulsort,90002) 'indpen, nbpeno', indpen, nbpeno
c
      endif
c
      endif
c
c 10.2 ==> Nombres
c
      if ( codret.eq.0 ) then
c
      nbpeac = nbpeno
      nbpema = nbpeno
      nbpepe = nbpeno
      nbpecf = nbpeno
      nbpeto = nbpeno
c
      nbheac = nbheno
      nbhema = nbheno
      nbhepe = nbheno
      nbhecf = nbheno
      nbheto = nbheno
c
      nbquac = nbquno
      nbqupe = 2*nbqupe
      nbquto = nbquno
c
      nbtrac = nbtrno
      nbtrpe = 2*nbtrpe
      nbtrto = nbtrno
c
      nbarac = 2*nbarac + nbnoto
      nbarma = 2*nbarma + nbnoma
      nbarpe = 2*nbarpe + nbnoma
      nbarto = nbarno
c
c      nbnop1 = nbnore - nbp2re - nbimre - nbnomp - nbnoei - nbnois
c      nbnop2 = nbp2re
c      nbnoim = nbimre
      nbnoma = 2*nbnoma
      nbnoto = nbnono
c
      sdim = 3
      call gmecat ( nomail, 1, sdim, codre1 )
      mdim = 3
      call gmecat ( nomail, 2, mdim, codre1 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 11. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre1  )
      call gmlboj ( ntrav2 , codre2  )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 10. mise a jour des voisinages
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. voisinages ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      voarno = -1
      vofaar = 2
      vovoar = -1
      vovofa = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nomail, nhvois,
     >              voarno, vofaar, vovoar, vovofa,
     >                iaux,   iaux,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 13. la fin
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
