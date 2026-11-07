      subroutine esecsu ( idfmed,
     >                    nomail,
     >                    nhnoeu,
     >                    nhmapo, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    infmgl,
     >                    dimcst, coocst,
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
c  Entree-Sortie : ECriture des informations SUpplementaires
c  -      -        --                        --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomail . e   . char*8 . structure du maillage a ecrire             .
c . infmgl . e   .   0:*  . 0 : nombre d'informations                  .
c .        .     .        . >0 : informations maillage globales        .
c . dimcst . e   .    1   . dimension de la coordonnee constante       .
c .        .     .        . eventuelle, 0 si toutes varient            .
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
      parameter ( nompro = 'ESECSU' )
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
      integer infmgl(0:*)
      integer numdt, numit
      integer dimcst
c
      character*8 nomail
      character*8 nhnoeu
      character*8 nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
c
      double precision coocst
      double precision instan
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
c
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Ecriture des informations supplementaires.'')'
      texte(1,7) = '(''Premieres valeurs : '',10i6)'
c
      texte(2,4) = '(''. Writings of additional information.'')'
      texte(2,7) = '(''First values : '',10i6)'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
      codret = 0
c
c====
c 2. Ecriture des informations entieres sous forme de profil
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. infos entieres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECS1', nompro
#endif
      call esecs1 ( idfmed,
     >              nomail,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 3. Ecriture des informations globales sous forme de profil
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. infos globales ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      noprof = blan64
c                     1234567890123456789012
      noprof(1:22) = 'Info_maillage_globales'
      iaux = infmgl(0)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
      write (ulsort,texte(langue,62)) iaux
      write (ulsort,texte(langue,7)) (infmgl(jaux), jaux = 1, iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW', nompro
#endif
      call mpfprw ( idfmed, noprof, iaux, infmgl(1), codret )
c
      endif
c
c====
c 4. Ecriture des renumerotations sous forme de profil
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. renumerotations ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECS2', nompro
#endif
      call esecs2 ( idfmed,
     >              nomail,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 5. Ecriture des recollements sous forme de profil
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. recollements ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECS3', nompro
#endif
      call esecs3 ( idfmed,
     >              nhnoeu,
     >              nhmapo, nharet, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 6. Ecriture de la dimension constante sous forme de variable scalaire
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. dimcst ; codret', codret
#endif
c
      if ( dimcst.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECS4', nompro
#endif
        call esecs4 ( idfmed,
     >                coocst,
     >                numdt, numit, instan,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c====
c 7. Ecriture des connectivites par aretes sous forme de profil
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. connectivite/aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECS5', nompro
#endif
      call esecs5 ( idfmed,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 8. la fin
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
