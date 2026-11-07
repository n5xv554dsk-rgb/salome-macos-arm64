      subroutine dehova ( arehom, decare,
     >                    nompra, phase,
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
c traitement des DEcisions - HOmologues - Verification des Aretes
c                --          --           -                -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . arehom . e   . nbarto . ensemble des aretes homologues             .
c . decare . e   . nbarto . decisions des aretes                       .
c . nompra . e   . char6  . nom du programme appelant                  .
c . phase  . e   .    1   . phase du programme appelant                .
c .        .     .        . 0 : debut                                  .
c .        .     .        . 1 : fin                                    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : desaccord sur les decisions entre      .
c .        .     .        .     entites homologues                     .
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
      parameter ( nompro = 'DEHOVA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer arehom(nbarto)
      integer decare(0:nbarto)
      integer phase
      character*6 nompra
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
      character*9 saux09(nblang,0:1)
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
      texte(1,4) =
     > '(''Pour les deux aretes homologues'',i6,'' et'',i6)'
      texte(1,5) = '(''. Arete numero'',i10,'' : decision = '',i2)'
      texte(1,6) = '(''... Probleme ...'')'
      texte(1,7) = '(/,a8,a6,'' : '',i8,'' erreur(s) sur les aretes.'')'
c
      texte(2,4) =
     > '(''For the two homologous edges'',i6,'' and'',i6)'
      texte(2,5) = '(''. Edge #'',i10,'' : decision = '',i2)'
      texte(2,6) = '(''... Problem ...'')'
      texte(2,7) = '(/,a8,a6,'' : '',i8,'' error(s) over edges.'')'
c
c                    123456789
      saux09(1,0) = 'Debut de '
      saux09(1,1) = 'Fin de   '
      saux09(2,0) = 'Start of '
      saux09(2,1) = 'End of   '
c
c====
c 2. controle des decisions sur les aretes
c    on boucle uniquement sur les aretes de la face periodique 2
c====
c
      jaux = 0
c
      if ( homolo.ge.2 ) then
c
        do 21 , iaux = 1 , nbarto
c
          if ( arehom(iaux).gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,4)) iaux, arehom(iaux)
            write (ulsort,texte(langue,5))
     >               iaux, decare(iaux)
            write (ulsort,texte(langue,5))
     >               abs(arehom(iaux)), decare(arehom(iaux))
#endif
c
            if ( decare(iaux).ne.decare(arehom(iaux)) ) then
              write (ulsort,texte(langue,4)) iaux, arehom(iaux)
              write (ulsort,texte(langue,5))
     >               iaux, decare(iaux)
              write (ulsort,texte(langue,5))
     >               abs(arehom(iaux)), decare(arehom(iaux))
              write (ulsort,texte(langue,6))
              jaux = jaux + 1
            endif
c
          endif
c
 21     continue
c
        if ( jaux.ne.0 ) then
          write (ulsort,texte(langue,7))
     >           saux09(langue,phase), nompra, jaux
          codret = 1
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
