      subroutine utmess ( messag, nblxms, nblims,
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
c    UTilitaire - MESSages
c    --           ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . messag .  s  . ch<200 . nom du fichier de configuration            .
c . nblxms . e   .    1   . nombre de lignes maximum du message        .
c . nblims .  s  .    1   . nombre de lignes du message                .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'UTMESS' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nblxms, nblims
c
      character*40 messag(nblang,*)
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
c ______________________________________________________________________
c
c====
c 1. initialisations des messages
c====
c
      codret = 0
c
#include "impr01.h"
c
#ifdef NEPTUNE
      messag(1,1) = 'Cette version est destinee exclusivement'
      messag(1,2) = '     au couplage avec Code_Neptune.     '
      messag(2,1) = '      Use with Code_Neptune only        '
      messag(2,2) = '                                        '
      iaux = 2
#else
#ifdef SATURNE
      messag(1,1) = 'Cette version est destinee exclusivement'
      messag(1,2) = '     au couplage avec Code_Saturne.     '
      messag(2,1) = '      Use with Code_Saturne only        '
      messag(2,2) = '                                        '
      iaux = 2
#else
#ifdef ESTEL
c                    1234567890123456789012345678901234567890
      messag(1,1) = 'Cette version est destinee exclusivement'
      messag(1,2) = '     au couplage avec ESTEL_3D.         '
      messag(1,3) = '  Simulation dans le systeme Telemac    '
      messag(2,1) = '        Use with ESTEL_3D only          '
      messag(2,2) = '      Simulation in Telemac system      '
      messag(2,3) = '                                        '
      iaux = 3
#else
#ifdef ASTER
      messag(1,1) = 'Cette version est destinee exclusivement'
      messag(1,2) = '      au couplage avec Code_Aster.      '
      messag(2,1) = '       Use with Code_Aster only         '
      messag(2,2) = '                                        '
      iaux = 2
#else
#ifdef CEA
      messag(1,1) = '   Cette version est destinee au CEA    '
      messag(1,2) = '  exclusivement pour des travaux de R&D '
      messag(1,3) = ' Aucune commercialisation des resultats '
      messag(1,4) = '  n''est possible sans autorisation EDF. '
      messag(2,1) = '      This release is given to CEA      '
      messag(2,2) = '          for R&D studies only.         '
      messag(2,3) = '            No trade is allowed         '
      messag(2,4) = '         without EDF authorization      '
      iaux = 4
#else
#ifdef SALOME
      messag(1,1) = '    Usage exclusivement avec SALOME     '
      messag(2,1) = '          Use with SALOME only          '
      iaux = 1
#else
      messag(1,1) = '    Usage exclusivement avec SALOME     '
      messag(2,1) = '          Use with SALOME only          '
      iaux = 1
c                    1234567890123456789012345678901234567890
#endif
#endif
#endif
#endif
#endif
#endif
c
c====
c 2. controle
c====
c
      if ( iaux.le.nblxms ) then
        nblims = iaux
      else
        codret = 1
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
