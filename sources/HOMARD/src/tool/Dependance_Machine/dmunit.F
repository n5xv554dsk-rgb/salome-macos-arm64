      subroutine dmunit ( enstul, sostul )
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
c   Dependance Machine : UNITes logiques d'entree et de sortie standard
c   -          -         ----
c ______________________________________________________________________
c
c but : retourne les numeros d'entree et de sortie standard sur
c       la machine concernee
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . enstul .  s  .    1   . entree standard : numero de l'unite logique.
c . sostul .  s  .    1   . sortie standard : numero de l'unite logique.
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
      integer enstul, sostul
c
c 0.4. ==> variables locales
c
c====
c 1. affectation
c====
c
      enstul = 5
c
      sostul = 6
c
      end
