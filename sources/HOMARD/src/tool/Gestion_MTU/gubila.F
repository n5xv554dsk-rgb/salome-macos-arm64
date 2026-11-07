      subroutine gubila ( codfic )
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
c but : - imprime les statistiques
c       - ferme toutes les unites logiques, sauf l'entree et la sortie
c         standard
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . codfic . e   .    1   . code pilotant le type d'info a imprimer    .
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
#ifdef _DEBUG_HOMARD_
      character*6 nompro
      parameter ( nompro = 'GUBILA' )
#endif
c
#ifdef _DEBUG_HOMARD_
#include "genbla.h"
#endif
c
#include "gunbul.h"
#include "gulggt.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer codfic
c
c 0.4. ==> variables locales
c
      integer ulsort
      integer codref
      integer iaux, jaux, code
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
#ifdef _DEBUG_HOMARD_
      integer langue
#endif
c
      character*200 nomfic(mbmxul)
c
#ifdef _DEBUG_HOMARD_
      integer nbmess
      parameter ( nbmess = 3 )
      character*80 texte(nblang,nbmess)
#endif
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c===
c 1. recuperation de l'information
c===
c
#ifdef _DEBUG_HOMARD_
#include "impr01.h"
#endif
c
      code = 1
      call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
      ulsort = gunmbr(16)
#ifdef _DEBUG_HOMARD_
      langue = gunmbr(17)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c===
c 2. impressions recapitulatives
c===
c
c 2.1. ==> statistiques
c
      call gustat ( gunmbr )
c
c 2.2. ==> etat des lieux au moment de l'appel
c
      if ( codfic.ne.0 ) then
c
        call guinfo
c
      endif
c
c====
c 3. fermeture de toutes les unites logiques, sauf les standard et
c    sauf celle ou sont imprimes les messages du gestionnaire. Elle
c    sera fermee tout a la fin.
c====
c
      do 3  , iaux = 1 , mbmxul
c
        if ( statut(iaux).ge.3 .and. statut(iaux).le.5 .and.
     >       iaux.ne.ulsort ) then
c
          jaux = iaux
          call guferm ( nomfic(iaux), lnomfi(iaux), jaux, codref )
c
        endif
c
    3 continue
c
      if ( ulsort.ge.1 .and. ulsort.le.mbmxul ) then
        if ( statut(ulsort).eq.3 ) then
          call gufeul ( ulsort , codref )
        else if ( statut(ulsort).ne.2 ) then
          codref = 1
        else
          codref = 0
        endif
      else
        codref = 1
      endif
c
      end
