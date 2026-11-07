      subroutine guinit ( enstul, sostul, langdf,
     >                    nfconf, lfconf, codret )
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
c but : initialiser la gestion des unites logiques
c       - a priori tout est disponible
c       - on reserve l'entree standard
c       - on reserve la sortie standard
c       - on archive ce point de depart
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . enstul . e   .    1   . entree standard : numero de l'unite logique.
c . sostul . e   .    1   . sortie standard : numero de l'unite logique.
c . langdf . e   .   1    . langue des messages par defaut             .
c .        .     .        . 1 : francais                               .
c .        .     .        . 2 : anglais                                .
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur du nom du fichier                 .
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
      parameter ( nompro = 'GUINIT' )
c
#include "genbla.h"
c
#include "gelggt.h"
#include "gedita.h"
c
#include "gunbul.h"
#include "gulggt.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      character *(*) nfconf
c
      integer enstul, sostul, langdf, lfconf
      integer codret
c
c 0.4. ==> variables locales
c
      integer entrst, sortst
      integer ulsort, langue
      integer typarr
c
      integer guimp, raison
      integer iaux, code
      integer gunmbr(lgunmb)
      integer statut(mbmxul), lnomfi(mbmxul)
c
      character*200 nomfic(mbmxul)
      character*200 nomaux
c
      integer iindef
      double precision rindef
      character*8 sindef
c
      logical dejavu
c
      integer nbmess
      parameter ( nbmess = 3 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data dejavu / .false. /
      data typarr /   0     /
c
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
c 1.1. ==> au debut, tout va bien ...
c
      codret = 0
c
c 1.2. ==> les valeurs indefinies
c
      call dmindf ( iindef, rindef, sindef )
c
c 1.3. ==> on verifie que l'initialisation n'a pas deja ete faite
c
      if ( dejavu ) then
c
        code = 1
        call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
        ulsort = gunmbr(16)
        langue = gunmbr(17)
        typarr = gunmbr(18)
        write (ulsort,11000)
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
c 1.4. ==> tout est libre
c
      if ( codret.eq.0 ) then
c
        do 141 , iaux = 1 , 25
          nomaux(8*(iaux-1)+1:8*iaux) = sindef
  141   continue
c
        do 142 , iaux = 1 , mbmxul
          statut(iaux) = 0
          lnomfi(iaux) = iindef
          nomfic(iaux) = nomaux
  142   continue
c
        do 143 , iaux = 1 , lgunmb
          gunmbr(iaux) = iindef
  143  continue
c
      endif
c
c====
c 2. reservation des unites standard
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> on verifie que les numeros donnes pour les unites
c          d'entree/sorties standard sont corrects.
c          . s'ils le sont, on declare la sortie standard comme etant
c            l'unite des messages par defaut.
c          . s'ils ne le sont pas, on arrete.
c          remarque : si l'unite logique souhaitee pour la sortie
c                     standard, sostul, il faut imprimer un message.
c                     or on ne sait pas ou : on le fait sur l'unite
c                     "ecran", faute de mieux.
c
        iaux = 0
c
        if ( sostul.lt.1 .or. sostul.gt.mbmxul ) then
          call dmunit ( entrst , sortst )
          langue = langdf
        write (ulsort,texte(langue,1)) 'Sortie', nompro
          write(sortst,21010) 'Sortie', sostul
          iaux = 1
          if ( .not.dejavu ) then
            ulsort = sortst
          endif
        else
          ulsort = sostul
        endif
c
        if ( enstul.lt.1 .or. enstul.gt.mbmxul ) then
          langue = langdf
          write (ulsort,texte(langue,1)) 'Sortie', nompro
          write(ulsort,21010) 'Entree', enstul
          iaux = 1
        endif
c
        if ( enstul.eq.sostul ) then
          langue = langdf
          write (ulsort,texte(langue,1)) 'Sortie', nompro
          write(ulsort,21020) enstul
          iaux = 1
        endif
c
        if ( iaux.ne.0 ) then
          if ( typarr.eq.0 ) then
            guimp = 1
            raison = 1
            call gustop ( nompro, ulsort, guimp, raison )
          else
            codret = 3
          endif
        endif
c
c 2.2. ==> reservation
c
        if ( codret.eq.0 ) then
c
          statut(enstul) = 1
          statut(sostul) = 2
c
        endif
c
      endif
c
c====
c 3. on archive l'information
c====
c
      if ( codret.eq.0 ) then
c
c     (1): nbre maxi d'unites ouvertes form/sequ
        gunmbr(1) = 2
c
c     (2): nbre maxi d'unites ouvertes bina/sequ
        gunmbr(2) = 0
c
c     (3): nbre maxi d'unites ouvertes bina/dire standard
        gunmbr(3) = 0
c
c     (4): nbre maxi d'unites ouvertes bina/dire special
        gunmbr(4) = 0
c
c     (5): nbre total d'unites ouvertes form/sequ
        gunmbr(5) = 2
c
c     (6): nbre total d'unites ouvertes bina/sequ
        gunmbr(6) = 0
c
c     (7): nbre total d'unites ouvertes bina/dire standard
        gunmbr(7) = 0
c
c     (8): nbre total d'unites ouvertes bina/dire special
        gunmbr(8) = 0
c
c     (9): nbre actuel d'unites ouvertes form/sequ
        gunmbr(9) = 2
c
c     (10): nbre actuel d'unites ouvertes bina/sequ
        gunmbr(10) = 0
c
c     (11): nbre actuel d'unites ouvertes bina/dire standard
        gunmbr(11) = 0
c
c     (12): nbre actuel d'unites ouvertes bina/dire special
        gunmbr(12) = 0
c
c     (13): nb maxi d'unites ouvertes tous types
        gunmbr(13) = 2
c
c     (14): numero de l'entree standard
        gunmbr(14) = enstul
c
c     (15): numero de la sortie standard
        gunmbr(15) = sostul
c
c     (16): numero de l'unite des messages du gu
        gunmbr(16) = ulsort
c
c     (17): langue des messages du gu
        gunmbr(17) = langdf
c
c     (18): type d'arret du gestionnaire
        gunmbr(18) = typarr
c
        code = 0
        call gutabl ( code, gunmbr, statut, nomfic, lnomfi )
c
      endif
c
c====
c 4. on note que l'on est deja passe par l'initialisation
c====
c
      if ( codret.eq.0 ) then
c
        dejavu = .true.
c
        code = 1
        call ugtabl ( code, tabges, sostul)
c
        tabges(1) = 1
c
        code = 0
        call ugtabl ( code, tabges, sostul)
c
      endif
c
c====
c 5. recherche du mode d'arret
c====
c
      call gumoge ( nfconf, lfconf, codret )
c
c====
c 6. formats
c====
c
11000 format(
     >/,'L''initialisation de GU a deja ete faite.',//)
21010 format(
     >/,a6,' standard : l''unite ',i8,' est incorrecte.',
     >/,'Il faut un numero compris entre 1 et mbmxul.',//)
21020 format(
     >/,'L''entree et la sortie standard sont sur la meme unite ',i8,
     >/,'Ce n''est pas bon, mes amis ...',//)
c
      end
