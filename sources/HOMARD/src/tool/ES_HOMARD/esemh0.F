      subroutine esemh0 ( nomail,
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
c  Entree-Sortie : Ecriture du Maillage Homard - 0
c  -      -        -           -        -        -
c ______________________________________________________________________
c    Attention : esemh0 et eslmh3 doivent evoluer en parallelle
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char*8 . nom du maillage a ecrire                   .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'ESEMH0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "envada.h"
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
      integer adinse
      integer codre1, codre2
c
      logical existe(2)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. les initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Enregistrement des communs.'')'
c
      texte(2,4) = '(''Recording of the commons'')'
c
#include "impr03.h"
c
c====
c 2. controle des allocations deja presentes
c    comme elles n'ont pu se faire qu'ici, on ne verifie pas les tailles
c====
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nomail )
      call gmprsx (nompro, nomail//'.InfoSupE' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab1' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab2' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab3' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab4' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab5' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab6' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab7' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab8' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab9' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab10' )
      call gmprsx (nompro, nomail//'.InfoSupS' )
      call gmprsx (nompro, nomail//'.InfoSupS.Tab2' )
      call gmprsx (nompro, nomail//'.InfoSupS.Tab3' )
      call gmprsx (nompro, nomail//'.InfoSupS.Tab4' )
      call gmprsx (nompro, nomail//'.InfoSupS.Tab5' )
      call gmprsx (nompro, nomail//'.InfoSupS.Tab10' )
#endif
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nomail//'.InfoSupE.Tab1', codre1 )
      if ( codre1.eq.2 ) then
        existe(1) = .true.
      elseif ( codre1.eq.0 ) then
        existe(1) = .false.
      else
        codret = 2
      endif
C
      call gmobal ( nomail//'.InfoSupE.Tab2', codre2 )
      if ( codre2.eq.2 ) then
        call gmdtoj ( nomail//'.InfoSupE.Tab2', codret )
      elseif ( codre2.ne.0 ) then
        codret = 2
      endif
c
      endif
c
c====
c 3. Allocations de la branche pour les informations en entier
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3 allocation : codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( .not.existe(1) ) then
        iaux = 12 + 2 + 12 + 12 + 9 + 22 + 9 + 9 + 18 + 9 + 8 + 27 + 5
        call gmaloj ( nomail//'.InfoSupE.Tab1',
     >                ' ', iaux, adinse, codret )
      else
        call gmadoj ( nomail//'.InfoSupE.Tab1', adinse, iaux, codret )
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nomail//'.InfoSupE', 1, iaux, codret )
c
      endif
c
c====
c 4. transfert des infos des communs vers la structure
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4 transfert : codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
       iaux = adinse - 1
c nombno
       imem(iaux+1) = nbnois
       imem(iaux+2) = nbnoei
       imem(iaux+3) = nbnoma
       imem(iaux+4) = nbnomp
       imem(iaux+5) = nbnop1
       imem(iaux+6) = nbnop2
       imem(iaux+7) = nbnoim
       imem(iaux+8) = nbnoto
       imem(iaux+9) = nbpnho
       imem(iaux+10) = numip1
       imem(iaux+11) = numap1
       imem(iaux+12) = nbnoin
       iaux = iaux + 12
c nombmp
       imem(iaux+1) = nbmpto
       imem(iaux+2) = nbppho
       iaux = iaux + 2
c nombar
       imem(iaux+1) = nbarac
       imem(iaux+2) = nbarde
       imem(iaux+3) = nbart2
       imem(iaux+4) = nbarq2
       imem(iaux+5) = nbarq3
       imem(iaux+6) = nbarq5
       imem(iaux+7) = nbarin
       imem(iaux+8) = nbarma
       imem(iaux+9) = nbarpe
       imem(iaux+10) = nbarto
       imem(iaux+11) = nbfaar
       imem(iaux+12) = nbpaho
       iaux = iaux + 12
c nombtr
       imem(iaux+1) = nbtrac
       imem(iaux+2) = nbtrde
       imem(iaux+3) = nbtrt2
       imem(iaux+4) = nbtrq3
       imem(iaux+5) = nbtrhc
       imem(iaux+6) = nbtrpc
       imem(iaux+7) = nbtrtc
       imem(iaux+8) = nbtrma
       imem(iaux+9) = nbtrpe
       imem(iaux+10) = nbtrto
       imem(iaux+11) = nbptho
       imem(iaux+12) = nbtrri
       iaux = iaux + 12
c nombqu
       imem(iaux+1) = nbquac
       imem(iaux+2) = nbqude
       imem(iaux+3) = nbquma
       imem(iaux+4) = nbquq2
       imem(iaux+5) = nbquq5
       imem(iaux+6) = nbqupe
       imem(iaux+7) = nbquto
       imem(iaux+8) = nbpqho
       imem(iaux+9) = nbquri
       iaux = iaux + 9
c nombte
       imem(iaux+1) = nbteac
       imem(iaux+2) = nbtea2
       imem(iaux+3) = nbtea4
       imem(iaux+4) = nbtede
       imem(iaux+5) = nbtef4
       imem(iaux+6) = nbteh1
       imem(iaux+7) = nbteh2
       imem(iaux+8) = nbteh3
       imem(iaux+9) = nbteh4
       imem(iaux+10) = nbtep0
       imem(iaux+11) = nbtep1
       imem(iaux+12) = nbtep2
       imem(iaux+13) = nbtep3
       imem(iaux+14) = nbtep4
       imem(iaux+15) = nbtep5
       imem(iaux+16) = nbtedh
       imem(iaux+17) = nbtedp
       imem(iaux+18) = nbtema
       imem(iaux+19) = nbtepe
       imem(iaux+20) = nbteto
       imem(iaux+21) = nbtecf
       imem(iaux+22) = nbteca
       iaux = iaux + 22
c nombhe
       imem(iaux+1) = nbheac
       imem(iaux+2) = nbheco
       imem(iaux+3) = nbhede
       imem(iaux+4) = nbhedh
       imem(iaux+5) = nbhema
       imem(iaux+6) = nbhepe
       imem(iaux+7) = nbheto
       imem(iaux+8) = nbhecf
       imem(iaux+9) = nbheca
       iaux = iaux + 9
c nombpe
       imem(iaux+1) = nbpeac
       imem(iaux+2) = nbpeco
       imem(iaux+3) = nbpede
       imem(iaux+4) = nbpedp
       imem(iaux+5) = nbpema
       imem(iaux+6) = nbpepe
       imem(iaux+7) = nbpeto
       imem(iaux+8) = nbpecf
       imem(iaux+9) = nbpeca
       iaux = iaux + 9
c nombpy
       imem(iaux+1) = nbpyac
       imem(iaux+2) = nbpyh1
       imem(iaux+3) = nbpyh2
       imem(iaux+4) = nbpyh3
       imem(iaux+5) = nbpyh4
       imem(iaux+6) = nbpyp0
       imem(iaux+7) = nbpyp1
       imem(iaux+8) = nbpyp2
       imem(iaux+9) = nbpyp3
       imem(iaux+10) = nbpyp4
       imem(iaux+11) = nbpyp5
       imem(iaux+12) = nbpydh
       imem(iaux+13) = nbpydp
       imem(iaux+14) = nbpyma
       imem(iaux+15) = nbpype
       imem(iaux+16) = nbpyto
       imem(iaux+17) = nbpycf
       imem(iaux+18) = nbpyca
       iaux = iaux + 18
c nbfami
       imem(iaux+1) = nbfnoe
       imem(iaux+2) = nbfmpo
       imem(iaux+3) = nbfare
       imem(iaux+4) = nbftri
       imem(iaux+5) = nbfqua
       imem(iaux+6) = nbftet
       imem(iaux+7) = nbfhex
       imem(iaux+8) = nbfpyr
       imem(iaux+9) = nbfpen
       iaux = iaux + 9
c dicfen
       imem(iaux+ 1) = ncffno
       imem(iaux+ 2) = ncffmp
       imem(iaux+ 3) = ncffar
       imem(iaux+ 4) = ncfftr
       imem(iaux+ 5) = ncffqu
       imem(iaux+ 6) = ncffte
       imem(iaux+ 7) = ncffhe
       imem(iaux+ 8) = ncffpy
       imem(iaux+ 9) = ncffpe
       imem(iaux+10) = ncefno
       imem(iaux+11) = ncefmp
       imem(iaux+12) = ncefar
       imem(iaux+13) = nceftr
       imem(iaux+14) = ncefqu
       imem(iaux+15) = nctfno
       imem(iaux+16) = nctfmp
       imem(iaux+17) = nctfar
       imem(iaux+18) = nctftr
       imem(iaux+19) = nctfqu
       imem(iaux+20) = nctfte
       imem(iaux+21) = nctfhe
       imem(iaux+22) = nctfpy
       imem(iaux+23) = nctfpe
       imem(iaux+24) = ncxfno
       imem(iaux+25) = ncxfar
       imem(iaux+26) = ncxftr
       imem(iaux+27) = ncxfqu
       iaux = iaux + 27
c envada
       imem(iaux+1) = nbiter
       imem(iaux+2) = nivinf
       imem(iaux+3) = nivsup
       imem(iaux+4) = niincf
       imem(iaux+5) = nisucf
       iaux = iaux + 5
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Apres remplissage InfoSupE : codret',
     > codret
      call gmprsx (nompro, nomail )
      call gmprsx (nompro, nomail//'.InfoSupE' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab1' )
      call gmprsx (nompro, nomail//'.InfoSupE.Tab2' )
#endif
c
c====
c 5. la fin
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
