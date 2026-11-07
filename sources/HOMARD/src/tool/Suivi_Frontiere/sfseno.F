      subroutine sfseno ( cono, numlig, unst2x, epsid2,
     >                    seglig, somseg, geocoo, abscur,
     >                    seg, acnoeu )
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
c   Suivi de Frontiere - SEgment - NOeud
c   -        -           --        --
c ______________________________________________________________________
c
c but : recherche du segment de la ligne auquel appartient le noeud
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . cono   . es  .  sdim  . coordonnees du noeud                       .
c . numlig . e   .   1    . numero de ligne sur laquelle on cherche    .
c . unst2x . e   .   1    . inverse de la taille maximale au carre     .
c . epsid2 . e   .   1    . precision relative pour carre de distance  .
c . seglig . e   .0:sfnbli. pointeur dans le tableau somseg : les      .
c .        .     .        . segments de la ligne i sont aux places de  .
c .        .     .        . seglig(i-1)+1 a seglig(i)-1 inclus         .
c . somseg . e   . sfnbse . liste des sommets des lignes separees par  .
c                           des 0                                      .
c . geocoo . e   .sfnbso**. coordonnees des sommets de la frontiere    .
c . seg    .  s  .   1    . numero de segment trouve                   .
c                           - : noeud sur extremite de ligne           .
c                           + : noeud hors extremites                  .
c . acnoeu .  s  .   1    . abscisse curviligne du noeud sur la ligne  .
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
c 0.2. ==> communs
c
#include "front1.h"
#include "infini.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      double precision unst2x, epsid2
      double precision geocoo(sfnbso,*), cono(sdim)
      integer seglig(0:sfnbli), somseg(sfnbse)
      integer numlig, seg
      double precision acnoeu
      double precision abscur(sfnbse)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer seg1, seg2, segmin
c
      double precision cooa(3), coob(3)
      double precision daux, daux1, daux2
c
#ifdef _DEBUG_HOMARD_
      integer ulsort
      parameter (ulsort=1)
      integer glop
      common / tutu / glop
#endif
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
#include "impr03.h"
c
c====
c 1. initialisation
c====
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
      write(ulsort,*) 'Entree dans SFSENO'
      write(ulsort,90004) 'unst2x',unst2x
      write(ulsort,90004) 'epsid2',epsid2
      write(ulsort,90004) 'cono', (cono(iaux),iaux = 1 , sdim)
      write(ulsort,90002) 'numlig', numlig
      endif
#endif
c
c 1.1. ==> segment pas encore trouve
c
      seg = 0
c
c 1.2. ==> bornes de la ligne dans la numerotation des segments
c
      seg1 = seglig(numlig-1) + 1
      seg2 = seglig(numlig  ) - 2
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
      write(ulsort,90006) 'Pointeurs seglig pour la ligne', numlig,
     >' de',seg1,' a ',seg2+2
      write(ulsort,90002) '==> Segments extremites',seg1,seg2
      write(ulsort,90002) '==> Sommets extremites ',
     >                    somseg(seg1),somseg(seg2+1)
        endif
#endif
c
c====
c 2. Le noeud est-il une extremite de la ligne ?
c    Remarque : on commence par la fin de la ligne pour pouvoir
c               initialiser correctement l'etape suivante en cas de
c               non coincidence
c    Remarque : comme ce sont les coordonnees du debut du segment qui
c               sont stockees, il faut examiner le segment fictif
c               (dernier+1) pour trouver les coordonnees de sa fin
c====
c
      do 20 , jaux = 1 , 2
c
        if ( jaux.eq.1 ) then
          kaux = seg2+1
        else
          kaux = seg1
        endif
c
        daux = 0.d0
        do 21 , iaux = 1 , sdim
          coob(iaux) = geocoo(somseg(kaux),iaux)
          daux = daux + (coob(iaux)-cono(iaux))**2
   21   continue
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
        if ( jaux.eq.1 ) then
          write(ulsort,90002) 'segment (jaux=1)', seg2
        else
          write(ulsort,90002) 'segment (jaux=2)', seg1
        endif
        write(ulsort,90024) 'Noeud', somseg(kaux),
     >  (geocoo(somseg(kaux),iaux),iaux=1,sdim)
        write(ulsort,90024) '==> carre distance a l''extremite',
     >   1+mod(jaux,2),daux
        endif
