      subroutine utalpr ( obprof,
     >                    nbvapr, noprof,
     >                    adlipr,
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
c    UTilitaire - ALlocation d'un PRofil
c    --           --              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . obprof .   s . char8  . nom de l'objet profil                      .
c . nbvapr . e   .   1    . nombre de valeurs                          .
c . noprof . e   . char64 . nom du profil                              .
c . adlipr .   s .   1    . adresse de la liste des entites            .
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
      parameter ( nompro = 'UTALPR' )
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
c====
c 2. creation du profil
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
      call gmalot ( obprof, 'Profil', 0, iaux, codret )
c
      endif
c
c 2.2. ==> les caracteristiques de ce profil
c
      if ( codret.eq.0 ) then
c
      call utlgut ( lgnomp, noprof,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( obprof, 1, lgnomp, codre1 )
      call gmecat ( obprof, 2, nbvapr, codre2 )
      if ( mod(lgnomp,8).eq.0 ) then
        iaux = lgnomp/8
      else
        iaux = (lgnomp-mod(lgnomp,8))/8 + 1
      endif
      call gmaloj ( obprof//'.NomProfi', ' ', iaux, adnomp, codre3 )
      call gmaloj ( obprof//'.ListEnti', ' ', nbvapr, adlipr, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c 2.3. ==> memorisation du nom
c
      if ( codret.eq.0 ) then
c
      call utchs8 ( noprof, lgnomp, smem(adnomp),
     >              ulsort, langue, codret )
c
      endif
c
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, obprof )
      call gmprsx (nompro, obprof//'.NomProfi' )
#endif
c
c====
c 3. la fin
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
