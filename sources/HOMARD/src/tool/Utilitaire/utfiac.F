      subroutine utfiac ( nfconf, lfconf, ulsort, langue, codret )
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
c  but : acquerir les noms des fichiers et des objets structures
c        concernes par un calcul
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur du nom du fichier                 .
c . ulsort . e   .    1   . unite logique d'impression                 .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour                             .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans l'allocation des tables  .
c .        .     .        . 3 : probleme de decodage des noms          .
c .        .     .        . 5 : deuxieme appel au programme            .
c .        .     .        . 7 : impossible de decoder une variable     .
c .        .     .        .     d'environnement                        .
c .        .     .        . 9 : probleme avec le fichier               .
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
      parameter ( nompro = 'UTFIAC' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      character*(*) nfconf
c
      integer lfconf
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "utliob.h"
c
      integer iaux
      integer adnore, adlono, adpono, adnofi, adnoos, adinsu
      integer nbfich, lgtanf
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8, codre9, codre0
c
      logical prem
c
      character*8 nomaux
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data prem / .true. /
c ______________________________________________________________________
c
c====
c 1.  messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Un seul appel a ce programme est autorise.'')'
      texte(1,5) = '(''Probleme avec le fichier de configuration'')'
      texte(1,6) = '(''Objet '',a8,'' : allocation impossible.'')'
      texte(1,7) = '(''Objet '',a8,'' : remplissage impossible.'')'
c
      texte(2,4) = '(''Only one call to this subroutine is allowed.'')'
      texte(2,5) = '(''Problem with the configuration file'')'
      texte(2,6) = '(''Object '',a8,'' : allocation impossible.'')'
      texte(2,7) = '(''Object '',a8,'' : filling is impossible.'')'
c
c====
c 2.  verification du nombre de passage
c====
c
      if ( prem ) then
        prem = .false.
      else
        write (ulsort,texte(langue,4))
        codret = 5
      endif
c
c====
c 3.  comptage du nombre de fichiers enregistres et de la longueur
c     cumulee de leurs noms
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. comptage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
        codre1 = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFIA1', nompro
#endif
        call utfia1 ( nbfich, lgtanf,
     >                nfconf, lfconf, ulsort, langue, codre1 )
c
        if ( codre1.eq.3 .or. codre1.eq.7 ) then
          codret = codre1
        else if ( codre1.eq.9 ) then
          codret = 9
          write (ulsort,texte(langue,5))
          if ( lfconf.gt.0 .and. len(nfconf).gt.0 ) then
            write (ulsort,*) nfconf(1:min(lfconf,len(nfconf)))
          else
            write (ulsort,*)
          endif
        else
          codret = 0
        endif
c
      endif
c
c====
c 4. allocation de l'objet structure correspondant
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. allocation ; codret = ', codret
#endif
c
      nomaux = osliob
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'nomaux = ', nomaux
      write (ulsort,*) 'nbfich = ', nbfich
      write (ulsort,*) 'lgtanf = ', lgtanf
#endif
c
        call gmaloj ( nomaux, 'FichExec', 0, iaux, codre1 )
c
        call gmecat ( nomaux, 1, nbfich, codre2 )
        call gmecat ( nomaux, 2, lgtanf, codre3 )
c
        call gmaloj ( nomaux//'.NomRefer', ' ', nbfich, adnore, codre4 )
        call gmaloj ( nomaux//'.LongNomF', ' ', nbfich, adlono, codre5 )
        iaux = nbfich + 1
        call gmaloj ( nomaux//'.PosiNomF', ' ', iaux, adpono, codre6 )
        call gmaloj ( nomaux//'.NomUFich', ' ', lgtanf, adnofi, codre7 )
        call gmaloj ( nomaux//'.NomObjSt', ' ', nbfich, adnoos, codre8 )
        call gmaloj ( nomaux//'.InfoSupp', ' ', nbfich, adinsu, codre9 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5, codre6,
     >                 codre7, codre8, codre9 )
        codre0 = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5, codre6,
     >                 codre7, codre8, codre9 )
c
        if ( codre0.ne.0 ) then
          write (ulsort,texte(langue,6)) nomaux
          codret = 2
        endif
c
      endif
c
c====
c 5. Remplissage de la structure
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. remplissage ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
        codre2 = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFIA2', nompro
#endif
        call utfia2 ( nbfich, lgtanf,
     >                smem(adnore), imem(adlono),
     >                imem(adpono), smem(adnofi),
     >                smem(adnoos), smem(adinsu),
     >                nfconf, lfconf, ulsort, langue, codre2 )
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        call gmprsx (nompro,nomaux//'.NomRefer')
        call gmprsx (nompro,nomaux//'.LongNomF')
        call gmprsx (nompro,nomaux//'.PosiNomF')
        call gmprsx (nompro,nomaux//'.NomUFich')
        call gmprsx (nompro,nomaux//'.NomObjSt')
        call gmprsx (nompro,nomaux//'.InfoSupp')
        endif
#endif
c
      endif
c
c====
c 6. fin
c====
c
      if ( codret.eq.0 ) then
        if ( codre1.eq.3 ) then
          codret = 3
        else
          if ( codre2.ne.0 ) then
            write (ulsort,texte(langue,7)) nomaux
            codret = codre2
          endif
        endif
      endif
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
