      subroutine utlgar ( larete, coonoe, somare,
     >                    dlong,
     >                    ulsort, langue, codret )
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
c    UTilitaire - LonGueur d'une ARete
c    --           -  -           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . larete . e   .    1   . l'arete                                    .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . dlong  .  s  .   1    . la longueur de l'arete                     .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'UTLGAR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer larete
      integer somare(2,nbarto)
c
      double precision dlong
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
      integer sa1a2, sa2a3
c
      double precision vn(3)
c
      integer nbmess
      parameter (nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      codret = 0
c
c====
c 2. calcul de la longueur de l'arete
c====
c
      sa1a2 = somare(1,larete)
      sa2a3 = somare(2,larete)
c
      vn(1) = coonoe(sa2a3,1) - coonoe(sa1a2,1)
c
      if ( sdim.eq.1 ) then
c
        dlong = abs ( vn(1) )
c
      elseif ( sdim.eq.2 ) then
c
        vn(2) = coonoe(sa2a3,2) - coonoe(sa1a2,2)
        dlong = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) )
c
      else
c
        vn(2) = coonoe(sa2a3,2) - coonoe(sa1a2,2)
        vn(3) = coonoe(sa2a3,3) - coonoe(sa1a2,3)
        dlong = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
      endif
c
      end
