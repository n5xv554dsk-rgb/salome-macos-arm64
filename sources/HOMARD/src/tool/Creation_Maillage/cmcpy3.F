      subroutine cmcpy3 ( lehexa, indpyr, indptp,
     >                    laface, codfac,
     >                    areint,
     >                    arequa, filqua,
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
c                         - par paquets de 3 appuyes sur une face
c                                          -
c ______________________________________________________________________
c    La description est faite comme pour le decoupage
c    de la face 1 par les aretes 1 et 2 et code<5
c
c           S2           N1          S1
c            |-----------|-----------|
c            |           |           |
c            |           |    FFI    |
c            |           |           |
c            |  FFI+2    |NF1        |
c         A3 |           |-----------| N2
c            |         /             |
c            |       /               |
c            |     /       FFI+1     |
c            |   /                   |
c            | /                     |
c            |-----------------------|
c           S3          A4           S4
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . laface . e   .   1    . face coupee en 2 quadrangles               .
c . codfac . e   .   1    . code de la face coupee en 3 quad dans l'hex.
c . areint . e   .   7    . Les aretes internes utiles                 .
c .        .     .        . . 1 : le sommet de FFI                     .
c .        .     .        . . 2 : le sommet du cote de FFI+1           .
c .        .     .        . . 3 : le sommet commun a FFI+1 et FFI+2    .
c .        .     .        . . 4 : le sommet du cote de FFI+2           .
c .        .     .        . . 5 : noeud commun a FFI et FFI+1          .
c .        .     .        . . 6 : noeud commun a FFI et FFI+2          .
c .        .     .        . . 7 : sur NF1, milieu de la face           .
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
      parameter ( nompro = 'CMCPY3' )
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
      integer laface, codfac
      integer areint(7)
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
      integer as1n1, as1n2, an1nf1, an2nf1, as3nf1
      integer as4n2, as2n1, as2s3, as3s4
      integer as1s0, as2s0, as3s0, as4s0, an1s0, an2s0, anf1s0
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
      write (ulsort,90002) 'laface, codfac', laface, codfac
      write (ulsort,90002) 'areint', areint
#endif
c
c====
c 2. Recuperation des aretes tracees sur la face et des aretes internes
c====
c
      iaux = filqua(laface)
c
      if ( codfac.lt.5 ) then
        as1n1 = arequa(iaux,1)
        as1n2 = arequa(iaux,2)
        an2nf1 = arequa(iaux,3)
        an1nf1 = arequa(iaux,4)
        as4n2 = arequa(iaux+1,1)
        as3s4 = arequa(iaux+1,2)
        as2n1 = arequa(iaux+2,1)
        as2s3 = arequa(iaux+2,4)
      else
        as1n1 = arequa(iaux,2)
        as1n2 = arequa(iaux,1)
        an2nf1 = arequa(iaux,4)
        an1nf1 = arequa(iaux,3)
        as4n2 = arequa(iaux+2,1)
        as3s4 = arequa(iaux+2,4)
        as2n1 = arequa(iaux+1,1)
        as2s3 = arequa(iaux+1,2)
      endif
      as3nf1 = arequa(iaux+1,3)
      as1s0 = areint(1)
      as4s0 = areint(2)
      as3s0 = areint(3)
      as2s0 = areint(4)
      an2s0 = areint(5)
      an1s0 = areint(6)
      anf1s0 = areint(7)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'as1n1, as1n2, an1nf1, an2nf1, as3nf1',
     >                      as1n1, as1n2, an1nf1, an2nf1, as3nf1
      write (ulsort,90002) 'as4n2, as2n1, as2s3, as3s4',
     >                      as4n2, as2n1, as2s3, as3s4
      write (ulsort,90002)
     >              'as1s0, as2s0, as3s0, as4s0, an1s0, an2s0, anf1s0',
     >               as1s0, as2s0, as3s0, as4s0, an1s0, an2s0, anf1s0
#endif
c
c====
c 3. Creation des pyramides
c====
c
      nupere = -indptp
      nufami = cfahex(cofpfh,famhex(lehexa))
c
c 3.1. ==> Pyramide numero 1
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 1', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              as1s0, an2s0, anf1s0, an1s0,
     >              as1n2, an2nf1, an1nf1, as1n1,
     >              nupere,  nufami,   indpyr )
c
c 3.2. ==> Pyramide du cote de ffi+1
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA cote de ffi+1', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              as4s0, as3s0, anf1s0, an2s0,
     >              as3s4, as3nf1, an2nf1, as4n2,
     >              nupere,  nufami,   indpyr )
c
c 3.3. ==> Pyramide du cote de ffi+2
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA cote de ffi+2', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              as2s0, an1s0, anf1s0, as3s0,
     >              as2n1, an1nf1, as3nf1, as2s3,
     >              nupere,  nufami,   indpyr )
c
c====
c 4. la fin
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
