      subroutine esveri ( nomfic, messin,
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
c  Entree-Sortie - VERIfication du fichier
c  -      -        ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomfic . e   .   1    . nom du fichier a examiner                  .
c . messin . e   .   1    . message d'informations                     .
c .        .     .        . impressions MED si multiple de 3           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : fichier inexistant                     .
c .        .     .        . 2 : probleme de version HDF du fichier     .
c .        .     .        . 3 : probleme de version MED du fichier     .
c .        .     .        . 4 : impossible trouver version MED HOMARD  .
c .        .     .        . 5 : impossible trouver version MED fichier .
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
      parameter ( nompro = 'ESVERI' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer messin
c
      character*(*) nomfic
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
      integer*8 idfmed
      integer hdfok, medok
      integer lgvhom, lgvfic
c
      logical old
c
      character*200 verhom, verfic
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
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
#include "esimpr.h"
c
      texte(1,4) = '(''Fichier : '',a)'
      texte(1,11) = '(''Ce fichier n''''existe pas.'')'
      texte(1,12) = '(''La version HDF est incompatible.'')'
      texte(1,13) = '(''La version MED est incompatible.'')'
      texte(1,14) =
     > '(''Impossible de trouver la bibliotheque MED de HOMARD.'')'
      texte(1,15) =
     > '(''Impossible de trouver la bibliotheque MED du fichier.'')'
      texte(1,16) = '(''Impossible de fermer le fichier.'')'
c
      texte(2,4) = '(''File: '',a)'
      texte(2,11) = '(''This file does not exist.'')'
      texte(2,12) = '(''HDF release is uncorrect.'')'
      texte(2,13) = '(''MED release is uncorrect.'')'
      texte(2,14) = '(''MED library for HOMARD cannot be found.'')'
      texte(2,15) = '(''MED library for file cannot be found.'')'
      texte(2,16) = '(''The file cannot be closed.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomfic
#endif
c
c====
c 2. verifications
c====
c
      codret = 0
c
c 2.1. ==> Existence
c
      if ( codret.eq.0 ) then
c
      inquire ( file = nomfic, exist = old )
      if ( .not.old ) then
        codret = 1
      endif
c
      endif
c
c 2.2. ==> Compatibilite du fichier en version HDF et MED
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFICOM', nompro
#endif
      call mficom ( nomfic, hdfok, medok, codret )
      if ( codret.ne.0 ) then
        codret = 1
      endif
      if ( hdfok.ne.1 ) then
        codret = 2
      endif
      if ( medok.ne.1 ) then
        codret = 3
      endif
c
      endif
cgn            print *,codret,hdfok, medok,messin
c
c 2.3. ==> Details
c
      if ( ( codret.eq.0 .and. mod(messin,3).eq.0 ) .or.
     >       codret.eq.2 .or.
     >       codret.eq.3 ) then
c
c 2.4.1. ==> versions de la bibliotheque MED utilisee par HOMARD
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MLBSTV', nompro
#endif
      call mlbstv ( verhom, iaux )
c
      if ( iaux.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLGUT', nompro
#endif
        call utlgut ( lgvhom, verhom,
     >                ulsort, langue, iaux )
        if ( iaux.eq.0 ) then
          write (ulsort,texte(langue,46)) 'HOMARD', verhom(1:lgvhom)
        else
          codret = 4
        endif
      else
        codret = 4
      endif
c
c 2.4.2. ==> versions de la bibliotheque MED du fichier
c
      if ( iaux.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFIOPE', nompro
#endif
      call mfiope ( idfmed, nomfic, edlect, iaux )
      if ( iaux.ne.0 ) then
        codret = 5
      endif
      endif
c
      if ( iaux.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFISVR', nompro
#endif
      call mfisvr ( idfmed, verfic, iaux )
      if ( iaux.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTLGUT', nompro
#endif
        call utlgut ( lgvfic, verfic,
     >                ulsort, langue, iaux )
        if ( iaux.eq.0 ) then
          write (ulsort,texte(langue,46)) nomfic, verfic(1:lgvfic)
        else
          codret = 5
        endif
      else
        codret = 5
      endif
      endif
c
      if ( iaux.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFICLO', nompro
#endif
      call mficlo ( idfmed, iaux )
      if ( iaux.ne.0 ) then
        codret = 6
      endif
      endif
c
      endif
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
      write (ulsort,texte(langue,8)) nomfic
      write (ulsort,texte(langue,codret+10))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
