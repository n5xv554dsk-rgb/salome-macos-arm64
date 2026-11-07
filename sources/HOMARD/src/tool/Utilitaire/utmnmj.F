      subroutine utmnmj ( option, chaine, lgchai,
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
c   UTilitaire - convertit MiNuscule/MaJuscule
c   --                     - -       - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . option de la conversion                    .
c .        .     .        . 1 : de minuscule a majuscule               .
c .        .     .        . 2 : de majuscule a minuscule               .
c .        .     .        . si negatif, on interdit tout caractere     .
c .        .     .        . non alphabetique                           .
c . chaine . es  .char*(*). chaine de caractere a convertir            .
c . lgchai .   s .    1   . longueur de la chaine traitee              .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : mauvaise option                        .
c .        .     .        . 2 : il existe un caractere non alphabetique.
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
      parameter ( nompro = 'UTMNMJ' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer option, lgchai
c
      character*(*) chaine
c
      integer ulsort, langue, codret
c
      character*01 saux01
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.4. ==> variables locales
c
      integer iaux
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
      texte(1,4) = '(''Chaine a convertir : '',a)'
      texte(1,5) = '(''Chaine convertie : '',a)'
      texte(1,6) = '(''Longueur = '',i8)'
      texte(1,7) = '(''Option : '',i8)'
      texte(1,8) = '(''Cette option est inconnue.'')'
c
      texte(2,4) = '(''String before conversion : '',a)'
      texte(2,5) = '(''String after conversion : '',a)'
      texte(2,6) = '(''Length = '',i8)'
      texte(2,7) = '(''Option : '',i8)'
      texte(2,8) = '(''This option is unknown.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) chaine
#endif
c
c====
c 2. Longueur de la chaine
c====
c
      call utlgut ( lgchai, chaine,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) lgchai
#endif
c
c====
c 3. Modification
c====
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> De minuscule a majuscule
c
      if ( abs(option).eq.1 ) then
c
        do 31 , iaux = 1 , lgchai
c
          saux01 = chaine(iaux:iaux)
c
          if ( saux01.eq.'a' ) then
            saux01 = 'A'
          elseif ( saux01.eq.'b' ) then
            saux01 = 'B'
          elseif ( saux01.eq.'c' ) then
            saux01 = 'C'
          elseif ( saux01.eq.'d' ) then
            saux01 = 'D'
          elseif ( saux01.eq.'e' ) then
            saux01 = 'E'
          elseif ( saux01.eq.'f' ) then
            saux01 = 'F'
          elseif ( saux01.eq.'g' ) then
            saux01 = 'G'
          elseif ( saux01.eq.'h' ) then
            saux01 = 'H'
          elseif ( saux01.eq.'i' ) then
            saux01 = 'I'
          elseif ( saux01.eq.'j' ) then
            saux01 = 'J'
          elseif ( saux01.eq.'k' ) then
            saux01 = 'K'
          elseif ( saux01.eq.'l' ) then
            saux01 = 'L'
          elseif ( saux01.eq.'m' ) then
            saux01 = 'M'
          elseif ( saux01.eq.'n' ) then
            saux01 = 'N'
          elseif ( saux01.eq.'o' ) then
            saux01 = 'O'
          elseif ( saux01.eq.'p' ) then
            saux01 = 'P'
          elseif ( saux01.eq.'q' ) then
            saux01 = 'Q'
          elseif ( saux01.eq.'r' ) then
            saux01 = 'R'
          elseif ( saux01.eq.'s' ) then
            saux01 = 'S'
          elseif ( saux01.eq.'t' ) then
            saux01 = 'T'
          elseif ( saux01.eq.'u' ) then
            saux01 = 'U'
          elseif ( saux01.eq.'v' ) then
            saux01 = 'V'
          elseif ( saux01.eq.'w' ) then
            saux01 = 'W'
          elseif ( saux01.eq.'x' ) then
            saux01 = 'X'
          elseif ( saux01.eq.'y' ) then
            saux01 = 'Y'
          elseif ( saux01.eq.'z' ) then
            saux01 = 'Z'
          else
            if ( option.lt.0 ) then
              codret = 2
            endif
          endif
c
          chaine(iaux:iaux) = saux01
c
   31   continue
c
c 3.2. ==> De majuscule a minuscule
c
      elseif ( abs(option).eq.2 ) then
c
        do 32 , iaux = 1 , lgchai
c
          saux01 = chaine(iaux:iaux)
c
          if ( saux01.eq.'A' ) then
            saux01 = 'a'
          elseif ( saux01.eq.'B' ) then
            saux01 = 'b'
          elseif ( saux01.eq.'C' ) then
            saux01 = 'c'
          elseif ( saux01.eq.'D' ) then
            saux01 = 'd'
          elseif ( saux01.eq.'E' ) then
            saux01 = 'e'
          elseif ( saux01.eq.'F' ) then
            saux01 = 'f'
          elseif ( saux01.eq.'G' ) then
            saux01 = 'g'
          elseif ( saux01.eq.'H' ) then
            saux01 = 'h'
          elseif ( saux01.eq.'I' ) then
            saux01 = 'i'
          elseif ( saux01.eq.'J' ) then
            saux01 = 'j'
          elseif ( saux01.eq.'K' ) then
            saux01 = 'k'
          elseif ( saux01.eq.'L' ) then
            saux01 = 'l'
          elseif ( saux01.eq.'M' ) then
            saux01 = 'm'
          elseif ( saux01.eq.'N' ) then
            saux01 = 'n'
          elseif ( saux01.eq.'O' ) then
            saux01 = 'o'
          elseif ( saux01.eq.'P' ) then
            saux01 = 'p'
          elseif ( saux01.eq.'Q' ) then
            saux01 = 'q'
          elseif ( saux01.eq.'R' ) then
            saux01 = 'r'
          elseif ( saux01.eq.'S' ) then
            saux01 = 's'
          elseif ( saux01.eq.'T' ) then
            saux01 = 't'
          elseif ( saux01.eq.'U' ) then
            saux01 = 'u'
          elseif ( saux01.eq.'V' ) then
            saux01 = 'v'
          elseif ( saux01.eq.'W' ) then
            saux01 = 'w'
          elseif ( saux01.eq.'X' ) then
            saux01 = 'x'
          elseif ( saux01.eq.'Y' ) then
            saux01 = 'y'
          elseif ( saux01.eq.'Z' ) then
            saux01 = 'z'
          else
            if ( option.lt.0 ) then
              codret = 2
            endif
          endif
c
          chaine(iaux:iaux) = saux01
c
   32   continue
c
c 3.3. ==> Mauvaise option
c
      else
c
        write (ulsort,texte(langue,7)) option
        write (ulsort,texte(langue,8))
        codret = 1
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) chaine
#endif
      endif
c
c====
c 4. La fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4)) chaine
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
