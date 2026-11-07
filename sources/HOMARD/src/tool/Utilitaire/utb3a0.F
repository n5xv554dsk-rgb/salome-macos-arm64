      subroutine utb3a0 ( hetnoe, coonoe,
     >                    numcoi, coinpt, coinnn,
     >                    hetare, somare, posifa,
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
c    UTilitaire - Bilan - option 3 - phase A0
c    --           -              -         --
c ______________________________________________________________________
c
c but : controle l'interpenetration des aretes.
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
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
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
      parameter ( nompro = 'UTB3A0' )
c
      integer typenh
      parameter ( typenh = 1 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
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
      integer hetare(nbarto), somare(2,nbarto), posifa(0:nbarto)
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
      integer larete, lenoeu
      integer nucoin, ptcoin, ptcode, ptcofi
      integer sommet(3), nbsomm
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      double precision v1(3), v2(3), v4(3), v6(4,3), vn(3)
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
        nbsomm = 2
      else
        nbsomm = 3
      endif
c
      v1(2) = 0.d0
      v2(2) = 0.d0
      vn(2) = 0.d0
      v1(3) = 0.d0
      v2(3) = 0.d0
      vn(3) = 0.d0
c
c====
c 2. controle de la non-interpenetration des aretes
c    remarques :
c    1. on ne s'interesse qu'aux actives car les autres sont
c    censees avoir ete controlees aux iterations anterieures
c    2. on ne s'interesse qu'aux aretes de region 1D, car celles qui
c    bordent des faces seront vues par la suite.
c    3. La verification est plus sujette a caution car le test sur la
c    colinearite est un test sur une egalite de reels ...
c====
c
      do 20 , larete = 1 , nbarto
c
#ifdef _DEBUG_HOMARD_
        if ( larete.lt.0 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
c
        if ( mod(hetare(larete),10).eq.0 ) then
          if ( nbtrto.eq.0 .and. nbquto.eq.0 ) then
            logaux(1) = .true.
          else
            if ( posifa(larete-1).eq.posifa(larete) ) then
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
c 2.1. ==> les sommets de cette arete active
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) '.. ', mess14(langue,2,typenh), larete
        endif
#endif
c
          sommet(1) = somare(1,larete)
          sommet(2) = somare(2,larete)
c
          if ( degre.eq.2 ) then
            sommet(3) = np2are(larete)
          endif
c
c 2.2. ==> l'enveloppe
c
          v1(1) = coonoe(sommet(1),1)
          if ( sdim.ge.2 ) then
            v1(2) = coonoe(sommet(1),2)
            if ( sdim.eq.3 ) then
              v1(3) = coonoe(sommet(1),3)
            endif
          endif
c
          v2(1) = coonoe(sommet(2),1)
          if ( sdim.ge.2 ) then
            v2(2) = coonoe(sommet(2),2)
            if ( sdim.eq.3 ) then
              v2(3) = coonoe(sommet(2),3)
            endif
          endif
c
          xmin = min(v1(1),v2(1))
          xmax = max(v1(1),v2(1))
          ymin = min(v1(2),v2(2))
          ymax = max(v1(2),v2(2))
          zmin = min(v1(3),v2(3))
          zmax = max(v1(3),v2(3))
c
c         v6(1,.) represente le vecteur s1s2
c
          v6(1,1) = v2(1)-v1(1)
          v6(1,2) = v2(2)-v1(2)
          v6(1,3) = v2(3)-v1(3)
c
c         v6(2,.) represente le vecteur s2s1
c
          v6(2,1) = - v6(1,1)
          v6(2,2) = - v6(1,2)
          v6(2,3) = - v6(1,3)
c
c 2.3. ==> on passe en revue tous les autres sommets qui ne sont pas des
c          sommets isoles.
c       . on ne s'interesse qu'a ceux qui sont strictement dans le
c         parallelepide enveloppe de l'arete
c       . on commence par eliminer les deux noeuds extremes de l'arete
c       . ensuite, on elimine les noeuds coincidents
c       . on elimine les noeuds qui ne sont pas sur la ligne de l'arete
c       . on recherche si le noeud est a l'interieur de l'arete
c
          do 23 , lenoeu = numip1, numap1
c
c 2.3.1. ==> filtrage initial
c
c              ce test sur htenoe est tres couteux ici
cgn            if ( mod(hetnoe(lenoeu),10).eq.1 ) then
c
            logaux(7) = .false.
c
            vn(1) = coonoe(lenoeu,1)
            if ( vn(1).ge.xmin .and. vn(1).le.xmax ) then
              if ( sdim.ge.2 ) then
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
              else
                logaux(7) = .true.
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
c 2.3.4. ==> le noeud est-il sur la ligne de l'arete ?
c            on calcule les deux vecteurs (s1,s2) et (s1,n)
c            on cherche s'ils sont paralleles
c
            if ( logaux(7) ) then
c
c            v4 represente le vecteur s1n
c
              v4(1) = vn(1)-v1(1)
              v4(2) = vn(2)-v1(2)
              v4(3) = vn(3)-v1(3)
c
c            daux2 represente la norme du produit vectoriel v4 x v6(1,.)
c
              daux2 = abs ( v6(1,2) * v4(3) - v6(1,3) * v4(2) )
     >              + abs ( v6(1,3) * v4(1) - v6(1,1) * v4(3) )
     >              + abs ( v6(1,1) * v4(2) - v6(1,2) * v4(1) )
c
c 2.3.4. ==> dans cette ligne, n est-il dedans ?
c            cela est vrai si le noeud et un sommet sont dans la meme
c            direction sur l'arete a partir de l'autre noeud. pour cela,
c            on regarde si les produits scalaires ab.an sont positifs
c            pour chaque permutation de a et b.
c
              if ( daux2.le.epsima ) then
c
c 2.3.4.1. ==> critere absolu ou relatif
c
                daux1 = 0.d0
c
c 2.3.4.2. ==> a partir de s1
c
                prosca = v4(1)*v6(1,1) + v4(2)*v6(1,2) + v4(3)*v6(1,3)
c
                if ( prosca.lt.daux1 ) then
                  goto 23
                endif
c
c 2.3.4.3. ==> a partir de s2
c
c            v4 represente le vecteur s2n
c
                v4(1) = vn(1)-v2(1)
                v4(2) = vn(2)-v2(2)
                v4(3) = vn(3)-v2(3)
c
                prosca = v4(1)*v6(2,1) + v4(2)*v6(2,2) + v4(3)*v6(2,3)
c
                if ( prosca.lt.daux1 ) then
                  goto 23
                endif
c
c 2.3.4.4. ==> si on arrive ici, c'est que le noeud est sur l'arete
c              ... malaise ...
c
                iaux = larete
c
#include "utb302.h"
c
                if ( sdim.eq.1 ) then
                  write (ulbila,14201) sommet(1), v1(1)
                  write (ulbila,14201) sommet(2), v2(1)
                elseif ( sdim.eq.2 ) then
                  write (ulbila,14202) sommet(1), v1(1), v1(2)
                  write (ulbila,14202) sommet(2), v2(1), v2(2)
                else
                  write (ulbila,14203) sommet(1), v1(1), v1(2), v1(3)
                  write (ulbila,14203) sommet(2), v2(1), v2(2), v2(3)
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
