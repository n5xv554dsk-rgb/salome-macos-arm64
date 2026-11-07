      subroutine sfcon1 ( typcca, maextr,
     >                    nohman, mafrmd, nocdfr, ncafdg,
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
c   Suivi de Frontiere - CONv de la geometrie frontiere - phase 1
c   -        -           ---                                    -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typcca . e   .   1    . type du code de calcul                     .
c .        .     .        .    26 : SATURNE_2D (format MED)            .
c .        .     .        .    36 : SATURNE    (format MED)            .
c .        .     .        .    46 : NEPTUNE_2D (format MED)            .
c .        .     .        .    56 : NEPTUNE    (format MED)            .
c . maextr . e   .   1    . maillage extrude                           .
c .        .     .        . 0 : non (defaut)                           .
c .        .     .        . 1 : selon X                                .
c .        .     .        . 2 : selon Y                                .
c .        .     .        . 3 : selon Z (cas de Saturne ou Neptune)    .
c . nohman . e   . char*8 . nom de l'objet maillage homard iteration n .
c . mafrmd . e   . char*8 . maillage de la frontiere au format med     .
c . nocdfr .   s . char*8 . maillage de la frontiere a format C        .
c . ncafdg . e   . char*8 . nom de l'objet groupes/attributs frontiere .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme avec la memoire               .
c .        .     .        . 3 : probleme avec le fichier               .
c .        .     .        . 5 : contenu incorrect                      .
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
      parameter ( nompro = 'SFCON1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer typcca
      integer maextr
c
      character*8 nohman
      character*8 mafrmd, nocdfr, ncafdg
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
c====
c 2. Prealable pour le cas extrude
c====
c
      if ( codret.eq.0 ) then
c
      if ( maextr.ne.0 ) then
c
cgn      call gmprsx (nompro,mafrmd)
cgn      call gmprsx (nompro,mafrmd//'.Noeud')
cgn      call gmprsx (nompro,mafrmd//'.ConnNoeu')
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMS20', nompro
#endif
c
      call vcms20 ( mafrmd, maextr,
     >              ulsort, langue, codret )
c
      endif
cgn      call gmprsx (nompro,mafrmd)
cgn      call gmprsx (nompro,mafrmd//'.Noeud')
cgn      call gmprsx (nompro,mafrmd//'.ConnNoeu')
cgn      call dmflsh (iaux)
c
      endif
c
c====
c 3. Conversion
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCVGF', nompro
#endif
      call sfcvgf ( nohman, mafrmd, nocdfr, ncafdg,
     >              ulsort, langue, codret )
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
