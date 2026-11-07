      subroutine uglanm ( lang , ulsort, codret )
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
c    Utilitaires des Gestionnaires : LANgue des Messages
c    -               -               ---        -
c ______________________________________________________________________
c
c   modifie la langue des messages des gestionnaires
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lang   . e   .   1    . code de la langue souhaitee                .
c .        .     .        . 1 : francais                               .
c .        .     .        . 2 : anglais                                .
c . ulsort . e   .   1    . unite logique d'impression des messages    .
c . codret .  s  .    1   . 0 : tout va bien                           .
c .        .     .        . 2 : problemes pour la memoire              .
c .        .     .        . 3 : problemes pour les unites logiques     .
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
      parameter ( nompro = 'UGLANM' )
c
#include "genbla.h"
#include "gelggt.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer lang , ulsort
      integer codret
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
c
      integer tabges(lgtage)
c
      integer guimp, gmimp, raison
      integer code
      integer langue
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
      codret = 0
c
#include "impr01.h"
c
      texte(1,10) = '(''Le numero de langue '',i2,'' pour les'')'
      texte(1,4) = '(''messages des gestionnaires est incorrect.'')'
      texte(1,5) = '(''Il doit etre compris entre 1 et '',i8)'
c
      texte(2,10) = '(''The language code # '',i2,'' wanted for'')'
      texte(2,4) = '(''managers messages is not correct.'')'
      texte(2,5) = '(''It must be included between 1 and '',i8)'
c
c====
c 2. recuperation de l'information
c===
c
      code = 1
      call ugtabl ( code, tabges, ulsort)
c
      langue = tabges(4)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 3. verification de la validite du numero.
c    Il faut que le numero soit compris entre 1 et le nombre maximal
c    de langues.
c====
c
      if ( lang.lt.1 .or. lang.gt.nblang ) then
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,10)) lang
        write (ulsort,texte(langue,4))
        write (ulsort,texte(langue,5)) nblang
c
        guimp = 1
        gmimp = 0
        raison = 1
        call ugstop (nompro,ulsort,guimp, gmimp, raison)
c
      endif
c
c====
c 4. changement dans les differents gestionnaires
c====
c
      call gmlanm ( lang )
      call gtlanm ( lang )
      call gulanm ( lang, codret )
c
c====
c 5. archivage du numero
c====
c
      if ( codret.eq.0 ) then
c
        tabges(4) = lang
c
        code = 0
        call ugtabl ( code, tabges, ulsort)
c
      endif
c
      end
