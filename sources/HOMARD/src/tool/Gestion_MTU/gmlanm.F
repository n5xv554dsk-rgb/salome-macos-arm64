      subroutine gmlanm ( lang )
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
c    'Gestion de la Memoire : LANgue des Messages'
c     -             -         ---        -
c ______________________________________________________________________
c
c but : modifie le numero de l'unite logique des messages du
c       gestionnaire de memoire
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lang   . e   .   1    . code de la langue souhaitee                .
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
      character*6 nompro
      parameter ( nompro = 'GMLANM' )
c
c
#include "genbla.h"
c
c 0.2. ==> communs
c
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      integer lang
c
c 0.4. ==> variables locales
c
      logical dejavu
c
      integer guimp, gmimp, raison
      integer lgimpr, ulimpr
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data dejavu / .false. /
c ______________________________________________________________________
c
c====
c 1. initialisation des messages
c    remarque : on doit faire qqe chose pour prevenir des cas ou le
c               numero de l'unite logique ou de la langue serait nul.
c====
c
      if ( ulsort.gt.0 ) then
        ulimpr = ulsort
      else
        call gusost ( ulimpr )
      endif
c
      if ( dejavu ) then
        lgimpr = langue
      else
        lgimpr = 1
      endif
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulimpr,texte(lgimpr,1)) nompro
#endif
c
      texte(1,10) = '(1x,''Le numero de langue '',i2,'' voulu'')'
      texte(1,4) = '(1x,''pour les sorties GM est incorrect.'')'
      texte(1,5) = '(1x,''Il doit etre compris entre 1 et '',i8)'
c
      texte(2,10) = '(1x,''The language code # '',i2,'' wanted for'')'
      texte(2,4) = '(1x,''GM messages is not correct.'')'
      texte(2,5) = '(1x,''It must be included between 1 and '',i8)'
c
c====
c 2. verification de la validite du numero.
c    Il faut que le numero soit compris entre 1 et le nombre maximal
c    de langue.
c====
c
      if ( lang.lt.1 .or. lang.gt.nblang ) then
c
         write (ulimpr,texte(lgimpr,1))
         write (ulimpr,texte(lgimpr,10)) lang
         write (ulimpr,texte(lgimpr,4))
         write (ulimpr,texte(lgimpr,5)) nblang
c
         guimp = 1
         gmimp = 1
         raison = 1
         call ugstop (nompro,ulimpr,guimp, gmimp, raison)
c
      endif
c
c====
c 3. archivage du numero
c====
c
      langue = lang
c
      dejavu = .true.
c
      end
