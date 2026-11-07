      subroutine pcmahe ( elemen, nbele0,
     >                    somare, np2are,
     >                    arequa,
     >                    quahex, coquhe, arehex,
     >                    hethex, ninhex,
     >                    famhex, cfahex,
     >                    nnosca, nhesca, nhesho,
     >                    famele, noeele, typele,
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
c    aPres adaptation - Conversion - MAillage connectivite - HExaedres
c     -                 -            --                      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . elemen . es  .   1    . numero du dernier element cree             .
c . nbele0 . e   .   1    . estimation du nombre d'elements            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu d'arete          .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . ninhex . e   . nbheto . noeud interne a l'hexaedre                 .
c . famhex . e   . nbheto . famille des hexaedres                      .
c . cfahex .     . nctfhe. codes des familles des hexaedres            .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . nnosca . e   . rsnoto . numero des noeuds du code de calcul        .
c . nhesca .  s  . rsheto . numero des hexaedres dans le calcul        .
c . nhesho .  s  . nbele0 . numero des hexaedres dans HOMARD           .
c . famele . es  . nbele0 . famille med des elements                   .
c . noeele . es  . nbele0 . noeuds des elements                        .
c .        .     . *nbmane.                                            .
c . typele . es  . nbele0 . type des elements                          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'PCMAHE' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "envca1.h"
c
#include "nbfami.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombhe.h"
c
#include "nombsr.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer elemen
      integer nbele0
c
      integer somare(2,nbarto), np2are(nbarto)
      integer arequa(nbquto,4)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto), ninhex(nbheto)
c
      integer cfahex(nctfhe,nbfhex), famhex(nbheto)
c
      integer nnosca(rsnoto)
      integer nhesca(rsheto), nhesho(nbele0)
c
      integer famele(nbele0), noeele(nbele0,nbmane)
      integer typele(nbele0)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer lehexa, lehex0
      integer etat
      integer iaux
      integer listar(12), listso(20), nomiar(12)
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbhecf, nbheca =', nbhecf, nbheca
#endif
c
#include "impr03.h"
c
#include "impr06.h"
c
c====
c 2. initialisations des renumerotations
c====
c
      do 21 , iaux = 1 , rsheto
        nhesca(iaux) = 0
   21 continue
c
      do 22 , iaux = 1 , nbele0
        nhesho(iaux) = 0
   22 continue
c
c====
c 3. Conversion en lineaire
c====
c
      if ( degre.eq.1 ) then
c
c             1                   4
c             --------------------
c            /                   /.
c           /                   / .
c          /                   /  .
c         /                   /   .
c       2 -------------------- 3  .
c         .                  .    .
c         .                  .    .
c         .    5             .    . 8
c         .                  .   /
c         .                  .  /
c         .                  . /
c         .                  ./
c         --------------------
c         6                  7
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c    . Les noeuds (5,6,7,8) sont translates de (1,2,3,4)
c    . Le triedre (1-->2,1-->5,1-->4) est direct
c

        do 31 , lehex0 = 1 , nbheto
c
          lehexa = lehex0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,6), lehexa
