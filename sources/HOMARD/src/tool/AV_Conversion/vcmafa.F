      subroutine vcmafa ( modhom, pilraf, tyconf, suifro,
     >                    nocman, nohman,
     >                    ncafdg, ncafan, ncfgnf, ncfgng,
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
c    aVant adaptation - Conversion de MAillage - FAmilles
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
c . pilraf . e   .   1    . pilotage du raffinement                    .
c .        .     .        . -1 : raffinement uniforme                  .
c .        .     .        .  0 : pas de raffinement                    .
c .        .     .        .  1 : raffinement libre                     .
c .        .     .        .  2 : raff. libre homogene en type d'element.
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
c . suifro . e   .   1    . 1 : pas de suivi de frontiere              .
c .        .     .        . 2x : frontiere discrete                    .
c .        .     .        . 3x : frontiere analytique                  .
c .        .     .        . 5x : frontiere cao                         .
c . nocman .  s  . char*8 . nom de l'objet maillage calcul iteration n .
c . nohman . e   . char8  . nom de l'objet maillage homard iteration n .
c . ncafdg . e   . char*8 . nom de l'objet des frontieres discretes/CAO.
c .        .     .        . nom des groupes frontiere                  .
c . ncafan . e   . char*8 . nom de l'objet des frontieres analytiques :.
c .        .     .        . description des frontieres                 .
c . ncfgnf . es  . char*8 . lien frontiere/groupe : nom des frontieres .
c . ncfgng . e   . char*8 . lien frontiere/groupe : nom des groupes    .
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
      parameter ( nompro = 'VCMAFA' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
#include "coftfq.h"
#include "coftfh.h"
#include "cofpfh.h"
#include "coftfp.h"
#include "cofpfp.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
#include "nbutil.h"
#include "dicfen.h"
#include "envca1.h"
#include "nbfami.h"
#include "nbfamm.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombno.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer modhom, pilraf, tyconf, suifro
c
      character*8 nocman, nohman
      character*8 ncafdg, ncafan, ncfgnf, ncfgng
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer pfamno, pcfano, pcexno
      integer pfammp, pcfamp, pcexmp
      integer pfamar, pcfaar, pcexar
      integer pfamtr, pcfatr, pcextr
      integer pfamqu, pcfaqu, pcexqu
      integer pfamte, pcfate, pcexte
      integer pfamhe, pcfahe, pcexhe
      integer pfampy, pcfapy, pcexpy
      integer pfampe, pcfape, pcexpe
      integer pnunoe, pnuele
      integer pnoemp
      integer psomar, pposif, pfacar, pnp2ar
      integer paretr, parequ, pareno
      integer pfamee, ptypel
      integer pgrpo, pgrtai, pgrtab
      integer nbfme0, ngrou0
c
      integer adhono, admpho, adhoar, adhotr, adhoqu
      integer ppovos, pvoiso, adfrfa, pnumfa, pnomfa
      integer adeqpo
      integer adeqno, adeqar, adeqtr, adeqqu
      integer adnomb
c
      integer typenh, pfamen, pcfaen
      integer nbento, nctfen, nbfenm, nbfaen
c
      integer rvnoac, adnohn
      integer rvmpac, admphn
      integer rvarac, adarhn
      integer rvtrac, adtrhn
      integer rvquac, adquhn
      integer rvteac, adtehn
      integer rvheac, adhehn
      integer rvpyac, adpyhn
      integer rvpeac, adpehn
      integer ptngrf
c
      integer iaux, jaux, kaux, paux
      integer iaux1, iaux2, iaux3, iaux4, iaux5, iaux6, iaux7, iaux8
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre0
      integer pttgrd, ptngrd, pointd
      integer adcpoi, adctai, adctab
      integer adfpoi, adftai, adftab
      integer adgpoi, adgtai, adgtab
      integer pointe
      integer nbgrof, nbfrgr, nbfran
      integer ptrav1
      integer adfrgr, adnogr
      integer un
      integer nbfmem, nbtype, nborie, nbrequ
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 nhnofa, nhmpfa, nharfa
      character*8 nhtrfa, nhqufa
      character*8 nhtefa, nhhefa, nhpyfa, nhpefa
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
      character*8 ntrav1
      character*8 nhenti, nhenfa
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
      texte(1,4) = '(''Erreur dans le decodage de l''''objet '',a)'
      texte(1,5) = '(''. Nombre de '',a,'' :'',i10)'
      texte(1,7) = '(5x,''Conversion '',a18,'' ---> HOMARD'',/)'
      texte(1,8) =
     > '(''Aucune frontiere analytique n''''a ete definie.'')'
c
      texte(2,4) = '(''Error while uncoding object '',a)'
      texte(2,5) = '(''. Number of '',a,'' :'',i10)'
      texte(2,7) = '(5x,''Conversion '',a18,'' ---> HOMARD'',/)'
      texte(2,8) = '(''No analytical boundary was defined.'')'
c
#include "impr03.h"
c
c====
c 2. recuperation des donnees du maillage d'entree
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,-1), nbnoto
      write (ulsort,texte(langue,5)) mess14(langue,3,0), nbmpto
      write (ulsort,texte(langue,5)) mess14(langue,3,1), nbarto
      write (ulsort,texte(langue,5)) mess14(langue,3,2), nbtrto
      write (ulsort,texte(langue,5)) mess14(langue,3,3), nbteto
      write (ulsort,texte(langue,5)) mess14(langue,3,4), nbquto
      write (ulsort,texte(langue,5)) mess14(langue,3,6), nbheto
#endif
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMC', nompro
#endif
      call utnomc ( nocman,
     >              iaux1, iaux2,
     >              iaux3, iaux4, iaux5, iaux6, iaux7,
     >              iaux8,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nohman,
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
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
#include "mslve4.h"
#endif
c
c 2.2. ==> tableaux
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2.==> tableaux ; codret', codret
#endif
c
c 2.2.1. ==> Numerotations externes du code de calcul
c
      if ( codret.eq.0 ) then
c
      if ( ( homolo.ge.1 ) .or.
     >     ( mod(suifro,2).eq.0 ) .or.
     >     ( mod(suifro,3).eq.0 ) .or.
     >     ( mod(suifro,5).eq.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD11', nompro
#endif
      if ( suifro.eq.1 ) then
        iaux = 85
      else
        iaux = 6545
      endif
      call utad11 ( iaux, ncnoeu, nccono,
     >                jaux,   jaux, pnunoe,  jaux,
     >              ptypel, pfamee,   jaux, pnuele,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.2.2. ==> Groupes et codes externes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD12_no', nompro
#endif
      iaux = 210
      jaux = -1
      call utad12 ( iaux, jaux,
     >              nccoex, pcexno,
     >              ulsort, langue, codret )
c
      if ( nbmpto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD12_mp', nompro
#endif
        iaux = 210
        jaux = 0
        call utad12 ( iaux, jaux,
     >                nccoex, pcexmp,
     >                ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD12_ar', nompro
#endif
      iaux = 210
      jaux = 1
      call utad12 ( iaux, jaux,
     >              nccoex, pcexar,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD12_tr', nompro
#endif
        iaux = 210
        jaux = 2
        call utad12 ( iaux, jaux,
     >                nccoex, pcextr,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD12_qu', nompro
#endif
        iaux = 210
        jaux = 4
        call utad12 ( iaux, jaux,
     >                nccoex, pcexqu,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbteto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD12_te', nompro
#endif
        iaux = 210
        jaux = 3
        call utad12 ( iaux, jaux,
     >                nccoex, pcexte,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD12_he', nompro
#endif
        iaux = 210
        jaux = 6
        call utad12 ( iaux, jaux,
     >                nccoex, pcexhe,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpyto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD12_py', nompro
#endif
        iaux = 210
        jaux = 5
        call utad12 ( iaux, jaux,
     >                nccoex, pcexpy,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD12_pe', nompro
#endif
        iaux = 210
        jaux = 7
        call utad12 ( iaux, jaux,
     >                nccoex, pcexpe,
     >                ulsort, langue, codret )
c
      endif
c
c 2.2.3. ==> Connectivites des entites HOMARD
c
      call gmadoj ( nhnoeu//'.AretSupp', pareno, iaux, codre1 )
      call gmadoj ( nhmapo//'.ConnDesc', pnoemp, iaux, codre2 )
      call gmadoj ( nharet//'.ConnDesc', psomar, iaux, codre3 )
      if ( degre.eq.2 ) then
        call gmadoj ( nharet//'.InfoSupp', pnp2ar, iaux, codre4 )
      else
        codre4 = 0
      endif
      if ( nbtrto.ne.0 ) then
        call gmadoj ( nhtria//'.ConnDesc', paretr, iaux, codre5 )
      else
        codre5 = 0
      endif
      if ( nbquto.ne.0 ) then
        call gmadoj ( nhquad//'.ConnDesc', parequ, iaux, codre6 )
      else
        codre6 = 0
      endif
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
c 2.2.4. ==> Homologues
c
      if ( homolo.ne.0 ) then
c
        call gmadoj ( ncequi//'.Pointeur', adeqpo, iaux, codre1 )
        call gmadoj ( ncequi//'.Noeud' , adeqno, iaux, codre2 )
        call gmadoj ( ncequi//'.Arete' , adeqar, iaux, codre3 )
        call gmadoj ( ncequi//'.Trian' , adeqtr, iaux, codre4 )
        call gmadoj ( ncequi//'.Quadr' , adeqqu, iaux, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
c 2.2.5. ==> Voisinages
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      iaux = 3
      if ( homolo.ne.0 ) then
        iaux = iaux*2
      endif
      call utad04 ( iaux, nhvois,
     >              ppovos, pvoiso, pposif, pfacar,
     >                jaux,   jaux,
     >                jaux,   jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.ne.0 ) then
      write (ulsort,texte(langue,4)) nocman
      endif
c
c 2.3. ==> modification de la taille du tableau des codes par la prise
c          en compte des groupes et des homologues
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. ==> modif taille ; codret', codret
      write (ulsort,90002) 'homolo', homolo
#endif
c
      if ( codret.eq.0 ) then
c
      ncefno = 0
      ncefmp = 0
      ncefar = 0
      nceftr = 0
      ncefqu = 0
c
c 2.3.1. ==> homologues
c
      if ( homolo.ne.0 ) then
c
c  pour chaque type d'entite, on repere si au moins une equivalence
c  est concernee
c
        do 23 , iaux = 1 , nbequi
          jaux = adeqpo + 5*iaux - 5
          if ( imem(jaux).ne.0 ) then
            ncefno = ncefno + 1
          endif
          jaux = adeqpo + 5*iaux - 4
          if ( imem(jaux).ne.0 ) then
            ncefmp = ncefmp + 1
          endif
          jaux = adeqpo + 5*iaux - 3
          if ( imem(jaux).ne.0 ) then
            ncefar = ncefar + 1
          endif
          jaux = adeqpo + 5*iaux - 2
          if ( imem(jaux).ne.0 ) then
            nceftr = nceftr + 1
          endif
          jaux = adeqpo + 5*iaux - 1
          if ( imem(jaux).ne.0 ) then
            ncefqu = ncefqu + 1
            nceftr = nceftr + 1
          endif
   23   continue
c
c  pour chaque type d'entite, si au moins une equivalence est concernee,
c  on dit que toutes les equivalences sont concernees.
c  verrue car on n'a pas separe les equivalences par type comme cela
c  est fait pour les groupes.
c  on gaspille un peu de memoire, mais ce n'est pas tres grave.
c
        if ( ncefno.ne.0 ) then
          ncefno = nbequi
        endif
        if ( ncefmp.ne.0 ) then
          ncefmp = nbequi
        endif
        if ( ncefar.ne.0 ) then
          ncefar = nbequi
        endif
        if ( nceftr.ne.0 ) then
          nceftr = nbequi
        endif
        if ( ncefqu.ne.0 ) then
          ncefqu = nbequi
        endif
c
      endif
c
c 2.3.2. ==> Changement de tailles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3.2. ==> modif taille ; codret', codret
#endif
c
      iaux1 = nctfno
      nctfno = nctfno + ncefno
      call gmmod ( nccoex//'.Noeud', pcexno,
     >             nbnoto, nbnoto, iaux1, nctfno, codre1 )
c
      if ( nbmpto.ne.0 ) then
        iaux1 = nctfmp
        nctfmp = nctfmp + ncefmp
        call gmmod ( nccoex//'.Point', pcexmp,
     >               nbmpto, nbmpto, iaux1, nctfmp, codre2 )
      endif
c
      iaux1 = nctfar
      nctfar = nctfar + ncefar
      call gmmod ( nccoex//'.Arete', pcexar,
     >             nbarto, nbarto, iaux1, nctfar, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      if ( nbtria.ne.0 .or. nbquad.ne.0 ) then
        iaux1 = nctftr
        if ( nbtria.ne.0 ) then
          nctftr = nctftr + nceftr
        endif
        if ( nbquad.ne.0 .and. modhom.eq.1 .and. pilraf.eq.1 ) then
          nctftr = nctftr
        endif
        call gmmod ( nccoex//'.Trian', pcextr,
     >               nbtrto, nbtrto, iaux1, nctftr, codre0 )
        codret = max ( abs(codre0), codret )
      endif
c
      if ( nbquto.ne.0 ) then
        iaux1 = nctfqu
        nctfqu = nctfqu + ncefqu
        call gmmod ( nccoex//'.Quadr', pcexqu,
     >               nbquto, nbquto, iaux1, nctfqu, codre0 )
        codret = max ( abs(codre0), codret )
      endif
c
      if ( nbteto.ne.0 ) then
        iaux1 = nctfte
        nctfte = nctfte
        call gmmod ( nccoex//'.Tetra', pcexte,
     >               nbteto, nbteto, iaux1, nctfte, codre0 )
        codret = max ( abs(codre0), codret )
      endif
c
      if ( nbheto.ne.0 ) then
        iaux1 = nctfhe
        nctfhe = nctfhe
        call gmmod ( nccoex//'.Hexae', pcexhe,
     >               nbheto, nbheto, iaux1, nctfhe, codre0 )
        codret = max ( abs(codre0), codret )
      endif
c
      if ( nbpyto.ne.0 ) then
        iaux1 = nctfpy
        nctfpy = nctfpy
        call gmmod ( nccoex//'.Pyram', pcexpy,
     >               nbpyto, nbpyto, iaux1, nctfpy, codre0 )
        codret = max ( abs(codre0), codret )
      endif
c
      if ( nbpeto.ne.0 ) then
        iaux1 = nctfpe
        nctfpe = nctfpe
        call gmmod ( nccoex//'.Penta', pcexpe,
     >               nbpeto, nbpeto, iaux1, nctfpe, codre0 )
        codret = max ( abs(codre0), codret )
      endif
c
      endif
c
c 2.4. ==> tableaux de renumerotation
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. ==> renumerotation ; codret', codret
      call gmprsx (nompro,norenu)
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_no', nompro
#endif
      iaux = -1
      jaux = 10
      call utre03 ( iaux, jaux, norenu,
     >              rvnoac,   kaux, adnohn,   kaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_mp', nompro
#endif
      iaux = 0
      jaux = -10
      call utre03 ( iaux, jaux, norenu,
     >              rvmpac,   kaux, admphn,   kaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_ar', nompro
#endif
      iaux = 1
      jaux = -10
      call utre03 ( iaux, jaux, norenu,
     >              rvarac,   kaux, adarhn,   kaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_tr', nompro
#endif
      iaux = 2
      jaux = -10
      call utre03 ( iaux, jaux, norenu,
     >              rvtrac,   kaux, adtrhn,   kaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_te', nompro
#endif
      iaux = 3
      jaux = -10
      call utre03 ( iaux, jaux, norenu,
     >              rvteac,   kaux, adtehn,   kaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_qu', nompro
#endif
      iaux = 4
      jaux = -10
      call utre03 ( iaux, jaux, norenu,
     >              rvquac,   kaux, adquhn,   kaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_py', nompro
#endif
      iaux = 5
      jaux = -10
      call utre03 ( iaux, jaux, norenu,
     >              rvpyac,   kaux, adpyhn,   kaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_he', nompro
#endif
      iaux = 6
      jaux = -10
      call utre03 ( iaux, jaux, norenu,
     >              rvheac,   kaux, adhehn,   kaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_pe', nompro
#endif
      iaux = 7
      jaux = -10
      call utre03 ( iaux, jaux, norenu,
     >              rvpeac,   kaux, adpehn,   kaux,
     >              ulsort, langue, codret )
c
      endif
c
c 2.5. ==> borne maximale des dimensionnements en fonction
c          de la configuration
c
c  noeuds          1 : famille MED
c                + l : appartenance a l'equivalence l
c
c  mailles-points  1 : famille MED
c                  2 : type de maille-point
c                  3 : famille du sommet support
c                + l : appartenance a l'equivalence l
c
c  aretes          1 : famille MED
c                  2 : type de segment
c                  3 : orientation
c                  4 : famille d'orientation inverse
c                  5 : numero de ligne de frontiere
c                       > 0 si arete concernee par le suivi de frontiere
c                      <= 0 si non concernee
c                  6 : famille de suivi de frontiere active/inactive
c                  7 : numero de surface de frontiere
c                + l : appartenance a l'equivalence l
c
c  triangles       1 : famille MED
c                  2 : type de triangle
c                  3 : numero de surface de frontiere
c                  4 : famille des aretes internes apres raf
c                + l : appartenance a l'equivalence l
c
c  quadrangles     1 : famille MED
c                  2 : type de quadrangle
c                  3 : numero de surface de frontiere
c                  4 : famille des aretes internes apres raf
c                  5 : famille des triangles de conformite
c                  6 : famille de suivi de frontiere active/inactive
c                + l : appartenance a l'equivalence l
c
c  tetraedres      1 : famille MED
c                  2 : type de tetraedres
c
c  hexaedres       1 : famille MED
c                  2 : type de hexaedres
c                  3 : famille des tetraedres de conformite
c                  4 : famille des pyramides de conformite
c
c  pyramides       1 : famille MED
c                  2 : type de pyramides
c
c  pentaedres      1 : famille MED
c                  2 : type de pentaedres
c                  3 : famille des tetraedres de conformite
c                  4 : famille des pyramides de conformite
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.5. ==> borne maximale ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)
     > 'nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu',
     >  nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
      write (ulsort,90002) 'nbfmen', nbfmen
#endif
c
      if ( codret.eq.0 ) then
c
c 2.5.1. ==> Les noeuds
c
      nbfnom = nbfmen + 2
c     prise en compte des equivalences possibles
      if ( ncefno.ne.0 ) then
        nbfnom = 2*nbfnom
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfnom', nbfnom
#endif
c
c 2.5.2. ==> Les mailles
c
c     nombre de familles med
      nbfmem = nbfmed - nbfmen
c
      do 252 , typenh = 0 , 7
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) ' '
        write (ulsort,*) mess14(langue,4,typenh)
#endif
c
c 2.5.2.1. ==> nombre de types possibles
c
        if ( typenh.eq.0 ) then
          nbtype = 1
        else
          nbtype = 2
        endif
c
c 2.5.2.2. ==> nombre d'orientations possibles
c
        if ( typenh.eq.1 ) then
          nborie = 2
        else
          nborie = 1
        endif
c
c 2.5.2.3. ==> equivalences possibles
c
        if ( typenh.eq.0 ) then
          nbrequ = ncefmp
        elseif ( typenh.eq.1 ) then
          nbrequ = ncefar
        elseif ( typenh.eq.2 ) then
          nbrequ = nceftr
        elseif ( typenh.eq.4 ) then
          nbrequ = ncefqu
        else
          nbrequ = 0
        endif
        nbrequ = nbrequ + 1
c
c 2.5.2.4. ==> evaluation du nombre maximum de familles
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbfmem', nbfmem
        write (ulsort,90002) 'nbtype', nbtype
        write (ulsort,90002) 'nborie', nborie
        write (ulsort,90002) 'nbrequ', nbrequ
#endif
        iaux = nbfmem*nbtype*nborie*nbrequ
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) '==> iaux', iaux
#endif
c
        if ( typenh.eq.0 ) then
          nbfmpm = iaux*nbfnom
        elseif ( typenh.eq.3 ) then
          nbftem = iaux
        elseif ( typenh.eq.5 ) then
          nbfhem = iaux
        elseif ( typenh.eq.6 ) then
          nbfpym = iaux
        elseif ( typenh.eq.7 ) then
          nbfpem = iaux
        endif
c
  252 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfmpm', nbfmpm
      write (ulsort,90002) 'nbfarm', nbfarm
      write (ulsort,90002) 'nbftrm', nbftrm
      write (ulsort,90002) 'nbfqum', nbfqum
      write (ulsort,90002) 'nbftem', nbftem
      write (ulsort,90002) 'nbfhem', nbfhem
      write (ulsort,90002) 'nbfpym', nbfpym
      write (ulsort,90002) 'nbfpem', nbfpem
#endif
c
      endif
c
c====
c 3. allocation des nouveaux tableaux
c    remarque : on alloue pour toutes les entites, meme s'il se
c               peut qu'il n'y en ait pas.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. allocation nou tab ; codret', codret
      call gmstat(1)
#endif
c
      do 30 , typenh = -1 , 7
c
c 3.1. ==> Caracteristiques des entites concernees
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.-1 ) then
          nhenti = nhnoeu
          nbento = nbnoto
          nctfen = nctfno
          nbfenm = nbfnom
        elseif ( typenh.eq.0 ) then
          nhenti = nhmapo
          nbento = nbmpto
          nctfen = nctfmp
          nbfenm = nbfmpm
        elseif ( typenh.eq.1 ) then
          nhenti = nharet
          nbento = nbarto
          nctfen = nctfar
          nbfenm = nbfarm
        elseif ( typenh.eq.2 ) then
          nhenti = nhtria
          nbento = nbtrto
          nctfen = nctftr
          nbfenm = nbftrm
        elseif ( typenh.eq.3 ) then
          nhenti = nhtetr
          nbento = nbteto
          nctfen = nctfte
          nbfenm = nbftem
        elseif ( typenh.eq.4 ) then
          nhenti = nhquad
          nbento = nbquto
          nctfen = nctfqu
          nbfenm = nbfqum
        elseif ( typenh.eq.5 ) then
          nhenti = nhpyra
          nbento = nbpyto
          nctfen = nctfpy
          nbfenm = nbfpym
        elseif ( typenh.eq.6 ) then
          nhenti = nhhexa
          nbento = nbheto
          nctfen = nctfhe
          nbfenm = nbfhem
        elseif ( typenh.eq.7 ) then
          nhenti = nhpent
          nbento = nbpeto
          nctfen = nctfpe
          nbfenm = nbfpem
        endif
c
        endif
c
c 3.2. ==> appel du programme generique
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) ' '
          write (ulsort,*) mess14(langue,4,typenh)
          write (ulsort,90002) 'nbento', nbento
          write (ulsort,90002) 'nctfen', nctfen
          write (ulsort,90002) 'nbfenm', nbfenm
#endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTALFE', nompro
#endif
        iaux = typenh
        call utalfe ( iaux, nhenti,
     >                nbento, nctfen, nbfenm,
     >                nhenfa, pfamen, pcfaen,
     >                ulsort, langue, codret )
c
        endif
c
c 3.3. ==> Recuperation de l'adresse des codes
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.-1 ) then
          nhnofa = nhenfa
          pfamno = pfamen
          pcfano = pcfaen
        elseif ( typenh.eq.0 ) then
          nhmpfa = nhenfa
          pfammp = pfamen
          pcfamp = pcfaen
        elseif ( typenh.eq.1 ) then
          nharfa = nhenfa
          pfamar = pfamen
          pcfaar = pcfaen
        elseif ( typenh.eq.2 ) then
          nhtrfa = nhenfa
          pfamtr = pfamen
          pcfatr = pcfaen
        elseif ( typenh.eq.3 ) then
          nhtefa = nhenfa
          pfamte = pfamen
          pcfate = pcfaen
        elseif ( typenh.eq.4 ) then
          nhqufa = nhenfa
          pfamqu = pfamen
          pcfaqu = pcfaen
        elseif ( typenh.eq.5 ) then
          nhpyfa = nhenfa
          pfampy = pfamen
          pcfapy = pcfaen
        elseif ( typenh.eq.6 ) then
          nhhefa = nhenfa
          pfamhe = pfamen
          pcfahe = pcfaen
        elseif ( typenh.eq.7 ) then
          nhpefa = nhenfa
          pfampe = pfamen
          pcfape = pcfaen
        endif
c
        endif
c
   30 continue
c
c====
c 4. initialisations
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. initialisations ; codret', codret
      call gmstat(1)
#endif
c
c 4.1. ==> prise en compte de l'eventuel suivi de frontiere
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'suifro', suifro
#endif
c
      if ( ( mod(suifro,2).eq.0 ) .or.
     >     ( mod(suifro,3).eq.0 ) .or.
     >     ( mod(suifro,5).eq.0 ) ) then
c
        nbgrof = 0
        nbfrgr = 0
c
        if ( codret.eq.0 ) then
c
        if ( ( mod(suifro,2).eq.0 ) .or.
     >       ( mod(suifro,3).eq.0 ) ) then
          call gmmod ( nocman//'.Frontier',
     >                 adfrfa, 0, nbfmed, 1, 1, codre1 )
        else
          codre1 = 0
        endif
c
        call gmaloj ( nhsupe//'.Tab10', ' ', nbfmed, adfrgr, codre2 )
        call gmecat ( nhsupe, 10, nbfmed, codre3 )
        iaux = 10*nbfmed
        call gmaloj ( nhsups//'.Tab10', ' ', iaux, adnogr, codre4 )
        call gmecat ( nhsups, 10, iaux, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        endif
c
cgn        call gmprsx (nompro,ncfami//'.Groupe.Table' )
cgn        call gmprsx (nompro,ncfami//'.Groupe.Pointeur' )
c
c 4.1.1. ==> Groupes pour les frontieres discretes ou CAO
c
        if ( ( mod(suifro,2).eq.0 ) .or. ( mod(suifro,5).eq.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1.1. F. discretes/CAO ; codret', codret
#endif
c
cgn        call gmprsx (nompro,ncafdg )
cgn        call gmprsx (nompro,ncafdg//'.Pointeur' )
cgn        call gmprsx (nompro,ncafdg//'.Table' )
cgn        call gmprsx (nompro,ncafdg//'.Taille' )
c
          if ( codret.eq.0 ) then
c
          call gmliat ( ncafdg, 1, nbgrof, codret )
c
          endif
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbgrof', nbgrof
#endif
c
          if ( nbgrof.gt.0 ) then
c
          iaux = 3
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
          call utadpt ( ncafdg, iaux,
     >                    jaux, kaux,
     >                  pointd, pttgrd, ptngrd,
     >                  ulsort, langue, codret )
c
          endif
c
          endif
c
        endif
c
c 4.1.2. ==> Frontieres analytiques
c
        if ( mod(suifro,3).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1.2 Front analytiques ; codret', codret
#endif
c
c 4.1.2.1 ==> Combien de frontieres analytiques ?
c
          if ( codret.eq.0 ) then
c
cgn        call gmprsx (nompro,ncafan )
          call gmliat ( ncafan, 1, nbfran ,codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          if ( nbfran.eq.0 ) then
            write (ulsort,texte(langue,8))
            codret = 4121
          endif
c
          endif
c
c 4.1.2.2 ==> Description des noms des frontieres dans les liens
c
          if ( nbfran.gt.0 ) then
c
            if ( codret.eq.0 ) then
c
cgn        call gmprsx (nompro,ncfgnf//'.Pointeur' )
cgn        call gmprsx (nompro,ncfgnf//'.Table' )
cgn        call gmprsx (nompro,ncfgnf//'.Taille' )
            iaux = 6
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
            call utadpt ( ncfgnf, iaux,
     >                    nbfrgr, kaux,
     >                    adfpoi, adftai, adftab,
     >                    ulsort, langue, codret )
c
            endif
c
          endif
c
c 4.1.2.3 ==> Description des noms des groupes dans les liens
c
          if ( nbfran.gt.0 ) then
c
            if ( codret.eq.0 ) then
cgn        call gmprsx (nompro//' - ncfgng',ncfgng )
cgn        call gmprsx (nompro//' - ncfgng',ncfgng//'.Pointeur' )
cgn        call gmprsx (nompro//' - ncfgng',ncfgng//'.Table' )
cgn        call gmprsx (nompro//' - ncfgng',ncfgng//'.Taille' )
            iaux = 3
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
            call utadpt ( ncfgng, iaux,
     >                    jaux, kaux,
     >                    adgpoi, adgtai, adgtab,
     >                    ulsort, langue, codret )
c
            endif
c
          endif
c
c 4.1.2.3 ==> Description des frontieres
c
          if ( nbfran.gt.0 ) then
c
            if ( codret.eq.0 ) then
cgn        call gmprsx (nompro,ncafan//'.Pointeur' )
cgn        call gmprsx (nompro,ncafan//'.Table' )
cgn        call gmprsx (nompro,ncafan//'.Taille' )
c
            iaux = 3
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
            call utadpt ( ncafan, iaux,
     >                    jaux, kaux,
     >                    adcpoi, adctai, adctab,
     >                    ulsort, langue, codret )
c
            endif
c
          endif
c
        endif
c
c 4.1.3. ==> Caracteristiques des familles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1.3. Carac familles ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        iaux = 30
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD13', nompro
#endif
        call utad13 ( iaux, ncfami,
     >                pnumfa, pnomfa,
     >                pointe,  jaux, ptngrf,
     >                ulsort, langue, codret )
c
        endif
c
c 4.1.4. ==> Initialisations ad-hoc
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1.4. Init ad hoc ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCSFIN', nompro
#endif
        call vcsfin ( suifro,
     >                imem(pcexar), imem(pcextr), imem(pcexqu),
     >                nbgrof, nbfrgr, nbfran, nbfmed, nbelem,
     >                imem(pointd), imem(pttgrd), smem(ptngrd),
     >                imem(adcpoi), imem(adctai), smem(adctab),
     >                imem(adfpoi), imem(adftai), smem(adftab),
     >                imem(adgpoi), imem(adgtai), smem(adgtab),
     >                imem(pointe), smem(ptngrf),
     >                imem(adfrfa), imem(adfrgr), smem(adnogr),
     >                imem(pnuele), imem(adarhn),
     >                imem(pfamee), imem(ptypel),
     >                imem(pnumfa), smem(pnomfa),
     >                imem(paretr), imem(adtrhn),
     >                imem(parequ), imem(adquhn),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 5. homologues
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. homologues ; codret', codret
#endif
c
      nbpnho = 0
      nbppho = 0
      nbpaho = 0
      nbptho = 0
c
c 5.1. ==> allocation des tableaux etendus de description des
c          homologues
c
      if ( codret.eq.0 ) then
c
      if ( homolo.ge.1 ) then
        call gmaloj ( nhnoeu//'.Homologu', ' ', nbnoto, adhono, codret )
      endif
c
      if ( homolo.ge.1 .and. nbmpto.gt.0 ) then
        typenh = 0
        iaux = 29
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_mp', nompro
#endif
        call utal02 ( typenh, iaux,
     >                nhmapo, nbmpto,   kaux,
     >                  paux,   paux,   paux,   paux,
     >                  paux,   paux,
     >                  paux,   paux,   paux,
     >                  paux, admpho,   paux,
     >                ulsort, langue, codret )
      endif
c
      if ( homolo.ge.2 ) then
        typenh = 1
        iaux = 29
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_ar', nompro
#endif
        call utal02 ( typenh, iaux,
     >                nharet, nbarto,   kaux,
     >                  paux,   paux,   paux,   paux,
     >                  paux,   paux,
     >                  paux,   paux,   paux,
     >                  paux, adhoar,   paux,
     >                ulsort, langue, codret )
      endif
c
      if ( homolo.ge.3 .and. nbtrto.gt.0 ) then
        typenh = 2
        iaux = 29
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_tr', nompro
#endif
        call utal02 ( typenh, iaux,
     >                nhtria, nbtrto,   kaux,
     >                  paux,   paux,   paux,   paux,
     >                  paux,   paux,
     >                  paux,   paux,   paux,
     >                  paux, adhotr,   paux,
     >                ulsort, langue, codret )
      endif
c
      if ( homolo.ge.3 .and. nbquto.gt.0 ) then
        typenh = 4
        iaux = 29
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAL02_qu', nompro
#endif
        call utal02 ( typenh, iaux,
     >                nhquad, nbquto,   kaux,
     >                  paux,   paux,   paux,   paux,
     >                  paux,   paux,
     >                  paux,   paux,   paux,
     >                  paux, adhoqu,   paux,
     >                ulsort, langue, codret )
      endif
c
      endif
c
c 5.2. ==> construction des tableaux etendus d'equivalence - phase 1
c          on ne fait ici que la traduction directe des donnees dans le
c          but de pouvoir etablir les familles
c
      if ( codret.eq.0 ) then
c
      if ( homolo.ge.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU1', nompro
#endif
        call vcequ1 ( imem(pnunoe), imem(pnuele),
     >                imem(adhono), imem(adnohn), imem(adeqno),
     >                imem(adhoar), imem(adarhn), imem(adeqar),
     >                imem(adhotr), imem(adtrhn), imem(adeqtr),
     >                imem(adhoqu), imem(adquhn), imem(adeqqu),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 5.3. ==> prise en compte des equivalences dans les caracteristiques
c          des entites
c
      if ( codret.eq.0 ) then
c
      if ( homolo.ge.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQUI', nompro
#endif
        call vcequi ( imem(pnunoe), imem(pnuele),
     >                imem(pcexno), imem(adnohn), imem(adeqno),
     >                imem(pcexar), imem(adarhn), imem(adeqar),
     >                imem(pcextr), imem(adtrhn), imem(adeqtr),
     >                imem(pcexqu), imem(adquhn), imem(adeqqu),
     >                imem(adeqpo),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 6. construction des familles de noeuds
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. familles de noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbnoto, nctfno, nbfnom',
     >                      nbnoto, nctfno, nbfnom
      write (ulsort,texte(langue,3)) 'VCCFAM_no', nompro
#endif
c
      iaux = -1
      call vccfam
     >        ( iaux,
     >          nbnoto, nctfno, nbfnom,
     >          imem(pcexno), imem(pcfano), imem(iaux), imem(iaux),
     >          imem(pfamno), nbfnoe,
     >          jaux, jaux, imem(jaux),
     >          ulsort, langue, codret )
c
      endif
c
c====
c 7. construction des familles de mailles-points
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. familles de m-pt ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbmpto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbmpto, nctfmp, nbfmpm',
     >                      nbmpto, nctfmp, nbfmpm
      write (ulsort,texte(langue,3)) 'VCCFAM_mp', nompro
#endif
c
        iaux = 0
        call vccfam
     >        ( iaux,
     >          nbmpto, nctfmp, nbfmpm,
     >          imem(pcexmp), imem(pcfamp), imem(pnoemp), imem(pfamno),
     >          imem(pfammp), nbfmpo,
     >          jaux, jaux, imem(jaux),
     >          ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 8. construction des familles d'aretes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. familles d aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbarto, nctfar, nbfarm',
     >                      nbarto, nctfar, nbfarm
      write (ulsort,texte(langue,3)) 'VCCFAM_ar', nompro
#endif
c
      iaux = 1
      call vccfam
     >        ( iaux,
     >          nbarto, nctfar, nbfarm,
     >          imem(pcexar), imem(pcfaar), imem(iaux), imem(iaux),
     >          imem(pfamar), nbfare,
     >          jaux, jaux, imem(jaux),
     >          ulsort, langue, codret )
c
      endif
c
c====
c 9. construction des familles de triangles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. familles de triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrto.ne.0 .or.
     >   ( nbquto.ne.0 .and. ( tyconf.eq.-1 .or. tyconf.eq.0 ) ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbtrto, nctftr, nbftrm',
     >                      nbtrto, nctftr, nbftrm
      write (ulsort,texte(langue,3)) 'VCCFAM_tr', nompro
#endif
c
        iaux = 2
        call vccfam
     >        ( iaux,
     >          nbtrto, nctftr, nbftrm,
     >          imem(pcextr), imem(pcfatr), imem(iaux), imem(iaux),
     >          imem(pfamtr), nbftri,
     >          nctfar, nbfarm, imem(pcfaar),
     >          ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 10. construction des familles de quadrangles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. familles de quad. ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbquto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbquto, nctfqu, nbfqum',
     >                      nbquto, nctfqu, nbfqum
      write (ulsort,texte(langue,3)) 'VCCFAM_qu', nompro
#endif
c
        iaux = 4
        call vccfam
     >        ( iaux,
     >          nbquto, nctfqu, nbfqum,
     >          imem(pcexqu), imem(pcfaqu), imem(iaux), imem(iaux),
     >          imem(pfamqu), nbfqua,
     >          nctfar, nbfarm, imem(pcfaar),
     >          ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 11. construction des familles de triangles pour la mise en conformite
c     des quadrangles
c     Remarque : seulement s'il y a du raffinement conforme
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11. triangles conformite ; codret', codret
      write (ulsort,90002) 'nbquto, modhom, pilraf',
     >                      nbquto, modhom, pilraf
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbquto.ne.0 .and. ( tyconf.eq.-1 .or. tyconf.eq.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfqua, nbftri', nbfqua, nbftri
#endif
c
        if ( codret.eq.0 ) then
        call gmalot ( ntrav1, 'entier  ', nctftr, ptrav1, codret )
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 4
        jaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFCF_qu_tr', nompro
#endif
        call vccfcf ( iaux, nctfqu, nbfqum, nbfqua,
     >                jaux, nctftr, nbftrm, nbftri, ncfftr,
     >                coftfq,
     >                imem(pcfaqu), imem(pcfatr),
     >                edqua4, edtri3,
     >                edqua8, edtri6,
     >                edqua9, edtri7,
     >                imem(ptrav1),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfqua, nbftri', nbfqua, nbftri
#endif
c
        endif
c
        if ( codret.eq.0 ) then
        call gmlboj ( ntrav1, codret )
        endif
c
      endif
c
      endif
c
c====
c 12. construction des familles de tetraedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '12. familles de tetraedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbteto.ne.0 .or.
     >   ( nbheto.ne.0 .and. ( tyconf.eq.-1 .or. tyconf.eq.0 ) ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFAM_te', nompro
#endif
        iaux = 3
        call vccfam
     >        ( iaux,
     >          nbteto, nctfte, nbftem,
     >          imem(pcexte), imem(pcfate), imem(iaux), imem(iaux),
     >          imem(pfamte), nbftet,
     >          jaux, jaux, imem(jaux),
     >          ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 13. construction des familles d'hexaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '13. familles d''hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFAM_he', nompro
#endif
        iaux = 6
        call vccfam
     >        ( iaux,
     >          nbheto, nctfhe, nbfhem,
     >          imem(pcexhe), imem(pcfahe), imem(iaux), imem(iaux),
     >          imem(pfamhe), nbfhex,
     >          jaux, jaux, imem(jaux),
     >          ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 14. construction des familles de pyramides
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '14. familles de pyramidess ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpyto.ne.0 .or.
     >   ( nbheto.ne.0 .and. ( tyconf.eq.-1 .or. tyconf.eq.0 ) ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFAM_py', nompro
#endif
        iaux = 5
        call vccfam
     >        ( iaux,
     >          nbpyto, nctfpy, nbfpym,
     >          imem(pcexpy), imem(pcfapy), imem(iaux), imem(iaux),
     >          imem(pfampy), nbfpyr,
     >          jaux, jaux, imem(jaux),
     >          ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 15. construction des familles de tetraedres et pyramides pour la mise
c     en conformite des hexaedres
c     Remarque : seulement s'il y a du raffinement conforme
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '15. tetr/pyra conformite ; codret', codret
      write (ulsort,90002) 'nbheto, modhom, pilraf',
     >                      nbheto, modhom, pilraf
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.ne.0 .and. ( tyconf.eq.-1 .or. tyconf.eq.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfhex, nbftet, nbfpyr',
     >                      nbfhex, nbftet, nbfpyr
#endif
c
        if ( codret.eq.0 ) then
        call gmalot ( ntrav1, 'entier  ', nctftr, ptrav1, codret )
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 6
        jaux = 3
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFCF_he_te', nompro
#endif
        call vccfcf ( iaux, nctfhe, nbfhem, nbfhex,
     >                jaux, nctfte, nbftem, nbftet, ncffte,
     >                coftfh,
     >                imem(pcfahe), imem(pcfate),
     >                edhex8, edtet4,
     >                edhe20, edte10,
     >                edhe20, edte10,
     >                imem(ptrav1),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfhex, nbftet', nbfhex, nbftet
#endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 6
        jaux = 5
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFCF_he_py', nompro
#endif
        call vccfcf ( iaux, nctfhe, nbfhem, nbfhex,
     >                jaux, nctfpy, nbfpym, nbfpyr, ncffpy,
     >                cofpfh,
     >                imem(pcfahe), imem(pcfapy),
     >                edhex8, edpyr5,
     >                edhe20, edpy13,
     >                edhe20, edpy13,
     >                imem(ptrav1),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfhex, nbfpyr', nbfhex, nbfpyr
#endif
c
        endif
c
        if ( codret.eq.0 ) then
        call gmlboj ( ntrav1, codret )
        endif
c
      endif
c
      endif
c
c====
c 16. construction des familles de pentaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '16. familles de pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpeto.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFAM_pe', nompro
#endif
        iaux = 7
        call vccfam
     >        ( iaux,
     >          nbpeto, nctfpe, nbfpem,
     >          imem(pcexpe), imem(pcfape), imem(iaux), imem(iaux),
     >          imem(pfampe), nbfpen,
     >          jaux, jaux, imem(jaux),
     >          ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 17. construction des familles de tetraedres et pyramides pour la mise
c     en conformite des pentaedres
c     Remarque : seulement s'il y a du raffinement conforme
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '17. tetr/pyra conformite ; codret', codret
      write (ulsort,90002) 'nbpeto, modhom, pilraf',
     >                      nbpeto, modhom, pilraf
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpeto.ne.0 .and. ( tyconf.eq.-1 .or. tyconf.eq.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfpen, nbftet, nbfpyr',
     >                      nbfpen, nbftet, nbfpyr
#endif
c
        if ( codret.eq.0 ) then
        call gmalot ( ntrav1, 'entier  ', nctftr, ptrav1, codret )
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 7
        jaux = 3
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFCF_pe_te', nompro
#endif
        call vccfcf ( iaux, nctfpe, nbfpem, nbfpen,
     >                jaux, nctfte, nbftem, nbftet, ncffte,
     >                coftfp,
     >                imem(pcfape), imem(pcfate),
     >                edpen6, edtet4,
     >                edpe15, edte10,
     >                edpe15, edte10,
     >                imem(ptrav1),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfpen, nbftet', nbfpen, nbftet
#endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 7
        jaux = 5
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFCF_pe_py', nompro
#endif
        call vccfcf ( iaux, nctfpe, nbfpem, nbfpen,
     >                jaux, nctfpy, nbfpym, nbfpyr, ncffpy,
     >                cofpfp,
     >                imem(pcfape), imem(pcfapy),
     >                edpen6, edpyr5,
     >                edpe15, edpy13,
     >                edpe15, edpy13,
     >                imem(ptrav1),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfpen, nbfpyr', nbfpen, nbfpyr
#endif
c
        endif
c
        if ( codret.eq.0 ) then
        call gmlboj ( ntrav1, codret )
        endif
c
      endif
c
      endif
c
c====
c 18. complement des familles pour non conforme ou Carmel
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '18. complement familles ; codret', codret
#endif
c
c 18.1. ==> Adaptation non conforme
c
      if ( tyconf.eq.-2 .or.
     >     tyconf.eq.1 .or.
     >     tyconf.eq.2 .or.
     >     tyconf.eq.3 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '18.1. non-conforme ; codret', codret
cgn      call gmprsx (nompro,ncfami)
cgn      call gmprsx (nompro,ncfami//'.Numero')
cgn      call gmprsx (nompro,ncfami//'.Nom')
#endif
c
c 18.1.1. ==> modifications des structures
c
        if ( codret.eq.0 ) then
c
        nbfme0 = nbfmed
        nbfmed = nbfmed + 3
        ngrou0 = ngrouc
        ngrouc = ngrouc + 3
        un = 1
c
        call gmecat ( ncfami, 1, nbfmed, codre1 )
        call gmecat ( ncfami, 2, ngrouc, codre2 )
        call gmecat ( ncfami//'.Groupe', 1, nbfmed, codre3 )
        iaux = 10*ngrouc
        call gmecat ( ncfami//'.Groupe', 2, iaux, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        call gmmod ( ncfami//'.Numero',
     >               pnumfa, nbfme0, nbfmed, un, un, codre1 )
        iaux1 = 10*nbfme0
        iaux2 = 10*nbfmed
        call gmmod ( ncfami//'.Nom',
     >               pnomfa, iaux1, iaux2, un, un, codre2 )
        call gmmod ( ncfami//'.Groupe.Pointeur',
     >               pgrpo, nbfme0+1, nbfmed+1, un, un, codre3 )
        iaux1 = 10*ngrou0
        iaux2 = 10*ngrouc
        call gmmod ( ncfami//'.Groupe.Taille',
     >               pgrtai, iaux1, iaux2, un, un, codre4 )
        call gmmod ( ncfami//'.Groupe.Table',
     >               pgrtab, iaux1, iaux2, un, un, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( ncnomb, adnomb, iaux, codret )
c
        endif
c
c 18.1.2. ==> Modifications
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFNC', nompro
#endif
        call vccfnc ( nbfare, imem(pcfaar),
     >                nbfqua, imem(pcfaqu),
     >                nbftri, imem(pcfatr),
     >                imem(adnomb+47), imem(adnomb+48),
     >                nbfme0, imem(pnumfa), smem(pnomfa),
     >                imem(pgrpo),
     >                imem(pgrtai), smem(pgrtab),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 18.2. ==> Carmel
c
      if ( typcca.eq.66 .or. typcca.eq.76 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '18.2. Carmel ; codret', codret
cgn      call gmprsx (nompro,ncfami)
cgn      call gmprsx (nompro,ncfami//'.Numero')
cgn      call gmprsx (nompro,ncfami//'.Nom')
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCCFCA', nompro
#endif
        call vccfca ( nbfare, imem(pcfaar),
     >                nbfqua, imem(pcfaqu),
     >                nbftri, imem(pcfatr),
     >                imem(adnomb+47), imem(adnomb+48),
     >                nbfme0, imem(pnumfa), smem(pnomfa),
     >                imem(pgrpo),
     >                imem(pgrtai), smem(pgrtab),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 19. construction des tableaux etendus d'equivalence - phase 2
c     les familles etant construites, on enrichit les structures pour
c     pouvoir passer l'algorithme de maillage
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '19. equivalence ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( homolo.ge.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCEQU2', nompro
#endif
        call vcequ2 ( imem(adhono), imem(adhoar),
     >                imem(adhotr), imem(adhoqu),
     >                imem(psomar), imem(pnp2ar),
     >                imem(paretr), imem(parequ),
     >                imem(pposif), imem(pfacar),
     >                imem(ppovos), imem(pvoiso),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, nhnoeu//'.Homologu' )
        call gmprsx (nompro, nharet//'.Homologu' )
cgn        call gmprsx (nompro, nhtria//'.Homologu' )
#endif
c
        endif
c
      endif
c
c====
c 20. menage
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '20. menage ; codret', codret
#endif
c
c 20.1. ==> mise a la bonne taille des tableaux lies aux familles HOMARD
c           Attention : meme dans le cas ou un type d'entite est absent,
c                       (maille-point, tetraedre, etc.), il faut passer
c                       par chacune des mises a jour. En effet par la
c                       suite, certains traitements font des appels
c                       systematiques aux attributs et aux adresses des
c                       tableaux. Il est est donc indispensable d'avoir
c                       correctement rempli les structures.
c
      do 201 , typenh = -1 , 7
c
c 20.1.1. ==> Caracteristiques des entites concernees
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.-1 ) then
          nhenfa = nhnofa
          nctfen = nctfno
          nbfenm = nbfnom
          nbfaen = nbfnoe
        elseif ( typenh.eq.0 ) then
          nhenfa = nhmpfa
          nctfen = nctfmp
          nbfenm = nbfmpm
          nbfaen = nbfmpo
        elseif ( typenh.eq.1 ) then
          nhenfa = nharfa
          nctfen = nctfar
          nbfenm = nbfarm
          nbfaen = nbfare
        elseif ( typenh.eq.2 ) then
          nhenfa = nhtrfa
          nctfen = nctftr
          nbfenm = nbftrm
          nbfaen = nbftri
        elseif ( typenh.eq.3 ) then
          nhenfa = nhtefa
          nctfen = nctfte
          nbfenm = nbftem
          nbfaen = nbftet
        elseif ( typenh.eq.4 ) then
          nhenfa = nhqufa
          nctfen = nctfqu
          nbfenm = nbfqum
          nbfaen = nbfqua
        elseif ( typenh.eq.5 ) then
          nhenfa = nhpyfa
          nctfen = nctfpy
          nbfenm = nbfpym
          nbfaen = nbfpyr
        elseif ( typenh.eq.6 ) then
          nhenfa = nhhefa
          nctfen = nctfhe
          nbfenm = nbfhem
          nbfaen = nbfhex
        elseif ( typenh.eq.7 ) then
          nhenfa = nhpefa
          nctfen = nctfpe
          nbfenm = nbfpem
          nbfaen = nbfpen
        endif
c
        endif
c
c 20.1.2. ==> appel du programme generique
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) ' '
          write (ulsort,*) mess14(langue,4,typenh)
          write (ulsort,90002) 'nctfen', nctfen
          write (ulsort,90002) 'nbfenm', nbfenm
          write (ulsort,90002) 'nbfaen', nbfaen
#endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3))
     >        'UTFAM1 - '//mess14(langue,3,typenh), nompro
#endif
        iaux = typenh
        call utfam1 ( iaux, nhenfa, pcfaen,
     >                nctfen, nbfenm, nbfaen,
     >                ulsort, langue, codret )
c
        endif
c
c 20.1.3. ==> Recuperation de l'adresse des codes
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.-1 ) then
          pcfano = pcfaen
        elseif ( typenh.eq.0 ) then
          pcfamp = pcfaen
        elseif ( typenh.eq.1 ) then
          pcfaar = pcfaen
        elseif ( typenh.eq.2 ) then
          pcfatr = pcfaen
        elseif ( typenh.eq.3 ) then
          pcfate = pcfaen
        elseif ( typenh.eq.4 ) then
          pcfaqu = pcfaen
        elseif ( typenh.eq.5 ) then
          pcfapy = pcfaen
        elseif ( typenh.eq.6 ) then
          pcfahe = pcfaen
        elseif ( typenh.eq.7 ) then
          pcfape = pcfaen
        endif
c
        endif
c
  201 continue
c
c 20.2. ==> Liberation de structures inutiles
c
      if ( codret.eq.0 ) then
c
      call gmsgoj ( nhvois//'.0D/1D' , codret )
c
      endif
c
c====
c 21. sauvegarde des informations sur les familles, au sens
c     du module de calcul associe
c     attention : il faut faire des copies et non pas des attachements
c                 car la structure generale de l'objet "maillage de
c                 calcul" est detruite apres la phase de conversion.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '21. sauvegarde ; codret', codret
#endif
c
cgn      print *,nompro,' : nbfmed,ngrouc',nbfmed,ngrouc
c
      if ( codret.eq.0 ) then
c
      if ( codret.eq.0 ) then
c
      if ( ngrouc.gt.0 ) then
c
        call gmecat ( nhsupe, 5, nbfmed, codre1 )
        iaux = 10*ngrouc
        call gmecat ( nhsupe, 6, iaux, codre2 )
        iaux = 10*ngrouc
        call gmecat ( nhsups, 2, iaux, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
c
      endif
c
      call gmecat ( nhsupe, 9, nbfmed, codre1 )
      call gmecat ( nhsups, 4, 10*nbfmed, codre2 )
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbfmed.ne.0 ) then
c
        if ( ngrouc.gt.0 ) then
c
          call gmcpoj ( ncfami//'.Groupe.Pointeur',
     >                  nhsupe//'.Tab5', codre1 )
          call gmcpoj ( ncfami//'.Groupe.Taille',
     >                  nhsupe//'.Tab6', codre2 )
          call gmcpoj ( ncfami//'.Groupe.Table',
     >                  nhsups//'.Tab2', codre3 )
c
          codre0 = min ( codre1, codre2, codre3 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3 )
c
        endif
c
        call gmcpoj ( ncfami//'.Numero',
     >                nhsupe//'.Tab9', codre1 )
        call gmcpoj ( ncfami//'.Nom',
     >                nhsups//'.Tab4', codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
c
      endif
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
      call gmprsx (nompro, nhsups//'.Tab3' )
      call gmprsx (nompro, nhsups//'.Tab4' )
      call gmprsx (nompro, nhsups//'.Tab9' )
#endif
c
      endif
c
c====
c 22. sauvegarde des informations sur les equivalences, au sens
c     du module de calcul associe
c     attention : il faut faire des copies et non pas des attachements
c                 car la structure generale de l'objet "maillage de
c                 calcul" est detruite apres la phase de conversion.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '22. sauvegarde equivalences ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( homolo.ne.0 ) then
c
        call gmecat ( nhsups, 5, 33*nbequi, codre1 )
        call gmcpoj ( ncequi//'.InfoGene',
     >                nhsups//'.Tab5', codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, nhsups )
        call gmprsx (nompro, nhsups//'.Tab5' )
#endif
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
c
c====
c 23. impressions
c====
cgn      call gmprsx (nompro, nhnofa//'.EntiFamm')
cgn      call gmprsx (nompro, nhmpfa//'.EntiFamm')
cgn      call gmprsx (nompro, nharfa//'.EntiFamm')
cgn      call gmprsx (nompro, nhtrfa//'.EntiFamm')
cgn      call gmprsx (nompro, nhqufa//'.EntiFamm')
cgn      call gmprsx (nompro, nhtefa//'.EntiFamm')
cgn      call gmprsx (nompro, nhtrfa//'.Codes')
cgn      call gmprsx (nompro, nhqufa//'.Codes')
cgn      call gmprsx (nompro, nhtetr/1/'.Famille')
cgn      call gmprsx (nompro, nhtetr//'.Famille.Codes')
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
c 24. la fin
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
