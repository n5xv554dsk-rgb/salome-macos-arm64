      subroutine utb17e ( typent, nbensc, aubord, nbensb,
     >                    ulbila,
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
c    UTilitaire - Bilan sur le maillage - option 17 - phase e
c    --           -                              --         -
c ______________________________________________________________________
c
c impression
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typent . e   .   1    . type d'entites                             .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c .        .     .        .   8 : triangle et quadrangle               .
c .        .     .        .   9 : melange de volumes                   .
c . nbensc . e   .   1    . nombre d'entites surcontraintes            .
c . aubord . e   .   1    . vrai si au moins une maille est au bord    .
c . nbensb . e   .   1    . nombre d'entites sans mailles de bord      .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB17E' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typent
      integer nbensc, nbensb
c
      logical aubord
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
c
      character*43 mess43(nblang,110)
c
      integer nbmess
      parameter (nbmess = 10 )
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
c                     1234567890123456789012345678901234567890123
      mess43(1,1)  = 'Nombre d''elements surcontraints            '
      mess43(1,2)  = 'Nombre d''elements sans mailles de bord     '
c
c                     1234567890123456789012345678901234567890123
      mess43(2,1)  = 'Number of overstressed elements            '
      mess43(2,2)  = 'Number of elements without boundary meshes '
c
10100 format(/,5x,60('*'))
10200 format(  5x,60('*'))
c
11200 format(  5x,'* ',21x,a14,21x,' *')
c
12200 format(  5x,'* ',a43,' * ', i10,' *')
c
      codret = 0
c
c====
c 2. impression
c====
c
      write (ulbila,10100)
      write (ulbila,11200) mess14(langue,4,typent)
      write (ulbila,10200)
      write (ulbila,12200) mess43(langue,1), nbensc
      if ( aubord ) then
        write (ulbila,12200) mess43(langue,2), nbensb
      endif
      write (ulbila,10200)
c
c====
c 3. La fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
