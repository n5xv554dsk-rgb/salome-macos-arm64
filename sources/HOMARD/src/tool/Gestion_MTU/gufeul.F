      subroutine gufeul ( nuroul, codret )
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
c  Gestionnaire des Unites logiques - FErmeture d'une Unite Logique
c  -                -                 --              -     -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nuroul . e   .    1   . numero de l'unite logique a fermer         .
c . codret .  s  .    1   . 0  : tout va bien                          .
c .        .     .        . 3  : pas de fichier pour cette UL          .
c .        .     .        . 9  : probleme a la fermeture               .
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
      parameter ( nompro = 'GUFEUL' )
c
#include "genbla.h"
#include "gunbul.h"
#include "gulggt.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer nuroul, codret
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
c
      integer lfichi
c
      character*200 fichie
c
      integer code
      integer ulsort, langue
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
c
      character*200 nomfic(mbmxul)
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
      texte(1,10) = '(''Fermeture de l''''unite logique : '',i4)'
      texte(1,4) = '(''Impossible de trouver un fichier associe.'')'
      texte(1,5) = '(''Fermeture impossible'')'
c
      texte(2,10) = '(''Closing of logical unit : '',i4)'
      texte(2,4) = '(''File cannot be found.'')'
      texte(2,5) = '(''Impossible to close'')'
c
c===
c 2. recuperation de l'information
c===
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
c 3. recherche du fichier associe a cette UL
c====
c
      call gufiul ( fichie, lfichi , nuroul, codret )
c
      if ( codret.eq.0 ) then
        if ( lfichi.le.0 ) then
          codret = 3
        endif
      endif
c
c====
c 4. fermeture
c====
c
      if ( codret.eq.0 ) then
        call guferm ( fichie, lfichi, nuroul, codret )
        if ( codret.ne.0 ) then
          codret =  9
        endif
      endif
c
c====
c 5. bilan
c====
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
        write (ulsort,texte(langue,10)) nuroul
        if ( codret.eq.3 ) then
           write (ulsort,texte(langue,4))
        else
           write (ulsort,texte(langue,5))
        endif
      endif
c
      end
