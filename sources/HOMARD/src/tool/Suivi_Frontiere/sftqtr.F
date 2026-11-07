      subroutine sftqtr ( bilan, bascul,
     >                    lenoeu, larete, letria,
     >                    coonoe,
     >                    somare, filare, np2are,
     >                    hettri, aretri,
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
c    HOMARD est une marque deposee d'Electricite de France
c
c Copyright EDF 1996
c Copyright EDF 1998
c Copyright EDF 2002
c Copyright EDF 2020
c ______________________________________________________________________
c
c   Suivi de Frontiere - Test Qualite - TRiangle
c   -        -           -    -         --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . bilan  .   s .   1    . bilan du controle de l'arete               .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c . bascul .   s .    1   . vrai pour une bascule d'arete              .
c . lenoeu . e   .    1   . noeud en cours d'examen                    .
c . larete . e   .    1   . arete en cours d'examen                    .
c . letria . e   .    1   . triangle en cours d'examen                 .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . np2are . e   . nbarto . noeud milieux des aretes                   .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
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
      parameter ( nompro = 'SFTQTR' )
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
#include "nombtr.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer bilan
c
      logical bascul
c
      integer lenoeu, larete, letria
c
      double precision coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto), filare(nbarto), np2are(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer a1, a2, a3
      integer sa1a2, sa2a3, sa3a1
      integer sn, sp, sq
      integer np, nq
      integer arep, areq
      integer etat
c
      double precision coopro(3)
      double precision conotr(3,3)
      double precision v1(3), v2(3), v3(3)
      double precision quaper
      double precision quafi1, quafi2, quafi3, quafi5, quafi6
      double precision daux1, daux2
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
      texte(1,4) = '(''Aretes du triangle'',i10'' :'',3i10)'
      texte(1,5) = '(''Annulation du SF pour le noeud : '',i10)'
c
      texte(2,4) = '(''Edges of triangle #'',i10'' :'',3i10)'
      texte(2,5) = '(''Cancellation of BF for node # : '',i10)'
c
 1000 format('... ',a,' :',3g13.5)
 1001 format('... ',a,' :',i10,', ',3g13.5)
 1002 format('... Test du ',a,' :',4i10)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,1002) mess14(langue,1,-1), lenoeu
      write (ulsort,1001) 'n', lenoeu, (coonoe(lenoeu,iaux),iaux=1,sdim)
      write (ulsort,1002) mess14(langue,1, 1), larete
      write (ulsort,1002) mess14(langue,1, 2), letria
#endif
c
c 1.2. ==> Tout va bien a priori
c
      bilan = 0
c
      codret = 0
c
c====
c 2. Reperage des caracteristiques du triangle pere
c====
c 2.1. ==> Reperage local des aretes
c
      a1 = aretri(letria,1)
      a2 = aretri(letria,2)
      a3 = aretri(letria,3)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) letria, a1, a2, a3
#endif
c
c 2.2. ==> Recherche des sommets
c                          sa2a3
c                            *
c                           . .
c                          .   .
c                         .     .
c                     a3 .       . a2
c                       .         .
c                      .           .
c                     .             .
c               sa3a1*---------------*sa1a2
c                           a1
c
      call utsotr ( somare, a1, a2, a3,
     >              sa1a2, sa2a3, sa3a1 )
c
      if ( larete.eq.a1 ) then
        sp = sa1a2
        sq = sa3a1
        sn = sa2a3
        arep = a3
        areq = a2
      elseif ( larete.eq.a2 ) then
        sp = sa2a3
        sq = sa1a2
        sn = sa3a1
        arep = a1
        areq = a3
      elseif ( larete.eq.a3 ) then
        sp = sa3a1
        sq = sa2a3
        sn = sa1a2
        arep = a2
        areq = a1
      else
        codret = 12
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,1001) 'sp', sp, (coonoe(sp,iaux),iaux=1,sdim)
      write (ulsort,1001) 'sq', sq, (coonoe(sq,iaux),iaux=1,sdim)
      write (ulsort,1001) 'sn', sn, (coonoe(sn,iaux),iaux=1,sdim)
      write (ulsort,1001) 'arep', arep
      write (ulsort,1001) 'areq', areq
#endif
c
c 2.3. ==> Autres caracteristiques
c          . Qualite du triangle de depart
c          . Coordonnees du noeud sur la frontiere
c          . Etat
c
      if ( codret.eq.0 ) then
c
      do 23 , iaux = 1 , sdim
        conotr(1,iaux) = coonoe(sp,iaux)
        conotr(2,iaux) = coonoe(sq,iaux)
        conotr(3,iaux) = coonoe(sn,iaux)
        coopro(iaux)   = coonoe(lenoeu,iaux)
   23 continue
cgn      write (ulsort,1001) 'n ', lenoeu, (coopro(iaux),iaux = 1 ,sdim)
cgn      write (ulsort,1002) 'triangle pere', sp, sq, sn
      call utqtr0 ( quaper, daux2, sdim, conotr )
