      subroutine cmcte3 ( lehexa, indtet, indptp,
     >                    laface, codfac, areint,
     >                    aretri, filqua,
     >                    aretet, famtet,
     >                    hettet, filtet, pertet,
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
c    Creation du Maillage - Creation de TEtraedres par leurs aretes
c    -           -          -           --
c                         - par paquets de 3 appuyes sur une face
c                                          -
c ______________________________________________________________________
c
c       S1 si code<5     are1 si code<5          S4 si code<5
c            |-----------------------------------|
c            |   .----------------------->   .   |
c            |  |                        .       |
c            |  |   FFI+1            .         V |
c            |  |                .             | |
c            |  |            .                 | |
c            |  |        .                     | |
c            |       .                         | |
c            |   .                             | |
c         n1 .                   FFI           | |  are2
c            |   .                             | |
c            |       .                         | |
c            |  |        .                     | |
c            |  |            .                 | |
c            |  |                .             | |
c            |  |   FFI+2            .         V |
c            |  |                        .       |
c            |      <--------------------    .   |
c            |-----------------------------------|
c       S2 si code<5     are3 si code<5          S3 si code<5
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . laface . e   .   1    . face coupee en 3 triangles                 .
c . codfac . e   .   1    . code de la face coupee en 3 tria dans l'hex.
c . areint . e   .   5    . Les aretes internes utiles                 .
c .        .     .        . S1 du cote ffi+1 S4 et S3 base ffi         .
c .        .     .        . S2 du cote de ffi+2 n1 arete coupee        .
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . aretet . es  .nouvta*6. numeros des 6 aretes des tetraedres        .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
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
      parameter ( nompro = 'CMCTE3' )
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
#include "coftfh.h"
c
c 0.3. ==> arguments
c
      integer lehexa, indtet, indptp
      integer laface, codfac
      integer areint(5)
      integer aretri(nouvtr,3)
      integer filqua(nouvqu)
      integer hettet(nouvte), aretet(nouvta,6)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer famhex(nouvhe), cfahex(nctfhe,nbfhex)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nupere, nufami
      integer as1n1, as4n1, as3n1, as2n1
      integer as1s0, as4s0, as3s0, as2s0, an1s0
      integer as1s4, as2s3, as3s4
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
      iaux = -filqua(laface)
c
      if ( codfac.lt.5 ) then
        as4n1 = aretri(iaux,1)
        as3n1 = aretri(iaux,3)
        as1n1 = aretri(iaux+1,1)
        as1s4 = aretri(iaux+1,2)
        as2n1 = aretri(iaux+2,1)
        as2s3 = aretri(iaux+2,3)
      else
        as4n1 = aretri(iaux,3)
        as3n1 = aretri(iaux,1)
        as1n1 = aretri(iaux+2,1)
        as1s4 = aretri(iaux+2,3)
        as2n1 = aretri(iaux+1,1)
        as2s3 = aretri(iaux+1,2)
      endif
      as3s4 = aretri(iaux,2)
      as1s0 = areint(1)
      as4s0 = areint(2)
      as3s0 = areint(3)
      as2s0 = areint(4)
      an1s0 = areint(5)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'as1n1, as4n1, as3n1, as2n1',
     >                      as1n1, as4n1, as3n1, as2n1
      write (ulsort,90002) 'as1s0, as4s0, as3s0, as2s0, an1s0',
     >                      as1s0, as4s0, as3s0, as2s0, an1s0
      write (ulsort,90002) 'as1s4, as2s3, as3s4',
     >                      as1s4, as2s3, as3s4
#endif
c
c====
c 3. Creation des tetraedres
c====
c
      nupere = -indptp
      nufami = cfahex(coftfh,famhex(lehexa))
c
c 3.1. ==> Sur la face centrale, ffi
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTEA pour ffi', nompro
#endif
      call cmctea ( aretet, famtet, hettet, filtet, pertet,
     >              an1s0, as4s0, as3s0, as4n1,
     >              as3n1, as3s4,
     >              nupere, nufami, indtet )
c
c 3.2. ==> Sur la face ffi+1 (si code<5)
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTEA pour ffi+1', nompro
#endif
      call cmctea ( aretet, famtet, hettet, filtet, pertet,
     >              an1s0, as1s0, as4s0, as1n1,
     >              as4n1, as1s4,
     >              nupere, nufami, indtet )
c
c 3.3. ==> Sur la face ffi+2 (si code<5)
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTEA pour ffi+2', nompro
#endif
      call cmctea ( aretet, famtet, hettet, filtet, pertet,
     >              an1s0, as3s0, as2s0, as3n1,
     >              as2n1, as2s3,
     >              nupere, nufami, indtet )
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
