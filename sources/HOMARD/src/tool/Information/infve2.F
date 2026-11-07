      subroutine infve2 ( coonoe,
     >                    somare, np2are, hetare, merare,
     >                    posifa, facare,
     >                    aretri, hettri, nivtri, nintri,
     >                    voltri, pypetr,
     >                    famtri,
     >                    arequa, hetqua, nivqua, ninqua,
     >                    volqua, pypequ,
     >                    famqua,
     >                    infsup, typbor, tbaux1,
     >                    zoom, xyzmiz, xyzmaz,
     >                    tbaux2,
     >                    numniv, numblo, nublfa, nubnvo,
     >                    nnquvi, nbquvi,
     >                    nntrvi, nbtrvi,
     >                    nnarvi, nbarvi,
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
c   INformation : Fichier VEctoriel - 2eme partie
c   --            -       --          -
c ______________________________________________________________________
c
c determination de la liste des noeuds des faces et aretes a visualiser
c
c       remarque : en sortie, on dispose de la liste des noeuds
c       decrivant une face a visualiser par ses noeuds.
c       la numerotation precedente des faces correspondantes est
c       oubliee, et une nouvelle numerotation est disponible
c       par defaut grace a l'ordre de sortie des triplets/quadruplets.
c       idem pour les aretes isolees
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . merare . e   . nbarto . mere de chaque arete                       .
c . np2are . e   . nbarto . numero du noeud p2 milieu de l'arete       .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . nintri . e   . nbtrto . noeud interne au triangle                  .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . famtri . e   . nbtrto . famille des triangles                      .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . ninqua . e   . nbquto . noeud interne au quadrangle                .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . infsup . e   .   1    . information supplementaire a afficher      .
c .        .     .        . 0 : aucune                                 .
c .        .     .        . 1 : numero homard des noeuds               .
c .        .     .        . 2 : numero du calcul des noeuds            .
c .        .     .        . 3 : numero homard des faces                .
c .        .     .        . 4 : numero du calcul des faces             .
c .        .     .        . 5 : numero homard des aretes               .
c .        .     .        . 6 : numero du calcul des aretes            .
c .        .     .        . np : choix n et choix p simultanement      .
c . typbor . e   .   1    . type d'affichage du bord                   .
c .        .     .        .   0 : pas de trace                         .
c .        .     .        .   1 : trace en rouge                       .
c .        .     .        .   2 : trace en noir                        .
c . tbaux1 . e   . nbftri/. donne un numero equivalent a une famille   .
c .        .     . nbfqua . selon que l'orientation est gardee ou non  .
c . zoom   . e   .   1    . vrai ou faux selon zoom ou non             .
c . xyzmiz . e   .   1    . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) minimales de la fenetre de zoom .
c . xyzmaz . e   .   1    . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) maximales de la fenetre de zoom .
c . tbaux2 . es  .-nbquto:. tableau de travail                         .
c .        .     .nbt/arto.                                            .
c . numniv . e   .   1    . numero du niveau a tracer                  .
c .        .     .        . -1 : tous les niveaux                      .
c . numblo . e   .   1    . numero du bloc a tracer                    .
c .        .     .        . 0 : trace du domaine global                .
c . nublfa . e   .-nbquto:. numero de blocs des faces                  .
c .        .     . nbtrto .                                            .
c . nubnvo . e   .   *    . . si numblo>0 : numero de blocs des volumes.
c .        .     .        . . si numniv >=0 : niveau des volumes       .
c .        .     .        . Rangement :                                .
c .        .     .        . les tetraedres                             .
c .        .     .        . les hexaedres                              .
c .        .     .        . les pyramides                              .
c .        .     .        . les pentaedres                             .
c . nnquvi .   s .12nbquac. 1 : niveau du quadrangle a afficher        .
c .        .     .        . 2 : numero HOMARD du quadrangle            .
c .        .     .        . 3, 4, 5, 6 : numeros des noeuds p1         .
c .        .     .        . 7 : famille du quadrangle                  .
c .        .     .        . 8, 9, 10, 11 : numeros des noeuds p2       .
c .        .     .        . 12 : numero du noeud interne               .
c . nbquvi .   s .   1    . nombre de quadrangles a visualiser         .
c . nntrvi .   s .10nbtrac. 1 : niveau du triangle a afficher          .
c .        .     .        . 2 : numero HOMARD du triangle              .
c .        .     .        . 3, 4, 5 : numeros des noeuds p1            .
c .        .     .        . 6 : famille du triangle                    .
c .        .     .        . 7, 8, 9 : numeros des noeuds p2            .
c .        .     .        . 10 : numero du noeud interne               .
c . nbtrvi .   s .   1    . nombre de triangles a visualiser           .
c . nnarvi .   s .6*nbarto. niveau et numero des aretes a visualiser   .
c .        .     .        . liste des noeuds des aretes a visualiser   .
c . nbarvi .   s .   1    . nombre d'aretes visualisables              .
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
      parameter ( nompro = 'INFVE2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "envada.h"
#include "impr02.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto)
      integer np2are(nbarto), merare(nbarto), hetare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer aretri(nbtrto,3), hettri(nbtrto), nivtri(nbtrto)
      integer nintri(nbtrto)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer famtri(nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto), nivqua(nbquto)
      integer ninqua(nbquto)
      integer volqua(2,nbquto), pypequ(2,*)
      integer famqua(nbquto)
      integer tbaux2(-nbquto:*)
      integer nnquvi(12,nbquac), nbquvi
      integer nntrvi(10,nbtrac), nbtrvi
      integer numniv
      integer numblo, nublfa(-nbquto:nbtrto), nubnvo(*)
      integer nnarvi(6,nbarto), nbarvi
      integer infsup, typbor, tbaux1(*)
c
      double precision xyzmiz(sdim), xyzmaz(sdim)
c
      logical zoom
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1, sa3a1
      integer larete, letria, lequad, noeudf(4)
      integer iaux, jaux, kaux, laux
      integer infsu1, infsu2, infsu3
      logical avoir
c
#ifdef _DEBUG_HOMARD_
      double precision daux(sdim)
#endif
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c_______________________________________________________________________
c
c====
c 1. prealables
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de '',a,'' a tracer :'',i10)'
c
      texte(2,4) = '(''Number of '',a,'' for plotting:'',i10)'