cgn      write (ulsort,1000) 'Qualite pere  ', quaper
cgn      write (ulsort,1000) 'Surface pere  ', daux2
c
      etat = mod(hettri(letria),10)
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
c                             larete
c       sp                    lenoeu                      sq
c        .-----------------------.-----------------------.
c         .                     . .                     .
c          .                   .   .                   .
c           .                 .     .                 .
c            .    Fils1      .       .     Fils3     .
c             .             .         .             .
c              .           .           .           .
c               .         .             .         .
c                .       .     Fils2     .       .
c                 .     .                 .     .
c                  .   .                   .   .
c           areq    . .                     . .   arep
c                    .-----------------------.
c                 nq  .                     . np
c                      .                   .
c                       .                 .
c                        .     Fils4     .
c                         .             .
c                          .           .
c                           .         .
c                            .       .
c                             .     .
c                              .   .
c                               . .
c                                .
c                               sn
c
c 3.1. ==> On verifie que le noeud lenoeu ne traverse pas
c          le segment np/nq
c
        if ( typsfr.le.2 ) then
          np = somare(2,filare(arep))
          nq = somare(2,filare(areq))
        else
          np = np2are(arep)
          nq = np2are(areq)
        endif
cgn      write (ulsort,1001) 'np', np, (coonoe(np,iaux),iaux = 1 ,sdim)
cgn      write (ulsort,1001) 'nq', nq, (coonoe(nq,iaux),iaux = 1 ,sdim)
c
        do 31 , iaux = 1 , sdim
          v1(iaux) = coonoe(np,iaux)
          v2(iaux) = coonoe(nq,iaux)
          v3(iaux) = conotr(1,iaux)
   31   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v1, v2, v3, coopro, iaux )
        else
          call utsen3 ( memeco, v1, v2, v3, coopro, iaux )
c                               np  nq  sp  N
        endif
cgn      write (ulsort,*) 'Du bon cote de np/nq :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 3.2. ==> On verifie que le noeud lenoeu ne traverse pas
c          le segment sp/nq
c
        do 32 , iaux = 1 , sdim
          v1(iaux) = conotr(2,iaux)
   32   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v3, v2, v1, coopro, iaux )
        else
          call utsen3 ( memeco, v3, v2, v1, coopro, iaux )
        endif
c                               sp  nq  sq  N
cgn      write (ulsort,*) 'Du bon cote de sp/sn :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 3.3. ==> On verifie que le noeud lenoeu ne traverse pas
c          le segment sq/np
c
        do 33 , iaux = 1 , sdim
          v2(iaux) = coonoe(np,iaux)
   33   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v1, v2, v3, coopro, iaux )
        else
          call utsen3 ( memeco, v1, v2, v3, coopro, iaux )
        endif
c                               sq  np  sp  N
cgn      write (ulsort,*) 'Du bon cote de sq/sn :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 3.4. ==> Qualites des fils avec le noeud deplace
c 3.4.1. ==> Les triangles de cote
c
        do 3411 , iaux = 1 , sdim
          conotr(2,iaux) = coonoe(nq,iaux)
          conotr(3,iaux) = coopro(iaux)
 3411   continue
cgn        write (ulsort,1002) 'triangle fils 1', sp, nq, lenoeu
        call utqtr0 ( quafi1, daux2, sdim, conotr )
cgn        write (ulsort,1000) 'Qualite fils 1', quafi1
cgn        write (ulsort,1000) 'Surface fils 1', daux1
c
        do 3412 , iaux = 1 , sdim
          conotr(1,iaux) = coonoe(sq,iaux)
          conotr(2,iaux) = coonoe(np,iaux)
 3412   continue
cgn        write (ulsort,1002) 'triangle fils 3', sq, np, lenoeu
        call utqtr0 ( quafi3, daux2, sdim, conotr )
cgn        write (ulsort,1000) 'Qualite fils 3', quafi3
cgn        write (ulsort,1000) 'Surface fils 3', daux1
c
cgn        write (ulsort,1000) 'max 1 3', max(quafi1,quafi3)
cgn        write (ulsort,1000) 'seuil  ', quaper*rapqmx
        if ( max(quafi1,quafi3).gt.quaper*rapqmx ) then
          bilan = 1
          goto 50
        endif
c
c 3.4.2. ==> Les triangles centraux
c            . Decoupage standard ou avec bascule d'aretes
c
        do 3421 , iaux = 1 , sdim
          conotr(1,iaux) = coonoe(nq,iaux)
 3421   continue
cgn        write (ulsort,1002) 'triangle fils 2', nq, np, lenoeu
        call utqtr0 ( quafi2, daux2, sdim, conotr )
cgn        write (ulsort,1000) 'Qualite fils 2', quafi2
cgn        write (ulsort,1000) 'Surface fils 2', daux1
c
        daux1 = max(quaper,quafi2)
