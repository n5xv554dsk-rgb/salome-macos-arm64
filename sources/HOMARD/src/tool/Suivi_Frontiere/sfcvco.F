      subroutine sfcvco ( dimcst, nbnoto, sdim,
     >                    coonca, geocoo,
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
c   Suivi de Frontiere - ConVersion des COordonnees
c   -        -           -  -           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . dimcst . e   .    1   . dimension de la coordonnee constante       .
c . nbnoto . e   .    1   . nombre total de noeuds                     .
c . sdim   . e   .    1   . dimension de l'espace de travail           .
c . coonca . e   . nbnoto . coordonnees des noeuds dans le calcul      .
c .        .     . *sdimca.                                            .
c . geocoo . e   .nbnoto**. coordonnees des sommets de la frontiere    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'SFCVCO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer dimcst, nbnoto, sdim
      double precision coonca(nbnoto,*), geocoo(nbnoto,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer lenoeu
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
      texte(1,4) = '(''Coordonnee constante incorrecte :'',i7)'
c
      texte(2,4) = '(''Constant coordinate is wrong:'',i7)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'dimcst', dimcst
      write (ulsort,90002) 'sdim', sdim
#endif
c====
c 2. Transfert des coordonnees
c====
c
      if ( sdim.eq.2 ) then
c
        if ( dimcst.eq.0 .or. dimcst.eq.3 ) then
          iaux = 1
          jaux = 2
        elseif ( dimcst.eq.1 ) then
          iaux = 2
          jaux = 3
        elseif ( dimcst.eq.2 ) then
          iaux = 1
          jaux = 3
        else
          write (ulsort,texte(langue,4)) dimcst
          codret = 1
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'iaux, jaux', iaux, jaux
#endif
c
        if ( codret.eq.0 ) then
c
        do 21 , lenoeu = 1 , nbnoto
          geocoo(lenoeu,1) = coonca(lenoeu,iaux)
          geocoo(lenoeu,2) = coonca(lenoeu,jaux)
   21   continue
c
        endif
c
      else
c
        do 22 , lenoeu = 1 , nbnoto
          geocoo(lenoeu,1) = coonca(lenoeu,1)
          geocoo(lenoeu,2) = coonca(lenoeu,2)
          geocoo(lenoeu,3) = coonca(lenoeu,3)
   22   continue
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
      end


