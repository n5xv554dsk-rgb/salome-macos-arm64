      subroutine cmctri ( aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
     >                    nutria, arete1, arete2, arete3,
     >                    codetr, niveau )
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
c    Creation du Maillage - Creation d'un TRIangle
c    -           -          -             ---
c ______________________________________________________________________
c
c but : creation effective d'un triangle etant donne :
c       - le niveau du triangle
c       - le numero du triangle
c       - les numero globaux des aretes locales 1,2 et 3
c       - le code du triangle qui permet en appliquant les fonctions
c         i1, i2, i3 de determiner le numero d'ordre des aretes dans le
c         triplet de definition du triangle
c       remarque : l'ordre local des aretes et le code du triangle sont
c       fonction de l'element sur lequel on travail lors de l'appel de
c       ce sous-programme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . famtri . es  . nouvtr . famille des triangles                      .
c . nutria . e   . 1      . numero du triangle a creer                 .
c . arete1 . e   . 1      . arete de numero local 1 dans le triangle   .
c . arete2 . e   . 1      . arete de numero local 2 dans le triangle   .
c . arete3 . e   . 1      . arete de numero local 3 dans le triangle   .
c . codetr . e   . 1      . code du triangle                           .
c . niveau . e   . 1      . niveau a attribuer au triangle             .
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
#include "i1i2i3.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer aretri(nouvtr,3), famtri(nouvtr)
      integer hettri(nouvtr), filtri(nouvtr), pertri(nouvtr)
      integer nivtri(nouvtr)
      integer nutria, arete1, arete2, arete3, codetr, niveau
c
c 0.4. ==> variables locales
c ______________________________________________________________________
c
c====
c 1. creation effective d'un triangle
c====
c
#ifdef _DEBUG_HOMARD_
#include "impr03.h"
      write (1,90015) 'Triangle', nutria,
     >                ', aretes', arete1, arete2, arete3
#endif
      aretri(nutria,i1(codetr)) = arete1
      aretri(nutria,i2(codetr)) = arete2
      aretri(nutria,i3(codetr)) = arete3
c
      famtri(nutria) = 1
c
      hettri(nutria)  = 50
      filtri(nutria)  = 0
      pertri(nutria)  = 0
      nivtri(nutria)  = niveau
c
      end
