      subroutine utvte0 ( letetr, nbtfal, nbtaal, nbtral,
     >                    somare, aretri,
     >                    tritet, cotrte, aretet,
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
c    UTilitaire - Verification d'un TEtraedre
c    --           -                 --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letetr . e   .   1    . le tetraedre a controler                   .
c . nbtfal . e   .   1    . nombre de tetrs par faces pour les allocs  .
c . nbtaal . e   .   1    . nbre de tetrs par aretes pour les allocs   .
c . nbtral . e   .   1    . nombre de triangles pour les allocations   .
c . somare . e   . 2*nbar . numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbtaal*6. numeros des 6 aretes des tetraedres        .
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
      parameter ( nompro = 'UTVTE0' )
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
      integer letetr, nbtfal, nbtaal, nbtral
      integer somare(2,*)
      integer aretri(nbtral,3)
      integer tritet(nbtfal,4), cotrte(nbtfal,4), aretet(nbtaal,8)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer f1, f2, f3, f4
      integer listar(6), listso(4)
c
      integer nbmess
      parameter ( nbmess = 10 )
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
      texte(1,4) =
     > '(''Le tetraedre '',i10,'' a des '',a,'' identiques :'',6i10)'
c
      texte(2,4) =
     > '(''Tetrahedron # '',i10,'' has got similar '',a,'':'',6i10)'
c
      codret = 0
c
c====
c 2. verification
c====
c
c 2.1. ==> les faces doivent etre differentes ...
c
      if ( letetr.le.nbtfal ) then
c
      f1 = tritet(letetr,1)
      f2 = tritet(letetr,2)
      f3 = tritet(letetr,3)
      f4 = tritet(letetr,4)
c
      if ( f1.eq.f2 .or.
     >     f1.eq.f3 .or.
     >     f1.eq.f4 .or.
     >     f2.eq.f3 .or.
     >     f2.eq.f4 .or.
     >     f3.eq.f4 ) then
        codret = 1
        write (ulsort,texte(langue,4)) letetr, mess14(langue,3,8),
     >                                 f1, f2, f3, f4
        write (ulbila,texte(langue,4)) letetr, mess14(langue,3,8),
     >                                 f1, f2, f3, f4
      endif
c
      endif
c
c 2.2. ==> les aretes doivent etre differentes ...
c
      if ( codret.eq.0 ) then
c
      call utaste ( letetr,
     >              nbtral, nbtfal, nbtaal,
     >              somare, aretri,
     >              tritet, cotrte, aretet,
     >              listar, listso )
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 221 , iaux = 1 , 5
        do 222 , jaux = iaux+1 , 6
          if ( listar(iaux).eq.listar(jaux) ) then
            codret = 1
          endif
  222  continue
  221  continue
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,4)) letetr, mess14(langue,3,1),
     >                                 (listar(iaux),iaux=1,6)
        write (ulbila,texte(langue,4)) letetr, mess14(langue,3,1),
     >                                 (listar(iaux),iaux=1,6)
      endif
c
      endif
c
c 2.3. ==> les aretes doivent etre conformes au modele HOMARD ...
c
      if ( codret.eq.0 ) then
c
      iaux = 3
      jaux = 6
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTVAR0', nompro
#endif
      call utvar0 ( iaux, letetr, jaux, listar, somare,
     >              ulbila, ulsort, langue, codret )
c
      endif
c
c 2.4. ==> les sommets doivent etre differents ...
c
      if ( codret.eq.0 ) then
c
      if ( listso(1).eq.listso(2) .or.
     >     listso(1).eq.listso(3) .or.
     >     listso(1).eq.listso(4) .or.
     >     listso(2).eq.listso(3) .or.
     >     listso(2).eq.listso(4) .or.
     >     listso(3).eq.listso(4) ) then
        codret = 1
        write (ulsort,texte(langue,4)) letetr, mess14(langue,3,-1),
     >                                 listso(1), listso(2),
     >                                 listso(3), listso(4)
        write (ulbila,texte(langue,4)) letetr, mess14(langue,3,-1),
     >                                 listso(1), listso(2),
     >                                 listso(3), listso(4)
      endif
c
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
