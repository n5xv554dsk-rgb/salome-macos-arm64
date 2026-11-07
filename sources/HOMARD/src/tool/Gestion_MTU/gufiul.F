      subroutine gufiul ( fichie, lfichi, nuroul, codret )
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
c but : recuperer le fichier associe a une unite logique
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . fichie .  s  . ch<200 . nom du fichier associe                     .
c . lfichi .  s  .    1   . -1 : on recupere l'unite d'entree standard .
c .        .     .        .  0 : on recupere l'unite de sortie standard.
c .        .     .        . >0 : longueur du nom du fichier a examiner .
c . nuroul . e   .    1   . numero de l'unite logique a examiner       .
c . codret .  s  .    1   . 0  : tout va bien                          .
c .        .     .        . 3 : mauvais numero ou                      .
c .        .     .        . 3 : aucun fichier n'est lie a ce numero    .
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
      parameter ( nompro = 'GUFIUL' )
c
#include "genbla.h"
#include "gunbul.h"
#include "gulggt.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer lfichi, nuroul, codret
      character*(*) fichie
c
c 0.4. ==> variables locales
c
      integer guimp, raison, iaux
      integer code
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
c
      character*200 nomfic(mbmxul)
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
      integer ulsort
      integer langue
      integer typarr
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1.  messages
c====
c
      codret = 0
c
#include "impr01.h"
c
      texte(1,10) = '(''Numero d''''unite logique : '',i4)'
      texte(1,4) = '(''Doit etre compris entre 0 et '',i4)'
      texte(1,5) = '(''N''''a pas ete attribue.'')'
c
      texte(2,10) = '(''Logical unit # : '',i4)'
      texte(2,4) = '(''Must be between 0 and '',i4)'
      texte(2,5) = '(''Never reserved.'')'
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
      typarr = gunmbr(18)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 3. recherche du bon numero
c====
c
      codret = 0
c
      if ( nuroul.le.0 .or. nuroul.gt.mbmxul ) then
c
        lfichi = 0
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,10)) nuroul
        write (ulsort,texte(langue,4)) mbmxul
        if ( typarr.eq.0 ) then
          guimp = 1
          raison = 1
          call gustop ( nompro, ulsort, guimp, raison )
        else
          codret = 3
        endif
c
      else if ( nuroul.eq.gunmbr(14) ) then
c
        lfichi = -1
c
      elseif ( nuroul.eq.gunmbr(15) ) then
c
        lfichi = 0
c
      elseif ( statut(nuroul).ge.1 .and. statut(nuroul).le.6 ) then
c
        lfichi = min(max(0,len(fichie)), max(0,lnomfi(nuroul)))
        if (lfichi.gt.0) then
          fichie(1:lfichi) = nomfic(nuroul)(1:lfichi)
        endif
c
      else
c
        lfichi = 0
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,10)) nuroul
        write (ulsort,texte(langue,5))
        if ( typarr.eq.0 ) then
          guimp = 1
          raison = 1
          call gustop ( nompro, ulsort, guimp, raison )
        else
          codret = 3
        endif
c
      endif
c
      do 3 iaux = max(0,lfichi)+1, len(fichie)
        fichie(iaux:iaux) = ' '
    3 continue
c
      end
