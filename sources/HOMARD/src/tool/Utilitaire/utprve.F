      subroutine utprve ( v1, v2, res )
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
c   UTilitaire : PRoduit VEctoriel
c   --           --      --
c     effectue res = V1^V2
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .  V1    . e   .   3    . premier vecteur                            .
c .  V2    . e   .   3    . deuxieme vecteur                           .
c . res    .  s  .   3    . Le resultat                                .
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
c
c 0.3. ==> arguments
c
      double precision v1(3), v2(3), res(3)
c
c 0.4. ==> variables locales
c
      res(1) = v1(2)*v2(3) - v1(3)*v2(2)
      res(2) = v1(3)*v2(1) - v1(1)*v2(3)
      res(3) = v1(1)*v2(2) - v1(2)*v2(1)
c
      end
