      subroutine utsen3 ( memeco,
     >                    coose1, coose2, coo1, coo2, choix )
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
c    UTilitaire - SEgment - Noeud - dimension 3
c    --           --        -                 -
c ______________________________________________________________________
c
c teste si les deux noeuds de coordonnees coo1 et coo2 sont du meme cote
c par rapport au segment delimite par les sommets de coordonnees
c coose1, coose2
c programme en dimension 3
c remarque : on suppose que tous les noeuds sont dans le meme plan
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . memeco .  s  . 1      . vrai ou faux selon que les noeuds sont du  .
c .        .     .        . meme cote du segment ou non                .
c . coose1 . e   .   3    . coordonnees du sommet 1 du segment         .
c . coose2 . e   .   3    . coordonnees du sommet 2 du segment         .
c . coo1   . e   .   3    . coordonnees du premier noeud               .
c . coo2   . e   .   3    . coordonnees du second noeud                .
c . choix  . e   .   1    . 1, si on accepte un noeud sur le segment   .
c .        .     .        . 0, si on rejette un noeud sur le segment   .
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
cgn      character*6 nompro
cgn      parameter ( nompro = 'UTSEN3' )
c
c 0.2. ==> communs
c
#include "precis.h"
c
c 0.3. ==> arguments
c
      integer choix
c
      double precision coose1(3), coose2(3), coo1(3), coo2(3)
c
      logical memeco
c
c 0.4. ==> variables locales
c
      double precision pvect1(3), pvect2(3)
      double precision daux1

c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c     pour analyser les cas ou le noeud est sur le segment, on utilise
c     deux versions du test selon la demande.
c     si on exclut le segment, il faut tester strictement positif
c     si on l'accepte, on tolere une egalite a zero.
c
      if ( choix.eq.0 ) then
        daux1 = epsima
      else
        daux1 = -epsima
      endif
c
c====
c 2. Controle
c    On compare les directions des produits vectoriels entre le
c    vecteur directeur du segment et le vecteur entre un sommet et
c    le noeud a tester.
c    Pour pouvoir pieger les cas ou le noeud est sur le segment, on
c    teste le caractere strictement positif ou positif du produit
c    scalaire selon la demande.
c====
cgn 1000 format('. ',a,' :',3g13.5)
cgn      write (1,1000) 'coose1 ', coose1(1), coose1(2), coose1(3)
cgn      write (1,1000) 'coose2 ', coose2(1), coose2(2), coose2(3)
cgn      write (1,1000) 'coo1', coo1(1), coo1(2), coo1(3)
cgn      write (1,1000) 'coo2', coo2(1), coo2(2), coo2(3)
c
c 2.1. ==>  pvect1 represente le produit vectoriel s1s2 x s1n1
c
      pvect1(1) = (coose2(2)-coose1(2)) * (coo1(3)-coose1(3))
     >          - (coose2(3)-coose1(3)) * (coo1(2)-coose1(2))
c
      pvect1(2) = (coose2(3)-coose1(3)) * (coo1(1)-coose1(1))
     >          - (coose2(1)-coose1(1)) * (coo1(3)-coose1(3))
c
      pvect1(3) = (coose2(1)-coose1(1)) * (coo1(2)-coose1(2))
     >          - (coose2(2)-coose1(2)) * (coo1(1)-coose1(1))
c
c 2.2. ==>  pvect2 represente le produit vectoriel s1s2 x s1n2

      pvect2(1) = (coose2(2)-coose1(2)) * (coo2(3)-coose1(3))
     >          - (coose2(3)-coose1(3)) * (coo2(2)-coose1(2))
c
      pvect2(2) = (coose2(3)-coose1(3)) * (coo2(1)-coose1(1))
     >          - (coose2(1)-coose1(1)) * (coo2(3)-coose1(3))
c
      pvect2(3) = (coose2(1)-coose1(1)) * (coo2(2)-coose1(2))
     >          - (coose2(2)-coose1(2)) * (coo2(1)-coose1(1))
c
cgn      write (1,1000) 'pvect1', pvect1
cgn      write (1,1000) 'pvect2', pvect2
cgn      write (1,1000) 'pvect1*pvect2', pvect1(1)*pvect2(1) +
cgn     >                                pvect1(2)*pvect2(2) +
cgn     >                                pvect1(3)*pvect2(3)
      if ( ( pvect1(1)*pvect2(1) +
     >       pvect1(2)*pvect2(2) +
     >       pvect1(3)*pvect2(3) ) .lt.daux1 ) then
        memeco = .false.
      else
        memeco = .true.
      endif
c
      end
