      subroutine utqtri ( letria, qualit, surf,
     >                    coonoe, somare, aretri )
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
c     UTilitaire : Qualite d'un TRIangle
c     --           -            ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letria . e   .  1     . numero du triangle a examiner              .
c . qualit .  s  .  1     . qualite                                    .
c . surf   .  s  .  1     . surface                                    .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTQTRI' )
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      double precision qualit, surf, coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto), aretri(nbtrto,3)
c
      integer letria
c
c 0.4. ==> variables locales
c
      integer sa1a2, sa2a3, sa3a1
      integer a1, a2, a3
      integer iaux
c
      double precision cooloc(3,3)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. le calcul
c====
c
c 1.1. ==> les aretes
c
      a1  = aretri(letria,1)
      a2  = aretri(letria,2)
      a3  = aretri(letria,3)
c
c 1.2. ==> les sommets
c
      call utsotr ( somare, a1, a2, a3,
     >              sa1a2, sa2a3, sa3a1 )
c
      do 12 , iaux = 1 , sdim
        cooloc(1,iaux) = coonoe(sa1a2,iaux)
        cooloc(2,iaux) = coonoe(sa2a3,iaux)
        cooloc(3,iaux) = coonoe(sa3a1,iaux)
  12  continue
c
c 1.3. ==> qualite et surface
c
      call utqtr0 ( qualit, surf, sdim, cooloc )
c
      end
