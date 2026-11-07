      subroutine utepyr ( nbpyto, nbyfal, nbyaal, nbtral,
     >                    somare, aretri,
     >                    facpyr, cofapy, arepyr,
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
c    UTilitaire - Examen des PYRamides
c    --           -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbpyto . e   .   1    . nombre de pyramides a examiner             .
c . nbyfal . e   .   1    . nbre de pyras par faces pour les allocs    .
c . nbyaal . e   .   1    . nbre de pyras par aretes pour les allocs   .
c . nbtral . e   .   1    . nombre de triangles pour les allocations   .
c . somare . e   . 2*nbar . numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . arepyr . e   .nbyaal*8. numeros des 8 aretes des pyramides         .
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
      parameter ( nompro = 'UTEPYR' )
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
      integer nbpyto, nbyfal, nbyaal, nbtral
      integer somare(2,*)
      integer aretri(nbtral,4)
      integer facpyr(nbyfal,5), cofapy(nbyfal,5), arepyr(nbyaal,8)
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
      integer nbpyal
      integer lapyra, lapyr0
      integer f1, f2, f3, f4
      integer listar(8), listso(5)
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,6) = '(5x,''Controle des '',i10,'' pyramides.'')'
      texte(1,7) =
     > '(''La pyramide '',i10,'' a des '',a,'' identiques :'',12i10)'
      texte(1,10) =
     > '(''Les aretes de la pyramide '',i10,'' ne se suivent pas.'')'
      texte(1,16) =
     > '(5x,''Pas de probleme dans la definition des pyramides'',/)'
      texte(1,17) = '(/,''Mauvais code pour '',a,'' : '',i10,/)'
      texte(1,18) = '(/,''.. A l''''entree de '',a,'' :'',/)'
      texte(1,19) = '(/,''.. Avant appel a '',a,'' :'',/)'
      texte(1,20) = '(/,''.. Apres appel a '',a,'' :'',/)'
c
      texte(2,6) = '(5x,''Control of '',i10,'' pyramids.'')'
      texte(2,7) =
     > '(''Pyramid # '',i10,'' has got similar '',a,'':'',12i10)'
      texte(2,10) =
     > '(''Edges of pyramid '',i10,'' are not following.'')'
      texte(2,16) = '(5x,''No problem with pyramid definition'',/)'
      texte(2,17) = '(/,''Bad code for '',a,'' : '',i10,/)'
      texte(2,18) = '(/,''.. At the beginning of '',a,'' :'',/)'
      texte(2,19) = '(/,''.. Before calling '',a,'' :'',/)'
      texte(2,20) = '(/,''.. After calling '',a,'' :'',/)'
c
#ifdef _DEBUG_HOMARD_
      if ( avappr.ge.0 .and. avappr.le.2 ) then
        write (ulsort,texte(langue,18+avappr)) nmprog
      else
        write (ulsort,texte(langue,17)) nmprog, avappr
      endif
#endif
      write (ulsort,texte(langue,6)) nbpyto
cgn      write (ulsort,*) nbyfal, nbyaal
c
c 1.3. ==> constantes
c
      codret = 0
c
c====
c 2. verification
c====
c
      nbpyal = nbyfal + nbyaal
c
      do 20 , lapyr0 = 1 , nbpyto
c
        lapyra = lapyr0
c
        codre0 = 0
c
c 2.1. ==> les faces doivent etre differentes ...
c
        if ( lapyra.le.nbyfal ) then
c
          f1 = facpyr(lapyra,1)
          f2 = facpyr(lapyra,2)
          f3 = facpyr(lapyra,3)
          f4 = facpyr(lapyra,4)
c
          if ( f1.eq.f2 .or.
     >         f1.eq.f3 .or.
     >         f1.eq.f4 .or.
     >         f2.eq.f3 .or.
     >         f2.eq.f4 .or.
     >         f3.eq.f4 ) then
            codre0 = 1
            write (ulsort,texte(langue,7)) lapyra, mess14(langue,3,2),
     >                                     f1, f2, f3, f4
            write (ulbila,texte(langue,7)) lapyra, mess14(langue,3,2),
     >                                     f1, f2, f3, f4
          endif
c
        endif
c
c 2.2. ==> les aretes doivent etre differentes ...
c
        if ( codre0.eq.0 ) then
c
        call utaspy ( lapyra,
     >                nbtral, nbyfal, nbyaal,
     >                somare, aretri,
     >                facpyr, cofapy, arepyr,
     >                listar, listso )
c
        endif
c
        if ( codre0.eq.0 ) then
c
        do 221 , iaux = 1 , 7
          do 222 , jaux = iaux+1 , 8
            if ( listar(iaux).eq.listar(jaux) ) then
              codre0 = 1
            endif
  222    continue
  221    continue
c
        if ( codre0.ne.0 ) then
          write (ulsort,texte(langue,7)) lapyra, mess14(langue,3,1),
     >                                   (listar(iaux),iaux=1,8)
          write (ulbila,texte(langue,7)) lapyra, mess14(langue,3,1),
     >                                   (listar(iaux),iaux=1,8)
        endif
c
        endif
c
c 2.3. ==> les aretes doivent etre conformes au modele HOMARD ...
c
        if ( codre0.eq.0 ) then
c
        iaux = 5
        jaux = 8
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVAR0', nompro
#endif
        call utvar0 ( iaux, lapyra, jaux, listar, somare,
     >                ulbila, ulsort, langue, codre0 )
c
        endif
c
c 2.4. ==> les sommets doivent etre differents ...
c
        if ( codre0.eq.0 ) then
c
        do 24 , iaux = 1 , 4
          do 241 , jaux = iaux+1 , 5
            if ( listso(iaux).eq.listso(jaux) ) then
              codre0 = 1
            endif
  241    continue
   24    continue
c
        if ( codre0.ne.0 ) then
          write (ulsort,texte(langue,7)) lapyra, mess14(langue,3,-1),
     >                                   (listso(iaux),iaux=1,5)
          write (ulbila,texte(langue,7)) lapyra, mess14(langue,3,-1),
     >                                   (listso(iaux),iaux=1,5)
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
