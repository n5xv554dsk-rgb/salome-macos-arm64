      subroutine gurbbu ( nuroul, codret )
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
c but : rembobinage d'une unite logique particuliere
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nuroul . e   .    1   . numero de l'unite a rembobiner             .
c . codret .  s  .    1   . 0 : tout va bien                           .
c .        .     .        . 3 : rembobinage impossible                 .
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
      parameter ( nompro = 'GURBBU' )
c
#include "genbla.h"
c
#include "gunbul.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer nuroul
      integer codret
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
c
#include "gulggt.h"
c
      integer ulsort, langue
      integer typarr
c
      integer guimp, raison
      integer ios, code
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
c
      character*200 nomfic(mbmxul)
c
      integer nbmess
      parameter ( nbmess = 3 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
c===
c 1. recuperation de l'information
c===
c
#include "impr01.h"
c
      code = 1
      call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
      ulsort = gunmbr(16)
      langue = gunmbr(17)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 2. rembobinage proprement dit
c===
c
      if ( nuroul.gt.0 .and. nuroul.le.mbmxul ) then
c
        if ( statut(nuroul).eq.3 .or. statut(nuroul).eq.4 ) then
c
          codret = 0
c
          rewind ( unit=nuroul, iostat=ios, err=20 )
c
        else
          ios = 1
        endif
c
      else
        ios = 1
      endif
c
   20 continue
c
      if ( ios.ne.0 ) then
c
        typarr = gunmbr(18)
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,20000) nuroul, ios
c
        codret = 3
        if ( typarr.eq.0 ) then
          guimp = 1
          raison = 1
          call gustop ( nompro, ulsort, guimp, raison )
        endif
      endif
c
20000 format(
     > 'Impossible de rembobiner l''unite logique ',i7,
     >/'Code d''erreur retourne par rewind : ',i7,//)
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
      endif
c
      end
