      subroutine utnqua ( lequad, normal,
     >                    nbnoto, nbquto,
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
c     UTilitaire : Normale d'un QUAdrangle
c     --           -            ---
c     Remarque : cela suppose que le quadrangle est plan
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   .  1     . numero du quadrangle a examiner            .
c . normal .  s  .  3     . vecteur de la normale (normalise)          .
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
c 0.3. ==> arguments
c
      integer lequad
c
      integer nbnoto, nbquto
c
      double precision normal(3), coonoe(nbnoto,*)
c
      integer somare(2,*), arequa(nbquto,4)
c
c 0.4. ==> variables locales
c
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
c
      double precision aret1(3), aret2(3)
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
      aret1(1) = coonoe(sa1a2,1) - coonoe(sa4a1,1)
      aret1(2) = coonoe(sa1a2,2) - coonoe(sa4a1,2)
      aret1(3) = coonoe(sa1a2,3) - coonoe(sa4a1,3)
c
      aret2(1) = coonoe(sa2a3,1) - coonoe(sa1a2,1)
      aret2(2) = coonoe(sa2a3,2) - coonoe(sa1a2,2)
      aret2(3) = coonoe(sa2a3,3) - coonoe(sa1a2,3)
c
c====
c 2. normal = produit vectoriel
c====
c
      normal(1) = aret2(2)*aret1(3) - aret2(3)*aret1(2)
      normal(2) = aret2(3)*aret1(1) - aret2(1)*aret1(3)
      normal(3) = aret2(1)*aret1(2) - aret2(2)*aret1(1)
c
      aret1(1) = sqrt ( normal(1)*normal(1) +
     >                  normal(2)*normal(2) +
     >                  normal(3)*normal(3) )
c
      normal(1) = normal(1)/aret1(1)
      normal(2) = normal(2)/aret1(1)
      normal(3) = normal(3)/aret1(1)
c
      end
