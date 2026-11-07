      subroutine utdich ( chain1, chain2,
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
c   UTilitaire - teste la DIfference entre 2 CHaines de caracteres
c   --                    --                 --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . chain1 . e   .char*(*). chaine de caractere 1 a comparer           .
c . chain2 . e   .char*(*). chaine de caractere 2 a comparer           .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : chaines identiques                     .
c .        .     .        . 1 : longueurs identiques, contenu different.
c .        .     .        . 2 : longueurs differentes                  .
c .        .     .        . 10 : probleme de comparaison               .
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
      parameter ( nompro = 'UTDICH' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*(*) chain1, chain2
c
      integer ulsort, langue, codret
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lg1, lg2
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
      texte(1,10) = '(''Chaine'',i2,'' a comparer :'')'
      texte(1,4) = '(''Longueur de la chaine'',i2,'' = '',i8)'
      texte(1,5) = '(''La chaine est vide.'')'
c
      texte(2,10) = '(''String #'',i2,'' :'')'
      texte(2,4) = '(''Length of #'',i2,'' : '',i8)'
      texte(2,5) = '(''The string is empty.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) 1
      write (ulsort,*) chain1
      write (ulsort,texte(langue,10)) 2
      write (ulsort,*) chain2
#endif
c
      iaux = -1
c
c====
c 2. mesure des longueurs
c====
c
      call utlgut ( lg1, chain1, ulsort, langue, codret )
      if ( codret.eq.0 ) then
        call utlgut ( lg2, chain2, ulsort, langue, codret )
      endif
c
c====
c 3. comparaison
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 1, lg1
      write (ulsort,texte(langue,4)) 2, lg2
#endif
c
      if ( lg1.eq.lg2 ) then
        if ( chain1(1:lg1).eq.chain2(1:lg2) ) then
          iaux = 0
        else
          iaux = 1
        endif
      else
        iaux = 2
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
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      endif
c
      if ( iaux.ge.0 ) then
        codret = iaux
      else
        codret = 10
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      endif
c
      end
