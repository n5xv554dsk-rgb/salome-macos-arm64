      subroutine mmag33 ( indhex,
     >                    nbduno, nbduar,
     >                    nbpejt, nbhejq, nbvojm, nbjoto,
     >                    nbjois, nbjoit,
     >                    tbaux2, tbau30, tbau40,
     >                    tbau41,
     >                    nbhe12, tbau53,
     >                    nbpe09, tbau52,
     >                    coonoe, somare,
     >                    arequa, hetqua,
     >                    filqua, perqua, nivqua,
     >                    quahex, coquhe,
     >                    hethex, filhex, perhex,
     >                    famqua, famhex,
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
c    Modification de Maillage - AGRegat - phase 3.3
c    -               -          --              - -
c    Creation des mailles pour les joints quadruples :
c    . hexaedres
c    Et donc des quadrangles supplementaires
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indhex . es  .   1    . indice du dernier hexaedre cree            .
c . nbduno . e   .   1    . nombre de duplication de noeuds            .
c . nbduar . e   .   1    . nombre de duplications d'aretes            .
c . nbpejt . e   .   1    . nombre de pentaedres de joints triples     .
c . nbhejq . e   .   1    . nombre d'hexaedres de joints quadruples    .
c . nbvojm . e   .   1    . nombre de volumes de joints multiples      .
c . nbjoto . e   .   1    . nombre total de joints                     .
c . nbjois . e   .   1    . nombre de joints simples                   .
c . nbjoit . e   .   1    . nombre de joints triples                   .
c . tbaux2 . e   .4*nbjoto. Pour le i-eme joint :                      .
c .        .     .        . Numeros des familles MED des volumes       .
c .        .     .        . jouxtant le pentaedre/hexaedre, classes du .
c .        .     .        . plus petit (1,i) au plus grand             .
c .        .     .        . 0, si pas de volume voisin                 .
c . tbau30 . e   .8*nbduno. Pour la i-eme duplication de noeud :       .
c .        .     .        . (1,i) : noeud a dupliquer                  .
c .        .     .        . (2,i) : arete construite sur le noeud      .
c .        .     .        . (3,i) : noeud cree cote min(fammed)        .
c .        .     .        . (4,i) : noeud cree cote max(fammed)        .
c .        .     .        . (5,i) : numero du joint simple cree        .
c .        .     .        . (6,i) : arete entrant dans le cote 1       .
c .        .     .        . (7,i) : arete entrant dans le cote 2       .
c .        .     .        . (8,i) : ordre de multiplicite              .
c . tbau40 . e   .6*nbduar. Pour la i-eme duplication d'arete :        .
c .        .     .        . (1,i) : arete a dupliquer                  .
c .        .     .        . (2,i) : arete creee cote min(fammed)       .
c .        .     .        . (3,i) : arete creee cote max(fammed)       .
c .        .     .        . (4,i) : numero du joint simple cree        .
c .        .     .        . (5,i) : ordre de multiplicite              .
c .        .     .        . (6,i) : arete d'orientation de joint       .
c . tbau41 . e   .4*nbvojm. Les pentaedres de joint triple, puis les   .
c .        .     .        . hexaedres de joint quadruple :             .
c .        .     .        . (1,i) : arete multiple                     .
c .        .     .        . (2,i) : numero du joint                    .
c .        .     .        . Pour le i-eme pentaedre de joint triple :  .
c .        .     .        . (3,i) : triangle cree cote 1er sommet      .
c .        .     .        . (4,i) : triangle cree cote 2nd sommet      .
c .        .     .        . Pour le i-eme hexaedre de joint quadruple :.
c .        .     .        . (3,i) : quadrangle cree cote 1er sommet    .
c .        .     .        . (4,i) : quadrangle cree cote 2nd sommet    .
c . nbhe12 . e   .   1    . nombre de hexa. des j. ponctuels d'ordre 12.
c . tbau53 . es  .  13*   . Les hexaedres ponctuels entre les joints   .
c .        .     . nbhe12 . quadruples (ordre 12) :                    .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : quadrangle cote du 1er joint quad. .
c .        .     .        . (3,i) : quadrangle cote du 2eme joint quad..
c .        .     .        . (4,i) : quadrangle cote du 3eme joint quad..
c .        .     .        . (5,i) : quadrangle cote du 4eme joint quad..
c .        .     .        . (6,i) : quadrangle cote du 5eme joint quad..
c .        .     .        . (7,i) : quadrangle cote du 6eme joint quad..
c .        .     .        . (1+k) : pour le k-eme quadrangle, 1 s'il   .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . nbpe09 . e   .   1    . nombre de pent. des j. ponctuels d'ordre 9 .
c . tbau52 . es  .  11*   . Les pentaedres ponctuels entre les joints  .
c .        .     . nbpe09 . triples et quadruples :                    .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : triangle cote du 1er joint triple  .
c .        .     .        . (3,i) : triangle cote du 2eme joint triple .
c .        .     .        . (4,i) : quadrangle cote du 1er joint quad. .
c .        .     .        . (5,i) : quadrangle cote du 2eme joint quad..
c .        .     .        . (6,i) : quadrangle cote du 3eme joint quad..
c .        .     .        . (1+k) : pour la k-eme face, 1 si elle      .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . coonoe . e   .nbnoto*3. coordonnees des noeuds                     .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 3 aretes des quadrangles       .
c . hetqua . es  . nbquto . historique de l'etat des quadrangles       .
c . filqua . es  . nbquto . premier fils des quadrangles               .
c . perqua . es  . nbquto . pere des quadrangles                       .
c . nivqua . es  . nbquto . niveau des quadrangles                     .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . quahex . es  .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . es  .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . hethex . es  . nbheto . historique de l'etat des hexaedres         .
c . filhex . es  . nbheto . premier fils des hexaedres                 .
c . perhex . es  . nbheto . pere des hexaedres                         .
c . famqua . es  . nbquto . famille des quadrangles                    .
c . famhex . es  . nbheto . famille des hexaedres                      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'MMAG33' )
c
#include "nblang.h"
c
      integer ordre
      parameter ( ordre = 4 )
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombhe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer indhex
      integer nbduno, nbduar
      integer nbpejt, nbhejq, nbvojm, nbjoto
      integer nbjois, nbjoit
      integer tbaux2(4,nbjoto)
      integer tbau30(8,nbduno), tbau40(6,nbduar)
      integer tbau41(4,nbvojm)
      integer nbhe12, tbau53(13,nbhe12)
      integer nbpe09, tbau52(11,nbpe09)
      integer somare(2,nbarto)
      integer arequa(nbquto,4), hetqua(nbquto)
      integer filqua(nbquto), perqua(nbquto), nivqua(nbquto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
      integer hethex(nbheto), filhex(nbheto), perhex(nbheto)
      integer famqua(nbquto), famhex(nbheto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer ideb, ifin
      integer larete
      integer lequad(2)
      integer nbjoin
c
      integer nujoin, nujois(ordre)
      integer aredup(2*ordre)
      integer arejoi(ordre), quajoi(ordre)
      integer nujolo(ordre), nujol2(ordre)
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
      integer somhex(8), arehex(12), orient
      integer tabcod(8)
c
      integer nbmess
      parameter ( nbmess = 40 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      data tabcod / 5, 8, 7, 6, 1, 4, 3, 2 /
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
#include "mmag01.h"
#include "mmag02.h"
c
      nbjoin = nbjois + nbjoit
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) nbjois
      write (ulsort,texte(langue,7)) mess14(langue,3,6), nbhejq
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), nbduno
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbduar
#endif
c
      codret = 0
c
      ideb = nbpejt + 1
      ifin = nbpejt + nbhejq
cgn      write (ulsort,90002) 'nbpejt', nbpejt
cgn      write (ulsort,90002) 'nbhejq', nbhejq
cgn      write (ulsort,*) '==> ideb , ifin =', ideb , ifin
c
cgn      write(ulsort,1001) 'nbnoto, nbarto, nbquto',nbnoto, nbarto,nbquto
cgn      write(ulsort,1001) 'nbhejq',nbhejq
cgn      write(ulsort,1000) (iaux,iaux=1,20)
cgn      write(ulsort,1001) 'tbaux2',4,nbjoto
cgn      do 1101 , kaux = 1,nbjoto
cgn       write(ulsort,1000) (tbaux2(jaux,kaux),jaux=1,4)
cgn 1101 continue
cgn      write(ulsort,1001) 'tbau41',4,nbvojm
cgn      do 1102 , kaux = 1,nbvojm
cgn       write(ulsort,1000) (tbau41(jaux,kaux),jaux=1,4)
cgn 1102  continue
cgn 1000 format(10i9)
cgn 1001 format(a,4i6)
c
c====
c 2. Parcours des aretes quadruples / hexaedres de joint quadruple
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,1)
#endif
c
c                 S5            a9             S6
c                  ----------------------------
c                 /.                          /.
c                / .                         / .
c               /  .                        /  .
c              /   .                       /   .
c           a6/    .                      /a5  .
c            /     .                     /     .
c           /   a11.                    /      .a10
c          /       .    a1             /       .
c       S2----------------------------- S1     .
c         .        .                  .        .
c         .        .           a12    .        .
c         .     S8 -------------------.--------.S7
c         .       /                   .       /
c       a3.      /                    .a2    /
c         .     /                     .     /
c         .    /                      .    /
c         . a8/                       .   /a7
c         .  /                        .  /
c         . /                         . /
c         ./                          ./
c         -----------------------------
c        S3            a4             S4
c
c    . Les noeuds (1,2,3,4) definissent un quadrangle a orientation
c      vers l'exterieur
c     Avec le code 1, les faces sont :
c     Face 1 : aretes 1, 2, 4, 3
c     Face 2 : aretes 1, 6, 9, 5
c     Face 3 : aretes 2, 5, 10, 7
c     Face 4 : aretes 3, 8, 11, 6
c     Face 5 : aretes 4, 7, 12, 8
c     Face 6 : aretes 9, 11, 12, 10
c
c  L'arete quadruple se retrouve dans a5, a7, a8, a6.
c  On impose que :
c  Le long de l'arete quadruple :
c  . La face F1 (a1,a2,a4,a3) est definie du cote du 1er sommet et
c     a1 est du cote du 1er joint simple voisin
c  . La face F2 borde le 1er joint simple.c
      ideb = nbpejt + 1
      ifin = nbpejt + nbhejq
