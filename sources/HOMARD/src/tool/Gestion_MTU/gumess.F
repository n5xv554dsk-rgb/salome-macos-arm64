      subroutine gumess (ulmess, codret)
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
c but : modifie le numero de l'unite logique des messages du
c       gestionnaire d'unite logique
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ulmess . e   .   1    . unite logique de la sortie generale        .
c . codret .  s  .    1   . 0 : tout va bien                           .
c .        .     .        . 3 : problemes                              .
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
      parameter ( nompro = 'GUMESS' )
c
#include "genbla.h"
#include "gunbul.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer ulmess
      integer codret
c
c 0.4. ==> variables locales
c
#include "gulggt.h"
c
      logical imprim
c
      integer guimp, gmimp, raison
      integer iaux, ulsort
c
      integer langue
      integer typarr
c
      integer code
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
c
      character*200 nomfic(mbmxul)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
      codret = 0
c
c 1.1. ==> initialisation des messages
c
#include "impr01.h"
c
      texte(1,10) = '(''Le numero d''''unite logique '',i2,'' voulu'')'
      texte(1,4) =
     >'(''pour les sorties GU n''''a pas le bon statut GU.'')'
c
      texte(2,10) = '(''The logical unit # '',i2,'' wanted for'')'
      texte(2,4) = '(''GU messages has not the right status in GU.'')'
c
c 1.2. ==> recuperation de l'information
c
      code = 1
      call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
c     (16): numero de l'unite des messages du gu
      ulsort = gunmbr(16)
c
c     (17): langue des messages du gu
      langue = gunmbr(17)
c
c     (18): type d'arret du gestionnaire
      typarr = gunmbr(18)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 2. verification de la validite du numero. il faut que le statut soit :
c    2 : Sortie standard (sequentiel formate)
c    3 : Ouvert en acces sequentiel formate
c====
c
      imprim = .false.
      call guinfu ( ulmess, iaux, imprim )
c
      if ( iaux.ne.2 .and. iaux.ne.3 ) then
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,10)) ulmess
        write (ulsort,texte(langue,4))
c
        if ( typarr.eq.0 ) then
          guimp = 1
          gmimp = 0
          raison = 1
          call ugstop(nompro,ulsort,guimp, gmimp, raison)
        else
          codret = 3
          write (ulsort,texte(langue,2)) codret
        endif
c
      endif
c
c===
c 3. archivage de l'information
c===
c
      if ( codret.eq.0 ) then
c
c     (16): numero de l'unite des messages du gu
        gunmbr(16) = ulmess
c
        code = 0
        call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
      endif
c
      end
