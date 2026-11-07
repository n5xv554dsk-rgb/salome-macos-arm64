      subroutine utcapg ( oblopg,
     >                    nolopg, typgeo, ngauss, dimcpg,
     >                    adcono, adcopg, adpopg,
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
c    UTilitaire - CAracteristiques de localisation des Points de Gauss
c    --           --                                   -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . oblopg . e   . char8  . nom de l'objet points de Gauss             .
c . nolopg .   s . char64 . nom de la localisation des Points de Gauss .
c . typgeo .   s .   1    . type geometrique au sens MED               .
c . ngauss .   s .   1    . nombre de points de Gauss                  .
c . dimcpg .   s .   1    . dimension des coordonnees des pts de Gauss .
c . adcono .   s .   1    . adresse des coordonnees des noeuds         .
c . adcopg .   s .   1    . adresse des coordonnees des points de Gauss.
c . adpopg .   s .   1    . adresse des poids des points de Gauss      .
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
      parameter ( nompro = 'UTCAPG' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#ifdef _DEBUG_HOMARD_
#include "gmreel.h"
#endif
#include "gmstri.h"
#include "indefs.h"
c
c 0.3. ==> arguments
c
      character*8 oblopg
      character*64 nolopg
c
      integer typgeo, ngauss, dimcpg
      integer adcono, adcopg, adpopg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
      integer codre1, codre2, codre3, codre4
      integer codre0
      integer lgnoml, adnoml
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nom de la localisation : '',a)'
      texte(1,5) = '(/,''Objet GM de la localisation : '',a)'
c
      texte(2,4) = '(''Name of the localization : '',a)'
      texte(2,5) = '(/,''GM object for localization : '',a)'
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, oblopg )
      call gmprsx (nompro, oblopg//'.NomLocPG' )
      call gmprsx (nompro, oblopg//'.CoorNoeu' )
      call gmprsx (nompro, oblopg//'.CoorPtGa' )
      call gmprsx (nompro, oblopg//'.PoidPtGa' )
#endif
c
c====
c 2. caracteristiques de la localisation
c====
c
      if ( codret.eq.0 ) then
c
      call gmliat ( oblopg, 1, lgnoml, codre1 )
      call gmliat ( oblopg, 2, typgeo, codre2 )
      call gmliat ( oblopg, 3, ngauss, codre3 )
      call gmliat ( oblopg, 4, dimcpg, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      if ( codret.ne.0 ) then
      write (ulsort,texte(langue,5)) oblopg
      if ( oblopg.ne.sindef ) then
        call gmprsx (nompro, oblopg )
      endif
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( oblopg//'.NomLocPG', adnoml, iaux, codre1 )
      call gmadoj ( oblopg//'.CoorNoeu', adcono, iaux, codre2 )
      call gmadoj ( oblopg//'.CoorPtGa', adcopg, iaux, codre3 )
      call gmadoj ( oblopg//'.PoidPtGa', adpopg, iaux, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 3. le nom de la localisation
c====
c
      if ( codret.eq.0 ) then
c
      if ( lgnoml.gt.0 ) then
c
        call uts8ch ( smem(adnoml), lgnoml, nolopg,
     >                ulsort, langue, codret )
c
      else
c
        nolopg = blan64
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,4)) nolopg
      iaux = mod(typgeo,100)
      call utimpg ( 2, ngauss, iaux, dimcpg,
     >              rmem(adcono), rmem(adcopg), rmem(1),
     >              ulsort, langue, codret )
      endif
#endif
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