cgn      write (ulsort,90002) 'nbpejt', nbpejt
cgn      write (ulsort,90002) 'nbhejq', nbhejq
cgn      write (ulsort,*) '==> ideb , ifin =', ideb , ifin

c  . La face F3 borde le joint qui suit le 1er.
c  . La face F4 borde le joint qui suit le 2eme.
c  . La face F5 est opposee a F2.
c  . La face F6 (a9,a11,a12,a10) est definie du cote du 2nd sommet :
c     a9 est du cote du 1er joint simple voisin
c
c voir utarhe pour le croquis ci-dessus
c
      do 2 , iaux = ideb , ifin
c
        indhex = indhex + 1
c
        larete = tbau41(1,iaux)
c
        nujoin = tbau41(2,iaux)
c
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
      write (ulsort,texte(langue,32)) nujoin - nbjoin
              endif
#endif
c
c 2.1. ==> reperage des numeros des 4 joints simples voisins
c
        do 21 , jaux = 1 , ordre
          nujois(jaux) = tbaux2(jaux,nujoin)
   21   continue
#ifdef _DEBUG_HOMARD_
        if ( larete.eq.-8 ) then
        write (ulsort,texte(langue,39)) nujois
        endif
#endif
c
c 2.2. ==> Reperage des aretes qui partent de chacun des noeuds.
C          Elles delimitent les faces 1 et 6 de l'hexaedre en cours.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG91', nompro
#endif
        call mmag91 ( larete, ordre, nujois,
     >                nbduno, tbau30,
     >                somare,
     >                aredup,
     >                ulsort, langue, codret )
