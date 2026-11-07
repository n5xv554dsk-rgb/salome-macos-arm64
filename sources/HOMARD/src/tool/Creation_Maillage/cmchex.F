      subroutine cmchex ( quahex, coquhe, famhex,
     >                    hethex, filhex, perhex,
     >                    nquad1, nquad2, nquad3,
     >                    nquad4, nquad5, nquad6,
     >                    codef1, codef2, codef3,
     >                    codef4, codef5, codef6,
     >                    nupere, famill, nuhexa )
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
c    Creation du Maillage - Creation d'un HEXaedre
c    -           -          -             ---
c ______________________________________________________________________
c
c but : creation effective d'un hexaedre etant donne :
c       - le numero du hexaedre
c       - les numeros globaux des faces locales 1,2,3,4,5 et 6
c       - les codes des faces
c       - le numero du pere
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . quahex . es  .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . es  .nouvhf*6. code des 6 quadrangles des hexaedres       .
c . famhex . es  . nouvhe . famille des hexaedres                      .
c . hethex . es  . nouvhe . historique de l'etat des hexaedres         .
c . filhex . es  . nouvhe . premier fils des hexaedres                 .
c . perhex . es  . nouvhe . pere des hexaedres                         .
c . nquad1 . e   . 1      . face de numero local 1 dans le hexaedre    .
c . nquad2 . e   . 1      . face de numero local 2 dans le hexaedre    .
c . nquad3 . e   . 1      . face de numero local 3 dans le hexaedre    .
c . nquad4 . e   . 1      . face de numero local 4 dans le hexaedre    .
c . nquad5 . e   . 1      . face de numero local 5 dans le hexaedre    .
c . nquad6 . e   . 1      . face de numero local 6 dans le hexaedre    .
c . codef1 . e   . 1      . code de la face 1                          .
c . codef2 . e   . 1      . code de la face 2                          .
c . codef3 . e   . 1      . code de la face 3                          .
c . codef4 . e   . 1      . code de la face 4                          .
c . codef5 . e   . 1      . code de la face 5                          .
c . codef6 . e   . 1      . code de la face 6                          .
c . nupere . e   . 1      . numero du pere du hexaedre                 .
c . famill . e   . 1      . famille a attribuer a l'hexaedre           .
c . nuhexa . e   . 1      . numero du hexaedre a creer                 .
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
      integer quahex(nouvhf,6), coquhe(nouvhf,6), famhex(nouvhe)
      integer hethex(nouvhe), filhex(nouvhe), perhex(nouvhe)
      integer nquad1, nquad2, nquad3, nquad4, nquad5, nquad6
      integer codef1, codef2, codef3, codef4, codef5, codef6
      integer nupere, famill, nuhexa
c
c 0.4. ==> variables locales
c ______________________________________________________________________
c
c====
c 1. creation effective d'un hexaedre
c====
c
      quahex(nuhexa,1) = nquad1
      quahex(nuhexa,2) = nquad2
      quahex(nuhexa,3) = nquad3
      quahex(nuhexa,4) = nquad4
      quahex(nuhexa,5) = nquad5
      quahex(nuhexa,6) = nquad6
c
      coquhe(nuhexa,1) = codef1
      coquhe(nuhexa,2) = codef2
      coquhe(nuhexa,3) = codef3
      coquhe(nuhexa,4) = codef4
      coquhe(nuhexa,5) = codef5
      coquhe(nuhexa,6) = codef6
c
      famhex(nuhexa) = famill
c
      hethex(nuhexa)  = 5000
      filhex(nuhexa)  = 0
      perhex(nuhexa)  = nupere
c
      end
