      subroutine utsex2 ( nbfonc, nofonc,
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
c    UTilitaire - Solution - EXtrusion - phase 2
c    --           -          --                -
c    Changement des caracteristiques d'une fonction
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .   1    . nombre de fonctions a traiter              .
c . nofonc . e   . nbfonc . nom des objets qui contiennent la          .
c .        .     .        . description de chaque fonction             .
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
      parameter ( nompro = 'UTSEX2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer edsuav, edsuap, edsaav, edsaap, nbenti
c
      character*8 nofonc(nbfonc)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2
      integer codre0
c
      integer nrfonc, nbtyas, typgeo
      integer adtyas
c
      character*8 obfonc
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
      texte(1,4) = '(''Fonction numero'',i3)'
c
      texte(2,4) = '(''Function #'',i3)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'Fonctions. Passage de', edsuav,' a', edsuap
      write (ulsort,90015) 'S. associe. Passage de', edsaav,' a', edsaap
      write (ulsort,90002) 'nbenti', nbenti
#endif
c
      codret = 0
c
c====
c 2. exploration des fonctions
c====
c
      do 20 , nrfonc = 1 , nbfonc
c
        obfonc = nofonc(nrfonc)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nrfonc
#endif
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, obfonc )
#endif
c
c 2.1. ==> caracteristiques de la fonction
c
        if ( codret.eq.0 ) then
c
        call gmliat ( obfonc, 1, typgeo, codre1 )
        call gmliat ( obfonc, 5, nbtyas, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'typgeo', typgeo
        write (ulsort,90002) 'nbtyas', nbtyas
#endif
c
c 2.2. ==> modification des caracteristiques entieres des fonctions
c
        if ( typgeo.eq.edsuav ) then
c
c 2.2.1. ==> type geometrique du support et nombre de valeurs
c
          if ( codret.eq.0 ) then
c
          call gmecat ( obfonc, 1, edsuap, codre1 )
          call gmecat ( obfonc, 3, nbenti, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
          endif
c
c 2.2.2. ==> type associes eventuels
c
          if ( nbtyas.gt.0 ) then
c
            if ( codret.eq.0 ) then
c
            call gmadoj ( obfonc//'.TypeSuAs', adtyas, iaux, codre0)
c
            codret = max ( abs(codre0), codret )
c
            if ( codret.eq.0 ) then
              do 222 , iaux = 1 , nbtyas
                if ( imem(adtyas-1+iaux).eq.edsaav ) then
                  imem(adtyas-1+iaux) = edsaap
                endif
  222         continue
            endif
c
            endif
c
          endif
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
