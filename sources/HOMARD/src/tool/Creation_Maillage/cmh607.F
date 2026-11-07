      subroutine cmh607 ( lehexa,
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
      integer nbarin
      character*6 nompro
      parameter ( nompro ='CMH607' )
      parameter ( nbarin = 18 )
c
      integer nbsomm
      parameter ( nbsomm = 8 )
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
      integer lesnoe(nbarin), areint(nbarin)
      integer lisomm(10), liarin(10)
      integer fdnume, fdcode
      integer are1, are2, are3, are4
      integer are5, are6, are7, are8

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
c 2. Recuperation
c    . des sommets de l'hexaedre
c    . des noeuds milieux des 6 aretes coupees
c    . des noeuds milieux des 4 faces coupees en 3 quadrangles
c====
c
      do 21 , iaux = 1 , 8
        lesnoe(iaux) = listso(iaux)
   21 continue
c
      lesnoe(9) = somare(2,filare(listar(1)))
      lesnoe(10) = somare(2,filare(listar(2)))
      lesnoe(11) = somare(2,filare(listar(6)))
      lesnoe(12) = somare(2,filare(listar(8)))
      lesnoe(13) = somare(2,filare(listar(10)))
      lesnoe(14) = somare(2,filare(listar(12)))
c
      iaux = filqua(listfa(1))
      lesnoe(15) = somare(2,arequa(iaux,4))
      iaux = filqua(listfa(2))
      lesnoe(16) = somare(2,arequa(iaux,4))
      iaux = filqua(listfa(5))
      lesnoe(17) = somare(2,arequa(iaux,4))
      iaux = filqua(listfa(6))
      lesnoe(18) = somare(2,arequa(iaux,4))
#ifdef _DEBUG_HOMARD_
      do 2000 , iaux = 1 , nbarin
        write(ulsort,90015) 'lesnoe(',iaux,') = ', lesnoe(iaux)
 2000 continue
#endif
c
c====
c 3. Creation du noeud interne et des dix-huit aretes internes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCHPB', nompro
#endif
      call cmchpb ( indnoe, indare, nbarin,
     >              nbsomm, lesnoe, areint,
     >              coonoe, hetnoe, arenoe,
     >              famnoe,
     >              hetare, somare,
     >              filare, merare, famare,
     >              ulsort, langue, codret )
c
c====
c 4. Creation des seize pyramides
c====
c
      iaux = -indptp
      jaux = cfahex(cofpfh,famhex(lehexa))
c
c 4.1. ==> Sur la face 1
c
      liarin(1) = areint(1)
      liarin(2) = areint(4)
      liarin(3) = areint(3)
      liarin(4) = areint(2)
      liarin(5) = areint(10)
      liarin(6) = areint(9)
      liarin(7) = areint(15)
      fdcode = listcf(1)
      fdnume = listfa(1)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPY3 - face 1', nompro
#endif
      call cmcpy3 ( lehexa, indpyr, indptp,
     >              fdnume, fdcode,
     >              liarin,
     >              arequa, filqua,
     >              arepyr, fampyr,
     >              hetpyr, filpyr, perpyr,
     >              famhex, cfahex,
     >              ulsort, langue, codret )
c
c 4.2. ==> Sur la face 2
c
      liarin(1) = areint(2)
      liarin(2) = areint(5)
      liarin(3) = areint(6)
      liarin(4) = areint(1)
      liarin(5) = areint(11)
      liarin(6) = areint(9)
      liarin(7) = areint(16)
      fdcode = listcf(2)
      fdnume = listfa(2)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPY3 - face 2', nompro
#endif
      call cmcpy3 ( lehexa, indpyr, indptp,
     >              fdnume, fdcode,
     >              liarin,
     >              arequa, filqua,
     >              arepyr, fampyr,
     >              hetpyr, filpyr, perpyr,
     >              famhex, cfahex,
     >              ulsort, langue, codret )
c
c 4.3. ==> Sur la face 3
c
      lisomm(1) = lesnoe(1)
      liarin(1) = areint(1)
      lisomm(2) = lesnoe(6)
      liarin(2) = areint(6)
      lisomm(3) = lesnoe(7)
      liarin(3) = areint(7)
      lisomm(4) = lesnoe(4)
      liarin(4) = areint(4)
      liarin(5) = areint(10)
      liarin(6) = areint(13)
      are1 = listar(2)
      are2 = listar(5)
      are3 = listar(10)
      are4 = listar(7)
      fdnume = listfa(3)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPY2 - face 3', nompro
#endif
      call cmcpy2 ( lehexa, indpyr, indptp,
     >              fdnume,
     >              lisomm, liarin,
     >              are1, are2, are3, are4,
     >              filare, arequa, filqua,
     >              arepyr, fampyr,
     >              hetpyr, filpyr, perpyr,
     >              famhex, cfahex,
     >              ulsort, langue, codret )
c
c 4.4. ==> Sur la face 4
c
      lisomm(1) = lesnoe(8)
      liarin(1) = areint(8)
      lisomm(2) = lesnoe(5)
      liarin(2) = areint(5)
      lisomm(3) = lesnoe(2)
      liarin(3) = areint(2)
      lisomm(4) = lesnoe(3)
      liarin(4) = areint(3)
      liarin(5) = areint(12)
      liarin(6) = areint(11)
      are1 = listar(8)
      are2 = listar(11)
      are3 = listar(6)
      are4 = listar(3)
      fdnume = listfa(4)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPY2 - face 4', nompro
#endif
      call cmcpy2 ( lehexa, indpyr, indptp,
     >              fdnume,
     >              lisomm, liarin,
     >              are1, are2, are3, are4,
     >              filare, arequa, filqua,
     >              arepyr, fampyr,
     >              hetpyr, filpyr, perpyr,
     >              famhex, cfahex,
     >              ulsort, langue, codret )
c
c 4.5. ==> Sur la face 5
c
      liarin(1) = areint(8)
      liarin(2) = areint(3)
      liarin(3) = areint(4)
      liarin(4) = areint(7)
      liarin(5) = areint(12)
      liarin(6) = areint(14)
      liarin(7) = areint(17)
      fdcode = listcf(5)
      fdnume = listfa(5)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPY3 - face 5', nompro
#endif
      call cmcpy3 ( lehexa, indpyr, indptp,
     >              fdnume, fdcode,
     >              liarin,
     >              arequa, filqua,
     >              arepyr, fampyr,
     >              hetpyr, filpyr, perpyr,
     >              famhex, cfahex,
     >              ulsort, langue, codret )
c
c 4.6. ==> Sur la face 6
c
      liarin(1) = areint(7)
      liarin(2) = areint(6)
      liarin(3) = areint(5)
      liarin(4) = areint(8)
      liarin(5) = areint(13)
      liarin(6) = areint(14)
      liarin(7) = areint(18)
      fdcode = listcf(6)
      fdnume = listfa(6)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPY3 - face 6', nompro
#endif
      call cmcpy3 ( lehexa, indpyr, indptp,
     >              fdnume, fdcode,
     >              liarin,
     >              arequa, filqua,
     >              arepyr, fampyr,
     >              hetpyr, filpyr, perpyr,
     >              famhex, cfahex,
     >              ulsort, langue, codret )
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
