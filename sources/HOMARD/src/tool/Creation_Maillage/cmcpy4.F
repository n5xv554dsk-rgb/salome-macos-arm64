      subroutine cmcpy4 ( lehexa, indpyr, indptp,
     >                    laface,
     >                    somhex, areint, as1s2, as1s4, as3s4, as2s3,
     >                    somare, filare, arequa, filqua,
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
c                         - par paquets de 4 appuyes sur une face
c                                          -
c ______________________________________________________________________
c    La description est faite comme pour le decoupage de la face 1
c
c           S2               N1              S1
c            |---------------|---------------|
c            |               |               |
c            |               |               |
c            |               |               |
c            |               |N0             |
c         N3 |---------------|---------------| N2
c            |               |               |
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
c . somhex . e   .   8    . Les sommets de la face dans                .
c .        .     .        . l'ordre S2, S1, S4, S3                     .
c .        .     .        . puis les noeuds milieux N1, N2, N4, N3     .
c . areint . e   .   9    . Les aretes internes utiles                 .
c .        .     .        . . Les 4 1ers sur S2, S1, S4, S3            .
c .        .     .        . . Les 4 suivants sur N1, N2, N4, N3        .
c .        .     .        . . 9 sur le milieu de la face               .
c . as1s2  . e   .   1    . arete S1-S2                                .
c . as1s4  . e   .   1    . arete S1-S4                                .
c . as3s4  . e   .   1    . arete S3-S4                                .
c . as2s3  . e   .   1    . arete S2-S3                                .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
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
      parameter ( nompro = 'CMCPY4' )
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
      integer somhex(8), areint(9)
      integer as1s2, as1s4, as3s4, as2s3
      integer somare(2,nouvar), filare(nouvar)
      integer arequa(nouvqu,4), filqua(nouvqu)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
      integer arepyr(nouvya,8), fampyr(nouvpy)
      integer hetpyr(nouvpy), filpyr(nouvpy), perpyr(nouvpy)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer listar(4)
      integer nupere, nufami
      integer as1n1, as2n1, as1n2, as4n2
      integer as3n4, as4n4, as2n3, as3n3
      integer an1nf1, an2nf1, an4nf1, an3nf1
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
      write (ulsort,90002) 'as1s2, as1s4, as3s4, as2s3',
     >                      as1s2, as1s4, as3s4, as2s3
#endif
c
c====
c 2. Recuperation des demi-aretes
c====
c 2.1. == filles de as1s2
c
      if ( somhex(1).le.somhex(2) ) then
        as1n1 = filare(as1s2) + 1
        as2n1 = filare(as1s2)
      else
        as1n1 = filare(as1s2)
        as2n1 = filare(as1s2) + 1
      endif
c
c 2.2. == filles de as1s4
c
      if ( somhex(2).le.somhex(3) ) then
        as1n2 = filare(as1s4)
        as4n2 = filare(as1s4) + 1
      else
        as1n2 = filare(as1s4) + 1
        as4n2 = filare(as1s4)
      endif
c
c 2.4. == filles de as3s4
c
      if ( somhex(3).le.somhex(4) ) then
        as3n4 = filare(as3s4) + 1
        as4n4 = filare(as3s4)
      else
        as3n4 = filare(as3s4)
        as4n4 = filare(as3s4) + 1
      endif
c
c 2.4. == filles de as2s3
c
      if ( somhex(4).le.somhex(1) ) then
        as2n3 = filare(as2s3) + 1
        as3n3 = filare(as2s3)
      else
        as2n3 = filare(as2s3)
        as3n3 = filare(as2s3) + 1
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'as1n1, as2n1, as1n2, as4n2',
     >                      as1n1, as2n1, as1n2, as4n2
      write (ulsort,90002) 'as3n4, as4n4, as2n3, as3n3',
     >                      as3n4, as4n4, as2n3, as3n3
#endif
c
c====
c 3. Recuperation des aretes entre les milieux des aretes coupees
c====
c 3.1. ==> Recuperation des aretes : ce sont les 2eme et 3eme dans
c          la description des fils (cf. cmcdq2)
c
      listar(1) = arequa(filqua(laface)  ,2)
      listar(2) = arequa(filqua(laface)  ,3)
      listar(3) = arequa(filqua(laface)+2,2)
      listar(4) = arequa(filqua(laface)+2,3)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'listar', listar
#endif
c
c 3.2. ==> Positionnement
c
      do 32 , iaux = 1 , 4
c
        jaux = somare(1,listar(iaux))
        if ( jaux.eq.somhex(5) ) then
          an1nf1 = listar(iaux)
        elseif ( jaux.eq.somhex(6) ) then
          an2nf1 = listar(iaux)
        elseif ( jaux.eq.somhex(7) ) then
          an4nf1 = listar(iaux)
        elseif ( jaux.eq.somhex(8) ) then
          an3nf1 = listar(iaux)
        endif
c
   32 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'an1nf1, an2nf1, an4nf1, an3nf1',
     >                      an1nf1, an2nf1, an4nf1, an3nf1
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
     >              areint(2), areint(6), areint(9), areint(5),
     >              as1n2, an2nf1, an1nf1, as1n1,
     >              nupere,  nufami,   indpyr )
c
c 4.2. ==> Pyramide numero 2
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 2', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              areint(3), areint(7), areint(9), areint(6),
     >              as4n4, an4nf1, an2nf1, as4n2,
     >              nupere,  nufami,   indpyr )
c
c 4.3. ==> Pyramide numero 3
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 3', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              areint(4), areint(8), areint(9), areint(7),
     >              as3n3, an3nf1, an4nf1, as3n4,
     >              nupere,  nufami,   indpyr )
c
c 4.4. ==> Pyramide numero 4
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 4', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              areint(1), areint(5), areint(9), areint(8),
     >              as2n1, an1nf1, an3nf1, as2n3,
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
