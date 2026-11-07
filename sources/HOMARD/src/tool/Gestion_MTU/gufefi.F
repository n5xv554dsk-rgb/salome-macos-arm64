      subroutine gufefi ( fichie, lfichi, codret )
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
c  Gestionnaire des Unites logiques - FErmeture d'un FIchier
c  -                -                 --             --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . fichie . e   . ch<200 . nom du fichier a fermer                    .
c . lfichi . e   .    1   . longueur du nom du fichier a fermer        .
c . codret .  s  .    1   . 0  : tout va bien                          .
c .        .     .        . 3  : pas d'unite logique pour ce fichier   .
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
      parameter ( nompro = 'GUFEFI' )
c
#include "genbla.h"
#include "gunbul.h"
#include "gulggt.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer lfichi, codret
c
      character*(*) fichie
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
c
      integer nuroul
c
      integer ulsort, langue
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
c 1. messages
c====
c
#include "impr01.h"
c
      texte(1,10) = '(''Fermeture du fichier :'')'
      texte(1,4) = '(''Impossible de trouver une UL associee.'')'
      texte(1,5) =
     > '(''Unite logique : '',i4,'' - fermeture impossible'')'
      texte(1,6) =
     > '(''Attention: longueur du nom : '',i4,'' caracteres'')'
c
      texte(2,10) = '(''Closing of file :'')'
      texte(2,4) = '(''LU cannot be found.'')'
      texte(2,5) =
     > '(''Logical unit # : '',i4,'' - impossible to close'')'
      texte(2,6) =
     > '(''Look out: lenght of name : '',i4,'' characters'')'
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
c 3. recherche de l'unite logique associee a ce fichier
c====
c
      call gucara ( fichie, lfichi, nuroul, codret )
c
      if ( codret.eq.0 ) then
        if ( nuroul.le.0 ) then
          codret = 3
        else if ( lfichi.le.0 ) then
c
c ce programme ne peut fermer ni l'entree standard, ni la sortie
c standard, ni l'unite logique des messages (fermee par gubila)
c
          codret = 9
        else if ( nuroul.eq.ulsort .or.
     >    nuroul.eq.gunmbr(14) .or. nuroul.eq.gunmbr(15) ) then
          codret = 9
        else
          codret = 0
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
        write (ulsort,texte(langue,10))
        if ( lfichi.gt.0 .and. len(fichie).gt.0 ) then
          write (ulsort,*) fichie(1:min(lfichi,len(fichie)))
          if ( lfichi.le.len(fichie) ) then
            if ( fichie(1:1).eq.' ' .or.
     >           fichie(lfichi:lfichi).eq.' ') then
c
c peut-etre un probleme avec les blancs en debut ou fin de chaine ...
c ( voire chaine toute blanche )
c
              write(ulsort,texte(langue,6)) lfichi
            endif
          endif
        else
          write (ulsort,*)
        endif
        if ( codret.eq.3 ) then
           write (ulsort,texte(langue,4))
        else
           write (ulsort,texte(langue,5)) nuroul
        endif
      endif
c
      end
