      subroutine mmag32 ( indpen,
     >                    nbduno, nbduar,
     >                    nbpejt, nbvojm, nbjoto,
     >                    tbaux2, tbau30, tbau40,
     >                    tbau41,
     >                    nbte06, tbau51,
     >                    nbpe09, tbau52,
     >                    coonoe, somare,
     >                    aretri, hettri,
     >                    filtri, pertri, nivtri,
     >                    arequa,
     >                    facpen, cofape,
     >                    hetpen, filpen, perpen,
     >                    famtri, fampen,
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
c    Modification de Maillage - AGRegat - phase 3.2
c    -               -          --              - -
c    Creation des mailles pour les joints triples :
c    . pentaedres
c    Et donc des triangles supplementaires
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indpen . es  .   1    . indice du dernier pentaedre cree           .
c . nbduno . e   .   1    . nombre de duplication de noeuds            .
c . nbduar . e   .   1    . nombre de duplications d'aretes            .
c . nbpejt . e   .   1    . nombre de pentaedres de joints triples     .
c . nbvojm . e   .   1    . nombre de volumes de joints multiples      .
c . nbjoto . e   .   1    . nombre total de joints                     .
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
c . nbte06 . e   .   1    . nombre de tetr. des j. ponctuels d'ordre 6 .
c . tbau51 . es  .9*nbte06. Les tetraedres ponctuels entre les joints  .
c .        .     .        . triples :                                  .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : triangle cote du 1er joint triple  .
c .        .     .        . (3,i) : triangle cote du 2eme joint triple .
c .        .     .        . (4,i) : triangle cote du 3eme joint triple .
c .        .     .        . (5,i) : triangle cote du 4eme joint triple .
c .        .     .        . (1+k) : pour le k-eme triangle, 1 s'il     .
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
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . es  . nbtrto . historique de l'etat des triangles         .
c . filtri . es  . nbtrto . premier fils des triangles                 .
c . pertri . es  . nbtrto . pere des triangles                         .
c . nivtri . es  . nbtrto . niveau des triangles                       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . facpen . es  .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . es  .nbpecf*5. code des 5 faces des pentaedres            .
c . hetpen . es  . nbpeto . historique de l'etat des pentaedres        .
c . filpen . es  . nbpeto . premier fils des pentaedres                .
c . perpen . es  . nbpeto . pere des pentaedres                        .
c . famtri . es  . nbtrto . famille des triangles                      .
c . fampen . es  . nbpeto . famille des pentaedres                     .
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
      parameter ( nompro = 'MMAG32' )
c
#include "nblang.h"
c
      integer ordre
      parameter ( ordre = 3 )
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer indpen
      integer nbduno, nbduar
      integer nbpejt, nbvojm, nbjoto
      integer tbaux2(4,nbjoto)
      integer tbau30(8,nbduno), tbau40(6,nbduar)
      integer tbau41(4,nbvojm)
      integer nbte06, tbau51(9,nbte06)
      integer nbpe09, tbau52(11,nbpe09)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3), hettri(nbtrto)
      integer filtri(nbtrto), pertri(nbtrto), nivtri(nbtrto)
      integer arequa(nbquto,4)
      integer facpen(nbpecf,5), cofape(nbpecf,5)
      integer hetpen(nbpeto), filpen(nbpeto), perpen(nbpeto)
      integer famtri(nbtrto), fampen(nbpeto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer larete
      integer letria(2), lequad
c
      integer nujoin, nujois(ordre)
      integer aredup(2*ordre)
      integer arejoi(ordre), quajoi(ordre)
      integer nujolo(ordre)
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1, sa3a1
      integer sompen(6), arepen(9), orient
      integer tabcod(6)
c
      integer nbmess
      parameter ( nbmess = 40 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      data tabcod / 4, 5, 6, 1, 2, 3 /
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) mess14(langue,3,7), nbpejt
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), nbduno
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbduar
#endif
c
      codret = 0
