      subroutine pppma5 ( dedans, wn,
     >                    nbnfa, vfa1, vfa2, vfa3, vfa4,
     >                    nbnfb, vfb1, vfb2, vfb3, vfb4,
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
c     Post-Processeur - Preparation du MAillage - phase 4
c     -    -            -              --               -
c ______________________________________________________________________
c
c    On cherche a savoir si un point de la face B est dans la face A
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . dedans .  s  .   1    . vrai : un point de la face A est dans la   .
c .        .     .        .        face B                              .
c .        .     .        . faux : aucun point commun                  .
c . wn     .   s .   2    . coordonnees du point inclus                .
c . nbnfa  . e   .   1    . nombre de noeuds de la face A              .
c . vfa1   . e   .   3    . coordonnees du sommet 1 de la face A       .
c . vfa2   . e   .   3    . coordonnees du sommet 2 de la face A       .
c . vfa3   . e   .   3    . coordonnees du sommet 3 de la face A       .
c . vfa4   . e   .   3    . coordonnees du sommet 4 de la face A       .
c . nbnfb  . e   .   1    . nombre de noeuds de la face B             .
c . vfb1   . e   .   3    . coordonnees du sommet 1 de la face B       .
c . vfb2   . e   .   3    . coordonnees du sommet 2 de la face B       .
c . vfb3   . e   .   3    . coordonnees du sommet 3 de la face B       .
c . vfb4   . e   .   3    . coordonnees du sommet 4 de la face B       .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c ._____________________________________________________________________
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
      parameter ( nompro = 'PPPMA5' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbnfa, nbnfb
c
      logical dedans
c
      double precision wn(2)
      double precision vfa1(3), vfa2(3), vfa3(3), vfa4(3)
      double precision vfb1(3), vfb2(3), vfb3(3), vfb4(3)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbnx, nbny
      parameter ( nbnx = 30 , nbny = 30 )
      integer iaux, jaux
      integer jdeb, jfin
      integer typbor
c
      double precision daux1, daux2
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
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
      codret = 0
c
      typbor = 0
c
 1796 format(a,6f12.5)
 1797 format(i5,' *',6f12.5)
 1798 format(i4,' :',i5,' *',3i4,' *',6f12.5)
 1799 format(i4,' :',i5,' *',4i4,' *',6f12.5)
c
c====
c 2. Un sommet de la face B est-il dans la face A?
c====
c
      do 21 , iaux = 1 , nbnfb
c
        if ( iaux.eq.1 ) then
          wn(1) = vfb1(1)
          wn(2) = vfb1(2)
        elseif ( iaux.eq.2 ) then
          wn(1) = vfb2(1)
          wn(2) = vfb2(2)
        elseif ( iaux.eq.3 ) then
          wn(1) = vfb3(1)
          wn(2) = vfb3(2)
        elseif ( iaux.eq.4 ) then
          wn(1) = vfb4(1)
          wn(2) = vfb4(2)
        endif
c
        if ( nbnfa.eq.3 ) then
          call uttrn2 ( dedans, vfa1, vfa2, vfa3, wn, typbor )
        else
          call utqun2 ( dedans, vfa1, vfa2, vfa3, vfa4, wn, typbor )
        endif
c
        if ( dedans ) then
cgn          print * ,'....... Le',iaux,'-eme sommet est dedans'
          goto 44
        endif
c
   21 continue
c
c====
c 3. Un point interieur a la face B est-il dans la face A ?
c    On cree des points par les methodes de maillages
c    Evidemment il y a des trous, mais bon ...
c====
c 3.1 ==> La face B est un triangle
c
      if ( nbnfb.eq.3 ) then
c
        jfin = nbny-1
        do 31 , iaux = 1 ,  nbnx
c
          daux1 = dble(iaux-1) / dble(nbnx-1)
          if ( iaux.eq.1 .or. iaux.eq.nbnx ) then
            jdeb = 2
          else
            jdeb = 1
          endif
c
          do 311 , jaux = jdeb, jfin
c
            daux2 = dble(jaux-1) / dble(nbny-1)
            call uttfi1 ( daux1, daux2, vfb1, vfb2, vfb3, wn )
c
            if ( nbnfa.eq.3 ) then
              call uttrn2 ( dedans, vfa1, vfa2, vfa3, wn, typbor )
            else
              call utqun2 ( dedans, vfa1, vfa2, vfa3, vfa4, wn, typbor )
            endif
c
            if ( dedans ) then
cgn              print * ,'....... Un point interieur est dedans'
              goto 44
            endif
c
  311     continue
c
  31    continue
c
c 32. ==> La face B est un quadrangle
c
      else
c
        do 32 , iaux = 1 ,  nbnx
c
          daux1 = dble(iaux-1) / dble(nbnx-1)
          if ( iaux.eq.1 .or. iaux.eq.nbnx ) then
            jdeb = 2
            jfin = nbny-1
          else
            jdeb = 1
            jfin = nbny
          endif
c
          do 321 , jaux = jdeb, jfin
c
            daux2 = dble(jaux-1) / dble(nbny-1)
            call uttfi2 ( daux1, daux2, vfb1, vfb2, vfb3, vfb4, wn )
c
            if ( nbnfa.eq.3 ) then
              call uttrn2 ( dedans, vfa1, vfa2, vfa3, wn, typbor )
            else
              call utqun2 ( dedans, vfa1, vfa2, vfa3, vfa4, wn, typbor )
            endif
c
            if ( dedans ) then
cgn              print * ,'....... Un point interieur est dedans'
              goto 44
            endif
c
  321     continue
c
   32   continue
c
      endif
c
c====
c 4. OK ... ou pas
c====
c
   44 continue
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