c
c       Test de la bascule d'arete : np-nq est remplace par sn-lenoeu
c       les triangles Fils2 et Fils4 sont remplaces
c
        if ( typsfr.le.2 ) then
c
          do 3422 , iaux = 1 , sdim
            conotr(2,iaux) = coonoe(sn,iaux)
 3422     continue
cgn        write (ulsort,1002) 'triangle fils 5', nq, sn, lenoeu
          call utqtr0 ( quafi5, daux2, sdim, conotr )
cgn        write (ulsort,1000) 'Qualite fils 5', quafi5
cgn        write (ulsort,1000) 'Surface fils 5', daux1
c
          do 3423 , iaux = 1 , sdim
            conotr(1,iaux) = coonoe(np,iaux)
 3423     continue
cgn        write (ulsort,1002) 'triangle fils 6', np, sn, lenoeu
          call utqtr0 ( quafi6, daux2, sdim, conotr )
cgn        write (ulsort,1000) 'Qualite fils 6', quafi6
cgn        write (ulsort,1000) 'Surface fils 6', daux1
c
          daux2 = max(quafi6,quafi5)
c
cgn        write (ulsort,1000) 'max 5 6', daux2
cgn        write (ulsort,1000) 'max p 2', daux1
c
          if ( daux1.lt.daux2 ) then
            bascul = .false.
          else
cgn        write (ulsort,*) '- On bascule -'
            bascul = .true.
            daux1 = daux2
          endif
c
        endif
c
cgn        write (ulsort,1000) 'max 2 4', daux1
cgn        write (ulsort,1000) 'seuil  ', quaper*rapqmx
        if ( daux1.gt.quaper*rapqmx ) then
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
      write (ulsort,*) '4. test decoupage en 2 ; codret = ', codret
#endif
c
      if ( etat.eq.2 .or. typsfr.gt.2 ) then
c
        if ( codret.eq.0 ) then
c
c                            larete
c       sp                   lenoeu                      sq
c        .-----------------------.-----------------------.
c         .                      .                      .
c          .                     .                     .
c           .                    .                    .
c            .                   .                   .
c             .                  .                  .
c              .                 .                 .
c               .                .                .
c                .               .               .
c                 .              .              .
c                  .             .             .
c           areq    .            .            .   arep
c                    .           .           .
c                     .          .          .
c                      .         .         .
c                       .        .        .
c                        .       .       .
c                         .      .      .
c                          .     .     .
c                           .    .    .
c                            .   .   .
c                             .  .  .
c                              . . .
c                               ...
c                                .
c                               sn
c
c 4.1. ==> On verifie que le noeud lenoeu ne traverse pas
c          les segments sp/sn ou sq/sn
c
        do 41 , iaux = 1 , sdim
          v1(iaux) = coonoe(sp,iaux)
          v2(iaux) = coonoe(sn,iaux)
          v3(iaux) = coonoe(sq,iaux)
   41   continue
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v1, v2, v3, coopro, iaux )
        else
          call utsen3 ( memeco, v1, v2, v3, coopro, iaux )
        endif
c                               sp  sn  sq  N
cgn      write (ulsort,*) 'Du bon cote de sp/sn :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
        iaux = 0
        if ( sdim.eq.2 ) then
          call utsen2 ( memeco, v3, v2, v1, coopro, iaux )
        else
          call utsen3 ( memeco, v3, v2, v1, coopro, iaux )
        endif
c                               sq  sn  sp  N
cgn      write (ulsort,*) 'Du bon cote de sq/sn :', memeco
c
        if ( .not. memeco ) then
          bilan = 1
          goto 50
        endif
c
c 4.2. ==> Qualite future des triangles issus du decoupage
c
        do 421 , iaux = 1 , sdim
          conotr(1,iaux) = coopro(iaux)
          conotr(2,iaux) = coonoe(sq,iaux)
          conotr(3,iaux) = coonoe(sn,iaux)
  421   continue
cgn      write (ulsort,1002) 'triangle', lenoeu, sq, sn
        call utqtr0 ( quafi1, daux2, sdim, conotr )
cgn      write (ulsort,1000) 'Qualite fils 1', quafi1
c
        do 422 , iaux = 1 , sdim
          conotr(2,iaux) = coonoe(sp,iaux)
  422   continue
cgn      write (ulsort,1002) 'triangle', lenoeu, sp, sn
        call utqtr0 ( quafi2, daux2, sdim, conotr )
cgn      write (ulsort,1000) 'Qualite fils 2', quafi2
c
c       On limite le facteur d'accroissement
c
cgn        write (ulsort,1000) 'max 1 2', max(quafi1,quafi2)
cgn        write (ulsort,1000) 'seuil  ', quaper*rapqmx*2.d0 
        if ( max(quafi1,quafi2).gt.quaper*rapqmx*2.d0 ) then
          bilan = 1
          goto 50
        endif
c
      endif
c
      endif
c
c====
c 5. La fin
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
      write (ulsort,1001) mess14(langue,2, 2), letria
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
