      subroutine utacme ( ncequi,
     >                    nbequi,
     >                    nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >                    nbeqte, nbeqhe,
     >                    adeqpo, adeqin,
     >                    adeqno, adeqmp, adeqar, adeqtr, adeqqu,
     >                    adeqte, adeqhe,
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
c    UTilitaire - Allocation pour le Calcul - Maillage - Equivalence
c    --           -                  -        -          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ncequi . e   . char8  . nom de la branche Equivalt maillage calcul .
c . nbequi . e   .    1   . nombre d'equivalences                      .
c . nbeqno . e   .    1   . nombre total de noeuds dans les equivalen. .
c . nbeqmp . e   .    1   . nombre total de mailles-points dans les eq..
c . nbeqar . e   .    1   . nombre total d'aretes dans les eq.         .
c . nbeqtr . e   .    1   . nombre total de triangles dans les eq.     .
c . nbeqqu . e   .    1   . nombre total de quadrangles dans les eq.   .
c . nbeqte . e   .    1   . nombre total de tetraedres dans les eq.    .
c . nbeqhe . e   .    1   . nombre total d'hexaedres dans les eq.      .
c . adeqpo .   s .    1   . adresse de la branche Pointeur             .
c . adeqin .   s .    1   . adresse de la branche InfoGene             .
c . adeqno .   s .    1   . adresse de la branche Noeud                .
c . adeqmp .   s .    1   . adresse de la branche Point                .
c . adeqar .   s .    1   . adresse de la branche Arete                .
c . adeqtr .   s .    1   . adresse de la branche Trian                .
c . adeqqu .   s .    1   . adresse de la branche Quadr                .
c . adeqte .   s .    1   . adresse de la branche Tetra                .
c . adeqhe .   s .    1   . adresse de la branche Hexae                .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . autre : probleme dans l'allocation         .
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
      parameter ( nompro = 'UTACME' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 ncequi
c
      integer nbequi
      integer nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
      integer nbeqte, nbeqhe
      integer adeqpo, adeqin
      integer adeqno, adeqmp, adeqar, adeqtr, adeqqu
      integer adeqte, adeqhe
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7, codre8
      integer codre0
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Allocation des equivalences du maillage de calcul'')'
      texte(1,5) = '(''Nombre d''''equivalences : '',i4)'
      texte(1,6) = '(''Nombre de paires de '',a14,'' : '',i4)'
      texte(1,7) = '(''Impossible d''''ecrire les attributs de '',a)'
      texte(1,8) = '(''Impossible d''''allouer les branches de '',a)'
      texte(1,9) = '(''Codes : '',7i3)'
c
      texte(2,4) =
     > '(''Allocation of equivalences of calculation mesh'')'
      texte(2,5) = '(''Number of equivalences: '',i4)'
      texte(2,6) = '(''Number of pairs of '',a14,'': '',i4)'
      texte(2,7) = '(''Attributes of '',a,'' cannot be written.'')'
      texte(2,8) = '(''Branches of '',a,'' cannot be allocated.'')'
      texte(2,9) = '(''Codes: '',7i3)'
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,4))
      write(ulsort,texte(langue,5)) nbequi
      write(ulsort,texte(langue,6)) mess14(langue,3,-1), nbeqno
      write(ulsort,texte(langue,6)) mess14(langue,3,0), nbeqmp
      write(ulsort,texte(langue,6)) mess14(langue,3,1), nbeqar
      write(ulsort,texte(langue,6)) mess14(langue,3,2), nbeqtr
      write(ulsort,texte(langue,6)) mess14(langue,3,4), nbeqqu
      write(ulsort,texte(langue,6)) mess14(langue,3,3), nbeqte
      write(ulsort,texte(langue,6)) mess14(langue,3,6), nbeqhe
#endif
c
c====
c 2. attributs
c====
c
      if ( codret.eq.0 ) then
c
      call gmecat ( ncequi, 1, nbequi, codre1 )
      call gmecat ( ncequi, 2, nbeqno, codre2 )
      call gmecat ( ncequi, 3, nbeqmp, codre3 )
      call gmecat ( ncequi, 4, nbeqar, codre4 )
      call gmecat ( ncequi, 5, nbeqtr, codre5 )
      call gmecat ( ncequi, 6, nbeqqu, codre6 )
      call gmecat ( ncequi, 7, nbeqte, codre7 )
      call gmecat ( ncequi, 8, nbeqhe, codre8 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7, codre8 )
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,7)) ncequi
      endif
c
      endif
c
c====
c 3. allocation
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbequi.ne.0 ) then
c
      iaux = 5*nbequi
      call gmaloj ( ncequi//'.Pointeur', ' ', iaux, adeqpo, codre1 )
      iaux = 33*nbequi
      call gmaloj ( ncequi//'.InfoGene', ' ', iaux, adeqin, codre2 )
      call gmaloj ( ncequi//'.Noeud' , ' ', 2*nbeqno, adeqno, codre3 )
      call gmaloj ( ncequi//'.Point' , ' ', 2*nbeqmp, adeqmp, codre4 )
      call gmaloj ( ncequi//'.Arete' , ' ', 2*nbeqar, adeqar, codre5 )
      call gmaloj ( ncequi//'.Trian' , ' ', 2*nbeqtr, adeqtr, codre6 )
      call gmaloj ( ncequi//'.Quadr' , ' ', 2*nbeqqu, adeqqu, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,8)) ncequi
        write(ulsort,texte(langue,9))
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7
      endif
c
      call gmaloj ( ncequi//'.Tetra' , ' ', 2*nbeqte, adeqte, codre1 )
      call gmaloj ( ncequi//'.Hexae' , ' ', 2*nbeqhe, adeqhe, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
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
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
