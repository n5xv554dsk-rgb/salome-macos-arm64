      subroutine infova ( typmes, nbaret, tbaret,
     >                    nbtear, pttear, tatear,
     >                    nbhear, pthear, tahear,
     >                    nbpyar, ptpyar, tapyar,
     >                    nbpear, ptpear, tapear,
     >                    hettet, hetpyr, hethex, hetpen,
     >                    ulecr,
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
c   INFOrmation : Volumes voisins des Aretes
c   ----          -                   -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typmes . e   .   1    . 10 : message pour les aretes               .
c .        .     .        . 20 : message pour les noeuds sommets       .
c .        .     .        . 30 : message pour les noeuds milieux       .
c . nbaret . e   .   1    . nombre d'aretes concernees                 .
c . tbaret . e   . nbaret . les aretes concernees                     .
c . nbtear . e   .    1   . nombre de tetraedres voisins d'aretes      .
c . pttear . e   .0:nbarto. nombre de tetraedres voisins par aretes    .
c . tatear . e   . nbtear . tetraedres voisins par aretes              .
c . nbhear . e   .    1   . nombre d'hexaedres voisins d'aretes        .
c . pthear . e   .0:nbarto. nombre d'hexaedres voisins par aretes      .
c . tahear . e   . nbhear . hexaedres voisins par aretes               .
c . nbpyar . e   .    1   . nombre de pyramides voisines d'aretes      .
c . ptpyar . e   .0:nbarto. nombre de pyramides voisines par aretes    .
c . tapyar . e   . nbpyar . pyramides voisines par aretes              .
c . nbpear . e   .    1   . nombre de pentaedres voisins d'aretes      .
c . ptpear . e   .0:nbarto. nombre de pentaedres voisins par aretes    .
c . tapear . e   . nbpear . pentaedres voisins par aretes              .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . ulecr  . e   .   1    . unite logique pour l'ecriture              .
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
      parameter ( nompro = 'INFOVA' )
c
#include "nblang.h"
#include "tbdim0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "nombar.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer typmes
      integer nbaret, tbaret(nbaret)
      integer nbtear, pttear(0:nbarto), tatear(nbtear)
      integer nbhear, pthear(0:nbarto), tahear(nbhear)
      integer nbpyar, ptpyar(0:nbarto), tapyar(nbpyar)
      integer nbpear, ptpear(0:nbarto), tapear(nbpear)
      integer hettet(nbteto)
      integer hetpyr(nbpyto)
      integer hethex(nbheto)
      integer hetpen(nbpeto)
c
      integer ulecr
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer jdeb, jfin
      integer larete
      integer letetr, lehexa, lapyra, lepent
      integer nbtevr, tatevr(tbdim)
      integer nbhevr, tahevr(tbdim)
      integer nbpyvr, tapyvr(tbdim)
      integer nbpevr, tapevr(tbdim)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c 1.1. ==> messages
c
#include "impr01.h"
#include "infoen.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de segments :'',i10)'
c
      texte(2,4) = '(''Number of edgs'',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbaret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbarto', nbarto
#endif
c
c====
c 2. tetraedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbteto, nbtecf', nbteto, nbtecf
#endif
c
      nbtevr = 0
c
      if ( nbteto.ne.0 ) then
c
        do 21 , iaux = 1 , nbaret
          larete = tbaret(iaux)
cgn          write (ulecr,90002) 'larete', larete
          jdeb = pttear(larete-1)+1
          jfin = pttear(larete)
          do 211 , jaux = jdeb , jfin
            letetr = tatear(jaux)
            if ( nbtevr.eq.0 ) then
              nbtevr = 1
              tatevr(nbtevr) = letetr
            else
              do 2111 , kaux = 1 , nbtevr
                if ( tatevr(kaux).eq.letetr ) then
                  goto 211
                endif
 2111         continue
              nbtevr = nbtevr + 1
              tatevr(nbtevr) = letetr
            endif
  211     continue
   21   continue
c
      endif
c
c====
c 3. hexaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbheto, nbhecf', nbheto, nbhecf
#endif
c
      nbhevr = 0
c
      if ( nbheto.ne.0 ) then
c
        do 31 , iaux = 1 , nbaret
          larete = tbaret(iaux)
cgn          write (ulecr,90002) 'larete', larete
          jdeb = pthear(larete-1)+1
          jfin = pthear(larete)
          do 311 , jaux = jdeb , jfin
            lehexa = tahear(jaux)
            if ( nbhevr.eq.0 ) then
              nbhevr = 1
              tahevr(nbhevr) = lehexa
            else
              do 3111 , kaux = 1 , nbhevr
                if ( tahevr(kaux).eq.lehexa ) then
                  goto 311
                endif
 3111         continue
              nbhevr = nbhevr + 1
              tahevr(nbhevr) = lehexa
            endif
  311     continue
   31   continue
c
      endif
c
c====
c 4. pyramides
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpyto, nbpycf', nbpyto, nbpycf
#endif
c
      nbpyvr = 0
c
      if ( nbpyto.ne.0 ) then
c
        do 41 , iaux = 1 , nbaret
          larete = tbaret(iaux)
cgn          write (ulecr,90002) 'larete', larete
          jdeb = ptpyar(larete-1)+1
          jfin = ptpyar(larete)
          do 411 , jaux = jdeb , jfin
            lapyra = tapyar(jaux)
            if ( nbpyvr.eq.0 ) then
              nbpyvr = 1
              tapyvr(nbpyvr) = lapyra
            else
              do 4111 , kaux = 1 , nbpyvr
                if ( tapyvr(kaux).eq.lapyra ) then
                  goto 411
                endif
 4111         continue
              nbpyvr = nbpyvr + 1
              tapyvr(nbpyvr) = lapyra
            endif
  411     continue
   41   continue
c
      endif
c
c====
c 5. pentaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpeto, nbpecf', nbpeto, nbpecf
#endif
c
      nbpevr = 0
c
      if ( nbpeto.ne.0 ) then
c
        do 51 , iaux = 1 , nbaret
          larete = tbaret(iaux)
cgn          write (ulecr,90002) 'larete', larete
          jdeb = ptpear(larete-1)+1
          jfin = ptpear(larete)
          do 511 , jaux = jdeb , jfin
            lepent = tapear(jaux)
            if ( nbpevr.eq.0 ) then
              nbpevr = 1
              tapevr(nbpevr) = lepent
            else
              do 5111 , kaux = 1 , nbpevr
                if ( tapevr(kaux).eq.lepent ) then
                  goto 511
                endif
 5111         continue
              nbpevr = nbpevr + 1
              tapevr(nbpevr) = lepent
            endif
  511     continue
   51   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
        write (ulecr,90002) 'nbtevr', nbtevr
        write (ulecr,90002) 'nbhevr', nbhevr
        write (ulecr,90002) 'nbpyvr', nbpyvr
        write (ulecr,90002) 'nbpevr', nbpevr
#endif
c
c====
c 6. Impressions
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'INFOVI', nompro
#endif
      call infovi ( typmes,
     >              nbtevr, tatevr,
     >              nbhevr, tahevr,
     >              nbpyvr, tapyvr,
     >              nbpevr, tapevr,
     >              hettet, hetpyr, hethex, hetpen,
     >              ulecr,
     >              ulsort, langue, codret )
c
c====
c 7. La fin
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
