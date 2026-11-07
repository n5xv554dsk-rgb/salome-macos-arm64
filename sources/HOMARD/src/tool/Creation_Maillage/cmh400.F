      subroutine cmh400 ( lehexa,
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
      parameter ( nompro ='CMH400' )
      parameter ( nbarin = 13 )
c
      integer nbsomm
      parameter ( nbsomm = 8 )
c
#include "nblang.h"
#include "cofpfh.h"
#include "coftfh.h"
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
      integer iaux
c
      integer lesnoe(nbarin), areint(nbarin)
      integer lisomm(10), liarin(10)
      integer fdnume, fdcode
      integer are1, are2, are3, are4
      integer are5, are6, are7, are8

#include "defiqu.h"
c
      integer laface, letria
      integer niveau, nf1
      integer quabas(4)
      integer an1nf1, an2nf1, an3nf1, an4nf1
      integer as5n1, as6n1, as1n1, as2n1
      integer as6n2, as7n2, as1n2, as4n2
      integer as5n3, as8n3, as2n3, as3n3
      integer as7n4, as8n4, as4n4, as3n4
      integer nufami
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
c    . des noeuds milieux des 4 aretes coupees
c    . du noeud milieu de la face coupee en 4 quadrangles
c====
c
      do 21 , iaux = 1 , 8
        lesnoe(iaux) = listso(iaux)
   21 continue
c
      lesnoe(9) = somare(2,filare(listar(1)))
      lesnoe(10) = somare(2,filare(listar(2)))
      lesnoe(11) = somare(2,filare(listar(3)))
      lesnoe(12) = somare(2,filare(listar(4)))
c
      iaux = filqua(listfa(1))
      lesnoe(13) = somare(2,arequa(iaux,2))
#ifdef _DEBUG_HOMARD_
      do 2000 , iaux = 1 , nbarin
        write(ulsort,90015) 'lesnoe(',iaux,') = ', lesnoe(iaux)
 2000 continue
#endif
c
c La face coupee en 4 et son code dans l'hexaedre
c
      fdnume = listfa(1)
      fdcode = listcf(1)
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'fdnume, fdcode', fdnume, fdcode
#endif
c
c====
c 3. Recuperation du noeud central de la face coupee en 4
c====
c
      iaux = filqua(fdnume)
      nf1 = somare(2,arequa(iaux,2))
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nf1', nf1
#endif
c
c====
c 4. Recuperation des aretes tracees sur la face coupee en 4
c    quabas stocke les quadrangles fils de la face coupee en 4
c    quabas(p) est la base de la pyramide fille numero p
c    filqua(fdnume) + defiqJ(fdcode) : J-eme fils du quadrangle
c    Attention : la regle de numerotation locale des quadrangles quabas
c                est celle des pyramides ; on part du sommet de plus
c                petit numero local et on tourne en entrant dans
c                l'hexaedre. Pour les fils du quadrangle, on part de la
c                plus petite arete locale et on tourne dans le meme sens
c                D'ou l'eventuel decalage selon les faces
c====
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'defiq1', defiq1(fdcode)
      write(ulsort,90002) 'defiq2', defiq2(fdcode)
      write(ulsort,90002) 'defiq3', defiq3(fdcode)
      write(ulsort,90002) 'defiq4', defiq4(fdcode)
#endif
      quabas(1) = filqua(fdnume) + defiq2(fdcode)
      quabas(2) = filqua(fdnume) + defiq3(fdcode)
      quabas(3) = filqua(fdnume) + defiq4(fdcode)
      quabas(4) = filqua(fdnume) + defiq1(fdcode)
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'Fils aine', filqua(fdnume)
      write(ulsort,90006) 'quabas(1) :', quabas(1)
      write(ulsort,90006) 'quabas(2) :', quabas(2)
      write(ulsort,90006) 'quabas(3) :', quabas(3)
      write(ulsort,90006) 'quabas(4) :', quabas(4)
#endif
c
      if ( fdcode.lt.5 ) then
       an2nf1 = arequa(quabas(1),2)
       an4nf1 = arequa(quabas(2),2)
       an3nf1 = arequa(quabas(3),2)
       an1nf1 = arequa(quabas(4),2)
      else
       an2nf1 = arequa(quabas(2),2)
       an4nf1 = arequa(quabas(3),2)
       an3nf1 = arequa(quabas(4),2)
       an1nf1 = arequa(quabas(1),2)
      endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,90015) 'an2nf1', an2nf1, ' entre les noeuds',
     >                    somare(1,an2nf1), somare(2,an2nf1)
      write(ulsort,90015) 'an4nf1', an4nf1, ' entre les noeuds',
     >                    somare(1,an4nf1), somare(2,an4nf1)
      write(ulsort,90015) 'an3nf1', an3nf1, ' entre les noeuds',
     >                    somare(1,an3nf1), somare(2,an3nf1)
      write(ulsort,90015) 'an1nf1', an1nf1, ' entre les noeuds',
     >                    somare(1,an1nf1), somare(2,an1nf1)
#endif
c
c====
c 5. Recuperation des aretes tracees sur les faces coupees en 3
c====
c
      laface = listfa(2)
      letria = -filqua(laface)
      if ( listcf(2).lt.5 ) then
        as5n1 = aretri(letria,1)
        as6n1 = aretri(letria,3)
        as1n1 = aretri(letria+2,1)
        as2n1 = aretri(letria+1,1)
      else
        as5n1 = aretri(letria,3)
        as6n1 = aretri(letria,1)
        as1n1 = aretri(letria+1,1)
        as2n1 = aretri(letria+2,1)
      endif