c
        if ( codret.ne.0 ) then
        write (ulsort,texte(langue,16)) mess14(langue,1,6), indhex, 0
        write (ulsort,texte(langue,31)) nujoin
        goto 5555
        endif
c
c 2.3. ==> Reperage des aretes et des quadrangles batis sur les joints
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG92', nompro
#endif
        call mmag92 ( larete, ordre, nujois,
     >                nbduar, tbau40,
     >                arejoi, quajoi,
     >                ulsort, langue, codret )
c
        if ( codret.ne.0 ) then
        write (ulsort,texte(langue,16)) mess14(langue,1,7), indhex, 0
        write (ulsort,texte(langue,31)) nujoin
        goto 5555
        endif
c
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
        do 23111 , jaux = 1 , ordre
        write (ulsort,90015)'Joint',jaux,', quadrangle',quajoi(jaux)
        write (ulsort,90015)'arete de joints',arejoi(jaux),
     >   ', de sommets',somare(1,arejoi(jaux)),somare(2,arejoi(jaux))
23111   continue
          endif
#endif
c
c 2.4. ==> Determination de l'orientation des joints
c          Par hypothese, la face f2 de l'hexaedre s'appuie sur le 1er
c          joint simple. Ensuite, par definition de l'hexaedre, les
c          faces f3, f5 et f4 arrivent dans le sens positif quand on
c          entre dans l'hexaedre depuis la face f1.
c          On cherche donc le positionnement des 4 joints relativement
c          a l'arete dupliquee et on en deduit l'ordre d'apparition
c          des joints qui creeront les faces f3, f5 et f4.
c          Ensuite, il faut definir un enchainement des aretes de joint
c          dans un ordre coherent.
c          . Soit on suit l'ordre entrant dans l'hexaedre que l'on veut
c            creer ;
c          . Soit on suit l'ordre inverse
c          Il faut que le choix entre les deux soit independant de
c          l'hexaedre car ce quadrangle peut apparaitre pour l'hexaedre
c          courant ou pour son voisin. Et donc le caractere
c          entrant/sortant va changer. On choisira de tourner dans
c          un sens ou dans un autre en fonction du plus petit numero de
c          joint qui suit.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTORA3', nompro
#endif
        call utora4 ( nujolo,
     >                larete,
     >                arejoi(1), arejoi(2), arejoi(3), arejoi(4),
     >                coonoe, somare,
     >                ulsort, langue, codret )