#endif
        if ( daux*unst2x.le.epsid2 ) then
          seg = -kaux
          acnoeu = abscur(kaux)
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
          write(ulsort,90015) '==> Le noeud est l''extremite',
     >      1+mod(jaux,2),' de la ligne', numlig
        endif
#endif
          goto 50
c
        endif
c
   20 continue
c
c====
c 3. Le noeud n'est pas une extremite de la ligne
c    On va chercher le segment dont la premiere extremite est
c    la plus proche du noeud courant.
c    Si une de ces extremites est le noeud courant, on le note
c    et on sort.
c====
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
      write(ulsort,90002) 'Le noeud n''est pas extremite de la ligne',
     >                     numlig
      endif
#endif
c
      daux1 = vinfpo
c
      do 30 , kaux = seg1 , seg2
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
        if ( kaux.eq.seg1 .or. kaux.le.-1 ) then
        write(ulsort,90006) '    Segment [',
     >                       somseg(kaux),' ',somseg(kaux+1),'] '
        endif
        endif
#endif
c
c 3.1. ==> Calcul de la distance au point A, debut du segment
c
        daux = 0.d0
        do 31 , iaux = 1 , sdim
          daux = daux + (geocoo(somseg(kaux),iaux)-cono(iaux))**2
   31   continue
cgn        if ( kaux.eq.seg1 .or. kaux.le.-1 ) then
cgn          write(ulsort,90004) '      Carre de la distance', daux
cgn        endif
c
        if ( daux*unst2x.le.epsid2 ) then
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
          write(ulsort,90004) 'Carre de la distance', daux
          write(ulsort,90002)
     >    '==> Le noeud est au debut du segment', kaux
        endif
#endif
          seg = kaux
          acnoeu = abscur(kaux)
          goto 50
c
        endif
c
c 3.2. ==> Memorisation du minimum
c
cgn        write(ulsort,90004) '     Distance ', daux
        if ( daux.le.daux1 ) then
c
          daux1 = daux
          segmin = kaux
cgn        write(ulsort,*) '     Minimum pour le segment ',segmin,
cgn     >               ' : [',somseg(segmin),',',somseg(segmin+1),'] '
c
        endif
c
   30 continue
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
        write(ulsort,90004) 'Distance minimale', daux1
        write(ulsort,90006) '    atteinte sur le segment ',segmin,
     >                  '[',somseg(segmin),' ',somseg(segmin+1),'] '
      endif
#endif
c
c====
c 4. Le noeud n'est pas une extremite d'un segment
c    On precise les points A et B
c====
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
      write(ulsort,90002) 'Le premier segment est seg1', seg1
      write(ulsort,90002) 'Le dernier segment est seg2', seg2
      write(ulsort,90002)
     >  'Le segment le plus proche du noeud est segmin', segmin
      endif
#endif
c
c 4.1. ==> On a trouve le segment dont le debut, A, est le sommet le
c          plus proche de N.
c          Si c'est le premier segment, il n'y a pas d'equivoque :
c          N sera place entre A et B
c          Sinon, il faut preciser entre les deux segments concernes,
c          segmin-1 et segmin. On postule que le segment le plus proche
c          est celui dont la deuxieme extremite est la plus proche de N.
c
c              N
c                       A
c                       .
c        segmin-1  .            . segmin
c             .                         .
c      C .                                      . B
c
      if ( segmin.ne.seg1 ) then
c
        daux  = 0.d0
        daux2 = 0.d0
        do 41 , iaux = 1 , sdim
          daux  = daux  +
     >           (geocoo(somseg(segmin-1),iaux)-cono(iaux))**2
          daux2 = daux2 +
     >           (geocoo(somseg(segmin+1),iaux)-cono(iaux))**2
   41   continue
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
       write(ulsort,90024) '(C-A) Carre de la distance au debut de',
     >          segmin-1, daux
       write(ulsort,90024) '(A-B) Carre de la distance au debut de',
     >          segmin  , daux1
       write(ulsort,90024) '(B- ) Carre de la distance au debut de',
     >          segmin+1, daux2
       write(ulsort,90004) '    N',(cono(iaux),iaux=1,sdim)
       write(ulsort,90004) '    C',
     >  (geocoo(somseg(segmin-1),iaux),iaux=1,sdim), abscur(segmin-1)
       write(ulsort,90004) '    A',
     >  (geocoo(somseg(segmin),iaux),iaux=1,sdim), abscur(segmin)
       write(ulsort,90004) '    B',
     >  (geocoo(somseg(segmin+1),iaux),iaux=1,sdim), abscur(segmin+1)
      endif
