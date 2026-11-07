      subroutine dmze10 ( vinfpo, zero, pd10vi, pd10ze )
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
c   Dependance Machine : ZEros en puissance de 10
c   -          -         --                    --
c ______________________________________________________________________
c
c
c  retourne la plus petite et la plus grande valeur possible
c  et leurs puissances de 10 associees : x = 0.abc*10**n
c  exemple : avec x = 1.e9,  on a x = 0.1*10**10, donc n = 10
c            avec x = 1.e-40, on a x = 0.1*10**-39, donc n = -39
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . vinfpo .  s  .  dp    . plus grande valeur positive possible       .
c . zero   .  s  .  dp    . le zero de la machine                      .
c . pd10vi .  s  .   i    . la puissance de 10 associee a vinfpo       .
c . pd10ze .  s  .   i    . la puissance de 10 associee a zero         .
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
c 0.3. ==> arguments
c
      double precision vinfpo, zero
      integer pd10vi, pd10ze
c
c 0.4. ==> variables locales
c
c 0.5. ==> initialisations
c
c====
c 1. les valeurs extremes
c===
c
c 1.1. ==> le maximum
c
      vinfpo = 1.d29
      pd10vi = 30
c
c 1.2. ==> le minimum : l'inverse du maximum
c
      zero = 1.d0 / vinfpo
c
c 1.3. ==> les puissances de 10 associees
c
      pd10ze = 2 - pd10vi
c
      end
