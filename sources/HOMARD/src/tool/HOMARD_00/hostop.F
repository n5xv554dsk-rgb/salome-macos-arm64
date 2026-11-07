      subroutine hostop ( ulsort, guimp, gmimp, raison )
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
c       HOMARD : STOP
c       --       ----
c
c but : arreter une execution apres avoir arrete les gestionnaires
c       - gestionnaire de memoire
c       - gestionnaire des mesures de temps de calcul
c       - gestionnaire d'unites logiques
c       - execution elle-meme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ulsort . e   .    1   . unite logique pour les messages            .
c . guimp  . e   .    1   . 1 => impressions gu                        .
c . gmimp  . e   .    1   . 1 => impressions gm                        .
c . raison . e   .    1   . raison d appel                             .
c .        .     .        . 0 : arret normal, sans core                .
c .        .     .        . .NE.0 : call abort -> core                 .
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
      parameter ( nompro = 'HOSTOP' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer ulsort, raison, guimp, gmimp
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
#include "langue.h"
c ______________________________________________________________________
c
c====
c 1. entete
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      write (ulsort,10001)
c
10001 format (/,
     > /,15x,'......................................',
     > /,15x,':                                    :',
     > /,15x,':           H O M A R D              :',
     > /,15x,':....................................:')
c
c====
c 2. arret des gestionnaires et de l'execution
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UGSTOP', nompro
#endif
      call ugstop ( spropb, ulsort, guimp, gmimp, raison )
c
      end
