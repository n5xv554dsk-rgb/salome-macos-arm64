      subroutine utal41 ( typcca, nonexm, nbanci, nbenrc,
     >                    nbarto, nbarde,
     >                    nbtrri, nbtrde,
     >                    nbquri, nbqude,
     >                    nbpeac, nbpyac,
     >                    nospec,
     >                    adarrc, adtrrc, adqurc,
     >                    adterc, adherc, adperc, adpyrc,
     >                    lgtrc1, lgtrc2, lgtrc3,
     >                    lgtrc4, lgtrc5, lgtrc6, lgtrc7,
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
c Copyright 2016 EDF
c ______________________________________________________________________
c
c    UTilitaire - ALocations - phase 41
c    --           --                 --
c ______________________________________________________________________
c   Allocation des tableaux pour les recollements
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typcca . e   .   1    . type du code de calcul                     .
c . nonexm . e   .    1   . non exportation de mailles                 .
c .        .     .        .   1 : on exporte toutes les mailles        .
c .        .     .        .  2x : les segments ne sont pas exportes    .
c . nbenci . e   .    1   . nombre de non conformites initiales        .
c . nbenrc . e   .    1   . nombre d'entites par recollement unitaire  .
c . nbpeac . e   .    1   . nombre de pentaedres actifs                .
c . nbpyac . e   .    1   . nombre de pyramides actives                .
c . nospec .  s  . char8  . nom de l'objet memorisant les specificites .
c . adarrc .  s  .   1    . paires d'aretes recollees                  .
c . adtrrc .  s  .   1    . paires de triangles recolles               .
c . adqurc .  s  .   1    . paires de quadrangles recolles             .
c . adterc .  s  .   1    . paires des tetra. voisins faces a recoller .
c . adherc .  s  .   1    . paires des hexa. voisins faces a recoller  .
c . adperc .  s  .   1    . paires des penta. voisins faces a recoller .
c . adpyrc .  s  .   1    . paires des pyram. voisines faces a recoller.
c . lgtrc1 .  s  .   1    . longueur des paires d'aretes               .
c . lgtrc2 .  s  .   1    . longueur des paires de triangles           .
c . lgtrc3 .  s  .   1    . longueur des paires de quadrangles         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'UTAL41' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer typcca, nonexm
      integer nbanci, nbenrc
      integer nbarto, nbarde
      integer nbtrri, nbtrde
      integer nbquri, nbqude
      integer nbpeac, nbpyac
c
      integer adarrc, adtrrc, adqurc
      integer adterc, adherc, adperc, adpyrc
      integer lgtrc1, lgtrc2, lgtrc3
      integer lgtrc4, lgtrc5, lgtrc6, lgtrc7
c
      character*8 nospec
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4
      integer codre0
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
      texte(1,4) = '(''Allocations relatives aux recollements'')'
c
      texte(2,4) = '(''Allocations for entities'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. La structure principale
c====
c
      call gmalot ( nospec, '10TabEnt', 0, iaux, codret )
c
c====
c 3. Les entites recollees
c====
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> Aretes
c
      if ( mod(nonexm,2).ne.0 ) then
cgn        write (ulsort,90002) 'nbanci', nbanci
cgn        write (ulsort,90002) 'nbenrc', nbenrc
        lgtrc1 = 2*nbarto
        if ( typcca.eq.26 .or.
     >       typcca.eq.46 ) then
          lgtrc1 = lgtrc1 + 2*nbanci*nbenrc
        endif
      else
        lgtrc1 = 0
      endif
c
      call gmaloj ( nospec//'.Tab1', ' ', lgtrc1, adarrc, codre1 )
c
c 3.2. ==> Triangles
c
cgn      write (ulsort,90002) 'nbtrri = ',nbtrri
cgn      write (ulsort,90002) 'nbtrde = ',nbtrde
      if ( typcca.eq.26 .or.
     >     typcca.eq.46 ) then
        lgtrc2 = 0
      else
        lgtrc2 = 2*(nbtrde+nbtrri)
      endif
c
      call gmaloj ( nospec//'.Tab2', ' ', lgtrc2, adtrrc, codre2 )
c
c 3.3. ==> Quadrangles
c
cgn      write (ulsort,90002) 'nbquri = ',nbquri
cgn      write (ulsort,90002) 'nbqude = ',nbqude
      if ( typcca.eq.26 .or.
     >     typcca.eq.46 ) then
        lgtrc3 = 2*(nbarde+nbanci*nbenrc)
      else
        lgtrc3 = 2*(nbqude+nbquri)
      endif
      call gmaloj ( nospec//'.Tab3', ' ', lgtrc3, adqurc, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c====
c 4. Les voisins des entites recollees
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. voisins ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      lgtrc4 = lgtrc2*3/2
      call gmaloj ( nospec//'.Tab4', ' ', lgtrc4, adterc, codre1 )
      lgtrc5 = lgtrc3*3/2
      call gmaloj ( nospec//'.Tab5', ' ', lgtrc5, adherc, codre2 )
      if ( nbpeac.gt.0 ) then
        lgtrc6 = (lgtrc2+lgtrc3)*3/2
      else
        lgtrc6 = 0
      endif
      call gmaloj ( nospec//'.Tab6', ' ', lgtrc6, adperc, codre3 )
      if ( nbpyac.gt.0 ) then
        lgtrc7 = (lgtrc2+lgtrc3)*3/2
      else
        lgtrc7 = 0
      endif
      call gmaloj ( nospec//'.Tab7', ' ', lgtrc7, adpyrc, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 5. les attributes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. les attributes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      lgtrc1 = lgtrc1/2
      lgtrc2 = lgtrc2/2
      lgtrc3 = lgtrc3/2
      lgtrc4 = lgtrc4/3
      lgtrc5 = lgtrc5/3
      lgtrc6 = lgtrc6/3
      lgtrc7 = lgtrc7/3
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nospec, 1, lgtrc1, codre1 )
      call gmecat ( nospec, 2, lgtrc2, codre2 )
      call gmecat ( nospec, 3, lgtrc3, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      call gmecat ( nospec, 4, lgtrc4, codre1 )
      call gmecat ( nospec, 5, lgtrc5, codre2 )
      call gmecat ( nospec, 6, lgtrc6, codre3 )
      call gmecat ( nospec, 7, lgtrc7, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
cgn      call gmprsx ( nompro, nospec )
c
c====
c 6. la fin
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
