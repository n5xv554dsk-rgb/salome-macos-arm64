      subroutine cmcpen ( facpen, cofape, fampen,
     >                    hetpen, filpen, perpen,
     >                    nface1, nface2, nface3,
     >                    nface4, nface5,
     >                    codef1, codef2, codef3,
     >                    codef4, codef5,
     >                    nupere, famill, nupent )
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
c    Creation du Maillage - Creation d'un PENtaedre
c    -           -          -             ---
c ______________________________________________________________________
c
c but : creation effective d'un pentaedre etant donne :
c       - le numero du pentaedre
c       - les numeros globaux des faces locales 1,2,3,4 et 5
c       - les codes des faces
c       - le numero du pere
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . facpen . es  .nouvpf*5. numeros des 5 faces des pentaedres         .
c . cofape . es  .nouvpf*5. code des 5 faces des pentaedres            .
c . fampen . es  . nouvpe . famille des pentaedres                     .
c . hetpen . es  . nouvpe . historique de l'etat des pentaedres        .
c . filpen . es  . nouvpe . premier fils des pentaedres                .
c . perpen . es  . nouvpe . pere des pentaedres                        .
c . nface1 . e   . 1      . face de numero local 1 dans le pentaedre   .
c . nface2 . e   . 1      . face de numero local 2 dans le pentaedre   .
c . nface3 . e   . 1      . face de numero local 3 dans le pentaedre   .
c . nface4 . e   . 1      . face de numero local 4 dans le pentaedre   .
c . nface5 . e   . 1      . face de numero local 5 dans le pentaedre   .
c . codef1 . e   . 1      . code de la face 1                          .
c . codef2 . e   . 1      . code de la face 2                          .
c . codef3 . e   . 1      . code de la face 3                          .
c . codef4 . e   . 1      . code de la face 4                          .
c . codef5 . e   . 1      . code de la face 5                          .
c . nupere . e   . 1      . numero du pere du pentaedre                 .
c . famill . e   . 1      . famille a attribuer a l'pentaedre           .
c . nupent . e   . 1      . numero du pentaedre a creer                 .
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
      integer facpen(nouvpe,5), cofape(nouvpf,5), fampen(nouvpe)
      integer hetpen(nouvpe), filpen(nouvpe), perpen(nouvpe)
      integer nface1, nface2, nface3, nface4, nface5
      integer codef1, codef2, codef3, codef4, codef5
      integer nupere, famill, nupent
c
c 0.4. ==> variables locales
c ______________________________________________________________________
c
cgn 1000 format('penta ',i8,' de faces :',5i8)
cgn 1001 format('               de codes :',5i8)
cgn      write(*,1000) nupent, nface1, nface2, nface3, nface4, nface5
cgn      write(*,1001)         codef1, codef2, codef3, codef4, codef5
c
c====
c 1. creation effective d'un pentaedre
c====
c
      facpen(nupent,1) = nface1
      facpen(nupent,2) = nface2
      facpen(nupent,3) = nface3
      facpen(nupent,4) = nface4
      facpen(nupent,5) = nface5
c
      cofape(nupent,1) = codef1
      cofape(nupent,2) = codef2
      cofape(nupent,3) = codef3
      cofape(nupent,4) = codef4
      cofape(nupent,5) = codef5
c
      fampen(nupent) = famill
c
      hetpen(nupent)  = 5500
      filpen(nupent)  = 0
      perpen(nupent)  = nupere
c
      end