#endif
c
          etat = mod(hethex(lehexa),1000)
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
        if ( elemen.eq.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write (ulsort,texte(langue,14)) elemen
        endif
#endif
            nhesho(elemen) = lehexa
            nhesca(lehexa) = elemen
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTASHE', nompro
#endif
            call utashe ( lehexa,
     >                    nbquto, nbhecf, nbheca,
     >                    somare, arequa,
     >                    quahex, coquhe, arehex,
     >                    listar, listso )
c
c     Attention : utashe donne la numerotation dans la convention homard
c                 il faut permuter les sommets 5/6 et 7/8 pour obtenir
c                 la numerotation dans la convention med
c
            noeele(elemen,1) = nnosca(listso(1))
            noeele(elemen,2) = nnosca(listso(2))
            noeele(elemen,3) = nnosca(listso(3))
            noeele(elemen,4) = nnosca(listso(4))
            noeele(elemen,6) = nnosca(listso(5))
            noeele(elemen,5) = nnosca(listso(6))
            noeele(elemen,8) = nnosca(listso(7))
            noeele(elemen,7) = nnosca(listso(8))
c
            famele(elemen) = cfahex(cofamd,famhex(lehexa))
            typele(elemen) = cfahex(cotyel,famhex(lehexa))
c
#ifdef _DEBUG_HOMARD_
cgn        if ( glop.ne.0 ) then
            write (ulsort,90002) 'famhex', famhex(lehexa)
            write (ulsort,texte(langue,14)) elemen
            write (ulsort,texte(langue,15))
     >             (noeele(elemen,iaux),iaux=1,8)
            write (ulsort,90002) 'Famille MED',famele(elemen)
            write (ulsort,90002) 'Type MED   ',typele(elemen)
cgn            endif
#endif
c
          endif
c
  31   continue
c
c====
c 4. Conversion en quadratique
c====
c
      elseif ( mod(mailet,5).gt.0 ) then
c
c             1                   4
c             ---------12---------
c            /                   /.
c          9/                   11.
c          /                   /  .
c         /   17              /   .
c       2 ---------10---------3   20
c         .                  .    .
c         .                  .    .
c         .    5       16    .    . 8
c       18.                  .19 /
c         .  13              .  /15
c         .                  . /
c         .                  ./
c         ---------14---------
c         6                  7
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c    . Les noeuds (5,6,7,8) sont translates de (1,2,3,4)
c    . Le triedre (1-->2,1-->5,1-->4) est direct
c
c            Au sens homard      au sens MED
c          arete  1 de s1 a s2 | de s1 a s2
c          arete  2 de s1 a s4 | de s1 a s4
c          arete  3 de s2 a s3 | de s2 a s3
c          arete  4 de s3 a s4 | de s3 a s4
c          arete  5 de s1 a s6 | de s1 a s5
c          arete  6 de s2 a s5 | de s2 a s6
c          arete  7 de s4 a s7 | de s4 a s8
c          arete  8 de s3 a s8 | de s3 a s7
c          arete  9 de s5 a s6 | de s6 a s5
c          arete 10 de s6 a s7 | de s5 a s8
c          arete 11 de s5 a s8 | de s6 a s7
c          arete 12 de s7 a s8 | de s8 a s7
c       Tableau de travail nomiar :
c       nomiar(i) contient le numero local au sens MED du noeud porte
c       par l'arete de numero local i au sens homard
c
        nomiar( 1) =  9
        nomiar( 2) = 12
        nomiar( 3) = 10
        nomiar( 4) = 11
        nomiar( 5) = 17
        nomiar( 6) = 18
        nomiar( 7) = 20
        nomiar( 8) = 19
        nomiar( 9) = 13
        nomiar(10) = 16
        nomiar(11) = 14
        nomiar(12) = 15
c
        do 41 , lehex0 = 1 , nbheto
c
          lehexa = lehex0
c
#ifdef _DEBUG_HOMARD_
        if ( elemen.eq.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,6), lehexa
#endif
c
          etat = mod(hethex(lehexa),1000)
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write (ulsort,texte(langue,14)) elemen
        endif
#endif
            nhesho(elemen) = lehexa
            nhesca(lehexa) = elemen
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTASHE', nompro
#endif
            call utashe ( lehexa,
     >                    nbquto, nbhecf, nbheca,
     >                    somare, arequa,
     >                    quahex, coquhe, arehex,
     >                    listar, listso )
c
c     Attention : utashe donne la numerotation dans la convention homard
c                 il faut permuter les sommets 5/6 et 7/8pour obtenir la
c                 numerotation dans la convention med
c
            noeele(elemen,1) = nnosca(listso(1))
            noeele(elemen,2) = nnosca(listso(2))
            noeele(elemen,3) = nnosca(listso(3))
            noeele(elemen,4) = nnosca(listso(4))
            noeele(elemen,6) = nnosca(listso(5))
            noeele(elemen,5) = nnosca(listso(6))
            noeele(elemen,8) = nnosca(listso(7))
            noeele(elemen,7) = nnosca(listso(8))
c
c     Les noeuds au milieu des aretes
c
            do 411 , iaux = 1 , 12
              noeele(elemen,nomiar(iaux)) = nnosca(np2are(listar(iaux)))
  411       continue
c
c     Les noeuds internes
c
            if ( mod(mailet,5).eq.0 ) then
              noeele(elemen,27) = nnosca(ninhex(lehexa))
            endif
c
            famele(elemen) = cfahex(cofamd,famhex(lehexa))
            typele(elemen) = cfahex(cotyel,famhex(lehexa))
c
          endif
c
  41   continue
c
c
c====
c 4. Conversion en quadratique etendu
c    Similaire au quadratique a part les noeuds de 21 a 27
c====
c
      else
c
c             1                   4
c             ---------12---------
c            /                   /.
c          9/                   11.
c          /                   /  .
c         /   17              /   .
c       2 ---------10---------3   20
c         .                  .    .
c         .                  .    .
c         .    5       16    .    . 8
c       18.                  .19 /
c         .  13              .  /15
c         .                  . /
c         .                  ./
c         ---------14---------
c         6                  7
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c    . Les noeuds (5,6,7,8) sont translates de (1,2,3,4)
c    . Le triedre (1-->2,1-->5,1-->4) est direct
c
c            Au sens homard      au sens MED
c          arete  1 de s1 a s2 | de s1 a s2
c          arete  2 de s1 a s4 | de s1 a s4
c          arete  3 de s2 a s3 | de s2 a s3
c          arete  4 de s3 a s4 | de s3 a s4
c          arete  5 de s1 a s6 | de s1 a s5
c          arete  6 de s2 a s5 | de s2 a s6
c          arete  7 de s4 a s7 | de s4 a s8
c          arete  8 de s3 a s8 | de s3 a s7
c          arete  9 de s5 a s6 | de s6 a s5
c          arete 10 de s6 a s7 | de s5 a s8
c          arete 11 de s5 a s8 | de s6 a s7
c          arete 12 de s7 a s8 | de s8 a s7
c       Tableau de travail nomiar :
c       nomiar(i) contient le numero local au sens MED du noeud porte
c       par l'arete de numero local i au sens homard
c
        nomiar( 1) =  9
        nomiar( 2) = 12
        nomiar( 3) = 10
        nomiar( 4) = 11
        nomiar( 5) = 17
        nomiar( 6) = 18
        nomiar( 7) = 20
        nomiar( 8) = 19
        nomiar( 9) = 13
        nomiar(10) = 16
        nomiar(11) = 14
        nomiar(12) = 15
c
        do 51 , lehex0 = 1 , nbheto
c
          lehexa = lehex0
c
#ifdef _DEBUG_HOMARD_
        if ( elemen.eq.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,6), lehexa
#endif
c
          etat = mod(hethex(lehexa),1000)
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
            write (ulsort,texte(langue,14)) elemen
        endif
#endif
            nhesho(elemen) = lehexa
            nhesca(lehexa) = elemen
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTASHE', nompro
#endif
            call utashe ( lehexa,
     >                    nbquto, nbhecf, nbheca,
     >                    somare, arequa,
     >                    quahex, coquhe, arehex,
     >                    listar, listso )
c
c     Attention : utashe donne la numerotation dans la convention homard
c                 il faut permuter les sommets 5/6 et 7/8pour obtenir la
c                 numerotation dans la convention med
c
            noeele(elemen,1) = nnosca(listso(1))
            noeele(elemen,2) = nnosca(listso(2))
            noeele(elemen,3) = nnosca(listso(3))
            noeele(elemen,4) = nnosca(listso(4))
            noeele(elemen,6) = nnosca(listso(5))
            noeele(elemen,5) = nnosca(listso(6))
            noeele(elemen,8) = nnosca(listso(7))
            noeele(elemen,7) = nnosca(listso(8))
c
c     Les noeuds au milieu des aretes
c
            do 512 , iaux = 1 , 12
              noeele(elemen,nomiar(iaux)) = nnosca(np2are(listar(iaux)))
  512       continue
c
c     Les noeuds internes
c
            noeele(elemen,27) = nnosca(ninhex(lehexa))
c
            famele(elemen) = cfahex(cofamd,famhex(lehexa))
            typele(elemen) = cfahex(cotyel,famhex(lehexa))
c
          endif
c
  51   continue
c
      endif
c
c====
c 6. la fin
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