c
        if ( nujois(nujolo(2)).lt.nujois(nujolo(4)) ) then
          orient = 1
          nujol2(2) = nujolo(2)
          nujol2(4) = nujolo(4)
        else
          orient = -1
          nujol2(2) = nujolo(4)
          nujol2(4) = nujolo(2)
        endif
#ifdef _DEBUG_HOMARD_
      if ( larete.eq.-8 ) then
      write (ulsort,90002)'orient',orient
      endif
#endif
c
c 2.5. ==> Creation des quadrangles
c          Eventuellement, on recree plusieurs fois le meme quadrangle.
c          Pas grave car il est toujours cree en s'orientant sur les
c          joints simples adjacents.
c
        do 25 , jaux = 1 , 2
c
c 2.5.1. ==> Numero du quadrangle
c
          kaux = tbau41(2+jaux,iaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,16)) mess14(langue,1,4), kaux,
     > jaux
       write (ulsort,texte(langue,17))
     > (aredup(kaux),kaux=ordre*(jaux-1)+1,ordre*jaux)
#endif
c
c 2.5.2. ==> Aretes
c          La 1ere arete est celle jouxtant le 1er joint simple.
c          La 2eme arete est celle qui suit selon la regle precedente.
c          La 3eme arete est celle qui borde le 3eme joint.
c          La 4eme arete est celle qui suit selon la regle precedente.
c
          arequa(kaux,1) = aredup(ordre*(jaux-1)+1)
          arequa(kaux,2) = aredup(ordre*(jaux-1)+nujol2(2))
          arequa(kaux,3) = aredup(ordre*(jaux-1)+nujolo(3))
          arequa(kaux,4) = aredup(ordre*(jaux-1)+nujol2(4))
