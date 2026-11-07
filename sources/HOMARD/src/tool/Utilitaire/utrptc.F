      subroutine utrptc ( nomobj,
     >                    nombre, lgtabl,
     >                    adpoin, adtail, adtabl,
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
c     UTilitaire : Recuperation d'un objet de type PtTabC08
c     --           -                               - -  -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomobj . es  . char8  . nom de l'objet PtTabC08                    .
c . nombre .   s .    1   . nombre d'entrees ; le tableau Pointeur est .
c .        .     .        . dimensionne (0:nombre)                     .
c . lgtabl .   s .    1   . longueur commune a Taille et Table         .
c . adpoin .   s .    1   . adresse de Pointeur                        .
c . adtail .   s .    1   . adresse de Taille                          .
c . adtabl .   s .    1   . adresse de Table                           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'UTRPTC' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*(*) nomobj
c
      integer nombre, lgtabl
      integer adpoin, adtail, adtabl
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
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
c 1. messages
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
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, nomobj )
        call gmprsx (nompro, nomobj )
        call gmprsx (nompro, nomobj//'.Pointeur' )
        call gmprsx (nompro, nomobj//'.Taille' )
        call gmprsx (nompro, nomobj//'.Table' )
#endif
c
c====
c 2. Recuperation
c====
c
      call gmliat ( nomobj, 1, nombre, codre1 )
      call gmadoj ( nomobj//'.Pointeur', adpoin, iaux, codre2 )
      call gmliat ( nomobj, 2, lgtabl, codre3 )
      call gmadoj ( nomobj//'.Taille', adtail, iaux, codre4 )
      call gmadoj ( nomobj//'.Table' , adtabl, iaux, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
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
