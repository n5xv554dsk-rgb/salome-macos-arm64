      subroutine vcequ7 ( arehom,
     >                    trihom, quahom,
     >                    aretri, arequa,
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
c    aVant adaptation Conversion - EQUivalence - phase 7
c     -               -            ---                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . arehom . e   . nbarto . liste etendue des homologues par aretes    .
c . trihom . e   . nbtrto . ensemble des triangles homologues          .
c . quahom . e   . nbquto . ensemble des quadrangles homologues        .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'VCEQU7' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer arehom(nbarto)
      integer trihom(nbtrto), quahom(nbquto)
      integer aretri(nbtrto,3), arequa(nbquto,4)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer entlo1, entlo2
      integer nbento, nbaret
      integer iaux, jaux
      integer option
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(a,i10,'' : l''''arete'',i10,'' est sans homologue.'')'
      texte(1,9) = '(/,''. Analyse des '',a,i10,'' et'',i10)'
c
      texte(2,4) = '(a,i10,'' : edge'',i10,'' has not homologous'')'
      texte(2,9) = '(/,''. Analysis of '',a,i10,'' and'',i10)'
c
      codret = 0
c
c====
c 2. controle des aretes des triangles puis des quadrangles
c====
c
      do 2 , option = 2, 4, 2
c
        if ( option.eq.2 ) then
          nbento = nbtrto
          nbaret = 3
        else
          nbento = nbquto
          nbaret = 4
        endif
c
        do 21 , entlo1 = 1 , nbento
c
          if ( option.eq.2 ) then
            entlo2 = trihom(entlo1)
          else
            entlo2 = quahom(entlo1)
          endif
c
          if ( entlo2.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,9)) mess14(langue,3,option),
     >                                     entlo1, entlo2
#endif
c
            do 211 , iaux = 1 , nbaret
c
              jaux = 0
              if ( option.eq.2 ) then
                if ( arehom(aretri(entlo1,iaux)).eq.0 ) then
                  jaux = aretri(entlo1,iaux)
                endif
              else
                if ( arehom(arequa(entlo1,iaux)).eq.0 ) then
                  jaux = arequa(entlo1,iaux)
                endif
              endif
              if ( jaux.ne.0 ) then
                codret = codret + 1
                write (ulsort,texte(langue,4)) mess14(langue,1,option),
     >                                         entlo1, jaux
              endif
c
  211       continue
c
          endif
c
   21   continue
c       
    2 continue
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
