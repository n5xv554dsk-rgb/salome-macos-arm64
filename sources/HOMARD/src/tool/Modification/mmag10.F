      subroutine mmag10 ( somare,
     >                    aretri,
     >                    tritet, cotrte,
     >                    nbjois, nbpejs, tbaux1, tbaux2,
     >                    tbau30, tbau40,
     >                    tbau31, tbau41,
     >                    nbduno, nbduar, nbdutr,
     >                    nbnotn, nbartn, nbtrtn, nbqutn,
     >                    nbtetn, nbpetn, nbhetn,
     >                    nbjoit, nbpejt, nbtrjt,
     >                    nbjoiq, nbhejq, nbqujq,
     >                    nbjp06, nbte06,
     >                    nbjp09, nbpe09,
     >                    nbjp12, nbhe12,
     >                    nbvojm,
     >                    tbaux5,
     >                    ntra51, ptra51, ntra52, ptra52,
     >                    ntra53, ptra53,
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
c    Modification de Maillage - AGregat - phase 1.0
c    -               -          --              - -
c    Connaissant le nombre et les caracteristiques des pentaedres
c    a creer pour les joints simples :
c    . Decompte du nombre de noeuds, aretes, quadrangles a creer
c    . Decompte du nombre de joints multiples
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . nbjois . e   .   1    . nombre de joints simples                   .
c . nbpejs . e   .   1    . nombre de pentaedres de joints simples     .
c . tbaux1 . e   .4*nbpejs. Pour le i-eme pentaedre de joint simple :  .
c .        .     .        . (1,i) : numero du triangle a dupliquer     .
c .        .     .        . (2,i) : numero du joint simple cree        .
c .        .     .        . (3,i) : tetraedre du cote min(fammed)      .
c .        .     .        . (4,i) : tetraedre du cote max(fammed)      .
c . tbaux2 . es  .   4**  . Pour le i-eme joint :                      .
c .        .     .        . Numeros des familles MED des volumes       .
c .        .     .        . jouxtant le pentaedre/hexaedre, classes du .
c .        .     .        . plus petit (1,i) au plus grand             .
c .        .     .        . 0, si pas de volume voisin                 .
c . tbau30 .   s .   8**  . Pour la i-eme duplication de noeud :       .
c .        .     .        . (1,i) : noeud a dupliquer                  .
c .        .     .        . (2,i) : arete construite sur le noeud      .
c .        .     .        . (3,i) : noeud cree cote min(fammed)        .
c .        .     .        . (4,i) : noeud cree cote max(fammed)        .
c .        .     .        . (5,i) : numero du joint simple cree        .
c .        .     .        . (6,i) : arete entrant dans le cote 1       .
c .        .     .        . (7,i) : arete entrant dans le cote 2       .
c .        .     .        . (8,i) : ordre de multiplicite              .
c . tbau40 .   s .   6**  . Pour la i-eme duplication d'arete :        .
c .        .     .        . (1,i) : arete a dupliquer                  .
c .        .     .        . (2,i) : arete creee cote min(fammed)       .
c .        .     .        . (3,i) : arete creee cote max(fammed)       .
c .        .     .        . (4,i) : numero du joint simple cree        .
c .        .     .        . (5,i) : ordre de multiplicite              .
c .        .     .        . (6,i) : arete d'orientation de joint       .
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
c . nbduno .  s  .   1    . nombre de duplications de noeuds           .
c . nbduar .  s  .   1    . nombre de duplications d'aretes            .
c . nbdutr .  s  .   1    . nombre de duplications de triangles        .
c . nbnotn .  s  .   1    . nombre de noeuds total nouveau             .
c . nbartn .  s  .   1    . nombre d'aretes total nouveau              .
c . nbtrtn .  s  .   1    . nombre de triangles total nouveau          .
c . nbqutn .  s  .   1    . nombre de quadrangles total nouveau        .
c . nbtetn .  s  .   1    . nombre de tetraaedres total nouveau        .
c . nbpetn .  s  .   1    . nombre de pentaedres total nouveau         .
c . nbhetn .  s  .   1    . nombre d'hexaedres total nouveau           .
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
c . nbvojm .  s  .   1    . nombre de volumes de joints multiples      .
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
      parameter ( nompro = 'MMAG10' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "envex1.h"
#include "impr02.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
c
c 0.3. ==> arguments
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer nbjois, nbpejs
      integer tbaux1(4,nbpejs), tbaux2(4,*)
      integer tbau30(8,*), tbau40(6,*)
      integer tbau31(2,*), tbau41(4,*)
      integer tbaux5(4,*)
c
      integer nbduno, nbduar, nbdutr
      integer nbnotn, nbartn, nbtrtn, nbqutn
      integer nbtetn, nbpetn, nbhetn
      integer nbjoit, nbpejt, nbtrjt
      integer nbjoiq, nbhejq, nbqujq
      integer nbjp06, nbte06
      integer nbjp09, nbpe09
      integer nbjp12, nbhe12
      integer nbvojm
      integer ptra51, ptra52, ptra53
c
      character*8 ntra51, ntra52, ntra53
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre1, codre2, codre3
      integer codre0
c
      integer iaux, jaux
#ifdef _DEBUG_HOMARD_
      integer kaux
#endif
      integer indnoe, indare
      integer multax, multnx
c
      integer muarmx
      parameter ( muarmx = 4 )
      integer nbarmu(muarmx)
c
      integer munomx
      parameter ( munomx = 12 )
      integer nbnomu(munomx)
c
      integer nbmess
      parameter ( nbmess = 30 )
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) nbjois
      write (ulsort,texte(langue,7)) mess14(langue,3,7), nbpejs
#endif
c
c 1.2. ==> Constantes
c
      codret = 0
c
      nbduno = 0
      nbduar = 0
      indnoe = nbnoto
      indare = nbarto
      nbdutr = nbpejs
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,2), nbdutr
#endif
c
c====
c 2. Reperage des joints simples
c====
c
      if ( codret.eq.0 ) then