c
      laface = listfa(3)
      letria = -filqua(laface)
      if ( listcf(3).lt.5 ) then
        as6n2 = aretri(letria,1)
        as7n2 = aretri(letria,3)
        as1n2 = aretri(letria+1,1)
        as4n2 = aretri(letria+2,1)
      else
        as6n2 = aretri(letria,3)
        as7n2 = aretri(letria,1)
        as1n2 = aretri(letria+2,1)
        as4n2 = aretri(letria+1,1)
      endif
c
      laface = listfa(4)
      letria = -filqua(laface)
      if ( listcf(4).lt.5 ) then
        as5n3 = aretri(letria,3)
        as8n3 = aretri(letria,1)
        as2n3 = aretri(letria+2,1)
        as3n3 = aretri(letria+1,1)
      else
        as5n3 = aretri(letria,1)
        as8n3 = aretri(letria,3)
        as2n3 = aretri(letria+1,1)
        as3n3 = aretri(letria+2,1)
      endif
c
      laface = listfa(5)
      letria = -filqua(laface)
      if ( listcf(5).lt.5 ) then
        as7n4 = aretri(letria,1)
        as8n4 = aretri(letria,3)
        as4n4 = aretri(letria+1,1)
        as3n4 = aretri(letria+2,1)
      else
        as7n4 = aretri(letria,3)
        as8n4 = aretri(letria,1)
        as4n4 = aretri(letria+2,1)
        as3n4 = aretri(letria+1,1)
      endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'as5n1, as6n1, as1n1, as2n1',
     >                     as5n1, as6n1, as1n1, as2n1
      write(ulsort,90002) 'as6n2, as7n2, as1n2, as4n2',
     >                     as6n2, as7n2, as1n2, as4n2
      write(ulsort,90002) 'as5n3, as8n3, as2n3, as3n3',
     >                     as5n3, as8n3, as2n3, as3n3
      write(ulsort,90002) 'as7n4, as8n4, as4n4, as3n4',
     >                     as7n4, as8n4, as4n4, as3n4
#endif
c
c====
c 6. Creation des quatre aretes internes
c    areint(1) : AS5NF1
c    areint(2) : AS6NF1
c    areint(3) : AS7NF1
c    areint(4) : AS8NF1
c====
c
      do 61 , iaux = 1 , 4
c
        indare = indare + 1
        areint(iaux) = indare
c
        somare(1,areint(iaux)) = min ( nf1 , listso(4+iaux) )
        somare(2,areint(iaux)) = max ( nf1 , listso(4+iaux) )
c
        famare(areint(iaux)) = 1
        hetare(areint(iaux)) = 50
        merare(areint(iaux)) = 0
        filare(areint(iaux)) = 0
#ifdef _DEBUG_HOMARD_
      write(ulsort,90006) 'areint(iaux) = ', areint(iaux),
     >                    ' de ',somare(1,areint(iaux)),
     >                    ' a ',somare(2,areint(iaux))
#endif
c
   61 continue
c
c====
c 5. Creation des 5 pyramides
c====
c
      iaux = -indptp
      nufami = cfahex(cofpfh,famhex(lehexa))
c
c 5.1. ==> Pyramide s'appuyant sur la face non decoupee
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 1', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              areint(2), areint(1), areint(4), areint(3),
     >              listar(9), listar(11), listar(12), listar(10),
     >              iaux,  nufami,   indpyr )
c
c 5.2. ==> Pyramides s'appuyant sur la face decoupee
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 2', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              listar(5), as6n2, areint(2), as6n1,
     >              as1n2, an2nf1, an1nf1, as1n1,
     >              iaux,  nufami,   indpyr )
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 3', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              listar(7), as7n4, areint(3), as7n2,
     >              as4n4, an4nf1, an2nf1, as4n2,
     >              iaux,  nufami,   indpyr )
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 4', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              listar(8), as8n3, areint(4), as8n4,
     >              as3n3, an3nf1, an4nf1, as3n4,
     >              iaux,  nufami,   indpyr )
c
      indpyr = indpyr + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYA pyra 5', nompro
#endif
      call cmcpya ( arepyr, fampyr, hetpyr, filpyr, perpyr,
     >              listar(6), as5n1, areint(1), as5n3,
     >              as2n1, an1nf1, an3nf1, as2n3,
     >              iaux,  nufami,   indpyr )
c
c====
c 6. Creation des 4 tetraedres
c====
c
      nufami = cfahex(coftfh,famhex(lehexa))
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTEA - tetra 1', nompro
#endif
      call cmctea ( aretet, famtet, hettet, filtet, pertet,
     >              an1nf1, areint(1), areint(2), as5n1,
     >              as6n1, listar(9),
     >              iaux,  nufami,   indtet )
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTEA - tetra 2', nompro
#endif
      call cmctea ( aretet, famtet, hettet, filtet, pertet,
     >              an2nf1, areint(2), areint(3), as6n2,
     >              as7n2, listar(10),
     >              iaux,  nufami,   indtet )
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTEA - tetra 3', nompro
#endif
      call cmctea ( aretet, famtet, hettet, filtet, pertet,
     >              an4nf1, areint(3), areint(4), as7n4,
     >              as8n4, listar(12),
     >              iaux,  nufami,   indtet )
c
      indtet = indtet + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTEA - tetra 4', nompro
#endif
      call cmctea ( aretet, famtet, hettet, filtet, pertet,
     >              an3nf1, areint(4), areint(1), as8n3,
     >              as5n3, listar(11),
     >              iaux,  nufami,   indtet )
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
