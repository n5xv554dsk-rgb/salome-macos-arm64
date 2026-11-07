      subroutine pcmarc ( nocmap, nospec,
     >                    nonexm,
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
c    aPres adaptation - Conversion de MAillage - ReCollements
c     -                 -             --         - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocmap . e   . char8  . nom de l'objet maillage de calcul iter.n+1 .
c . nospec . e   . char8  . nom de l'objet memorisant les specificites .
c . nonexm . e   .    1   . non exportation de mailles                 .
c .        .     .        .   1 : on exporte toutes les mailles        .
c .        .     .        .  2x : les segments ne sont pas exportes    .
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
      parameter ( nompro = 'PCMARC' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
#include "impr02.h"
c
#include "envca1.h"
c
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      character*8 nocmap
      character*8 nospec
c
      integer nonexm
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nparrc, nptrrc, npqurc
      integer npterc, npherc, npperc, nppyrc
      integer adarrc, adtrrc, adqurc
      integer adterc, adherc, adperc, adpyrc
c
      integer nbnomb, adnomb
      integer un
c
      integer adeqpo, adeqin
      integer adeqno, adeqmp, adeqar, adeqtr, adeqqu
      integer adeqte, adeqhe
c
      integer iaux, jaux, kaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
c
      character*64 saux64
      character*200 sau200
c
      integer nbmess
      parameter ( nbmess = 30 )
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
      texte(1,4) =
     > '(''. Creation de l''''equivalence pour le recollement'')'
      texte(1,6) =
     > '(2x,''Nombre de paires de '',a,''a recoller :'',i10)'
c
      texte(2,4) = '(''. Creation of equivalence for glue'')'
      texte(2,6) = '(2x,''Number of pairs of '',a,''to glue :'',i10)'
c
#include "impr03.h"
c
      write (ulsort,texte(langue,4))
c
      un = 1
c
c====
c 2. recuperation des donnees du maillage a modifier
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. recuperation donnees ; codret', codret
#endif
c
c 2.1. ==> les noms des structures
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMC', nompro
#endif
      call utnomc ( nocmap,
     >                sdim,   mdim,
     >               degre, mailet, maconf, homolo, hierar,
     >              nbnomb,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret)
c
      endif
c
c 2.2. ==> les recollements
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nospec)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD41', nompro
#endif
      call utad41 ( nospec,
     >              nparrc, nptrrc, npqurc,
     >              npterc, npherc, npperc, nppyrc,
     >              adarrc, adtrrc, adqurc,
     >              adterc, adherc, adperc, adpyrc,
     >              ulsort, langue, codret)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nospec//'.Tab1')
      call gmprsx (nompro, nospec//'.Tab2')
      call gmprsx (nompro, nospec//'.Tab3')
      call gmprsx (nompro, nospec//'.Tab5')
#endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(nonexm,2).ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,1), nparrc
      endif
      if ( nbtria.ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,2), nptrrc
      endif
      if ( nbquad.ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,4), npqurc
      endif
      if ( nbtetr.ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,3), npterc
      endif
      if ( nbhexa.ne.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,6), npherc
      endif
      write (ulsort,*) ' '
c
      endif
c
c====
c 3. la structure generale des equivalences
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Struct gale des equiv ; codret', codret
#endif
c
      if ( nparrc.ne.0 .or. nptrrc.ne.0 .or. npqurc.ne.0 ) then
c
c 3.1. ==> Les nombres
c
      if ( codret.eq.0 ) then
c
      nbequi = nbequi + 1
      nbeqar = nbeqar + nparrc
      nbeqtr = nbeqtr + nptrrc
      nbeqqu = nbeqqu + npqurc
      nbeqte = nptrrc
      nbeqhe = npqurc
c
      endif
c
c 3.2. ==> Si aucune equivalence n'existe, on en cree une
c
      if ( homolo.eq.0 ) then
c
        if ( codret.eq.0 ) then
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
cgn        call gmprsx ( nompro, ncequi )
cgn        call gmprsx ( nompro, ncequi//'.Quadr' )
cgn        call gmprsx ( nompro, ncequi//'.Hexae' )
c
        endif
c
      else
c
c 3.3. ==> Si des equivalences existent, on enrichit
c
        if ( codret.eq.0 ) then
c
        call gmecat ( ncequi, 1, nbequi, codre1 )
        call gmecat ( ncequi, 4, nbeqar, codre2 )
        call gmecat ( ncequi, 5, nbeqtr, codre3 )
        call gmecat ( ncequi, 6, nbeqqu, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        iaux = 5*(nbequi-1)
        jaux = 5*nbequi
        call gmmod ( ncequi//'.Pointeur',
     >               adeqpo, iaux, jaux, un, un, codre1 )
        iaux = 33*(nbequi-1)
        jaux = 33*nbequi
        call gmmod ( ncequi//'.InfoGene',
     >               adeqin, iaux, jaux, un, un, codre2 )
        iaux = 2*(nbeqar-nparrc)
        jaux = 2*nbeqar
        call gmmod ( ncequi//'.Arete',
     >               adeqar, iaux, jaux, un, un, codre3 )
        iaux = 2*(nbeqtr-nptrrc)
        jaux = 2*nbeqtr
        call gmmod ( ncequi//'.Trian',
     >               adeqtr, iaux, jaux, un, un, codre4 )
        iaux = 2*(nbeqqu-npqurc)
        jaux = 2*nbeqqu
        call gmmod ( ncequi//'.Quadr',
     >               adeqqu, iaux, jaux, un, un, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,ncequi)
      call gmprsx (nompro,ncequi//'.Pointeur')
      call gmprsx (nompro,ncequi//'.InfoGene')
      call gmprsx (nompro,ncequi//'.Arete')
      call gmprsx (nompro,ncequi//'.Trian')
      call gmprsx (nompro,ncequi//'.Quadr')
#endif
c
      endif
c
c====
c 4. Remplissage
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Remplissage ; codret', codret
#endif
c
      if ( nparrc.ne.0 .or. nptrrc.ne.0 .or. npqurc.ne.0 ) then
c
c 4.1. ==> Les pointeurs
c
      if ( codret.eq.0 ) then
c
      iaux = adeqpo + 5*nbequi
      imem(iaux-5) = 0
      imem(iaux-4) = 0
      imem(iaux-3) = nparrc
      imem(iaux-2) = nptrrc
      imem(iaux-1) = npqurc
c
      endif
c
c 4.2. ==> Les informations generales
c
      if ( codret.eq.0 ) then
c
      saux64 = blan64
      saux64(1:31) = 'MAILLES_A_RECOLLER_APRES_HOMARD'
c                     12345678901234567890123456789012
      iaux = 64
      jaux = adeqin + 33*(nbequi-1)
      call utchs8 ( saux64, iaux, smem(jaux),
     >              ulsort, langue, codret )
c                        1234567890123456789012345678901234567890
      sau200(  1: 40) = 'Cette equivalence decrit les mailles a r'
      sau200( 41: 80) = 'ecoller. Dans chaque correspondance, le '
      sau200( 81:120) = 'premier numero est celui de la maille co'
      sau200(121:160) = 'upee ; le second numero est celui d''une '
      sau200(161:200) = 'des petites mailles en regard.          '
c
      iaux = 200
      jaux = adeqin + 33*(nbequi-1) + 8
      call utchs8 ( sau200, iaux, smem(jaux),
     >              ulsort, langue, codret )
c
      endif
c
c 4.3. ==> Les aretes
c
      if ( codret.eq.0 ) then
c
      jaux = adeqar + 2*(nbeqar-nparrc)
      kaux = 2*nparrc - 1
      do 43 , iaux = 0 , kaux
        imem(jaux+iaux) = imem(adarrc+iaux)
   43 continue
c
      endif
c
c 4.4. ==> Les triangles
c
      if ( codret.eq.0 ) then
c
      jaux = adeqtr + 2*(nbeqtr-nptrrc)
      kaux = 2*nptrrc - 1
      do 44 , iaux = 0 , kaux
        imem(jaux+iaux) = imem(adtrrc+iaux)
   44 continue
c
      endif
c
c 4.5. ==> Les quadrangles
c
      if ( codret.eq.0 ) then
c
      jaux = adeqqu + 2*(nbeqqu-npqurc)
      kaux = 2*npqurc - 1
      do 45 , iaux = 0 , kaux
        imem(jaux+iaux) = imem(adqurc+iaux)
   45 continue
c
      endif
c
c 4.6. ==> Les tetraedres
c
      if ( codret.eq.0 ) then
c
      jaux = adeqte
      kaux = 2*nptrrc - 1
      do 46 , iaux = 0 , kaux
        imem(jaux+iaux) = imem(adterc+iaux)
   46 continue
c
      endif
c
c 4.7. ==> Les hexaedres
c
      if ( codret.eq.0 ) then
c
      jaux = adeqhe
      kaux = 2*npqurc - 1
      do 47 , iaux = 0 , kaux
        imem(jaux+iaux) = imem(adherc+iaux)
   47 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,ncequi)
      call gmprsx (nompro,ncequi//'.Pointeur')
      call gmprsx (nompro,ncequi//'.InfoGene')
      call gmprsx (nompro,ncequi//'.Arete')
      call gmprsx (nompro,ncequi//'.Trian')
      call gmprsx (nompro,ncequi//'.Quadr')
      call gmprsx (nompro,ncequi//'.Tetra')
      call gmprsx (nompro,ncequi//'.Hexae')
#endif
c
      endif
c
c====
c 5. Les nombres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Les nombres ; codret', codret
#endif
c
      if ( nparrc.ne.0 .or. nptrrc.ne.0 .or. npqurc.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ncnomb, adnomb, iaux, codret )
c
      endif
cgn      print *,nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
c
      if ( codret.eq.0 ) then
c
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
      endif
c
c====
c 6. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. la fin ; codret', codret
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
