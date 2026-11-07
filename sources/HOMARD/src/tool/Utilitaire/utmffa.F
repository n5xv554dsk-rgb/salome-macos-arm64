      subroutine utmffa ( nomail,
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
c    UTilitaire - passage de Mere a Fille pour les FAces
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
      parameter ( nompro = 'UTMFFA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbenti(2)
      integer iaux, jaux
      integer codre1, codre2
      integer codre0
c
      character*4 saux04(2)
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
     > '(''Reperage des fils a partir des peres pour les faces'')'
      texte(1,5) = '(''. Type d''''entites   : '',a)'
      texte(1,6) = '(''. Nombre d''''entites :'',i10)'
c
      texte(2,4) = '(''Son arrays from father arrays for faces'')'
      texte(2,5) = '(''. Type of entities  : '',a)'
      texte(2,6) = '(''. Number of entities:'',i10)'
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
c====
c 3. les triangles puis les quadrangles
c====
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        call gmprsx (nompro, nomail//'.Face' )
        endif
#endif
c
      do 30 , iaux = 1 , 2
c
c 3.1. ==> nom de la branche
c
        if ( codret.eq.0 ) then
c
        jaux = mod(iaux,2) + 1
        if ( degre.eq.1 ) then
          saux04(iaux) = 'Tr03'
          saux04(jaux) = 'Qu04'
        else
          if ( mod(mailet,2).eq.0 .or. mod(mailet,3).eq.0 ) then
            saux04(iaux) = 'Tr07'
            saux04(jaux) = 'Qu09'
          else
            saux04(iaux) = 'Tr06'
            saux04(jaux) = 'Qu08'
          endif
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,texte(langue,5)) saux04(1)
cgn        call gmprsx (nompro, nomail//'.Face.HOM_'//saux04(1) )
        endif
#endif
c
        call gmobal ( nomail//'.Face.HOM_'//saux04(1) , codre0 )
        if ( codre0.eq.0 ) then
          goto 30
        elseif ( codre0.ne.1 ) then
          codret = 1
        endif
c
        endif
c
c 3.2. ==> combien d'entites de ce type ?
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nomail//'.Face.HOM_'//saux04(1),
     >                1, nbenti(1), codre0 )
        codret = max ( abs(codre0), codret )
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,texte(langue,6)) nbenti(1)
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
        if ( nbenti(1).eq.0 ) then
c
          goto 30
c
        else
c
          call gmnomc ( nomail//'.Face.HOM_'//saux04(1),
     >                  nhenti(1), codre1 )
          codret = max ( abs(codre0), codret )
c
        endif
c
        endif
c
c 3.4. ==> A-t-on le type frere ?
c
        if ( codret.eq.0 ) then
c
        call gmobal ( nomail//'.Face.HOM_'//saux04(2) , codre0 )
        if ( codre0.eq.1 ) then
          call gmliat ( nomail//'.Face.HOM_'//saux04(2),
     >                  1, nbenti(2), codre1 )
          call gmnomc ( nomail//'.Face.HOM_'//saux04(2),
     >                  nhenti(2), codre2 )
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
        else
          nbenti(2) = 0
        endif
c
        endif
c
c 3.5. ==> Appel du programme generique
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMFEN', nompro
#endif
        call utmfen ( nhenti(1), nhenti(2), nbenti(2),
     >                ulsort, langue, codret )
c
        endif
c
   30 continue
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
