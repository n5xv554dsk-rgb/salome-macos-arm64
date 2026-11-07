      subroutine utchs8 ( chacar, lgchac, tabch8,
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
c   UTilitaire - transfere une CHaine dans un tableau de String*8
c   --                         --                        -      -
c
c   Remarque : on transfere stricto sensu le nombre de caracteres
c              demandes, sans se preoccuper de savoir s'il y a des
c              blancs ou des "mauvais" caracteres.
c   Remarque : si on est oblige d'entamer une nouvelle case du tableau,
c              on complete a droite par des blancs.
c
c   Exemple :
c
c   chacar = 'Sous le pont Mirabeau coule la Seine'
c             123456789012345678901234567890123456
c   lgchac = 36
c                           12345678
c   devient : tabch8 (1) = 'Sous le '
c             tabch8 (2) = 'pont Mir'
c             tabch8 (3) = 'abeau co'
c             tabch8 (4) = 'ule la S'
c             tabch8 (5) = 'eine    '
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . chacar . e   .char*(*). chaine de caractere                        .
c . lgchac . e   .    1   . nombre de caracteres a transferer          .
c . tabch8 .   s .   *    . tableau a remplir                          .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : chaine trop courte                     .
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
      parameter ( nompro = 'UTCHS8' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer lgchac
c
      character*8 tabch8(*)
      character*(*) chacar
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
      integer lencha, nbchar, nbpack
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
      texte(1,4) = '(''Chaine a transferer : '')'
      texte(1,5) = '(''La chaine est declaree en char*'',i4)'
      texte(1,6) = '(''mais on veut transferer '',i4,'' caracteres !'')'
c
      texte(2,4) = '(''String to convert : '')'
      texte(2,5) = '(''The string is declared as char*'',i4)'
      texte(2,6) = '(''but, '',i4,'' characters must be moved !'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,*) chacar
#endif
c
c====
c 2. verification de la longueur
c====
c
      codret = 0
c
      lencha = len(chacar)
      if ( lgchac.gt.lencha ) then
        codret = 1
      endif
c
c====
c 3. transfert
c====
c
      if ( codret.eq.0 ) then
c
      nbchar = mod(lgchac,8)
      nbpack = ( lgchac - nbchar ) / 8
c
      jaux = 1
      do 31 , iaux = 1 , nbpack
        tabch8(iaux) = chacar(jaux:jaux+7)
        jaux = jaux + 8
   31 continue
c
      if ( nbchar.gt.0 ) then
c                           12345678
        tabch8(nbpack+1) = '        '
        tabch8(nbpack+1)(1:nbchar) = chacar(jaux:jaux+nbchar-1)
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
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
        write (ulsort,texte(langue,4))
        write (ulsort,*) chacar
        write (ulsort,texte(langue,5)) lencha
        write (ulsort,texte(langue,6)) lgchac
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
