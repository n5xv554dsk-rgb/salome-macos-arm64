      subroutine utvopy ( coonoe, listso, volume )
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
c   UTilitaire : VOlume PYramide
c   --           --     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . listso . e   .    8   . liste des sommets ordonnes de la pyramide  .
c . volume .  s  .    1   . Volume de la pyramide                      .
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
c 0.2. ==> communs
c
#include "nombno.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
      integer listso(5)
      double precision volume
c
c 0.4. ==> variables locales
c
      integer iaux
c
      double precision coosom(3,5)
c
c====
c 1. Reperage des coordonnees des sommets
c====
c
      do 11 , iaux = 1 , 3
c
        coosom(iaux,1) = coonoe(listso(1),iaux)
        coosom(iaux,2) = coonoe(listso(2),iaux)
        coosom(iaux,3) = coonoe(listso(3),iaux)
        coosom(iaux,4) = coonoe(listso(4),iaux)
        coosom(iaux,5) = coonoe(listso(5),iaux)
c
   11 continue
c
c====
c 2. Programme generique
c====
c
      call utvoy0 ( coosom, volume )
c
      end
