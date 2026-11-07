      subroutine utequa ( nbquto, nbqual, nbnoal, sdim,
     >                    coonoe, somare, arequa,
     >                    nmprog, avappr, ulbila,
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
c    UTilitaire - Examen des QUAdrangles
c    --           -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbquto . e   .   1    . nombre de quadrangles a examiner           .
c . nbqual . e   .   1    . nombre de quadrangles pour les allocations .
c . nbnoal . e   .   1    . nombre de noeuds pour les allocations      .
c . sdim   . e   .   1    . dimension du maillage                      .
c . coonoe . e   . nbnoal . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   . 2*nbar . numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nmprog . e   . char*  . nom du programme a pister                  .
c . avappr . e   .   1    . 1 : impression avant l'appel a "nmprog"    .
c .        .     .        . 2 : impression apres l'appel a "nmprog"    .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . >0 : probleme dans le controle             .
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
      parameter ( nompro = 'UTEQUA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbquto, nbqual, nbnoal, sdim
      integer somare(2,*)
      integer arequa(nbqual,4)
c
      double precision coonoe(nbnoal,sdim)
c
      character*(*) nmprog
c
      integer avappr
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre0
      integer iaux, jaux, kaux, laux
      integer ulaux
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
      integer listar(4)
c
      double precision v1(3), v2(3), v3(3), v4(3)
      double precision v12(3), v34(3)
      double precision daux
c
      character*1 saux01(3)
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data saux01 / 'x', 'y', 'z' /
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
      texte(1,5) = '(5x,''Controle des '',i10,1x,a)'
      texte(1,6) = '(a,'' numero '',i10)'
      texte(1,7) = '(''Les '',a,'' sont :'',4i10)'
      texte(1,8) = '(''Les '',a,'' sont confondus :'',4i10)'
      texte(1,10) = '(''Le '',a,'' est croise.'')'
      texte(1,16) =
     > '(5x,''Pas de probleme dans la definition des quadrangles'',/)'
      texte(1,17) = '(/,''Mauvais code pour '',a,'' : '',i10,/)'
      texte(1,18) = '(/,''.. A l''''entree de '',a,'' :'',/)'
      texte(1,19) = '(/,''.. Avant appel a '',a,'' :'',/)'
      texte(1,20) = '(/,''.. Apres appel a '',a,'' :'',/)'
c
      texte(2,5) = '(5x,''Control of '',i10,1x,a)'
      texte(2,6) = '(a,'' # '',i10)'
      texte(2,7) = '(''The '',a,'' are :'',4i10)'
      texte(2,8) = '(''The '',a,'' are similar :'',4i10)'
      texte(2,10) = '(''The '',a,'' is overlapped.'')'
      texte(2,16) = '(5x,''No problem with quadrangle definition'',/)'
      texte(2,17) = '(/,''Bad code for '',a,'' : '',i10,/)'
      texte(2,18) = '(/,''.. At the beginning of '',a,'' :'',/)'
      texte(2,19) = '(/,''.. Before calling '',a,'' :'',/)'
      texte(2,20) = '(/,''.. After calling '',a,'' :'',/)'
c
 1000 format('Arete a',i1,' :',i10,' de',i10,' a',i10)
 1001 format('Noeud',i10,' :', 3(2x,a,' =',g12.5) )
c
#ifdef _DEBUG_HOMARD_
      if ( avappr.ge.0 .and. avappr.le.2 ) then
        write (ulsort,texte(langue,18+avappr)) nmprog
      else
        write (ulsort,texte(langue,17)) nmprog, avappr
      endif
#endif
      write (ulsort,texte(langue,5)) nbquto, mess14(langue,3,4)
c
c 1.3. ==> constantes
c
      codret = 0
c
c====
c 2. verification
c====
c
ccc      do 20 , iaux = 1 , nbquto
      do 20 , iaux = 1 , 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,2,4), iaux
#endif
c
        codre0 = 0
c
c 2.1. ==> les aretes doivent etre differentes ...
c
        a1 = arequa(iaux,1)
        a2 = arequa(iaux,2)
        a3 = arequa(iaux,3)
        a4 = arequa(iaux,4)
c
        if ( a1.eq.a2 .or.
     >       a1.eq.a3 .or.
     >       a1.eq.a4 .or.
     >       a2.eq.a3 .or.
     >       a2.eq.a4 .or.
     >       a3.eq.a4 ) then
          codre0 = 1
          write (ulsort,texte(langue,6)) mess14(langue,2,4), iaux
          write (ulsort,texte(langue,8)) mess14(langue,3,1), a1,a2,a3,a4
          write (ulbila,texte(langue,6)) mess14(langue,2,4), iaux
          write (ulbila,texte(langue,8)) mess14(langue,3,1), a1,a2,a3,a4
        endif
c
c 2.2. ==> les aretes doivent se suivre ...
c
        if ( codre0.eq.0 ) then
c
        listar(1) = a1
        listar(2) = a2
        listar(3) = a3
        listar(4) = a4
        jaux = 4
        kaux = 4
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVAR0', nompro
#endif
        call utvar0 ( jaux, iaux, kaux, listar, somare,
     >                ulbila, ulsort, langue, codre0 )
c
        endif
c
c 2.3. ==> les sommets doivent etre differents ...
c
        if ( codre0.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSOQU', nompro
#endif
        call utsoqu ( somare, a1, a2, a3, a4,
     >                sa1a2, sa2a3, sa3a4, sa4a1 )
c
        if ( sa1a2.eq.sa2a3 .or.
     >       sa1a2.eq.sa3a4 .or.
     >       sa1a2.eq.sa4a1 .or.
     >       sa2a3.eq.sa3a4 .or.
     >       sa2a3.eq.sa4a1 .or.
     >       sa1a2.eq.sa4a1 ) then
c
          codre0 = 1
c
          if ( ulsort.ne.ulbila ) then
            jaux = 2
          else
            jaux = 1
          endif
c
          do 23 , kaux = 1 , jaux
c
            if ( kaux.eq.1 ) then
              ulaux = ulsort
            else
              ulaux = ulbila
            endif
c
            write (ulaux,texte(langue,8)) mess14(langue,3,-1),
     >                                    sa1a2, sa2a3, sa3a4, sa4a1
            write(ulaux,*) 'a1',somare(1,a1),somare(2,a1)
            write(ulaux,*) coonoe(somare(1,a1),1),coonoe(somare(1,a1),2)
     >           ,coonoe(somare(1,a1),3)
            write(ulaux,*) coonoe(somare(2,a1),1),coonoe(somare(2,a1),2)
     >           ,coonoe(somare(2,a1),3)
            write(ulaux,*) 'a2',somare(1,a2),somare(2,a2)
            write(ulaux,*) coonoe(somare(1,a2),1),coonoe(somare(1,a2),2)
     >           ,coonoe(somare(1,a2),3)
            write(ulaux,*) coonoe(somare(2,a2),1),coonoe(somare(2,a2),2)
     >           ,coonoe(somare(2,a2),3)
            write(ulaux,*) 'a3',somare(1,a3),somare(2,a3)
            write(ulaux,*) coonoe(somare(1,a3),1),coonoe(somare(1,a3),2)
     >           ,coonoe(somare(1,a3),3)
            write(ulaux,*) coonoe(somare(2,a3),1),coonoe(somare(2,a3),2)
     >           ,coonoe(somare(2,a3),3)
            write(ulaux,*) 'a4',somare(1,a4),somare(2,a4)
            write(ulaux,*) coonoe(somare(1,a4),1),coonoe(somare(1,a4),2)
     >           ,coonoe(somare(1,a4),3)
            write(ulaux,*) coonoe(somare(2,a4),1),coonoe(somare(2,a4),2)
     >           ,coonoe(somare(2,a4),3)
            write(ulaux,*) coonoe(sa1a2,1), coonoe(sa1a2,2),
     >           coonoe(sa1a2,3)
            write(ulaux,*) coonoe(sa2a3,1), coonoe(sa2a3,2),
     >           coonoe(sa2a3,3)
            write(ulaux,*) coonoe(sa3a4,1), coonoe(sa3a4,2),
     >           coonoe(sa3a4,3)
            write(ulaux,*) coonoe(sa4a1,1), coonoe(sa4a1,2),
     >           coonoe(sa4a1,3)
c
   23     continue
c
        endif
c
        endif
c
c 2.4. ==> il ne faut pas croiser ...
c          pour cela, il faut que les deux produits vectoriels
c          a1xa2 et a3xa4 soient dans la meme orientation. On teste
c          si leur produit scalaire est >0
c          Remarque : cela suppose que le quadrangle est plan
c
c               sa4a1  a4  sa3a4             sa4a1      sa2a3 
c                   ._______.                     .       .
c                   .       .                     ..     ..
c                   .       .                     . .a4 . .
c                 a1.       .a3                 a1.  . .  .a3
c                   .       .                     .   .   .
c                   .       .                     .  . .  .
c                   .       .                     . .   . .
c                   .       .                     .. a2  ..
c                   ._______.                     .       .
c               sa1a2   a2  sa2a3            sa1a2     sa3a4
c
c
        if ( codre0.eq.0 ) then
c
        if ( sdim.eq.2 ) then
c
          v1(1)    = coonoe(sa4a1,1) - coonoe(sa1a2,1)
          v1(2)    = coonoe(sa4a1,2) - coonoe(sa1a2,2)
c
          v2(1)    = coonoe(sa2a3,1) - coonoe(sa1a2,1)
          v2(2)    = coonoe(sa2a3,2) - coonoe(sa1a2,2)
c
          v3(1)    = coonoe(sa2a3,1) - coonoe(sa3a4,1)
          v3(2)    = coonoe(sa2a3,2) - coonoe(sa3a4,2)
c
          v4(1)    = coonoe(sa4a1,1) - coonoe(sa3a4,1)
          v4(2)    = coonoe(sa4a1,2) - coonoe(sa3a4,2)
c
c         v12 represente le produit vectoriel a1xa2.
c
          v12(3) = v1(1)*v2(2) - v1(2)*v2(1)
c
c         v34 represente le produit vectoriel a3xa4.
c
          v34(3) = v3(1)*v4(2) - v3(2)*v4(1)
c
          daux = v12(3)*v34(3)
c
#ifdef _DEBUG_HOMARD_
          if ( iaux.eq.1 ) then
          write (ulsort,texte(langue,7)) mess14(langue,3,-1),
     >                                   sa1a2, sa2a3, sa3a4, sa4a1
          write (ulsort,1001) sa1a2,
     >                  (saux01(laux),coonoe(sa1a2,laux),laux=1,sdim)
          write (ulsort,1001) sa2a3,
     >                  (saux01(laux),coonoe(sa2a3,laux),laux=1,sdim)
          write (ulsort,1001) sa3a4,
     >                  (saux01(laux),coonoe(sa3a4,laux),laux=1,sdim)
          write (ulsort,1001) sa4a1,
     >                  (saux01(laux),coonoe(sa4a1,laux),laux=1,sdim)
          write (ulsort,*) ' '
          write (ulsort,1789) 'v1', v1(1), v1(2)
          write (ulsort,1789) 'v2', v2(1), v2(2)
          write (ulsort,1789) 'v3', v3(1), v3(2)
          write (ulsort,1789) 'v4', v4(1), v4(2)
          write (ulsort,*) ' '
          write (ulsort,1789) 'v12(3) = ', v12(3)
          write (ulsort,1789) 'v34(3) = ', v34(3)
          write (ulsort,1789) ' ==> daux =',daux
          endif
 1789 format(a,' : ',2g13.5,a,g13.5)
#endif
c
        else
c
          v1(1)    = coonoe(sa4a1,1) - coonoe(sa1a2,1)
          v1(2)    = coonoe(sa4a1,2) - coonoe(sa1a2,2)
          v1(3)    = coonoe(sa4a1,3) - coonoe(sa1a2,3)
c
          v2(1)    = coonoe(sa2a3,1) - coonoe(sa1a2,1)
          v2(2)    = coonoe(sa2a3,2) - coonoe(sa1a2,2)
          v2(3)    = coonoe(sa2a3,3) - coonoe(sa1a2,3)
c
          v3(1)    = coonoe(sa2a3,1) - coonoe(sa3a4,1)
          v3(2)    = coonoe(sa2a3,2) - coonoe(sa3a4,2)
          v3(3)    = coonoe(sa2a3,3) - coonoe(sa3a4,3)
c
          v4(1)    = coonoe(sa4a1,1) - coonoe(sa3a4,1)
          v4(2)    = coonoe(sa4a1,2) - coonoe(sa3a4,2)
          v4(3)    = coonoe(sa4a1,3) - coonoe(sa3a4,3)
c
c         v12 represente le produit vectoriel a1xa2.
c
          v12(1) = v1(2)*v2(3) - v1(3)*v2(2)
          v12(2) = v1(3)*v2(1) - v1(1)*v2(3)
          v12(3) = v1(1)*v2(2) - v1(2)*v2(1)
c
c         v34 represente le produit vectoriel a3xa4.
c
          v34(1) = v3(2)*v4(3) - v3(3)*v4(2)
          v34(2) = v3(3)*v4(1) - v3(1)*v4(3)
          v34(3) = v3(1)*v4(2) - v3(2)*v4(1)
c
          daux = v12(1)*v34(1) + v12(2)*v34(2) + v12(3)*v34(3)
c
#ifdef _DEBUG_HOMARD_
          if ( iaux.eq.1 ) then
          write (ulsort,texte(langue,7)) mess14(langue,3,-1),
     >                                   sa1a2, sa2a3, sa3a4, sa4a1
          write (ulsort,1001) sa1a2,
     >                  (saux01(laux),coonoe(sa1a2,laux),laux=1,sdim)
          write (ulsort,1001) sa2a3,
     >                  (saux01(laux),coonoe(sa2a3,laux),laux=1,sdim)
          write (ulsort,1001) sa3a4,
     >                  (saux01(laux),coonoe(sa3a4,laux),laux=1,sdim)
          write (ulsort,1001) sa4a1,
     >                  (saux01(laux),coonoe(sa4a1,laux),laux=1,sdim)
          write (ulsort,*) ' '
          write (ulsort,1792) 'v1', v1(1), v1(2)
          write (ulsort,1792) 'v2', v2(1), v2(2)
          write (ulsort,1792) 'v3', v3(1), v3(2)
          write (ulsort,1792) 'v4', v4(1), v4(2)
          write (ulsort,*) ' '
          write (ulsort,1792) 'v12(1) = ', v12(1)
          write (ulsort,1792) 'v12(2) = ', v12(2)
          write (ulsort,1792) 'v12(3) = ', v12(3)
          write (ulsort,1792) 'v34(1) = ', v34(1)
          write (ulsort,1792) 'v34(2) = ', v34(2)
          write (ulsort,1792) 'v34(3) = ', v34(3)
          write (ulsort,1792) ' ==> daux =',daux
          endif
 1792 format(a,' : ',2g13.5,a,g13.5)
#endif
c
        endif
c
        if ( daux.le.0.d0 ) then
c
          codre0 = 1
c
          if ( ulsort.ne.ulbila ) then
            jaux = 2
          else
            jaux = 1
          endif
c
          do 24 , kaux = 1 , jaux
c
            if ( kaux.eq.1 ) then
              ulaux = ulsort
            else
              ulaux = ulbila
            endif
c
            write (ulaux,texte(langue,6)) mess14(langue,2,4), iaux
            write (ulaux,texte(langue,7)) mess14(langue,3,-1),
     >                                   sa1a2, sa2a3, sa3a4, sa4a1
            write (ulaux,texte(langue,10)) mess14(langue,1,4)
            write(ulaux,1001) sa1a2,
     >                    (saux01(laux),coonoe(sa1a2,laux),laux=1,sdim)
            write(ulaux,1001) sa2a3,
     >                    (saux01(laux),coonoe(sa2a3,laux),laux=1,sdim)
            write(ulaux,1001) sa3a4,
     >                    (saux01(laux),coonoe(sa3a4,laux),laux=1,sdim)
            write(ulaux,1001) sa4a1,
     >                    (saux01(laux),coonoe(sa4a1,laux),laux=1,sdim)
cgn            write(ulaux,*) coonoe(sa1a2,1), coonoe(sa1a2,2),
cgn     >                     coonoe(sa1a2,3)
cgn            write(ulaux,*) coonoe(sa2a3,1), coonoe(sa2a3,2),
cgn     >                     coonoe(sa2a3,3)
cgn            write(ulaux,*) coonoe(sa3a4,1), coonoe(sa3a4,2),
cgn     >                     coonoe(sa3a4,3)
cgn            write(ulaux,*) coonoe(sa4a1,1), coonoe(sa4a1,2),
cgn     >                     coonoe(sa4a1,3)
            write(ulaux,1000) 1,a1,somare(1,a1),somare(2,a1)
cgn            write(ulaux,1001) somare(1,a1),coonoe(somare(1,a1),1),
cgn     >           coonoe(somare(1,a1),2),coonoe(somare(1,a1),3)
cgn            write(ulaux,1001) somare(2,a1),coonoe(somare(2,a1),1),
cgn     >           coonoe(somare(2,a1),2),coonoe(somare(2,a1),3)
            write(ulaux,1000) 2,a2,somare(1,a2),somare(2,a2)
cgn            write(ulaux,1001) somare(1,a2),coonoe(somare(1,a2),1),
cgn     >           coonoe(somare(1,a2),2),coonoe(somare(1,a2),3)
cgn            write(ulaux,1001) somare(2,a2),coonoe(somare(2,a2),1),
cgn     >           coonoe(somare(2,a2),2),coonoe(somare(2,a2),3)
            write(ulaux,1000) 3,a3,somare(1,a3),somare(2,a3)
cgn            write(ulaux,1001) somare(1,a3), coonoe(somare(1,a3),1),
cgn     >           coonoe(somare(1,a3),2),coonoe(somare(1,a3),3)
cgn            write(ulaux,1001) somare(2,a3), coonoe(somare(2,a3),1),
cgn     >           coonoe(somare(2,a3),2),coonoe(somare(2,a3),3)
            write(ulaux,1000) 4,a4,somare(1,a4),somare(2,a4)
cgn            write(ulaux,1001) somare(1,a4), coonoe(somare(1,a4),1),
cgn     >           coonoe(somare(1,a4),2),coonoe(somare(1,a4),3)
cgn            write(ulaux,1001) somare(2,a4), coonoe(somare(2,a4),1),
cgn     >           coonoe(somare(2,a4),2),coonoe(somare(2,a4),3)
c
   24     continue
c
        endif
c
        endif
c
c 2.5. ==> cumul des erreurs
c
        codret = codret + codre0
c
   20 continue
c
c 2.6. ==> tout va bien
c
      if ( codret.eq.0 ) then
        write (ulsort,texte(langue,16))
        write (ulbila,texte(langue,16))
      endif
c
c====
c 3. la fin
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
