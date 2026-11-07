      subroutine sftqqu ( bilan,
     >                    lenoeu, larete, lequad,
     >                    coonoe,
     >                    somare, filare, np2are,
     >                    hetqua, arequa, filqua,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
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
c
c
c Copyright EDF 1996
c Copyright EDF 1998
c Copyright EDF 2002
c Copyright EDF 2020
c ______________________________________________________________________
c
c   Suivi de Frontiere - Test Qualite - QUadrangle
c   -        -           -    -         --
c______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . bilan  .   s .   1    . bilan du controle de l'arete               .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c . lenoeu . e   .    1   . noeud en cours d'examen                    .
c . larete . e   .    1   . arete en cours d'examen                    .
c . lequad . e   .    1   . quadrangle en cours d'examen               .
c . coonoe . es  . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'SFTQQU' )
c
      double precision rapqmx
      parameter ( rapqmx = 5.0d0 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "impr02.h"
#include "ope1a4.h"
c
c 0.3. ==> arguments
c
      integer bilan
c
      integer lenoeu, larete, lequad
c
      double precision coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto), filare(nbarto), np2are(nbarto)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer a1, a2, a3, a4
      integer sp, sq, spn, sqn
      integer s0, sp0, sq0
      integer inloc, inloc1, inloc2, inloc3
      integer etat
      integer som(4)
c
      double precision coopro(3)
      double precision coocen(3)
      double precision conoqu(4,3)
      double precision conotr(3,3)
      double precision v1(3), v2(3), v3(3)
      double precision quaper
      double precision quafi1, quafi2, quafi3
      double precision daux1
c
      logical memeco
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.1. ==> messages
c
      texte(1,4) = '(''Aretes du quadrangle'',i10'' :'',4i10)'
      texte(1,5) = '(''Annulation du SF pour le noeud : '',i10)'
c
      texte(2,4) = '(''Edges of quadrangle #'',i10'' :'',4i10)'
      texte(2,5) = '(''Cancellation of BF for node # : '',i10)'
c
 1001 format('... ',a,' :',i10,', ',3g13.5)
#ifdef _DEBUG_HOMARD_
cgn 1000 format('... ',a,' :',3g13.5)
 1002 format('... Test du ',a,' :',4i10)
      write (ulsort,1002) mess14(langue,1,-1), lenoeu
      write (ulsort,1001) 'n', lenoeu, (coonoe(lenoeu,iaux),iaux=1,sdim)
      write (ulsort,1002) mess14(langue,1, 1), larete
      write (ulsort,1002) mess14(langue,1, 4), lequad
#endif
c
c 1.2. ==> Tout va bien a priori
c
      bilan = 0
c
      codret = 0
c
c====
c 2. Reperage des caracteristiques du quadrangle pere
c====
c 2.1. ==> Reperage local des aretes
c
      a1 = arequa(lequad,1)
      a2 = arequa(lequad,2)
      a3 = arequa(lequad,3)
      a4 = arequa(lequad,4)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) lequad, a1, a2, a3, a4
#endif
c
c 2.2. ==> Recherche des sommets
c
c    som(4) = sa4a1   a4   sa3a4 = som(3)
c                 ._________.
c                 .         .
c                 .         .
c               a1.         .a3
c                 .         .
c                 ._________.
c    som(1) = sa1a2   a2   sa2a3 = som(2)
c
cgn      print *,larete
cgn      print *,a1, a2, a3, a4
c
      call utsoqu ( somare, a1, a2, a3, a4,
     >              som(1), som(2), som(3), som(4) )
cgn      write (ulsort,*) 'Sommets : ', som
c
      codret = 22
      do 22 , iaux = 1 , 4
        if ( larete.eq.arequa(lequad,iaux) ) then
          inloc = iaux
          codret = 0
        endif
   22 continue
cgn      print *,inloc
c
      if ( codret.eq.0 ) then
c
      sp = som(inloc)
