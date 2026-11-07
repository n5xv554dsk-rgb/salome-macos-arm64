      subroutine pcfaa3 ( nbblqu, nbfold, nbfnew, numfam,
     >                    nromat, numboi, nbattr, attri, descri,
     >                    ptabne, vattne,
     >                    nufmne, nofmne, descne,
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
c    aPres adaptation - Conversion - FAmilles pour ATHENA - Phase 3
c     -                 -            --            -              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbblqu . e   .   1    . nombre de blocs                            .
c . nbfold . e   .   1    . ancien nombre de familles MED              .
c . nbfnew . es  .   1    . nombre de nouvelles familles MED           .
c . numfam . es  .   1    . numero de la famille MED a creer           .
c . nromat . e   .   1    . numero du materiau de la boite             .
c . numboi . e   .   1    . numero de la boite                         .
c . nbattr . e   .   1    . nombre d'attributs decrivant les familles  .
c . attri  . e   .char*200. les caracteristiques immuables             .
c . descri . e   .char*200. les caracteristiques immuables             .
c . ptabne .   s .   *    . pointeur dans tables d'attributs (nouveau) .
c . vattne .   s .   *    . table des valeurs des attributs (nouveau)  .
c . nufmne .   s .   *    . numero de la famille MED (nouveau)         .
c . nofmne .   s .   *    . nom de la famille MED (nouveau)            .
c . descne .   s .   *    . description des attributs (nouveau)        .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'PCFAA3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbblqu, nbfold, nbfnew, numfam
      integer nromat, numboi, nbattr
c
      integer attri(nbattr)
      integer ptabne(0:*)
      integer vattne(*)
      integer nufmne(*)
c
      character*8 nofmne(*)
      character*8 descne(*)
      character*200 descri(nbattr)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer adrnew
c
      character*8 saux08
#ifdef _DEBUG_HOMARD_
      character*64 saux64
#endif
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
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
      texte(1,4) =
     >'(a,'' de la'',i6''-ieme famille MED, de numero'',i6)'
      texte(1,5) = '(/,''Nombre de familles MED crees : '',i8)'
      texte(1,6) = '(''Ce nombre est superieur au maximum :'',i8)'
      texte(1,8) = '(''Modifier le programme UTINCG'',/)'
      texte(1,7) = '(''Modifier le programme PCFAAT'',/)'
      texte(1,9) = '(/,''.. Bloc numero'',i6,/)'
      texte(1,10) = '(''Impossible de trouver la famille du pere'')'
      texte(1,11) = '(''Impossible de trouver le materiau du pere'')'
c
      texte(2,4) =
     >'(a,'' of the'',i6,''th MED family, with #'',i6)'
      texte(2,5) = '(/,''Number of created MED families : '',i8)'
      texte(2,6) = '(''This number is greater than maximum :'',i8)'
      texte(2,7) = '(''Modify PCFAAT program.'',/)'
      texte(2,8) = '(''Modify UTINCG program.'',/)'
      texte(2,9) = '(/,''.. Block #'',i6,/)'
      texte(2,10) = '(''Father family cannot be found.'')'
      texte(2,11) = '(''Father material cannot be found.'')'
c
cgn 1004 format(4i6)
cgn 2000 format('.... ',a,' = ',10i6)
c
      codret = 0
c
c====
c 2. creation d'une nouvelle famille med
c====
c
c 2.1. ==> numero de cette famille
c
      nbfnew = nbfnew + 1
      numfam = numfam - 1
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,4)) 'Creation', nbfnew, numfam
#endif
cgn        write(ulsort,2000) '.. nbfnew', nbfnew
c
      if ( nbfnew.gt.nbblqu*nbfold ) then
        write (ulsort,texte(langue,5)) nbfnew
        write (ulsort,texte(langue,6)) nbblqu*nbfold
        write (ulsort,texte(langue,7))
        codret = 1
      endif
c
c 2.2. ==> les attributs
c
      if ( codret.eq.0 ) then
c
      attri(1) = nromat
      ptabne(nbfnew) = ptabne(nbfnew-1) + nbattr
      do 221 , iaux = 1 , nbattr
        vattne(ptabne(nbfnew-1)+iaux) = attri(iaux)
        adrnew = 25*(ptabne(nbfnew-1)+iaux-1)
        do 222 , jaux = 1 , 25
          descne(adrnew+jaux) = descri(iaux)(8*(jaux-1)+1:8*jaux)
  222   continue
  221 continue
cgn        write(ulsort,2000) '.. vattne'
cgn        write(ulsort,1004) (vattne(iaux),iaux=1,nbattr*(nbfnew-1))
c
      endif
c
c 2.3. ==> le nom de la famille
c
cgn      write(ulsort,*) '.. numboi', numboi
      nofmne(8*(nbfnew-1)+1)(1:6) = 'Boite_'
      if ( codret.eq.0 ) then
      call utench ( numboi, '0', iaux, saux08,
     >              ulsort, langue, codret )
      endif
      if ( codret.eq.0 ) then
      nofmne(8*(nbfnew-1)+1)(7:8) = saux08(1:2)
      nofmne(8*(nbfnew-1)+2)(1:6) = saux08(3:8)
      nofmne(8*(nbfnew-1)+2)(7:8) = '_M'
      nofmne(8*(nbfnew-1)+2) = 'ateriau_'
      call utench ( nromat, '0', iaux, saux08,
     >              ulsort, langue, codret )
      nofmne(8*(nbfnew-1)+4) = saux08
      nofmne(8*(nbfnew-1)+5) = saux08
      nofmne(8*(nbfnew-1)+6) = saux08
      nofmne(8*(nbfnew-1)+7) = saux08
      nofmne(8*(nbfnew-1)+8) = saux08
      endif
c
c 2.4. ==> le numero de la famille
c
      nufmne(nbfnew) = numfam
cgn        write(ulsort,2000) '.. numfam', numfam
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      saux64 = nofmne(8*(nbfnew-1)+1)//nofmne(8*(nbfnew-1)+2)//
     >         nofmne(8*(nbfnew-1)+3)//nofmne(8*(nbfnew-1)+4)//
     >         nofmne(8*(nbfnew-1)+5)//nofmne(8*(nbfnew-1)+6)//
     >         nofmne(8*(nbfnew-1)+7)//nofmne(8*(nbfnew-1)+8)
      call utinfm ( numfam, saux64,
     >              0, saux08,
     >              -1, -1,
     >              ulsort, langue, codret )
      endif
#endif
c
c====
c 4. la fin
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
      call dmflsh (iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
