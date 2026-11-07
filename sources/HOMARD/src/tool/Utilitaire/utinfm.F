      subroutine utinfm ( numfam, nomfam,
     >                    nbrgrf, nomgrf,
     >                    nbnofa, nbmafa,
     >                    ulsort, langue, codret )
c
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
c  Entree-Sortie - UTilitaire - INformation sur les Familles MED
c  -      -        -            --                  -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numfam . e   .   1    . numero de la famille a decrire             .
c . nomfam . e   .char*64 . nom de la famille a decrire                .
c . nbnofa . e   .   1    . nombre de noeuds dans cette famille        .
c . nbmafa . e   .   1    . nombre de mailles dans cette famille       .
c . nbrgrf . e   .   1    . nombre de groupes dans cette famille       .
c . nomgrf . e   .10*nbgrf. noms des groupes dans cette famille        .
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
      parameter ( nompro = 'UTINFM' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer numfam
      integer nbnofa, nbmafa, nbrgrf
c
      integer ulsort, langue, codret
c
      character*8 nomgrf(10*nbrgrf)
      character*64 nomfam
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
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
      texte(1,4) = '(''*   Famille : '',a64,5x,''*'')'
      texte(1,5) = '(''*   Numero  : '',i8,61x,''*'')'
      texte(1,9) = '(''*   Nombre de groupes  : '',i8,50x,''*'')'
      texte(1,10) =
     > '(''*'',10x,''Groupe(s) correspondant(s) :'',44x,''*'')'
      texte(1,17) = '(''*   Nombre de noeuds    : '',i8,49x,''*'')'
      texte(1,18) = '(''*   Nombre de noeuds inconnus.'',53x,''*'')'
      texte(1,19) = '(''*   Nombre de mailles   : '',i8,49x,''*'')'
      texte(1,20) = '(''*   Nombre de mailles inconnues.'',51x,''*'')'
c
      texte(2,4) = '(''*   Family  : '',a64,5x,''*'')'
      texte(2,5) = '(''*   #       : '',i8,61x,''*'')'
      texte(2,9) = '(''*   Number of groups     : '',i8,54x,''*'')'
      texte(2,10) = '(''*'',8x,''Associated group(s)'',55x,''*'')'
      texte(2,17) = '(''*   Number of nodes     : '',i8,49x,''*'')'
      texte(2,18) = '(''*   Number of nodes is unknown.'',52x,''*'')'
      texte(2,19) = '(''*   Number of meshes  : '',i8,47x,''*'')'
      texte(2,20) = '(''*   Number of meshes is unknown.'',47x,''*'')'
c
10001 format(/)
10002 format(84('*'))
10003 format('* ',a80,' *')
10004 format('* ',10a8,' *')
c
c====
c 2. affichage
c====
c
      write (ulsort,10001)
      write (ulsort,10002)
      write (ulsort,texte(langue,4)) nomfam
      write (ulsort,texte(langue,5)) numfam
c
      write (ulsort,texte(langue,9)) nbrgrf
      if ( nbrgrf.gt.0 ) then
        write (ulsort,10002)
        write (ulsort,texte(langue,10))
        do 22 , iaux = 1 , nbrgrf
          write (ulsort,10004) (nomgrf(jaux),jaux=10*(iaux-1)+1,10*iaux)
   22   continue
        write (ulsort,10002)
      endif
c
      if ( nbnofa.gt.0 ) then
        write (ulsort,texte(langue,17)) nbnofa
      elseif ( nbnofa.lt.0 ) then
        write (ulsort,texte(langue,18))
      endif
c
      if ( nbmafa.gt.0 ) then
        write (ulsort,texte(langue,19)) nbmafa
      elseif ( nbmafa.lt.0 ) then
        write (ulsort,texte(langue,20))
      endif
c
      write (ulsort,10002)
      write (ulsort,10001)
c
      codret = 0
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