#endif
c
        if ( daux.lt.daux2 ) then
          seg = segmin - 1
        else
          seg = segmin
        endif
c
      else
c
        seg = segmin
c
      endif
c
c 4.2. ==> Definition des points A et B
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
      write(ulsort,90002) '... ==> Le noeud est lie au segment', seg
      endif
#endif
c
      do 42 , iaux = 1 , sdim
        cooa(iaux) = geocoo(somseg(seg  ),iaux)
        coob(iaux) = geocoo(somseg(seg+1),iaux)
   42 continue
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
      write(ulsort,90004) '   de A', (cooa(iaux),iaux=1,sdim),
     >                   abscur(seg)
      write(ulsort,90004) '    a B', (coob(iaux),iaux=1,sdim),
     >                   abscur(seg+1)
      endif
#endif
c
c 4.3. ==> Il faut recoller N sur la frontiere le cas echeant,
c          puis redefinir son abscisse curviligne.
c
c 4.3.1. ==> Calcul du produit scalaire AB.AN
c
      daux = 0.d0
      do 431 , iaux = 1 , sdim
        daux = daux +
     >       ( coob(iaux) - cooa(iaux) ) *
     >       ( cono(iaux) - cooa(iaux) )
  431   continue
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
      write(ulsort,90004) 'Produit scalaire AB.AN', daux
      endif
#endif
c
c 4.3.2. ==> Positionnement
c 4.3.2.1. ==> Si le produit scalaire est negatif, c'est que P est
c              "en arriere" de A. On ramene P sur A.
c
      if ( daux.le.0 ) then
c
        do 4321 , iaux = 1 , sdim
          cono(iaux) = cooa(iaux)
 4321   continue
        acnoeu = abscur(seg)
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
        write(ulsort,90004) '.. ==> Le noeud a ete replace sur A'
      endif
#endif
c
      else
c
c         daux1 : distance AB
        daux1 = abscur(seg+1)-abscur(seg)
        daux = daux / (daux1**2)
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
        write(ulsort,90004) 'Distance AB', daux1
        write(ulsort,90004) 'Carre de la distance AB  ', daux1**2
      endif
#endif
c
c 4.3.2.2. ==> Si le produit scalaire est superieur au carre de la
c              distance AB, c'est que P est "en avant" de B.
c              On ramenera P sur B.
c
        if ( daux.ge.1.d0 ) then
c
          do 4322 , iaux = 1 , sdim
            cono(iaux) = coob(iaux)
 4322     continue
          acnoeu = abscur(seg+1)
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
        write(ulsort,90004) '.. ==> Le noeud a ete replace sur B'
      endif
#endif
c
c 4.3.2.3. ==> N est "entre" A et B.
c              On decompose le vecteur AN en une partie le long du
c              segment, alpha.AB, et une partie orthogonale.
c              Cela revient a projeter N orthogonalement au segment.
c
        else
c
          do 4323 , iaux = 1 , sdim
            cono(iaux) = cooa(iaux) + daux*(coob(iaux)-cooa(iaux))
 4323     continue
          acnoeu = abscur(seg) + daux*daux1
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
        write(ulsort,90004) '.. ==> Le noeud a ete place entre A et B'
      endif
#endif
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
        write(ulsort,90004) '. Nouveau noeud', (cono(iaux),iaux=1,sdim)
      endif
#endif
c
c====
c 5. Sortie
c====
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) '5. sortie'
#endif
c
   50 continue
c
#ifdef _DEBUG_HOMARD_
      if ( glop.ne.0 ) then
      write(ulsort,*) 'Bilan :'
      write(ulsort,90002) '==> Segment ', seg
      write(ulsort,90004) '==> Abcisse curviligne', acnoeu
      write(ulsort,*) 'Sortie de SFSENO'
      endif
#endif
c
      end
