      subroutine utqte2 ( qualit, volume,
     >                    coonoe, s1, s2, cooso3, cooso4 )
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
c    UTilitaire : Qualite d'un TEtraedre 2
c    --           -            ---       _ 
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . qualit .  s  .  1     . qualite                                    .
c . volume .  s  .  1     . volume                                     .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c . s1     . e   . 1      . numero global du sommet 1                  .
c . s2     . e   . 1      . numero global du sommet 2                  .
c . cooso3 . e   . 3      . coordonnees du sommet 3                    .
c . cooso4 . e   . 3      . coordonnees du sommet 4                    . 
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
#include "fracte.h"
c
c 0.3. ==> arguments
c
      double precision qualit, volume
      double precision coonoe(nbnoto,3)
      integer s1,s2
      double precision cooso3(3), cooso4(3)
c
c 0.4. ==> variables locales
c      
      double precision sf1, sf2, sf3, sf4, sixvol
      double precision ar1, ar2, ar3, ar4, ar5, ar6
      double precision v1(3), v3(3), v4(3), v6(3), vn(3)
c
c 1.3. ==> on ne memorise que les vecteurs des aretes 1 3 4 et 6
c
      v1(1) = coonoe(s2,1)-coonoe(s1,1)
      v1(2) = coonoe(s2,2)-coonoe(s1,2)
      v1(3) = coonoe(s2,3)-coonoe(s1,3)
      ar1 = sqrt ( v1(1)*v1(1) + v1(2)*v1(2) + v1(3)*v1(3) )
c     longueur arete 2
      vn(1) = cooso3(1)-coonoe(s1,1)
      vn(2) = cooso3(2)-coonoe(s1,2)
      vn(3) = cooso3(3)-coonoe(s1,3)
      ar2 = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
      v3(1) = cooso4(1)-coonoe(s1,1)
      v3(2) = cooso4(2)-coonoe(s1,2)
      v3(3) = cooso4(3)-coonoe(s1,3)
      ar3 = sqrt ( v3(1)*v3(1) + v3(2)*v3(2) + v3(3)*v3(3) )
c
      v4(1) = cooso3(1)-coonoe(s2,1)
      v4(2) = cooso3(2)-coonoe(s2,2)
      v4(3) = cooso3(3)-coonoe(s2,3)
      ar4 = sqrt ( v4(1)*v4(1) + v4(2)*v4(2) + v4(3)*v4(3) )
c
      vn(1) = cooso4(1)-coonoe(s2,1)
      vn(2) = cooso4(2)-coonoe(s2,2)
      vn(3) = cooso4(3)-coonoe(s2,3)
      ar5 = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
      v6(1) = cooso4(1)-cooso3(1)
      v6(2) = cooso4(2)-cooso3(2)
      v6(3) = cooso4(3)-cooso3(3)
      ar6 = sqrt ( v6(1)*v6(1) + v6(2)*v6(2) + v6(3)*v6(3) )
c
c 1.4. ==> calcul des 4 surfaces (plutot 2 fois les surfaces)
c           on rappelle que la surface d'un triangle est egale
c           a la moitie de la norme du produit vectoriel de deux
c           des vecteurs representant les aretes.
c
      vn(1) = v6(2)*v4(3) - v6(3)*v4(2)
      vn(2) = v6(3)*v4(1) - v6(1)*v4(3)
      vn(3) = v6(1)*v4(2) - v6(2)*v4(1)
      sf1 = vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3)
c
      vn(1) = v6(2)*v3(3) - v6(3)*v3(2)
      vn(2) = v6(3)*v3(1) - v6(1)*v3(3)
      vn(3) = v6(1)*v3(2) - v6(2)*v3(1)
      sf2 = vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3)
c
      vn(1) = v1(2)*v3(3) - v1(3)*v3(2)
      vn(2) = v1(3)*v3(1) - v1(1)*v3(3)
      vn(3) = v1(1)*v3(2) - v1(2)*v3(1)
      sf3 = vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3)
c
      vn(1) = v1(2)*v4(3) - v1(3)*v4(2)
      vn(2) = v1(3)*v4(1) - v1(1)*v4(3)
      vn(3) = v1(1)*v4(2) - v1(2)*v4(1)
      sf4 = vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3)
c
c 1.5. ==> calcul du volume du tetraedre (plutot de 6 fois le volume)
c          on rappelle que le volume d'un tetraedre est egal au
c          sixieme de la valeur absolue du produit mixte de trois
c          des vecteurs representant les aretes.
c          vn = v1xv4 --> volume = 1/6 * produit mixte (v1,v4,v3)
c
      sixvol = abs ( vn(1)*v3(1) + vn(2)*v3(2) + vn(3)*v3(3) )
c
c 1.6. ==> volume et qualite
c
      volume = unssix * sixvol
c
c 7.65 est la normalisation pour 1 cube
      qualit =  max(ar1,ar2,ar3,ar4,ar5,ar6)/7.6569d0
     >     * (sqrt(sf1)+sqrt(sf2)+sqrt(sf3)+sqrt(sf4)) / sixvol
c
      end
