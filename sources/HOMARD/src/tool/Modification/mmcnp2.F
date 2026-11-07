      subroutine mmcnp2 ( nomail, nhnoeu, nharet,
     >                    indnoe,
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
c  Modification de Maillage - DEGRe
c  -               -          ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . nhnoeu . e   .  ch8   . branche des noeuds dans le maillage        .
c . nharet . e   .  ch8   . branche des aretes dans le maillage        .
c . indnoe . es  . 1      . indice du dernier noeud cree               .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'MMCNP2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "envca1.h"
c
#include "nombar.h"
#include "nombno.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
      character*8 nhnoeu, nharet
c
      integer indnoe
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre0
      integer codre1, codre2, codre3, codre4
      integer phetno, pareno, pcoono
      integer pfamno, pnp2ar
      integer un
      integer iaux, jaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
#include "impr01.h"
c ______________________________________________________________________
c
c====
c 1. Reallocation des tableaux
c====
c
      if ( codret.eq.0 ) then
c
      un = 1
c
      call gmmod ( nhnoeu//'.Coor',
     >             pcoono, nbnoto, nouvno, sdim, sdim, codre1 )
      call gmmod ( nhnoeu//'.HistEtat',
     >             phetno, nbnoto, nouvno, un, un, codre2 )
      call gmmod ( nhnoeu//'.AretSupp',
     >             pareno, nbnoto, nouvno, un, un, codre3 )
      call gmmod ( nhnoeu//'.Famille.EntiFamm',
     >             pfamno, nbnoto, nouvno, un, un, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( nharet//'.InfoSupp', ' ', nbarto, pnp2ar, codre0 )
      codret = max ( abs(codre0), codret )
c
      endif
c
c====
c 2. creation des noeuds
c====
c
      if ( codret.eq.0 ) then
c
      jaux = pnp2ar + nbarto - 1
      do 21 , iaux = pnp2ar , jaux
        imem(iaux) = 0
   21 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMNO22', nompro
#endif
      call cmno22 ( nomail,
     >              indnoe, 1, nouvar,
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
      end
