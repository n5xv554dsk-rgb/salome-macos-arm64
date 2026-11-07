      subroutine dmindf ( iindef, rindef, sindef )
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
c   Dependance Machine : valeurs INDeFinies
c   -          -                 --- -
c ______________________________________________________________________
c
c  affecte les valeurs indefinies
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . iindef .  s  .    1   . valeur indefinie entiere                   .
c . rindef .  s  .    1   . valeur indefinie double precision reelle   .
c . sindef .  s  .   c8   . valeur indefinie caractere                 .
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
      integer iindef
c
      double precision rindef
c
      character*8 sindef
c
c 0.4. ==> variables locales
c
c====
c 1. On met une tres grande valeur, reconnaissble
c====
c
      iindef = 17891792
c
      rindef = 1848.1871d12
c
      sindef = 'INDEFINI'
c
      end
