      subroutine utdtri ( letria, diamet,
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
c     UTilitaire : Diametre d'un TRIangle
c     --           -             ---
c ______________________________________________________________________
c
c    Le diametre d'une maille est la longueur du plus grand segment que
c    l'on peut tracer a l'interieur de cette maille.
c    Pour un triangle, le diametre est la longueur maximale des aretes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letria . e   .  1     . numero du triangle a examiner              .
c . diamet .  s  .  1     . diametre                                   .
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
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      double precision diamet, coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto), aretri(nbtrto,3)
c
      integer letria
c
c 0.4. ==> variables locales
c
      integer a1, a2, a3
c
      double precision ar1, ar2, ar3
      double precision var(3)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les aretes
c====
c
      a1 = aretri(letria,1)
      a2 = aretri(letria,2)
      a3 = aretri(letria,3)
c
c====
c 2. les carres des longueurs des 3 aretes
c====
c
c 2.1. ==> en dimension 2
c
      if ( sdim.eq.2 ) then
c
        var(1) = coonoe(somare(2,a1),1) - coonoe(somare(1,a1),1)
        var(2) = coonoe(somare(2,a1),2) - coonoe(somare(1,a1),2)
        ar1 = var(1)*var(1) + var(2)*var(2)
c
        var(1) = coonoe(somare(2,a2),1) - coonoe(somare(1,a2),1)
        var(2) = coonoe(somare(2,a2),2) - coonoe(somare(1,a2),2)
        ar2 = var(1)*var(1) + var(2)*var(2)
c
        var(1) = coonoe(somare(2,a3),1) - coonoe(somare(1,a3),1)
        var(2) = coonoe(somare(2,a3),2) - coonoe(somare(1,a3),2)
        ar3 = var(1)*var(1) + var(2)*var(2)
c
c 2.2. ==> en dimension 3
c
      else
c
        var(1) = coonoe(somare(2,a1),1) - coonoe(somare(1,a1),1)
        var(2) = coonoe(somare(2,a1),2) - coonoe(somare(1,a1),2)
        var(3) = coonoe(somare(2,a1),3) - coonoe(somare(1,a1),3)
        ar1 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
        var(1) = coonoe(somare(2,a2),1) - coonoe(somare(1,a2),1)
        var(2) = coonoe(somare(2,a2),2) - coonoe(somare(1,a2),2)
        var(3) = coonoe(somare(2,a2),3) - coonoe(somare(1,a2),3)
        ar2 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
        var(1) = coonoe(somare(2,a3),1) - coonoe(somare(1,a3),1)
        var(2) = coonoe(somare(2,a3),2) - coonoe(somare(1,a3),2)
        var(3) = coonoe(somare(2,a3),3) - coonoe(somare(1,a3),3)
        ar3 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      endif
c
c====
c 3. diametre
c    on ne prend la racine carre qu'ici pour economiser du temps calcul
c====
c
      diamet = max ( ar1, ar2, ar3 )
      diamet = sqrt(diamet)
cgn      print *, ar1, ar2, ar3, ' ==> ', diamet
c
      end
