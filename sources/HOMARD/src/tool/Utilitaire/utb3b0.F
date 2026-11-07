      subroutine utb3b0 ( hetnoe, coonoe,
     >                    numcoi, coinpt, coinnn,
     >                    somare,
     >                    hettri, aretri, voltri,
     >                    np2are,
     >                    nbpbco, mess08, mess54,
     >                    ulbila, ulsort, langue, codret )
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
c    UTilitaire - Bilan - option 3 - phase B0
c    --           -              -         --
c ______________________________________________________________________
c
c but : controle l'interpenetration des triangles.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetnoe . e   . nbnoto . historique de l'etat des noeuds            .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . numcoi . e   . nbnoto . numero de la coincidence du noeud          .
c . coinpt . e   .   *    . pointeur de la i-eme coincidence dans coinn.
c . coinnn . e   .   *    . liste des noeuds coincidents               .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . nbpbco . es  .  -1:7  . nombre de problemes de coincidences        .
c . mess54 . e   .nblang,*. messages                                   .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
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
      parameter ( nompro = 'UTB3B0' )
c
      integer typenh
      parameter ( typenh = 2 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombpe.h"
#include "envca1.h"
#include "precis.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer hetnoe(nbnoto)
      integer numcoi(nbnoto), coinpt(*), coinnn(*)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3), hettri(nbtrto), voltri(2,nbtrto)
      integer np2are(nbarto)
      integer nbpbco(-1:7)
