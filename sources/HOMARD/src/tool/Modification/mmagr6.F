      subroutine mmagr6 ( nbduno, nbduar, nbdutr,
     >                    tbaux1, tbau30, tbau40,
     >                    tbaux2, tbaux5, tbaux6,
     >                    coonoe, famnoe,
     >                    somare, famare,
     >                    aretri, famtri, arequa,
     >                    tritet, facpen,
     >                    anctri, noutri,
     >                    ancare, nouare,
     >                    ancnoe, nounoe,
     >                    nbtrtn, nbartn, nbnotn,
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
c    Modification de Maillage - AGRegat - phase 6
c    -               -          ---             -
c    Suppression des noeuds, aretes et triangles dupliques
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbduno . e   .   1    . nombre de duplications de noeuds           .
c . nbduar . e   .   1    . nombre de duplications d'aretes            .
c . nbdutr . e   .   1    . nombre de duplications de triangles        .
c . tbaux1 . e   .4*nbpejs. Pour le i-eme pentaedre de joint simple :  .
c .        .     .        . (1,i) : numero du triangle a dupliquer     .
c .        .     .        . (2,i) : numero du joint simple cree        .
c .        .     .        . (3,i) : tetraedre du cote min(fammed)      .
c .        .     .        . (4,i) : tetraedre du cote max(fammed)      .
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
c . tbaux2 . --  . nbnoto . auxiliaire                                 .
c . tbaux5 . --  . nbarto . auxiliaire                                 .
c . tbaux6 . --  . nbtrto . auxiliaire                                 .
c . coonoe . es  .nbnoto*3. coordonnees des noeuds                     .
c . famnoe . es  . nbnoto . famille des noeuds                         .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . famare . es  . nbarto . famille des aretes                         .
c . aretri . es  .nbtrto*3. numeros des 3 aretes des triangles         .
c . famtri . es  . nbtrto . famille des triangles                      .
c . arequa . es  .nbquto*4. numeros des 4 aretes des quadrangle        .
c . tritet . e/s .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . facpen . e/s .nbpecf*5. numeros des 5 faces des pentaedres         .
c . nbnotn .  s  .   1    . nombre de noeuds total nouveau             .
c . nbartn .  s  .   1    . nombre d'aretes total nouveau              .
c . nbtrtn .  s  .   1    . nombre de triangles total nouveau          .
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
      parameter ( nompro = 'MMAGR6' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "coftex.h"
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbduno, nbduar, nbdutr
      integer tbaux1(4,nbdutr), tbau30(8,nbduno), tbau40(6,nbduar)
      integer tbaux2(nbnoto), tbaux5(nbarto), tbaux6(nbtrto)
      integer famnoe(nbnoto)
      integer somare(2,nbarto), famare(nbarto)
      integer aretri(nbtrto,3), famtri(nbtrto)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4)
      integer facpen(nbpecf,5)
      integer anctri(nbtrto), noutri(0:nbtrto)
      integer ancare(nbarto), nouare(0:nbarto)
      integer ancnoe(nbnoto), nounoe(0:nbnoto)
      integer nbtrtn, nbartn, nbnotn
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lepent, letetr, letria, lequad, larete
      integer lenoeu
      integer nbarmu, nbnomu
c
      integer nbmess
      parameter ( nbmess = 40 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
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
#include "mmag01.h"
c
      texte(1,31) = '(a,'' Traitement du '',a,i8,'', ordre'',i3)'
c
      texte(2,31) = '(a,'' Treatment of the '',a,i8,'', order'',i3)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), nbduno
      write (ulsort,texte(langue,8)) mess14(langue,3,1), nbduar
      write (ulsort,texte(langue,8)) mess14(langue,3,2), nbdutr
#endif
c
      codret = 0
c
c====
c 2. Reperages
c====
c 2.1. ==> Triangles
c
      do 211 , iaux = 1 , nbtrto
        tbaux6(iaux) = 0
  211 continue
c
      do 212 , iaux = 1 , nbdutr
        letria = tbaux1(1,iaux)
        tbaux6(letria) = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,31)) '.', mess14(langue,1,2),
     >                               letria, tbaux6(letria)
#endif
  212 continue
c
c 2.2. ==> Aretes
c
      do 221 , iaux = 1 , nbarto
        tbaux5(iaux) = 0
  221 continue
c
      nbarmu = 0
      do 222 , iaux = 1 , nbduar
        larete = tbau40(1,iaux)
        if ( tbaux5(larete).ge.1 ) then
          nbarmu = nbarmu + 1
cgn              write (ulsort,*)'LARETE',larete
        endif
        tbaux5(larete) = tbaux5(larete) + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,31)) '.', mess14(langue,1,1),
     >                               larete, tbaux5(larete)
#endif
  222 continue
c
c 2.3. ==> Noeuds
c
      do 231 , iaux = 1 , nbnoto
        tbaux2(iaux) = 0
  231 continue
c
      nbnomu = 0
      do 232 , iaux = 1 , nbduno
        lenoeu = tbau30(1,iaux)
        if ( tbaux2(lenoeu).ge.1 ) then
          nbnomu = nbnomu + 1
cgn              write (ulsort,*)'LENOEU',lenoeu
        endif
        tbaux2(lenoeu) = tbaux2(lenoeu) +1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,31)) '.', mess14(langue,1,-1),
     >                               lenoeu, tbaux2(lenoeu)
#endif
  232 continue
c
c====
c 3. suppression des entites
c====
c 3.1. ==> suppression des triangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3.1. suppression tria ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbtrtn = 0
      noutri(0) = 0
c
      do 31 , letria = 1 , nbtrto
c
        if ( tbaux6(letria).gt.0 ) then
c
          noutri(letria) = 0
