      subroutine utad07 ( ncequi,
     >                    nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >                    nbeqnn, nbeqmn, nbeqan, nbeqtn, nbeqqn,
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
c    UTilitaire - ADresses - phase 07
c    --           --               --
c ______________________________________________________________________
c   Modification des longueurs des tableaux pour une entite MC_Equ
c   et recuperation de leurs adresses
c   Remarque : le code de retour en entree ne doit pas etre ecrase
c              brutalement ; il doit etre cumule avec les operations
c              de ce programme
c   Remarque : utacme et utad07 sont similaires
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ncequi . e   . char8  . nom de la branche Equivalt maillage calcul .
c . nbeqno . e   .    1   . nombre total de noeuds dans les equivalen. .
c . nbeqmp . e   .    1   . nombre total de mailles-points dans les eq..
c . nbeqar . e   .    1   . nombre total d'aretes dans les eq.         .
c . nbeqtr . e   .    1   . nombre total de triangles dans les eq.     .
c . nbeqqu . e   .    1   . nombre total de quadrangles dans les eq.   .
c . nbeqnn . e   .    1   . nouveau nbeqno                             .
c . nbeqmn . e   .    1   . nouveau nbeqmp                             .
c . nbeqan . e   .    1   . nouveau nbeqar                             .
c . nbeqtn . e   .    1   . nouveau nbeqtr                             .
c . nbeqqn . e   .    1   . nouveau nbeqqu                             .
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
      parameter ( nompro = 'UTAD07' )
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
      integer nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
      integer nbeqnn, nbeqmn, nbeqan, nbeqtn, nbeqqn
      integer adeqno, adeqmp, adeqar, adeqtr, adeqqu
      integer adeqte, adeqhe
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer un
      parameter ( un = 1 )
c
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
      integer nbeqte, nbeqhe
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
     > '(''Rellocation des equivalences du maillage de calcul'')'
      texte(1,5) = '(''Nombre d''''equivalences : '',i4)'
      texte(1,6) = '(''Nombre de paires de '',a14,'' : '',i4)'
      texte(1,7) = '(''Impossible d''''ecrire les attributs de '',a)'
      texte(1,8) = '(''Impossible de reallouer les branches de '',a)'
      texte(1,9) = '(''Codes : '',7i3)'
c
      texte(2,4) =
     > '(''Re-allocation of equivalences of calculation mesh'')'
      texte(2,5) = '(''Number of equivalences: '',i4)'
      texte(2,6) = '(''Number of pairs of '',a14,'': '',i4)'
      texte(2,7) = '(''Attributes of '',a,'' cannot be written.'')'
      texte(2,8) = '(''Branches of '',a,'' cannot be re-allocated.'')'
      texte(2,9) = '(''Codes: '',7i3)'
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,4))
      write(ulsort,texte(langue,6)) mess14(langue,3,-1), nbeqno
      write(ulsort,texte(langue,6)) mess14(langue,3,0), nbeqmp
      write(ulsort,texte(langue,6)) mess14(langue,3,1), nbeqar
      write(ulsort,texte(langue,6)) mess14(langue,3,2), nbeqtr
      write(ulsort,texte(langue,6)) mess14(langue,3,4), nbeqqu
      write(ulsort,texte(langue,6)) mess14(langue,3,-1), nbeqnn
      write(ulsort,texte(langue,6)) mess14(langue,3,0), nbeqmn
      write(ulsort,texte(langue,6)) mess14(langue,3,1), nbeqan
      write(ulsort,texte(langue,6)) mess14(langue,3,2), nbeqtn
      write(ulsort,texte(langue,6)) mess14(langue,3,4), nbeqqn
#endif
c
c====
c 2. attributs
c====
c
      if ( codret.eq.0 ) then
c
      call gmecat ( ncequi, 2, nbeqnn, codre1 )
      call gmecat ( ncequi, 3, nbeqmn, codre2 )
      call gmecat ( ncequi, 4, nbeqan, codre3 )
      call gmecat ( ncequi, 5, nbeqtn, codre4 )
      call gmecat ( ncequi, 6, nbeqqn, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,7)) ncequi
      endif
c
      endif
c
c====
c 3. redimensionnement
c====
c 3.1. ==> Noeuds, mailles-point, aretes et faces
c
      if ( codret.eq.0 ) then
c
      call gmmod ( ncequi//'.Noeud',
     >             adeqno, 2*nbeqno, 2*nbeqnn, un, un, codre1 )
      call gmmod ( ncequi//'.Point',
     >             adeqmp, 2*nbeqmp, 2*nbeqmn, un, un, codre2 )
      call gmmod ( ncequi//'.Arete',
     >             adeqar, 2*nbeqar, 2*nbeqan, un, un, codre3 )
      call gmmod ( ncequi//'.Trian',
     >             adeqtr, 2*nbeqtr, 2*nbeqtn, un, un, codre4 )
      call gmmod ( ncequi//'.Quadr',
     >             adeqqu, 2*nbeqqu, 2*nbeqqn, un, un, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,8)) ncequi
        write(ulsort,texte(langue,9))
     >               codre1, codre2, codre3, codre4, codre5
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      nbeqno = nbeqnn
      nbeqmp = nbeqmn
      nbeqar = nbeqan
      nbeqtr = nbeqtn
      nbeqqu = nbeqqn
c
      endif
c
c 3.2. ==> Volumes dans le cas du recollement
c
      if ( codret.eq.0 ) then
c
      call gmliat ( ncequi, 7, nbeqte, codre1 )
      call gmliat ( ncequi, 8, nbeqhe, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbeqte.gt.0 ) then
        call gmecat ( ncequi, 6, nbeqtr+nbeqqu, codre1 )
        call gmmod ( ncequi//'.Tetra', adeqte,
     >               2, 2, nbeqte, nbeqtr+nbeqqu, codre2 )
      else
        codre1 = 0
        codre2 = 0
      endif
      if ( nbeqhe.gt.0 ) then
        call gmecat ( ncequi, 7, nbeqtr+nbeqqu, codre3 )
        call gmmod ( ncequi//'.Hexae', adeqhe,
     >               2, 2, nbeqhe, nbeqtr+nbeqqu, codre4 )
      else
        codre3 = 0
        codre4 = 0
      endif
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
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