c
      character*08 mess08(nblang,*)
      character*54 mess54(nblang,*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer letria, lenoeu
      integer nucoin, ptcoin, ptcode, ptcofi
      integer sommet(6), nbsomm
      integer a1, a2, a3
      integer sa1a2, sa2a3, sa3a1
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      double precision v1(3), v2(3), v3(3), v4(3), v6(4,3), vn(3)
      double precision xmax, xmin, ymax, ymin, zmax, zmin
      double precision prosca
      double precision daux1, daux2
c
      logical logaux(7)
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
#include "utb300.h"
c
#include "utb301.h"
c
c 1.2. ==> constantes
c
      codret = 0
c
      if ( degre.eq.1 ) then
        nbsomm = 3
      else
        nbsomm = 6
      endif
c
      if ( sdim.eq.2 ) then
        v1(3) = 0.d0
        v2(3) = 0.d0
        v3(3) = 0.d0
        vn(3) = 0.d0
      endif
c
      if ( nbteto.eq.0 .and. nbpyto.eq.0 .and. nbpeto.eq.0 ) then
        logaux(2) = .true.
      else
        logaux(2) = .false.
      endif
c
c====
c 2. controle de la non-interpenetration des triangles
c    remarque :
c    La verification est sujette a caution car le test sur la
c    coplanarite est un test sur une egalite de reels ...
c====
c
      do 20 , letria = 1 , nbtrto
c
#ifdef _DEBUG_HOMARD_
        if ( letria.lt.0 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
c 2.1. ==> Filtrage
c    1. on ne s'interesse qu'aux actifs car les autres sont
c    censes avoir ete controles aux iterations anterieures
c    2. on ne s'interesse qu'aux triangles de region 2D, car ceux qui
c    bordent des volumes seront vus par la suite.
c
        if ( mod(hettri(letria),10).eq.0 ) then
          if ( logaux(2) ) then
            logaux(1) = .true.
          else
            if ( voltri(1,letria).eq.0 ) then
              logaux(1) = .true.
            else
              logaux(1) = .false.
            endif
          endif
        else
          logaux(1) = .false.
        endif
c
        if ( logaux(1) ) then
c
          if ( nbpbco(typenh).eq.-1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
            nbpbco(typenh) = 0
          endif
c
c 2.3. ==> les aretes et les sommets de ce triangle
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) '.. ', mess14(langue,2,typenh), letria
        endif
#endif
c
          a1  = aretri(letria,1)
          a2  = aretri(letria,2)
          a3  = aretri(letria,3)
c
          call utsotr ( somare, a1, a2, a3,
     >                  sa1a2, sa2a3, sa3a1 )
c
          sommet(1) = sa1a2
          sommet(2) = sa2a3
          sommet(3) = sa3a1
c
          if ( degre.eq.2 ) then
            sommet(4) = np2are(a1)
            sommet(5) = np2are(a2)
            sommet(6) = np2are(a3)
          endif
c
          v1(1) = coonoe(sommet(1),1)
          v1(2) = coonoe(sommet(1),2)
          if ( sdim.eq.3 ) then
            v1(3) = coonoe(sommet(1),3)
          endif
c
          v2(1) = coonoe(sommet(2),1)
          v2(2) = coonoe(sommet(2),2)
          if ( sdim.eq.3 ) then
            v2(3) = coonoe(sommet(2),3)
          endif
c
          v3(1) = coonoe(sommet(3),1)
          v3(2) = coonoe(sommet(3),2)
          if ( sdim.eq.3 ) then
            v3(3) = coonoe(sommet(3),3)
          endif
c
          xmin = min(v1(1),v2(1),v3(1))
          xmax = max(v1(1),v2(1),v3(1))
          ymin = min(v1(2),v2(2),v3(2))
          ymax = max(v1(2),v2(2),v3(2))
          zmin = min(v1(3),v2(3),v3(3))
          zmax = max(v1(3),v2(3),v3(3))
c
c         v6(1,.) est le produit vectoriel n1n2 x n1n3.
c
          v6(1,1) = (v2(2)-v1(2)) * (v3(3)-v1(3))
     >            - (v2(3)-v1(3)) * (v3(2)-v1(2))
          v6(1,2) = (v2(3)-v1(3)) * (v3(1)-v1(1))
     >            - (v2(1)-v1(1)) * (v3(3)-v1(3))
          v6(1,3) = (v2(1)-v1(1)) * (v3(2)-v1(2))
     >            - (v2(2)-v1(2)) * (v3(1)-v1(1))
c
c         v6(2,.) est le produit vectoriel n2n3 x n2n1.
c
          v6(2,1) = (v3(2)-v2(2)) * (v1(3)-v2(3))
     >            - (v3(3)-v2(3)) * (v1(2)-v2(2))
          v6(2,2) = (v3(3)-v2(3)) * (v1(1)-v2(1))
     >            - (v3(1)-v2(1)) * (v1(3)-v2(3))
          v6(2,3) = (v3(1)-v2(1)) * (v1(2)-v2(2))
     >            - (v3(2)-v2(2)) * (v1(1)-v2(1))
c
c         v6(3,.) est le produit vectoriel n3n1 x n3n2.
c
          v6(3,1) = (v1(2)-v3(2)) * (v2(3)-v3(3))
     >            - (v1(3)-v3(3)) * (v2(2)-v3(2))
          v6(3,2) = (v1(3)-v3(3)) * (v2(1)-v3(1))
     >            - (v1(1)-v3(1)) * (v2(3)-v3(3))
          v6(3,3) = (v1(1)-v3(1)) * (v2(2)-v3(2))
     >            - (v1(2)-v3(2)) * (v2(1)-v3(1))
c
c 2.3. ==> on passe en revue tous les autres sommets qui ne sont pas des
c          sommets isoles.
c       . on ne s'interesse qu'a ceux qui sont strictement dans le
c         parallelepide enveloppe du triangle
c       . on commence par eliminer les trois noeuds du triangle
c       . ensuite, on elimine les noeuds coincidents
c       . on recherche si le noeud est a l'interieur du triangle
c
c         Remarque hyper importante : il ne faut faire les affectations
c         de vn(2) et vn(3) que si c'est utile car elles coutent
c         tres cheres (30% du temps total !)
c         En revanche, inutile de deplier davantage les tests
c         Remarque hyper importante : il vaut mieux mettre en dernier
c         le test sur l'identite de lenoeu avec les noeuds du triangle
c         car on gagne aussi 40% !
c
          do 23 , lenoeu = numip1, numap1
c
            logaux(7) = .false.
c
            vn(1) = coonoe(lenoeu,1)
            if ( vn(1).ge.xmin .and. vn(1).le.xmax ) then
              vn(2) = coonoe(lenoeu,2)
              if ( vn(2).ge.ymin .and. vn(2).le.ymax ) then
                if ( sdim.eq.3 ) then
                  vn(3) = coonoe(lenoeu,3)
                  if ( vn(3).ge.zmin .and. vn(3).le.zmax ) then
                    logaux(7) = .true.
                  endif
                else
                  logaux(7) = .true.
                endif
              endif
            endif
c
            if ( logaux(7) ) then
              do 231 , iaux = 1 , nbsomm
                if ( lenoeu.eq.sommet(iaux) ) then
                  goto 23
                endif
  231         continue
            endif
c
c 2.3.2. ==> le noeud est-il coincident avec un des sommets ?
c
            if ( logaux(7) ) then
c
              if ( nbpbco(-1).gt.0 ) then
c
                nucoin = numcoi(lenoeu)
c
                if ( nucoin.ne.0 ) then
c
                  ptcode = coinpt(nucoin)+1
                  ptcofi = coinpt(nucoin+1)
                  do 232 , ptcoin = ptcode, ptcofi
                    jaux = coinnn(ptcoin)
                    do 2321 , iaux = 1 , nbsomm
                      if ( jaux.eq.sommet(iaux) ) then
                        goto 23
                      endif
 2321               continue
  232             continue
c
                endif
c
              endif
c
            endif
c
c 2.3.3. ==> exclusivement les noeuds p1
c
            if ( logaux(7) ) then
c
              if ( hetnoe(lenoeu).ne.1  .and.
     >             hetnoe(lenoeu).ne.21 .and.
     >             hetnoe(lenoeu).ne.51 ) then
c
                logaux(7) = .false.
c
              endif
c
            endif
c
c 2.3.2. ==> le noeud est-il dans le plan du triangle ?
c            on calcule les deux vecteurs normaux aux triangles
c            (s1,s2,s3) et (s1,s2,n) : vecteurs v6 et v4
c            on cherche s'ils sont paralleles, c'est-a-dire de produit
c            vectoriel nul
c
            if ( logaux(7) ) then
c
c            v4 est le produit vectoriel n1n2 x n1n.
c
              v4(1) = (v2(2)-v1(2)) * (vn(3)-v1(3))
     >              - (v2(3)-v1(3)) * (vn(2)-v1(2))
              v4(2) = (v2(3)-v1(3)) * (vn(1)-v1(1))
     >              - (v2(1)-v1(1)) * (vn(3)-v1(3))
              v4(3) = (v2(1)-v1(1)) * (vn(2)-v1(2))
     >              - (v2(2)-v1(2)) * (vn(1)-v1(1))
c
c            daux2 represente la norme du produit vectoriel v4 x v6(1,.)
c
              daux2 = abs ( v6(1,2) * v4(3) - v6(1,3) * v4(2) )
     >              + abs ( v6(1,3) * v4(1) - v6(1,1) * v4(3) )
     >              + abs ( v6(1,1) * v4(2) - v6(1,2) * v4(1) )
c
c 2.3.3. ==> dans ce plan, n est-il dedans ?
c            cela est vrai si le noeud et un sommet sont du meme cote
c            de l'arete formee par les deux autres sommets. pour cela,
c            on regarde si les produits vectoriels (ab,ac) et (ab,an)
c            sont de meme orientation pour les trois permutations
c            circulaires sur (a,b,c), c'est-a-dire si le produit
c            scalaire des deux produits vectoriels est positif.
c            on teste le caractere strictement positif du produit
c            scalaire, pour pouvoir pieger les cas ou le noeud est sur
c            une arete.
c
              if ( daux2.le.epsima ) then
c
c 2.3.3.1. ==> critere absolu ou relatif
c
                daux1 = 0.d0
c
c 2.3.3.2. ==> arete (s1,s2)
c
                prosca = v4(1)*v6(1,1) + v4(2)*v6(1,2) + v4(3)*v6(1,3)
c
                if ( prosca.lt.daux1 ) then
                  goto 23
                endif
c
c 2.3.3.3. ==> arete (s2,s3)
c
c            v4 est le produit vectoriel n2n3 x s2n.
c
                v4(1) = (v3(2)-v2(2)) * (vn(3)-v2(3))
     >                - (v3(3)-v2(3)) * (vn(2)-v2(2))
                v4(2) = (v3(3)-v2(3)) * (vn(1)-v2(1))
     >                - (v3(1)-v2(1)) * (vn(3)-v2(3))
                v4(3) = (v3(1)-v2(1)) * (vn(2)-v2(2))
     >                - (v3(2)-v2(2)) * (vn(1)-v2(1))
c
                prosca = v4(1)*v6(2,1) + v4(2)*v6(2,2) + v4(3)*v6(2,3)
c
                if ( prosca.lt.daux1 ) then
                  goto 23
                endif
c
c 2.3.3.4. ==> arete (s3,s1)
c
c            v4 est le produit vectoriel n3n1 x s3n.
c
                v4(1) = (v1(2)-v3(2)) * (vn(3)-v3(3))
     >                - (v1(3)-v3(3)) * (vn(2)-v3(2))
                v4(2) = (v1(3)-v3(3)) * (vn(1)-v3(1))
     >                - (v1(1)-v3(1)) * (vn(3)-v3(3))
                v4(3) = (v1(1)-v3(1)) * (vn(2)-v3(2))
     >                - (v1(2)-v3(2)) * (vn(1)-v3(1))
c
                prosca = v4(1)*v6(3,1) + v4(2)*v6(3,2) + v4(3)*v6(3,3)
c
                if ( prosca.lt.daux1 ) then
                  goto 23
                endif
c
c 2.3.5. ==> si logaux(7) est encore vrai, c'est que le noeud est
c            a l'interieur du triangle ... malaise ...
c
                iaux = letria
c
#include "utb302.h"
c
                if ( sdim.eq.2 ) then
                  write (ulbila,14202) sommet(1), v1(1), v1(2)
                  write (ulbila,14202) sommet(2), v2(1), v2(2)
                  write (ulbila,14202) sommet(3), v3(1), v3(2)
                else
                  write (ulbila,14203) sommet(1), v1(1), v1(2), v1(3)
                  write (ulbila,14203) sommet(2), v2(1), v2(2), v2(3)
                  write (ulbila,14203) sommet(3), v3(1), v3(2), v3(3)
                endif
c
                write (ulbila,10200)
c
              endif
c
            endif
c
   23     continue
c
        endif
c
   20 continue
c
      end
