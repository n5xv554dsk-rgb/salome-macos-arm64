      subroutine infovo ( typmes, nufade, nufafi, volint,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
     >                    hettet, hetpyr, hethex, hetpen,
     >                    trav1a, trav2a,
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
c   INFOrmation : VOisins
c   ----          --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typmes . e   .   1    .  0 : message pour les faces                .
c .        .     .        . 40 : message pour les tetra-penta-hexaedres.
c .        .     .        . 50 : message pour les pyramides            .
c . nufade . e   .   1    . numero initial de la liste des faces       .
c . nufafi . e   .   1    . numero final de la liste des faces         .
c . volint . e   .  4**   . i,0 : nombre de volumes interdits          .
c .        .     .        . i,j>0 : numeros des volumes interdits      .
c .        .     .        . i=1 : tetr, i=2 : hexa, i=3 : pyra,        .
c .        .     .        . i=4 : pent                                 .
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
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . trav1a . a   .   *    . tableau de travail numero 1                .
c . trav2a . a   .   *    . liste des faces a examiner                 .
c .        .     .        . . numero positif si triangle               .
c .        .     .        . . numero negatif si quadrangle             .
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
      parameter ( nompro = 'INFOVO' )
c
#include "nblang.h"
#include "tbdim0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "inmess.h"
#include "impr02.h"
c
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "hexcf0.h"
#include "hexcf1.h"
c
c 0.3. ==> arguments
c
      integer typmes
      integer nufade, nufafi
      integer volint(4,0:*)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer volqua(2,nbquto), pypequ(2,*)
      integer hettet(nbteto)
      integer hetpyr(nbpyto)
      integer hethex(nbheto)
      integer hetpen(nbpeto)
c
      integer trav1a(tbdim), trav2a(tbdim)
c
      integer ulecr
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nument, decafv
      integer etat, bindec
      integer letetr, lehexa, lapyra, lepent
      integer nbtetr, nbhexa, nbpyra, nbpent
      integer nbtevr, nbhevr, nbpyvr, nbpevr
      integer inditv (0:2,0:2,0:2,0:2)
c
      character*40 taux40
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
      texte(1,4) = '(''Examen de'',i10,'' face(s).'')'
      texte(1,5) = '(''Nombre de '',a,'' interdits :'',i10)'
      texte(1,6) = '(''.. '',a,''numero'',i10)'
      texte(1,7) = '(''Nombre de '',a,'' :'',i10)'
c
      texte(2,4) = '(''Examination of'',i10,'' face(s).'')'
      texte(2,5) = '(''Number of '',,a,'' which are forbiden :'',i10)'
      texte(2,6) = '(''.. '',a,''#'',i10)'
      texte(2,7) = '(''Number of '',,a,'':'',i10)'
c
#include "impr03.h"
c
#include "tbdim1.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nufafi-nufade+1
      write (ulsort,90002) 'Numeros',(trav2a(jaux),jaux=nufade,nufafi)
#endif
c
c 1.2. ==> indirections dans les messages
c
      inditv(1,0,0,0) = 1 + typmes
      inditv(2,0,0,0) = 2 + typmes
      inditv(0,1,0,0) = 3 + typmes
      inditv(0,2,0,0) = 4 + typmes
      inditv(0,0,1,0) = 5 + typmes
      inditv(0,0,2,0) = 6 + typmes
      inditv(0,0,0,1) = 7 + typmes
      inditv(0,0,0,2) = 8 + typmes
c
cgn      print *,(volint(1,iaux), iaux = 0 , volint(1,0) )
cgn      print *,(volint(2,iaux), iaux = 0 , volint(2,0) )
cgn      print *,(volint(3,iaux), iaux = 0 , volint(3,0) )
cgn      print *,(volint(4,iaux), iaux = 0 , volint(4,0) )
c
c====
c 2. decompte des elements de volumes voisins
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVGVA', nompro
#endif
      call utvgv1 ( nufade, nufafi,
     >              voltri, pypetr,
     >              volqua, pypequ,
     >              nbtetr, nbhexa, nbpyra, nbpent,
     >              trav1a, trav2a,
     >              ulsort, langue, codret )
c
c====
c 3. filtrage des elements interdits
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. filtrage  ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 3.0. ==> decalage dans le tableau face/volumes (trav1a)
c
      decafv = 2 * ( nufafi - nufade + 1 )
c
c 3.1. ==> tetraedres
c
      if ( volint(1,0).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,3), volint(1,0)
      write (ulsort,90002) 'Numeros',(volint(1,jaux),jaux=1,volint(1,0))
#endif
c
        kaux = 0
        do 31 , nument = 1 , nbtetr
          letetr = trav1a(nument)
          do 311 , jaux = 1 , volint(1,0)
            if ( volint(1,jaux).eq.letetr ) then
              iaux = nument
#include "tbdim2.h"
              trav1a(iaux) = 0
              goto 31
            endif
  311     continue
          kaux = kaux + 1
   31   continue
        nbtevr = min(2,kaux)
c
      else
c
        nbtevr = nbtetr
c
      endif
c
c 3.2. ==> hexaedres
c
      if ( volint(2,0).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,6), volint(2,0)
      write (ulsort,90002) 'Numeros',(volint(2,jaux),jaux=1,volint(2,0))
#endif
c
        kaux = 0
        do 32 , nument = 1 , nbhexa
          lehexa = trav1a(decafv+nument)
          do 321 , jaux = 1 , volint(2,0)
            if ( volint(2,jaux).eq.lehexa ) then
              iaux = decafv+nument
#include "tbdim2.h"
              trav1a(iaux) = 0
              goto 32
            endif
  321     continue
          kaux = kaux + 1
   32   continue
        nbhevr = kaux
c
      else
c
        nbhevr = nbhexa
c
      endif
c
c 3.3. ==> pyramides
c
      if ( volint(3,0).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,5), volint(3,0)
      write (ulsort,90002) 'Numeros',(volint(3,jaux),jaux=1,volint(3,0))
#endif
c
        kaux = 0
        do 33 , nument = 1 , nbpyra
          lapyra = trav1a(2*decafv+nument)
          do 331 , jaux = 1 , volint(3,0)
            if ( volint(3,jaux).eq.lapyra ) then
              iaux = 2*decafv+nument
#include "tbdim2.h"
              trav1a(iaux) = 0
              goto 33
            endif
  331     continue
          kaux = kaux + 1
   33   continue
        nbpyvr = min(2,kaux)
c
      else
c
        nbpyvr = nbpyra
c
      endif
c
c 3.4. ==> pentaedres
c
      if ( volint(4,0).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,7), volint(4,0)
      write (ulsort,90002) 'Numeros',(volint(4,jaux),jaux=1,volint(4,0))
#endif
c
        kaux = 0
        do 34 , nument = 1 , nbpent
          lepent = trav1a(3*decafv+nument)
          do 341 , jaux = 1 , volint(4,0)
            if ( volint(4,jaux).eq.lepent ) then
              iaux = 3*decafv+nument
#include "tbdim2.h"
              trav1a(iaux) = 0
              goto 34
            endif
  341     continue
          kaux = kaux + 1
   34   continue
        nbpevr = min(2,kaux)
c
      else
c
        nbpevr = nbpent
c
      endif
c
c====
c 4. impression
c====
c
c 4.1. ==> tetraedres
c
      if ( nbtevr.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) mess14(langue,3,3), nbtevr
#endif
        iaux = min(2,nbtevr)
        write (ulecr,40002) textvo(inditv(iaux,0,0,0))
        do 41 , nument = 1 , nbtetr
          iaux = nument
          letetr = trav1a(iaux)
          if ( letetr.gt.0 ) then
            etat = mod(hettet(letetr),100)
            taux40 = textte(etat)
            write (ulecr,46000) letetr, taux40
          endif
   41   continue
      endif
c
c 4.2. ==> hexaedres
c
      if ( nbhevr.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) mess14(langue,3,6), nbhevr
        write (ulsort,texte(langue,7)) mess14(langue,3,6), nbhexa
#endif
        iaux = min(2,nbhevr)
        write (ulecr,40002) textvo(inditv(0,iaux,0,0))
        do 42 , nument = 1 , nbhexa
          iaux = decafv+nument
          lehexa = trav1a(iaux)
          if ( lehexa.gt.0 ) then
            etat = mod(hethex(lehexa),1000)
            if ( etat.le.10 ) then
              taux40 = texthe(etat)
              write (ulecr,46000) lehexa, taux40
            else
              bindec = chbiet(etat)
              if ( etat.le.22 ) then
                write (ulecr,46031) lehexa, charde(bindec)(1:3)
              elseif ( ( etat.ge.285 ) .and. ( etat.le.290 ) ) then
                taux40 = texthe(etat-244)
                write (ulecr,46000) lehexa, taux40
              else
                write (ulecr,46030) lehexa, charde(bindec)(1:27)
              endif
            endif
          endif
   42   continue
      endif
c
c 4.3. ==> pyramides
c
      if ( nbpyvr.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) mess14(langue,3,5), nbpyvr
#endif
        iaux = min(2,nbpyvr)
        write (ulecr,40002) textvo(inditv(0,0,iaux,0))
        do 43 , nument = 1 , nbpyra
          iaux = 2*decafv+nument
          lapyra = trav1a(iaux)
          if ( lapyra.gt.0 ) then
            etat = mod(hetpyr(lapyra),100)
            taux40 = textpy(etat)
            write (ulecr,46000) lapyra, taux40
          endif
   43   continue
      endif
c
c 4.4. ==> pentaedres
c
      if ( nbpevr.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) mess14(langue,3,7), nbpevr
#endif
        iaux = min(2,nbpevr)
        write (ulecr,40002) textvo(inditv(0,0,0,iaux))
        do 44 , nument = 1 , nbpent
          iaux = 3*decafv+nument
          lepent = trav1a(iaux)
          if ( lepent.gt.0 ) then
            etat = mod(hetpen(lepent),100)
            taux40 = textpe(etat)
            write (ulecr,46000) lepent, taux40
          endif
   44   continue
      endif
c
      endif
c
c====
c 5. La fin
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
