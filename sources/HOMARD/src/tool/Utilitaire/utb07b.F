      subroutine utb07b ( tabaui, ulbila,
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
c    UTilitaire - Bilan sur le maillage - option 07 - impressions
c    --           -                              --
c ______________________________________________________________________
c
c    Imprime les statistiques sur les niveaux des mailles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tabaui .  a  .-nivsup . tableau de travail                         .
c .        .     . :nivsup.                                            .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB07B' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envada.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer tabaui(-nivsup-1:nivsup+1)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nbmess
      parameter (nbmess = 10 )
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
      texte(1,4) =
     >'(5x,''* . du niveau '',i3,28x,'' * '',i10,'' *'')'
      texte(1,5) =
     >'(5x,''* . du niveau '',i3,''.5'',26x,'' * '',i10,'' *'')'
c
      texte(2,4) =
     >'(5x,''* . from level '',i3,27x,'' * '',i10,'' *'')'
      texte(2,5) =
     >'(5x,''* . from level '',i3,''.5'',25x,'' * '',i10,'' *'')'
cgn      ulbila = ulsort
c
10200 format(  5x,60('*'))
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'maconf', maconf
      write (ulsort,90002) 'lg de tabaui = nivsup+1', nivsup+1
      write (ulsort,90002) 'tabaui',
     >                     (tabaui(iaux),iaux=-nivsup-1,nivsup+1)
#endif
c
c====
c 2. Recherche du niveau maximal atteint pour la categorie
c    en cours d'impression
c====
c
      jaux = -1
c
      do 21 , iaux = nivsup+1, 0, -1
c
        if ( iaux.le.nivsup .and.
     >      ( ( maconf.eq.-1 ) .or. ( maconf.eq.0 ) ) .and.
     >       tabaui(-iaux-1).ne.0 ) then
          jaux = iaux + 1
          goto 211
        endif
c
        if ( tabaui(iaux).ne.0 ) then
          jaux = iaux
          goto 211
        endif
c
   21 continue
c
  211 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '==> jaux', jaux
#endif
c
c====
c 3. Impressions
c====
c
      if ( jaux.ge.0 ) then
c
        write (ulbila,10200)
c
        do 31 , iaux = 0 , jaux
c
          if ( iaux.lt.jaux .or. tabaui(iaux).ne.0 ) then
            write (ulbila,texte(langue,4)) iaux, tabaui(iaux)
          endif
c
          if ( iaux.lt.jaux .and.
     >         ( ( maconf.eq.-1 ) .or. ( maconf.eq.0 ) ) ) then
            write (ulbila,texte(langue,5)) iaux, tabaui(-iaux-1)
          endif
c
   31   continue
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
