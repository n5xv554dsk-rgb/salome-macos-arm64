      subroutine esecno ( idfmed, nomamd,
     >                    nhnoeu,
     >                    numdt, numit, instan,
     >                    ltbiau, tbiaux,
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
c  Entree-Sortie : ECriture des NOeuds
c  -      -        --           --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . ltbiau . e   .    1   . longueur allouee a tbiaux                  .
c . tbiaux .     .    *   . tableau tampon entier                      .
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
      parameter ( nompro = 'ESECNO' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
#include "gmreel.h"
c
#include "envca1.h"
#include "nombno.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer numdt, numit
      integer ltbiau, tbiaux(*)
c
      character*8 nhnoeu
      character*64 nomamd
c
      double precision instan
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
      integer adcoor, adhist, adarno
      integer adhono, addera
      integer adcoco, adinfg
      integer adreco
      integer adfami, adcofa
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''. Ecriture des noeuds.'')'
c
      texte(2,4) = '(''. Writings of nodes.'')'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
ccc      call gmprsx ( nompro, nhnoeu )
ccc      call gmprsx ( nompro, nhnoeu//'.HistEtat' )
c
c====
c 2. Adresses
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD21', nompro
#endif
      call utad21 ( nhnoeu,
     >              adcoor, adhist, adarno,
     >              adhono, addera,
     >              adcoco, adinfg,
     >              adreco,
     >              adfami, adcofa,
     >              ulsort, langue, codret )
c
c====
c 3. Ecritures
c====
c 3.1. ==> Ecriture de la connectivite et des familles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. connectivite ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMNO', nompro
#endif
      call esemno ( idfmed, nomamd,
     >              nbnoto, sdim, rmem(adcoor), imem(adfami),
     >              numdt, numit, instan,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2. ==> Ecriture des complements
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. complements ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECN1', nompro
#endif
      call esecn1 ( idfmed, nomamd,
     >              adhist, adarno,
     >              adhono, addera,
     >              numdt, numit, instan,
     >              ltbiau, tbiaux,
     >              ulsort, langue, codret )
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
