      subroutine esecs4 ( idfmed,
     >                    coocst,
     >                    numdt, numit, instan,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : ECriture des informations Supplementaires - 4
c  -      -        --                        -                 -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . coocst . e   .    1   . coordonnee constante eventuelle            .
c . numdt  . e   .   1    . numero du pas de temps                     .
c . numit  . e   .   1    . numero d'iteration                         .
c . instan . e   .   1    . pas de temps                               .
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
      parameter ( nompro = 'ESECS4' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer numdt, numit
c
      double precision coocst
      double precision instan
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
c
      character*16 dtunit
      character*64 novals
      character*200 sau200
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c
c ______________________________________________________________________
c
c====
c 1. initialisation
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
      texte(1,4) = '(''... Ecriture de la dimension constante '',g15.8)'
      texte(1,5) = '(/,''..... pour les '',a)'
c
      texte(2,4) = '(''... Writings of constant dimension '',g15.8)'
      texte(2,5) = '(/,''..... for '',a)'
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) coocst
#endif
c
c====
c 2. Ecriture sous forme de valeur scalaire
c====
c
c 2.1. ==> Creation de la variable scalaire
c
      if ( codret.eq.0 ) then
c
      novals = blan64
c                     1234567890123
      novals(1:13) = 'Dim_Constante'
c
      jaux = edfl64
      sau200(1:64) = novals
      do 21 , iaux = 65 , 200
        sau200(iaux:iaux) = ' '
   21 continue
      dtunit = blan16
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPRCRE', nompro
#endif
      call mprcre ( idfmed, novals, jaux, sau200, dtunit, codret )
c
      endif
c
c 2.2. ==> Ecriture de la valeur
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPRRVW', nompro
#endif
      call mprrvw ( idfmed, novals, numdt, numit, instan,
     >              coocst, codret )
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
      write (ulsort,texte(langue,4)) coocst
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
