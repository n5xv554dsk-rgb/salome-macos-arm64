      subroutine mmag13 ( muarmx, nbarmu, multax, multnx,
     >                    somare,
     >                    nbjois, tbaux2,
     >                    nbduno, nbduar, nbtrtn, nbqutn,
     >                    tbau30, tbau40,
     >                    tbau31, tbau41,
     >                    tbau51, tbau52, tbau53,
     >                    nbjoit, nbpejt, nbtrjt,
     >                    nbjoiq, nbhejq, nbqujq,
     >                    nbjp06, nbte06,
     >                    nbjp09, nbpe09,
     >                    nbjp12, nbhe12,
     >                    tbaux5,
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
c    Modification de Maillage - AGregat - phase 1.3
c    -               -          --              - -
c    . Creation des mailles a partir des aretes et noeuds multiples
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . muarmx . e   .   1    . ordre de multiplicite des aretes maximal   .
c .        .     .        . possible                                   .
c . nbarmu . e   . muarmx . nombre d'aretes par ordre de multiplicite  .
c . multax . e   .   1    . ordre de multiplicite des aretes maximal   .
c . munrmx . e   .   1    . ordre de multiplicite des noeuds maximal   .
c .        .     .        . possible                                   .
c . multnx . e   .   1    . ordre de multiplicite des noeuds maximal   .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . nbjois . e   .   1    . nombre de joints simples                   .
c . tbaux2 . es  .   4**  . Pour le i-eme joint :                      .
c .        .     .        . Numeros des familles MED des volumes       .
c .        .     .        . jouxtant le pentaedre/hexaedre, classes du .
c .        .     .        . plus petit (1,i) au plus grand             .
c .        .     .        . 0, si pas de volume voisin                 .
c . tbau30 . es  .8*nbduno. Pour la i-eme duplication de noeud :       .
c .        .     .        . (1,i) : noeud a dupliquer                  .
c .        .     .        . (2,i) : arete construite sur le noeud      .
c .        .     .        . (3,i) : noeud cree cote min(fammed)        .
c .        .     .        . (4,i) : noeud cree cote max(fammed)        .
c .        .     .        . (5,i) : numero du joint simple cree        .
c .        .     .        . (6,i) : arete entrant dans le cote 1       .
c .        .     .        . (7,i) : arete entrant dans le cote 2       .
c .        .     .        . (8,i) : ordre de multiplicite              .
c . tbau40 . es  .6*nbduar. Pour la i-eme duplication d'arete :        .
c .        .     .        . (1,i) : arete a dupliquer                  .
c .        .     .        . (2,i) : arete creee cote min(fammed)       .
c .        .     .        . (3,i) : arete creee cote max(fammed)       .
c .        .     .        . (4,i) : numero du joint simple cree        .
c .        .     .        . (5,i) : ordre de multiplicite              .
c .        .     .        . (6,i) : arete d'orientation de joint       .
c . nbduno . e   .   1    . nombre de duplication de noeuds            .
c . nbduar . e   .   1    . nombre de duplications d'aretes            .
c . nbtrtn . e   .   1    . nouveau nombre total de triangles          .
c . nbqutn . e   .   1    . nouveau nombre total de quadrangles        .
c . tbau31 .  s  .   2**  . Les triangles puis les quadrangles         .
c .        .     .        . construits sur un noeud multiple :         .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : numero du joint multiple cree      .
c . tbau41 .  s  .   4**  . Les pentaedres de joint triple, puis les   .
c .        .     .        . hexaedres de joint quadruple :             .
c .        .     .        . (1,i) : arete multiple                     .
c .        .     .        . (2,i) : numero du joint                    .
c .        .     .        . Pour le i-eme pentaedre de joint triple :  .
c .        .     .        . (3,i) : triangle cree cote 1er sommet      .
c .        .     .        . (4,i) : triangle cree cote 2nd sommet      .
c .        .     .        . Pour le i-eme hexaedre de joint quadruple :.
c .        .     .        . (3,i) : quadrangle cree cote 1er sommet    .
c .        .     .        . (4,i) : quadrangle cree cote 2nd sommet    .
c . tbau51 .  s  .   9**  . Les tetraedres ponctuels entre les joints  .
c .        .     .        . triples (ordre 6) :                        .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : triangle cote du 1er joint triple  .
c .        .     .        . (3,i) : triangle cote du 2eme joint triple .
c .        .     .        . (4,i) : triangle cote du 3eme joint triple .
c .        .     .        . (5,i) : triangle cote du 4eme joint triple .
c .        .     .        . (1+k) : pour le k-eme triangle, 1 s'il     .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . tbau52 .  s  .  11**  . Les pentaedres ponctuels entre les joints  .
c .        .     .        . triples et quadruples (ordre 9) :          .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : triangle cote du 1er joint triple  .
c .        .     .        . (3,i) : triangle cote du 2eme joint triple .
c .        .     .        . (4,i) : quadrangle cote du 1er joint quad. .
c .        .     .        . (5,i) : quadrangle cote du 2eme joint quad..
c .        .     .        . (6,i) : quadrangle cote du 3eme joint quad..
c .        .     .        . (1+k) : pour la k-eme face, 1 si elle      .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . tbau53 .  s  .  13**  . Les hexaedres ponctuels entre les joints   .
c .        .     .        . quadruples (ordre 12) :                    .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : quadrangle cote du 1er joint quad. .
c .        .     .        . (3,i) : quadrangle cote du 2eme joint quad..
c .        .     .        . (4,i) : quadrangle cote du 3eme joint quad..
c .        .     .        . (5,i) : quadrangle cote du 4eme joint quad..
c .        .     .        . (6,i) : quadrangle cote du 5eme joint quad..
c .        .     .        . (7,i) : quadrangle cote du 6eme joint quad..
c .        .     .        . (1+k) : pour le k-eme quadrangle, 1 s'il   .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . nbjoit .  s  .   1    . nombre de joints triples                   .
c . nbpejt .  s  .   1    . nombre de pentaedres de joints triples     .
c . nbtrjt .  s  .   1    . nombre de triangles de joints triples      .
c . nbjoiq .  s  .   1    . nombre de joints quadruples                .
c . nbhejq .  s  .   1    . nombre d'hexaedres de joints quadruples    .
c . nbqujq .  s  .   1    . nombre de quad. crees pour j. quadruples   .
c . nbjp06 .  s  .   1    . nombre de joints ponctuels ordre 6         .
c . nbte06 .  s  .   1    . nombre de tetr. des j. ponctuels d'ordre 6 .
c . nbjp09 .  s  .   1    . nombre de joints ponctuels ordre 9         .
c . nbpe09 .  s  .   1    . nombre de pent. des j. ponctuels d'ordre 9 .
c . nbjp12 .  s  .   1    . nombre de joints ponctuels ordre 12        .
c . nbhe12 .  s  .   1    . nombre de hexa. des j. ponctuels d'ordre 12.
c . tbaux5 . --- .   4**  . Pour la i-eme duplication d'arete :        .
c .        .     .        . (1,i), (2,i), (3,i), (4,i)                 .
c .        .     .        . numeros ordonnes des joints simples crees  .
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
      parameter ( nompro = 'MMAG13' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer muarmx, multax, multnx
      integer nbarmu(muarmx)
c
      integer somare(2,nbarto)
      integer nbjois
      integer nbduno, nbduar, nbtrtn, nbqutn
      integer tbaux2(4,*)
      integer tbau30(8,nbduno), tbau40(6,nbduar)
      integer tbau31(2,*), tbau41(4,*)
      integer tbau51(9,*), tbau52(11,*), tbau53(13,*)
      integer tbaux5(4,nbduar)
c
      integer nbtrjt, nbqujq
      integer nbjoit, nbpejt
      integer nbjoiq, nbhejq
      integer nbjp06, nbte06
      integer nbjp09, nbpe09
      integer nbjp12, nbhe12
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer jdeb, kdeb
      integer lequad, letria, larete
      integer lenoeu
      integer nujoin
c
      integer nbmess
      parameter ( nbmess = 40 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. prealables
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
#include "mmag01.h"
#include "impr03.h"
c
      texte(1,31) = '(''Ordre de multiplicite :'',i2)'
      texte(1,32) = '(''Nombre estime de '',a,'':'',i6)'
      texte(1,33) = '(''Nombre reel de '',a,''  :'',i6)'
      texte(1,34) = '(''Creation du joint :'',i6)'
c
      texte(2,31) = '(''Ordre of multiplicity :'',i2)'
      texte(2,32) = '(''Estimate number of '',a,'':'',i6)'
      texte(2,33) = '(''Real number of '',a,''    :'',i6)'
      texte(2,34) = '(''Creation of junction #'',i6)'
c
c 1.2. ==> Constantes
c
      codret = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), nbduno
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbduar
#endif
c
      nbtrjt = 0
      nbjoit = 0
      nbpejt = 0
c
      nbqujq = 0
      nbjoiq = 0
      nbhejq = 0
c
      nbjp06 = 0
      nbte06 = 0
c
      nbjp09 = 0
      nbpe09 = 0
c
      nbjp12 = 0
      nbhe12 = 0
c
cgn      write(ulsort,90002) 'tbaux2',4,nbjois
cgn      do 1101 , kaux = 1,nbjois
cgn       write(ulsort,90010) (tbaux2(jaux,kaux),jaux=1,4)
cgn 1101 continue
cgn      write(ulsort,90002) 'tbau30',8,nbduno
cgn      do 1102 , kaux = 1,nbduno
cgn       write(ulsort,90010) (tbau30(jaux,kaux),jaux=1,8)
cgn 1102 continue
cgn      write(ulsort,90002) 'tbau40',5,nbduar
cgn      do 1102 , kaux = 1,nbduar
cgn       write(ulsort,90010) (tbau40(jaux,kaux),jaux=1,6)
cgn 1102 continue
cgn      write(ulsort,90002) 'tbau41',4,5
cgn      do 1103 , kaux = 1,5
cgn       write(ulsort,90010) (tbau41(jaux,kaux),jaux=1,4)
cgn 1103 continue
c
c====
c 2. Caracterisation des noeuds muliples
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Caract noeuds multiples ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( multnx.ge.6 ) then
c
        do 21 , iaux = 1 , nbduno
cgn      write (ulsort,90002) 'Ordre', tbau30(8,iaux)
c
c 2.1. ==> Les noeuds d'ordre 6
c          Ils sont a la jonction de 4 joints triples.
c          Ils formeront un joint ponctuel forme d'un tetraedre.
c
          if ( tbau30(8,iaux).eq.6 ) then
c
            lenoeu = tbau30(1,iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,-1), lenoeu
#endif
c          On recherche dans les tetraedres deja crees si on en a
c          un qui est base sur le meme noeud multiple. Si oui,
c          on ne recommence pas !
c
            do 211 , jaux = 1 , nbjp06
c
              if ( tbau51(1,jaux).eq.lenoeu ) then
                goto 21
              endif
c
  211       continue
c
c         Il faut noter un nouveau joint ponctuel
c
            nbjp06 = nbjp06 + 1
            tbau51(1,nbjp06) = lenoeu
            tbau51(2,nbjp06) = 0
            tbau51(3,nbjp06) = 0
            tbau51(4,nbjp06) = 0
            tbau51(5,nbjp06) = 0
c
c 2.2. ==> Les noeuds d'ordre 9
c          Ils sont a la jonction de 2 joints triples et de 3 joints
c          quadruples.
c          Ils formeront un joint ponctuel forme d'un pentaedre.
c
          elseif ( tbau30(8,iaux).eq.9 ) then
c
            lenoeu = tbau30(1,iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,-1), lenoeu
#endif
c          On recherche dans les pentaedres deja crees si on en a
c          un qui est base sur le meme noeud multiple. Si oui,
c          on ne recommence pas !
c
            do 221 , jaux = 1 , nbjp09
c
              if ( tbau52(1,jaux).eq.lenoeu ) then
                goto 21
              endif
c
  221       continue
c
c         Il faut noter un nouveau joint ponctuel
c
            nbjp09 = nbjp09 + 1
            tbau52(1,nbjp09) = lenoeu
            tbau52(2,nbjp09) = 0
            tbau52(3,nbjp09) = 0
            tbau52(4,nbjp09) = 0
            tbau52(5,nbjp09) = 0
            tbau52(6,nbjp09) = 0
cgn      write (ulsort,texte(langue,34)) nbjp09
cgn      write (ulsort,texte(langue,20))(tbau52(jaux,nbjp09),jaux=1,1)
c
c 2.3. ==> Les noeuds d'ordre 12
c          Ils sont a la jonction de 6 joints quadruples.
c          Ils formeront un joint ponctuel forme d'un hexaedre.
c
          elseif ( tbau30(8,iaux).eq.12 ) then
c
            lenoeu = tbau30(1,iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,-1), lenoeu
#endif
c          On recherche dans les hexaedres deja crees si on en a
c          un qui est base sur le meme noeud multiple. Si oui,
c          on ne recommence pas !
c
            do 231 , jaux = 1 , nbjp12
c
              if ( tbau53(1,jaux).eq.lenoeu ) then
                goto 21
              endif
c
  231       continue
c
c         Il faut noter un nouveau joint ponctuel
c
            nbjp12 = nbjp12 + 1
            tbau53(1,nbjp12) = lenoeu
            do 232 , jaux = 2 , 13
              tbau53(jaux,nbjp12) = 0
  232       continue
cgn      write (ulsort,texte(langue,34)) nbjp12
cgn      write (ulsort,texte(langue,20))(tbau53(jaux,nbjp12),jaux=1,1)
c
          endif
c
   21   continue
c
      nbte06 = nbjp06
      nbpe09 = nbjp09
      nbhe12 = nbjp12
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,21))  6, nbjp06
      write (ulsort,texte(langue,21))  9, nbjp09
      write (ulsort,texte(langue,21)) 12, nbjp12
