      subroutine mmdeg0 ( nomail,
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
c  Modification de Maillage - DEGre - phase 0
c  -               -          ---           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard iter. n     .
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
      parameter ( nompro = 'MMDEG0' )
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
c
#include "nombar.h"
#include "nombno.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7
      integer codre0
c
      integer indnoe
      integer degnou
      integer nbsegm, nbtria, nbquad, nbtetr, nbhexa, nbpyra, nbpent
      integer nbfare, pcfaar
      integer nbftri, pcfatr
      integer nbfqua, pcfaqu
      integer nbftet, pcfate
      integer nbfhex, pcfahe
      integer nbfpyr, pcfapy
      integer nbfpen, pcfape
      integer adnbrn
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 nharfa, nhtrfa, nhqufa
      character*8 nhtefa, nhhefa, nhpyfa, nhpefa
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
      texte(1,4) = '(5x,''Passage du degre '',i1,'' au degre '',i1,/)'
c
      texte(2,4) = '(5x,''From degree '',i1,'' to '',i1,/)'
c
c====
c 2. structure de donnees
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
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
      endif
cgn      call gmprsx (nompro, nomail )
cgn      call gmprsx (nompro, nomail//'.Volume' )
cgn      call gmprsx (nompro, nomail//'.Volume.HOM_Te04' )
cgn      call gmprsx (nompro, nharet//'.Famille' )
cgn      call gmprsx (nompro, nhtria//'.Famille' )
cgn      call gmprsx (nompro, nhquad//'.Famille' )
cgn      call gmprsx (nompro, nhtetr//'.Famille' )
cgn      call gmprsx(nompro,nhtetr//'.Famille')
c
c 2.2. ==> grandeurs
c
      if ( codret.eq.0 ) then
c
      if ( degre.eq.1 ) then
c
        degnou = 2
        nouvar = nbarto
        nouvno = nbnoto + nbarto
        indnoe = nbnoto
c
      else
c
        degnou = 1
        nouvno = nbnoto
c
      endif
c
      write (ulsort,texte(langue,4)) degre, degnou
c
      endif
c
c====
c 3. changement de degre pour les noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. chang. de degre noeuds; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> Creation des noeuds P2
c
      if ( degre.eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMCNP2', nompro
#endif
c
        call mmcnp2 ( nomail, nhnoeu, nharet,
     >                indnoe,
     >                ulsort, langue, codret )
c
c 3.2. ==> Suppression des noeuds P2
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMSNP2', nompro
#endif
c
        call mmsnp2 ( nomail,
     >                indnoe,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 4. changement de degre pour les elements
c    les elements etant decrits par connectivite descendante, celle-ci
c    est invariante par un changement de degre. Il suffit de changer la
c    localisation de la branche.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4.  chang. de degre elem ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( degre.eq.1 ) then
c
        call gmcpgp ( nharet, nomail//'.Arete.HOM_Se03' , codre1 )
        call gmcpgp ( nhtria, nomail//'.Face.HOM_Tr06'  , codre2 )
        call gmcpgp ( nhquad, nomail//'.Face.HOM_Qu08'  , codre3 )
        call gmcpgp ( nhtetr, nomail//'.Volume.HOM_Te10', codre4 )
        call gmcpgp ( nhpyra, nomail//'.Volume.HOM_Py13', codre5 )
        call gmcpgp ( nhhexa, nomail//'.Volume.HOM_He20', codre6 )
        call gmcpgp ( nhpent, nomail//'.Volume.HOM_Pe15', codre7 )
c
      else
c
        call gmcpgp ( nharet, nomail//'.Arete.HOM_Se02' , codre1 )
        call gmcpgp ( nhtria, nomail//'.Face.HOM_Tr03'  , codre2 )
        call gmcpgp ( nhquad, nomail//'.Face.HOM_Qu04'  , codre3 )
        call gmcpgp ( nhtetr, nomail//'.Volume.HOM_Te04', codre4 )
        call gmcpgp ( nhpyra, nomail//'.Volume.HOM_Py05', codre5 )
        call gmcpgp ( nhhexa, nomail//'.Volume.HOM_He08', codre6 )
        call gmcpgp ( nhpent, nomail//'.Volume.HOM_Pe06', codre7 )
c
      endif
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( nharet, codre1 )
      call gmlboj ( nhtria, codre2 )
      call gmlboj ( nhquad, codre3 )
      call gmlboj ( nhtetr, codre4 )
      call gmlboj ( nhpyra, codre5 )
      call gmlboj ( nhhexa, codre6 )
      call gmlboj ( nhpent, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      endif
c
c====
c 5. mise a jour des grandeurs caracteristiques
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. mise a jour ; codret = ', codret
#endif
c
c 5.1. ==> nbmane : nombre maximal de noeud par element
c
      if ( codret.eq.0 ) then
c
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
     >                iaux, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpent, nbpyra,
     >                iaux,   iaux,
     >                iaux,   iaux,
     >              ulsort, langue, codret )
cgn      print *, nbmane
cgn      print *, nbsegm, nbtria, nbquad, nbtetr, nbhexa, nbpent
c
      if ( degnou.eq.1 ) then
c
        if ( nbhexa.gt.0 ) then
          nbmane = 8
        elseif ( nbpent.gt.0 ) then
          nbmane = 6
        elseif ( nbpyra.gt.0 ) then
          nbmane = 5
        elseif ( nbtetr.gt.0 .or. nbquad.gt.0 ) then
          nbmane = 4
        elseif ( nbtria.gt.0 ) then
          nbmane = 3
        elseif ( nbsegm.gt.0 ) then
          nbmane = 2
        else
          nbmane = 1
        endif
c
      else
c
        if ( nbhexa.gt.0 ) then
          nbmane = 20
        elseif ( nbpent.gt.0 ) then
          nbmane = 15
        elseif ( nbpyra.gt.0 ) then
          nbmane = 13
        elseif ( nbtetr.gt.0 ) then
          nbmane = 10
        elseif ( nbquad.gt.0 ) then
          nbmane = 8
        elseif ( nbtria.gt.0 ) then
          nbmane = 6
        elseif ( nbsegm.gt.0 ) then
          nbmane = 3
        else
          nbmane = 1
        endif
c
      endif
c
cgn      print *, nbmane
      call gmecat ( nomail, 8, nbmane , codret )
c
      endif
c
c 5.2. ==> le nombres d'entites
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5.2. nombre entites ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbnop2 = nbarto - nbnop2
      nbnoto = indnoe
      degre = degnou
c
      call gmecat ( nhnoeu, 1, nbnoto, codre1 )
      call gmecat ( nomail, 3, degre , codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 5.3. ==> reperage des tableaux des types d'elements
c          attention, il faut refaire un appel a utnomh, car les
c          branches ont ete permutees entre degres ...
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5.3. reperage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
c      call gmprsx (nompro,nomail)
c      call gmprsx (nompro,nomail//'.Volume')
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
      call gmnomc ( nharet//'.Famille', nharfa, codre1 )
      call gmnomc ( nhtria//'.Famille', nhtrfa, codre2 )
      call gmnomc ( nhquad//'.Famille', nhqufa, codre3 )
      call gmnomc ( nhtetr//'.Famille', nhtefa, codre4 )
      call gmnomc ( nhhexa//'.Famille', nhhefa, codre5 )
      call gmnomc ( nhpyra//'.Famille', nhpyfa, codre6 )
      call gmnomc ( nhpent//'.Famille', nhpefa, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nharfa, 1, nbfare, codre1 )
      call gmliat ( nhtrfa, 1, nbftri, codre2 )
      call gmliat ( nhqufa, 1, nbfqua, codre3 )
      call gmliat ( nhtefa, 1, nbftet, codre4 )
      call gmliat ( nhpyfa, 1, nbfpyr, codre5 )
      call gmliat ( nhhefa, 1, nbfhex, codre6 )
      call gmliat ( nhpefa, 1, nbfpen, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 , codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( nharfa//'.Codes'   , pcfaar, iaux, codre1 )
      call gmadoj ( nhtrfa//'.Codes'   , pcfatr, iaux, codre2 )
      call gmadoj ( nhqufa//'.Codes'   , pcfaqu, iaux, codre3 )
      call gmadoj ( nhtefa//'.Codes'   , pcfate, iaux, codre4 )
      call gmadoj ( nhpyfa//'.Codes'   , pcfapy, iaux, codre5 )
      call gmadoj ( nhhefa//'.Codes'   , pcfahe, iaux, codre6 )
      call gmadoj ( nhpefa//'.Codes'   , pcfape, iaux, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      endif
c
c 5.4. ==> on echange le code du second champ de la description des
c          familles : c'est celui qui designe le type de l'element
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5.4. echange de code ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Avant appel a mmelde, codes des familles : '
      call gmprsx (nompro, nharfa//'.Codes' )
      call gmprsx (nompro, nhtrfa//'.Codes' )
      call gmprsx (nompro, nhqufa//'.Codes' )
      call gmprsx (nompro, nhtefa//'.Codes' )
      call gmprsx (nompro, nhpyfa//'.Codes' )
      call gmprsx (nompro, nhhefa//'.Codes' )
      call gmprsx (nompro, nhpefa//'.Codes' )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMELDE', nompro
#endif
      call mmelde ( typcca,
     >              nbfare, imem(pcfaar),
     >              nbftri, imem(pcfatr),
     >              nbfqua, imem(pcfaqu),
     >              nbftet, imem(pcfate),
     >              nbfhex, imem(pcfahe),
     >              nbfpyr, imem(pcfapy),
     >              nbfpen, imem(pcfape),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'Apres appel a mmelde, codes des familles : '
      call gmprsx (nompro, nharfa//'.Codes'    )
      call gmprsx (nompro, nhtrfa//'.Codes'    )
      call gmprsx (nompro, nhqufa//'.Codes'    )
      call gmprsx (nompro, nhtefa//'.Codes'    )
      call gmprsx (nompro, nhpyfa//'.Codes' )
      call gmprsx (nompro, nhhefa//'.Codes' )
      call gmprsx (nompro, nhpefa//'.Codes' )
#endif
c
      endif
c
c====
c 6. suppression des voisins par noeuds s'ils existent
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. voisins ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nhvois//'.0D/1D', codre0 )
c
      if ( codre0.eq.1 ) then
c
        call gmlboj ( nhvois//'.0D/1D', codret )
c
      elseif ( codre0.ne.0 ) then
c
        codret = 5
c
      endif
c
      endif
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
