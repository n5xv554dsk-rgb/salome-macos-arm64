      subroutine cmctet ( tritet, cotrte, famtet,
     >                    hettet, filtet, pertet,
     >                    ntria1, ntria2, ntria3, ntria4,
     >                    codef1, codef2, codef3, codef4,
     >                    nupere, famill, nutetr )
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
c    Creation du Maillage - Creation d'un TETraedre
c    -           -          -             ---
c ______________________________________________________________________
c
c but : creation effective d'un tetraedre etant donne :
c       - le numero du tetraedre
c       - les numero globaux des faces locales 1, 2, 3 et 4
c       - les codes des faces
c       - le numero du pere
c       - la famille a attribuer
c       ce sous-programme est valable pour les tetraedres qui ne
c       conservent aucune face de leur pere : tous sauf les tetraedres
c       issus d'un decoupage en deux.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . es  .nouvtf*4. code des 4 triangles des tetraedres        .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . ntria1 . e   . 1      . face de numero local 1 dans le tetraedre   .
c . ntria2 . e   . 1      . face de numero local 2 dans le tetraedre   .
c . ntria3 . e   . 1      . face de numero local 3 dans le tetraedre   .
c . ntria4 . e   . 1      . face de numero local 4 dans le tetraedre   .
c . codef1 . e   . 1      . code de la face 1                          .
c . codef2 . e   . 1      . code de la face 2                          .
c . codef3 . e   . 1      . code de la face 3                          .
c . codef4 . e   . 1      . code de la face 4                          .
c . nupere . e   . 1      . numero du pere du tetraedre                .
c . famill . e   . 1      . famille a attribuer au tetraedre           .
c . nutetr . e   . 1      . numero du tetraedre a creer                .
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
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer tritet(nouvtf,4), cotrte(nouvtf,4), famtet(nouvte)
      integer hettet(nouvte), filtet(nouvte), pertet(nouvte)
      integer ntria1, ntria2, ntria3, ntria4
      integer codef1, codef2, codef3, codef4
      integer nupere, famill, nutetr
c
c 0.4. ==> variables locales
c
c ______________________________________________________________________
c
c====
c 1. creation effective d'un tetraedre
c====
c
#ifdef _DEBUG_HOMARD_
#include "impr03.h"
      write (1,90015) 'Tetraedre', nutetr,
     >                ', faces', ntria1, ntria2, ntria3, ntria4
      write (1,90015) 'Tetraedre', nutetr,
     >                ', codes', codef1, codef2, codef3, codef4
#endif
      tritet(nutetr,1) = ntria1
      tritet(nutetr,2) = ntria2
      tritet(nutetr,3) = ntria3
      tritet(nutetr,4) = ntria4
c
      cotrte(nutetr,1) = codef1
      cotrte(nutetr,2) = codef2
      cotrte(nutetr,3) = codef3
      cotrte(nutetr,4) = codef4
c
      famtet(nutetr) = famill
c
      hettet(nutetr) = 5500
      filtet(nutetr) = 0
      pertet(nutetr) = nupere
c
      end
