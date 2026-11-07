      subroutine eslsmd ( nocson, nochso,
     >                    messin, option,
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
c  Entree-Sortie - Lecture d'une Solution au format MeD
c  -      -        -             -                  - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocson .   s . char*8 . nom de l'objet solution calcul iteration n .
c . nochso . e   . char*8 . nom des champs de solution a lire          .
c .        .     .        . si la chaine est blanche, on lit tout      .
c . messin . e   .   1    . message d'informations                     .
c .        .     .        . impressions MED si multiple de 3           .
c . option . e   .   1    . 1 : on controle que l'on a les couples (aux.
c .        .     .        . noeuds par element/aux points de Gauss)    .
c .        .     .        . 0 : pas de controle                        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .        .     .        . -1 : fichier inconnu                       .
c .        .     .        . -2 : nom de maillage inconnu               .
c ______________________________________________________________________
c
c  HOAPLS --> ESLSMD
c /ININFM
c  ESLSMD -> ESLSM0 -> ESOUVL -> ESVERI -> MFICOM
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
      parameter ( nompro = 'ESLSMD' )
c
#include "nblang.h"
c
#include "motcle.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      character*8 nocson, nochso
c
      integer messin, option
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lnomfi, lnomam
      integer nbseal, nbtosv
      integer adcact, adcaet, adcart
c
      character*8 typobs
      character*64 nomamd
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
#include "esimpr.h"
c
c 1.2. ==> nom du fichier contenant la solution
c
      typobs = mccson
      iaux = 0
      jaux = 0
      call utfino ( typobs, iaux, nomfic, lnomfi,
     >              jaux,
     >              ulsort, langue, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,8)) 'en entree'
        codret = -1
      endif
c
c 1.3. ==> nom du maillage dans ce fichier
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
          codret = -2
        endif
      endif
c
      endif
c
c====
c 2. liste des champs a lire
c    si nbseal = -1, on lira tous les champs du fichier
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. liste des champs a lire ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '... Debut de 2., codret',codret
      write (ulsort,*) '... Debut de 2., nochso =',nochso
      if ( nochso.ne.blan08 ) then
        write (ulsort,*) '... Champs a lire :'
cgn        call gmprsx (nompro,nochso)
        call gmprsx (nompro, nochso//'.CarCaChp' )
        call gmprsx (nompro, nochso//'.CarEnChp' )
        call gmprsx (nompro, nochso//'.CarReChp' )
      endif
      write (ulsort,texte(langue,3)) 'ESLSCH', nompro
#endif
      call eslsch ( nochso,
     >              nbseal, adcact, adcaet, adcart,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Etape 2, nbseal', nbseal
#endif
c
c====
c 3. lecture vraie
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. lecture vraie ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSM0', nompro
#endif
      call eslsm0 ( nocson, nomfic, lnomfi,
     >              nomamd, lnomam,
     >              nbseal, nbtosv,
     >              smem(adcact), imem(adcaet), rmem(adcart),
     >              messin, option,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,111)) nbtosv
      call gmprsx (nompro, nocson)
      call gmprsx (nompro, nocson//'.InfoCham')
      call gmprsx (nompro, nocson//'.InfoPaFo')
      call gmprsx (nompro, nocson//'.InfoProf')
      call gmprsx (nompro, nocson//'.InfoLoPG')
      call gmprsx (nompro, '%%%%%%%7')
      call gmprsx (nompro, '%%%%%%%9')
      call gmprsx (nompro, '%%Fo002o')
      call gmprsx (nompro, '%%%%%%%8')
      call gmprsx (nompro, '%%%%%%%8.InfoCham')
      call gmprsx (nompro, '%%%%%%%8.InfoPrPG')
      call gmprsx (nompro, '%%%%%%%8.ValeursR')
      endif
#endif
c
c====
c 4. message si on n'a pas trouve les champs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. message ; codret', codret
#endif
c
      if ( codret.ne.0 ) then
c
      iaux = codret
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLSC1', nompro
#endif
      call eslsc1 ( nomfic, lnomfi,
     >              messin,
     >              ulsort, langue, codret )
c
      codret = iaux
c
      endif
c
c====
c 5. menage
c====
c
      if ( codret.eq.0 ) then
c
      if ( nochso.ne.blan08 ) then
c
        call gmsgoj (nochso, codret)
c
      endif
c
      endif
c
c====
c 6. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      if ( codret.ne.-1 ) then
        write (ulsort,texte(langue,8)) nomfic
      endif
      if ( codret.gt.0 ) then
        write (ulsort,texte(langue,22)) nomamd
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
