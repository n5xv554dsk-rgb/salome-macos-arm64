      subroutine cmnoim ( nomail,
     >                    indnoe, option,
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
c    Creation du Maillage - les NOeuds Internes aux Mailles
c    -           -              --     -            -
c ______________________________________________________________________
c
c but : gestion de la creation des noeuds internes aux mailles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . indnoe . es  . 1      . indice du dernier noeud cree               .
c . option . e   . 1      . 0 : decoupage standard                     .
c .        .     .        . 1 : decoupage de conformite                .
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
      parameter ( nompro = 'CMNOIM' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "envca1.h"
#include "nouvnb.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer indnoe
      integer option
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer phetno, pareno, pcoono
      integer phetar, psomar, pfilar, pnp2ar
      integer pcfano, pfamno
      integer paretr, phettr, pfiltr, adnmtr
      integer parequ, phetqu, pfilqu, adnmqu
      integer nnoeim
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
      texte(1,5) = '(5x,''Nombre de noeuds internes crees     : '',i10)'
      texte(1,8) =
     > '(5x,''Au depart, nombre de '',a,'' : '',i10)'
      texte(1,9) =
     > '(5x,''A la fin, nombre de '',a,'' : '',i10)'
c
      texte(2,5) = '(5x,''Number of internal nodes created: '',i10)'
      texte(2,8) =
     > '(5x,''At the beginning, number of created '',a,'': '',i10)'
      texte(2,9) =
     > '(5x,''At the end, number of created '',a,'': '',i10)'
c
#include "impr03.h"
c
c====
c 2. recuperation des pointeurs
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c 2.2. ==> tableaux
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 210
      call utad01 ( iaux, nhnoeu,
     >              phetno,
     >              pfamno, pcfano,   jaux,
     >              pcoono, pareno,   jaux,  jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 78
      call utad02 ( iaux, nharet,
     >              phetar, psomar, pfilar,  jaux,
     >                jaux,   jaux,   jaux,
     >              jaux  , pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nouvtr.ne.0  ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        iaux = 798
        call utad02 ( iaux, nhtria,
     >                phettr, paretr, pfiltr,  jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                adnmtr,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nouvqu.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        iaux = 798
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ, pfilqu,  jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                adnmqu,   jaux,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 3. creation effective des noeuds internes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. creation effective ; codret = ', codret
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,3,-1), indnoe
      write (ulsort,90002) 'nouvtr', nouvtr
      write (ulsort,90002) 'nouvqu', nouvqu
      write (ulsort,90002) 'permim', permim
      write (ulsort,90002) 'nouvim', nouvim
cgn      call gmprsx(nompro//' tria', nhtria//'.NoeuInMa')
cgn      call gmprsx(nompro//' quad', nhquad//'.NoeuInMa')
#endif
      nnoeim = indnoe
c
c 3.1. ==> Pour le decoupage de triangles
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNITR', nompro
#endif
      call utnitr ( rmem(pcoono),
     >              imem(phetno), imem(pareno), imem(pfamno),
     >              imem(psomar), imem(pnp2ar),
     >              imem(paretr), imem(phettr), imem(pfiltr),
     >              imem(adnmtr),
     >              indnoe, nouvno, nouvar, nouvtr,
     >              option,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) indnoe - nnoeim
#endif
c
      endif
c
c 3.2. ==> Pour le decoupage de quadrangles
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNIQU', nompro
#endif
      call utniqu ( rmem(pcoono),
     >              imem(phetno), imem(pareno), imem(pfamno),
     >              imem(phetar), imem(psomar), imem(pfilar),
     >              imem(pnp2ar),
     >              imem(adnmtr),
     >              imem(parequ), imem(phetqu), imem(pfilqu),
     >              imem(adnmqu),
     >              indnoe, nouvno, nouvar, nouvtr, nouvqu,
     >              option,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) indnoe - nnoeim
#endif
c
      endif
c
c 3.3. ==> Bilan
c
      if ( codret.eq.0 ) then
c
      nnoeim = indnoe - nnoeim
      write (ulsort,texte(langue,5)) nnoeim
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) mess14(langue,3,-1), indnoe
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
