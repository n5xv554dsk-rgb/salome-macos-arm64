      subroutine gtstop ( appela, ulsort, raison )
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
c                                       premiere creation le 30.12.88 gn
c ______________________________________________________________________
c
c    'Gestion du Temps : STOP du programme'
c     -          -       ----
c ______________________________________________________________________
c
c but : arrete le gestionnaire de temps
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . appela . e   .    1   . nom du programme appelant                  .
c . ulsort . e   .    1   . unite logique pour les messages            .
c . raison . e   .    1   . raison de l'appel :                        .
c .        .     .        . 0 : arret normal, sans core                .
c .        .     .        . >0 : call abort -> core                    .
c .        .     .        . <0 : arret des gestionnaires, puis sortie  .
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
      parameter ( nompro = 'GTSTOP' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer ulsort, raison
c
      character *(*) appela
c
c 0.4. ==> variables locales
c
      integer guimp, gmimp
c
#ifdef _DEBUG_HOMARD_
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
#endif
c
#include "langue.h"
c
c====
c  1. appel du programme d'arret general
c====
c
      guimp = 0
      gmimp = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UGSTOP', nompro
#endif
      call ugstop ( appela, ulsort, guimp, gmimp, raison )
c
      end