c
#include "impr03.h"
c
c     a priori, on ne trace rien
c
      nbarvi = 0
      nbtrvi = 0
      nbquvi = 0
c
c====
c 2. Recherche des faces a tracer :
c    On trace une face seulement si elle est active et
c    . si elle appartient a une region bidimensionnelle du maillage, et
c      si elle appartient au bloc ou au niveau retenu
c    . si elle est une face ayant un et un seul element volumique
c      voisin, et si ce volume appartient au bloc ou au niveau retenu
c    . si elle est une face ayant deux elements volumiques voisins,
c      et si un et un seul des volumes appartient au bloc ou au niveau
c      retenu
c
c    La convention est la suivante :
c    * tbaux2(iaux) vaut 0 si la face est d'une region 2D, du bloc ou
c      du niveau retenu
c    * tbaux2(iaux) vaut 1 si la face borde un domaine volumique, du
c      bloc ou du niveau retenu
c    * tbaux2(iaux) vaut 2 si la face est interne a un domaine
c      volumique, un et un seul des voisins appartenant au bloc ou au
c      niveau retenu
c    * tbaux2(iaux) vaut -1 sinon
c    On tracera donc pour tbaux2(iaux) >= 0
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. recherche des faces a tracer'
#endif
c
c 2.1. ==> A priori, on ne retient rien
c
      do 21 , iaux = -nbquto, nbtrto
        tbaux2(iaux) = -1
   21 continue
c
c 2.2. ==> En l'absence de mailles 3D
c
      if ( nbteto.eq.0 .and. nbheto.eq.0 .and.
     >     nbpyto.eq.0 .and. nbpeto.eq.0 ) then
c
c 2.2.1. ==> Pour tout le domaine et sans tenir compte des niveaux, on
c            se contente de filtrer sur les actives / inactives
c
        if ( numblo.eq.0 .and. numniv.eq.-1 ) then
