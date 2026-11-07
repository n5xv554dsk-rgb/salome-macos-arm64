      subroutine mmag93 ( letria, orient,
     >                    nbte06, tbau51,
     >                    nbpe09, tbau52,
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
c    Modification de Maillage - AGRegat - phase 9.3
c    -               -          --              - -
c    Memorisation de l'orientation du triangle dans un joint ponctuel
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letria . e   .   1    . triangle a examiner                        .
c . orient . e   .   1    . 1 si le triangle entre dans le joint       .
c .        .     .        . ponctuel, -1 sinon                         .
c . nbte06 . e   .   1    . nombre de tetr. des j. ponctuels d'ordre 6 .
c . tbau51 . es  .9*nbte06. Les tetraedres ponctuels entre les joints  .
c .        .     .        . triples :                                  .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : triangle cote du 1er joint triple  .
c .        .     .        . (3,i) : triangle cote du 2eme joint triple .
c .        .     .        . (4,i) : triangle cote du 3eme joint triple .
c .        .     .        . (5,i) : triangle cote du 4eme joint triple .
c .        .     .        . (1+k) : pour le k-eme triangle, 1 s'il     .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . nbpe09 . e   .   1    . nombre de pent. des j. ponctuels d'ordre 9 .
c . tbau52 . es  .  11*   . Les pentaedres ponctuels entre les joints  .
c .        .     . nbpe09 . triples et quadruples :                    .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : triangle cote du 1er joint triple  .
c .        .     .        . (3,i) : triangle cote du 2eme joint triple .
c .        .     .        . (4,i) : quadrangle cote du 1er joint quad. .
c .        .     .        . (5,i) : quadrangle cote du 2eme joint quad..
c .        .     .        . (6,i) : quadrangle cote du 3eme joint quad..
c .        .     .        . (1+k) : pour la k-eme face, 1 si elle      .
c .        .     .        . entre dans le joint ponctuel, -1 sinon     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'MMAG93' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer letria, orient
      integer nbte06, tbau51(9,nbte06)
      integer nbpe09, tbau52(11,nbpe09)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
c
      integer nbmess
      parameter ( nbmess = 40 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
#include "mmag01.h"
#include "mmag02.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,23)) mess14(langue,1,2), letria, orient
#endif
c
c====
c 2. Parcours des tetraedres de joint ponctuel d'ordre 6
c====
c
      do 21 , iaux = 1 , nbte06
c
        do 211 , jaux = 1 , 4
c
          kaux = tbau51(1+jaux,iaux)
          if ( kaux.eq.letria ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'Vu dans le joint ponctuel', iaux
#endif
            tbau51(5+jaux,iaux) = orient
          endif
c
  211   continue
c
   21 continue
c
c====
c 3. Parcours des pentaedres de joint ponctuel d'ordre 9
c====
c
      do 31 , iaux = 1 , nbpe09
c
        do 311 , jaux = 1 , 2
c
          kaux = tbau52(1+jaux,iaux)
          if ( kaux.eq.letria ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'Vu dans le joint ponctuel', iaux
#endif
            tbau52(6+jaux,iaux) = orient
          endif
c
  311   continue
c
   31 continue
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
