      subroutine utqpen ( lepent, qualit, qualij, volume,
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
c     UTilitaire : Qualite d'un PENtaedre
c     --           -            ---
c ______________________________________________________________________
c
c     . Jacobien normalise
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .  1     . numero du pentaedre a examiner             .
c . qualit .  s  .  1     . qualite non definie                        .
c . qualij .  s  .  1     . qualite par le jacobien normalise          .
c . volume .  s  .  1     . volume                                     .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
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
#include "nombar.h"
#include "nombqu.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      double precision qualit, qualij, volume
      double precision coonoe(nbnoto,3)
c
      integer lepent
      integer somare(2,nbarto)
      integer arequa(nbquto,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer aresom(0:3,6)
      integer listar(9), listso(6)
c
      double precision daux
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les aretes et les sommets
c====
c
      call utaspe ( lepent,
     >              nbquto, nbpecf, nbpeca,
     >              somare, arequa,
     >              facpen, cofape, arepen,
     >              listar, listso )
c
c====
c 2. volume
c====
c
      call utvope ( coonoe, listso, volume )
c
c====
c 3. qualite bidon
c====
c
      qualit = -1789.d0
c
c====
c 4. qualite par le jacobien normalise
c====
c 4.1. ==> Liens sommet/aretes
c
      aresom(0,1) = 1
      aresom(1,1) = 2
      aresom(2,1) = 1
      aresom(3,1) = 7
c
      aresom(0,2) = 2
      aresom(1,2) = 3
      aresom(2,2) = 2
      aresom(3,2) = 8
c
      aresom(0,3) = 3
      aresom(1,3) = 1
      aresom(2,3) = 3
      aresom(3,3) = 9
c
      aresom(0,4) = 4
      aresom(1,4) = 4
      aresom(2,4) = 5
      aresom(3,4) = 7
c
      aresom(0,5) = 5
      aresom(1,5) = 5
      aresom(2,5) = 6
      aresom(3,5) = 8
c
      aresom(0,6) = 6
      aresom(1,6) = 6
      aresom(2,6) = 4
      aresom(3,6) = 9
c
c 4.2. ==> fonction generique
c
      iaux = 6
      daux = sqrt(3.d0)/2.d0
      call utqjno (   iaux, aresom,   daux,
     >              listar, listso, somare, coonoe,
     >              qualij )
cgn      write(1,*) '==> qualij : ', qualij
c
      end
