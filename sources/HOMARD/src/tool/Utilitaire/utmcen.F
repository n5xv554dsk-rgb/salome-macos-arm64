      subroutine utmcen ( motcle, valeur, imopti,
     >                    ulsort, langue, codret)
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
c     UTilitaire : Mot-Cle - ENtier qui lui est associe
c     --           -   -     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . motcle . e   . char*8 . mot-cle a rechercher                       .
c . valeur .   s .   1    . valeur entiere associee au mot-cle         .
c . imopti . e   .   1    . choix d'impression en mode optimise        .
c .        .     .        . 0 : jamais                                 .
c .        .     .        . 1 : si codret = 2                          .
c .        .     .        . 2 : si codret = 2, 4                       .
c .        .     .        . 3 : si codret = 2 ou 5                     .
c .        .     .        . 4 : si codret = 2, 4 ou 5                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme au decodage du mot-cle        .
c .        .     .        . 4 : le mot-cle n'a pas ete defini          .
c .        .     .        . 5 : le mot-cle est defini plusieurs fois   .
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
      parameter ( nompro = 'UTMCEN' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 motcle
c
      integer imopti
      integer valeur
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
      integer loptio
      integer nombre, numero
c
      character*200 option
c
      character*5 fmtent
c
      integer nbmess
      parameter ( nbmess = 20 )
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
      texte(1,10) = '(''Option liee au mot-cle '',a8,'' :'')'
      texte(1,12) = '(''Elle est illisible.'')'
      texte(1,14) = '(''Elle n''''est pas definie.'')'
      texte(1,15) = '(''Elle est definie plusieurs fois.'')'
c
      texte(2,10) = '(''Option for keyword '',a8,'' :'')'
      texte(2,12) = '(''It cannot be read.'')'
      texte(2,14) = '(''It does not exist.'')'
      texte(2,15) = '(''It exists more than once.'')'
c
cgn      write (ulsort,texte(langue,10)) motcle
c
c====
c 2. entier associe
c====
c
c 2.1. ==> recherche du pseudo-fichier associe au mot-cle
c
      numero = 1
c
      call utfin1 ( motcle, numero,
     >              nombre, option, loptio,
     >              ulsort, langue, codre0 )
c
c 2.2. ==> aucune option n'a ete precisee
c
      if ( codre0.eq.2 ) then
c
        codret = 4
c
c 2.3. ==> definition multiple
c
      elseif ( codre0.eq.0 .and. nombre.gt.1 ) then
c
        codret = 5
c
c 2.4. ==> probleme de lecture
c
      elseif ( codre0.ne.0 ) then
c
        codret = 2
c
c 2.5. ==> decodage
c
      else
c
        fmtent = '(I  )'
        if ( loptio.lt.10 ) then
          write(fmtent(3:3),'(i1)') loptio
        else
          write(fmtent(3:4),'(i2)') loptio
        endif
        read ( option(1:loptio),fmtent) valeur
c
        codret = 0
c
      endif
c
c====
c 3. Messages
c====
c
#ifdef _DEBUG_HOMARD_
      if ( codret.ne.0 .and. imopti.ge.0 ) then
#else
      if ( ( imopti.eq.1 .and. codret.eq.2 ) .or.
     >     ( imopti.eq.2 .and.
     >       ( codret.eq.2 .or. codret.eq.4 ) ) .or.
     >     ( imopti.eq.3 .and. 
     >       ( codret.eq.2 .or. codret.eq.5 ) ) .or.
     >     ( imopti.eq.4 .and. 
     >       ( codret.eq.2 .or. codret.eq.4 .or. codret.eq.5 ) ) ) then
#endif
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,10)) motcle
      write (ulsort,texte(langue,10+codret))
c
      endif
c
      end
