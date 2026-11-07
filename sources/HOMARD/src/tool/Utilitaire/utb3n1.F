      subroutine utb3n1 ( coonoe,
     >                    nbintx, nbbomx,
     >                    lglibo, ptnubo,
     >                    xyzmin, xyzmax, xyzeps,
     >                    nbboit, boimin, boimax,
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
c    UTilitaire - Bilan - option 3 - phase N1
c    --           -              -         --
c ______________________________________________________________________
c
c Repartit les noeuds dans les boites
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . nbintx . e   .    1   . nombre maximal d'intervalle                .
c . nbbomx . e   .    1   . nombre maximal de boites                   .
c . lglibo .  s  .   1    . longueur de listbo                         .
c . ptnubo .  s  .0:nbbomx. pointeur dans listbo                       .
c . xyzmin . e   .  sdim  . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) minimales du domaine total      .
c . xyzmax . e   .  sdim  . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) maximales du domaine total      .
c . xyzeps . e   .  sdim  . -1 si min = max dans la direction,         .
c .        .     .        . ecart sinon.                               .
c . nbboit .  s  .  sdim  . nombre de boite dans chaque direction      .
c . boimin .  s  .0:nbintx. limite minimale de chaque boite            .
c . boimax .  s  .0:nbintx. limite maximale de chaque boite            .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB3N1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "envca1.h"
#include "infini.h"
c
c 0.3. ==> arguments
c
      integer nbintx, nbbomx
      integer lglibo
      integer ptnubo(0:nbbomx)
      integer nbboit(3)
c
      double precision coonoe(nbnoto,sdim)
      double precision xyzmin(sdim), xyzmax(sdim), xyzeps(sdim)
      double precision boimin(3,0:nbintx), boimax(3,0:nbintx)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer tbiaux(3)
      integer lgboin, boinoe(8)
      integer lenoeu, noedeb
      integer nbinte(3)
c
      double precision daux, daux1
      double precision coord(3)
