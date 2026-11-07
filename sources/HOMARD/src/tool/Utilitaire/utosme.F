      subroutine utosme ( typobs, ulsort, langue )
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
c       UTilitaire : Objet Structure - Message d'Erreur
c       --           -     -           -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typobs . e   .  ch8   . nom symbolique de l'objet                  .
c . ulsort . e   .    1   . unite logique d'impression                 .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
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
      parameter ( nompro = 'UTOSME' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      character*8 typobs
c
      integer ulsort, langue
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
c 1.  messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(1x,''Objet '',a,'' : recuperation impossible.'')'
c
      texte(2,4) = '(1x,''Object '',a,'': recovery is impossible.'')'
c
c====
c 2. message
c====
c
#ifdef _DEBUG_HOMARD_
      iaux = 1
#else
      if ( typobs.eq.mclist ) then
        iaux = 0
      else
        iaux = 1
      endif
#endif
c
      if ( iaux.eq.1 ) then
c
        write (ulsort,texte(langue,4)) typobs
c
      endif
c
      end
