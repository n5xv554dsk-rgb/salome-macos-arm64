      subroutine ugtabl ( code, tabges, ulsort )
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
c but : archiver ou redonner les caracteristiques des differents
c       gestionnaires.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . code   . e   .    1   . 0 : on archive les tableaux de l'appelant  .
c .        .     .        . 1 : on renvoie les tableaux vers l'appelant.
c . tabges . e/s . lgtage . les nombres caracteristiques de la gestion .
c .        .     .        .(1): memoire                                .
c .        .     .        .(2): mesures de temps de calcul             .
c .        .     .        .(3): unites logiques                        .
c .        .     .        .(4): langue des messages                    .
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
      parameter ( nompro = 'UGTABL' )
c
#include "genbla.h"
c
#include "gelggt.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer code, tabges(lgtage), ulsort
c
c 0.4. ==> variables locales
c
      integer trges0(lgtage)
      integer langue
c
      logical initia
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data langue / 1 /
      data initia / .false. /
c ______________________________________________________________________
c
c====
c 1. verifications de l'initialisation
c====
c
#include "impr01.h"
c
      if ( code.ne.0 .and. .not.initia ) then
        write (ulsort,texte(langue,1)) 'Entree', nompro
        write (ulsort,11000) nompro
        call dmabor
      endif
c
11000 format(
     > 'L''initialisation du gestionnaire des gestionnaires',
     > 'n''a pas ete faite.',
     >/,'Il faut d''abord faire appel a ',a6,' en archivage.',//)
c
c====
c 2. on archive les informations transmises par l'appelant
c====
c
      if ( code.eq.0 ) then
c
        call ugtaci ( trges0, tabges, 1, lgtage )
c
        initia = .true.
c
c===
c 3. on renvoie a l'appelant
c====
c
      elseif ( code.eq.1 ) then
c
        call ugtaci ( tabges, trges0, 1, lgtage )
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
     >    'a aucune option possible.',
     >/,'Il faut 0 pour archiver ou 1 pour recuperer.',/)
c
      end
