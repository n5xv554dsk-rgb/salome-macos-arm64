      subroutine utalpg ( oblopg,
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
c    UTilitaire - ALlocation de la localisation des Points de Gauss
c    --           --                                -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . oblopg .   s . char8  . nom de l'objet points de Gauss             .
c . nolopg . e   . char64 . nom de la localisation des Points de Gauss .
c . typgeo . e   .   1    . type geometrique au sens MED               .
c . ngauss . e   .   1    . nombre de points de Gauss                  .
c . dimcpg . e   .   1    . dimension des coordonnees des pts de Gauss .
c . adcono .   s .   1    . adresse des coordonnees des noeuds         .
c . adcopg .   s .   1    . adresse des coordonnees des points de Gauss.
c . adpopg .   s .   1    . adresse des poids des points de Gauss      .
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
      parameter ( nompro = 'UTALPG' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmstri.h"
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
      integer codre1, codre2, codre3, codre4
      integer codre0
      integer lgnoml, adnoml
      integer nbnoeu
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
c
      texte(2,4) = '(''Name of the localization : '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nolopg
#endif
c
c====
c 2. les caracteristiques de cette localisation
c====
c
      if ( codret.eq.0 ) then
c
      call utlgut ( lgnoml, nolopg,
     >              ulsort, langue, codret )
c
      endif
c
      nbnoeu = mod(typgeo,100)
C
c====
c 3. creation de la localisation des points de Gauss
c====
c
c 3.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
      call gmalot ( oblopg, 'LocaPG', 0, iaux, codret )
c
      endif
c
c 3.2. ==> les attributs
c
      if ( codret.eq.0 ) then
c
      call gmecat ( oblopg, 1, lgnoml, codre1 )
      call gmecat ( oblopg, 2, typgeo, codre2 )
      call gmecat ( oblopg, 3, ngauss, codre3 )
      call gmecat ( oblopg, 4, dimcpg, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(lgnoml,8).eq.0 ) then
        iaux = lgnoml/8
      else
        iaux = (lgnoml-mod(lgnoml,8))/8 + 1
      endif
      call gmaloj ( oblopg//'.NomLocPG', ' ', iaux, adnoml, codre1 )
      iaux = nbnoeu*dimcpg
      call gmaloj ( oblopg//'.CoorNoeu', ' ', iaux, adcono, codre2 )
      iaux = ngauss*dimcpg
      call gmaloj ( oblopg//'.CoorPtGa', ' ', iaux, adcopg, codre3 )
      call gmaloj ( oblopg//'.PoidPtGa', ' ', ngauss, adpopg, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c 3.3. ==> memorisation du nom
c
      if ( codret.eq.0 ) then
c
      call utchs8 ( nolopg, lgnoml, smem(adnoml),
     >              ulsort, langue, codret )
c
      endif
c
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, oblopg )
      call gmprsx (nompro, oblopg//'.NomLocPG' )
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
