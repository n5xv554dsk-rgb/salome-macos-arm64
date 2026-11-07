      subroutine cmalco ( nomail,
     >                    lgetco, taetco,
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
c    Creation du Maillage - ALlocation pour la mise en COnformite
c    -           -          --                         --
c ______________________________________________________________________
c
c but : decompte les entites a creer lors du decoupage de mise en
c       conformite des faces et des volumes.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .   1    . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . e/s .   1    . code de retour des modules                 .
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
      parameter ( nompro = 'CMALCO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
#include "envca1.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nretap, nrsset
      integer iaux, jaux
c
      integer codre0
      integer adtes2
      integer adhes2
      integer adpes2
      integer adpys2
c
      character*6 saux
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*8 ndecfa
c
      logical extrus
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
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(/,a6,'' ALLOCATION MEMOIRE POUR LA CONFORMITE'')'
      texte(1,5) = '(44(''=''),/)'
      texte(1,6) = '(''Modification de taille des tableaux des '',a)'
      texte(1,7) = '(5x,''==> code de retour :'',i8)'
c
      texte(2,4) =
     > '(/,a6,'' MEMORY ALLOCATION FOR CONFORMITY'')'
      texte(2,5) = '(39(''=''),/)'
      texte(2,6) = '(''Size modification of arrays for '',a)'
      texte(2,7) = '(5x,''==> error code :'',i8)'
c
#include "impr03.h"
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5. ==> le titre
c
      write ( ulsort,texte(langue,4)) saux
      write ( ulsort,texte(langue,5))
c
c====
c 2. recuperation des pointeurs
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
c
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 3. Reallocation des tableaux avec les nouvelles dimensions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. reallocation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 2
      if ( typcca.eq.26 .or .typcca.eq.46 ) then
        extrus = .false.
      elseif ( maextr.ne.0 ) then
        extrus = .true.
      else
        extrus = .false.
      endif
      jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMAL01', nompro
#endif
      call cmal01 (   iaux, extrus,
     >              nomail, ndecfa,
     >              permno, nouvno,
     >              permar, nouvar,
     >              permtr, nouvtr,
     >              permqu, nouvqu,
     >              permte, nouvte, jaux, provta,
     >              permhe, nouvhe, jaux, provha,
     >              permpe, nouvpe, jaux, provpa,
     >              permpy, nouvpy, jaux, provya,
     >              ulsort, langue, codret )
c
      endif
cgn      call gmprsx(nompro,nomail//'.Volume.HOM_Py05')
cgn      call gmprsx(nompro,nomail//'.Volume.HOM_Py05.ConnDesc')
cgn      call gmprsx(nompro,nomail//'.Volume.HOM_Py05.ConnAret')
cgn      call gmprsx(nompro,nomail//'.Volume.HOM_Py05.InfoSupp')
c
c 3.2. ==> Les tetraedres
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,3)//' - avant'
      write (ulsort,texte(langue,7)) codret
      write (ulsort,90002) 'permte', permte
      write (ulsort,90002) 'nouvte', nouvte
#endif
c
      if ( permte.ne.nouvte ) then
c
        if ( nbpeco.ne.0 .or. nbheco.ne.0 ) then
c
          iaux = nbheco + nbpeco
          call gmaloj ( nhtetr//'.InfoSup2', ' ',
     >                  iaux  , adtes2, codre0 )
c
          codret = max ( abs(codre0), codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,3)//' - apres'
      write (ulsort,texte(langue,7)) codret
#endif
c
      endif
c
c 3.3. ==> Les pyramides
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,5)//' - avant'
      write (ulsort,texte(langue,7)) codret
      write (ulsort,90002) 'permpy', permpy
      write (ulsort,90002) 'nouvpy', nouvpy
#endif
c
      if ( permpy.ne.nouvpy ) then
c
        if ( nbpeco.ne.0 .or. nbheco.ne.0 ) then
c
          iaux = nbheco + nbpeco
          call gmaloj ( nhpyra//'.InfoSup2', ' ',
     >                  iaux  , adpys2, codre0 )
c
          codret = max ( abs(codre0), codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,5)//' - apres'
      write (ulsort,texte(langue,7)) codret
#endif
c
      endif
c
c 3.4. ==> Les hexaedres : filiation en tetraedres/pyramides
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.4. hexaedres ; codret', codret
#endif
c
      if ( nbheco.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = nbheco*2
        call gmaloj ( nhhexa//'.InfoSup2', ' ', iaux  , adhes2, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
c
      endif
c
c 3.5. ==> Les pentaedres : filiation en tetraedres/pyramides
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.5. pentaedres ; codret', codret
#endif
c
      if ( nbpeco.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = nbpeco*2
        call gmaloj ( nhpent//'.InfoSup2', ' ', iaux  , adpes2, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
c=======================================================================
      endif
c=======================================================================
c
      end
