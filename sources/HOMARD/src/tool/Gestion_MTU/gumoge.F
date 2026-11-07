      subroutine gumoge ( nfconf, lfconf, codret )
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
c     Gestionnaire des Unites logiques : MOde de GEstion
c     -                -                 --      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur du nom du fichier                 .
c . codret .  s  .    1   . 0 : tout va bien                           .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'GUMOGE' )
c
#include "gunbul.h"
#include "genbla.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      character*(*) nfconf
c
      integer lfconf
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
      integer codre0
      integer lfmode
c
      integer code
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
c
      character*200 nomfic(mbmxul)
      character*8 motcle
      character*200 nfmode
c
      character*5 fmtent
c
      integer ulsort
      integer langue
      integer typarr
c
#include "motcle.h"
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
      texte(1,4) =
     >'(''L''''option de la memoire '',a8,'' est illisible.'')'
      texte(1,5) = '(''Le type d''''arret '',i8,'' ne convient pas.'')'
      texte(1,6) = '(''Il faut 0 ou 1.'')'
c
      texte(2,4) = '(''The option '',a8,'' cannot be read.'')'
      texte(2,5) = '(''Type '',i8,'' is not correct.'')'
      texte(2,6) = '(''0 or 1 is needed.'')'
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
c 3. type d'arret
c====
c
      codret = 0
c
c 3.1. ==> recherche de l'option de pilotage qui contient le
c          le type d'arret de la gestion des unites logiques
c
      motcle = mcguta
      call ugfino ( motcle, nfmode, lfmode,
     >              nfconf, lfconf,
     >              ulsort, langue, codre0 )
c
c 3.2. ==> si aucune option n'a ete precisee, on arretera brutalement
c
      if (codre0.eq.1 ) then
c
        typarr = 0
c
c 3.3. ==> probleme de lecture
c
      elseif ( codre0.ne.0 ) then
c
        codret = 1
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,4)) motcle
c
c 3.4. ==> decodage
c
      else
c
        fmtent = '(I  )'
        if ( lfmode.lt.10 ) then
          write(fmtent(3:3),'(i1)') lfmode
        else
          write(fmtent(3:4),'(i2)') lfmode
        endif
        read ( nfmode,fmtent) typarr
c
      endif
c
c 3.5. ==> verification
c
      if ( typarr.lt.0 .or. typarr.gt.1 ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,4)) motcle
        write (ulsort,texte(langue,5)) typarr
        write (ulsort,texte(langue,6))
        codret = 1
      endif
c
c====
c 4. archivage du numero
c====
c
      if ( codret.eq.0 ) then
c
        gunmbr(18) = typarr
c
        code = 0
        call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
      endif
c
c====
c 5. la fin
c====
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
      endif
c
      end