c
      call gtdems (62)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG11', nompro
#endif
      call mmag11 ( somare,
     >              aretri,
     >              tritet, cotrte,
     >              nbpejs, tbaux1, tbaux2,
     >              tbau30, tbau40,
     >              nbduno, nbduar, nbdutr,
     >              indnoe, indare,
     >              ulsort, langue, codret )
c
      call gtfims (62)
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,3,-1),indnoe-nbnoto
      write (ulsort,texte(langue,11)) mess14(langue,3,1), indare-nbarto
      write (ulsort,texte(langue,11)) mess14(langue,3,2), 2*nbdutr
      write (ulsort,texte(langue,11)) mess14(langue,3,4), nbduar
#endif
c
      nbnotn = indnoe
      nbartn = indare
      nbtrtn = nbtrto + 2*nbdutr
      nbqutn = nbduar
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) mess14(langue,3,-1), nbnotn
      write (ulsort,texte(langue,10)) mess14(langue,3,1), nbartn
      write (ulsort,texte(langue,10)) mess14(langue,3,2), nbtrtn
      write (ulsort,texte(langue,10)) mess14(langue,3,4), nbqutn
#endif
c
      endif
c
c====
c 3. Reperage des joints multiples
c====
c
      call gtdems (63)
c
c 3.1. ==> Recherche des aretes et des noeuds multiples
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG12', nompro
#endif
      call mmag12 ( muarmx, nbarmu, multax,
     >              munomx, nbnomu, multnx,
     >              nbduno, nbduar,
     >              tbau30, tbau40,
     >              tbaux5,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2. ==> Allocation
c
      if ( codret.eq.0 ) then
c
      jaux = 0
      do 32 , iaux = 4 , multnx
        jaux = jaux + nbnomu(iaux)
   32 continue
c
      iaux = (1+2*4)*nbnomu(6)
      call gmalot ( ntra51, 'entier  ', iaux, ptra51, codre1 )
c
      iaux = (1+2*5)*nbnomu(9)
      call gmalot ( ntra52, 'entier  ', iaux, ptra52, codre2 )
c
      iaux = (1+2*6)*nbnomu(12)
      call gmalot ( ntra53, 'entier  ', iaux, ptra53, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 3.3. ==> Creation des mailles a partir des aretes et noeuds multiples
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG13', nompro
#endif
      call mmag13 ( muarmx, nbarmu, multax, multnx,
     >              somare,
     >              nbjois, tbaux2,
     >              nbduno, nbduar, nbtrtn, nbqutn,
     >              tbau30, tbau40,
     >              tbau31, tbau41,
     >              imem(ptra51), imem(ptra52), imem(ptra53),
     >              nbjoit, nbpejt, nbtrjt,
     >              nbjoiq, nbhejq, nbqujq,
     >              nbjp06, nbte06,
     >              nbjp09, nbpe09,
     >              nbjp12, nbhe12,
     >              tbaux5,
     >              ulsort, langue, codret )
c
      endif
cgn              nbjp06=0
cgn              nbte06=0
c
      call gtfims (63)
c
c====
c 4. Messages
c====
c
c 4.1. ==> Nouvelles entites
c
      if ( codret.eq.0 ) then
c
      nbtrtn = nbtrtn + nbtrjt
      nbqutn = nbqutn + nbqujq
      nbtetn = nbteto + nbte06
      nbpetn = nbpejs + nbpejt + nbpe09
      nbhetn = nbhejq + nbhe12
c
      nbvojm = nbpejt + nbhejq
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) mess14(langue,3,2), nbtrtn
      write (ulsort,texte(langue,10)) mess14(langue,3,3), nbtetn
      write (ulsort,texte(langue,10)) mess14(langue,3,4), nbqutn
      write (ulsort,texte(langue,10)) mess14(langue,3,7), nbpetn
      write (ulsort,texte(langue,10)) mess14(langue,3,6), nbhetn
#endif
c
      endif
c
c 4.2. ==> Joints triples
c
      if ( nbjoit.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,13)) nbjoit
        write (ulsort,texte(langue,11)) mess14(langue,3,7), nbpejt
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,11)) mess14(langue,3,2), nbtrjt
#endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,1420)
        jaux = nbjois + 1
        kaux = nbjois + nbjoit
        do 42 , iaux = jaux, kaux
          write (ulsort,1421) iaux-nbjois,
     >    tbaux2(1,iaux), tbaux2(2,iaux), tbaux2(3,iaux)
   42   continue
        write (ulsort,1422)
