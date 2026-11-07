      subroutine utpmhe ( lehexa, prmixt,
     >                    som1, som2, som3, som4,
     >                    coonoe, somare, arequa,
     >                    quahex, coquhe, arehex )
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
c     UTilitaire : Produit Mixte d'un HExaedre
c     --           -       -          --
c         selon (som1-som2, som1-som3, som1-som4)
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .  1     . numero du tetraedre a examiner             .
c . prmixt .  s  .  1     . produit mixte (12, 13, 14)                 .
c . som i  . e   .  1     . sommets definissant le produit mixte       .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
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
#include "nombqu.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      double precision prmixt, coonoe(nbnoto,3)
c
      integer lehexa
      integer som1, som2, som3, som4
      integer somare(2,nbarto)
      integer arequa(nbquto,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer listar(12)
      integer listso(8)
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
c 1.1. ==> les aretes et sommets de cet hexaedre
c
      call utashe ( lehexa,
     >              nbquto, nbhecf, nbheca,
     >              somare, arequa,
     >              quahex, coquhe, arehex,
     >              listar, listso )
c
c 1.2. ==> memorisation des vecteurs lies
c          aux aretes som1-som2, som1-som3, som1-som4
c
      v12(1) = coonoe(listso(som2),1) - coonoe(listso(som1),1)
      v12(2) = coonoe(listso(som2),2) - coonoe(listso(som1),2)
      v12(3) = coonoe(listso(som2),3) - coonoe(listso(som1),3)
c
      v13(1) = coonoe(listso(som3),1) - coonoe(listso(som1),1)
      v13(2) = coonoe(listso(som3),2) - coonoe(listso(som1),2)
      v13(3) = coonoe(listso(som3),3) - coonoe(listso(som1),3)
c
      v14(1) = coonoe(listso(som4),1) - coonoe(listso(som1),1)
      v14(2) = coonoe(listso(som4),2) - coonoe(listso(som1),2)
      v14(3) = coonoe(listso(som4),3) - coonoe(listso(som1),3)
c
c 1.3. ==> calcul du produit mixte (v12,v13,v14)
c
      prmixt = ( v12(2)*v13(3) - v12(3)*v13(2) ) * v14(1)
     >       + ( v12(3)*v13(1) - v12(1)*v13(3) ) * v14(2)
     >       + ( v12(1)*v13(2) - v12(2)*v13(1) ) * v14(3)
c
      end
