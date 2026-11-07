      subroutine mmagf1 ( decafa,
     >                    cfaqua,
     >                    cfatet, nbfte0, cfapen, cfahex,
     >                    nbfme0, nbfmed,
     >                    nbjois, nbjoit, nbjoiq,
     >                    nbjp06, nbjp09, nbjp12,
     >                    grfmpo, grfmtl, grfmtb,
     >                    numfam, nomfam,
     >                    nbjoto,
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
c    Modification de Maillage - AGregat - Famille - phase 1
c    -               -          --        -               -
c    Creation des nouvelles familles MED
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . cfaqua .  s  . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . cfatet . es  . nctfte*. codes des familles des tetraedres          .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
c . nbfte0 . e   .    1   . ancien nombre de familles des tetraedres   .
c . cfapen .  s  . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . cfahex .  s  . nctfhe*. codes des familles des hexaedres           .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . decafa . e   .   1    . decalage dans le numero de famille         .
c . nbjois . e   .   1    . nombre de joints simples                   .
c . nbjoit . e   .   1    . nombre de joints triples                   .
c . nbjoiq . e   .   1    . nombre de joints quadruples                .
c . nbjp06 . e   .   1    . nombre de joints ponctuels ordre 6         .
c . nbjp09 . e   .   1    . nombre de joints ponctuels ordre 9         .
c . nbjp12 . e   .   1    . nombre de joints ponctuels ordre 12        .
c . grfmpo . es  .nbfmed+1. pointeur des groupes des familles          .
c . grfmtl . es  .nbfmed+1. taille des groupes des familles            .
c . grfmtb . es  .10ngrouc. table des groupes des familles             .
c . numfam . es  . nbfmed . numero des familles MED                    .
c . nbjoto . e   .   1    . nombre total de joints                     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 33 : trop de groupes                       .
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
      parameter ( nompro = 'MMAGF1' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "meddc0.h"
#include "envex1.h"
c
#include "coftex.h"
#include "cofatq.h"
#include "cofina.h"
#include "coftfq.h"
#include "cofpfh.h"
#include "coftfh.h"
#include "cofpfp.h"
#include "coftfp.h"
#include "envca1.h"
#include "nbfami.h"
#include "dicfen.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer decafa
      integer nbfme0, nbfmed
      integer nbjois, nbjoit, nbjoiq
      integer nbjp06, nbjp09, nbjp12
      integer nbfte0
      integer cfaqua(nctfqu,nbfqua)
      integer cfatet(nctfte,nbftet)
      integer cfapen(nctfpe,nbfpen)
      integer cfahex(nctfhe,nbfhex)
      integer grfmpo(0:nbfmed), grfmtl(*)
      integer numfam(nbfmed)
      integer nbjoto
c
      character*8 grfmtb(*)
      character*8 nomfam(10,nbfmed)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer lgnogr, nufame, nufaho
      integer rgfame, ptnogr
      integer tymate, tymape, tymahe
c
      character*1 saux01
      character*8 nomgro
      character*30 saux30
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. prealables
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Decalage dans les numeros des familles :'',i5)'
      texte(1,5) = '(''Nombre de familles de '',a,'' :'',i5)'
      texte(1,6) = '(''. Creation de la famille :'',i5)'
      texte(1,7) = '(''.. Groupe  : '',a)'
      texte(1,8) = '(''.. Famille : '',a)'
      texte(1,9) =
     > '(''.. Trop de groupes pour coder les noms sur 8 caracteres.'')'
c
      texte(2,4) = '(''Shift with numbers of the families :'',i5)'
      texte(2,5) = '(''Number of families of '',a,'' :'',i5)'
      texte(2,6) = '(''. Creation of the family :'',i5)'
      texte(2,7) = '(''.. Group  : '',a)'
      texte(2,8) = '(''.. Family : '',a)'
      texte(2,9) =
     > '(''.. Too many groups for 8 character coding of the names.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) decafa
      write (ulsort,texte(langue,5)) mess14(langue,3,7), nbfpen
      if ( nbjoiq.gt.0 ) then
        write (ulsort,texte(langue,5)) mess14(langue,3,1), nbfhex
      endif
#endif
c
      codret = 0
c
      if ( degre.eq.1 ) then
        tymape = edpen6
        if ( nbjoiq.gt.0 ) then
          tymahe = edhex8
        endif
        if ( nbjp06.gt.0 ) then
          tymate = edtet4
        endif
      else
        tymape = edpe15
        if ( nbjoiq.gt.0 ) then
          tymahe = edhe20
        endif
        if ( nbjp06.gt.0 ) then
          tymate = edte10
        endif
      endif
c
c====
c 2. Les familles libres
c====
c 2.1. ==> Les quadrangles
c
      if ( nbfqua.gt.0 ) then
        cfaqua(cofamd,1) = 0
        cfaqua(cotyel,1) = 0
        cfaqua(cosfsu,1) = 0
        cfaqua(cofafa,1) = 1
        cfaqua(cosfin,1) = 0
        cfaqua(coftfq,1) = 1
      endif
c
c 2.2. ==> Les pentaedres
c
      if ( nbfpen.gt.0 ) then
        cfapen(cofamd,1) = 0
        cfapen(cotyel,1) = 0
        cfapen(coftfp,1) = 1
        cfapen(cofpfp,1) = 1
      endif
c
c 2.3. ==> Les hexaedres
c
      if ( nbfhex.gt.0 ) then
        cfahex(cofamd,1) = 0
        cfahex(cotyel,1) = 0
        cfahex(coftfh,1) = 1
        cfahex(cofpfh,1) = 1
      endif
c
c====
c 3. familles de tetraedres, d'hexaedres et de pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. familles ; codret = ', codret
#endif
c
      rgfame = nbfme0
      ptnogr = grfmpo(rgfame)
c
cgn      write (ulsort,*) 'nbjois = ', nbjois
cgn      write (ulsort,*) 'nbjoit = ', nbjoit
cgn      write (ulsort,*) 'nbjoiq = ', nbjoiq
cgn      write (ulsort,*) 'nbjp06 = ', nbjp06
cgn      write (ulsort,*) 'nbjp09 = ', nbjp09
cgn      write (ulsort,*) 'nbjp12 = ', nbjp12
cgn      write (ulsort,*) 'nbjoto = ', nbjoto
      do 3 , iaux = 1 , nbjoto
c
c 3.1. ==> Numero de la famille MED
c
        if ( codret.eq.0 ) then
c
        nufame = decafa - iaux
        rgfame = rgfame + 1
        numfam(rgfame) = nufame
cgn      write (ulsort,*)'rgfame, nufame,ptnogr ',rgfame,nufame,ptnogr
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nufame
#endif
c
        endif
c
c 3.2. ==> Caracteristiques des familles de pentaedres, de
c          tetraedres ou d'hexaedres
c
        if ( iaux.le.(nbjois+nbjoit) ) then
          nufaho = iaux + 1
          cfapen(cofamd,nufaho) = nufame
          cfapen(cotyel,nufaho) = tymape
          cfapen(coftfp,nufaho) = 1
          cfapen(cofpfp,nufaho) = 1
        elseif ( iaux.le.(nbjois+nbjoit+nbjoiq) ) then
          nufaho = iaux - (nbjois+nbjoit) + 1
          cfahex(cofamd,nufaho) = nufame
          cfahex(cotyel,nufaho) = tymahe
          cfahex(coftfh,nufaho) = 1
          cfahex(cofpfh,nufaho) = 1
        elseif ( nbjp06.gt.0 .and.
     >           iaux.le.(nbjois+nbjoit+nbjoiq+nbjp06) ) then
          nufaho = iaux - (nbjois+nbjoit+nbjoiq) + nbfte0
          cfatet(cofamd,nufaho) = nufame
          cfatet(cotyel,nufaho) = tymate
        elseif ( nbjp09.gt.0 .and.
     >           iaux.le.(nbjois+nbjoit+nbjoiq+nbjp06+nbjp09) ) then
          nufaho = iaux - (nbjoiq+nbjp06) + 1
          cfapen(cofamd,nufaho) = nufame
          cfapen(cotyel,nufaho) = tymape
          cfapen(coftfp,nufaho) = 1
          cfapen(cofpfp,nufaho) = 1
        elseif ( nbjp12.gt.0 ) then
          nufaho = iaux - (nbjois+nbjoit+nbjp06+nbjp09) + 1
          cfahex(cofamd,nufaho) = nufame
          cfahex(cotyel,nufaho) = tymahe
          cfahex(coftfh,nufaho) = 1
          cfahex(cofpfh,nufaho) = 1
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nufaho
#endif
c
c 3.3. ==> Nom du groupe et de la famille
c
        if ( codret.eq.0 ) then
c
        if ( iaux.le.nbjois ) then
          jaux = iaux
          saux01 = 'J'
        elseif ( iaux.le.(nbjois+nbjoit) ) then
          jaux = iaux - nbjois
          saux01 = 'T'
        elseif ( iaux.le.(nbjois+nbjoit+nbjoiq) ) then
          jaux = iaux - (nbjois+nbjoit)
          saux01 = 'Q'
        else
          jaux = iaux - (nbjois+nbjoit+nbjoiq)
          saux01 = 'P'
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTENCH', nompro
#endif
        call utench ( jaux, 'G', kaux, saux30,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( kaux.ge.8 ) then
c
          write (ulsort,texte(langue,9))
          codret = 33
c
        endif
c
        endif
c
c 3.4. ==> nom du groupe du joint
c
        if ( codret.eq.0 ) then
c
c                1        2345678
        nomgro = saux01//'_      '
        lgnogr = kaux + 2
        nomgro(3:lgnogr) = saux30(1:kaux)
cgn        write (ulsort,*) nomgro
c
        grfmtb(ptnogr+1) = nomgro
        do 342 , jaux = 2, 10
          grfmtb(ptnogr+jaux) = '        '
c                                12345678
  342   continue
        do 343 , jaux = 1, 10
          grfmtl(ptnogr+jaux) = 0
  343   continue
cgn        if ( lgnogr.le.8 ) then
          grfmtl(ptnogr+1) = lgnogr
cgn        elseif ( lgnogr.le.16 ) then
cgn          grfmtl(ptnogr+1) = 8
cgn          grfmtl(ptnogr+2) = lgnogr - 8
cgn        elseif ( lgnogr.le.24) then
cgn          grfmtl(ptnogr+1) = 8
cgn          grfmtl(ptnogr+2) = 8
cgn          grfmtl(ptnogr+3) = lgnogr - 8
cgn        else
cgn          grfmtl(ptnogr+1) = 8
cgn          grfmtl(ptnogr+2) = 8
cgn          grfmtl(ptnogr+3) = 8
cgn          grfmtl(ptnogr+4) = lgnogr - 8
cgn        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nomgro
#endif
c
        ptnogr = ptnogr + 10
c
c 3.5. ==> nom du groupe global de tous les joints
c
        if ( codret.eq.0 ) then
c
        if ( saux01.eq.'J' ) then
c                             12345678
          grfmtb(ptnogr+1) = 'JOINT   '
          grfmtl(ptnogr+1) = 5
        elseif ( saux01.eq.'T' ) then
          grfmtb(ptnogr+1) = 'TRIPLE  '
          grfmtl(ptnogr+1) = 6
        elseif ( saux01.eq.'Q' ) then
          grfmtb(ptnogr+1) = 'QUADRUPL'
          grfmtl(ptnogr+1) = 8
        else
          grfmtb(ptnogr+1) = 'POINT   '
          grfmtl(ptnogr+1) = 8
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) grfmtb(ptnogr+1)
#endif
        do 351 , jaux = 2 , 10
c                                12345678
          grfmtb(ptnogr+jaux) = '        '
          grfmtl(ptnogr+jaux) = 0
  351   continue
c
        ptnogr = ptnogr + 10
        grfmpo(rgfame) = ptnogr
c
        endif
c
c 3.6. ==> Stockage du nom de la famille
c
        if ( codret.eq.0 ) then
c
        nomfam(1,rgfame) = blan08
        nomfam(2,rgfame) = blan08
        nomfam(3,rgfame) = blan08
        nomfam(4,rgfame) = blan08
        nomfam(5,rgfame) = blan08
        nomfam(6,rgfame) = blan08
        nomfam(7,rgfame) = blan08
        nomfam(8,rgfame) = blan08
cgn        if ( lgnogr.le.8 ) then
          nomfam(1,rgfame)(1:lgnogr) = nomgro(1:lgnogr)
cgn        elseif ( lgnogr.le.16 ) then
cgn          nomfam(1,rgfame) = saux64( 1: 8)
cgn          nomfam(2,rgfame)( 1:lgnogr-8) = nomgro( 9:lgnogr)
cgn        elseif ( lgnogr.le.24) then
cgn          nomfam(1,rgfame) = saux64( 1: 8)
cgn          nomfam(2,rgfame) = saux64( 9:16)
cgn          nomfam(3,rgfame)( 1:lgnogr-8) = nomgro(17:lgnogr)
cgn        else
cgn          nomfam(1,rgfame) = saux64( 1: 8)
cgn          nomfam(2,rgfame) = saux64( 9:16)
cgn          nomfam(3,rgfame) = saux64(17:24)
cgn          nomfam(4,rgfame)( 1:lgnogr-8) = nomgro(25:lgnogr)
cgn        endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) nomfam(1,rgfame)//
     > nomfam(2,rgfame)//nomfam(3,rgfame)//nomfam(4,rgfame)
     > //nomfam(5,rgfame)//nomfam(6,rgfame)
     > //nomfam(7,rgfame)//nomfam(8,rgfame)
#endif
c
        endif
c
    3 continue
c
c====
c 4. la fin
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
