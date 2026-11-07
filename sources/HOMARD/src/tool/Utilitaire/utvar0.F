      subroutine utvar0 ( typver, numele, nbaret, listar, somare,
     >                    ulbila,
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
c    UTilitaire - Verification des ARetes - 0
c    --           -                --       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typver . e   .   1    . type de verification :                     .
c .        .     .        . 0 : boucle fermee                          .
c .        .     .        . -1 : continuite, ouverture aux 2 extremites.
c .        .     .        . n>0 : de l'element de type n ad-hoc        .
c . numele . e   .   1    . numero de l'element si typver = 0          .
c . nbaret . e   .   1    . nombre d'aretes a examiner                 .
c . listar . e   . nbaret . liste des aretes a examiner                .
c . somare . e   . 2*nbar . numeros des extremites d'arete             .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : pas assez d'arete dans la liste        .
c .        .     .        . 2 : mauvais type de verification           .
c .        .     .        . 10 : les aretes ne se suivent pas          .
c .        .     .        . 11 : la suite des aretes ne ferme pas      .
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
      parameter ( nompro = 'UTVAR0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typver, numele, nbaret
      integer listar(nbaret)
      integer somare(2,*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer kvoulu
      integer ulaux
      integer laret1, laret2
      integer lesom1
      integer nbaref(7)
      integer arsote(3,4)
      integer arsohe(3,8)
      integer arsopy(4,5)
      integer arsope(3,6)
      integer s1
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data nbaref / 1, 3, 6, 4, 8, 12, 9 /
c
c     Pour chaque sommet j, arsoxx(i,j) donne le numero local dec
c     la i-eme arete qui y aboutit.
c
c     pour un tetraedre :
c
c       a1 est l'arete entre s1 et s2
c       a2 est l'arete entre s1 et s3
c       a3 est l'arete entre s1 et s4
c       a4 est l'arete entre s2 et s3
c       a5 est l'arete entre s2 et s4
c       a6 est l'arete entre s3 et s4
c
      data arsote / 1, 2, 3,   1, 4, 5,   2, 4, 6,   3, 5, 6 /
c
c     pour un hexaedre :
c
c       a1 est l'arete entre s1 et s2
c       a2 est l'arete entre s1 et s4
c       a3 est l'arete entre s2 et s3
c       a4 est l'arete entre s3 et s4
c       a5 est l'arete entre s1 et s6
c       a6 est l'arete entre s2 et s5
c       a7 est l'arete entre s4 et s7
c       a8 est l'arete entre s3 et s8
c       a9 est l'arete entre s5 et s6
c       a10 est l'arete entre s6 et s7
c       a11 est l'arete entre s5 et s8
c       a12 est l'arete entre s7 et s8
c
      data arsohe / 1, 2, 5,   1, 3, 6,   3, 4, 8,    2, 4, 7,
     >              6, 9, 11,  5, 9, 10,  7, 10, 12,  8, 11, 12 /
c
c     pour une pyramide :
c
c       a1 est l'arete entre s1 et s5
c       a2 est l'arete entre s2 et s5
c       a3 est l'arete entre s3 et s5
c       a4 est l'arete entre s4 et s5
c       a5 est l'arete entre s1 et s2
c       a6 est l'arete entre s2 et s3
c       a7 est l'arete entre s3 et s4
c       a8 est l'arete entre s4 et s1
c
      data arsopy / 1, 5, 8, 0,   2, 5, 6, 0,   3, 6, 7, 0,
     >              4, 7, 8, 0,   1, 2, 3, 4 /
c
c     pour un pentaedre :
c
c       a1 est l'arete entre s1 et s3
c       a2 est l'arete entre s1 et s2
c       a3 est l'arete entre s2 et s3
c       a4 est l'arete entre s4 et s6
c       a5 est l'arete entre s4 et s5
c       a6 est l'arete entre s5 et s6
c       a7 est l'arete entre s1 et s4
c       a8 est l'arete entre s2 et s5
c       a9 est l'arete entre s3 et s6
c
      data arsope / 1, 2, 7,   2, 3, 8,   1, 3, 9,    4, 5, 7,
     >              5, 6, 8,   4, 6, 9 /
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(5x,''Controle des '',a)'
      texte(1,5) = '(''Il faut au moins 2 aretes dans la liste !'')'
      texte(1,6) = '(''Mauvais type de verification (typver) :'',i8)'
      texte(1,7) = '(/,a,'' numero'',i8)'
      texte(1,8) = '(''Nombre d''''aretes attendues :'',i8)'
      texte(1,9) = '(''Nombre d''''aretes fournies  :'',i8)'
      texte(1,10) = '(''Les aretes ne se suivent pas :'')'
      texte(1,11) = '(''La suite des aretes ne ferme pas :'')'
      texte(1,12) = '(''La suite des aretes n''''est pas conforme :'')'
      texte(1,20) = '(''Controle impossible'',/)'
c
      texte(2,4) = '(5x,''Control of the '',a)'
      texte(2,5) = '(''At least 2 edges in the list !'')'
      texte(2,6) = '(''Bad choice for checking (typver) :'',i8)'
      texte(2,7) = '(/,a,'' #'',i8)'
      texte(2,8) = '(''Number of expected edges :'',i8)'
      texte(2,9) = '(''Number of given edges    :'',i8)'
      texte(2,10) = '(''Edges are not following each other :'')'
      texte(2,11) = '(''The list of edges is not closed :'')'
      texte(2,12) = '(''The list of edges is not correct :'')'
      texte(2,20) = '(''Control cannot be done.'',/)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1)
#endif
c
      codret = 0
c
c====
c 2. verifications prealables
c====
c
c 2.1. ==> Au moins 2 aretes dans la liste !
c
      if ( nbaret.le.1 ) then
c
        write (ulsort,texte(langue,4)) mess14(langue,3,1)
        write (ulsort,texte(langue,5))
        codret = 1
c
      else
c
c 2.2. ==> Le bon code de controle
c
        if ( typver.lt.-1 .or.
     >       typver.eq.1 .or.
     >       typver.ge.8 ) then
c
          write (ulsort,texte(langue,6)) typver
          codret = 2
c
c 2.2. ==> Le bon nombre d'aretes pour un element
c
        elseif ( typver.gt.0 ) then
c
          if ( nbaret.ne.nbaref(typver) ) then
            write (ulsort,texte(langue,7)) mess14(langue,2,typver),
     >                                     numele
            write (ulsort,texte(langue,8)) nbaref(typver)
            write (ulsort,texte(langue,9)) nbaret
            codret = 3
          endif
c
        endif
c
      endif
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,20))
        write (ulbila,texte(langue,20))
      else
c
c====
c 3. verification pour un tetraedre
c====
c
#ifdef _DEBUG_HOMARD_
      if ( typver.ge.3 .and. typver.le.7 ) then
        write (ulsort,texte(langue,4)) mess14(langue,3,typver)
      endif
#endif
c
      if ( typver.eq.3 ) then
c
        iaux = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVAR1', nompro
#endif
        call utvar1 ( iaux, arsote, listar, somare,
     >                ulsort, langue, codret )
c
c====
c 4. verification pour un hexaedre
c====
c
      elseif ( typver.eq.6 ) then
c
        iaux = 8
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVAR1', nompro
#endif
        call utvar1 ( iaux, arsohe, listar, somare,
     >                ulsort, langue, codret )
c
c====
c 5. verification pour une pyramide
c====
c
      elseif ( typver.eq.5 ) then
c
        do 51 , iaux = 1 , 5
c
c         examen du iaux-eme sommet local
c
          kaux = 0
          if ( iaux.le.4 ) then
            kvoulu = 2
          else
            kvoulu = 3
          endif
c
          do 511 , jaux = 1 , 2
c
            s1 = somare(jaux,listar(arsopy(1,iaux)))
            if ( s1.eq.somare(1,listar(arsopy(2,iaux))) .or.
     >           s1.eq.somare(2,listar(arsopy(2,iaux))) ) then
              kaux = kaux + 1
            endif
            if ( s1.eq.somare(1,listar(arsopy(3,iaux))) .or.
     >           s1.eq.somare(2,listar(arsopy(3,iaux))) ) then
              kaux = kaux + 1
            endif
            if ( iaux.eq.5 ) then
              if ( s1.eq.somare(1,listar(arsopy(4,iaux))) .or.
     >             s1.eq.somare(2,listar(arsopy(4,iaux))) ) then
                kaux = kaux + 1
              endif
            endif
c
  511     continue
          if ( kaux.ne.kvoulu ) then
            codret = 12
          endif
c
   51   continue
c
c====
c 6. verification pour un pentaedre
c====
c
      elseif ( typver.eq.7 ) then
c
        iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVAR1', nompro
#endif
        call utvar1 ( iaux, arsope, listar, somare,
     >                ulsort, langue, codret )
c
c====
c 7. verification de continuite pour les autres types d'element
c====
c
      else
c
c 7.1. ==> recherche du premier sommet
c
        laret1 = listar(1)
        laret2 = listar(2)
        if ( somare(1,laret1).eq.somare(1,laret2) ) then
          lesom1 = somare(2,laret1)
          jaux = 2
        elseif ( somare(1,laret1).eq.somare(2,laret2) ) then
          lesom1 = somare(2,laret1)
          jaux = 1
        elseif ( somare(2,laret1).eq.somare(1,laret2) ) then
          lesom1 = somare(1,laret1)
          jaux = 2
        elseif ( somare(2,laret1).eq.somare(2,laret2) ) then
          lesom1 = somare(1,laret1)
          jaux = 1
        else
          codret = 10
        endif
c
c 7.2. ==> poursuite de la liste
c
        do 72 , iaux = 3 , nbaret
c
          if ( codret.eq.0 ) then
c
            laret1 = laret2
            laret2 = listar(iaux)
c
            if ( somare(jaux,laret1).eq.somare(1,laret2) ) then
              jaux = 2
            elseif ( somare(jaux,laret1).eq.somare(2,laret2) ) then
              jaux = 1
            else
              codret = 10
            endif
c
          endif
c
   72 continue
c
c 7.3. ==> bouclage
c
        if ( typver.ge.0 ) then
          if ( lesom1.ne.somare(jaux,laret2) ) then
            codret = 11
          endif
        endif
c
      endif
c
      endif
cgn      if ( mod(numele,2).eq.0)codret=10
c
c====
c 8. impressions en cas d'erreur
c====
c
      if ( codret.ne.0 ) then
c
      if ( ulsort.ne.ulbila ) then
        jaux = 2
      else
        jaux = 1
      endif
c
      do 81 , kaux = 1 , jaux
c
        if ( kaux.eq.1 ) then
          ulaux = ulsort
        else
          ulaux = ulbila
        endif
c
        if ( typver.gt.0 ) then
          write (ulaux,texte(langue,7)) mess14(langue,2,typver), numele
        endif
        if ( codret.ge.10 ) then
          write (ulaux,texte(langue,codret))
        endif
c
        write (ulaux,8000) mess14(langue,2,1),
     >                      mess14(langue,2,-1), mess14(langue,2,-1)
        do 810 , iaux = 1 , nbaret
          laret1 = listar(iaux)
          write (ulaux,8001) laret1, somare(1,laret1), somare(2,laret1)
  810   continue
        write (ulaux,8002)
c
   81 continue
c
 8000 format(
     >/,53('*')
     >/,'* ',a14,'* ',a14,'1 * ',a14,'2 *'
     >/, 53('*'))
 8001 format('*',i10,'     *',2(i10,'       *'))
 8002 format(53('*'),/)
c
      endif
c
c====
c 9. la fin
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
