      subroutine utnmqu ( lequad, noeumi,
     >                    somare, arequa, filqua )
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
c    UTilitaire - Noeud Milieu d'un QUadrangle
c    --           -     -           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   . 1      . numero du quadrangle a examiner            .
c . noeumi .  s  . 1      . numero du noeud milieu                     .
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
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
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer lequad, noeumi
      integer somare(2,*)
      integer arequa(nbquto,4), filqua(*)
c
c 0.4. ==> variables locales
c
c     f1hp = Fils 1er du quadrangle en numerotation Homard a l'it. N+1
      integer f1hp
c
c====
c 1. recherche du noeud sommet central
c    Pour le connaitre, on examine le premier fils du quadrangle. C'est
c    la seconde extremite de sa deuxieme arete.
c    Remarque : regarder cmrdqu pour ces conventions
c====
c
c     le fils aine
c
      f1hp = filqua(lequad)
c
c     recuperation du noeud sommet central : le second sommet
c     de la troisieme arete, que ce soit pour le decoupage standard
c     en 4 quadrangles (cf. cmrdqu) ou pour le decoupage de
c     conformite en 3 quadrangles (cf. cmcdqu)
c
      noeumi = somare(2,arequa(f1hp,3))
c
      end
