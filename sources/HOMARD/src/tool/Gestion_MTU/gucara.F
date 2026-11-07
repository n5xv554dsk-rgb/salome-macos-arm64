      subroutine gucara ( fichie, lfichi, nuroul, codret )
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
c but : recuperer l'unite associee a un fichier
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . fichie . e   . ch<200 . nom du fichier a examiner                  .
c . lfichi . e   .    1   . -1 : on recupere l'unite d'entree standard .
c .        .     .        .  0 : on recupere l'unite de sortie standard.
c .        .     .        . >0 : longueur du nom du fichier a examiner .
c . nuroul .  s  .    1   . 0 si le fichier est inconnu, sinon c'est le.
c .        .     .        . numero de l'unite logique attribuee        .
c . codret .  s  .    1   . 0  : tout va bien                          .
c .        .     .        . 3 : nom de fichier trop long               .
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
      parameter ( nompro = 'GUCARA' )
c
#include "gunbul.h"
#include "genbla.h"
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
#include "gulggt.h"
c
      integer guimp, raison
      integer iaux, code
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
c
      character*200 nomfic(mbmxul)
c
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
#include "impr01.h"
c
      texte(1,10) = '(''La longueur du nom vaut'',i4,'' curieux !'')'
      texte(1,4) = '(''Il faut :'')'
      texte(1,5) = '(''-1 pour le numero de l''''entree standard'')'
      texte(1,6) = '(''0, pour le numero de la sortie standard'')'
      texte(1,7) = '(''la vraie longueur du nom (1=<l=<200) sinon.'')'
      texte(1,8) = '(''Ce fichier est inconnu du gestionnaire :'')'
c
      texte(2,10) = '(''The length of the name is'',i4,'' curious!'')'
      texte(2,4) = '(''You need :'')'
      texte(2,5) = '(''-1 for the number of standard input'')'
      texte(2,6) = '(''0, for the number of standard output'')'
      texte(2,7) =
     > '(''the real length of the name (1=<l=<200) if not.'')'
      texte(2,8) = '(''This file is unknown by the manager :'')'
c
      codret = 0
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
cgn      write (ulsort,*) 'lfichi =', lfichi
cgn      write (ulsort,*) 'fichie(1:lfichi) =', fichie(1:lfichi)
c
c 3.1. ==> erreurs
c
      if ( lfichi.lt.-1 .or. lfichi.gt.200 .or.
     >     lfichi.gt.len(fichie)                ) then
c
        nuroul = 0
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        if (lfichi.gt.0 .and. len(fichie).gt.0) then
          write (ulsort,*) fichie( 1 : min(lfichi,len(fichie)) )
        else
          write (ulsort,*)
        endif
        write (ulsort,texte(langue,10)) lfichi
        write (ulsort,texte(langue,4))
        write (ulsort,texte(langue,5))
        write (ulsort,texte(langue,6))
        write (ulsort,texte(langue,7))
c
        if ( typarr.eq.0 ) then
          guimp = 1
          raison = 1
          call gustop ( nompro, ulsort, guimp, raison )
        else
          codret = 3
        endif
c
c 3.2. ==> cas des entrees/sorties standard
c
      elseif ( lfichi.eq.-1 ) then
c
        nuroul = gunmbr(14)
c
      elseif ( lfichi.eq.0 ) then
c
        nuroul = gunmbr(15)
c
c 3.3. ==> un fichier particulier : recherche du bon nom
c    remarque : on ne recherche que parmi les unites qui sont ouvertes
c
      else
c
        nuroul = 0
c
        do 331 , iaux = 1 , mbmxul
c
          if ( statut(iaux).ge.1 .and. statut(iaux).le.6 ) then
            if ( lnomfi(iaux).eq.lfichi ) then
              if ( nomfic(iaux)(1:lfichi).eq.fichie(1:lfichi) ) then
                nuroul = iaux
                goto 332
              endif
            endif
          endif
c
  331   continue
c
  332   continue
c
#ifdef _DEBUG_HOMARD_
        if ( nuroul.eq.0 ) then
          write (ulsort,texte(langue,1))
          write (ulsort,texte(langue,7))
          if (lfichi.gt.0 .and. len(fichie).gt.0) then
            write (ulsort,*) fichie(1:min(lfichi,len(fichie)))
          else
            write (ulsort,*)
          endif
        endif
#endif
c
      endif
c
      end