c
      inloc1 = per1a4(1,inloc)
      spn = som(inloc1)
c
      inloc2 = per1a4(2,inloc)
      sqn = som(inloc2)
c
      inloc3 = per1a4(3,inloc)
      sq = som(inloc3)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,1001) 'sp ',  sp, (coonoe(sp ,iaux),iaux=1,sdim)
      write (ulsort,1001) 'spn', spn, (coonoe(spn,iaux),iaux=1,sdim)
      write (ulsort,1001) 'sq ',  sq, (coonoe(sq ,iaux),iaux=1,sdim)
      write (ulsort,1001) 'sqn', sqn, (coonoe(sqn,iaux),iaux=1,sdim)
#endif
c
c 2.3. ==> Autres caracteristiques
c          . Qualite du quadrangle de depart
c          . Coordonnees du noeud sur la frontiere
c          . Etat
c
      do 23 , iaux = 1 , sdim
        conoqu(1,iaux) = coonoe(sp,iaux)
        conoqu(2,iaux) = coonoe(spn,iaux)
        conoqu(3,iaux) = coonoe(sqn,iaux)
        conoqu(4,iaux) = coonoe(sq,iaux)
        coopro(iaux)   = coonoe(lenoeu,iaux)
   23 continue
cgn      write (ulsort,1001) 'n ', lenoeu, (coopro(iaux),iaux = 1 ,sdim)
cgn      write (ulsort,1002) 'quadrangle pere', sp, spn, sqn, sq
      call utqqu0 ( quaper, daux1, sdim, conoqu )
cgn      write (ulsort,1000) 'Qualite pere  ', quaper
cgn      write (ulsort,1000) 'Surface pere  ', daux1
c
      etat = mod(hetqua(lequad),100)
c
      endif
c
c====
c 3. Test de qualite du decoupage standard
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. test decoupage en 4 ; codret = ', codret
#endif
c
      if ( etat.eq.4 .or. typsfr.gt.2 ) then
c
        if ( codret.eq.0 ) then
c
c                           larete/inloc
c       sp                    lenoeu                     sq
c        .-----------------------.-----------------------.
c        .                       .                       .
c        .                       .                       .
c        .                       .                       .
c        .                       .                       .
c        .                       .                       .
c        .                       .                       .
c inloc1 .                       .s0                     .inloc3
c    sp0 .-----------------------.-----------------------.sq0
c        .                       .                       .
c        .                       .                       .
c        .                       .                       .
c        .        Fils1          .       Fils2           .
c        .                       .                       .
c        .                       .                       .
c        .                       .                       .
c        .-----------------------.-----------------------.
c       spn                                             sqn
c                               inloc2
c
c 3.1. ==> On verifie que le noeud lenoeu ne traverse pas
c          le segment sp0/s0
c
        if ( typsfr.le.2 ) then
          sp0 = somare(2,filare(arequa(lequad,inloc1)))
          sq0 = somare(2,filare(arequa(lequad,inloc3)))
          s0 = somare(2,arequa(filqua(lequad),2))
          do 311 , iaux = 1 , sdim
            coocen(iaux) = coonoe(s0,iaux)
  311     continue
        else
          sp0 = np2are(arequa(lequad,inloc1))
          sq0 = np2are(arequa(lequad,inloc3))
          do 312 , iaux = 1 , sdim
            coocen(iaux) = 0.5d0*(coonoe(sp0,iaux)+coonoe(sq0,iaux))
  312     continue
        endif
cgn      write (ulsort,1001) 'sp0', sp0, (coonoe(sp0,iaux),iaux=1,sdim)
cgn      write (ulsort,1001) 'sq0', sq0, (coonoe(sq0,iaux),iaux=1,sdim)
cgn      write (ulsort,1001) 's0 ',  s0, (coocen(iaux),iaux=1,sdim)
c
        do 31 , iaux = 1 , sdim
          v1(iaux) = coonoe(sp0,iaux)
          v2(iaux) = coocen(iaux)
          v3(iaux) = conoqu(1,iaux)
   31   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v1, v2, v3, coopro, iaux )
        else
          call utsen3 ( memeco, v1, v2, v3, coopro, iaux )
        endif
