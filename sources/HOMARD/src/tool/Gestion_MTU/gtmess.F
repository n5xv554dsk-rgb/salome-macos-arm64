      subroutine gtmess ( ulmess )
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
c                                       premiere creation le 11.12.95 gn
c ______________________________________________________________________
c
c    'Gestion du Temps : unite de sortie des MESSages'
c     -          -                           ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ulmess . e   .    1   . numero de l'unite logique ou imprimer      .
c .        .     .        . les messages du gestionnaire de temps      .
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
      parameter ( nompro = 'GTMESS' )
c
#include "genbla.h"
#include "gtnbse.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer ulmess
c
c 0.4. ==> variables locales
c
#include "gtdita.h"
c
      logical imprim, dejavu
c
      integer guimp, gmimp, raison
      integer codret, ulsort
c
      integer langue
c
      integer iaux, code
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data dejavu / .false. /
      data langue / 1 /
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
c 1.1. ==> initialisation des messages
c
#include "impr01.h"
c
      texte(1,10) = '(''Le numero d''''unite logique '',i2,'' voulu'')'
      texte(1,4) =
     >'(''pour les sorties GT n''''a pas le bon statut GU.'')'
c
      texte(2,10) = '(''The logical unit # '',i2,'' wanted for'')'
      texte(2,4) = '(''GT messages has not the right status in GU.'')'
c
c 1.2. ==> recuperation de l'information
c
      code = 1
      iaux = nbsep1
      call gttabl ( code, iaux, nbrapp, ouvert, titsec, tpscpu )
c
      if ( dejavu ) then
        ulsort = nbrapp(0)
      else
        call gusost ( ulsort )
      endif
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
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        call dmflsh (iaux)
        write (ulsort,texte(langue,10)) ulmess
        write (ulsort,texte(langue,4))
c
        guimp = 1
        gmimp = 0
        raison = 1
        call ugstop(nompro,ulsort,guimp, gmimp, raison)
c
      endif
c
c====
c 3. on archive l'information
c====
c
      nbrapp(0) = ulmess
c
      code = 0
      iaux = nbsep1
      call gttabl ( code, iaux, nbrapp, ouvert, titsec, tpscpu )
c
      dejavu = .true.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