c
c 2.5.3. ==> Caracteristiques
c
          famqua(kaux) = 1
c
          hetqua(kaux) = 0
          filqua(kaux) = 0
          perqua(kaux) = 0
          nivqua(kaux) = 0
c
          lequad(jaux) = kaux
c
c 2.5.4. ==> Impact pour l'eventuel joint ponctuel voisin
c            Pour le 1er quadrangle :
c            . Si l'orientation est positive, le quadrangle entre dans
c              l'hexaedre, donc sort de l'eventuel joint ponctuel
c              voisin : -1 = 2*1 - 3
c            . Sinon, le triangle sort de l'hexaedre, donc entre dans
c              l'eventuel joint ponctuel voisin : 1 = 3 - 2*1
c            Pour le 2nd quadrangle : raisonnement symetrique
c            . Orientation >0, entree :  1 = 2*2 - 3
c            . Orientation <0, sortie : -1 = 3 - 2*2
c
          if ( orient.gt.0 ) then
            laux = 2*jaux - 3
          else
            laux = 3 - 2*jaux
          endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG94', nompro
#endif
          call mmag94 ( kaux, laux,
     >                  nbhe12, tbau53,
     >                  nbpe09, tbau52,
     >                  ulsort, langue, codret )
c
   25   continue
c
c 2.6. ==> Creation de l'hexaedre
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,16)) mess14(langue,1,6), indhex, 0
#endif
c
c 2.6.1. ==> La face f1 est le 1er quadrangle.
c   On impose :
c     la 1ere arete de l'hexaedre est la 1ere arete du quadrangle ;
c   --> le code sera donc 1 ou 5.
c   Si l'orientation est positive, le quadrangle entre dans l'hexaedre.
c   On lui donnera donc le code 1.
C   Inversement, si l'orientation est negative, il va sortir
c   de l'hexaedre. On lui donnera alors le code 5.
c
        quahex(indhex,1) = lequad(1)
        if ( orient.gt.0 ) then
          coquhe(indhex,1) = 1
        else
          coquhe(indhex,1) = 5
        endif
c
        call utsoqu ( somare,
     >                aredup(1), aredup(nujol2(2)),
     >                aredup(nujolo(3)), aredup(nujol2(4)),
     >                sa1a2, sa2a3, sa3a4, sa4a1 )
        arehex(1) = aredup(1)
        arehex(2) = aredup(nujolo(2))
        arehex(4) = aredup(nujolo(3))
        arehex(3) = aredup(nujolo(4))
        if ( orient.gt.0 ) then
          somhex(1) = sa1a2
          somhex(4) = sa2a3
          somhex(3) = sa3a4
          somhex(2) = sa4a1
        else
          somhex(1) = sa4a1
          somhex(4) = sa3a4
          somhex(3) = sa2a3
          somhex(2) = sa1a2
        endif
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,90002)'sommets quad',sa1a2, sa2a3, sa3a4, sa4a1
      write (ulsort,90002)'sommets hexa 1-4',(somhex(jaux),jaux=1,4)
      write (ulsort,90002)'aretes hexa  1-4',(arehex(jaux),jaux=1,4)
            endif
#endif
c
c 2.6.2. ==> Face 6 : c'est le quadrangle cree du cote de la fin
c                     de l'arete quadruple.
c   Suite aux choix faits sur f1, sa 1ere arete est a9.
c   Si le code du quadrangle en tant que face 1 est 1, alors sa 2eme
c   arete est la translatee de a2, donc a10, ce qui fait un code 5.
c   Si le code du quadrangle en tant que face 1 est 4, alors sa 2eme
c   arete est la translatee de a3, donc a11, ce qui fait un code 1.
c
        quahex(indhex,6) = lequad(2)
        coquhe(indhex,6) = tabcod(coquhe(indhex,1))