c                              sp0  s0  sp  N
cgn      write (ulsort,*) 'Du bon cote de sp0/s0 :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 3.2. ==> On verifie que le noeud lenoeu ne traverse pas
c          le segment sq0/s0
c
        do 32 , iaux = 1 , sdim
          v1(iaux) = coonoe(sq0,iaux)
   32   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v1, v2, v3, coopro, iaux )
        else
          call utsen3 ( memeco, v1, v2, v3, coopro, iaux )
        endif
c                              sq0  s0  sp  N
cgn      write (ulsort,*) 'Du bon cote de sq0/s0 :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 3.3. ==> On verifie que le noeud lenoeu ne traverse pas
c          le segment sq0/sq
c
        do 33 , iaux = 1 , sdim
          v2(iaux) = coonoe(sq,iaux)
   33   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v1, v2, v3, coopro, iaux )
        else
          call utsen3 ( memeco, v1, v2, v3, coopro, iaux )
        endif
c                              sq0  sq  sp  N
cgn      write (ulsort,*) 'Du bon cote de sq0/sq :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 3.4. ==> On verifie que le noeud lenoeu ne traverse pas
c          le segment sp0/sp
c
        do 34 , iaux = 1 , sdim
          v1(iaux) = coonoe(sp0,iaux)
   34   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v1, v3, v2, coopro, iaux )
        else
          call utsen3 ( memeco, v1, v3, v2, coopro, iaux )
        endif
c                              sp0  sp  sq  N
cgn      write (ulsort,*) 'Du bon cote de sp0/sp :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 3.5. ==> Qualites des fils avec le noeud deplace
c
        do 351 , iaux = 1 , sdim
          conoqu(2,iaux) = coonoe(sp0,iaux)
          conoqu(3,iaux) = coocen(iaux)
          conoqu(4,iaux) = coopro(iaux)
  351   continue
cgn      write (ulsort,1002) 'quadrangle', sp, sp0, s0, lenoeu
        call utqqu0 ( quafi1, daux1, sdim, conoqu )
cgn        write (ulsort,1000) 'Qualite fils 1', quafi1
c
        do 352 , iaux = 1 , sdim
          conoqu(1,iaux) = coonoe(sq,iaux)
          conoqu(2,iaux) = coonoe(sq0,iaux)
  352   continue
cgn      write (ulsort,1002) 'quadrangle', sq, sq0, s0, lenoeu
        call utqqu0 ( quafi2, daux1, sdim, conoqu )
cgn        write (ulsort,1000) 'Qualite fils 2', quafi2
c
c       On limite le facteur d'accroissement
c
cgn        write (ulsort,1000) 'max 1 2', max(quafi1,quafi2)
cgn        write (ulsort,1000) 'seuil  ', quaper*rapqmx
        if ( max(quafi1,quafi2).gt.quaper*rapqmx ) then
          bilan = 1
          goto 50
        endif
c
        endif
c
      endif
c
c====
c 4. Test de qualite du decoupage de conformite
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. test decoupage en 3 ; codret = ', codret
#endif
c
      if ( ( etat.ge.31 .and. etat.le.34 ) .or. typsfr.gt.2 ) then
c
        if ( codret.eq.0 ) then
