      subroutine utthex ( lehexa, torsio,
     >                    coonoe, somare, arequa,
     >                    quahex, coquhe, arehex )

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
c     UTilitaire : Torsion d'un HEXaedre
c     --           -            ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .  1     . numero de l'hexaedre a examiner            .
c . torsio .  s  .  1     . torsion de l'hexaedre                      .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
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
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      double precision torsio, coonoe(nbnoto,3)
c
      integer lehexa
      integer somare(2,nbarto)
      integer arequa(nbquto,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
c
c 0.4. ==> variables locales
c
      integer listar(12), listso(8)
c
      double precision daux
c
c====
c 1. Les aretes et les sommets de l'hexaedre
c====
c
      call utashe ( lehexa,
     >              nbquto, nbhecf, nbheca,
     >              somare, arequa,
     >              quahex, coquhe, arehex,
     >              listar, listso )
c
c====
c 2. traitement
c====
c
c 2.1. ==> face 1
c
      call uttoqu ( listso(1), listso(2), listso(3), listso(4),
     >              coonoe, daux )
      torsio = daux
c
c 2.2. ==> face 2
c
      call uttoqu ( listso(1), listso(2), listso(5), listso(6),
     >              coonoe, daux )
      torsio = max(torsio, daux)
c
c 2.3. ==> face 3
c
      call uttoqu ( listso(1), listso(6), listso(7), listso(4),
     >              coonoe, daux )
      torsio = max(torsio, daux)
c
c 2.4. ==> face 4
c
      call uttoqu ( listso(5), listso(2), listso(3), listso(8),
     >              coonoe, daux )
      torsio = max(torsio, daux)
c
c 2.5. ==> face 5
c
      call uttoqu ( listso(7), listso(8), listso(3), listso(4),
     >              coonoe, daux )
      torsio = max(torsio, daux)
c
c 2.6. ==> face 6
c
      call uttoqu ( listso(5), listso(6), listso(7), listso(8),
     >              coonoe, daux )
      torsio = max(torsio, daux)
c
      end
