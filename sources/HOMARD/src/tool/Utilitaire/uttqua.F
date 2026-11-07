      subroutine uttqua ( lequad, torsio,
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
c     UTilitaire : Torsion d'un QUAdrangle
c     --           -            ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   .  1     . numero du quadrangle a examiner            .
c . torsio .  s  .  1     . torsion du quadrangle                      .
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
      double precision torsio, coonoe(nbnoto,sdim)
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
c 2. Traitement
c====
c
      call uttoqu ( sa1a2, sa2a3, sa3a4, sa4a1,
     >              coonoe, torsio )
c
      end
