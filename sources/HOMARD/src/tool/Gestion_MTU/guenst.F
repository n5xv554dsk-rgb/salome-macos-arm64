      subroutine guenst ( nuroul )
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
c but : recuperer l'unite associee a l'entree standard
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nuroul .  s  .    1   . numero de l'unite logique attribuee        .
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
      integer nuroul
c
c 0.4. ==> variables locales
c
      integer codret
      integer lfichi
      character*200 fichie
c ______________________________________________________________________
c
c===
c 1. appel du programme generique avec un nom de fichier bidon
c===
c
      fichie = ' '
      lfichi = -1
c
      call gucara ( fichie, lfichi, nuroul, codret )
c
      end