c
cgn      write(ulsort,1001) 'nbnoto, nbarto, nbtrto',nbnoto, nbarto,nbtrto
cgn      write(ulsort,1001) 'nbpejt',nbpejt
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
c 2. Parcours des aretes triples / pentaedres de joint triple
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,1)
#endif
c
c  Le long de l'arete triple :
c  Le triangle (a1,a2,a3) est defini du cote du 1er sommet
c     a1 est du cote du 1er joint simple voisin
c     a2 est du cote du 2eme joint simple voisin
c     a3 est du cote du 3eme joint simple voisin
c  Le triangle (a4,a5,a6) est defini du cote du 2nd sommet
c     a4 est du cote du 1er joint simple voisin
c     a5 est du cote du 2eme joint simple voisin
c     a6 est du cote du 3eme joint simple voisin
c  L'arete triple se retrouve dans a7, a8, a9.
c
c    S3=tbau30(3,i/St3)       arepen(9)          S6=tbau30(4,i/St3)
c           x------------------------------------------x
c          .                                          .
c         .  .                                       .  .
c   arepen(3)                                  arepen(6)
c       .     .                                    .     .
c      .                                          .
c     .        .arepen(1)                        .        . arepen(4)
c    .                                          .
c S2.           .          arepen(8)         S5.=tbau30(4,i/St2)
c  x - - - - - - - - - - - - - - - - - - - - -x
ctbau30(3,i/St2).                               .           .
c          .                                          .
c       arepen(2)                                arepen(5).  .
c                  x------------------------------------------x
c       S1=tbau30(3,i/St1)          arepen(7)        S4=tbau30(4,i/St1)
c
c voir utarpe pour le croquis ci-dessus
c
      do 2 , iaux = 1 , nbpejt
c
        indpen = indpen + 1
c
        larete = tbau41(1,iaux)
c
        nujoin = tbau41(2,iaux)
c
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
      write (ulsort,texte(langue,31)) nujoin
              endif
#endif
c
c 2.1. ==> reperage des numeros des 3 joints simples voisins
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
C          Elles delimitent les faces 1 et 2 du pentaedre en cours.
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
        write (ulsort,texte(langue,16)) mess14(langue,1,7), indpen, 0
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
        write (ulsort,texte(langue,16)) mess14(langue,1,7), indpen, 0
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
c          Par hypothese, la face f3 du pentaedre s'appuie sur le 1er
c          joint simple. Ensuite, par definition du pentaedre, les
c          faces f4 et f5 arrivent dans le sens positif quand on
c          entre dans le pentaedre depuis la face f1.
c          On cherche donc le positionnement des 3 joints relativement
c          a l'arete dupliquee et on en deduit l'ordre d'apparition
c          des joints qui creeront les faces f4 et f5.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTORA3', nompro
#endif
        call utora3 ( orient,
     >                larete,
     >                arejoi(1), arejoi(2), arejoi(3),
     >                coonoe, somare,
     >                ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
      if ( larete.eq.-8 ) then
      write (ulsort,90002)'orient',orient
      endif
#endif
c
        nujolo(1) = 1
        if ( orient.gt.0 ) then
          nujolo(2) = 2
          nujolo(3) = 3
        else
          nujolo(2) = 3
          nujolo(3) = 2
        endif
c
c 2.5. ==> Creation des triangles
c          Eventuellement, on recree plusieurs fois le meme triangle.
c          Pas grave car il est toujours cree en s'orientant sur les
c          joints simples adjacents.
c
        do 25 , jaux = 1 , 2
c
c 2.5.1. ==> Numero du triangle
c
          kaux = tbau41(2+jaux,iaux)
c
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,2), kaux,
     > jaux
       write (ulsort,texte(langue,17))
     > (aredup(kaux),kaux=ordre*(jaux-1)+1,ordre*jaux)
           endif
#endif
c
c 2.5.2. ==> Aretes
c          La 1ere arete est celle jouxtant le 1er joint simple.
c          La 2eme arete est celle jouxtant le 2eme joint simple.
c          La 3eme arete est la derniere.
c
          aretri(kaux,1) = aredup(ordre*jaux-2)
          aretri(kaux,2) = aredup(ordre*jaux-1)
          aretri(kaux,3) = aredup(ordre*jaux)
