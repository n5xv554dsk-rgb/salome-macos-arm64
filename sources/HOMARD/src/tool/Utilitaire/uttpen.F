      subroutine uttpen ( lepent, torsio,
     >                    coonoe, somare, arequa,
     >                    facpen, cofape, arepen )

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
c     UTilitaire : Torsion d'un PENtaedre
c     --           -            ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .  1     . numero du pentaedre a examiner             .
c . torsio .  s  .  1     . torsion du pentaedre                       .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. codes des 5 faces des pentaedres           .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
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
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      double precision torsio, coonoe(nbnoto,3)
c
      integer lepent
      integer somare(2,nbarto)
      integer arequa(nbquto,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
c
c 0.4. ==> variables locales
c
      integer listar(9), listso(6)
c
      double precision daux
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les aretes et les sommets du pentaedre
c====
c
      call utaspe ( lepent,
     >              nbquto, nbpecf, nbpeca,
     >              somare, arequa,
     >              facpen, cofape, arepen,
     >              listar, listso )
c
c====
c 2. Traitement
c====
c
c 2.1. ==> face 3
c
      call uttoqu ( listso(1), listso(4), listso(6), listso(3),
     >              coonoe, daux )
      torsio = daux
c
c 2.2. ==> face 4
c
      call uttoqu ( listso(2), listso(5), listso(4), listso(1),
     >              coonoe, daux )
      torsio = max(torsio, daux)
c
c 2.3. ==> face 5
c
      call uttoqu ( listso(3), listso(6), listso(5), listso(2),
     >              coonoe, daux )
      torsio = max(torsio, daux)
c
      end
