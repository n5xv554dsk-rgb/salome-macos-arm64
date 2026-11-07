      subroutine uttoqu (s1, s2, s3, s4, coonoe, torsio)
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
c     UTilitaire : TOrsion d'un QUadrangle
c     --           --           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c .s1/2/3/4. e   .  1     . les noeuds de la face                      .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . torsio .  s  .  1     . torsion de la face entre 0, plane, et 2    .
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
c
c 0.3. ==> arguments
c
      integer s1, s2, s3, s4
c
      double precision coonoe(nbnoto,3)
      double precision torsio
c
c 0.4. ==> variables locales
c
      integer iaux
c
      double precision n1(3), n2(3)
      double precision vs1s2(3), vs1s3(3)
      double precision vs1s4(3), vs2s4(3), vs3s4(3)
      double precision daux
c
#include "impr03.h"
c
c====
c 1. Traitement par la diagonale s1/s3
c====
c
c          s1                       s2
c           -------------------------
c           .   .                   .
c           .       .               .
c           .           .           .
c           .               .       .
c           .                   .   .
c           -------------------------
c          s4                       s3
c   Attention a prendre la meme orientation pour les deux normales !
c
c 1.1. ==> Vecteur normal au triangle (s1,s2,s3)
c
cgn      write(*,90002) 'triangle des sommets', s1, s2, s3
      vs1s2(1) = coonoe(s2,1) - coonoe(s1,1)
      vs1s2(2) = coonoe(s2,2) - coonoe(s1,2)
      vs1s2(3) = coonoe(s2,3) - coonoe(s1,3)
c
      vs1s3(1) = coonoe(s3,1) - coonoe(s1,1)
      vs1s3(2) = coonoe(s3,2) - coonoe(s1,2)
      vs1s3(3) = coonoe(s3,3) - coonoe(s1,3)
c
      n1(1) = vs1s3(2)*vs1s2(3) - vs1s3(3)*vs1s2(2)
      n1(2) = vs1s3(3)*vs1s2(1) - vs1s3(1)*vs1s2(3)
      n1(3) = vs1s3(1)*vs1s2(2) - vs1s3(2)*vs1s2(1)
c
      daux = sqrt(n1(1)*n1(1)+n1(2)*n1(2)+n1(3)*n1(3))
      do 11 , iaux = 1 , 3
        n1(iaux) = n1(iaux)/daux
   11 continue
cgn      write(*,92010) 11, n1
c
c 1.2. ==> Vecteur normal au triangle (s1,s4,s3)
c
cgn      write(*,90002) 'triangle des sommets', s1, s3, s4
      vs1s4(1) = coonoe(s4,1) - coonoe(s1,1)
      vs1s4(2) = coonoe(s4,2) - coonoe(s1,2)
      vs1s4(3) = coonoe(s4,3) - coonoe(s1,3)
c
      n2(1) = vs1s3(2)*vs1s4(3) - vs1s3(3)*vs1s4(2)
      n2(2) = vs1s3(3)*vs1s4(1) - vs1s3(1)*vs1s4(3)
      n2(3) = vs1s3(1)*vs1s4(2) - vs1s3(2)*vs1s4(1)
c
      daux = sqrt(n2(1)*n2(1)+n2(2)*n2(2)+n2(3)*n2(3))
      do 12 , iaux = 1 , 3
        n2(iaux) = -n2(iaux)/daux
   12 continue
cgn      write(*,92010) 12, n2
c
c 1.3. ==> Produit scalaire des vecteurs normaux
c
      torsio = n1(1)*n2(1) + n1(2)*n2(2) + n1(3)*n2(3)
cgn      write(*,92010) n1(1)*n2(1) + n1(2)*n2(2) + n1(3)*n2(3)
c
c====
c 2. Traitement par la diagonale s2/s4
c====
c
c          s1                       s2
c           -------------------------
c           .                   .   .
c           .               .       .
c           .           .           .
c           .       .               .
c           .   .                   .
c           -------------------------
c          s4                       s3
c   Attention a prendre la meme orientation pour les deux normales !
c
c 2.1. ==> Vecteur normal au triangle (s4,s1,s2)
c
cgn      write(*,90002) 'triangle des sommets', s4,s1,s2
      vs2s4(1) = coonoe(s4,1) - coonoe(s2,1)
      vs2s4(2) = coonoe(s4,2) - coonoe(s2,2)
      vs2s4(3) = coonoe(s4,3) - coonoe(s2,3)
c
      n1(1) = vs2s4(2)*vs1s4(3) - vs2s4(3)*vs1s4(2)
      n1(2) = vs2s4(3)*vs1s4(1) - vs2s4(1)*vs1s4(3)
      n1(3) = vs2s4(1)*vs1s4(2) - vs2s4(2)*vs1s4(1)
c
      daux = sqrt(n1(1)*n1(1)+n1(2)*n1(2)+n1(3)*n1(3))
      do 21 , iaux = 1 , 3
        n1(iaux) = n1(iaux)/daux
   21 continue
cgn      write(*,92010) 21, n1
c
c 2.2. ==> Vecteur normal au triangle (s1,s4,s3)
c
cgn      write(*,90002) 'triangle des sommets', s4, s2, s3
      vs3s4(1) = coonoe(s4,1) - coonoe(s3,1)
      vs3s4(2) = coonoe(s4,2) - coonoe(s3,2)
      vs3s4(3) = coonoe(s4,3) - coonoe(s3,3)
c
      n2(1) = vs3s4(2)*vs2s4(3) - vs3s4(3)*vs2s4(2)
      n2(2) = vs3s4(3)*vs2s4(1) - vs3s4(1)*vs2s4(3)
      n2(3) = vs3s4(1)*vs2s4(2) - vs3s4(2)*vs2s4(1)
c
      daux = sqrt(n2(1)*n2(1)+n2(2)*n2(2)+n2(3)*n2(3))
      do 22 , iaux = 1 , 3
        n2(iaux) = n2(iaux)/daux
   22 continue
cgn      write(*,92010) 22, n2
c
c 2.3. ==> Produit scalaire des vecteurs normaux
c
      torsio = min ( torsio, n1(1)*n2(1) + n1(2)*n2(2) + n1(3)*n2(3) )
cgn      write(*,92010) n1(1)*n2(1) + n1(2)*n2(2) + n1(3)*n2(3)
c
c====
c 3. Torsion : Le produit scalaire des vecteurs normaux vaut 1 s'ils
c    sont colineaires. La torsion vaudra alors 0. A l'extreme, pour
c    deux triangles opposes, le produit scalaire vaut -1 et la
c    torsion vaudra 2.
c    Remarque : on prend la valeur absolue pour eviter les affichages
c               en -0.00000
c====
c
      torsio = abs(1.d0 - torsio)
c
      end