c
c 2.5.3. ==> Caracteristiques
c
          famtri(kaux) = 1
c
          hettri(kaux) = 0
          filtri(kaux) = 0
          pertri(kaux) = 0
          nivtri(kaux) = 0
c
          letria(jaux) = kaux
c
c 2.5.4. ==> Impact pour l'eventuel joint ponctuel voisin
c            Pour le 1er triangle :
c            . Si l'orientation est positive, le triangle entre dans le
c              pentaedre, donc sort de l'eventuel joint ponctuel
c              voisin : -1 = 2*1 - 3
c            . Sinon, le triangle sort du pentaedre, donc entre dans
c              l'eventuel joint ponctuel voisin : 1 = 3 - 2*1
c            Pour le 2nd triangle : raisonnement symetrique
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
      write (ulsort,texte(langue,3)) 'MMAG93', nompro
#endif
          call mmag93 ( kaux, laux,
     >                  nbte06, tbau51,
     >                  nbpe09, tbau52,
     >                  ulsort, langue, codret )
c
   25   continue
c
c 2.6. ==> Creation du pentaedre
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,16)) mess14(langue,1,7), indpen, 0
#endif
c
c 2.6.1. ==> Face 1 : c'est le triangle cree du cote du debut de
c                     l'arete triple
c   On impose :
c     la 1ere arete du pentaedre est la 1ere arete du triangle ;
c   --> le code sera donc 1 ou 4.
c   Si l'orientation est positive, le triangle entre dans le pentaedre.
c   On lui donnera donc le code 1.
C   Inversement, si l'orientation est negative, il va sortir
c   du pentaedre. On lui donnera alors le code 4.
c
c   Avec utsotr, on recupere les sommets du triangle dans l'ordre de
c   ses aretes. On en deduit les 3 premiers sommets du pentaedre selon
c   le positionnement du triangle.
c
        facpen(indpen,1) = letria(1)
        if ( orient.gt.0 ) then
          cofape(indpen,1) = 1
        else
          cofape(indpen,1) = 4
        endif
c
        call utsotr ( somare, aredup(1), aredup(2), aredup(3),
     >                sa1a2, sa2a3, sa3a1 )
        arepen(1) = aredup(1)
        if ( orient.gt.0 ) then
          arepen(2) = aredup(2)
          arepen(3) = aredup(3)
          sompen(1) = sa1a2
          sompen(3) = sa3a1
        else
          arepen(2) = aredup(3)
          arepen(3) = aredup(2)
          sompen(1) = sa3a1
          sompen(3) = sa1a2
        endif
        sompen(2) = sa2a3
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,90002)'sommets tria',sa1a2, sa2a3, sa3a1
      write (ulsort,90002)'sommets penta 1-3',(sompen(jaux),jaux=1,3)
      write (ulsort,90002)'aretes penta  1-3',(arepen(jaux),jaux=1,3)
            endif
#endif
c
c 2.6.2. ==> Face 2 : c'est le 2nd triangle cree, du cote de la fin
c                     de l'arete triple.
c   Suite aux choix faits sur f1, sa 1ere arete est a4.
c   Si le code du triangle en tant que face 1 est 1, alors sa 2eme arete
c   est la translatee de a2, donc a5, ce qui fait un code 4.
c   Si le code du triangle en tant que face 1 est 4, alors sa 2eme arete
c   est la translatee de a3, donc a5, ce qui fait un code 1.
c
        facpen(indpen,2) = letria(2)
        cofape(indpen,2) = tabcod(cofape(indpen,1))
c
        call utsotr ( somare, aredup(4), aredup(5), aredup(6),
     >                sa1a2, sa2a3, sa3a1 )
        arepen(4) = aredup(4)
        if ( orient.gt.0 ) then
          arepen(5) = aredup(5)
          arepen(6) = aredup(6)
          sompen(4) = sa1a2
          sompen(6) = sa3a1
        else
          arepen(5) = aredup(6)
          arepen(6) = aredup(5)
          sompen(4) = sa3a1
          sompen(6) = sa1a2
        endif
        sompen(5) = sa2a3
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,90002)'sommets tria',sa1a2, sa2a3, sa3a1
      write (ulsort,90002)'sommets penta 4-6',(sompen(jaux),jaux=4,6)
      write (ulsort,90002)'aretes penta  4-6',(arepen(jaux),jaux=4,6)
            endif
