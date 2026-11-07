      subroutine cmcqua
     >                ( arequa, famqua, hetqua, filqua, perqua, nivqua,
     >                  nuquad, arete1, arete2, arete3, arete4,
     >                  codequ, niveau )
c
c
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
c    Creation du Maillage - Creation d'un Quadrangle
c    -           -          -             ---
c ______________________________________________________________________
c
c but : creation effective d'un quadrangle etant donne :
c       - le niveau du quadrangle
c       - le numero du quadrangle
c       - les numero globaux des aretes locales 1,2 et 3
c       - le code du quadrangle qui permet en appliquant les fonctions
c         i1, i2, i3 de determiner le numero d'ordre des aretes dans le
c         quadruplet de definition du quadrangle
c      remarque : l'ordre local des aretes et le code du quadrangle sont
c       fonction de l'element sur lequel on travail lors de l'appel de
c       ce sous-programme
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . arequa . es  .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . hetqua . es  . nouvqu . historique de l'etat des quadrangles       .
c . filqua . es  . nouvqu . premier fils des quadrangles               .
c . perqua . es  . nouvqu . pere des quadrangles                       .
c . nivqua . es  . nouvqu . niveau des quadrangles                     .
c . famqua . es  . nouvqu . famille des quadrangles                    .
c . nuquad . e   . 1      . numero du quadrangle a creer               .
c . arete1 . e   . 1      . arete de numero local 1 dans le quadrangle .
c . arete2 . e   . 1      . arete de numero local 2 dans le quadrangle .
c . arete3 . e   . 1      . arete de numero local 3 dans le quadrangle .
c . arete4 . e   . 1      . arete de numero local 4 dans le quadrangle .
c . codequ . e   . 1      . code du quadrangle                         .
c . niveau . e   . 1      . niveau du quadrangle                       .
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
#include "j1234j.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer arequa(nouvqu,4), famqua(nouvqu)
      integer hetqua(nouvqu), filqua(nouvqu), perqua(nouvqu)
      integer nivqua(nouvqu)
      integer nuquad, arete1, arete2, arete3, arete4, codequ, niveau
c
c 0.4. ==> variables locales
c
c ______________________________________________________________________
c
c====
c 1. creation effective d'un quadrangle
c====
c
      arequa(nuquad,j1(codequ)) = arete1
      arequa(nuquad,j2(codequ)) = arete2
      arequa(nuquad,j3(codequ)) = arete3
      arequa(nuquad,j4(codequ)) = arete4
c
      famqua(nuquad) = 1
c
      hetqua(nuquad)  = 5500
      filqua(nuquad)  = 0
      perqua(nuquad)  = 0
      nivqua(nuquad)  = niveau
c
      end
