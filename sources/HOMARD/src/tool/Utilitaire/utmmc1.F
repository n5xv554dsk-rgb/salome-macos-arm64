      subroutine utmmc1 ( sdim, nbnoto,
     >                    coonca, coocst, sdimre, ncnoeu,
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
c    UTilitaire - Minimum/Maximum des Coordonnees - phase 1
c    --           -       -           -                   -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . sdim   . e   .   1    . dimension                                  .
c . nbnoto . e   .   1    . nombre total de noeuds                     .
c . coonca . e   . nbnoto . coordonnees des noeuds                     .
c . coocst .  s  .   11   . 1 : coordonnee constante eventuelle        .
c .        .     .        . 2, 3, 4 : xmin, ymin, zmin                 .
c .        .     .        . 5, 6, 7 : xmax, ymax, zmax                 .
c .        .     .        . 8, 9, 10 : -1 si constant, max-min sinon   .
c .        .     .        . 11 : max des (max-min)                     .
c . sdimre .  s  .   1    . dimension reelle                           .
c . ncnoeu . es  .   1    . structure des noeuds                       .
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
      parameter ( nompro = 'UTMMC1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "indefr.h"
c
c 0.3. ==> arguments
c
      integer sdim, nbnoto, dimcst
      integer sdimre
c
      double precision coonca(nbnoto,sdim), coocst(11)
c
      character*8 ncnoeu
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Direction '',a1,'' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(1,5) = '(/,8x,''La coordonnee'',i2,'' est constante.'')'
      texte(1,6) = '(8x,''Elle vaut : '',g12.4)'
      texte(1,7) =
     > '(50(''*''),/,''Taille maximale :'',g12.5,/,50(''*''))'
c
      texte(2,4) =
     > '(a1,''direction '','' : mini = '',g12.5,'' maxi = '',g12.5)'
      texte(2,5) = '(/,8x,''The coordinate #'',i2,'' is constant.'')'
      texte(2,6) = '(8x,''Its value is : '',g12.4)'
      texte(2,7) =
     > '(50(''*''),/,''Maximum size :'',g12.5,/,50(''*''))'
c
c 1.2. ==> constantes
c
      codret = 0
c
c====
c 2. coordonnees extremes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMMCO', nompro
#endif
      call utmmco ( coocst(2), coocst(5), coocst(8),
     >              nbnoto, sdim, coonca,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,4)) 'x', coocst(2), coocst(5)
      write (ulsort,texte(langue,4)) 'y', coocst(3), coocst(6)
      if ( sdim.eq.3 ) then
        write (ulsort,texte(langue,4)) 'z', coocst(4), coocst(7)
      endif
      endif
#endif
c
c====
c 3. tests et memorisation
c====
c
      if ( codret.eq.0 ) then
c
      dimcst = 0
      coocst(1) = rindef
      sdimre = 0
c
      do 30 , iaux = 1 , sdim
c
        if ( coocst(iaux+7).lt.0.d0 ) then
          dimcst = iaux
          call gmecat ( ncnoeu, 3, dimcst, codret )
          coocst(1) = coocst(iaux+1)
          write (ulsort,texte(langue,5)) dimcst
          write (ulsort,texte(langue,6)) coocst(1)
        else
          sdimre = sdimre + 1
        endif
c
   30 continue
c
      endif
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
