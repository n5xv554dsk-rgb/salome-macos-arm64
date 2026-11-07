      subroutine utsex3 ( nbcham, nocham,
     >                    edsuav, edsuap, edsaav, edsaap, nbenti,
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
c    UTilitaire - Solution - EXtrusion - phase 3
c    --           -          --                -
c    Changement du support dans un champ
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbcham . e   .   1    . nombre de champs a traiter                 .
c . nocham . e   . nbcham . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . edsuav . e   .   1    . type med avant                             .
c . edsuap . e   .   1    . type med apres                             .
c . edsaav . e   .   1    . type med associe avant                     .
c . edsaap . e   .   1    . type med associe apres                     .
c . nbenti . e   .   1    . nombre d'entites apres                     .
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
      parameter ( nompro = 'UTSEX3' )
c
#include "nblang.h"
#include "esutil.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer nbcham
      integer edsuav, edsuap, edsaav, edsaap, nbenti
c
      character*8 nocham(nbcham)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codre1, codre2
      integer codre0
c
      integer nrcham, nbtv
c
      integer adcaen
c
      character*8 obcham
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Champ numero'',i3)'
c
      texte(2,4) = '(''Field #'',i3)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'Support. Passage de', edsuav,' a', edsuap
      write (ulsort,90015) 'S. associe. Passage de', edsaav,' a', edsaap
      write (ulsort,90002) 'nbenti', nbenti
#endif
c
      codret = 0
c
c====
c 2. exploration des champs
c====
c
      do 20 , nrcham = 1 , nbcham
c
        if ( codret.eq.0 ) then
c
        obcham = nocham(nrcham)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nrcham
#endif
#ifdef _DEBUG_HOMARD_
cgn        call gmprsx (nompro, obcham )
        call gmprsx (nompro//' - entree', obcham//'.Cham_Ent' )
#endif
c
c 2.1. ==> caracteristiques du champ
c
        if ( codret.eq.0 ) then
c
        call gmliat ( obcham, 2, nbtv, codre1 )
        call gmadoj ( obcham//'.Cham_Ent', adcaen, iaux, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,90002) 'nbtv', nbtv
        endif
#endif
c
c 2.2. ==> modification des caracteristiques entieres des champs
c
        if ( codret.eq.0 ) then
c
        do 22 , iaux = 1 , nbtv
c
          jaux = adcaen
c
          if ( imem(jaux).eq.edsuav ) then
c
c 2.2.1. ==> Support
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) '==> conversion support', edsuav, edsuap
#endif
            imem(jaux) = edsuap
c
c 2.2.2. ==> Nombre d'entites
c
            jaux = adcaen + 4
#ifdef _DEBUG_HOMARD_
       write (ulsort,90002) '==> conversion nbenti', imem(jaux), nbenti
#endif
            imem(jaux) = nbenti
c
c 2.2.3. ==> Support associe eventuel
c
            jaux = adcaen + 20
            if ( mod(imem(jaux),edsaav).eq.0 ) then
#ifdef _DEBUG_HOMARD_
       write (ulsort,90002) '==> conversion support associe',
     > imem(jaux), imem(jaux)*edsaap/edsaav
#endif
              imem(jaux) = imem(jaux)*edsaap/edsaav
            endif
c
          endif
c
          adcaen = adcaen + nbinec
c
   22   continue
c
        endif
c
#ifdef _DEBUG_HOMARD_
cgn        write (ulsort,texte(langue,4)) nrcham
        call gmprsx (nompro//' - sortie', obcham//'.Cham_Ent' )
#endif
c
        endif
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