#endif
c
c 2.6.3. ==> Face 3 : par definition du pentaedre, elle s'appuie sur a1.
c   Par construction, quajoi(1) borde le 1er joint, donc f3=quajoi(1)
c   Par construction, l'arete dupliquee est la 1ere et la 3eme du
c   quadrangle (mmag31), donc il y a 4 possibilites de positionnement :
c     Si (a1,a9,a4,a7) du pentaedre = (a4,a1,a2,a3) du quad : code = 2
c     Si (a1,a9,a4,a7) du pentaedre = (a2,a1,a4,a3) du quad : code = 6
c     Si (a1,a9,a4,a7) du pentaedre = (a4,a3,a2,a1) du quad : code = 8
c     Si (a1,a9,a4,a7) du pentaedre = (a2,a3,a4,a1) du quad : code = 4
c  On va positionner le tout en recherchant les extremites de l'arete
c  dupliquee et en les comparant aux sommets du pentaedre
c
        facpen(indpen,3) = quajoi(1)
        a1 = arequa(quajoi(1),1)
        a2 = arequa(quajoi(1),2)
        a3 = arequa(quajoi(1),3)
        a4 = arequa(quajoi(1),4)
cgn      write (ulsort,90002) 'aretes de fac 3 1/9/4/7',
cgn     >                     arepen(1),arepen(9), arepen(4), arepen(7)
        call utsoqu ( somare, a1, a2, a3, a4,
     >                sa1a2, sa2a3, sa3a4, sa4a1 )
cgn      write (ulsort,90002) 'aretes de qua 1', a1, a2, a3, a4
cgn      write (ulsort,90002) 'sommet de qua 1', sa1a2, sa2a3, sa3a4, sa4a1
c
        if ( sa1a2.eq.sompen(1) .or. sa1a2.eq.sompen(4) ) then
          arepen(7) = a1
          arepen(9) = a3
        elseif ( sa1a2.eq.sompen(3) .or. sa1a2.eq.sompen(6) ) then
          arepen(7) = a3
          arepen(9) = a1
        else
          write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
          write (ulsort,texte(langue,16)) mess14(langue,1,7), indpen, 0
          write (ulsort,texte(langue,31)) nujoin
          write (ulsort,texte(langue,39)) nujois
cgn      write (ulsort,90002) 'aretes de fac 1 1/2/3',
cgn     >                     aredup(1),aredup(2), aredup(3)
cgn      write (ulsort,90002) 'aretes de fac 1 4/5/6',
cgn     >                     aredup(4),aredup(5), aredup(6)
cgn      write (ulsort,90002) 'aretes de fac 3 1/9/4/7',
cgn     >                     aredup(1),    0  , aredup(4), 0
cgn      write (ulsort,90002) 'aretes de qua 1 1/2/3/4', a1, a2, a3, a4
cgn      write (ulsort,90002) 'aretes de qua 1 1/2/3/4', a1, a2, a3, a4
cgn      write (ulsort,90002) 'sommet de qua 1 ',
cgn     >                         sa1a2, sa2a3, sa3a4, sa4a1
          codret = 263
          goto 5555
        endif
c
        if ( arepen(9).eq.a1 ) then
          if ( arepen(1).eq.a4 ) then
            cofape(indpen,3) = 2
          else
            cofape(indpen,3) = 6
          endif
        else
          if ( arepen(1).eq.a4 ) then
            cofape(indpen,3) = 8
          else
            cofape(indpen,3) = 4
          endif
        endif
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,90002)'aretes penta  7-9',(arepen(jaux),jaux=7,9)
            endif
