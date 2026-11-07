      subroutine eslmh3 ( idfmed, nomamd,
     >                    nhsupe,
     >                    nbfmed, natmax, ngrmax,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : Lecture du Maillage Homard - phase 3
c  -      -        -          -        -              -
c ______________________________________________________________________
c    Attention : esemh0 et eslmh3 doivent evoluer en parallelle
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . nhsupe . e   . char8  . informations supplementaires entieres      .
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
      parameter ( nompro = 'ESLMH3' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
c
#include "envex1.h"
c
#include "envada.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombno.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nancnb.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer nbfmed, natmax, ngrmax
c
      character*8 nhsupe
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux, kaux, laux
      integer lgnpro
      integer codre1, codre2
      integer codre0
      integer nbprof
      integer nbvapr, adlipr
c
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. intialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,5x,''Mise a jour des communs'')'
c
      texte(2,4) = '(/,5x,''Updating of commons'')'
c
#include "esimpr.h"
c
#include "impr03.h"
c
c====
c 2. Recuperation des parametres essentiels
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Lecture des profils ; codret', codret
#endif
c 2.1. ==> Nombre de profils
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFNPF', nompro
#endif
      call mpfnpf ( idfmed, nbprof, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,86)) nbprof
#endif
c
      endif
c
c 2.2. ==> Parcours des profils
c
      do 22 , iaux = 1 , nbprof
c
c 2.2.1. ==> nom et taille du profil a lire
c
        if ( codret.eq.0 ) then
c
        jaux = iaux
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPFI', nompro
#endif
        call mpfpfi ( idfmed, jaux, noprof, nbvapr, codret )
        if ( codret.ne.0 ) then
        write (ulsort,texte(langue,79))
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,61)) noprof
        write (ulsort,texte(langue,62)) nbvapr
#endif
c
        endif
c
c 2.2.2. ==> On ne continue que pour les InfoSupE
c
        if ( codret.eq.0 ) then
c
        if ( noprof(10:12).ne.'Tab' ) then
          goto 22
        endif
c
        endif
c
c 2.2.3. ==> Allocation du tableau receptacle
c
        if ( codret.eq.0 ) then
