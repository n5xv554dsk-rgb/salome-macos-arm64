      subroutine utntri ( letria, normal,
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
c     UTilitaire : Normale d'un TRIangle
c     --           -            ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letria . e   .  1     . numero du triangle a examiner              .
c . normal .  s  .  3     . vecteur de la normale                      .
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
      double precision normal(3), coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto), aretri(nbtrto,3)
c
      integer letria
c
c 0.4. ==> variables locales
c
      integer a1, a2
c
      double precision aret1(3), aret2(3)
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
c
      aret1(1) = coonoe(somare(2,a1),1) - coonoe(somare(1,a1),1)
      aret1(2) = coonoe(somare(2,a1),2) - coonoe(somare(1,a1),2)
      aret1(3) = coonoe(somare(2,a1),3) - coonoe(somare(1,a1),3)
c
      aret2(1) = coonoe(somare(2,a2),1) - coonoe(somare(1,a2),1)
      aret2(2) = coonoe(somare(2,a2),2) - coonoe(somare(1,a2),2)
      aret2(3) = coonoe(somare(2,a2),3) - coonoe(somare(1,a2),3)
c
c====
c 2. normal = produit vectoriel
c====
c
      normal(1) = aret2(2)*aret1(3) - aret2(3)*aret1(2)
      normal(2) = aret2(3)*aret1(1) - aret2(1)*aret1(3)
      normal(3) = aret2(1)*aret1(2) - aret2(2)*aret1(1)
c
      aret1(1) = sqrt ( normal(1)*normal(1) +
     >                  normal(2)*normal(2) +
     >                  normal(3)*normal(3) )
c
      normal(1) = normal(1)/aret1(1)
      normal(2) = normal(2)/aret1(1)
      normal(3) = normal(3)/aret1(1)
c
      end
