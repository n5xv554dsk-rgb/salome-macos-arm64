      subroutine utprma ( sommet, arete1, arete2, arete3,
     >                    somare, nbnoto, coonoe,
     >                    promix, promin )
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
c   UTilitaire : PRoduit Mixte - par Arete
c   --           --      -           -
c     effectue promix = A1.(A2^A3)
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . sommet . e   .   1    . sommet du triedre                          .
c . arete1 . e   .   1    . premiere arete du triedre                  .
c . arete2 . e   .   1    . premiere arete du triedre                  .
c . arete3 . e   .   1    . premiere arete du triedre                  .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . nbnoto . e   .   1    . nombre de noeuds                           .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . promix .  s  .   1    . le produit mixte brut                      .
c . promin .  s  .   1    . le produit mixte des vecteurs normalises   .
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
      integer sommet
      integer arete1, arete2, arete3
      integer nbnoto
      integer somare(2,*)
c
      double precision coonoe(nbnoto,*)
      double precision promix, promin
c
c 0.4. ==> variables locales
c
      integer iaux
      integer ideb, ifin
c
      double precision daux, daux0
      double precision v1(3), v2(3), v3(3)
      double precision vn(3)
c ______________________________________________________________________
c
c====
c 1. Les vecteurs des aretes
c====
c
      if ( somare(1,arete1).eq.sommet ) then
        ideb = 1
        ifin = 2
      else
        ideb = 2
        ifin = 1
      endif
c
      daux0 = 0.d0
      do 11 , iaux = 1 , 3
        v1(iaux) = coonoe(somare(ifin,arete1),iaux)
     >           - coonoe(somare(ideb,arete1),iaux)
        daux0 = daux0 + v1(iaux)**2
   11 continue
      daux = sqrt(daux0)
c
      if ( somare(1,arete2).eq.sommet ) then
        ideb = 1
        ifin = 2
      else
        ideb = 2
        ifin = 1
      endif
c
      daux0 = 0.d0
      do 12 , iaux = 1 , 3
        v2(iaux) = coonoe(somare(ifin,arete2),iaux)
     >           - coonoe(somare(ideb,arete2),iaux)
        daux0 = daux0 + v2(iaux)**2
   12 continue
      daux = daux*sqrt(daux0)
c
      if ( somare(1,arete3).eq.sommet ) then
        ideb = 1
        ifin = 2
      else
        ideb = 2
        ifin = 1
      endif
c
      daux0 = 0.d0
      do 13 , iaux = 1 , 3
        v3(iaux) = coonoe(somare(ifin,arete3),iaux)
     >           - coonoe(somare(ideb,arete3),iaux)
        daux0 = daux0 + v3(iaux)**2
   13 continue
      daux = daux*sqrt(daux0)
c
      vn(1) = v2(2)*v3(3) - v2(3)*v3(2)
      vn(2) = v2(3)*v3(1) - v2(1)*v3(3)
      vn(3) = v2(1)*v3(2) - v2(2)*v3(1)
c
      promix = v1(1)*vn(1) + v1(2)*vn(2) + v1(3)*vn(3)
      promin = promix/daux
c
      end
