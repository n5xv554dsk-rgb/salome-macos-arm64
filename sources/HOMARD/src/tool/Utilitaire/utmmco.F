      subroutine utmmco ( xyzmin, xyzmax, xyzeps,
     >                    nbnoto, sdim, coonoe,
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
c    UTilitaire - Minimum/Maximum des COordonnees
c    --           -       -           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . xyzmin .  s  .    3   . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) minimales du domaine total      .
c . xyzmax .  s  .    3   . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) maximales du domaine total      .
c . xyzeps .  s  .    4   . -1 si min = max dans la direction,         .
c .        .     .        . ecart sinon, puis ecart maximal            .
c . nbnoto . e   .   1    . nombre total de noeuds                     .
c . sdim   . e   .   1    . dimension                                  .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
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
      parameter ( nompro = 'UTMMCO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbnoto, sdim
c
      double precision coonoe (nbnoto,sdim)
      double precision xyzmin(3), xyzmax(3), xyzeps(4)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
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
      texte(1,4) = '(''Nombre de noeuds : '',i10)'
      texte(1,5) = '(''Dimension        : '',i8)'
      texte(1,6) =
     > '(''direction *  minimum   *  maximum   *   ecart'',/,50(''*''))'
      texte(1,7) =
     > '(50(''*''),/,''Taille maximale :'',g12.5,/,50(''*''))'
c
      texte(2,4) = '(''Number of nodes : '',i10)'
      texte(2,5) = '(''Dimension       : '',i8)'
      texte(2,6) =
     > '(''direction *  minimum   *  maximum   *   shift'',/,50(''*''))'
      texte(2,7) =
     > '(50(''*''),/,''Maximum size :'',g12.5,/,50(''*''))'
c
 1000 format(5x,a1,4x,3('*',g12.5))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbnoto
      write (ulsort,texte(langue,5)) sdim
#endif
c
      codret = 0
c
c====
c 2. min/max des coordonnees et tolerance
c====
c 2.1. ==> Mise a zero de la 3eme dimension eventuellement absente
c
      do 21 , iaux = sdim+1 , 3
        xyzmin(iaux) = 0.d0
        xyzmax(iaux) = 0.d0
   21 continue
c
c 2.2. ==> Recherche des extremes
c
      xyzeps(4) = 0.d0
      do 22 , iaux = 1 , sdim
c
        xyzmin(iaux) = coonoe(1,iaux)
        xyzmax(iaux) = coonoe(1,iaux)
        do 220 , jaux = 2 , nbnoto
          xyzmin(iaux) = min ( xyzmin(iaux), coonoe(jaux,iaux) )
          xyzmax(iaux) = max ( xyzmax(iaux), coonoe(jaux,iaux) )
  220   continue
        xyzeps(iaux) = xyzmax(iaux) - xyzmin(iaux)
        xyzeps(4) = max ( xyzeps(4), xyzeps(iaux) )
c
   22 continue
c
c 2.3. ==> Notation des coordonnees constantes
c    Si pour une coordonnee, l'ecart entre le min et le max
c    est 1 million de fois plus petit que le max des ecarts,
c    c'est que le probleme est vraisemblablement plan dans cette
c    direction. On memorise cela en mettant une tolerance negative.
c    Sinon, on memorise l'ecart min/max.
c    Ces valeurs sont totalement pifometriques.
c
      do 23 , iaux = 1 , 3
        if ( xyzeps(iaux)/xyzeps(4).lt.1.d-6 ) then
          xyzeps(iaux) = -1.d0
        endif
   23 continue
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,6))
      write (ulsort,1000) 'x', xyzmin(1), xyzmax(1), xyzeps(1)
      write (ulsort,1000) 'y', xyzmin(2), xyzmax(2), xyzeps(2)
      if ( sdim.eq.3 ) then
        write (ulsort,1000) 'z', xyzmin(3), xyzmax(3), xyzeps(3)
      endif
      write (ulsort,texte(langue,7)) xyzeps(4)
      endif
#endif
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
