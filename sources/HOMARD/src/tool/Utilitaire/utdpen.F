      subroutine utdpen ( lepent, diamet,
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
c     UTilitaire : Diametre d'un PENtaedre
c     --           -             ---
c ______________________________________________________________________
c
c    Le diametre d'une maille est la longueur du plus grand segment que
c    l'on peut tracer a l'interieur de cette maille.
c    Pour un pentaedre, le diametre est le maximum des longueurs des
c    aretes et des diagonales
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .  1     . numero du tetraedre a examiner             .
c . diamet .  s  .  1     . qualite                                    .
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
      double precision diamet, coonoe(nbnoto,3)
c
      integer lepent
      integer somare(2,nbarto)
      integer arequa(nbquto,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
c
c 0.4. ==> variables locales
c
      integer s1, s2, s3, s4, s5, s6
c
      integer listar(9), listso(6)
      integer iaux
c
      double precision var(3)
      double precision ar1, ar2, ar3, ar4, ar5, ar6
      double precision ar7, ar8, ar9
      double precision ad1, ad2, ad3, ad4, ad5, ad6
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
      s1 = listso(1)
      s2 = listso(2)
      s3 = listso(3)
      s4 = listso(4)
      s5 = listso(5)
      s6 = listso(6)
c
c====
c 2. les carres des longueurs des 9 aretes et des 6 diagonales
c====
c
      var(1) = coonoe(s3,1) - coonoe(s1,1)
      var(2) = coonoe(s3,2) - coonoe(s1,2)
      var(3) = coonoe(s3,3) - coonoe(s1,3)
      ar1 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s2,1) - coonoe(s1,1)
      var(2) = coonoe(s2,2) - coonoe(s1,2)
      var(3) = coonoe(s2,3) - coonoe(s1,3)
      ar2 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s3,1) - coonoe(s2,1)
      var(2) = coonoe(s3,2) - coonoe(s2,2)
      var(3) = coonoe(s3,3) - coonoe(s2,3)
      ar3 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s4,1) - coonoe(s6,1)
      var(2) = coonoe(s4,2) - coonoe(s6,2)
      var(3) = coonoe(s4,3) - coonoe(s6,3)
      ar4 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s4,1) - coonoe(s5,1)
      var(2) = coonoe(s4,2) - coonoe(s5,2)
      var(3) = coonoe(s4,3) - coonoe(s5,3)
      ar5 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s5,1) - coonoe(s6,1)
      var(2) = coonoe(s5,2) - coonoe(s6,2)
      var(3) = coonoe(s5,3) - coonoe(s6,3)
      ar6 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s4,1) - coonoe(s1,1)
      var(2) = coonoe(s4,2) - coonoe(s1,2)
      var(3) = coonoe(s4,3) - coonoe(s1,3)
      ar7 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s5,1) - coonoe(s2,1)
      var(2) = coonoe(s5,2) - coonoe(s2,2)
      var(3) = coonoe(s5,3) - coonoe(s2,3)
      ar8 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s6,1) - coonoe(s3,1)
      var(2) = coonoe(s6,2) - coonoe(s3,2)
      var(3) = coonoe(s6,3) - coonoe(s3,3)
      ar9 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s5,1) - coonoe(s1,1)
      var(2) = coonoe(s5,2) - coonoe(s1,2)
      var(3) = coonoe(s5,3) - coonoe(s1,3)
      ad1 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s6,1) - coonoe(s1,1)
      var(2) = coonoe(s6,2) - coonoe(s1,2)
      var(3) = coonoe(s6,3) - coonoe(s1,3)
      ad2 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s4,1) - coonoe(s2,1)
      var(2) = coonoe(s4,2) - coonoe(s2,2)
      var(3) = coonoe(s4,3) - coonoe(s2,3)
      ad3 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s6,1) - coonoe(s2,1)
      var(2) = coonoe(s6,2) - coonoe(s2,2)
      var(3) = coonoe(s6,3) - coonoe(s2,3)
      ad4 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s4,1) - coonoe(s3,1)
      var(2) = coonoe(s4,2) - coonoe(s3,2)
      var(3) = coonoe(s4,3) - coonoe(s3,3)
      ad5 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
      var(1) = coonoe(s5,1) - coonoe(s3,1)
      var(2) = coonoe(s5,2) - coonoe(s3,2)
      var(3) = coonoe(s5,3) - coonoe(s3,3)
      ad6 = var(1)*var(1) + var(2)*var(2) + var(3)*var(3)
c
c====
c 3. diametre
c    on ne prend la racine carre qu'ici pour economiser du temps calcul
c====
c
      diamet = max( ar1, ar2, ar3,  ar4,  ar5,  ar6,
     >              ar7, ar8, ar9,
     >              ad1, ad2, ad3, ad4, ad5, ad6 )
      diamet = sqrt(diamet)
c
      end
