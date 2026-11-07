      subroutine gmmess (ulmess)
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
c    'Gestion de la Memoire : unite de sortie des MESSages'
c     -             -                             ----
c ______________________________________________________________________
c
c but : modifie le numero de l'unite logique des messages du
c       gestionnaire de memoire
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ulmess . e   .   1    . unite logique voulue pour les messages     .
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
      parameter ( nompro = 'GMMESS' )
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
      integer ulmess
c
c 0.4. ==> variables locales
c
      logical imprim, dejavu
c
      integer lgimpr, ulimpr
c
      integer guimp, gmimp, raison
      integer codret
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
      if ( dejavu ) then
        ulimpr = ulsort
      else
        call gusost ( ulimpr )
      endif
c
      if ( langue.le.0 ) then
        lgimpr = 1
      else
        lgimpr = langue
      endif
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulimpr,texte(lgimpr,1)) nompro
#endif
c
      texte(1,10) = '(''Le numero d''''unite logique '',i2,'' voulu'')'
      texte(1,4) =
     >'(''pour les sorties GM n''''a pas le bon statut GU.'')'
c
      texte(2,10) = '(''The logical unit # '',i2,'' wanted for'')'
      texte(2,4) = '(''GM messages has not the right status in GU.'')'
c
c====
c 2. verification de la validite du numero. il faut que le statut soit :
c    2 : Sortie standard (sequentiel formate)
c    3 : Ouvert en acces sequentiel formate
c====
c
      imprim = .false.
      call guinfu ( ulmess, codret, imprim )
c
      if ( codret.ne.2 .and. codret.ne.3 ) then
c
        write (ulimpr,texte(lgimpr,1)) nompro
        write (ulimpr,texte(lgimpr,10)) ulmess
        write (ulimpr,texte(lgimpr,4))
c
        guimp = 1
        gmimp = 1
        raison = 1
        call ugstop(nompro,ulimpr,guimp, gmimp, raison)
c
      endif
c
c====
c 3. archivage du numero
c====
c
      ulsort = ulmess
c
      dejavu = .true.
c
      end
