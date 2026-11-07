      subroutine utehex ( nbheto, nbhfal, nbhaal, nbqual,
     >                    somare, arequa,
     >                    quahex, coquhe, arehex,
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
c    UTilitaire - Examen des HEXaedres
c    --           -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbheto . e   .   1    . nombre de hexaedres a examiner             .
c . nbhfal . e   .   1    . nombre de hexas par faces pour les allocs  .
c . nbhaal . e   .   1    . nbre de hexas par aretes pour les allocs   .
c . nbqual . e   .   1    . nombre de quadrangles pour les allocations .
c . somare . e   . 2*nbar . numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. code des 6 quadrangles des hexaedres       .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . nmprog . e   . char*  . nom du programme a pister                  .
c . avappr . e   .   1    . 1 : impression avant l'appel a "nmprog"    .
c .        .     .        . 2 : impression apres l'appel a "nmprog"    .
c . ulbila . e   .   1    . unite logitee d'ecriture du bilan          .
c . ulsort . e   .   1    . numero d'unite logitee de la liste standard.
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
      parameter ( nompro = 'UTEHEX' )
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
      integer nbheto, nbhfal, nbhaal, nbqual
      integer somare(2,*)
      integer arequa(nbqual,4)
      integer quahex(nbhfal,6), coquhe(nbhfal,6), arehex(nbhaal,12)
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
      integer iaux, jaux
      integer lehexa, lehex0
      integer f1, f2, f3, f4, f5, f6
      integer listar(12), listso(8)
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
      texte(1,6) = '(5x,''Controle des '',i10,'' hexaedres.'')'
      texte(1,7) =
     > '(''L''''hexaedre '',i10,'' a des '',a,'' identiques :'',12i10)'
      texte(1,10) =
     > '(''Les aretes de l''''hexaedre '',i10,'' ne se suivent pas.'')'
      texte(1,16) =
     > '(5x,''Pas de probleme dans la definition des hexaedres'',/)'
      texte(1,17) = '(/,''Mauvais code pour '',a,'' : '',i10,/)'
      texte(1,18) = '(/,''.. A l''''entree de '',a,'' :'',/)'
      texte(1,19) = '(/,''.. Avant appel a '',a,'' :'',/)'
      texte(1,20) = '(/,''.. Apres appel a '',a,'' :'',/)'
c
      texte(2,6) = '(5x,''Control of '',i10,'' hexahedrons.'')'
      texte(2,7) =
     > '(''Hexahedron # '',i10,'' has got similar '',a,'':'',12i10)'
      texte(2,10) =
     > '(''Edges of hexahedron '',i10,'' are not following.'')'
      texte(2,16) = '(5x,''No problem with hexaedra definition'',/)'
      texte(2,17) = '(/,''Bad code for '',a,'' : '',i10,/)'
      texte(2,18) = '(/,''.. At the beginning of '',a,'' :'',/)'
      texte(2,19) = '(/,''.. Before calling '',a,'' :'',/)'
      texte(2,20) = '(/,''.. After calling '',a,'' :'',/)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      if ( avappr.ge.0 .and. avappr.le.2 ) then
        write (ulsort,texte(langue,18+avappr)) nmprog
      else
        write (ulsort,texte(langue,17)) nmprog, avappr
      endif
#endif
      write (ulsort,texte(langue,6)) nbheto
c
      codret = 0
c
c====
c 2. verification
c====
c
      do 20 , lehex0 = 1 , nbheto
c
        lehexa = lehex0
c
        codre0 = 0
c
c 2.1. ==> les faces doivent etre differentes ...
c
        if ( lehexa.le.nbhfal ) then
c
          f1 = quahex(lehexa,1)
          f2 = quahex(lehexa,2)
          f3 = quahex(lehexa,3)
          f4 = quahex(lehexa,4)
          f5 = quahex(lehexa,5)
          f6 = quahex(lehexa,6)
c
          if ( f1.eq.f2 .or.
     >         f1.eq.f3 .or.
     >         f1.eq.f4 .or.
     >         f1.eq.f5 .or.
     >         f1.eq.f6 .or.
     >         f2.eq.f3 .or.
     >         f2.eq.f4 .or.
     >         f2.eq.f5 .or.
     >         f2.eq.f6 .or.
     >         f3.eq.f4 .or.
     >         f3.eq.f5 .or.
     >         f3.eq.f6 .or.
     >         f4.eq.f5 .or.
     >         f4.eq.f6 .or.
     >         f5.eq.f6 ) then
            codre0 = 1
            write (ulsort,texte(langue,7)) lehexa, mess14(langue,3,8),
     >                                     f1, f2, f3, f4, f5, f6
            write (ulbila,texte(langue,7)) lehexa, mess14(langue,3,8),
     >                                     f1, f2, f3, f4, f5, f6
          endif
c
        endif
c
c 2.2. ==> les aretes doivent etre differentes ...
c
        if ( codre0.eq.0 ) then
c
        call utashe ( lehexa,
     >                nbqual, nbhfal, nbhaal,
     >                somare, arequa,
     >                quahex, coquhe, arehex,
     >                listar, listso )
c
        endif
c
        if ( codre0.eq.0 ) then
c
        do 22 , iaux = 1 , 11
          do 221 , jaux = iaux+1 , 12
            if ( listar(iaux).eq.listar(jaux) ) then
              codre0 = 1
            endif
  221    continue
   22    continue
c
        if ( codre0.ne.0 ) then
          write (ulsort,texte(langue,7)) lehexa, mess14(langue,3,1),
     >                                   (listar(iaux),iaux=1,12)
          write (ulbila,texte(langue,7)) lehexa, mess14(langue,3,1),
     >                                   (listar(iaux),iaux=1,12)
        endif
c
        endif
c
c 2.3. ==> les aretes doivent etre conformes au modele HOMARD ...
c
        if ( codre0.eq.0 ) then
c
        iaux = 6
        jaux = 12
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVAR0', nompro
#endif
        call utvar0 ( iaux, lehexa, jaux, listar, somare,
     >                ulbila, ulsort, langue, codre0 )
c
        endif
c
c 2.4. ==> les sommets doivent etre differents ...
c
        if ( codre0.eq.0 ) then
c
        do 24 , iaux = 1 , 7
          do 241 , jaux = iaux+1 , 8
            if ( listso(iaux).eq.listso(jaux) ) then
              codre0 = 1
            endif
  241    continue
   24    continue
c
        if ( codre0.ne.0 ) then
          write (ulsort,texte(langue,7)) lehexa, mess14(langue,3,-1),
     >                                   (listso(iaux),iaux=1,8)
          write (ulbila,texte(langue,7)) lehexa, mess14(langue,3,-1),
     >                                   (listso(iaux),iaux=1,8)
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
