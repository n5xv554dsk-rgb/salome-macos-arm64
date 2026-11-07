      subroutine utpmte ( letetr, prmixt,
     >                    coonoe, somare, aretri,
     >                    tritet, cotrte, aretet )
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
c     UTilitaire : Produit Mixte d'un TEtraedre selon (12, 13, 14)
c     --           -       -          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letetr . e   .  1     . numero du tetraedre a examiner             .
c . prmixt .  s  .  1     . produit mixte (12, 13, 14)                 .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
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
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
c
c 0.3. ==> arguments
c
      double precision prmixt, coonoe(nbnoto,3)
c
      integer letetr
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer listar(6)
      integer listso(4)
c
      double precision v12(3), v13(3), v14(3)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. traitement
c====
c
c 1.1. ==> les aretes et sommets de ce tetraedre
c
      call utaste ( letetr,
     >              nbtrto, nbtecf, nbteca,
     >              somare, aretri,
     >              tritet, cotrte, aretet,
     >              listar, listso )
c
c 1.2. ==> memorisation des vecteurs lies aux aretes 12, 13, 14
c
      v12(1) = coonoe(listso(2),1) - coonoe(listso(1),1)
      v12(2) = coonoe(listso(2),2) - coonoe(listso(1),2)
      v12(3) = coonoe(listso(2),3) - coonoe(listso(1),3)
c
      v13(1) = coonoe(listso(3),1) - coonoe(listso(1),1)
      v13(2) = coonoe(listso(3),2) - coonoe(listso(1),2)
      v13(3) = coonoe(listso(3),3) - coonoe(listso(1),3)
c
      v14(1) = coonoe(listso(4),1) - coonoe(listso(1),1)
      v14(2) = coonoe(listso(4),2) - coonoe(listso(1),2)
      v14(3) = coonoe(listso(4),3) - coonoe(listso(1),3)
c
c 1.3. ==> calcul du produit mixte (v12,v13,v14)
c
      prmixt = ( v12(2)*v13(3) - v12(3)*v13(2) ) * v14(1)
     >       + ( v12(3)*v13(1) - v12(1)*v13(3) ) * v14(2)
     >       + ( v12(1)*v13(2) - v12(2)*v13(1) ) * v14(3)
c
      end