#endif
c
      endif
c
c====
c 3. Caracterisation des aretes triples
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Caract aretes triples ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( multax.ge.3 ) then
c
        do 3 , iaux = 1 , nbduar
c
          larete = tbau40(1,iaux)
c
          if ( tbau40(5,iaux).eq.3 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
#endif
c
c 3.1. ==> On recherche dans les pentaedres deja crees si on en a
c          un qui est base sur la meme arete triple. Si oui,
c          on ne recommence pas !
c
            do 31 , jaux = 1 , nbpejt
c
              if ( tbau41(1,jaux).eq.larete ) then
                goto 3
              endif
c
   31       continue
c
c 3.2. ==> On doit donc creer un nouveau pentaedre.
c          On recherche dans les joints triples deja crees si on
c          en a un qui est base sur les memes joints simples. Si oui,
c          on en deduit le numero de joint triple a associer.
c
            do 32 , jaux = nbjois+1 , nbjois+nbjoit
c
              if ( tbaux5(1,iaux).eq.tbaux2(1,jaux) .and.
     >             tbaux5(2,iaux).eq.tbaux2(2,jaux) .and.
     >             tbaux5(3,iaux).eq.tbaux2(3,jaux) ) then
c
                nujoin = jaux
                goto 320
c
              endif
c
   32       continue
c
c         Il faut creer un nouveau joint
c
            nbjoit = nbjoit + 1
            nujoin = nbjois + nbjoit
            tbaux2(1,nujoin) = tbaux5(1,iaux)
            tbaux2(2,nujoin) = tbaux5(2,iaux)
            tbaux2(3,nujoin) = tbaux5(3,iaux)
cgn      write (ulsort,texte(langue,34)) nbjoit
cgn      write (ulsort,texte(langue,20))(tbaux2(jaux,nujoin),jaux=1,3)
c
  320       continue
c
c
c 3.3. ==> Pour ce pentaedre :
c          1 : son arete directrice est la courante
c          2 : le joint associe
c
            nbpejt = nbpejt + 1
c
            tbau41(1,nbpejt) = larete
            tbau41(2,nbpejt) = nujoin
c
c           Creations/Recuperation des 2 triangles associes
c
            do 33 , jaux = 1 , 2
c
              lenoeu = somare(jaux,larete)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '. ', mess14(langue,1,-1), lenoeu
#endif
c
              do 331 , kaux = 1 , nbtrjt
                if ( tbau31(1,kaux).eq.lenoeu .and.
     >               tbau31(2,kaux).eq.nujoin ) then
                  letria = kaux
                  goto 332
                endif
  331         continue
c
              nbtrjt = nbtrjt + 1
              tbau31(1,nbtrjt) = lenoeu
              tbau31(2,nbtrjt) = nujoin
              letria = nbtrjt
c
  332         continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '. ', mess14(langue,1,2), letria
#endif
c
              tbau41(2+jaux,nbpejt) = nbtrtn + letria
c
c             Reperage des eventuels joints ponctuels
c
              do 333 , kaux = 1 , nbjp06
c
                if ( tbau51(1,kaux).eq.lenoeu ) then
                  do 3331 , laux = 2 , 5
                    if ( tbau51(laux,kaux).eq.nbtrtn+letria ) then
                      goto 33
                    elseif ( tbau51(laux,kaux).eq.0 ) then
                      tbau51(laux,kaux) = nbtrtn+letria
                      goto 33
                    endif
 3331             continue
                endif
c
  333         continue
c
              do 334 , kaux = 1 , nbjp09
c
                if ( tbau52(1,kaux).eq.lenoeu ) then
                  do 3341 , laux = 2 , 3
                    if ( tbau52(laux,kaux).eq.nbtrtn+letria ) then
                      goto 33
                    elseif ( tbau52(laux,kaux).eq.0 ) then
                      tbau52(laux,kaux) = nbtrtn+letria
                      goto 33
                    endif
 3341             continue
                endif
c
  334         continue
c
   33       continue
c
          endif
c
    3   continue
c
      endif
c
      endif
c
c====
c 4. Caracterisation des aretes quadruples
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Caract aretes quadruples ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( multax.ge.4 ) then
c
        jdeb = nbjois + nbjoit
        kdeb = nbtrjt
c
        do 4 , iaux = 1 , nbduar
c
          larete = tbau40(1,iaux)
c
          if ( tbau40(5,iaux).eq.4 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
#endif
c
c 4.1. ==> On recherche dans les hexaedres deja crees si on en a
c          un qui est base sur la meme arete quadruple. Si oui,
c          on ne recommence pas !
c
            do 41 , jaux = 1 , nbhejq
c
              if ( tbau41(1,nbpejt+jaux).eq.larete ) then
                goto 4
              endif
c
   41       continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
#endif
c
c 4.2. ==> On doit donc creer un nouvel hexaedre.
c          On recherche dans les joints quadruples deja crees si on
c          en a un qui est base sur les memes joints simples. Si oui,
c          on en deduit le numero de joint quadruple a associer.
c
            do 42 , jaux = jdeb+1 , jdeb+nbjoiq
c
              if ( tbaux5(1,iaux).eq.tbaux2(1,jaux) .and.
     >             tbaux5(2,iaux).eq.tbaux2(2,jaux) .and.
     >             tbaux5(3,iaux).eq.tbaux2(3,jaux) .and.
     >             tbaux5(4,iaux).eq.tbaux2(4,jaux) ) then
c
                nujoin = jaux
                goto 420
c
              endif
c
   42       continue
c
c         Il faut creer un nouveau joint
c
            nbjoiq = nbjoiq + 1
            nujoin = jdeb + nbjoiq
            tbaux2(1,nujoin) = tbaux5(1,iaux)
            tbaux2(2,nujoin) = tbaux5(2,iaux)
            tbaux2(3,nujoin) = tbaux5(3,iaux)
            tbaux2(4,nujoin) = tbaux5(4,iaux)
cgn      write (ulsort,texte(langue,34)) nbjoiq
cgn      write (ulsort,texte(langue,20))(tbaux2(jaux,nujoin),jaux=1,4)
c
  420       continue
c
c 4.3. ==> Pour cet hexaedre :
c          1 : son arete directrice est la courante
c          2 : le joint associe
c
            nbhejq = nbhejq + 1
c
            tbau41(1,nbpejt+nbhejq) = larete
            tbau41(2,nbpejt+nbhejq) = nujoin
c
c           Creations/Recuperation des 2 quadrangles associes
c
            do 43 , jaux = 1 , 2
c
              lenoeu = somare(jaux,larete)
c
              do 431 , kaux = kdeb+1 , kdeb+nbqujq
                if ( tbau31(1,kaux).eq.lenoeu .and.
     >               tbau31(2,kaux).eq.nujoin ) then
                  lequad = kaux - kdeb
                  goto 432
                endif
  431         continue
c
              nbqujq = nbqujq + 1
              tbau31(1,kdeb+nbqujq) = lenoeu
              tbau31(2,kdeb+nbqujq) = nujoin
              lequad = nbqujq
c
  432         continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '. ', mess14(langue,1,4), lequad
      write (ulsort,*) 'nbqujq =', nbqujq,', kaux =',kdeb+nbqujq
#endif
c
              tbau41(2+jaux,nbpejt+nbhejq) = nbqutn + lequad
c
c             Reperage des eventuels joints ponctuels
c
              do 433 , kaux = 1 , nbjp09
c
                if ( tbau52(1,kaux).eq.lenoeu ) then
                  do 4331 , laux = 4 , 6
                    if ( tbau52(laux,kaux).eq.nbqutn+lequad ) then
                      goto 43
                    elseif ( tbau52(laux,kaux).eq.0 ) then
                      tbau52(laux,kaux) = nbqutn+lequad
                      goto 43
                    endif
 4331             continue
                endif
c
  433         continue
c
c             Reperage des eventuels joints ponctuels
c
              do 434 , kaux = 1 , nbjp12
c
                if ( tbau53(1,kaux).eq.lenoeu ) then
                  do 4341 , laux = 2 , 7
                    if ( tbau53(laux,kaux).eq.0 ) then
                      tbau53(laux,kaux) = nbqutn+lequad
                      goto 43
                    endif
 4341             continue
                endif
c
  434         continue
c
   43       continue
c
          endif
c
    4   continue
c
      endif
c
      endif
c
c====
c 5. Controle
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Controle ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbpejt.ne.nbarmu(3) ) then
        write (ulsort,texte(langue,31)) 3
        write (ulsort,texte(langue,32)) mess14(langue,3,1), nbarmu(3)
        write (ulsort,texte(langue,33)) mess14(langue,3,1), nbpejt
        codret = 51
      endif
c
      if ( nbhejq.ne.nbarmu(4) ) then
        write (ulsort,texte(langue,31)) 4
        write (ulsort,texte(langue,32)) mess14(langue,3,1), nbarmu(4)
        write (ulsort,texte(langue,33)) mess14(langue,3,1), nbhejq
        codret = codret*100 + 52
      endif
c
      endif
c
cgn      write(ulsort,4001) 'tbaux2',4,nbjois+nbjoit+nbjoiq
cgn      do 4101 , kaux = 1,nbjois+nbjoit+nbjoiq
cgn       write(ulsort,4000) (tbaux2(jaux,kaux),jaux=1,4)
cgn 4101 continue
cgn      write(ulsort,4001) 'tbau41',4,nbpejt+nbhejq
cgn      do 4102 , kaux = 1,nbpejt+nbhejq
cgn       write(ulsort,4000) (tbau41(jaux,kaux),jaux=1,4)
cgn 4102 continue
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