c
        call utsoqu ( somare,
     >                aredup(5), aredup(ordre+nujol2(2)),
     >                aredup(ordre+nujolo(3)), aredup(ordre+nujol2(4)),
     >                sa1a2, sa2a3, sa3a4, sa4a1 )
        arehex( 9) = aredup(5)
        arehex(10) = aredup(ordre+nujolo(2))
        arehex(12) = aredup(ordre+nujolo(3))
        arehex(11) = aredup(ordre+nujolo(4))
        if ( orient.gt.0 ) then
          somhex(6) = sa1a2
          somhex(7) = sa2a3
          somhex(8) = sa3a4
          somhex(5) = sa4a1
        else
          somhex(6) = sa4a1
          somhex(7) = sa3a4
          somhex(8) = sa2a3
          somhex(5) = sa1a2
        endif
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,90002)'sommets quad',sa1a2, sa2a3, sa3a4, sa4a1
      write (ulsort,90002)'sommets hexa  5-8',(somhex(jaux),jaux=5,8)
      write (ulsort,90002)'aretes hexa  9-12',(arehex(jaux),jaux=9,12)
            endif
#endif
c
c 2.6.3. ==> Face 2 : par definition de l'hexa, elle s'appuie sur a1.
c   Par construction, quajoi(1) borde le 1er joint, donc f2=quajoi(1).
c   Par construction, l'arete dupliquee est la 1ere et la 3eme
c   du quadrangle (cf. mmag31), donc :
c   Les aretes 1 et 3 du quadrangle peuvent etre a5 ou a6
c   Les aretes 2 et 4 du quadrangle peuvent etre a1 ou a9
c   Si (a1,a6,a9,a5) de l'hexaedre = (a4,a1,a2,a3) du quad : code = 2
c   Si (a1,a6,a9,a5) de l'hexaedre = (a2,a1,a4,a3) du quad : code = 6
c   Si (a1,a6,a9,a5) de l'hexaedre = (a4,a3,a2,a1) du quad : code = 8
c   Si (a1,a6,a9,a5) de l'hexaedre = (a2,a3,a4,a1) du quad : code = 4
c
        quahex(indhex,2) = quajoi(1)
        a1 = arequa(quajoi(1),1)
        a2 = arequa(quajoi(1),2)
        a3 = arequa(quajoi(1),3)
        a4 = arequa(quajoi(1),4)
cgn      write (ulsort,90002) 'aretes de fac 2 1/6/9/5',
cgn     >                     arehex(1),arehex(6), arehex(9), arehex(5)
        call utsoqu ( somare, a1, a2, a3, a4,
     >                sa1a2, sa2a3, sa3a4, sa4a1 )
cgn      write (ulsort,90002) 'aretes de qua 1', a1, a2, a3, a4
cgn      write (ulsort,90002) 'sommet de qua 1', sa1a2, sa2a3, sa3a4, sa4a1
        if ( sa1a2.eq.somhex(1) .or. sa1a2.eq.somhex(6) ) then
          arehex(5) = a1
          arehex(6) = a3
        elseif ( sa1a2.eq.somhex(2) .or. sa1a2.eq.somhex(5) ) then
          arehex(5) = a3
          arehex(6) = a1
        else
          write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
          write (ulsort,texte(langue,16)) mess14(langue,1,6), indhex, 0
          write (ulsort,texte(langue,32)) nujoin - nbjoin
          write (ulsort,texte(langue,39)) nujois
