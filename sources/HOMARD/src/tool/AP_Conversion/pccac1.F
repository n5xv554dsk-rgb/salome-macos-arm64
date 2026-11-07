      subroutine pccac1 ( nbcham, nocham,
     >                    nnfonc, npfonc, obprof, oblopg,
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
c    aPres adaptation - mise a jour des CAracteristiques des Champs - 1
c     -                                 --                   -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbcham . e   .   1    . nombre de champs                           .
c . nocham . es  . nbcham . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . nnfonc . e   . char8  . nom de la fonction iteration n             .
c . npfonc . e   . char8  . nom de la fonction iteration n+1           .
c . obprof . e   . char8  . nom de l'objet profil eventuel             .
c . oblopg . e   . char8  . nom de l'objet localisation eventuelle     .
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
      parameter ( nompro = 'PCCAC1' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "esutil.h"
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer nbcham
c
      character*8 nocham(nbcham)
      character*8 npfonc, nnfonc, obprof, oblopg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer codre1, codre2, codre3
      integer codre0
c
      integer nrocha, nrotv
      integer nbtvch
      integer adcaen, adcaca
      integer typgeo, ngauss, nbenmx, nbvapr, nbtyas
      integer carsup, nbtafo, typint
      integer advale, advalr, adobch, adprpg, adtyas
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
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Etape '',a1,'' : nom de la fonction = '',a8)'
      texte(1,5) = '(''... Le remplacement de la fonction a eu lieu.'')'
c
      texte(2,4) = '(''Stage '',a1,'' : name of the function = '',a8)'
      texte(2,5) = '(''... Change of function occured.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 'n', nnfonc
      write (ulsort,texte(langue,4)) 'p' ,npfonc
#endif
c
c====
c 2. on passe en revue tous les champs
c====
c
      do 20 , nrocha = 1 , nbcham
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '.. Nom du champ = ',nocham(nrocha)
      call gmprsx (nompro, nocham(nrocha)//'.Cham_Car' )
#endif
c
c 2.1. ==> reperage des noms des fonctions
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nocham(nrocha), 2, nbtvch, codre1 )
      call gmadoj ( nocham(nrocha)//'.Cham_Ent', adcaen, iaux, codre2 )
      call gmadoj ( nocham(nrocha)//'.Cham_Car', adcaca, iaux, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 2.2. ==> on parcourt les tableaux
c          on opere un traitement quand on tombe sur la bonne fonction
c
      if ( codret.eq.0 ) then
c
      do 21 , nrotv = 1, nbtvch
c
        jaux = adcaca + nbincc*(nrotv-1)
c
        if ( smem(jaux).eq.nnfonc ) then
c
c 2.2.1. ==> on met a jour le nombre de valeurs
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
          call utcafo ( npfonc,
     >                  iaux,
     >                  typgeo, ngauss, nbenmx, nbvapr, nbtyas,
     >                  carsup, nbtafo, typint,
     >                  advale, advalr, adobch, adprpg, adtyas,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c          Rappel :
c       1. type de support au sens MED
c       2. numero du pas de temps
c       4. 1, si numero d'ordre, 0 sinon
c       3. numero d'ordre
c       4. nombre de points de Gauss
c       5. nombre d'entites support
c       6. nombre de valeurs du profil eventuel
c       7. nombre de supports associes
c       8. noeuds par elements/points de Gauss/autre
c       9. numero du 1er tableau dans la fonction
c       10. -1 ou champ elga/champ elno
c       11. type interpolation
c       21-nbinec. type des supports associes
c
          jaux = adcaen + nbinec*(nrotv-1)
          imem(jaux+4) = nbenmx
          imem(jaux+5) = nbvapr
          imem(jaux+6) = nbtyas
cgn              print *,nbtyas
cgn              print *,(imem(adtyas+kaux-1),kaux = 1 , nbtyas)
          do 211 , kaux = 1 , nbtyas
            imem(jaux+19+kaux) = imem(adtyas+kaux-1)
  211     continue
c
          endif
c
c 2.2.2. ==> on remplace l'ancien nom de la fonction par le nouveau
c
          jaux = adcaca + nbincc*(nrotv-1)
          smem(jaux) = npfonc
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,5))
#endif
c
c 2.2.3. ==> on archive le nom de l'eventuel profil
c
          if ( nbvapr.gt.0 ) then
            smem(jaux+1) = obprof
          else
            smem(jaux+1) = blan08
          endif
c
c 2.2.4. ==> on archive le nom de l'eventuelle localisation
c
          smem(jaux+2) = oblopg
c
        endif
c
   21 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          call gmprsx (nompro, nocham(nrocha) )
          call gmprsx (nompro, nocham(nrocha)//'.Cham_Ent' )
          call gmprsx (nompro, nocham(nrocha)//'.Cham_Car' )
          endif
#endif
c
   20 continue
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
