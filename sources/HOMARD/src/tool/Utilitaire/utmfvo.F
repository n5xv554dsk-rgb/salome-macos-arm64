      subroutine utmfvo ( nomail,
     >                    ulsort, langue, codret)
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
c    UTilitaire - passage de Mere a Fille pour les VOlumes
c    --                      -      -              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard             .
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
      parameter ( nompro = 'UTMFVO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer degre, nbenti(4), nbent0
      integer codre1, codre2
      integer codre0
      integer pperte
      integer pfilhp, adhps2
      integer adtes2, adpys2
      integer pperpy
      integer nbhpco
c
      character*4 saux04(4)
      character*8 nhenti(2)
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
     >'(''== Reperage des filles a partir des meres pour les volumes'')'
      texte(1,5) = '(/,''. Type d''''entites : '',a)'
      texte(1,6) = '(''. Nombre de '',a,'' :'',i8)'
      texte(1,7) = '(''.. Pas de filiation ..'')'
      texte(1,8) = '(''.. Aucun traitement a faire ..'')'
c
      texte(2,4) = '(''== Son arrays from father arrays for volumes'')'
      texte(2,5) = '(/,''. Type of entities: '',a)'
      texte(2,6) = '(''. Number of '',a,'':'',i8)'
      texte(2,7) = '(''.. No sons ..'')'
      texte(2,8) = '(''.. Nothing to do ..'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. recuperation des donnees du maillage d'entree
c====
c
      call gmliat ( nomail, 3, degre, codre0 )
      codret = max ( abs(codre0), codret )
c
      if ( codret.eq.0 ) then
c
      if ( degre.eq.1 ) then
        saux04(1) = 'Te04'
        saux04(2) = 'He08'
        saux04(3) = 'Py05'
        saux04(4) = 'Pe06'
      else
        saux04(1) = 'Te10'
        saux04(2) = 'He20'
        saux04(3) = 'Py13'
        saux04(4) = 'Pe15'
      endif
c
      endif
c
c====
c 3. Traitement des filiations de types identiques
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Traitement ; codret = ', codret
#endif
c
      do 30 , iaux = 1 , 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Traitement ',iaux,' ; codret = ', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,texte(langue,5)) saux04(iaux)
ccc        call gmprsx (nompro, nomail//'.Volume.HOM_'//saux04(iaux) )
        endif
#endif
c
        call gmobal ( nomail//'.Volume.HOM_'//saux04(iaux) , codre0 )
        if ( codre0.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7))
#endif
          nbenti(iaux) = 0
          goto 30
        elseif ( codre0.ne.1 ) then
          codret = 1
        endif
c
        endif

c 3.2. ==> combien d'entites de ce type ?
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nomail//'.Volume.HOM_'//saux04(iaux),
     >                1, nbenti(iaux), codre0 )
        codret = max ( abs(codre0), codret )
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        if ( iaux.eq.1 ) then
          jaux = 3
        elseif ( iaux.eq.2 ) then
          jaux = 6
        elseif ( iaux.eq.3 ) then
          jaux = 5
        else
          jaux = 7
        endif
        write (ulsort,texte(langue,6))
     >         mess14(langue,3,jaux), nbenti(iaux)
        endif
#endif
c
        endif
c
c 3.3. ==> s'il y en a, on recupere la structure qui les decrit
c          sinon, on passe a la suite
c
        if ( codret.eq.0 ) then
c
        if ( nbenti(iaux).eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,8))
#endif
          goto 30
c
        else
c
          call gmnomc ( nomail//'.Volume.HOM_'//saux04(iaux),
     >                  nhenti(1), codre0 )
          codret = max ( abs(codre0), codret )
c
        endif
c
        endif
c
c 3.5. ==> Appel du programme generique
c
        if ( codret.eq.0 ) then
c
cgn        call gmprsx (nompro,
cgn     >  nomail//'.Volume.HOM_'//saux04(iaux)//'.Mere' )
c
        nbent0 = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMFEN', nompro
#endif
        call utmfen ( nhenti(1), nhenti(2), nbent0,
     >                ulsort, langue, codret )
c
        endif
cgn        call gmprsx (nompro,
cgn     >  nomail//'.Volume.HOM_'//saux04(iaux)//'.Fille' )
c
   30 continue
c
c====
c 4. Prise en compte des filiations de type differents :
c    hexaedre --> tetraedre/pyramide
c    pentaedre --> tetraedre/pyramide
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Filiations hexa/tet-pyr; codret = ', codret
      write (ulsort,90002) 'nbenti', nbenti
#endif
c
      if ( nbenti(1).gt.0 .or. nbenti(3).gt.0 ) then
c
      do 40 , iaux = 2 , 4, 2
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,90002) '4. Traitement numero',iaux
        write (ulsort,90003) 'Entite mere', saux04(iaux)
        endif
#endif
c
cgn      call gmprsx (nompro,nomail//'.Volume' )
cgn      call gmprsx (nompro,nomail//'.Volume.HOM_'//saux04(iaux) )
cgn      call gmprsx
cgn     > (nompro,nomail//'.Volume.HOM_'//saux04(iaux)//'.Fille')
cgn      call gmprsx
cgn     > (nompro,nomail//'.Volume.HOM_'//saux04(iaux)//'.InfoSup2' )
c
c 4.1. ==> A-t-on une telle filiation ?
c
        if ( codret.eq.0 ) then
c
        call gmobal ( nomail//'.Volume.HOM_'//saux04(iaux)//'.InfoSup2',
     >                codre0 )
c
        if ( codre0.eq.0 ) then
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7))
#endif
          goto 40
        elseif ( codre0.ne.2 ) then
          codret = 1
        endif
c
        endif
c
c 4.2. ==> Les adresses
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '4.2. Adresses ; codret = ', codret
#endif
c
        if ( codret.eq.0 ) then
c
c 4.2.1.==> Pour les tetraedres
c
        if ( nbenti(1).gt.0 ) then
c
          call gmadoj ( nomail//'.Volume.HOM_'//saux04(1)//'.Mere',
     >                  pperte, jaux, codre1 )
          call gmobal ( nomail//'.Volume.HOM_'//saux04(1)//'.InfoSup2',
     >                  codre0 )
          if ( codre0.eq.2 ) then
            call gmadoj (
     >           nomail//'.Volume.HOM_'//saux04(1)//'.InfoSup2',
     >           adtes2, jaux, codre2 )
          else
            codre2 = codre0
          endif
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'tetraedres - codre1/2', codre1, codre2
#endif
c
        endif
c
c 4.2.2.==> Pour les pyramides
c
        if ( nbenti(3).gt.0 ) then
c
          call gmadoj ( nomail//'.Volume.HOM_'//saux04(3)//'.Mere',
     >                  pperpy, jaux, codre1 )
          call gmobal ( nomail//'.Volume.HOM_'//saux04(3)//'.InfoSup2',
     >                  codre0 )
          if ( codre0.eq.2 ) then
            call gmadoj (
     >           nomail//'.Volume.HOM_'//saux04(3)//'.InfoSup2',
     >           adpys2, jaux, codre2 )
          else
            codre2 = codre0
          endif
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'pyramides  - codre1/2', codre1, codre2
#endif
c
        endif
c
c 4.2.3.==> Pour les volumes
c
        call gmadoj (
     >       nomail//'.Volume.HOM_'//saux04(iaux)//'.Fille',
     >       pfilhp, jaux, codre1 )
        call gmobal (
     >       nomail//'.Volume.HOM_'//saux04(iaux)//'.InfoSup2',
     >       codre0 )
        if ( codre0.eq.2 ) then
          call gmadoj (
     >         nomail//'.Volume.HOM_'//saux04(iaux)//'.InfoSup2',
     >         adhps2, nbhpco, codre2 )
        else
          codre2 = codre0
        endif
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'volumes    - codre1/2', codre1, codre2
#endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbhpco', nbhpco
#endif
c
        endif
c
c 4.3. ==> Traitement
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '4.3. Traitement ; codret = ', codret
#endif
c
        if ( codret.eq.0 ) then
c
        if ( nbhpco.ne.0 ) then
c
          nbhpco = nbhpco/2
c
          if ( iaux.eq.2 ) then
            jaux = 6
          else
            jaux = 7
          endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTMFV1_'//saux04(iaux), nompro
#endif
          call utmfv1 ( jaux, nbenti(iaux), nbhpco,
     >                  imem(pfilhp), imem(adhps2),
     >                  imem(pperte), imem(pperpy),
     >                  imem(adtes2), imem(adpys2),
     >                  ulsort, langue, codret)
c
        endif
c
        endif
c
   40 continue
cgn        call gmprsx (nompro, nomail//'.Volume.HOM_'//saux04(2)//'.Fille' )
c
      endif
c
c====
c 5. la fin
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