cgn      write (ulsort,90002) 'aretes de fac 1 1/2/3',
cgn     >                     arehex(1),arehex(2), arehex(3)
cgn      write (ulsort,90002) 'aretes de fac 1 4/5/6',
cgn     >                     arehex(4),arehex(5), arehex(6)
cgn      write (ulsort,90002) 'aretes de fac 3 1/9/4/7',
cgn     >                     arehex(1),    0  , arehex(4), 0
cgn      write (ulsort,90002) 'aretes de qua 1 1/2/3/4', a1, a2, a3, a4
cgn      write (ulsort,90002) 'sommet de fac 3 1/3/6/4',
cgn     >                     somhex(1),somhex(3), somhex(6), somhex(4)
cgn      write (ulsort,90002) 'aretes de qua 1 1/2/3/4', a1, a2, a3, a4
cgn      write (ulsort,90002) 'sommet de qua 1 ',
cgn     >                         sa1a2, sa2a3, sa3a4, sa4a1
          codret = 263
          goto 5555
        endif
cgn      write (ulsort,90002) 'arehex(5), arehex(6)',arehex(5), arehex(6)
        if ( arehex(6).eq.a1 ) then
          if ( arehex(1).eq.a4 ) then
            coquhe(indhex,2) = 2
          else
            coquhe(indhex,2) = 6
          endif
        else
c   La face f3 est le quadrangle quajoi(2).
          if ( arehex(1).eq.a4 ) then
            coquhe(indhex,2) = 8
          else
            coquhe(indhex,2) = 4
          endif
        endif
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,90002)'aretes hexa 5-6',(arehex(jaux),jaux=5,6)
            endif
