      subroutine utcapr ( obprof,
     >                    nbvapr, noprof, adlipr,
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
c    UTilitaire - CAracteristiques d'un PRofil
c    --           --                    --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . obprof . e   . char8  . nom de l'objet profil                      .
c . nbvapr .  s  .   1    . nombre de valeurs                          .
c . noprof .   s . char64 . nom du profil                              .
c . adlipr .   s .   1    . adresse de la liste des entites            .
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
      parameter ( nompro = 'UTCAPR' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      character*8 obprof
      character*64 noprof
c
      integer nbvapr
      integer adlipr
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4
      integer codre0
      integer lgnomp, adnomp
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
      texte(1,4) = '(''Nom du profil : '',a)'
      texte(1,5) = '(''Longueur du nom du profil : '',i10)'
c
      texte(2,4) = '(''Name of the profile : '',a)'
      texte(2,5) = '(''Longueur du nom du profil : '',i10)'
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, obprof )
      call gmprsx (nompro, obprof//'.NomProfi' )
      call gmprot (nompro, obprof//'.ListEnti', 1, 10 )
#endif
c
c====
c 2. caracteristiques du profil
c====
c
      if ( codret.eq.0 ) then
c
      call gmliat ( obprof, 1, lgnomp, codre1 )
      call gmliat ( obprof, 2, nbvapr, codre2 )
      call gmadoj ( obprof//'.NomProfi', adnomp, iaux, codre3 )
      call gmadoj ( obprof//'.ListEnti', adlipr, iaux, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 3. le nom du profil
c====
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) lgnomp
#endif
c
      if ( lgnomp.gt.0 ) then
c
        call uts8ch ( smem(adnomp), lgnomp, noprof,
     >                ulsort, langue, codret )
c
      else
c
        noprof = blan64
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) noprof
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
