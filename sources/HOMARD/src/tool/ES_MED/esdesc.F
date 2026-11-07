      subroutine esdesc ( idfmed, saux, descri,
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
c  Entree-Sortie - format MED - DESCription
c  -      -                     ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage de sortie                         .
c . saux   . e   .   1    . texte complementaire eventuel              .
c . descri .   s .   1    . description enregistree                    .
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
      parameter ( nompro = 'ESDESC' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envada.h"
#include "nuvers.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer ulsort, langue, codret
c
      character*(*) saux
      character*200 descri
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
      integer numann, datheu
c
      character*5 saux05
      character*48 ladate
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> les messages
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
      codret = 0
c
c====
c 2. description du fichier
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> Les 20 premiers caracteres ne doivent pas changer, de
c            maniere a assurer la compatibilite avec les logiciels
c            en couplage avec HOMARD
c
c       'HOMARD VN.P     NITER '
c        123456 12345678 I5    A50
c        12345678901234567890123456
c
      descri = ' '
      descri( 1: 6) = 'HOMARD'
      descri( 8:15) = nuvers
      call utench ( nbiter, 'D', iaux, saux05,
     >              ulsort, langue, codret )
      descri(17:21) = saux05
c
c 2.2. ==> Date de creation du fichier
c
      call utdhlg ( ladate, langue )
      descri(23:70) = ladate
c
c 2.3. ==> Eventuel texte libre
c
      call utlgut ( iaux, saux,
     >              ulsort, langue, codret )
      if ( codret.eq.0 .and.iaux.gt.0 ) then
        iaux = min(iaux,80)
        descri(81:80+iaux) = saux(1:iaux)
      else
        codret = 0
      endif
c
c 2.4. ==> Copyright
c                        2345678901234567890
      descri(142:160) = 'Copyright 1996 EDF,'
c                        23456789012345678901
      descri(162:181) = ' Copyright 2015 EDF,'
c                        2345678901
      descri(182:191) = ' Copyright'
      call utdhco ( numann, datheu )
      call utench ( numann, 'D', iaux, saux05,
     >              ulsort, langue, codret )
      descri(192:196) = saux05
c                        7890
      descri(197:200) = ' EDF'
      endif
c
c 2.5. ==> Appel du programme MED
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,47)) descri
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFICOW', nompro
#endif
      call mficow ( idfmed, descri, codret )
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,78)) 'mficow', codret
        write(ulsort,texte(langue,80))
        write(ulsort,texte(langue,47)) descri
      endif
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
