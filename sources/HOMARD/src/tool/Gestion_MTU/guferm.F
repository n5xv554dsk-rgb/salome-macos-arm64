      subroutine guferm ( fichie, lfichi, nuroul, codret )
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
c  Gestionnaire des Unites logiques - FERMeture d'une unite logique
c  -                -                 ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . fichie . e   . ch<200 . nom du fichier a fermer                    .
c . lfichi . e   .    1   . longueur du nom du fichier a fermer        .
c . nuroul . e   .    1   . numero de l'unite logique a fermer         .
c . codret .  s  .    1   . 0  : tout va bien                          .
c .        .     .        . non nul : probleme                         .
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
      parameter ( nompro = 'GUFERM' )
c
#include "genbla.h"
c
#include "gunbul.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer lfichi, nuroul, codret
c
      character*(*) fichie
c
c 0.4. ==> variables locales
c
#include "gulggt.h"
c
      integer guimp, raison
      integer iaux, code, statfi, l200
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
      integer ulsort, langue
      integer typarr
c
      character*200 ficloc, nomfic(mbmxul)
c
      integer iindef
      double precision rindef
      character*8 sindef
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
      typarr = gunmbr(18)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 2. fermeture
c====
c
      codret = 0
c
      if (nuroul.gt.0 .and. nuroul.le.mbmxul) then
        statfi = statut(nuroul)
      else
        statfi = 0
      endif
c
      l200 = -1
c
c 2.1. ==> fermeture proprement dite
c
      if ( statfi.ge.3 .and. statfi.le.4 ) then
c
        close ( unit=nuroul, err=2100, iostat=codret )
        goto 2101
 2100   continue
        if ( codret.eq.0 ) then
          codret = -1
        endif
 2101   continue
c
      else
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        l200 = max(0, min( 200, lfichi, len(fichie) ) )
        if (l200.gt.0) then
          ficloc(1:l200) = fichie(1:l200)
        endif
        do 210 iaux = l200 + 1, 200
          ficloc(iaux:iaux) = ' '
  210   continue
        write (ulsort,21000) nuroul, ficloc
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
      if (codret.ne.0.and.l200.lt.0) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        l200 = max(0, min( 200, lfichi, len(fichie) ) )
        if (l200.gt.0) then
          ficloc(1:l200) = fichie(1:l200)
        endif
        do 211 iaux = l200 + 1, 200
          ficloc(iaux:iaux) = ' '
  211   continue
        write(ulsort,22000) nuroul, ficloc
        if ( typarr.eq.0 ) then
          guimp = 1
          raison = 1
          call gustop ( nompro, ulsort, guimp, raison )
        endif
      endif
c
c 2.2. ==> inscription dans les listes
c
      if ( codret.eq.0 ) then
c
        statut(nuroul) = 0
c
        call dmindf ( iindef, rindef, sindef )
c
        do 22 , iaux = 1 , 25
           nomfic(nuroul)(8*(iaux-1)+1:8*iaux) = sindef
   22   continue
c
        lnomfi(nuroul) = iindef
c
      endif
c
c===
c 3. archivage de l'information
c===
c
c     (9): nb actuel d'unites ouvertes form/sequ
c     (10): nb actuel d'unites ouvertes bina/sequ
c     (11): nb actuel d'unites ouvertes form/dire
c     (12): nb actuel d'unites ouvertes form/dire
c
      if ( codret.eq.0 ) then
c
        gunmbr(statfi+6) = gunmbr(statfi+6) - 1
c
        code = 0
        call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
      endif
c
c====
c 4. formats
c====
c
21000 format(
     >/,'Erreur lors de la fermeture de l''unite ',i2,
     >/,'Fichier :',
     >/,a200,
     >/,'Ce fichier n''a jamais ete ouvert ...',//)
c
22000 format(
     >/,'Erreur lors de la fermeture de l''unite ',i2,
     >/,'Fichier :',
     >/,a200,//)
c
      end