c
        else
c
          nbtrtn = nbtrtn + 1
          anctri(nbtrtn) = letria
          noutri(letria) = nbtrtn
c
        endif
c
   31 continue
c
      if ( nbtrtn+nbdutr.ne.nbtrto ) then
        codret = 31
      endif
cgn      print*,nbtrtn,nbdutr,nbtrto
c
      endif
c
c 3.2. ==> suppression des aretes
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3.2. suppression aret ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbartn = 0
      nouare(0) = 0
c
      do 32 , larete = 1 , nbarto
c
        if ( tbaux5(larete).gt.0 ) then
c
          nouare(larete) = 0
c
        else
c
          nbartn = nbartn + 1
          ancare(nbartn) = larete
          nouare(larete) = nbartn
c
        endif
cgn        write (ulsort,*) larete,tbaux5(larete),nbartn
c
   32 continue
c
      if ( nbartn+nbduar-nbarmu.ne.nbarto ) then
        codret = 32
        write (ulsort,*) nbartn,nbduar,nbarmu,nbarto
      endif
cgn      write (ulsort,*) nbartn,nbduar,nbarmu,nbarto
c
      endif
c
c 3.3. ==> suppression des noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3.3. suppression noeuds ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbnotn = 0
      nounoe(0) = 0
c
      do 33 , lenoeu = 1 , nbnoto
c
        if ( tbaux2(lenoeu).gt.0 ) then
c
          nounoe(lenoeu) = 0
c
        else
c
          nbnotn = nbnotn + 1
          ancnoe(nbnotn) = lenoeu
          nounoe(lenoeu) = nbnotn
c
        endif
c
   33 continue
c
      if ( nbnotn+nbduno-nbnomu.ne.nbnoto ) then
        codret = 33
        write (ulsort,*) nbnotn,nbduno,nbnomu,nbnoto
      endif
cgn      write (ulsort,*) nbnotn,nbduno,nbnomu,nbnoto
c
      endif
c
c====
c 4. compactage des numerotations
c====
c 4.1. ==> compactage des triangles
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4.1 compactage tria ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 4.1.1. ==> Impact sur la definition des tetraedres
c
      do 411 , letetr = 1 , nbteto
c
        do 4111 , iaux = 1 , 4
          tritet(letetr,iaux) = noutri(tritet(letetr,iaux))
 4111   continue
c
  411 continue
c
c 4.1.2. ==> Impact sur la definition des pentaedres
c
      do 412 , lepent = 1 , nbpeto
c
        do 4121 , iaux = 1 , 2
          facpen(lepent,iaux) = noutri(facpen(lepent,iaux))
 4121   continue
c
  412 continue
c
c 4.1.3. ==> Dans les tableaux des triangles, on ne traite pas :
c            hettri : toujours = 0
c            mertri : toujours = 0
c            filtri : toujours = 0
c
      do 413 , letria = 1 , nbtrtn
c
        do 4131, iaux = 1 , 3
          aretri(letria,iaux) = aretri(anctri(letria),iaux)
 4131   continue
c
        famtri(letria) = famtri(anctri(letria))
c
  413 continue
c
      endif
c
c 4.2. ==> compactage des aretes
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4.2 compactage aret ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 4.2.1. ==> Impact sur la definition des triangles
c
      do 421 , letria = 1 , nbtrtn
c
cgn      write (ulsort,*) (nouare(aretri(letria,iaux)), iaux = 1 , 3)
        do 4211, iaux = 1 , 3
          aretri(letria,iaux) = nouare(aretri(letria,iaux))
 4211   continue
c
  421 continue
c
c 4.2.2. ==> Impact sur la definition des quadrangles
c
      do 422 , lequad = 1 , nbquto
c
cgn      write (ulsort,*) lequad,(arequa(lequad,iaux), iaux = 1,4)
cgn      write (ulsort,*) lequad,(nouare(arequa(lequad,iaux)), iaux = 1,4)
        do 4221, iaux = 1 , 4
          arequa(lequad,iaux) = nouare(arequa(lequad,iaux))
 4221   continue
c
  422 continue
c
c 4.2.3. ==> Dans les tableaux des aretes, on ne traite pas :
c            hetare : toujours = 0
c            merare : toujours = 0
c            filare : toujours = 0
c
      do 423 , larete = 1 , nbartn
c
cgn      write (ulsort,*) larete
cgn      write (ulsort,*) ancare(larete)
        somare(1,larete) = somare(1,ancare(larete))
        somare(2,larete) = somare(2,ancare(larete))
c
        famare(larete) = famare(ancare(larete))
c
  423 continue
c
      endif
c
c 4.3 ==> compactage des noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4.3. compactage noeuds ; codret =', codret
#endif
c
c 4.3.1. ==> Impact sur la definition des aretes
c
      if ( codret.eq.0 ) then
c
      do 431 , larete = 1 , nbartn
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
#endif
        iaux = nounoe(somare(1,larete))
        jaux = nounoe(somare(2,larete))
        somare(1,larete) = min(iaux,jaux)
        somare(2,larete) = max(iaux,jaux)
c
  431 continue
c
c 4.3.2. ==> Dans les tableaux des noeuds, on ne traite pas :
c            hetnoe : toujours = 1
c            arenoe : toujours = 0
c
      do 432 , lenoeu = 1 , nbnotn
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,-1), lenoeu
#endif
c
        if ( ancnoe(lenoeu).ne.lenoeu ) then
c
          do 4321, iaux = 1 , sdim
            coonoe(lenoeu,iaux) = coonoe(ancnoe(lenoeu),iaux)
 4321     continue
c
        famnoe(lenoeu) = famnoe(ancnoe(lenoeu))
c
        endif
c
  432 continue
c
      endif
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
