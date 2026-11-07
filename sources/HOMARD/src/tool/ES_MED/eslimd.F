      subroutine eslimd ( nocind,
     >                    numdt, numit, instan,
     >                    yandt, yanrd, yains,
     >                    messin,
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
c  Entree-Sortie - Lecture de l'Indicateur au format MED
c  -      -        -            -                    - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocind .  s  . char*8 . nom de l'objet indicateur d'erreur calcul  .
c . numdt  . e   .   1    . numero du pas de temps eventuel            .
c . numit  . e   .   1    . numero d'ordre eventuel                    .
c . instan . e   .   1    . instant eventuel                           .
c . yandt  . e   .   1    . 2, on prend le dernier pas de temps        .
c .        .     .        . 1, le numero du pas de temps est fourni    .
c .        .     .        . 0, sinon                                   .
c . yanrd  . e   .   1    . 2, on prend le dernier numero d'ordre      .
c .        .     .        . 1, le numero d'ordre est fourni            .
c .        .     .        . 0, sinon                                   .
c . yains  . e   .   1    . 2, on prend le dernier instant             .
c .        .     .        . 1, l'instant est fourni                    .
c .        .     .        . 0, sinon                                   .
c . messin . e   .   1    . message d'informations                     .
c .        .     .        . impressions MED si multiple de 3           .
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
c .        .     .        . -1 : probleme avec le nom du champ         .
c .        .     .        . -2 : probleme avec le nom de la composante .
c .        .     .        . -3 : probleme avec le nom du maillage      .
c ______________________________________________________________________
c
c  HOAVLI --> ESLIMD --> ESLSM0
c        -> ESLSM0 -> ESOUVL -> ESVERI -> MFICOM
c                                       -> MLBSTV
c                                       -> MFIOPE
c                                       -> MFISVR
c                                       -> MFICLO
c                             -> MFIOPE
c                             -> ESLENT -> MFICOR
c                   -> ESLNOM -> MMHNMH
c                             -> MMHMII
c                   -> MFDNFD
c                   -> MLCNLC
c                   -> ESLSM1 -> MFDNFC
c                             -> MFDFDI
c                             -> ESLCH1 -> ESLCH2 -> MFDCSI
c                                       -> MFDNPF
c                                       -> ESLPR1 -> MPFPSN
c                                                 -> MPFPRR
c                                       -> ESLPG1 -> ESLPG2 -> MLCNLC
c                                                           -> MLCLCI
c                                                 -> MLCLOR
c                                       -> MFDNPN
c                             -> ESLCH6
c                   -> ESLSM2 -> ESLCH3
c                             -> ESLCH7
c                   -> ESLSM3
c                   -> ESLSM4 -> ESLCH4 -> MFDRPR
c                                       -> ESLCH5
c                   -> ESLSM5
c         -> MFICLO
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
      parameter ( nompro = 'ESLIMD' )
c
#include "nblang.h"
#include "consts.h"
c
#include "motcle.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"

c 0.3. ==> arguments
c
      integer numdt, numit, yandt, yanrd,yains
      double precision instan
c
      character*8 nocind
c
      integer messin
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codre0
      integer codre1, codre2, codre3
      integer adcact, adcaet, adcart
      integer nbseal, nbtosv
c
      integer lnomfi
      integer lnocin, lnomam
c
      character*8 typobs
      character*8 ntrav1, ntrav2, ntrav3
      character*64 nomamd
      character*64 nochin
      character*64 saux64
      character*200 nomfic
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
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
     >'(''Probleme pour allouer l''''objet indicateur.'')'
      texte(1,5) = '(''Mot-cle : '',a8)'
      texte(1,6) = '(''Le nom du champ indicateur est inconnu.'')'
      texte(1,7) =
     > '(''La composante du champ indicateur est inconnue.'')'
c
      texte(2,4) ='(''Problem while allocating the indicator object.'')'
      texte(2,5) = '(''Keyword : '',a8)'
      texte(2,6) = '(''The name of the indicator field is unknown.'')'
      texte(2,7) =
     >'(''The name of the indicator field component is unknown.'')'
c
#include "impr03.h"
c
#include "esimpr.h"
c
c====
c 2. premiers decodages
c====
c
c 2.1. ==> nom du fichier contenant l'indicateur
c
      typobs = mccind
      iaux = 0
      jaux = 1
      call utfino ( typobs, iaux, nomfic, lnomfi,
     >              jaux,
     >              ulsort, langue, codret )
c
c 2.2. ==> nom du maillage dans ce fichier
c
      if ( codret.eq.0 ) then
c
      typobs = mccnmn
      iaux = 0
      jaux = 0
      call utfino ( typobs, iaux, nomamd, lnomam,
     >              jaux,
     >              ulsort, langue, codret )
      if ( codret.ne.0 ) then
        call utosme ( typobs, ulsort, langue )
        if ( codret.eq.4 ) then
          write (ulsort,texte(langue,52)) lnomam
          write (ulsort,texte(langue,53)) len(nomamd)
          codret = -3
        endif
      endif
c
      endif
c
c 2.3. ==> recherche des caracteristiques de l'indicateur
c          si le nom de l'indicateur est absent, ... probleme
c
c 2.3.1. ==> nom du champ
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3.2. nom du champ ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      typobs = mccnin
      iaux = 0
      jaux = 0
      call utfino ( typobs, iaux, nochin, lnocin,
     >              jaux,
     >              ulsort, langue, codret )
c
      if ( codret.eq.2 ) then
        codret = -1
        write (ulsort,texte(langue,5)) typobs
        write (ulsort,texte(langue,6))
      endif
c
      endif
c
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,32)) nochin(1:lnocin)
      endif
c
c====
c 3. mise en forme du tableau a lire
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. mise en forme ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbseal = 1
c
      iaux = 8*nbseal
      call gmalot ( ntrav1, 'chaine  ', iaux, adcact, codre1 )
      iaux = 12*nbseal
      call gmalot ( ntrav2, 'entier  ', iaux, adcaet, codre2 )
      iaux = 1*nbseal
      call gmalot ( ntrav3, 'reel    ', iaux, adcart, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      saux64 = blan64
      iaux = 64
c
      call utchs8 ( saux64, iaux, smem(adcact),
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call utchs8 ( nochin, lnocin, smem(adcact),
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'yandt', yandt
      write (ulsort,90002) 'yanrd', yanrd
      write (ulsort,90002) 'yains', yains
#endif
      imem(adcaet+0) = -1
      imem(adcaet+1) = yandt
      if ( yandt.eq.1 ) then
        imem(adcaet+2) = numdt
        write (ulsort,texte(langue,113)) numdt
      elseif ( yandt.eq.2 ) then
        write (ulsort,texte(langue,93))
      endif
      imem(adcaet+3) = yanrd
      if ( yanrd.eq.1 ) then
        imem(adcaet+4) = numit
        write (ulsort,texte(langue,114)) numit
cgn      elseif ( yanrd.eq.2 ) then
cgn        write (ulsort,texte(langue,94))
      endif
      imem(adcaet+5) = yains
      if ( yains.eq.1 ) then
        rmem(adcart) = instan
        write (ulsort,texte(langue,115)) instan
      elseif ( yains.eq.2 ) then
        write (ulsort,texte(langue,95))
      endif
      imem(adcaet+6) = -1
      imem(adcaet+9) = 0
c
      endif
c
c====
c 4. lecture
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. lecture ; codret', codret
#endif
c
c 4.1. ==> lecture MED
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSM0', nompro
#endif
c
      iaux = 0
      call eslsm0 ( nocind, nomfic, lnomfi,
     >              nomamd, lnomam,
     >              nbseal, nbtosv,
     >              smem(adcact), imem(adcaet), rmem(adcart),
     >              messin, iaux,
     >              ulsort, langue, codret )
c
      endif
c
c 4.2. ==> on controle qu'il y a bien au moins un tableau
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nocind )
      call gmprsx (nompro, nocind//'.InfoPaFo' )
      call gmprsx (nompro, '%%%%%%13' )
      call gmprsx (nompro, nocind//'.InfoCham' )
      call gmprsx (nompro, '%%%%%%11' )
      call gmprsx (nompro, '%%%%%%11.Nom_Comp' )
      call gmprsx (nompro, '%%%%%%11.Cham_Ent' )
      call gmprsx (nompro, '%%%%%%11.Cham_Ree' )
      call gmprsx (nompro, '%%%%%%11.Cham_Car' )
      call gmprsx (nompro, '%%%%%%12' )
      call gmprsx (nompro, '%%%%%%12.ValeursR' )
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,111)) nbtosv
#endif
c
      if ( nbtosv.eq.0 ) then
c
      write (ulsort,texte(langue,96)) nomamd
      if ( yandt.eq.1 ) then
        write (ulsort,texte(langue,113)) numdt
      endif
      if ( yanrd.eq.1 ) then
        write (ulsort,texte(langue,114)) numit
      endif
      if ( yains.eq.1 ) then
        write (ulsort,texte(langue,115)) instan
      endif
      write (ulsort,texte(langue,70))
      write (ulsort,texte(langue,71))
      write (ulsort,texte(langue,72))
      write (ulsort,texte(langue,73))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSC1', nompro
#endif
      call eslsc1 ( nomfic, lnomfi,
     >              messin,
     >              ulsort, langue, codret )
c
      codret = 2
c
      endif
c
      endif
c
c 4.3. ==> Menage
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
      call gmlboj ( ntrav3, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
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
      write (ulsort,texte(langue,8)) nomfic
      if ( codret.gt.0 .or. codret.eq.-2 ) then
        write (ulsort,texte(langue,32)) nochin
      endif
      if ( codret.gt.0 ) then
        if ( yandt.eq.1 ) then
          write (ulsort,texte(langue,113)) numdt
        elseif ( yandt.eq.2 ) then
        write (ulsort,texte(langue,93))
        endif
        if ( yanrd.eq.1 ) then
          write (ulsort,texte(langue,114)) numit
        endif
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
