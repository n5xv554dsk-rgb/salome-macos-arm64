      subroutine utvgv1 ( nufade, nufafi,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
     >                    nbtetr, nbhexa, nbpyra, nbpent,
     >                    trav1a, trav2a,
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
c     UTilitaire : VoisinaGes Volumes / aretes - phase 1
c     --           -      -   -                        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nufade . e   .   1    . numero initial de la liste des faces       .
c . nufafi . e   .   1    . numero final de la liste des faces         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . nbtetr .  s  .   1    . nombre de tetraedres voisins               .
c . nbhexa .  s  .   1    . nombre d'hexaedres voisins                 .
c . nbpyra .  s  .   1    . nombre de pyramides voisines               .
c . nbpent .  s  .   1    . nombre de pentaedres voisins               .
c . trav1a .  s  .   *    . liste des voisins                          .
c . trav2a . a   .   *    . liste des faces a examiner                 .
c .        .     .        . . numero positif si triangle               .
c .        .     .        . . numero negatif si quadrangle             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . non nul : probleme                         .
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
      parameter ( nompro = 'UTVGV1' )
c
#include "nblang.h"
#include "tbdim0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer nufade, nufafi
      integer nbtetr, nbhexa, nbpyra, nbpent
      integer voltri(2,nbtrto), pypetr(2,*)
      integer volqua(2,nbquto), pypequ(2,*)
c
      integer trav1a(tbdim), trav2a(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer cote, laface, nuface
      integer decafv
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
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
      texte(1,4) = '(''Examen de'',i10,'' face(s).'')'
      texte(1,5) = '(i10,'' voisins de type '',a)'
c
      texte(2,4) = '(''Examination of'',i10,'' face(s).'')'
      texte(2,5) = '(i10,'' neighbours '',a,''type'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nufafi-nufade+1
      write (ulsort,90002) 'Numeros',(trav2a(jaux),jaux=nufade,nufafi)
#endif
#include "tbdim1.h"
c
c====
c 2. decompte des elements de volumes voisins
c====
c
      nbtetr = 0
      nbhexa = 0
      nbpyra = 0
      nbpent = 0
c
      if ( nbteto.gt.0 .or. nbheto.gt.0 .or.
     >     nbpyto.gt.0 .or. nbpeto.gt.0 ) then
c
      decafv = 2 * ( nufafi - nufade + 1 )
c
      do 20 , nuface = nufade, nufafi
c
        laface = trav2a(nuface)
c
c 2.1. ==> La face est un triangle
c
        if ( laface.gt.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) mess14(langue,1,2), laface
#endif
c
          do 21 , cote = 1 , 2
c
            jaux = voltri(cote,laface)
c
c 2.1.1. ==> voisinage par un tetraedre
c
            if ( jaux.gt.0 ) then
c
              do 211 , kaux = 1 , nbtetr
                if ( trav1a(kaux).eq.jaux ) then
                  goto 21
                endif
  211         continue
              nbtetr = nbtetr + 1
              iaux = nbtetr
#include "tbdim2.h"
              trav1a(iaux) = jaux
c
            elseif ( jaux.lt.0 ) then
c
c 2.1.2. ==> voisinage par une pyramide
c
              if ( pypetr(1,-jaux).gt.0 ) then
                do 212 , kaux = 1 , nbpyra
                  if ( trav1a(2*decafv+kaux).eq.
     >                 pypetr(1,-jaux) ) then
                    goto 21
                  endif
  212           continue
                nbpyra = nbpyra + 1
                iaux = 2*decafv+nbpyra
#include "tbdim2.h"
                trav1a(iaux) = pypetr(1,-jaux)
              endif
c
c 2.1.3. ==> voisinage par un pentaedre
c
              if ( pypetr(2,-jaux).gt.0 ) then
                do 213 , kaux = 1 , nbpent
                  if ( trav1a(3*decafv+kaux).eq.
     >                 pypetr(2,-jaux) ) then
                    goto 21
                  endif
  213           continue
                nbpent = nbpent + 1
                iaux = 3*decafv+nbpent
#include "tbdim2.h"
                trav1a(iaux) = pypetr(2,-jaux)
              endif
c
            endif
c
   21     continue
c
c 2.2. ==> La face est un quadrangle
c
        elseif ( laface.lt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) mess14(langue,1,4), -laface
#endif
c
          do 22 , cote = 1 , 2
c
            jaux = volqua(cote,-laface)
c
c 2.2.1. ==> voisinage par un hexaedre
c
            if ( jaux.gt.0 ) then
c
              do 221 , kaux = 1 , nbhexa
                if ( trav1a(decafv+kaux).eq.jaux ) then
                  goto 22
                endif
  221         continue
              nbhexa = nbhexa + 1
              iaux = decafv+nbhexa
#include "tbdim2.h"
              trav1a(iaux) = jaux
c
            elseif ( jaux.lt.0 ) then
c
c 2.2.2. ==> voisinage par une pyramide
c
              if ( pypequ(1,-jaux).gt.0 ) then
                do 222 , kaux = 1 , nbpyra
                  if ( trav1a(2*decafv+kaux).eq.
     >                 pypequ(1,-jaux) ) then
                    goto 22
                  endif
  222           continue
                nbpyra = nbpyra + 1
                iaux = 2*decafv+nbpyra
#include "tbdim2.h"
                trav1a(iaux) = pypequ(1,-jaux)
              endif
c
c 2.2.3. ==> voisinage par un pentaedre
c
              if ( pypequ(2,-jaux).gt.0 ) then
                do 223 , kaux = 1 , nbpent
                  if ( trav1a(3*decafv+kaux).eq.
     >                 pypequ(2,-jaux) ) then
                    goto 22
                  endif
  223           continue
                nbpent = nbpent + 1
                iaux = 3*decafv+nbpent
#include "tbdim2.h"
                trav1a(iaux) = pypequ(2,-jaux)
              endif
c
            endif
c
   22     continue
c
        endif
c
   20 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nbtetr, mess14(langue,1,3)
      write (ulsort,texte(langue,5)) nbhexa, mess14(langue,1,6)
      write (ulsort,texte(langue,5)) nbpyra, mess14(langue,1,5)
      write (ulsort,texte(langue,5)) nbpent, mess14(langue,1,7)
#endif
c
c====
c 3. La fin
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
