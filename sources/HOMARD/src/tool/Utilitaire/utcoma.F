      subroutine utcoma ( nomail, optimp,
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
c    UTilitaire - verification de la COnformite du MAillage
c    --                              --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . optimp . e   .   1    . option d'impression des non-conformites :  .
c .        .     .        . 0 : pas d'impression                       .
c .        .     .        . non nul : impression                       .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans la recherche de tableaux .
c .        .     .        . 11 : pb. de conformite sur les triangles   .
c .        .     .        . 21 : pb. de conformite sur les tetras      .
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
      parameter ( nompro = 'UTCOMA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer optimp
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nbarto, nbtrto, nbquto
      integer nbteto, nbheto, nbpyto, nbpeto
      integer nbteca, nbheca, nbpyca, nbpeca
      integer nbtecf, nbhecf, nbpycf, nbpecf
c
      integer psomar, phetar
      integer paretr, phettr
      integer parequ, phetqu
      integer ptrite, phette, pcotrt, parete
      integer pquahe, phethe, pcoquh, parehe
      integer pfacpy, phetpy, pcofay, parepy
      integer pfacpe, phetpe, pcofap, parepe
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7
      integer codre0
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Impossible de recuperer les tableaux.'')'
      texte(1,5) = '(''Probleme de conformite sur les '',a,''.'')'
      texte(1,6) = '(''Le maillage est de type non-conforme.'')'
c
      texte(2,4) = '(''Arrays cannot be found.'')'
      texte(2,5) = '(a,'' with hanging nodes.'')'
      texte(2,6) = '(''Mesh is hanging-node type.'')'
c
#include "impr03.h"
c
c====
c 2. recuperation des pointeurs, initialisations
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
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
cgn      write (ulsort,90003) 'structures',
cgn     > nhnoeu, nhmapo, nharet, nhtria, nhquad,
cgn     > nhtetr, nhhexa, nhpyra, nhpent
cgn      call gmprsx(nompro,nhquad)
cgn      call gmprsx(nompro,nhpyra)
cgn      call gmprsx(nompro,nhpyra//'.InfoSupp')
      endif
c
c 2.2. ==> le maillage est declare non conforme
c
      if ( codret.eq.0 ) then
c
      if ( ( maconf.gt.0 ) .or. ( maconf.eq.-2 ) ) then
c
        write (ulsort,texte(langue,6))
c
      endif
c
      endif
c
c====
c 3. analyse
c====
c
      if ( maconf.le.2 ) then
c
c 3.1. ==> Recherche des tableaux
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nharet, 1, nbarto, codre1 )
        call gmliat ( nhtria, 1, nbtrto, codre2 )
        call gmliat ( nhquad, 1, nbquto, codre3 )
        call gmliat ( nhtetr, 1, nbteto, codre4 )
        call gmliat ( nhhexa, 1, nbheto, codre5 )
        call gmliat ( nhpyra, 1, nbpyto, codre6 )
        call gmliat ( nhpent, 1, nbpeto, codre7 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >                 codre6, codre7 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 ,
     >                 codre6, codre7 )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nhtetr, 2, nbteca, codre1 )
        call gmliat ( nhhexa, 2, nbheca, codre2 )
        call gmliat ( nhpyra, 2, nbpyca, codre3 )
        call gmliat ( nhpent, 2, nbpeca, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbteca, nbheca, nbpyca, nbpeca',
     >                        nbteca, nbheca, nbpyca, nbpeca
#endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
        call utad02 (   iaux, nharet,
     >                phetar, psomar, jaux  , jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
        if ( nbtrto.ne.0 ) then
c
         iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
         call utad02 (   iaux, nhtria,
     >                  phettr, paretr, jaux  ,  jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
c
        endif
c
        if ( nbquto.ne.0 ) then
c
          iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
          call utad02 (   iaux, nhquad,
     >                  phetqu, parequ, jaux  ,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
c
        endif
c
        if ( nbteto.ne.0 ) then
c
          iaux = 26
          if ( nbteca.gt.0 ) then
            iaux = iaux*31
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
          call utad02 (   iaux, nhtetr,
     >                  phette, ptrite, jaux  , jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux, pcotrt,   jaux,
     >                    jaux,   jaux, parete,
     >                  ulsort, langue, codret )
c
        endif
c
        if ( nbheto.ne.0 ) then
c
          iaux = 26
          if ( nbheca.gt.0 ) then
            iaux = iaux*31
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
          call utad02 (   iaux, nhhexa,
     >                  phethe, pquahe, jaux  , jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux, pcoquh,   jaux,
     >                    jaux,   jaux, parehe,
     >                  ulsort, langue, codret )
c
        endif
c
        if ( nbpyto.ne.0 ) then
c
          iaux = 26
          if ( nbpyca.gt.0 ) then
            iaux = iaux*31
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
          call utad02 (   iaux, nhpyra,
     >                  phetpy, pfacpy, jaux  , jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux, pcofay,   jaux,
     >                    jaux,   jaux, parepy,
     >                  ulsort, langue, codret )
c
        endif
c
        if ( nbpeto.ne.0 ) then
c
          iaux = 26
          if ( nbpeca.gt.0 ) then
            iaux = iaux*31
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
          call utad02 (   iaux, nhpent,
     >                  phetpe, pfacpe, jaux  , jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux, pcofap,   jaux,
     >                    jaux,   jaux, parepe,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 3.2. ==> Analyse
c
        if ( codret.eq.0 ) then
c
        iaux = maconf
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCONF', nompro
#endif
        call utconf ( nbarto, nbtrto, nbquto,
     >                nbteto, nbheto, nbpyto, nbpeto,
     >                nbteca, nbheca, nbpyca, nbpeca,
     >                nbtecf, nbhecf, nbpycf, nbpecf,
     >                imem(phetar),
     >                imem(phettr), imem(paretr),
     >                imem(phetqu), imem(parequ),
     >                imem(phette), imem(ptrite), imem(pcotrt),
     >                imem(phethe), imem(pquahe), imem(pcoquh),
     >                imem(phetpy), imem(pfacpy), imem(pcofay),
     >                imem(phetpe), imem(pfacpe), imem(pcofap),
     >                iaux, optimp,
     >                ulsort, langue, codret )
c
        endif
c
      endif
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
        if ( codret.eq.2 ) then
          write (ulsort,texte(langue,4))
        else
#ifdef _DEBUG_HOMARD_
c
#else
          if ( optimp.ne.0 ) then
#endif
            write (ulsort,texte(langue,5)) mess14(langue,3,codret)
#ifdef _DEBUG_HOMARD_
c
#else
c
          endif
#endif
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
