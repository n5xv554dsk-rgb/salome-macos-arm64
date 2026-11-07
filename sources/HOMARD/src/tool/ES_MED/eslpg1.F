      subroutine eslpg1 ( idfmed,
     >                    nolopg, oblopg,
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
c  Entree-Sortie - Lecture des localisations des Points de Gauss
c  -      -        -                             -         -
c                  au format MED - phase 1
c                                        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med                 .
c . nolopg . e   . char64 . nom de la localisation a lire              .
c . oblopg .  s  . char*8 . nom de l'objet de type 'LocaPG' associe    .
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
      parameter ( nompro = 'ESLPG1' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmreel.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
c
      character*8 oblopg
      character*64 nolopg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
c
      integer typgeo, ngauss, dimcpg
      integer adcono, adcopg, adpopg
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
      texte(1,4) = '(''Points de Gauss dans le fichier MED :'')'
      texte(1,5) = '(/,''Lecture de la localisation '',a)'
c
      texte(2,4) = '(''Gauss points in MED file :'')'
      texte(2,5) = '(/,''Readings of localization '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nolopg
#endif
c
#include "esimpr.h"
c
c====
c 2. caracterisation de la localisation a lire
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLPG2', nompro
#endif
c
      call eslpg2 ( idfmed,
     >              nolopg, typgeo, ngauss, dimcpg,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,81)) nolopg
      write (ulsort,texte(langue,64)) typgeo
      write (ulsort,texte(langue,57)) ngauss
#endif
c
      endif
c
c====
c 3. Allocation de la localisation
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALPG', nompro
#endif
c
      call utalpg ( oblopg,
     >              nolopg, typgeo, ngauss, dimcpg,
     >              adcono, adcopg, adpopg,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. Lecture de la localisation
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MLCLOR', nompro
#endif
      call mlclor ( idfmed, nolopg, edfuin,
     >              rmem(adcono), rmem(adcopg), rmem(adpopg),
     >              codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nolopg
      iaux = mod(typgeo,100)
      jaux = (typgeo-iaux) / 100
      call utimpg ( 2, ngauss, iaux, jaux,
     >              rmem(adcono), rmem(adcopg), rmem(1),
     >              ulsort, langue, codret )
#endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, oblopg )
      call gmprsx (nompro, oblopg//'.NomLocPG' )
      call gmprsx (nompro, oblopg//'.CoorNoeu' )
      call gmprsx (nompro, oblopg//'.CoorPtGa' )
      call gmprsx (nompro, oblopg//'.PoidPtGa' )
#endif
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