#endif
c
c 2.6.4. ==> Face 4 : par definition du pentaedre, elle s'appuie sur a2.
c   Selon l'orientation, la 2eme arete du pentaedre borde le 2eme ou
c   le 3eme joint.
c   Par construction, l'arete dupliquee est la 1ere et la 3eme du
c   quadrangle (mmag31), donc il y a 4 possibilites de positionnement :
c     Si (a2,a7,a5,a8) du pentaedre = (a4,a1,a2,a3) du quad : code = 2
c     Si (a2,a7,a5,a8) du pentaedre = (a2,a1,a4,a3) du quad : code = 6
c     Si (a2,a7,a5,a8) du pentaedre = (a4,a3,a2,a1) du quad : code = 8
c     Si (a2,a7,a5,a8) du pentaedre = (a2,a3,a4,a1) du quad : code = 4
c
        lequad = quajoi(nujolo(2))
        facpen(indpen,4) = lequad
c
        if ( arepen(7).eq.arequa(lequad,1) ) then
          if ( arepen(2).eq.arequa(lequad,4) ) then
            cofape(indpen,4) = 2
          else
            cofape(indpen,4) = 6
          endif
          arepen(8) = arequa(lequad,3)
        else
          if ( arepen(2).eq.arequa(lequad,4) ) then
            cofape(indpen,4) = 8
          else
            cofape(indpen,4) = 4
          endif
          arepen(8) = arequa(lequad,1)
        endif
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,90002)'aretes penta  7-9',(arepen(jaux),jaux=7,9)
            endif
#endif
c
c 2.6.5. ==> Face 5 : par definition du pentaedre, elle s'appuie sur a3.
c   Selon l'orientation, la 3eme arete du pentaedre borde le 2eme ou
c   le 3eme joint.
c   Par construction, l'arete dupliquee est la 1ere et la 3eme du
c   quadrangle (mmag31), donc il y a 4 possibilites de positionnement :
c     Si (a3,a8,a6,a9) du pentaedre = (a4,a1,a2,a3) du quad : code = 2
c     Si (a3,a8,a6,a9) du pentaedre = (a2,a1,a4,a3) du quad : code = 6
c     Si (a3,a8,a6,a9) du pentaedre = (a4,a3,a2,a1) du quad : code = 8
c     Si (a3,a8,a6,a9) du pentaedre = (a2,a3,a4,a1) du quad : code = 4
c
        lequad = quajoi(nujolo(3))
        facpen(indpen,5) = lequad
c
        if ( arepen(9).eq.arequa(quajoi(3),3) ) then
          if ( arepen(3).eq.arequa(quajoi(3),4) ) then
            cofape(indpen,5) = 2
          else
            cofape(indpen,5) = 6
          endif
        else
          if ( aredup(3).eq.arequa(quajoi(3),4) ) then
            cofape(indpen,5) = 8
          else
            cofape(indpen,5) = 4
          endif
        endif
c
c 2.6.6. ==> nujoin est le numero du joint parmi tous les joints.
c            Il faut ajouter 1 pour tenir compte de la famille libre.
c
        fampen(indpen) = nujoin + 1
c
        hetpen(indpen)  = 0
        filpen(indpen)  = 0
        perpen(indpen)  = 0
c
#ifdef _DEBUG_HOMARD_
          if ( larete.eq.-8 ) then
      write (ulsort,texte(langue,16)) mess14(langue,1,7), indpen, 0
      do 4444 , jaux = 1, 5
        write (ulsort,90001) 'face/code', jaux,
     >                       facpen(indpen,jaux),cofape(indpen,jaux)
 4444 continue
      write (ulsort,90002)'aretes penta  1-3',(arepen(jaux),jaux=1,3)
      write (ulsort,90002)'aretes penta  4-6',(arepen(jaux),jaux=4,6)
      write (ulsort,90002)'aretes penta  7-9',(arepen(jaux),jaux=7,9)
      write (ulsort,90002)'sommets penta 1-3', (sompen(jaux),jaux=1,3)
      write (ulsort,90002)'sommets penta 4-6', (sompen(jaux),jaux=4,6)
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
