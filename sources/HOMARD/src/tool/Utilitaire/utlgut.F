      subroutine utlgut ( lgchai, chaine,
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
c   UTilitaire - retourne la LonGueur UTile d'une chaine de caractere
c   --                       -  -     --
c
c   en gros, on elimine les blancs a droite
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgchai .   s .    1   . longueur de la chaine obtenue              .
c . chaine . e   .char*(*). chaine de caractere a mesurer              .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : impossible de trouver la longueur      .
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
      parameter ( nompro = 'UTLGUT' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer lgchai
c
      character*(*) chaine
c
      integer ulsort, langue, codret
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
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
      texte(1,4) = '(''Chaine a mesurer : '',a)'
      texte(1,5) = '(''Longueur = '',i8)'
      texte(1,6) = '(''La chaine est vide.'')'
c
      texte(2,4) = '(''String : '',a)'
      texte(2,5) = '(''Length = '',i8)'
      texte(2,6) = '(''The string is empty.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) chaine
#endif
c
c====
c 2. mesure
c====
c
      codret = 0
c
      jaux = len(chaine)
      if ( jaux.eq.0 ) then
        lgchai = -1
        codret = 1
      endif
c
      if ( codret.eq.0 ) then
c
      do 21 , iaux = jaux, 1, -1
        if ( chaine(iaux:iaux).ne.' ' ) then
          lgchai = iaux
          goto 22
        endif
   21 continue
c
      lgchai = 0
c
   22 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) lgchai
#endif
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4)) chaine
      write (ulsort,texte(langue,6))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