c
c                   larete/inloc
c       sp            lenoeu              sq
c        .---------------.----------------.
c        .              .  .              .
c        .             .    .             .
c        .            .      .            .
c        .           .        .           .
c        .          .          .          .
c        .         .            .         .
c        .        .              .        .
c        .       .                .       .
c        .      .                  .      .
c        .     .                    .     .
c        .    .                     .    .
c        .   .                        .   .
c        .  .                          .  .
c        . .                            . .
c        ..                              ..
c        .--------------------------------.
c       spn                              sqn
c
c 4.1. ==> On verifie que le noeud lenoeu ne traverse pas
c          le segment sp/spn
c
        do 41 , iaux = 1 , sdim
          v1(iaux) = coonoe(sp,iaux)
          v2(iaux) = coonoe(spn,iaux)
          v3(iaux) = coonoe(sq,iaux)
   41   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v1, v2, v3, coopro, iaux )
        else
          call utsen3 ( memeco, v1, v2, v3, coopro, iaux )
        endif
c                               sp spn  sq  N
cgn      write (ulsort,*) 'Du bon cote de sp/spn :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 4.2. ==> On verifie que le noeud lenoeu ne traverse pas
c          le segment sq/sqn
c
        do 42 , iaux = 1 , sdim
          v2(iaux) = coonoe(sqn,iaux)
   42   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v3, v2, v1, coopro, iaux )
        else
          call utsen3 ( memeco, v3, v2, v1, coopro, iaux )
        endif
c                               sq sqn  sp  N
cgn      write (ulsort,*) 'Du bon cote de sq/sqn :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 4.3. ==> On verifie que le noeud lenoeu ne traverse pas
c          le segment spn/sqn
c
        do 43 , iaux = 1 , sdim
          v1(iaux) = coonoe(spn,iaux)
   43   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v1, v2, v3, coopro, iaux )
        else
          call utsen3 ( memeco, v1, v2, v3, coopro, iaux )
        endif
c                              spn sqn  sq  N
cgn      write (ulsort,*) 'Du bon cote de spn/sqn :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 4.4. ==> Qualite future des triangles issus du decoupage
c
        do 441 , iaux = 1 , sdim
          conotr(1,iaux) = coonoe(sp,iaux)
          conotr(2,iaux) = coonoe(spn,iaux)
          conotr(3,iaux) = coopro(iaux)
  441   continue
cgn      write (ulsort,1002) 'triangle', sp, spn, lenoeu
        call utqtr0 ( quafi1, daux1, sdim, conotr )
cgn      write (ulsort,1000) 'Qualite fils 1', quafi1
c
        do 442 , iaux = 1 , sdim
          conotr(1,iaux) = coonoe(sqn,iaux)
  442   continue
cgn      write (ulsort,1002) 'triangle', sqn, spn, lenoeu
        call utqtr0 ( quafi2, daux1, sdim, conotr )
cgn      write (ulsort,1000) 'Qualite fils 2', quafi2
c
        do 443 , iaux = 1 , sdim
          conotr(2,iaux) = coonoe(sq,iaux)
  443   continue
cgn      write (ulsort,1002) 'triangle', sqn, sq, lenoeu
        call utqtr0 ( quafi3, daux1, sdim, conotr )
cgn      write (ulsort,1000) 'Qualite fils 3', quafi3
c
c        On limite le facteur d'accroissement
c
cgn        write (ulsort,1000) 'max 1 2 3', max(quafi1,quafi2,quafi3)
cgn        write (ulsort,1000) 'seuil  ', quaper*rapqmx*2.d0
         if ( max(quafi1,quafi2,quafi3).gt.quaper*rapqmx*2.d0 ) then
          bilan = 1
          goto 50
        endif
c
      endif
c
      endif
c
c====
c 5.La fin
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. la fin ; codret = ', codret
#endif
c
   50 continue
c
#ifdef _DEBUG_HOMARD_
      if ( bilan.ne.0 ) then
        write(ulsort,texte(langue,5)) lenoeu
      endif
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,1001) mess14(langue,2,-1), lenoeu,
     >                               (coopro(iaux),iaux=1,sdim)
      write (ulsort,1001) mess14(langue,2, 1), larete
      write (ulsort,1001) mess14(langue,2, 4), lequad
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