c
      character*1 nomcoo(3)
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data nomcoo / 'x', 'y', 'z' /
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de noeuds     : '',i10)'
      texte(1,5) = '(''Dimension de l''''espace : '',i8)'
      texte(1,6) =
     > '(''Direction '',a1,'' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(1,7) = '(''Ecart maxi = '',g12.5)'
      texte(1,8) = '(''Nombre de boites en '',a1,'' : '',i10)'
      texte(1,9) = '(''. Boite'',i4,'' : '',g14.7,'' < '',g14.7)'
      texte(1,10) = '(''Nombre total de boites : '',i10)'
      texte(1,10) = '(''Longueur des listes des boites : '',i10)'
c
      texte(2,4) = '(''Number of nodes       : '',i10)'
      texte(2,5) = '(''Dimension of the space: '',i8)'
      texte(2,6) =
     > '(a1,''direction '','' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(2,7) = '(''Maximum shift = '',g12.5)'
      texte(2,8) = '(''Number of box for '',a1,'' : '',i10)'
      texte(2,9) = '(''. Box #'',i4,'' : '',g14.7,'' < '',g14.7)'
      texte(2,10) = '(''Total number of boxes : '',i10)'
      texte(2,10) = '(''Length of box lists : '',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbnoto
      write (ulsort,texte(langue,5)) sdim
      do 11 , iaux = 1 , sdim
        write (ulsort,texte(langue,6)) nomcoo(iaux),
     >                                 xyzmin(iaux), xyzmax(iaux)
   11 continue
ccc      write (ulsort,*) xyzeps
#endif
c
c 1.2. ==> constantes
c
      codret = 0
c
c====
c 2. limites des boites
c====
c 2.1. ==> daux = ecart le plus grand entre mini et maxi
c
      daux = 0.d0
      do 21 , iaux = 1 , sdim
        if ( xyzmax(iaux)-xyzmin(iaux).ge.daux ) then
          daux = xyzmax(iaux)-xyzmin(iaux)
          tbiaux(iaux) = 1
        else
          tbiaux(iaux) = 0
        endif
cgn        write (ulsort,*) xyzmax(iaux)-xyzmin(iaux), daux
cgn        write (ulsort,*) tbiaux(iaux)
   21 continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) daux
#endif
c
c 2.2. ==> taille des boites egale au plus grand ecart divise par
c          le nombre maximal d'intervalle
c          la taille est la meme quelle que soit la direction
c          . si l'epaisseur est nulle, il faut declarer au moins
c            une boite ; cela arrive dans le cas de maillage 1D
c            sur un axe de coordonnees
c          . quand on est sur une dimension maximale, le nombre de
c            boites est maximal
c
      daux = daux/dble(nbintx)
      do 22 , iaux = 1 , sdim
        if ( xyzeps(iaux).le.zeroma ) then
          nbboit(iaux) = 1
        elseif ( tbiaux(iaux).eq.1 ) then
          nbboit(iaux) = nbintx
        else
          daux1 = (xyzmax(iaux)-xyzmin(iaux))/daux
          jaux = int(daux1)
          daux1 = daux1-dble(jaux)
          if ( daux1.gt.zeroma) then
            jaux = jaux+1
          endif
          nbboit(iaux) = jaux
        endif
        nbinte(iaux) = nbboit(iaux) - 1
   22 continue
c
c 2.3. ==> limite des boites : on elargit chaque boite pour
c                              ne rien rater
c
      daux1 = 1.d-5*daux
      do 23 , iaux = 1 , sdim
        do 232 , jaux = 1 , nbboit(iaux)
          boimin(iaux,jaux) =
     >           xyzmin(iaux) + daux*dble(jaux-1) - daux1
          boimax(iaux,jaux) =
     >           xyzmin(iaux) + daux*dble(jaux) + daux1
  232   continue
        boimin(iaux,1)            = xyzmin(iaux) - daux1
        boimax(iaux,nbboit(iaux)) = xyzmax(iaux) + daux1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,8)) nomcoo(iaux), nbboit(iaux)
        do 2321 , jaux = 1, nbboit(iaux)
          write (ulsort,texte(langue,9)) jaux,
     >           boimin(iaux,jaux), boimax(iaux,jaux)
 2321   continue
#endif
   23 continue
c
c====
c 3. Elaboration du contenu des boites
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Elaboration ; codret', codret
#endif
c 3.0. ==> On controle tous les noeuds, sauf dans un cas : si le code
c          de calcul associe est Saturne_2D ou Neptune_2D, le maillage
c          est une couche 2D du maillage 3D. Dans ce cas, un noeud
c          supplementaire a ete cree pour memoriser les cotes mini
c          et maxi du maillage. Ce noeud etant isole se trouve en
c          premiere position. Il doit etre retire du controle car il
c          n'a pas de sens du point de vue du maillage.
c         A la fin de cette etape, ptnubo contient pour chaque boite
c         le nombre de noeuds qu'elle contient
c
      if ( typcca.eq.26 .or.
     >     typcca.eq.46 ) then
        noedeb = 2
      else
        noedeb = 1
      endif
c
      do 30 , iaux = 0 , nbbomx
        ptnubo(iaux) = 0
   30 continue
c
c 3.1. ==> en dimension 1
c
      if ( sdim.eq.1 ) then
c
        do 31 , lenoeu = noedeb , nbnoto
cgn      write (ulsort,*) lenoeu,(coonoe(lenoeu,iaux) , iaux = 1 , sdim)
c
          coord(1) = coonoe(lenoeu,1)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3N5', nompro
#endif
          call utb3n5 ( lgboin, boinoe,
     >                  coord,
     >                  nbboit, nbinte,
     >                  boimin, boimax )
c
cgn      write (ulsort,*) 'boinoe', (boinoe(iaux),iaux = 1 , lgboin)
cgn      write (ulsort,*) 'lgboin', lgboin
          do 311 , iaux = 1 , lgboin
            ptnubo(boinoe(iaux)) = ptnubo(boinoe(iaux)) + 1
  311     continue
c
   31   continue
cgn      write (ulsort,*) 'ptnubo', (ptnubo(iaux),iaux=1,nbbomx)
c
c 3.2. ==> en dimension 2
c
      elseif ( sdim.eq.2 ) then
c
        do 32 , lenoeu = noedeb , nbnoto
cgn      write (ulsort,*) lenoeu,(coonoe(lenoeu,iaux) , iaux = 1 , sdim)
c
          coord(1) = coonoe(lenoeu,1)
          coord(2) = coonoe(lenoeu,2)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3N4', nompro
#endif
          call utb3n4 ( lgboin, boinoe,
     >                  coord,
     >                  nbboit, nbinte,
     >                  boimin, boimax )
c
cgn      write (ulsort,90002) 'boinoe', (boinoe(iaux),iaux =1,lgboin)
cgn      write (ulsort,90002) 'lgboin', lgboin
          do 321 , iaux = 1 , lgboin
            ptnubo(boinoe(iaux)) = ptnubo(boinoe(iaux)) + 1
  321     continue
c
   32   continue
cgn      write (ulsort,*) 'ptnubo', (ptnubo(iaux),iaux=1,nbbomx)
c
c 3.3. ==> en dimension 3
c
      else
c
        do 33 , lenoeu = noedeb , nbnoto
cgn      write (ulsort,90024) 'noeud', lenoeu,
cgn     >                     (coonoe(lenoeu,iaux),iaux=1,sdim)
c
          coord(1) = coonoe(lenoeu,1)
          coord(2) = coonoe(lenoeu,2)
          coord(3) = coonoe(lenoeu,3)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3N3', nompro
#endif
          call utb3n3 ( lgboin, boinoe,
     >                  coord,
     >                  nbboit, nbinte,
     >                  boimin, boimax )
c
          do 331 , iaux = 1 , lgboin
            ptnubo(boinoe(iaux)) = ptnubo(boinoe(iaux)) + 1
  331     continue
c
   33   continue
c
      endif
c
c====
c 4. On initialise le pointeur dans le tableau de la liste
c    ptnubo(i) = position du dernier noeud de la boite i-1
c              = nombre cumule de noeuds pour les (i-1) premieres boites
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. On initialise ; codret', codret
      write (ulsort,*) 'ptnubo', (ptnubo(iaux),iaux=1,nbbomx)
#endif
c
      do 41 , iaux = 1 , nbbomx
        ptnubo(iaux) = ptnubo(iaux) + ptnubo(iaux-1)
   41 continue
c
      lglibo = ptnubo(nbbomx)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) lglibo
#endif
c
      do 42 , iaux = nbbomx , 1 , -1
        ptnubo(iaux) = ptnubo(iaux-1)
   42 continue
cgn      write (ulsort,*) 'ptnubo', (ptnubo(iaux),iaux=1,nbbomx)
c
c====
c 5. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
#endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
