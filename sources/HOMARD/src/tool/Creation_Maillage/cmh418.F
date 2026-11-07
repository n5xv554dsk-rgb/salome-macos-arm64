      subroutine cmh418 ( lehexa,
     >                    indnoe, indare, indtet, indpyr, indhex,
     >                    indptp,
     >                    listso, listar, listfa, listcf,
     >                    coonoe, hetnoe, arenoe,
     >                    famnoe,
     >                    hetare, somare,
     >                    filare, merare, famare,
     >                    aretri,
     >                    arequa, filqua,
     >                    hettet, aretet,
     >                    filtet, pertet, famtet,
     >                    hetpyr, arepyr,
     >                    filpyr, perpyr, fampyr,
     >                    hethex, arehex,
     >                    filhex, perhex, famhex,
     >                    cfahex,
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
c    Creation du Maillage - decoupage de conformite des Hexaedres
c    -           -                                      -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .   1    . hexaedre a decouper                        .
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indhex . es  .   1    . indice du dernier hexaedre cree            .
c . indptp . es  .   1    . indice du dernier pere enregistre          .
c . listso . e   .   8    . numeros globaux des sommets                .
c . listar . e   .  12    . numeros globaux des aretes                 .
c . listfa . e   .   6    . numeros globaux des faces                  .
c . listcf . e   .   6    . codes des faces                            .
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . famnoe . es  . nouvno . famille des noeuds                         .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare . es  . nouvar . famille des aretes                         .
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . aretet . es  .nouvta*6. numeros des 6 aretes des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . hetpyr . es  . nouvpy . historique de l'etat des pyramides         .
c . arepyr . es  .nouvya*8. numeros des 8 aretes des pyramides         .
c . filpyr . es  . nouvpy . premier fils des pyramides                 .
c . perpyr . es  . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . es  . nouvpy . famille des pyramides                      .
c . hethex . es  . nouvhe . historique de l'etat des hexaedres         .
c . arehex . es  .nouvha12. numeros des 12 aretes des hexaedres        .
c . filhex . es  . nouvhe . premier fils des hexaedres                 .
c . perhex . es  . nouvhe . pere des hexaedres                         .
c . famhex . es  . nouvhe . famille des hexaedres                      .
c . cfahex . e   . nctfhe. codes des familles des hexaedres            .
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
      parameter ( nompro ='CMH418' )
c
#include "nblang.h"
#include "cofpfh.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer lehexa
      integer indnoe, indare, indtet, indpyr, indhex
      integer indptp
      integer listso(8), listar(12), listfa(6), listcf(6)
      integer hetnoe(nouvno), arenoe(nouvno)
      integer famnoe(nouvno)
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
      integer aretri(nouvtr,3)
      integer arequa(nouvqu,4)
      integer filqua(nouvqu)
      integer hettet(nouvte), aretet(nouvta,6)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer hetpyr(nouvpy), arepyr(nouvya,8)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
      integer arehex(nouvha,12)
      integer hethex(nouvhe)
      integer filhex(nouvhe), perhex(nouvhe)
      integer cfahex(nctfhe,nbfhex), famhex(nouvhe)
c
      double precision coonoe(nouvno,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer as1n1, as2n1, as3n4, as4n4
      integer as5n9, as6n9, as7n12, as8n12
      integer an1n4, an1n9, an4n12, an9n12
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'indnoe', indnoe
      write (ulsort,90002) 'indtet', indtet
      write (ulsort,90002) 'indpyr', indpyr
      write (ulsort,90002) 'indhex', indhex
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'listar  1-8', (listar(iaux),iaux=1,8)
      write (ulsort,90002) 'listar 9-12', (listar(iaux),iaux=9,12)
      write (ulsort,90002) 'listso', listso
      write (ulsort,90002) 'listfa', listfa
      write (ulsort,90002) 'listcf', listcf
#endif
c
      codret = 0
c
c====
c 2. Recuperation des demi-aretes
c====
c 2.1. ==> Filles de l'arete 1
c
      if ( listso(1).le.listso(2) ) then
        as1n1 = filare(listar(1))
        as2n1 = filare(listar(1)) + 1
      else
        as1n1 = filare(listar(1)) + 1
        as2n1 = filare(listar(1))
      endif
c
c 2.2. ==> Filles de l'arete 4
c
      if ( listso(3).le.listso(4) ) then
        as3n4 = filare(listar(4))
        as4n4 = filare(listar(4)) + 1
      else
        as3n4 = filare(listar(4)) + 1
        as4n4 = filare(listar(4))
      endif
c
c 2.3. ==> Filles de l'arete 9
c
      if ( listso(5).le.listso(6) ) then
        as5n9 = filare(listar(9))
        as6n9 = filare(listar(9)) + 1
      else
        as5n9 = filare(listar(9)) + 1
        as6n9 = filare(listar(9))
      endif
c
c 2.4. ==> Filles de l'arete 12
c
      if ( listso(7).le.listso(8) ) then
        as7n12 = filare(listar(12))
        as8n12 = filare(listar(12)) + 1
      else
        as7n12 = filare(listar(12)) + 1
        as8n12 = filare(listar(12))
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'as1n1, as2n1, as3n4, as4n4',
     >                      as1n1, as2n1, as3n4, as4n4
      write (ulsort,90002) 'as5n9, as6n9, as7n12, as8n12',
     >                      as5n9, as6n9, as7n12, as8n12
#endif
c
c====
c 3. Recuperation des aretes tracees sur les faces coupees
c    C'est toujours la 4eme dans la description des fils (cf. cmcdq2)
c====
c
      an1n4 = arequa(filqua(listfa(1)),4)
      an1n9 = arequa(filqua(listfa(2)),4)
      an4n12 = arequa(filqua(listfa(5)),4)
      an9n12 = arequa(filqua(listfa(6)),4)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'an1n4, an1n9, an4n12, an9n12',
     >                      an1n4, an1n9, an4n12, an9n12
#endif
c
c====
c 4. Creation des hexaedres
c====
c
      jaux = cfahex(cofpfh,famhex(lehexa))
c
c 4.1. ==> Sur la face 3
c
      indhex = indhex + 1
      call cmchea ( arehex, famhex,
     >              hethex, filhex, perhex,
     >              as1n1, listar(2), an1n4, as4n4,
     >              listar(5), an1n9, listar(7), an4n12,
     >              as6n9, listar(10), an9n12, as7n12,
     >              lehexa, jaux, indhex )
c
c 4.2. ==> Sur la face 4
c
      indhex = indhex + 1
      call cmchea ( arehex, famhex,
     >              hethex, filhex, perhex,
     >              as2n1, an1n4, listar(3), as3n4,
     >              an1n9, listar(6), an4n12, listar(8),
     >              as5n9, an9n12, listar(11), as8n12,
     >              lehexa, jaux, indhex )
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