c
        call utlgut ( lgnpro, noprof,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call utchen ( noprof(13:lgnpro), jaux, ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmaloj ( nhsupe//'.'//noprof(10:lgnpro) , ' ',
     >                nbvapr, adlipr, codre1 )
        call gmecat ( nhsupe , jaux, nbvapr, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
c 2.2.4. ==> Lecture de la liste des valeurs
c
        if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRR', nompro
#endif
        call mpfprr ( idfmed, noprof, imem(adlipr), codret )
c
        endif
c
c 2.2.5. ==> Transfert le cas echeant
c
        if ( codret.eq.0 ) then
c
c 2.2.5.1. ==> Tab1 : communs entiers
c
        if ( jaux.eq.1 ) then
c
          kaux = adlipr - 1
c nombno
          nbnois = imem(kaux+1)
          nbnoei = imem(kaux+2)
          nbnoma = imem(kaux+3)
          nbnomp = imem(kaux+4)
          nbnop1 = imem(kaux+5)
          nbnop2 = imem(kaux+6)
          nbnoim = imem(kaux+7)
          nbnoto = imem(kaux+8)
          nbpnho = imem(kaux+9)
          numip1 = imem(kaux+10)
          numap1 = imem(kaux+11)
          nbnoin = imem(kaux+12)
          kaux = kaux + 12
c nombmp
          nbmpto = imem(kaux+1)
          nbppho = imem(kaux+2)
          kaux = kaux + 2
c nombar
          nbarac = imem(kaux+1)
          nbarde = imem(kaux+2)
          nbart2 = imem(kaux+3)
          nbarq2 = imem(kaux+4)
          nbarq3 = imem(kaux+5)
          nbarq5 = imem(kaux+6)
          nbarin = imem(kaux+7)
          nbarma = imem(kaux+8)
          nbarpe = imem(kaux+9)
          nbarto = imem(kaux+10)
          nbfaar = imem(kaux+11)
          nbpaho = imem(kaux+12)
          kaux = kaux + 12
c nombtr
          nbtrac = imem(kaux+1)
          nbtrde = imem(kaux+2)
          nbtrt2 = imem(kaux+3)
          nbtrq3 = imem(kaux+4)
          nbtrhc = imem(kaux+5)
          nbtrpc = imem(kaux+6)
          nbtrtc = imem(kaux+7)
          nbtrma = imem(kaux+8)
          nbtrpe = imem(kaux+9)
          nbtrto = imem(kaux+10)
          nbptho = imem(kaux+11)
          nbtrri = imem(kaux+12)
          kaux = kaux + 12
c nombqu
          nbquac = imem(kaux+1)
          nbqude = imem(kaux+2)
          nbquma = imem(kaux+3)
          nbquq2 = imem(kaux+4)
          nbquq5 = imem(kaux+5)
          nbqupe = imem(kaux+6)
          nbquto = imem(kaux+7)
          nbpqho = imem(kaux+8)
          nbquri = imem(kaux+9)
          kaux = kaux + 9
c nombte
          nbteac = imem(kaux+1)
          nbtea2 = imem(kaux+2)
          nbtea4 = imem(kaux+3)
          nbtede = imem(kaux+4)
          nbtef4 = imem(kaux+5)
          nbteh1 = imem(kaux+6)
          nbteh2 = imem(kaux+7)
          nbteh3 = imem(kaux+8)
          nbteh4 = imem(kaux+9)
          nbtep0 = imem(kaux+10)
          nbtep1 = imem(kaux+11)
          nbtep2 = imem(kaux+12)
          nbtep3 = imem(kaux+13)
          nbtep4 = imem(kaux+14)
          nbtep5 = imem(kaux+15)
          nbtedh = imem(kaux+16)
          nbtedp = imem(kaux+17)
          nbtema = imem(kaux+18)
          nbtepe = imem(kaux+19)
          nbteto = imem(kaux+20)
          nbtecf = imem(kaux+21)
          nbteca = imem(kaux+22)
          kaux = kaux + 22
c nombhe
          nbheac = imem(kaux+1)
          nbheco = imem(kaux+2)
          nbhede = imem(kaux+3)
          nbhedh = imem(kaux+4)
          nbhema = imem(kaux+5)
          nbhepe = imem(kaux+6)
          nbheto = imem(kaux+7)
          nbhecf = imem(kaux+8)
          nbheca = imem(kaux+9)
          kaux = kaux + 9
c nombpe
          nbpeac = imem(kaux+1)
          nbpeco = imem(kaux+2)
          nbpede = imem(kaux+3)
          nbpedp = imem(kaux+4)
          nbpema = imem(kaux+5)
          nbpepe = imem(kaux+6)
          nbpeto = imem(kaux+7)
          nbpecf = imem(kaux+8)
          nbpeca = imem(kaux+9)
          kaux = kaux + 9
c nombpy
          nbpyac = imem(kaux+1)
          nbpyh1 = imem(kaux+2)
          nbpyh2 = imem(kaux+3)
          nbpyh3 = imem(kaux+4)
          nbpyh4 = imem(kaux+5)
          nbpyp0 = imem(kaux+6)
          nbpyp1 = imem(kaux+7)
          nbpyp2 = imem(kaux+8)
          nbpyp3 = imem(kaux+9)
          nbpyp4 = imem(kaux+10)
          nbpyp5 = imem(kaux+11)
          nbpydh = imem(kaux+12)
          nbpydp = imem(kaux+13)
          nbpyma = imem(kaux+14)
          nbpype = imem(kaux+15)
          nbpyto = imem(kaux+16)
          nbpycf = imem(kaux+17)
          nbpyca = imem(kaux+18)
          kaux = kaux + 18
c nbfami
          nbfnoe = imem(kaux+1)
          nbfmpo = imem(kaux+2)
          nbfare = imem(kaux+3)
          nbftri = imem(kaux+4)
          nbfqua = imem(kaux+5)
          nbftet = imem(kaux+6)
          nbfhex = imem(kaux+7)
          nbfpyr = imem(kaux+8)
          nbfpen = imem(kaux+9)
          kaux = kaux + 9
c dicfen
          ncffno = imem(kaux+ 1)
          ncffmp = imem(kaux+ 2)
          ncffar = imem(kaux+ 3)
          ncfftr = imem(kaux+ 4)
          ncffqu = imem(kaux+ 5)
          ncffte = imem(kaux+ 6)
          ncffhe = imem(kaux+ 7)
          ncffpy = imem(kaux+ 8)
          ncffpe = imem(kaux+ 9)
          ncefno = imem(kaux+10)
          ncefmp = imem(kaux+11)
          ncefar = imem(kaux+12)
          nceftr = imem(kaux+13)
          ncefqu = imem(kaux+14)
          nctfno = imem(kaux+15)
          nctfmp = imem(kaux+16)
          nctfar = imem(kaux+17)
          nctftr = imem(kaux+18)
          nctfqu = imem(kaux+19)
          nctfte = imem(kaux+20)
          nctfhe = imem(kaux+21)
          nctfpy = imem(kaux+22)
          nctfpe = imem(kaux+23)
          ncxfno = imem(iaux+24)
          ncxfar = imem(iaux+25)
          ncxftr = imem(iaux+26)
          ncxfqu = imem(iaux+27)
          kaux = kaux + 27
c envada
          nbiter = imem(kaux+1)
          nivinf = imem(kaux+2)
          nivsup = imem(kaux+3)
          niincf = imem(kaux+4)
          nisucf = imem(kaux+5)
          kaux = kaux + 5
c
c 2.2.5.2. ==> Tab7 : pointeurs des informations generales
c
        elseif ( jaux.eq.7 ) then
c
          kaux = nbvapr
          call gmecat ( nhsupe , jaux, kaux, codret )
c
        endif
c
        endif
c
   22 continue
c
ccc      write (ulsort,90002) 'nbnoto', nbnoto
ccc      write (ulsort,90002) 'nbmpto', nbmpto
ccc      write (ulsort,90002) 'nbarto', nbarto
ccc      write (ulsort,90002) 'nbtrto', nbtrto
ccc      write (ulsort,90002) 'nbteto', nbteto
ccc      write (ulsort,90002) 'nbquto', nbquto
ccc      write (ulsort,90002) 'nbpyto', nbpyto
ccc      write (ulsort,90002) 'nbheto', nbheto
ccc      write (ulsort,90002) 'nbpeto', nbpeto
c
cgn      call gmprsx (nompro,nhsupe)
c
c 2.3. ==> Archivage
c
      if ( codret.eq.0 ) then
c
      nancno = nbnoto
      nancar = nbarto
      nanctr = nbtrto
      nancqu = nbquto
      nancte = nbteto
      nanctf = nbtecf
      nancta = nbteca
      nanche = nbheto
      nanchf = nbhecf
      nancha = nbheca
      nancpe = nbpeto
      nancpf = nbpecf
      nancpa = nbpeca
      nancpy = nbpyto
      nancyf = nbpycf
      nancya = nbpyca
c
      endif
c
c====
c 3. Recuperation du dimensionnement des familles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Lecture des familles ; codret', codret
#endif
c
c 3.1. ==> Nombre de familles
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFANFA', nompro
#endif
      call mfanfa ( idfmed, nomamd, nbfmed, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,29)) nbfmed
#endif
c
      endif
c
c 3.2. ==> Recherche des nombres maximaux de groupe
c
      if ( codret.eq.0 ) then
c
      natmax = 0
      ngrmax = 0
c
      do 320 , laux = 1 , nbfmed
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFANFG', nompro
#endif
        iaux = laux
ccc        call efnatt ( idfmed, nomamd, iaux, jaux, codre1 )
        call mfanfg ( idfmed, nomamd, iaux, kaux, codret )
ccc        write (ulsort,90002) 'natt ', jaux
ccc        write (ulsort,90002) 'ngro ', kaux
c
        endif
c
        if ( codret.eq.0 ) then
c
        ngrmax = max ( ngrmax, kaux )
c
        endif
c
  320 continue
c
      endif
ccc      write (ulsort,90002) 'nbfmed', nbfmed
ccc      write (ulsort,90002) 'ngrmax', ngrmax
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
