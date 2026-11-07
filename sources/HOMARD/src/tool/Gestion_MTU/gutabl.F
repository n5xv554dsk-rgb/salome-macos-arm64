      subroutine gutabl ( code, gunmbr, statut, nomfic, lnomfi )
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
c but : archiver ou redonner les listes caracteristiques de la
c       gestion des unites logiques.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . code   . e   .    1   . 0 : on archive les tableaux de l'appelant  .
c .        .     .        . 1 : on renvoie les tableaux vers l'appelant.
c . gunmbr . e/s . lgunmb . les nombres caracteristiques de la gestion .
c .        .     .        .(1): nb maxi d'unites ouvertes form/sequ    .
c .        .     .        .(2): nb maxi d'unites ouvertes bina/sequ    .
c .        .     .        .(3): nb maxi d'unites ouvertes bina/dire sta.
c .        .     .        .(4): nb maxi d'unites ouvertes bina/dire spe.
c .        .     .        .(5): nb total d'unites ouvertes form/sequ   .
c .        .     .        .(6): nb total d'unites ouvertes bina/sequ   .
c .        .     .        .(7): nb total d'unites ouvertes bina/dire st.
c .        .     .        .(8): nb total d'unites ouvertes bina/dire sp.
c .        .     .        .(9): nb actuel d'unites ouvertes form/sequ  .
c .        .     .        .(10): nb actuel d'unites ouvertes bina/sequ .
c .        .     .        .(11): nb actuel d'unites ouvertes bina/dire .
c .        .     .        .(12): nb actuel d'unites ouvertes bina/dire .
c .        .     .        .(13): nb maxi d'unites ouvertes tous types  .
c .        .     .        .(14): numero de l'entree standard           .
c .        .     .        .(15): numero de la sortie standard          .
c .        .     .        .(16): numero de l'unite des messages du gu  .
c .        .     .        .(17): langue des messages du gu             .
c .        .     .        .(18): type d'arret du gu                    .
c . statut . e/s . mbmxul . statut de chaque unite logique :           .
c .        .     .        . 0 : disponible                             .
c .        .     .        . 1 : entree standard (form/sequ)            .
c .        .     .        . 2 : sortie standard (form/sequ)            .
c .        .     .        . 3 : ouvert en form/sequ                    .
c .        .     .        . 4 : ouvert en bina/sequ                    .
c .        .     .        . 5 : ouvert en form/dire                    .
c .        .     .        . 6 : ouvert en bina/dire                    .
c .        .     .        . 7 : interdit                               .
c . nomfic . e/s . mbmxul . nom du fichier attache a chaque unite      .
c .        .     .        . logique ouverte                            .
c . lnomfi . e/s . mbmxul . longueur du nom du fichier attache a chaque.
c .        .     .        . unite logique ouverte                      .
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
      parameter ( nompro = 'GUTABL' )
c
#include "genbla.h"
c
#include "gunbul.h"
#include "gulggt.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer code
      integer gunmbr(*)
      integer statut(mbmxul), lnomfi(mbmxul)
c
      character*(*) nomfic(mbmxul)
c
c 0.4. ==> variables locales
c
      integer sortst
      parameter ( sortst = 6 )
c
      integer ulsort, langue
c
      integer gunmb0(lgunmb)
      integer statu0(mbmxul), lnomf0(mbmxul)
c
      logical initia
c
      character*200 nomfi0(mbmxul)
c
      integer nbmess
      parameter ( nbmess = 3 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> intialisations
c
      data initia / .false. /
c
c ... juste pour ne plus avoir de messages ftnchek :
c
      data gunmb0(16) / sortst /
c
c ______________________________________________________________________
c
c====
c 1. verifications
c====
c
#include "impr01.h"
c
c 1.1. ==> unite pour la sortie standard et langue
c
      if ( .not.initia ) then
        ulsort = sortst
        langue = 1
      else if ( gunmb0(16).gt.0 .and. gunmb0(16).le.mbmxul ) then
        ulsort = gunmb0(16)
        langue = gunmb0(17)
      else
        ulsort = sortst
        langue = 1
      endif
c
c 1.2. ==> L'initialisation n'est pas faite
c
      if ( code.ne.0 .and. .not.initia ) then
        write (ulsort,texte(langue,1)) 'Entree', nompro
        write (ulsort,12000)
        call dmabor
      endif
c
12000 format(
     > 'L''initialisation du gestionnaire n''a pas ete faite.',
     >/'Il faut faire appel a GUINIT.',//)
c
c====
c 2. on archive les informations transmises par l'appelant
c====
c
      if ( code.eq.0 ) then
c
         call ugtaci (gunmb0, gunmbr, 1, lgunmb)
         call ugtaci (statu0, statut, 1, mbmxul)
         call ugtaci (lnomf0, lnomfi, 1, mbmxul)
         call ugtac2 (nomfi0, nomfic, 1, mbmxul)
c
         initia = .true.
c
c===
c 3. on renvoie a l'appelant
c====
c
      elseif ( code.eq.1 ) then
c
        call ugtaci (gunmbr, gunmb0, 1, lgunmb)
        call ugtaci (statut, statu0, 1, mbmxul)
        call ugtaci (lnomfi, lnomf0, 1, mbmxul)
        call ugtac2 (nomfic, nomfi0, 1, mbmxul)
c
c===
c 4. probleme
c====
c
      else
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write(ulsort,40000) code
        call dmabor
c
      endif
c
40000 format(
     > 'Le choix ',i4,' pour le premier argument ne correspond ',
     > 'a aucune option possible.',
     >/'Il faut 0 pour archiver ou 1 pour recuperer.',/)
c
      end