#endif
c
c 2.6.4. ==> Face 3 : par definition de l'hexa, elle s'appuie sur a2.
c   Par construction, f3=quajoi(du 2eme dans l'ordre entrant).
c   Par construction, l'arete dupliquee est la 1ere et la 3eme
c   du quadrangle (cf. mmag31), donc :
c   Les aretes 1 et 3 du quadrangle peuvent etre a5 ou a7
c   Les aretes 2 et 4 du quadrangle peuvent etre a2 ou a10
c   Si (a2,a5,a10,a7) de l'hexaedre = (a4,a1,a2,a3) du quad : code = 2
c   Si (a2,a5,a10,a7) de l'hexaedre = (a2,a1,a4,a3) du quad : code = 6
c   Si (a2,a5,a10,a7) de l'hexaedre = (a4,a3,a2,a1) du quad : code = 8
c   Si (a2,a5,a10,a7) de l'hexaedre = (a2,a3,a4,a1) du quad : code = 4
c
        quahex(indhex,3) = quajoi(nujolo(2))
cgn      write (ulsort,90002) 'quadrangle de F3', qua(2)
cgn      write (ulsort,90002) 'aretes de qua 1/2/3/4',
cgn     > arequa(qua(2),1),arequa(qua(2),2),
cgn     > arequa(qua(2),3),arequa(qua(2),4)
        if ( arehex(5).eq.arequa(quajoi(nujolo(2)),1) ) then
          if ( arehex(2).eq.arequa(quajoi(nujolo(2)),4) ) then
            coquhe(indhex,3) = 2
          else
            coquhe(indhex,3) = 6
          endif
        else
          if ( arehex(2).eq.arequa(quajoi(nujolo(2)),4) ) then
            coquhe(indhex,3) = 8
          else
            coquhe(indhex,3) = 4
          endif
        endif
cgn      write (ulsort,1001) 'aretes de fac 3 2/5/10/7',
cgn     >                     arehex(2),arehex(5), arehex(10), arehex(7)
c
c 2.6.5. ==> Face 4 : par definition de l'hexa, elle s'appuie sur a3.
c   Par construction, f4=quajoi(du 4eme dans l'ordre entrant).
c   Les aretes 1 et 3 du quadrangle peuvent etre a8 ou a6
c   Les aretes 2 et 4 du quadrangle peuvent etre a3 ou a11
c   Si (a3,a8,a11,a6) de l'hexaedre = (a4,a1,a2,a3) du quad : code = 2
c   Si (a3,a8,a11,a6) de l'hexaedre = (a2,a1,a4,a3) du quad : code = 6
c   Si (a3,a8,a11,a6) de l'hexaedre = (a4,a3,a2,a1) du quad : code = 8
c   Si (a3,a8,a11,a6) de l'hexaedre = (a2,a3,a4,a1) du quad : code = 4
c
        quahex(indhex,4) = quajoi(nujolo(4))
cgn      write (ulsort,90002) 'quadrangle de F4', qua(2)
cgn      write (ulsort,90002) 'aretes de qua 1/2/3/4',
cgn     > arequa(qua(3),1),arequa(qua(3),2),
cgn     > arequa(qua(3),3),arequa(qua(3),4)
        if ( arehex(6).eq.arequa(quajoi(nujolo(4)),3) ) then
          if ( arehex(3).eq.arequa(quajoi(nujolo(4)),4) ) then
            coquhe(indhex,4) = 2
          else
            coquhe(indhex,4) = 6
          endif
          arehex(8) = arequa(quajoi(nujolo(4)),1)
        else
          if ( arehex(3).eq.arequa(quajoi(nujolo(4)),4) ) then
            coquhe(indhex,4) = 8
          else
            coquhe(indhex,4) = 4
          endif
          arehex(8) = arequa(quajoi(nujolo(4)),3)
        endif
c
c 2.6.6. ==> Face 5 : par definition de l'hexa, elle s'appuie sur a4.
c   Par construction, f5=quajoi(du 3eme dans l'ordre entrant).
c   Les aretes 1 et 3 du quadrangle peuvent etre a7 ou a8
c   Les aretes 2 et 4 du quadrangle peuvent etre a4 ou a12
c   Si (a4,a7,a12,a8) de l'hexaedre = (a4,a1,a2,a3) du quad : code = 2
c   Si (a4,a7,a12,a8) de l'hexaedre = (a2,a1,a4,a3) du quad : code = 6
c   Si (a4,a7,a12,a8) de l'hexaedre = (a4,a3,a2,a1) du quad : code = 8
c   Si (a4,a7,a12,a8) de l'hexaedre = (a2,a3,a4,a1) du quad : code = 4
c
        quahex(indhex,5) = quajoi(nujolo(3))
cgn      write (ulsort,90002) 'quadrangle de F5', qua(2)
cgn      write (ulsort,90002) 'aretes de qua 1/2/3/4',
cgn     > arequa(qua(4),1),arequa(qua(4),2),
cgn     > arequa(qua(4),3),arequa(qua(4),4)
        if ( arehex(8).eq.arequa(quajoi(nujolo(3)),3) ) then
          if ( arehex(4).eq.arequa(quajoi(nujolo(3)),4) ) then
            coquhe(indhex,5) = 2
          else
            coquhe(indhex,5) = 6
          endif
        else
          if ( arehex(4).eq.arequa(quajoi(nujolo(3)),4) ) then
            coquhe(indhex,5) = 8
          else
            coquhe(indhex,5) = 4
          endif
        endif
c
c 2.6.8.==> nujoin est le numero du joint parmi tous les joints.
c       Il faut retrancher le nombre de joints de pentaedres qui
c       ont ete crees auparavant
c       Il faut ajouter 1 pour tenir compte de la famille libre.
c
        famhex(indhex) = nujoin - nbjoin + 1
c
        hethex(indhex)  = 0
        filhex(indhex)  = 0
        perhex(indhex)  = 0
c
#ifdef _DEBUG_HOMARD_
        if ( indhex.eq.-1 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,6), indhex, 0
      write (ulsort,90002)'faces ',(quahex(indhex,jaux),jaux=1,6)
      write (ulsort,90002)'coquhe',(coquhe(indhex,jaux),jaux=1,6)
      write (ulsort,90002)'aretes 1-4',(arehex(jaux),jaux=1,4)
      write (ulsort,90002)'aretes 5-8',(arehex(jaux),jaux=5,8)
      write (ulsort,90002)'aretes 9-12',(arehex(jaux),jaux=9,12)
      write (ulsort,90002)'sommets 1-4', (somhex(jaux),jaux=1,4)
      write (ulsort,90002)'sommets 5-8', (somhex(jaux),jaux=5,8)
        endif
#endif
c
    2 continue
c
c====
c 5. la fin
c====
c
 5555 continue
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
