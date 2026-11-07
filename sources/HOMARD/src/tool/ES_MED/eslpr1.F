      subroutine eslpr1 ( idfmed,
     >                    noprof, obprof, nbvapr,
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
c  Entree-Sortie - Lecture d'un PRofil au format MED - phase 1
c  -      -        -            --                           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med en entree       .
c . noprof . e   . char64 . nom du profil a lire                       .
c . obprof .  s  . char*8 . nom de l'objet de type 'Profil' associe    .
c . nbvapr .  s  .   1    . nombre de valeurs du profil                .
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
      parameter ( nompro = 'ESLPR1' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer nbvapr
c
      character*64 noprof
      character*8 obprof
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer adlipr
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
      texte(1,4) = '(''Longueur du profil dans le fichier MED :'')'
c
      texte(2,4) = '(''Profile length in MED file :'')'
c
#include "esimpr.h"
cgn      print *, '. nbcomp = ', nbcomp
cgn      print *, '. typerr = ', typerr
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
#endif
c
c====
c 2. taille du profil a lire
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPSN', nompro
#endif
      call mpfpsn ( idfmed, noprof, nbvapr, codret )
      if ( codret.ne.0 ) then
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,79))
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,62)) nbvapr
#endif
c
      endif
c
c====
c 3. Allocation du profil
c====
c
      if ( codret.eq.0 ) then
c
      call utalpr ( obprof,
     >              nbvapr, noprof,
     >              adlipr,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. Lecture du profil
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRR', nompro
#endif
      call mpfprr ( idfmed, noprof, imem(adlipr), codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,obprof)
      call gmprsx (nompro,obprof//'.NomProfi')
      call gmprsx (nompro,obprof//'.ListEnti')
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