c
 1420   format( /,5x,41('*'),
     >          /,5x,'* Joint t *',3(' Joint s *'),
     >          /,5x,41('*'))
 1421   format(4x,4(' *',i8),' *')
 1422   format(5x,41('*'),/)
#endif
c
        endif
c
      endif
c
c 4.3. ==> Joints quadruples
c
      if ( nbjoiq.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,14)) nbjoiq
        write (ulsort,texte(langue,11)) mess14(langue,3,6), nbhejq
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,11)) mess14(langue,3,4), nbqujq
#endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,1430)
        jaux = nbjois + nbjoit + 1
        kaux = nbjois + nbjoit + nbjoiq
        do 43 , iaux = jaux, kaux
          write (ulsort,1431) iaux-nbjois-nbjoit,
     >    tbaux2(1,iaux), tbaux2(2,iaux), tbaux2(3,iaux), tbaux2(4,iaux)
   43   continue
        write (ulsort,1432)
c
 1430   format( /,5x,51('*'),
     >          /,5x,'* Joint q *',4(' Joint s *'),
     >          /,5x,51('*'))
 1431   format(4x,5(' *',i8),' *')
 1432   format(5x,51('*'),/)
#endif
c
        endif
c
      endif
c
c 4.4. ==> Joints ponctuels
c
      if ( nbjp06.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,21)) 6, nbjp06
        write (ulsort,texte(langue,11)) mess14(langue,3,3), nbte06
c
        endif
c
      endif
c
      if ( nbjp09.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,21)) 9, nbjp09
        write (ulsort,texte(langue,11)) mess14(langue,3,7), nbpe09
c
        endif
c
      endif
c
      if ( nbjp12.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,21)) 12, nbjp12
        write (ulsort,texte(langue,11)) mess14(langue,3,6), nbhe12
c
        endif
c
      endif
cc
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
