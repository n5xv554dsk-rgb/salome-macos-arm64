      subroutine pppma2 ( vafomi, vafoma,
     >                    typcof, nbtrvi, nbquvi,
     >                    fotrva, foquva,
     >                    ulsost,
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
c     Post-Processeur - Preparation du MAillage - phase 2
c     -    -            -              --               -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . vafomi .  s  .   1    . minimum de l'echelle de la fonction        .
c . vafoma .  s  .   1    . maximum de l'echelle de la fonction        .
c . typcof . e   .   1    . type de coloriage des faces                .
c .        .     .        .   0 : incolore transparent                 .
c .        .     .        .   1 : incolore opaque                      .
c .        .     .        .   2 : famille HOMARD                       .
c .        .     .        .   3 : famille HOMARD, sans orientation     .
c .        .     .        .   4/5 : idem 2/3, en niveau de gris        .
c .        .     .        . +-6 : couleur selon un champ, echelle auto..
c .        .     .        . +-7 : idem avec echelle fixe               .
c .        .     .        . +-8/+-9 : idem +-6/+-7, en niveau de gris  .
c .        .     .        .  10 : niveau                               .
c . nbtrvi . e   .   1    . nombre triangles visualisables             .
c . nbquvi . e   .   1    . nombre de quadrangles visualisables        .
c . fotrva . e   . nbtrvi . fonctions triangles : valeur               .
c . foquva . e   . nbquvi . fonctions quadrangles : valeur             .
c . ulsost . e   .   1    . unite logique de la sortie standard        .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'PPPMA2' )
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
      integer typcof
      integer nbtrvi, nbquvi
      integer ulsost
c
      double precision vafomi, vafoma
      double precision fotrva(nbtrvi), foquva(nbquvi)
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
c_______________________________________________________________________
c
c====
c 1. les messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Type de coloriage :'',i6)'
      texte(1,5) = '(''Fonction sur les '',a)'
      texte(1,6) = '(''min = '',g12.5,'', max = '',g12.5)'
c
      texte(2,4) = '(''Colouring type :'',i6)'
      texte(2,5) = '(''Function over '',a)'
      texte(2,6) = '(''min = '',g12.5,'', max = '',g12.5)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) typcof
      write (ulsort,90002) 'nbtrvi', nbtrvi
      write (ulsort,90002) 'nbquvi', nbquvi
#endif
cgn      write (ulsort,*) 'fotrva'
cgn      write (ulsort,92010) (fotrva(iaux), iaux = 1 , nbtrvi)
cgn      write (ulsort,*) 'foquva'
cgn      write (ulsort,92010) (foquva(iaux), iaux = 1 , nbquvi)
c
c====
c 2. fonction exprimee sur les triangles
c====
c
      if ( nbtrvi.ne.0 ) then
c
c 2.1. ==> valeur brute
c
        if ( typcof.gt.0 ) then
c
          vafomi = fotrva(1)
          vafoma = vafomi
c
          do 21 , iaux = 2 , nbtrvi
            vafomi = min (vafomi,fotrva(iaux))
            vafoma = max (vafoma,fotrva(iaux))
   21     continue
c
c 2.2. ==> valeur absolue
c
        else
c
          vafomi = abs(fotrva(1))
          vafoma = vafomi
c
          do 22 , iaux = 2 , nbtrvi
            vafomi = min (vafomi,abs(fotrva(iaux)))
            vafoma = max (vafoma,abs(fotrva(iaux)))
   22     continue
c
        endif
c
#ifdef _DEBUG_HOMARD_
        iaux = 2
        write (ulsort,texte(langue,5)) mess14(langue,3,iaux)
        write (ulsort,texte(langue,6)) vafomi, vafoma
        if ( ulsost.ne.ulsort ) then
          write (ulsost,texte(langue,5)) mess14(langue,3,iaux)
          write (ulsost,texte(langue,6)) vafomi, vafoma
        endif
#endif
c
      endif
c
c====
c 3. fonction exprimee sur les quadrangles
c====
c
      if ( nbquvi.ne.0 ) then
c
c 3.1. ==> valeur brute
c
        if ( typcof.gt.0 ) then
c
          if ( nbtrvi.eq.0 ) then
            vafomi = foquva(1)
            vafoma = vafomi
          endif
c
          do 31 , iaux = 2 , nbquvi
            vafomi = min (vafomi,foquva(iaux))
            vafoma = max (vafoma,foquva(iaux))
   31     continue
c
c 3.2. ==> valeur absolue
c
        else
c
          if ( nbtrvi.eq.0 ) then
            vafomi = abs(foquva(1))
            vafoma = vafomi
          endif
c
          do 32 , iaux = 2 , nbquvi
            vafomi = min (vafomi,abs(foquva(iaux)))
            vafoma = max (vafoma,abs(foquva(iaux)))
   32     continue
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( nbquvi.ne.0 ) then
c
        if ( nbtrvi.eq.0 ) then
          iaux = 4
        else
          iaux = 8
        endif
c
        write (ulsort,texte(langue,5)) mess14(langue,3,iaux)
        write (ulsost,texte(langue,5)) mess14(langue,3,iaux)
        write (ulsort,texte(langue,6)) vafomi, vafoma
        write (ulsost,texte(langue,6)) vafomi, vafoma
c
      endif
#endif
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
