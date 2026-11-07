      subroutine dmlocs (var,iad)
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
c   Dependance Machine : LOCalisation en memoire - String
c   -          -         ---                       -
c ______________________________________________________________________
c
c    Ce programme retourne l'adresse en machine ou est la variable var.
c    Il utilise la fonction machine loc qui est une extension par
c    rapport au fortran 77 ansi.
c    Si cette extension n'est pas disponible, on reactivera la
c    fonction C dmloca qui joue sur la facon de passer les arguments :
c    par adresse / par valeur.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . iad    .  s  .   1    . adresse de depart de la zone allouee       .
c . var    . e   .   1    .                                            .
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
      character*8 var
      integer iad
c
c 0.4. ==> variables locales
c ______________________________________________________________________
c
c====
c 1. appel du programme ad-hoc
c====
c
      iad = loc(var)
c
      end
