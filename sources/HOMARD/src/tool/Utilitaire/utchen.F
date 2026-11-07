      subroutine utchen ( chaine, entier,
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
c   UTilitaire - convertit une CHaine de caractere en ENtier
c   --                         --                     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . chaine . e   .char*(*). chaine de caractere                        .
c . entier .  s  .    1   . entier associe                             .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : chaine trop courte                     .
c .        .     .        . 2 : le nombre est trop grand               .
c .        .     .        . 3 : type de cadrage inconnu                .
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
      parameter ( nompro = 'UTCHEN' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer entier
c
      character*(*) chaine
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lgchai
c
      character*5 fmtent
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Chaine a convertir : '',a)'
      texte(1,5) = '(''La chaine est blanche.'')'
c
      texte(2,4) = '(''String to convert : '',a)'
      texte(2,5) = '(''The string is blank.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) chaine
#endif
c
c====
c 2. decodage
c====
c
      codret = 0
c
c 2.1. ==> longueur reelle de la chaine
c
      call utlgut ( lgchai, chaine,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'lgchai', lgchai
#endif
c
c 2.2. ==> decodage
c
      if ( codret.eq.0 ) then
c
      if ( lgchai.eq.0 ) then
        codret = 22
      else
        fmtent = '(I  )'
        if ( lgchai.lt.10 ) then
          write(fmtent(3:3),'(i1)') lgchai
        else
          write(fmtent(3:4),'(i2)') lgchai
        endif
        read (chaine,fmtent) entier
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
      write (ulsort,texte(langue,4)) chaine
      if ( codret.eq.22 ) then
        write (ulsort,texte(langue,5))
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
