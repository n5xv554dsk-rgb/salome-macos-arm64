      subroutine cmchea ( arehex, famhex,
     >                    hethex, filhex, perhex,
     >                    nare01, nare02, nare03, nare04,
     >                    nare05, nare06, nare07, nare08,
     >                    nare09, nare10, nare11, nare12,
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
c    Creation du Maillage - Creation d'un HExaedre par ses Aretes
c    -           -          -             --               -
c ______________________________________________________________________
c
c but : creation effective d'un hexaedre etant donne :
c       - le numero de l'hexaedre
c       - les numeros globaux des faces locales 1,2,3,4,5 et 6
c       - les codes des faces
c       - le numero du pere
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . arehex . es  .nouvha12. numeros des 12 aretes des hexaedres        .
c . famhex . es  . nouvhe . famille des hexaedres                      .
c . hethex . es  . nouvhe . historique de l'etat des hexaedres         .
c . filhex . es  . nouvhe . premier fils des hexaedres                 .
c . perhex . es  . nouvhe . pere des hexaedres                         .
c . narei  . e   . 1      . arete de numero local i dans l'hexaedre    .
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
      integer arehex(nouvha,12), famhex(nouvhe)
      integer hethex(nouvhe), filhex(nouvhe), perhex(nouvhe)
      integer nare01, nare02, nare03, nare04
      integer nare05, nare06, nare07, nare08
      integer nare09, nare10, nare11, nare12
      integer nupere, famill, nuhexa
c
c 0.4. ==> variables locales
c
      integer iaux
c ______________________________________________________________________
c
c====
c 1. creation effective d'un hexaedre
c====
c
cgn        write (*,*) 'nuhexa',nuhexa
      iaux = nuhexa - nouvhf
      arehex(iaux,1) = nare01
      arehex(iaux,2) = nare02
      arehex(iaux,3) = nare03
      arehex(iaux,4) = nare04
      arehex(iaux,5) = nare05
      arehex(iaux,6) = nare06
      arehex(iaux,7) = nare07
      arehex(iaux,8) = nare08
      arehex(iaux,9) = nare09
      arehex(iaux,10) = nare10
      arehex(iaux,11) = nare11
      arehex(iaux,12) = nare12
c
      famhex(nuhexa) = famill
c
      hethex(nuhexa)  = 5000
      filhex(nuhexa)  = 0
      perhex(nuhexa)  = nupere
c
      end