c
          do 221 , iaux = -nbquto, -1
            if ( mod(hetqua(-iaux),100).eq.0 ) then
              tbaux2(iaux) = 0
            endif
  221     continue
c
          do 212 , iaux = 1, nbtrto
            if ( mod(hettri(iaux),10).eq.0 ) then
              tbaux2(iaux) = 0
            endif
  212     continue
c
c 2.1.2. ==> Avec un bloc, on filtre aussi sur ce bloc
c
        elseif ( numblo.gt.0 ) then
c
          do 213 , iaux = -nbquto, -1
            if ( mod(hetqua(-iaux),100).eq.0 ) then
              if ( nublfa(iaux).eq.numblo ) then
                tbaux2(iaux) = 0
              endif
            endif
  213     continue
c
          do 214 , iaux = 1, nbtrto
            if ( mod(hettri(iaux),10).eq.0 ) then
              if ( nublfa(iaux).eq.numblo ) then
                tbaux2(iaux) = 0
              endif
            endif
  214     continue
c
c 2.1.2. ==> Avec un niveau, on filtre aussi sur ce niveau
c
        else
c
          do 215 , iaux = -nbquto, -1
            if ( mod(hetqua(-iaux),100).eq.0 ) then
              if ( nivqua(iaux).eq.numniv ) then
                tbaux2(iaux) = 0
              endif
            endif
  215     continue
c
          do 216 , iaux = 1, nbtrto
            if ( mod(hettri(iaux),10).eq.0 ) then
              if ( nivtri(iaux).eq.numniv ) then
                tbaux2(iaux) = 0
              endif
            endif
  216     continue
c
        endif
c
      endif
c
c 2.2 ==> En presence d'elements volumiques
c 2.2.1. ==> Les triangles
c
      if ( codret.eq.0 ) then
