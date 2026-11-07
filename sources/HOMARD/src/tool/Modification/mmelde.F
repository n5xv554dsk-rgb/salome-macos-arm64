      subroutine mmelde ( typcca,
     >                    nbfare, cfaare,
     >                    nbftri, cfatri,
     >                    nbfqua, cfaqua,
     >                    nbftet, cfatet,
     >                    nbfhex, cfahex,
     >                    nbfpyr, cfapyr,
     >                    nbfpen, cfapen,
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
c  Modification de Maillage - ELements - changement de DEgre
c  -               -          --                       --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typcca . e   .   1    . type du code de calcul                     .
c . nbfare . e   .   1    . nombre de familles d'aretes                .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nbftri . e   .   1    . nombre de familles de triangles            .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nbfqua . e   .   1    . nombre de familles de quadrangles          .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nbftet . e   .   1    . nombre de familles de tetraedres           .
c . cfatet .     . nctfte. codes des familles des tetraedres          .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nbfhex . e   .   1    . nombre de familles d'hexaedres             .
c . cfahex .     . nctfhe. codes des familles des hexaedres            .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . nbfpyr . e   .   1    . nombre de familles de pyramides            .
c . cfapyr .     . nctfpy. codes des familles des pyramides            .
c .        .     . nbfpyr .   1 : famille MED                          .
c .        .     .        .   2 : type de pyramides                    .
c . nbfpen . e   .   1    . nombre de familles de pyramides            .
c . cfapen .     . nctfpe. codes des familles des pentaedres           .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
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
      parameter ( nompro = 'MMELDE' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "rftmed.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typcca
c
      integer nbfare, nbftri, nbfqua, nbftet, nbfhex, nbfpyr, nbfpen
      integer cfaare(nctfar,nbfare)
      integer cfatri(nctftr,nbftri)
      integer cfaqua(nctfqu,nbfqua)
      integer cfatet(nctfte,nbftet)
      integer cfahex(nctfhe,nbfhex)
      integer cfapyr(nctfpy,nbfpyr)
      integer cfapen(nctfpe,nbfpen)
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
      codret = 0
c
      texte(1,4) = '(''Nombre de familles de '',a,'' :'',i8)'
c
      texte(2,4) = '(''Number of families of '',a,'' :'',i8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,1), nbfare
      write (ulsort,texte(langue,4)) mess14(langue,3,2), nbftri
      write (ulsort,texte(langue,4)) mess14(langue,3,4), nbfqua
      write (ulsort,texte(langue,4)) mess14(langue,3,3), nbftet
      write (ulsort,texte(langue,4)) mess14(langue,3,5), nbfpyr
      write (ulsort,texte(langue,4)) mess14(langue,3,6), nbfhex
      write (ulsort,texte(langue,4)) mess14(langue,3,7), nbfpen
#endif
c
c====
c 2. Modification des codes du type d'element
c====
c
      do 21 , iaux = 1, nbfare
        if ( cfaare(cotyel,iaux).ne.0 ) then
          cfaare(cotyel,iaux) = medt12(cfaare(cotyel,iaux))
        endif
   21 continue
c
      do 22 , iaux = 1, nbftri
        if ( cfatri(cotyel,iaux).ne.0 ) then
          cfatri(cotyel,iaux) = medt12(cfatri(cotyel,iaux))
        endif
   22 continue
c
      do 23 , iaux = 1, nbfqua
        if ( cfaqua(cotyel,iaux).ne.0 ) then
          cfaqua(cotyel,iaux) = medt12(cfaqua(cotyel,iaux))
        endif
   23 continue
c
      do 24 , iaux = 1, nbftet
        if ( cfatet(cotyel,iaux).ne.0 ) then
          cfatet(cotyel,iaux) = medt12(cfatet(cotyel,iaux))
        endif
   24 continue
c
      do 25 , iaux = 1, nbfpyr
        if ( cfapyr(cotyel,iaux).ne.0 ) then
          cfapyr(cotyel,iaux) = medt12(cfapyr(cotyel,iaux))
        endif
   25 continue
c
      do 26 , iaux = 1, nbfhex
        if ( cfahex(cotyel,iaux).ne.0 ) then
          cfahex(cotyel,iaux) = medt12(cfahex(cotyel,iaux))
        endif
   26 continue
c
      do 27 , iaux = 1, nbfpen
        if ( cfapen(cotyel,iaux).ne.0 ) then
          cfapen(cotyel,iaux) = medt12(cfapen(cotyel,iaux))
        endif
   27 continue
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
