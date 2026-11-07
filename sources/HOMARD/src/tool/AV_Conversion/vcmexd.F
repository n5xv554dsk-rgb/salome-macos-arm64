      subroutine vcmexd ( nomail,
     >                    nhnoeu, nharet, nhtria, nhquad,
     >                    nhhexa, nhpent, norenu,
     >                    disnoe, nbnore, nbp2re, nbimre,
     >                    hetnoe, coonoe,
     >                    arenoe, homnoe,
     >                    nnoeca, nnoeho,
     >                    disare, nbarre,
     >                    hetare, somare, merare, filare,
     >                    np2are, homare,
     >                    posifa, facare,
     >                    distri, nbtrre,
     >                    hettri, aretri, pertri, filtri,
     >                    nivtri, pentri, nintri, homtri,
     >                    ntreca, ntreho,
     >                    disqua, nbqure,
     >                    hetqua, arequa, perqua, filqua,
     >                    nivqua, hexqua, ninqua,
     >                    nqueca, nqueho,
     >                    coocst,
     >                    famnoe, cfanoe,
     >                    fammpo, cfampo,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
     >                    cfahex,
     >                    cfapen,
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
c    aVant adaptation - Conversion de Maillage EXtrude - phase D
c     -                 -             -        --              -
c Destruction des entites 3D
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . disnoe . e   . nbnoto . indicateurs de disparition des noeuds      .
c . disare . e   . nbarto . indicateurs de disparition des aretes      .
c . distri . e   . nbtrto . indicateurs de disparition des triangles   .
c . disqua . e   . nbquto . indicateurs de disparition des quadrangles .
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
      parameter ( nompro = 'VCMEXD' )
c
#include "nblang.h"
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
#include "dicfen.h"
#include "nouvnb.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer disnoe(nbnoto), nbnore
      integer nbp2re, nbimre
      integer hetnoe(nbnoto)
      integer arenoe(nouvno), homnoe(nouvno)
      integer nnoeca(nouvno), nnoeho(*)
      integer disare(nbarto), nbarre
      integer hetare(nbarto), somare(2,nouvar)
      integer merare(nouvar), filare(nouvar)
      integer homare(nouvar)
      integer np2are(nouvar)
      integer posifa(0:nbarto), facare(nbfaar)
      integer distri(nbtrto), nbtrre
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer pertri(nouvtr), filtri(nouvtr)
      integer nivtri(nouvtr), pentri(nbtrto), nintri(nouvtr)
      integer homtri(nouvtr)
      integer ntreca(nouvtr), ntreho(*)
      integer disqua(nbquto), nbqure
      integer hetqua(nouvqu), arequa(nouvqu,4)
      integer perqua(nouvqu), filqua(nouvqu)
      integer nivqua(nouvqu), hexqua(nbquto), ninqua(nouvqu)
      integer nqueca(nouvqu), nqueho(*)
c
      integer famnoe(nouvno), cfanoe(nctfno,nbfnoe)
      integer fammpo(*), cfampo(nctfmp,nbfmpo)
      integer famare(nouvar), cfaare(nctfar,nbfare)
      integer famtri(nouvtr), cfatri(nctftr,nbftri)
      integer famqua(nouvqu), cfaqua(nctfqu,nbfqua)
      integer cfahex(nctfhe,nbfhex)
      integer cfapen(nctfpe,nbfpen)
c
      character*8 nomail, norenu
      character*8 nhnoeu, nharet, nhtria, nhquad
      character*8 nhhexa, nhpent
c
      double precision coonoe(nouvno,sdim)
      double precision coocst(11)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer tbiaux(1)
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      integer pcoono, pareno, phetno
      integer adnoho, adnoca
      integer psomar, phetar, pfilar, pmerar, pnp2ar
      integer paretr, phettr, pfiltr, ppertr, pnivtr, adpetr, adnmtr
      integer adtrho, adtrca
      integer parequ, phetqu, pfilqu, pperqu, pnivqu, adhequ, adnmqu
      integer adquho, adquca
      integer phette, ptrite, pcotrt, parete, pfilte, pperte, pancte
      integer phethe, pquahe, pcoquh, parehe, pfilhe, pperhe, panche
      integer adnmhe
      integer phetpy, pfacpy, pcofay, parepy, pfilpy, pperpy, pancpy
      integer phetpe, pfacpe, pcofap, parepe, pfilpe, pperpe, pancpe
      integer pposif, pfacar
      integer pfamno
      integer pfamar
      integer pfamtr
      integer pfamqu
      integer pfamte
      integer pfamhe
      integer pfampe
      integer pfampy
      integer pancqu
      integer panctr
      integer pancar
      integer pancno
      integer adhono, adhoar, adhotr, adhoqu
c
      integer voarno, vofaar, vovoar, vovofa
      integer ppovos, pvoiso
c
      integer nbnoan, nbnono
      integer nbaran, nbarno
      integer nbtran, nbtrno
      integer nbquan, nbquno
      integer nbtean, nbteno, nbtaan, nbtano
      integer nbhean, nbheno, nbhaan, nbhano
      integer nbpyan, nbpyno, nbyaan, nbyano
      integer nbpean, nbpeno, nbpaan, nbpano
c
      character*8 nhvois
      character*8 nhenti
c
      double precision dmin, dmax
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
      texte(1,4) = '(''Destruction des entites inutiles'')'
c
      texte(2,4) = '(''Removal of useless entities'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
      codret = 0
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro, nomail )
      call gmprsx ( nompro, nomail//'.Volume' )
#endif
c
c====
c 2. Tableaux utilitaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Tableaux utilitaires ; codret', codret
#endif
c
      nouvno = nbnoto
      call gmaloj ( nhnoeu//'.Deraffin', ' ', nouvno, pancno, codre1 )
      nouvar = nbarto
      call gmaloj ( nharet//'.Deraffin', ' ', nouvar, pancar, codre2 )
      nouvtr = nbtrto
      call gmaloj ( nhtria//'.Deraffin', ' ', nouvtr, panctr, codre3 )
      nouvqu = nbquto
      call gmaloj ( nhquad//'.Deraffin', ' ', nouvqu, pancqu, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
c====
c 3. Suppression des entites inutiles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Suppression ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'utsuex', nompro
#endif
      call utsuex ( disnoe, imem(pancno), nbnore, nbp2re, nbimre,
     >              hetnoe,
     >              famnoe, arenoe, homnoe,
     >              nnoeca, nnoeho,
     >              coonoe,
     >              disare, imem(pancar), nbarre,
     >              hetare, somare, merare, filare,
     >              famare, np2are, homare,
     >              posifa, facare,
     >              distri, imem(panctr), nbtrre,
     >              hettri, aretri, pertri, filtri,
     >              famtri, nivtri, pentri, nintri, homtri,
     >              ntreca, ntreho,
     >              disqua, imem(pancqu), nbqure,
     >              hetqua, arequa, perqua, filqua,
     >              famqua, nivqua, hexqua, ninqua,
     >              nqueca, nqueho,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. mise a jour avec les nouvelles dimensions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. mise a jour ; codret', codret
#endif
c
c 4.1. ==> Nombres ancien/nouveau
c
      if ( codret.eq.0 ) then
c
      nbnoan = nbnoto
      nbnono = nbnore
c
      nbaran = nbarto
      nbarno = nbarre
c
      nbtran = nbtrto
      nbtrno = nbtrre
c
      nbquan = nbquto
      nbquno = nbqure
c
      nbtean = 0
      nbteno = 0
c
      nbhean = nbheto
      nbheno = 0
c
      nbpean = nbpeto
      nbpeno = 0
c
      nbpyan = 0
      nbpyno = 0
c
      endif
c
c 4.2. ==> noeuds
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. ==> noeuds, codret', codret
      write (ulsort,90002) 'nbnoan', nbnoan
      write (ulsort,90002) 'nbnono', nbnono
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 210
      jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD05', nompro
#endif
      call utad05 (   iaux,   jaux, nhnoeu,
     >              nbnoan, nbnono,   sdim,
     >              phetno,
     >              pfamno,
     >              pcoono, pareno, adhono,   jaux,
     >              ulsort, langue, codret )
c
      call gmecat ( nhnoeu, 1, nbnono, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
c 4.3. ==> Les entites
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.3. ==> entites, codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD98', nompro
#endif
      call utad98 ( nomail,   iaux,  jaux,
     >              nbaran, nbarno,
     >              nbtran, nbtrno,
     >              nbquan, nbquno,
     >              nbtean, nbteno, nbtaan, nbtano,
     >              nbhean, nbheno, nbhaan, nbhano,
     >              nbpyan, nbpyno, nbyaan, nbyano,
     >              nbpean, nbpeno, nbpaan, nbpano,
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
      endif
c
c 4.4. ==> Les renumerotations
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.4. ==> renumerotations, codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = -1
      jaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02 - noe', nompro
#endif
      call utre02 (   iaux,   jaux, norenu,
     >              renoac, nbnoan, renoac, nbnono,
     >              adnoho, adnoca,
     >              ulsort, langue, codret )
c
      endif
c
      if ( retrac.gt.0 ) then
c
      if ( codret.eq.0 ) then
c
        iaux = 2
        jaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02 - tri', nompro
#endif
        call utre02 (   iaux,   jaux, norenu,
     >                retrac, nbtran, retrac, nbtrno,
     >                adtrho, adtrca,
     >                ulsort, langue, codret )
c
      endif
c
      endif
cgn      call gmprsx(nompro, norenu//'.TrCalcul')
cgn      call gmprsx(nompro, norenu//'.TrHOMARD')
c
      if ( codret.eq.0 ) then
c
      iaux = 4
      jaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE02 - qua', nompro
#endif
      call utre02 (   iaux,   jaux, norenu,
     >              requac, nbquan, requac, nbquno,
     >              adquho, adquca,
     >              ulsort, langue, codret )
c
      endif
cgn      call gmprsx(nompro, norenu//'.QuCalcul')
cgn      call gmprsx(nompro, norenu//'.QuHOMARD')
c
c 4.5. ==> Rearrangement des coordonnees
c          Attention a fonctionner avec le pointeur car le
c          tableau coonoe a ete raccourci par utsuex
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.5. coordonnees ; codret', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'maextr', maextr
      write (ulsort,90002) 'nbnore', nbnore
#endif
c
c 4.5.1. ==> Si l'extrusion a lieu selon X, on decale
c            les coordonnees Y et Z
c
      if ( codret.eq.0 ) then
c
cgn      call gmprsx ( nompro//' - noeuds', nhnoeu//'.CoorCons' )
cgn      call gmprsx ( nompro//' - noeuds', nhnoeu//'.Coor' )
c
      if ( maextr.eq.1 ) then
c
        jaux = pcoono - 1
        kaux = pcoono - 1 +   nbnore
        laux = pcoono - 1 + 2*nbnore
        do 451 , iaux = 1 , nbnore
          rmem(jaux+iaux) = rmem(kaux+iaux)
          rmem(kaux+iaux) = rmem(laux+iaux)
  451   continue
c
        dmin = coocst(2)
        dmax = coocst(5)
        coocst(2) = coocst(3)
        coocst(3) = coocst(4)
        coocst(5) = coocst(6)
        coocst(6) = coocst(7)
        coocst(8) = coocst(9)
        coocst(9) = coocst(10)
        coocst(10) = -1.d0
c
c 4.5.2. ==> Si l'extrusion a lieu selon Y, on decale la coordonnee Z
c
      elseif ( maextr.eq.2 ) then
c
        jaux = pcoono - 1 +   nbnore
        kaux = pcoono - 1 + 2*nbnore
        do 452 , iaux = 1 , nbnore
          rmem(jaux+iaux) = rmem(kaux+iaux)
  452   continue
c
        dmin = coocst(3)
        dmax = coocst(6)
        coocst(3) = coocst(4)
        coocst(6) = coocst(7)
        coocst(9) = coocst(10)
        coocst(10) = -1.d0
c
c 4.5.3. ==> Si l'extrusion a lieu selon Z, on memorise la coordonnee Z
c
      else
c
        dmin = coocst(4)
        dmax = coocst(7)
c
      endif
c
c 4.5.4. ==> Memorisation de la coordonnee d'extrusion
c
      coocst(4) = dmin
      coocst(7) = dmax
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90004) 'dmin', dmin
      write (ulsort,90004) 'dmax', dmax
      call gmprsx ( nompro//' - noeuds', nhnoeu//'.CoorCons' )
#endif
c
c 4.5.5. ==> Dimension du tableau des coordonnees
c
      if ( codret.eq.0 ) then
c
      call gmmod ( nhnoeu//'.Coor',
     >             pcoono, nbnore, nbnore, 3, 2, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
c====
c 5. Suppression des familles des volumes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. familles des volumes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 51 , laux = 6, 7
c
        if ( codret.eq.0 ) then
c
        if ( laux.eq.6 ) then
          kaux = nbfhex
          nhenti = nhhexa
        elseif ( laux.eq.7 ) then
          kaux = nbfpen
          nhenti = nhpent
        endif
c
        if ( kaux.ne.0 ) then
c
        iaux = 2
        jaux = laux
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD08', nompro
#endif
        call utad08 (   jaux,   iaux, nhenti,
     >                ulsort, langue, codret )
c
        endif
c
        endif
c
   51 continue
c
      endif
c
c====
c 6. Nombres (cf. cmmisa)
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. Nombres ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbnop1 = nbnore - nbp2re - nbimre - nbnomp - nbnoei - nbnois
      nbnop2 = nbp2re
      nbnoim = nbimre
      nbnoma = nbnore
      nbnoto = nbnore
c
      nbarac = nbarre
      nbarma = nbarre
      nbarpe = nbarre
      nbarto = nbarre
c
      nbtrac = nbtrre
      nbtrpe = nbtrre
      nbtrto = nbtrre
c
      nbquac = nbqure
      nbqupe = nbqure
      nbquto = nbqure
c
      nbheto = 0
      nbheac = 0
      nbhema = 0
      nbhepe = 0
      nbhecf = 0
c
      nbpeto = 0
      nbpeac = 0
      nbpema = 0
      nbpepe = 0
      nbpecf = 0
c
      sdim = 2
      mdim = 2
c
      call gmecat ( nomail, 1, sdim, codre1 )
      call gmecat ( nomail, 2, mdim, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      call gmecat ( nharet, 1, nbarto, codre1 )
      call gmecat ( nhtria, 1, nbtrto, codre2 )
      call gmecat ( nhquad, 1, nbquto, codre3 )
      call gmecat ( nhhexa, 1, nbheto, codre4 )
      call gmecat ( nhpent, 1, nbpeto, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbnoto', nbnoto
      write (ulsort,90002) 'nbarto', nbarto
      write (ulsort,90002) 'nbtrto', nbtrto
      write (ulsort,90002) 'nbquto', nbquto
      write (ulsort,90002) 'nbheto', nbheto
      write (ulsort,90002) 'nbpeto', nbpeto
cgn      call gmprsx ( nompro//' - noeuds', nhnoeu )
cgn      call gmprsx ( nompro//' - noeuds', nhnoeu//'.Coor' )
cgn      call gmprsx ( nompro//' - aretes', nharet )
cgn      call gmprsx ( nompro//' - aretes', nharet//'.ConnDesc' )
cgn      call gmprsx ( nompro//' - triangles', nhtria )
cgn      call gmprsx ( nompro//' - triangles', nhtria//'.ConnDesc' )
cgn      call gmprsx ( nompro//' - quadrangles', nhquad )
cgn      call gmprsx ( nompro//' - quadrangles', nhquad//'.Famille' )
cgn      call gmprsx ( nompro//' - quadrangles', nhquad//'.ConnDesc' )
cgn      call gmprsx ( nompro//' - quadrangles', nhquad//'.HistEtat' )
cgn      call gmprsx ( nompro//' - quadrangles', nhquad//'.Fille' )
#endif
c
c====
c 7. mise a jour des voisinages
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. voisinages ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( homolo.ne.0 ) then
        voarno = 2
      else
        voarno = 0
      endif
      voarno = -1
      vofaar = 2
      vovoar = -1
      vovofa = -1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVOIS', nompro
#endif
      call utvois ( nomail, nhvois,
     >              voarno, vofaar, vovoar, vovofa,
     >              ppovos, pvoiso,
     >              nbfaar, pposif, pfacar,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 8. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( nhnoeu//'.Deraffin', codre1 )
      call gmlboj ( nharet//'.Deraffin', codre2 )
      call gmlboj ( nhtria//'.Deraffin', codre3 )
      if ( nbquto.ne.0 ) then
        call gmlboj ( nhquad//'.Deraffin', codre4 )
      else
        codre4 = 0
      endif
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTECFE - final', nompro
#endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call utecfe ( maextr,
     >              famnoe, cfanoe,
     >              fammpo, cfampo,
     >              famare, cfaare,
     >              famtri, cfatri,
     >              famqua, cfaqua,
     >              tbiaux, tbiaux,
     >              tbiaux, cfahex,
     >              tbiaux, tbiaux,
     >              tbiaux, cfapen,
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 9. la fin
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
