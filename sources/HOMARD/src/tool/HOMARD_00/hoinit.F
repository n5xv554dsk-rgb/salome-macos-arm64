      subroutine hoinit ( nfconf, lfconf, langue, codret )
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
c       HOMARD : INITialisation
c       --       ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur du nom du fichier                 .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 2x : probleme dans les memoires            .
c .        .     .        . 3x : probleme dans les fichiers            .
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
      parameter ( nompro = 'HOINIT' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*(*) nfconf
c
      integer lfconf, langue, codret
c
c 0.4. ==> variables locales
c
      integer ulsort
      integer iaux
      integer nblims
c
      integer nbrmes
      parameter ( nbrmes = 10 )
      character*40 messag(nblang,nbrmes)
c
#include "mesutp.h"
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
      ulsort = 6
      if ( langue.le.0 .or. langue.gt.nblang ) then
        langue = 1
      endif
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Appel de UTMESS par ', nompro
#endif
      call utmess ( messag, nbmess, nblims,
     >              ulsort, langue, codret )
c
c 1.2. ==> les utilitaires
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (*,*) 'Appel de UTINIT par ', nompro
#endif
      call utinit ( nfconf, lfconf, messag, nblims,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      endif
c
c====
c 2. mesures de temps de calcul
c====
c
      if ( codret.eq.0 ) then
c
      do 20 , iaux = 1 , nbsect
        numsec (iaux) = 0
   20 continue
c
#include "hotits.h"
c
      endif
c
c====
c 3. pretraitements
c====
c
c 3.1. ==> les options du traitement
c
      if ( codret.eq.0 ) then
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTINDH', nompro
#endif
      call utindh ( iaux, ulsort, langue, codret )
c
      endif
c
c 3.2. ==> les communs constants
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTINCG', nompro
#endif
      call utincg
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTINCI', nompro
#endif
      call utinci ( ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTINCA', nompro
#endif
      call utinca
c
      endif
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
