      subroutine utqqua ( lequad, qualit, surf,
     >                    coonoe, somare, arequa )
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
c     UTilitaire : Qualite d'un QUAdrangle
c     --           -            ---
c ______________________________________________________________________
c
c    on utilise le critere decrit dans
c     'Pascal Jean Frey, Paul-Louis George'
c     'Maillages - applications aux elements finis, Hermes, 1999'
c
c     Chapitre 8 'Optimisation des maillages', page 610
c
c                                           hmax * hs
c    le critere de qualite, q, vaut alpha * ---------
c                                             Smin
c    hmax est la plus grande longueur entre les 4 cotes et les
c    2 diagonales
c    hs est la moyenne quadratique des longueur des cotes
c    Smin est la plus petite des surfaces des 4 triangles que l'on
c    peut tracer dans le quadrangle
c    alpha est un coefficient de normalisation pour que le critere q
c    vaille 1 pour un carre ==> alpha = racine(2)/8
c
c    pour tout autre quadrangle, le critere est donc superieur a 1
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   .  1     . numero du quadrangle a examiner            .
c . qualit .  s  .  1     . qualite                                    .
c . surf   .  s  .  1     . surface                                    .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
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
      parameter ( nompro = 'UTQQUA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      double precision qualit, surf, coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto), arequa(nbquto,4)
c
      integer lequad
c
c 0.4. ==> variables locales
c
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
      integer iaux
c
      double precision cooloc(4,3)
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
      a1 = arequa(lequad,1)
      a2 = arequa(lequad,2)
      a3 = arequa(lequad,3)
      a4 = arequa(lequad,4)
c
c 1.2. ==> les sommets
c
      call utsoqu ( somare, a1, a2, a3, a4,
     >              sa1a2, sa2a3, sa3a4, sa4a1 )
c
      do 12 , iaux = 1 , sdim
        cooloc(1,iaux) = coonoe(sa1a2,iaux)
        cooloc(2,iaux) = coonoe(sa2a3,iaux)
        cooloc(3,iaux) = coonoe(sa3a4,iaux)
        cooloc(4,iaux) = coonoe(sa4a1,iaux)
  12  continue
c
c 1.3. ==> qualite et surface
c
      call utqqu0 ( qualit, surf, sdim, cooloc )
c
      end
