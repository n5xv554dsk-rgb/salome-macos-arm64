      subroutine utsext ( nocsol, option, typcca,
     >                    lgetco, taetco,
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
c    UTilitaire - Solution - EXTrusion
c    --           -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocsol . e   . char8  . nom de l'objet solution a modifier         .
c . option . e   .    1   . option de la modification                  .
c .        .     .        . 1 : passage du 3D au 2D                    .
c .        .     .        . 2 : passage du 2D au 3D                    .
c . typcca . e   .   1    . type du code de calcul                     .
c .        .     .        .    26 : SATURNE_2D (format MED)            .
c .        .     .        .    36 : SATURNE (format MED)               .
c .        .     .        .    46 : NEPTUNE_2D (format MED)            .
c .        .     .        .    56 : NEPTUNE (format MED)               .
c .        .     .        .    66 : CARMEL_2D (format MED)             .
c .        .     .        .    76 : CARMEL (format MED)                .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'UTSEXT' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer option, typcca
c
      character*8 nocsol
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nretap, nrsset
      integer iaux
c
      integer sdimav, sdimap
c
      character*6 saux
      character*9 saux09
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
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
      if ( typcca.eq.26 ) then
        saux09 = 'SATURNE  '
      elseif ( typcca.eq.46 ) then
        saux09 = 'NEPTUNE  '
      else
        saux09 = 'EXTRUSION'
      endif
c
      texte(1,4) =
     > '(/,a6,1x,'''//saux09//' - PASSAGE DU CHAMP '',i1,
     > ''D EN '',i1,''D'')'
      texte(1,5) = '(44(''=''),/)'
      texte(1,6) = '(''Option de conversion '',i8,'' invalide.'')'
      texte(1,7) = '(''Il faut 1 ou 2.'')'
c
      texte(2,4) = '(/,a6,1x,'''//saux09//' - FROM '',i1,
     > ''D FIELD TO '',i1,''D'')'
      texte(2,5) = '(38(''=''),/)'
      texte(2,6) = '(''Option for conversion '',i8,'' is uncorrect.'')'
      texte(2,7) = '(''1 or 2 is needed.'')'
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5 ==> le titre
c
      if ( option.eq.1 ) then
        sdimav = 3
        sdimap = 2
      elseif ( option.eq.2 ) then
        sdimav = 2
        sdimap = 3
      else
        sdimav = 0
        sdimap = 0
        codret = 1
      endif
c
      write (ulsort,texte(langue,4)) saux, sdimav, sdimap
      write (ulsort,texte(langue,5))
c
      if ( codret.eq.1 ) then
        write (ulsort,texte(langue,6)) option
        write (ulsort,texte(langue,7))
      endif
c
#include "impr03.h"
c
c====
c 2. conversion de la solution
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSEX0', nompro
#endif
      call utsex0 ( nocsol, option,
     >              ulsort, langue, codret )
c
      endif
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
c=======================================================================
      endif
c=======================================================================
c
      end
