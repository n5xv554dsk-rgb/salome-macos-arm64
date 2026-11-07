      subroutine esecfe ( idfmed, nomamd,
     >                    nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    numfam,
     >                    tbiaux,
     >                    ulsort, langue, codret)
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
c  Entree-Sortie : ECriture des Familles des Entites
c  -      -        --           -            -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . numfam .  s  .   1    . plus petit numero de famille               .
c . tbiaux .     .    *   . tableau tampon entier                      .
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
      parameter ( nompro = 'ESECFE' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nbfami.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer tbiaux(*)
      integer numfam
c
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer typenh
c
      character*8 nhenti
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''. Ecriture des familles'')'
c
      texte(2,4) = '(''. Writings of families'')'
c
 1000 format('... ',a,' : ',i8)
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. Ecriture type par type
c====
c
      do 21 , typenh = -1 , 7
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.-1 ) then
          nhenti = nhnoeu
          iaux = nbfnoe
          numfam = 0
        elseif ( typenh.eq.0 ) then
          nhenti = nhmapo
          iaux = nbfmpo
          numfam = 0
        elseif ( typenh.eq.1 ) then
          nhenti = nharet
          iaux = nbfare
        elseif ( typenh.eq.2 ) then
          nhenti = nhtria
          iaux = nbftri
       elseif ( typenh.eq.3 ) then
          nhenti = nhtetr
          iaux = nbftet
        elseif ( typenh.eq.4 ) then
          nhenti = nhquad
          iaux = nbfqua
        elseif ( typenh.eq.5 ) then
          nhenti = nhpyra
          iaux = nbfpyr
        elseif ( typenh.eq.6 ) then
          nhenti = nhhexa
          iaux = nbfhex
        else
          nhenti = nhpent
          iaux = nbfpen
        endif
c
        if ( iaux.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) ' '
          write (ulsort,*) mess14(langue,4,typenh)
          write (ulsort,1000) 'nbfent', iaux
#endif
c
          jaux = typenh
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'ESECF0', nompro
#endif
          call esecf0 ( idfmed, nomamd,
     >                  jaux, iaux, numfam, nhenti,
     >                  tbiaux,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
   21 continue
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
