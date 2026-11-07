      subroutine mmag94 ( lequad, orient,
     >                    nbhe12, tbau53,
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
c    Modification de Maillage - AGRegat - phase 9.4
c    -               -          --              - -
c    Memorisation de l'orientation du quadrangle dans un joint ponctuel
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   .   1    . quadrangle a examiner                      .
c . orient . e   .   1    . 1 si le quadrangle entre dans le joint     .
c .        .     .        . ponctuel, -1 sinon                         .
c . nbhe12 . e   .   1    . nombre de hexa. des j. ponctuels d'ordre 12.
c . tbau53 . es  .  13*   . Les hexaedres ponctuels entre les joints   .
c .        .     . nbhe12 . quadruples (ordre 12) :                    .
c .        .     .        . (1,i) : noeud multiple                     .
c .        .     .        . (2,i) : quadrangle cote du 1er joint quad. .
c .        .     .        . (3,i) : quadrangle cote du 2eme joint quad..
c .        .     .        . (4,i) : quadrangle cote du 3eme joint quad..
c .        .     .        . (5,i) : quadrangle cote du 4eme joint quad..
c .        .     .        . (6,i) : quadrangle cote du 5eme joint quad..
c .        .     .        . (7,i) : quadrangle cote du 6eme joint quad..
c .        .     .        . (1+k) : pour le k-eme quadrangle, 1 s'il   .
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
      integer lequad, orient
      integer nbhe12, tbau53(13,nbhe12)
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
      write (ulsort,texte(langue,23)) mess14(langue,1,4), lequad, orient
#endif
c
c====
c 2. Parcours des hexaedres de joint ponctuel d'ordre 12
c====
c
      do 21 , iaux = 1 , nbhe12
c
        do 211 , jaux = 1 , 6
c
          kaux = tbau53(1+jaux,iaux)
          if ( kaux.eq.lequad ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'Vu dans le joint ponctuel', iaux
#endif
            tbau53(7+jaux,iaux) = orient
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
        do 311 , jaux = 1 , 3
c
          kaux = tbau52(3+jaux,iaux)
          if ( kaux.eq.lequad ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'Vu dans le joint ponctuel', iaux
#endif
            tbau52(8+jaux,iaux) = orient
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