c
      if ( nbteto.gt.0 .or. nbpyto.gt.0 .or. nbpeto.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFVE5_tr', nompro
#endif
        iaux = 2
        call infve5 ( iaux, nbtrto, voltri, pypetr,
     >                hettri,
     >                numniv, numblo, nubnvo,
     >                tbaux2,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 2.2.2. ==> Les quadrangles
c
      if ( codret.eq.0 ) then
c
      if ( nbheto.gt.0 .or. nbpyto.gt.0 .or. nbpeto.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFVE5_qu', nompro
#endif
        iaux = 4
        call infve5 ( iaux, nbquto, volqua, pypequ,
     >                hetqua,
     >                numniv, numblo, nubnvo,
     >                tbaux2,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 3. caracteristiques associees aux triangles a tracer
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. caracteristiques des tria a tracer'
#endif
c
c 3.1. ==> prealable : on etablit le tableau de correspondance des
c          familles.
c          on indique simplement le numero de la famille.
c
c          iaux : numero de la famille en cours d'examen
c          jaux : nombre de familles equivalentes etablies
c          kaux : numero des familles a comparer
c          laux : numero des codes a comparer
c          famille courante iaux
c
      if ( codret.eq.0 ) then
c
      do 31 , iaux = 1 , nbftri
        tbaux1(iaux) = iaux
   31 continue
c
      do 30 , letria = 1 , nbtrto
c
        if ( tbaux2(letria).ge.0 ) then
c
          avoir = .true.
c
c 3.2. ==> on cherche les sommets
c
          a1 = aretri(letria,1)
          a2 = aretri(letria,2)
          a3 = aretri(letria,3)
c
          call utsotr ( somare, a1, a2, a3,
     >                  sa1a2, sa2a3, sa3a1 )
c
          noeudf(1) = sa1a2
          noeudf(2) = sa2a3
          noeudf(3) = sa3a1
c
c 3.3. ==> on cherche si au moins un des noeuds est a l'interieur
c          de la fenetre de zoom
c
          if ( zoom ) then
c
            avoir = .false.
c
            do 33 , iaux = 1 , 3
              kaux = 0
              do 331 , jaux = 1 , sdim
                if ( coonoe(noeudf(iaux),jaux).ge.xyzmiz(jaux) .and.
     >               coonoe(noeudf(iaux),jaux).le.xyzmaz(jaux) ) then
                  kaux = kaux + 1
                endif
  331         continue
              if ( kaux.eq.sdim ) then
                avoir = .true.
                goto 332
              endif
   33       continue
c
  332       continue
c
          endif
c
c 3.4. ==> Si le triangle est retenu, filtrage eventuel pour deboggage
c
#ifdef _DEBUG_HOMARD_
          if ( avoir ) then
c
            do 34 , jaux = 1 , sdim
              daux(jaux) = 0.d0
              do 341 , iaux = 1 , 3
                daux(jaux) = daux(jaux) + coonoe(noeudf(iaux),jaux)
  341         continue
              daux(jaux) = daux(jaux)/3.d0
   34       continue
cgn            print *,daux
c
            if ( abs(daux(1)-6.d-2).lt.1.d-5 ) then
              avoir = .false.
            elseif ( abs(daux(1)-4.d-2).lt.1.d-5 ) then
              avoir = .false.
            elseif ( abs(daux(2)-1.5d-2).lt.1.d-5 ) then
              avoir = .false.
            elseif ( abs(daux(3)-0.0d-2).lt.1.d-5 ) then
              avoir = .false.
            elseif ( abs(daux(3)-1.5d-2).lt.1.d-5 ) then
              avoir = .false.
            endif
c
          endif
#endif
c
c 3.5. ==> Si le triangle est retenu, on le memorise ainsi que
c          son niveau, sa famille, et on stocke ses trois sommets.
c          En degre 2, on stocke les 3 noeuds milieux. Attention a
c          les placer en coherence avec l'ordre des sommets ...
c
          if ( avoir ) then
c
            nbtrvi = nbtrvi + 1
c
            nntrvi(1,nbtrvi) = nivtri(letria)
            nntrvi(2,nbtrvi) = letria
            nntrvi(3,nbtrvi) = noeudf(1)
            nntrvi(4,nbtrvi) = noeudf(2)
            nntrvi(5,nbtrvi) = noeudf(3)
            nntrvi(6,nbtrvi) = tbaux1(famtri(letria))
            if ( degre.eq.2 ) then
              nntrvi(7,nbtrvi) = np2are(aretri(letria,2))
              nntrvi(8,nbtrvi) = np2are(aretri(letria,3))
              nntrvi(9,nbtrvi) = np2are(aretri(letria,1))
            endif
            if ( mod(mailet,2).eq.0 ) then
              nntrvi(10,nbtrvi) = nintri(letria)
            endif
c
          endif
c
        endif
c
  30  continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,2), nbtrvi
#endif
c
      endif
c
c====
c 4. caracteristiques associees aux quadrangles a tracer
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. caracteristiques des quad a tracer'
#endif
c
      if ( codret.eq.0 ) then
c
c 4.1. ==> prealable : on etablit le tableau de correspondance des
c          familles.
c          on indique simplement le numero de la famille.
c
c          iaux : numero de la famille en cours d'examen
c          jaux : nombre de familles equivalentes etablies
c          kaux : numero des familles a comparer
c          laux : numero des codes a comparer
c          famille courante iaux
c
      do 41 , iaux = 1 , nbfqua
        tbaux1(iaux) = iaux
   41 continue
c
      do 40 , lequad = 1 , nbquto
c
        if ( tbaux2(-lequad).ge.0 ) then
c
          avoir = .true.
c
c 4.2. ==> on cherche les sommets
c
          a1 = arequa(lequad,1)
          a2 = arequa(lequad,2)
          a3 = arequa(lequad,3)
          a4 = arequa(lequad,4)
c
          call utsoqu ( somare, a1, a2, a3, a4,
     >                  sa1a2, sa2a3, sa3a4, sa4a1 )
c
          noeudf(1) = sa1a2
          noeudf(2) = sa2a3
          noeudf(3) = sa3a4
          noeudf(4) = sa4a1
c
c 4.3. ==> on cherche si au moins un des noeuds est a l'interieur
c          de la fenetre de zoom
c
          if ( zoom ) then
c
            avoir = .false.
c
            do 43 , iaux = 1 , 4
              kaux = 0
              do 431 , jaux = 1 , sdim
                if ( coonoe(noeudf(iaux),jaux).ge.xyzmiz(jaux) .and.
     >               coonoe(noeudf(iaux),jaux).le.xyzmaz(jaux) ) then
                  kaux = kaux + 1
                endif
  431         continue
              if ( kaux.eq.sdim ) then
                avoir = .true.
                goto 432
              endif
   43       continue
c
  432       continue
c
          endif
c
c 4.4. ==> Si le quadrangle est retenu, filtrage eventuel pour deboggage
c
#ifdef _DEBUG_HOMARD_
          if ( avoir ) then
c
            do 44 , jaux = 1 , sdim
              daux(jaux) = 0.d0
              do 441 , iaux = 1 , 4
                daux(jaux) = daux(jaux) + coonoe(noeudf(iaux),jaux)
  441         continue
              daux(jaux) = daux(jaux)/4.d0
   44       continue
c
            if ( abs(daux(1)-6.d-2).lt.1.d-5 ) then
              avoir = .false.
            elseif ( abs(daux(1)-4.d-2).lt.1.d-5 ) then
              avoir = .false.
            elseif ( abs(daux(2)-1.5d-2).lt.1.d-5 ) then
              avoir = .false.
            elseif ( abs(daux(3)-0.0d-2).lt.1.d-5 ) then
              avoir = .false.
            elseif ( abs(daux(3)-1.5d-2).lt.1.d-5 ) then
              avoir = .false.
            endif
c
          endif
#endif
c
c 4.5. ==> Si le quadrangle est retenu, on le memorise ainsi que
c          son niveau, sa famille, et on stocke ses quatre sommets.
c          En degre 2, on stocke les 4 noeuds milieux. Attention a
c          les placer en coherence avec l'ordre des sommets ...
c
          if ( avoir ) then
c
            nbquvi = nbquvi + 1
cgn      write (ulsort,*) 'quadrangle ',lequad,' de niveau ',nivqua(lequad)
c
            nnquvi(1,nbquvi) = nivqua(lequad)
            nnquvi(2,nbquvi) = lequad
            nnquvi(3,nbquvi) = noeudf(1)
            nnquvi(4,nbquvi) = noeudf(2)
            nnquvi(5,nbquvi) = noeudf(3)
            nnquvi(6,nbquvi) = noeudf(4)
            nnquvi(7,nbquvi) = tbaux1(famqua(lequad))
            if ( degre.eq.2 ) then
              nnquvi( 8,nbquvi) = np2are(arequa(lequad,2))
              nnquvi( 9,nbquvi) = np2are(arequa(lequad,3))
              nnquvi(10,nbquvi) = np2are(arequa(lequad,4))
              nnquvi(11,nbquvi) = np2are(arequa(lequad,1))
            endif
            if ( mod(mailet,3).eq.0 ) then
              nnquvi(12,nbquvi) = ninqua(lequad)
            endif
c
          endif
c
        endif
c
  40  continue

#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,4), nbquvi
#endif
c
      endif
c
c====
c 5. recherche des aretes a tracer si on a demande le trace des bords
c
c    Une arete a tracer a au plus une face voisine
c
c    la convention est la suivante :
c    * tbaux2(iaux) vaut 0 si l'arete est isolee et est active ;
c    * tbaux2(iaux) vaut 1 si l'arete est un bord de face active ;
c    * tbaux2(iaux) vaut 2 sinon.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. recherche des aretes a tracer'
#endif
c
      if ( numblo.eq.0 .and. numniv.eq.-1 ) then
c
      if ( codret.eq.0 ) then
c
c 5.1. ==> on repere les aretes isolees actives ; pour les autres, on
c          les oublie
c
      do 51 , larete = 1 , nbarto
cgn            print *,hetare(larete),posifa(larete-1),posifa(larete)
        if ( mod(hetare(larete),10).eq.0 .and.
     >       posifa(larete).eq.posifa(larete-1) ) then
          tbaux2(larete) = 0
        else
          tbaux2(larete) = 2
        endif
cgn              print *,'===> tbaux2(,',larete,') = ',tbaux2(larete)
   51 continue
c
c 5.2. ==> recherche des bords eventuels de faces actives
c          attention aux voisinages multiples dus aux conformites
c
      if ( typbor.gt.0 ) then
c
        do 521 , larete = 1 , nbarto
          jaux = 0
          do 522 , iaux = posifa(larete-1)+1, posifa(larete)
            kaux = facare(iaux)
            if ( kaux.gt.0 ) then
              if ( mod(hettri(kaux),10).eq.0 ) then
                jaux = jaux + 1
              endif
            else
              if ( mod(hetqua(-kaux),100).eq.0 ) then
                jaux = jaux + 1
              endif
            endif
  522     continue
          if ( jaux.eq.1 ) then
            tbaux2(larete) = 1
          endif
  521   continue
c
      endif
c
      endif
c
      endif
c
c====
c 6. recherche des noeuds associes aux aretes retenues
c    methode : on boucle sur toutes les aretes retenues en ne
c              considerant que les actives.
c              pour celles-la, on recupere les 2 sommets
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. recherche des noeuds associes aux aretes'
#endif
c
      if ( ( numblo.eq.0 .and. numniv.eq.-1 ) .or.
     >     ( typbor.gt.0 ) ) then
c
      if ( codret.eq.0 ) then
c
      infsu1 = mod(infsup,10)
      if ( infsup.ge.10 ) then
        iaux = ( infsup-infsu1 ) / 10
        infsu2 = mod(iaux,10)
        if ( iaux.ge.10 ) then
          infsu3 = ( iaux-infsu2 ) / 10
        else
          infsu3 = 0
        endif
      else
        infsu2 = 0
        infsu3 = 0
      endif
c
      if ( ( infsu1.ge.5 .and. infsu1.le.6 ) .or.
     >     ( infsu2.ge.5 .and. infsu2.le.6 ) .or.
     >     ( infsu3.ge.5 .and. infsu3.le.6 ) ) then
        laux = 1
      else
        laux = 0
      endif
c
      avoir = .true.
      do 60 , larete = 1 , nbarto
c
c       dans le cas ou l'arete "est active" et "est a tracer"
c
        if ( tbaux2(larete).le.1 .or.
     >       ( laux.eq.1 .and. mod(hetare(larete),10).eq.0 ) ) then
c
c 6.1. ==> on memorise les deux noeuds
c
          noeudf(1) = somare ( 1, larete )
          noeudf(2) = somare ( 2, larete )
c
c 6.3. ==> on cherche si au moins un des noeuds est a l'interieur
c          de la fenetre de zoom
c
          if ( zoom ) then
c
            avoir = .false.
c
            do 62 , iaux = 1 , 2
              kaux = 0
              do 621 , jaux = 1 , sdim
                if ( coonoe(noeudf(iaux),jaux).ge.xyzmiz(jaux) .and.
     >               coonoe(noeudf(iaux),jaux).le.xyzmaz(jaux) ) then
                  kaux = kaux + 1
                endif
  621         continue
              if ( kaux.eq.sdim ) then
                avoir = .true.
                goto 622
              endif
   62       continue
c
  622       continue
c
          endif
c
c 6.4. ==> Si l'arete est retenue, on la memorise, ainsi que son niveau
c          et ses noeuds extremes.
c          En degre 2, on stocke le noeud milieu
c
          if ( avoir ) then
c
            nbarvi = nbarvi + 1
c
            jaux = larete
            do 64 , iaux = 0 , nivsup
              if ( merare(jaux).eq.0 ) then
                nnarvi(1,nbarvi) = iaux
                goto 641
              endif
              jaux = merare(jaux)
   64       continue
  641       continue
            nnarvi(2,nbarvi) = larete
            nnarvi(3,nbarvi) = noeudf(1)
            nnarvi(4,nbarvi) = noeudf(2)
            nnarvi(5,nbarvi) = tbaux2(larete)
c            if ( tbaux2(larete).eq.1 ) then
c              nnarvi(5,nbarvi) = 1
c            else
c              nnarvi(5,nbarvi) = 0
c            endif
            if ( degre.eq.2 ) then
              nnarvi(6,nbarvi) = np2are(larete)
            endif
c
          endif
c
        endif
c
  60  continue
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbarvi
      endif
#endif
c
      endif
c
      endif
c
c====
c 7. la fin
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
