      subroutine utdqua ( lequad, diamet,
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
c     UTilitaire : Diametre d'un QUAdrangle
c     --           -             ---
c ______________________________________________________________________
c
c    Le diametre d'une maille est la longueur du plus grand segment que
c    l'on peut tracer a l'interieur de cette maille.
c    Pour un quadrangle, le diametre est le maximum des longueurs des
c    aretes et des diagonales
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   .  1     . numero du quadrangle a examiner            .
c . diamet .  s  .  1     . diametre du quadrangle                     .
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
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      double precision diamet, coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto), arequa(nbquto,4)
c
      integer lequad
c
c 0.4. ==> variables locales
c
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
c
      double precision var(3)
      double precision ar1, ar2, ar3, ar4, ad1, ad2
c
c 0.5. ==> initialisations
c
c====
c 1. les sommets
c====
c
      a1 = arequa(lequad,1)
      a2 = arequa(lequad,2)
      a3 = arequa(lequad,3)
      a4 = arequa(lequad,4)
c
      call utsoqu ( somare, a1, a2, a3, a4,
     >              sa1a2, sa2a3, sa3a4, sa4a1 )
c
c====
c 2. les carres des longueurs des 4 aretes et des 2 diagonales
c====
c
c 2.1. ==> en dimension 2
c
      if ( sdim.eq.2 ) then
c
        var(1) = coonoe(sa1a2,1) - coonoe(sa4a1,1)
        var(2) = coonoe(sa1a2,2) - coonoe(sa4a1,2)
        ar1 = var(1)*var(1) + var(2)*var(2)
c
        var(1) = coonoe(sa2a3,1) - coonoe(sa1a2,1)
        var(2) = coonoe(sa2a3,2) - coonoe(sa1a2,2)
        ar2 = var(1)*var(1) + var(2)*var(2)
c
        var(1) = coonoe(sa3a4,1) - coonoe(sa2a3,1)
        var(2) = coonoe(sa3a4,2) - coonoe(sa2a3,2)
        ar3 = var(1)*var(1) + var(2)*var(2)
c
        var(1) = coonoe(sa4a1,1) - coonoe(sa3a4,1)
        var(2) = coonoe(sa4a1,2) - coonoe(sa3a4,2)
        ar4 = var(1)*var(1) + var(2)*var(2)
c
        var(1) = coonoe(sa2a3,1) - coonoe(sa4a1,1)
        var(2) = coonoe(sa2a3,2) - coonoe(sa4a1,2)
        ad1 = var(1)*var(1) + var(2)*var(2)
c
        var(1) = coonoe(sa3a4,1) - coonoe(sa1a2,1)
        var(2) = coonoe(sa3a4,2) - coonoe(sa1a2,2)
        ad2 = var(1)*var(1) + var(2)*var(2)
c
      else
c
        var(1) = coonoe(sa1a2,1) - coonoe(sa4a1,1)
        var(2) = coonoe(sa1a2,2) - coonoe(sa4a1,2)
        var(3) = coonoe(sa1a2,3) - coonoe(sa4a1,3)
        ar1 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
        var(1) = coonoe(sa2a3,1) - coonoe(sa1a2,1)
        var(2) = coonoe(sa2a3,2) - coonoe(sa1a2,2)
        var(3) = coonoe(sa2a3,3) - coonoe(sa1a2,3)
        ar2 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
        var(1) = coonoe(sa3a4,1) - coonoe(sa2a3,1)
        var(2) = coonoe(sa3a4,2) - coonoe(sa2a3,2)
        var(3) = coonoe(sa3a4,3) - coonoe(sa2a3,3)
        ar3 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
        var(1) = coonoe(sa4a1,1) - coonoe(sa3a4,1)
        var(2) = coonoe(sa4a1,2) - coonoe(sa3a4,2)
        var(3) = coonoe(sa4a1,3) - coonoe(sa3a4,3)
        ar4 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
        var(1) = coonoe(sa2a3,1) - coonoe(sa4a1,1)
        var(2) = coonoe(sa2a3,2) - coonoe(sa4a1,2)
        var(3) = coonoe(sa2a3,3) - coonoe(sa4a1,3)
        ad1 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
        var(1) = coonoe(sa3a4,1) - coonoe(sa1a2,1)
        var(2) = coonoe(sa3a4,2) - coonoe(sa1a2,2)
        var(3) = coonoe(sa3a4,3) - coonoe(sa1a2,3)
        ad2 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      endif
c
c====
c 3. diametre
c    on ne prend la racine carre qu'ici pour economiser du temps calcul
c====
c
      diamet = max ( ar1, ar2, ar3, ar4, ad1, ad2 )
      diamet = sqrt(diamet)
cgn      print *, ar1, ar2, ar3, ar4, ad1, ad2, ' ==> ', diamet
c
      end
