      subroutine cmcpy2 ( lehexa, indpyr, indptp,
     >                    laface,
     >                    somhex, areint, are1, are2, are3, are4,
     >                    filare, arequa, filqua,
     >                    arepyr, fampyr,
     >                    hetpyr, filpyr, perpyr,
     >                    famhex, cfahex,
     >                    ulsort, langue, codret )
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
c    Creation du Maillage - Creation de PYramidee par leurs aretes
c    -           -          -            --
c                         - par paquets de 2 appuyes sur une face
c                                          -
c ______________________________________________________________________
c    La description est faite comme pour le decoupage
c    de la face 1 par les aretes 1 et 4
c
c           S2               N1              S1
c            |---------------|---------------|
c            |               |               |
c            |               |               |
c            |               |               |
c         A3 |               |               | A2
c            |               |               |
c            |               |               |
c            |               |               |
c            |---------------|---------------|
c           S3               N4              S4
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . laface . e   .   1    . face coupee en 2 quadrangles               .
c . somhex . e   .   4    . Les sommets de la face dans                .
c .        .     .        . l'ordre S1, S4, S3, S2                     .
c . areint . e   .   6    . Les aretes internes utiles                 .
c .        .     .        . . Les 4 premiers sur les sommets           .
c .        .     .        . . 5 sur le milieu de S1-S2                 .
c .        .     .        . . 6 sur le milieu de S3-S4                 .
c . are1   . e   .   1    . arete S1-S2                                .
c . are2   . e   .   1    . arete S1-S4                                .
c . are3   . e   .   1    . arete S3-S4                                .
c . are4   . e   .   1    . arete S2-S3                                .
c . filare . e   . nouvar . fille ainee de chaque arete                .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . arepyr . e   .nouvya*8. numeros des 8 aretes des pyramides         .
c . fampyr . e   . nouvpy . famille des pyramides                      .
c . hetpyr . e   . nouvpy . historique de l'etat des pyramides         .
c . filpyr . e   . nouvpy . premier fils des pyramides                 .
c . perpyr . e   . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . famhex . e   . nouvhe . famille des hexaedres                      .
c . cfahex .     . nctfhe. codes des familles des hexaedres            .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      character*6 nompro
      parameter ( nompro = 'CMCPY2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nouvnb.h"
#include "cofpfh.h"
c
c 0.3. ==> arguments
c
      integer lehexa, indpyr, indptp
      integer laface
      integer somhex(4), areint(6)
      integer are1, are2, are3, are4
      integer filare(nouvar)
      integer arequa(nouvqu,4), filqua(nouvqu)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
      integer arepyr(nouvya,8), fampyr(nouvpy)
      integer hetpyr(nouvpy), filpyr(nouvpy), perpyr(nouvpy)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nupere, nufami
      integer as1n1, as2n1, as3n4, as4n4, an1n4
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'laface', laface
      write (ulsort,90002) 'somhex', somhex
      write (ulsort,90002) 'areint', areint
      write (ulsort,90002) 'are1, are2, are3, are4',
     >                      are1, are2, are3, are4
#endif
c
c====
c 2. Recuperation des demi-aretes
c====
c
      if ( somhex(1).le.somhex(4) ) then
        as1n1 = filare(are1)
        as2n1 = filare(are1) + 1
      else
        as1n1 = filare(are1) + 1
        as2n1 = filare(are1)
      endif
c
      if ( somhex(2).le.somhex(3) ) then
        as3n4 = filare(are3) + 1
        as4n4 = filare(are3)
      else
        as3n4 = filare(are3)
        as4n4 = filare(are3) + 1
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'as1n1, as2n1, as3n4, as4n4',
     >                      as1n1, as2n1, as3n4, as4n4
#endif
c
c====
c 3. Recuperation de l'arete entre les milieux des aretes coupees
c    C'est toujours la 4eme dans la description des fils (cf. cmcdq2)
c====
c
      an1n4 = arequa(filqua(laface),4)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'an1n4', an1n4
#endif
c
c====
c 4. Creation des pyramides
c====
c
      nupere = -indptp
      nufami = cfahex(cofpfh,famhex(lehexa))
c
c 4.1. ==> Pyramide numero 1
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 1', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              areint(1), areint(2), areint(6), areint(5),
     >              are2, as4n4, an1n4, as1n1,
     >              nupere,  nufami,   indpyr )
c
c 4.2. ==> Pyramide numero 2
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 2', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              areint(3), areint(4), areint(5), areint(6),
     >              are4, as2n1, an1n4, as3n4,
     >              nupere,  nufami,   indpyr )
c
c====
c 5. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
