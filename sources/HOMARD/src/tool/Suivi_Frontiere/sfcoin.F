      subroutine sfcoin ( nomail,
     >                    lgopti, taopti, lgopts, taopts,
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
c   Suivi de Frontiere : COnversions INitiales
c   --                   --          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard             .
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . en entree = celui du module d'avant        .
c .        .     .        . en sortie = celui du module en cours       .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 2x : probleme dans les memoires            .
c .        .     .        . 3x : probleme dans les fichiers            .
c .        .     .        . 5 : mauvaises options                      .
c .        .     .        . 6 : problemes dans les noms d'objet        .
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
      parameter ( nompro = 'SFCOIN' )
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
#include "nombqu.h"
#include "impr02.h"
#include "precis.h"
#include "front0.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nretap, nrsset
c
      integer nbarfr, nbqufr
      integer nbfrdi
      integer adnuno, adlino, adacno
      integer adabsc, psomse, psegli, pgeoco
      integer pcoono, adcocs
      integer pareno
      integer phetno
      integer psomar, phetar, pfilar, pnp2ar
      integer pcfaar, pfamar
      integer parequ, phetqu
      integer pcfaqu, pfamqu
      integer adcafr
      integer adfrgr, adnogr, nbfrgr, adulgr
      integer cpt1d, cpt2d
c
      integer codre0
      integer codre1, codre2, codre3, codre4
c
      double precision unst2x, epsid2
c
      character*2 saux02
      character*6 saux
      character*7 saux07
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ntrav1, ntrav2, ntrav3
      character*8 ncafdg, nocdfr, ncafan, ncfgnf, ncfgng, ncafar
      character*80 saux80
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les initialisations
c====
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,a6,'' PRISE EN COMPTE DES FRONTIERES'')'
      texte(1,5) = '(37(''=''),/)'
      texte(1,6) = '(''Aucun '',a,''n''''est concerne.'')'
      texte(1,7) = '(''Nombre de '',a,''concernes :'',i10)'
      texte(1,8) = '(/,''. Conversion de la geometrie discrete'',/)'
c
      texte(2,4) = '(/,a6,'' BOUNDARY EXAMINATION'')'
      texte(2,5) = '(27(''=''),/)'
      texte(2,6) = '(''No '',a,''is involved'')'
      texte(2,7) = '(''Number of involved '',a,'':'',i10)'
      texte(2,8) = '(/,''. Conversion of discrete geometry'',/)'
c
#include "impr03.h"
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
      if ( taopti(4).ne.2 ) then
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
      endif
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
c 2.2.==> tableaux du maillage
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 30*19
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >                jaux,   jaux,   jaux,
     >              pcoono, pareno,   jaux, adcocs,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 1554
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
      call utad02 ( iaux, nharet,
     >              phetar, psomar, pfilar, jaux,
     >              pfamar, pcfaar,   jaux,
     >              jaux  , pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbquto.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 518
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, jaux, jaux,
     >                pfamqu, pcfaqu,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      epsid2 = max(1.d-14,epsima)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'epsid2', epsid2
#endif
c
      nrofro = 0
c
c====
c 3. Decompte des entites concernees par la frontiere
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Decompte ; codret', codret
#endif
c
c 3.1. ==> Decompte des aretes concernees par la frontiere
c
      if ( codret.eq.0 ) then
c
      nbarfr = 0
      iaux = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCONA', nompro
#endif
      call sfcona ( iaux, nbarfr, imem(iaux),
     >              imem(phetar), imem(pcfaar), imem(pfamar),
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      if ( nbarfr.eq.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,1,1)
      else
        write (ulsort,texte(langue,7)) mess14(langue,3,1), nbarfr
      endif
      endif
#endif
c
c 3.2. ==> Decompte des quadrangles concernes par la frontiere
c          Ne sert a rien ?
c
cgn      if ( nbquto.lt.0 ) then
cgnc
cgn        if ( codret.eq.0 ) then
cgnc
cgn        nbqufr = 0
cgn        iaux = 0
cgnc
cgn#ifdef _DEBUG_HOMARD_
cgn      write (ulsort,texte(langue,3)) 'SFCONQ', nompro
cgn#endif
cgn        call sfconq ( iaux, nbqufr, imem(iaux),
cgn     >                imem(phetqu), imem(pcfaqu), imem(pfamqu),
cgn     >                ulsort, langue, codret )
cgnc
cgn        endif
cgnc
cgn#ifdef _DEBUG_HOMARD_
cgn      if ( codret.eq.0 ) then
cgn      if ( nbarfr.eq.0 ) then
cgn        write (ulsort,texte(langue,6)) mess14(langue,1,4)
cgn      else
cgn        write (ulsort,texte(langue,7)) mess14(langue,3,4), nbqufr
cgn      endif
cgn      endif
cgn#endif
cgnc
cgn      endif
c
c 3.3. ==> Nombre de frontieres discretes ou CAO
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3 ; codret', codret
      write (ulsort,90002) 'nbarfr', nbarfr
      write (ulsort,90002) 'taopti(29) (suifro)', taopti(29)
      call gmprsx ( nompro, taopts(17) )
#endif
c
      if ( nbarfr.gt.0 .and.
     >   ( mod(taopti(29),2).eq.0 ) ) then
c
c 3.3.1. ==> Au premier passage
c
        if ( taopti(10).eq.0 ) then
c
          if ( codret.eq.0 ) then
c
          ncafdg = taopts(17)
          call gmliat ( ncafdg, 1, nbfrdi, codret )
c
          endif
c
c 3.3.2. ==> ensuite
c
        else
c
          if ( codret.eq.0 ) then
c
          call gmliat ( nhsupe, 10, nbfrdi, codret )
c
          endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfrdi', nbfrdi
#endif
c
      endif
c
c====
c 4. Affichage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Affichage ; codret', codret
      write (ulsort,90002) 'nbarfr', nbarfr
#endif
c
      if ( nbarfr.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        ncfgnf = taopts(23)
        ncfgng = taopts(24)
        ncafan = taopts(25)
        ncafar = taopts(26)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFFAFF', nompro
#endif
        call sffaff ( taopti(29),
     >                ncafdg, ncafan, ncfgnf, ncfgng, ncafar,
     >                nhsupe, nhsups,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 5. frontiere CAO : initialisations des fichiers
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. frontiere CAO ; codret', codret
#endif
c
      if ( mod(taopti(29),5).eq.0 ) then
c
        if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        call gmprsx ( nompro, nhsupe//'.Tab10' )
        call gmprsx ( nompro, nhsups//'.Tab10' )
#endif
c
        call gmadoj ( nhsupe//'.Tab10', adfrgr, iaux, codre1 )
        call gmadoj ( nhsups//'.Tab10', adnogr, iaux, codre2 )
        call gmliat ( nhsupe, 10, nbfrgr, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmalot ( taopts(27), 'entier', nbfrgr, adulgr, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        cpt1d = 0
        cpt2d = 0
        do 51 , iaux = 1, nbfrgr
c
          if ( imem(adfrgr+iaux-1).gt.0 ) then
            jaux = cpt1d
            cpt1d = cpt1d + 1
            saux07 = 'fr1D.  '
          elseif ( imem(adfrgr+iaux-1).lt.0 ) then
            jaux = cpt2d
            cpt2d = cpt2d + 1
            saux07 = 'fr2D.  '
          else
            jaux = -1
          endif
c
          if ( jaux.ge.0 ) then
c
            if ( codret.eq.0 ) then
c
            call utench ( jaux, '0', kaux, saux02,
     >                    ulsort, langue, codret )
c
            saux07(6:7) = saux02
            jaux = 7
            call guoufs ( saux07, jaux, kaux, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
            call uts8ch ( smem(adnogr+(iaux-1)*10), 80, saux80,
     >                    ulsort, langue, codret )
            write (kaux,*) saux80
c
            endif
c
          else
c
            kaux = 0
c
          endif
c
          imem(adulgr+iaux-1) = kaux
c
   51   continue
c
        endif
#ifdef _DEBUG_HOMARD_
        call gmprsx ( nompro, taopts(27) )
#endif
c
      endif
c
c====
c 6. Conversion de la description de la geometrie analytique
c    Il faut normaliser les axes ; on ne le fait pas avant pour
c    avoir un affichage conforme a la donnee de l'utilisateur
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Conversion geometrie ; codret', codret
#endif
c
      if ( nbarfr.gt.0 .and. mod(taopti(29),3).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( ncafar, adcafr, jaux, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        jaux = jaux/13
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCOI1', nompro
#endif
        call sfcoi1 ( jaux, rmem(adcafr),
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c====
c 7. Conversion de la description de la geometrie discrete
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. Conversion geometrie ; codret', codret
      write (ulsort,90002) 'taopti(29)', taopti(29)
      write (ulsort,90002) 'nbfrdi', nbfrdi
      write (ulsort,90002) 'nbarfr', nbarfr
#endif
c
      if ( taopti(29).lt.0 .and. mod(taopti(29),2).eq.0 .and.
     >     nbfrdi.gt.0 .and. nbarfr.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCONV', nompro
#endif
        call sfconv ( lgopti, taopti, lgopts, taopts,
     >                lgetco, taetco,
     >                ulsort, langue, codret)
c
        endif
c
        if ( codret.eq.0 ) then
c
        nocdfr = taopts(16)
c
        call gmadoj ( nocdfr//'.CoorNoeu', pgeoco, iaux, codre1 )
        call gmadoj ( nocdfr//'.PtrSomLi', psegli, iaux, codre2 )
        call gmadoj ( nocdfr//'.SommSegm', psomse, iaux, codre3 )
        call gmadoj ( nocdfr//'.AbsCurvi', adabsc, iaux, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        endif
c
      endif
c
c====
c 8. Quand on est parti d'un macro-maillage : inhibition du suivi
c    de frontiere sur les lignes droites
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. lignes droites ; codret', codret
#endif
c
      if ( nbfrdi.gt.0 .and. nbarfr.gt.0 ) then
c
        if ( taopti(10).eq.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'SFINDR', nompro
#endif
          call sfindr ( imem(psegli), imem(pcfaar), imem(pfamar),
     >                  lgetco, taetco,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
c
c====
c 9. Quand on est parti d'un macro-maillage : determination du
c    comportement en degre 2
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. degre 2 ; codret', codret
#endif
c
      if ( taopti(10).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
c 9.1. ==> en degre 1, c'est simple
c
        if ( degre.eq.1 ) then
c
          typsfr = 1
c
c 9.2. ==> en degre 2, tout depent de la position initiale des noeuds P2
c
        else
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'SFPOP2', nompro
#endif
          call sfpop2 ( typsfr,
     >                  rmem(pcoono),
     >                  imem(psomar), imem(pnp2ar),
     >                  imem(pcfaar), imem(pfamar),
     >                  lgetco, taetco,
     >                  ulsort, langue, codret)
c
        endif
c
        if ( codret.eq.0 ) then
        call gmecat ( nomail, 10, typsfr, codret )
        endif
c
        endif
c
      endif
c
c====
c 10. Noeuds initiaux et frontiere
c     Attention : sfcaf1 et sfcoin doivent etre coherents
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. Noeuds ini / frontiere ; codret', codret
#endif
c
      if ( taopti(10).eq.0 ) then
c
      if ( taopti(29).lt.0 .and. nbfrdi.gt.0 ) then
c
cgn      call gmprot(nompro,nhnoeu//'.Coor',115,115)
c
        if ( codret.eq.0 ) then
c
        unst2x = 1.d0 / rmem(adcocs+10)**2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFNOFL', nompro
#endif
        call sfnofl ( ntrav1, ntrav2, ntrav3,
     >                adnuno, adlino, adacno,
     >                unst2x, epsid2,
     >                rmem(pcoono),
     >                imem(psomar), imem(phetar), imem(pfilar),
     >                imem(pnp2ar),
     >                imem(pcfaar), imem(pfamar),
     >                rmem(pgeoco), rmem(adabsc),
     >                imem(psomse), imem(psegli),
     >                lgetco, taetco,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      endif
c
cgn      call gmprot(nompro,nhnoeu//'.Coor',115,115)
c
c====
c 11. La fin
c====
c
      if ( codret.eq.0 ) then
c
      taopti(29) = abs(taopti(29))
c
      endif
c
c====
c 12. La fin
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
