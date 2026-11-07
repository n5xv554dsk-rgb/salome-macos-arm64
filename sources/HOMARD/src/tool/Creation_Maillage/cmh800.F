      subroutine cmh800 ( lehexa,
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
      parameter ( nompro ='CMH800' )
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

      integer listaf(4)
      integer as1n1, as2n1, as1n2, as4n2
      integer as3n4, as4n4, as2n3, as3n3
      integer an1nf1, an2nf1, an4nf1, an3nf1
      integer as5n9, as6n9, as6n10, as7n10
      integer as7n12, as8n12, as8n11, as5n11
      integer an9f6, an10f6, an11f6, an12f6
      integer an1n9, an2n10, an3n11, an4n12
      integer af1f6
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
c    . des noeuds milieux des 8 aretes coupees
c    . des noeuds milieux des 2 faces coupees en 4 quadrangles
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
      lesnoe(13) = somare(2,filare(listar(9)))
      lesnoe(14) = somare(2,filare(listar(10)))
      lesnoe(15) = somare(2,filare(listar(11)))
      lesnoe(16) = somare(2,filare(listar(12)))
c
      iaux = filqua(listfa(1))
      lesnoe(17) = somare(2,arequa(iaux,2))
      iaux = filqua(listfa(6))
      lesnoe(18) = somare(2,arequa(iaux,2))
#ifdef _DEBUG_HOMARD_
      do 2000 , iaux = 1 , nbarin
        write(ulsort,90015) 'lesnoe(',iaux,') = ', lesnoe(iaux)
 2000 continue
#endif
c
c====
c 3. Recuperation des demi-aretes de la face f1
c====
c 3.1. ==> Filles des aretes de bord
c 3.1.1. == filles de listar(1)
c
      if ( lesnoe(2).le.lesnoe(1) ) then
        as1n1 = filare(listar(1)) + 1
        as2n1 = filare(listar(1))
      else
        as1n1 = filare(listar(1))
        as2n1 = filare(listar(1)) + 1
      endif
c
c 3.1.2. == filles de listar(2)
c
      if ( lesnoe(1).le.lesnoe(4) ) then
        as1n2 = filare(listar(2))
        as4n2 = filare(listar(2)) + 1
      else
        as1n2 = filare(listar(2)) + 1
        as4n2 = filare(listar(2))
      endif
c
c 3.1.3. == filles de listar(4)
c
      if ( lesnoe(4).le.lesnoe(3) ) then
        as3n4 = filare(listar(4)) + 1
        as4n4 = filare(listar(4))
      else
        as3n4 = filare(listar(4))
        as4n4 = filare(listar(4)) + 1
      endif
c
c 3.1.4. == filles de listar(3)
c
      if ( lesnoe(3).le.lesnoe(2) ) then
        as2n3 = filare(listar(3)) + 1
        as3n3 = filare(listar(3))
      else
        as2n3 = filare(listar(3))
        as3n3 = filare(listar(3)) + 1
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'as1n1, as2n1, as1n2, as4n2',
     >                      as1n1, as2n1, as1n2, as4n2
      write (ulsort,90002) 'as3n4, as4n4, as2n3, as3n3',
     >                      as3n4, as4n4, as2n3, as3n3
#endif
c
c 3.2. Recuperation des aretes entre les milieux des aretes coupees
c 3.2.1. ==> Recuperation des aretes : ce sont les 2eme et 3eme dans
c            la description des fils (cf. cmcdq2)
c
      listaf(1) = arequa(filqua(listfa(1))  ,2)
      listaf(2) = arequa(filqua(listfa(1))  ,3)
      listaf(3) = arequa(filqua(listfa(1))+2,2)
      listaf(4) = arequa(filqua(listfa(1))+2,3)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'listaf', listaf
#endif
c
c 3.2.2. ==> Positionnement
c
      do 322 , iaux = 1 , 4
c
        jaux = somare(1,listaf(iaux))
        if ( jaux.eq.lesnoe(9) ) then
          an1nf1 = listaf(iaux)
        elseif ( jaux.eq.lesnoe(10) ) then
          an2nf1 = listaf(iaux)
        elseif ( jaux.eq.lesnoe(12) ) then
          an4nf1 = listaf(iaux)
        elseif ( jaux.eq.lesnoe(11) ) then
          an3nf1 = listaf(iaux)
        endif
c
  322 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'an1nf1, an2nf1, an4nf1, an3nf1',
     >                      an1nf1, an2nf1, an4nf1, an3nf1
#endif
c
c====
c 4. Recuperation des demi-aretes de la face f6
c====
c 4.1. ==> Filles des aretes de bord
c 4.1.1. == filles de listar(9)
c
      if ( lesnoe(5).le.lesnoe(6) ) then
        as5n9 = filare(listar(9))
        as6n9 = filare(listar(9)) + 1
      else
        as5n9 = filare(listar(9)) + 1
        as6n9 = filare(listar(9))
      endif
c
c 4.1.2. == filles de listar(10)
c
      if ( lesnoe(6).le.lesnoe(7) ) then
        as6n10 = filare(listar(10))
        as7n10 = filare(listar(10)) + 1
      else
        as6n10 = filare(listar(10)) + 1
        as7n10 = filare(listar(10))
      endif
c
c 4.1.3. == filles de listar(12)
c
      if ( lesnoe(7).le.lesnoe(8) ) then
        as7n12 = filare(listar(12))
        as8n12 = filare(listar(12))+ 1
      else
        as7n12 = filare(listar(12))+ 1
        as8n12 = filare(listar(12))
      endif
c
c 4.1.4. == filles de listar(11)
c
      if ( lesnoe(5).le.lesnoe(8) ) then
        as5n11 = filare(listar(11))
        as8n11 = filare(listar(11))+ 1
      else
        as5n11 = filare(listar(11))+ 1
        as8n11 = filare(listar(11))
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'as5n9, as6n9, as6n10, as7n10',
     >                      as5n9, as6n9, as6n10, as7n10
      write (ulsort,90002) 'as7n12, as8n12, as8n11, as5n11',
     >                      as7n12, as8n12, as8n11, as5n11
#endif
c
c 4.2. Recuperation des aretes entre les milieux des aretes coupees
c 4.2.1. ==> Recuperation des aretes : ce sont les 2eme et 3eme dans
c            la description des fils (cf. cmcdq2)
c
      listaf(1) = arequa(filqua(listfa(6))  ,2)
      listaf(2) = arequa(filqua(listfa(6))  ,3)
      listaf(3) = arequa(filqua(listfa(6))+2,2)
      listaf(4) = arequa(filqua(listfa(6))+2,3)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'listaf', listaf
#endif
c
c 4.2.2. ==> Positionnement
c
      do 422 , iaux = 1 , 4
c
        jaux = somare(1,listaf(iaux))
        if ( jaux.eq.lesnoe(13) ) then
          an9f6 = listaf(iaux)
        elseif ( jaux.eq.lesnoe(14) ) then
          an10f6 = listaf(iaux)
        elseif ( jaux.eq.lesnoe(15) ) then
          an11f6 = listaf(iaux)
        elseif ( jaux.eq.lesnoe(16) ) then
          an12f6 = listaf(iaux)
        endif
c
  422 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'an9f6, an10f6, an11f6, an12f6',
     >                      an9f6, an10f6, an11f6, an12f6
#endif
c
c====
c 5. Aretes sur les faces coupees en 2
c    C'est toujours la 4eme dans la description des fils (cf. cmcdq2)
c====
c
      an1n9 = arequa(filqua(listfa(2)),4)
      an2n10 = arequa(filqua(listfa(3)),4)
      an3n11 = arequa(filqua(listfa(4)),4)
      an4n12 = arequa(filqua(listfa(5)),4)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'an1n9, an2n10, an3n11, an4n12',
     >                      an1n9, an2n10, an3n11, an4n12
#endif
c
c====
c 6. Creation de l'arete interne
c====
c
      indare = indare + 1
c
      af1f6 = indare
      somare(1,af1f6) = min ( lesnoe(17) , lesnoe(18) )
      somare(2,af1f6) = max ( lesnoe(17) , lesnoe(18) )
c
      famare(af1f6) = 1
      hetare(af1f6) = 50
      merare(af1f6) = 0
      filare(af1f6) = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'af1f6', af1f6
#endif
c
c====
c 7. Creation des hexaedres
c====
c
      jaux = cfahex(cofpfh,famhex(lehexa))
c
c 7.1. ==> Contenant l'arete A5
c
      indhex = indhex + 1
      call cmchea ( arehex, famhex,
     >              hethex, filhex, perhex,
     >              as1n1, as1n2, an1nf1, an2nf1,
     >              listar(5), an1n9, an2n10, af1f6,
     >              as6n9, as6n10, an9f6, an10f6,
     >              lehexa, jaux, indhex )
c
      filhex(lehexa) = indhex
c
c 7.2. ==> Contenant l'arete A7
c
      indhex = indhex + 1
      call cmchea ( arehex, famhex,
     >              hethex, filhex, perhex,
     >              an2nf1, as4n2, an4nf1, as4n4,
     >              an2n10, af1f6, listar(7), an4n12,
     >              an10f6, as7n10, an12f6, as7n12,
     >              lehexa, jaux, indhex )
c
c 7.3. ==> Contenant l'arete A8
c
      indhex = indhex + 1
      call cmchea ( arehex, famhex,
     >              hethex, filhex, perhex,
     >              an3nf1, an4nf1, as3n3, as3n4,
     >              af1f6, an3n11, an4n12, listar(8),
     >              an11f6, an12f6, as8n11, as8n12,
     >              lehexa, jaux, indhex )
c
c 7.4. ==> Contenant l'arete A6
c
      indhex = indhex + 1
      call cmchea ( arehex, famhex,
     >              hethex, filhex, perhex,
     >              as2n1, an1nf1, as2n3, an3nf1,
     >              an1n9, listar(6), af1f6, an3n11,
     >              as5n9, an9f6, as5n11, an11f6,
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
