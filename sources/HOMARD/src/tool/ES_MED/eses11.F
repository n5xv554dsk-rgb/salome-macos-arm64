      subroutine eses11 ( idfmed, nomcha,
     >                    nbcomp, typcha,
     >                    nomcmp, unicmp,
     >                    dtunit, nomamd,
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
c  Entree-Sortie - Ecriture d'une Solution au format MED - phase 1.1
c  -      -        -              -                              - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med en sortie       .
c . nomcha . e   . char64 . nom du champ                               .
c . nbcomp . e   .    1   . nombre de composantes                      .
c . typcha . e   .   1    . edin64/edfl64 selon entier/reel            .
c . nomcmp . e   . nbcomp . noms des composantes                       .
c . unicmp . e   . nbcomp . unites des composantes                     .
c . dtunit . e   .   1    . unite des pas de temps                     .
c . nomamd . e   . char64 . nom du maillage MED                        .
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
      parameter ( nompro = 'ESES11' )
c
#include "nblang.h"
#include "consts.h"
c
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer nbcomp, typcha
c
      character*64 nomcha
      character*16 nomcmp(nbcomp), unicmp(nbcomp)
      character*16 dtunit
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "esimpr.h"
c
      texte(1,4) = '(/,''Creation du champ : '',a)'
      texte(1,5) = '(''Type du champ : '',i2)'
      texte(1,6) =
     > '(''Numero !     Composante     !       Unite'',/,49(''-''))'
      texte(1,7) = '(i6,'' !  '',a16,''  !  '',a16)'
      texte(1,8) = '(''Unite du pas de temps : '',a)'
c
      texte(2,4) = '(/,''Creation of field: '',a)'
      texte(2,5) = '(''Type of field: '',i2)'
      texte(2,6) =
     > '(''  #    !     Component      !       Unit'',/,49(''-''))'
      texte(2,7) = '(i6,'' !  '',a16,''  !  '',a16)'
      texte(2,8) = '(''Time step unity: '',a)'
c
#include "impr03.h"
c
c====
c 2. creation du champ
c====
c
      call utlgut ( iaux, nomcha, ulsort, langue, codret )
c
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,4)) nomcha(1:iaux)
      write (ulsort,texte(langue,5)) typcha
      write (ulsort,texte(langue,6))
      do 20 , iaux = 1 , nbcomp
        write (ulsort,texte(langue,7)) iaux, nomcmp(iaux), unicmp(iaux)
   20 continue
      call utlgut ( iaux, dtunit, ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( iaux.gt.0 ) then
      write (ulsort,texte(langue,8)) dtunit
      endif
c
      endif
c
c====
c 3. creation du champ
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. creation du champ ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDCRE', nompro
#endif
      call mfdcre ( idfmed, nomcha, typcha,
     >              nbcomp, nomcmp, unicmp,
     >              dtunit, nomamd, codret )
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,13)) nomcha
      endif
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
