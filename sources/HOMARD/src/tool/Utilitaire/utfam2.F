      subroutine utfam2 ( typenh, nhenfa, nctfen, nbfnew,
     >                    pcfaen,
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
c    UTilitaire - FAMilles - phase 2
c    --           ---              -
c    Creation/Allongement du tableau des codes des familles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nhenfa . e   . char*8 . nom de l'objet de la famille de l'entite   .
c . nctfen . e   .    1   . nombre de caracteristique des f. entite    .
c . nbfnew . e   .    1   . nombre de familles                         .
c . pcfaen .  s  .  1     . codes des familles de l'entite             .
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
      parameter ( nompro = 'UTFAM2' )
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
      integer typenh, nctfen, nbfnew
      integer pcfaen
c
      character*8 nhenfa
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
      integer codre1, codre2, codre3
      integer nbfold
c
      logical existe
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
     > '(''Allocation des familles pour extruder les '',a)'
c
      texte(2,4) =
     > '(''Allocation of arrays for family of extruded '',a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,90002) 'nctfen', nctfen
      write (ulsort,90002) 'nbfnew', nbfnew
      call gmprsx ( nompro, nhenfa )
#endif
c
      codret = 0
c
c====
c 2. Le tableau existe-t-il ?
c====
c
      call gmobal ( nhenfa//'.Codes', codre0 )
      if ( codre0.eq.0 ) then
        existe = .False.
      elseif ( codre0.eq.2 ) then
        existe = .True.
      else
        codret = abs(codre0)
      endif
c
c====
c 3. creation/allongement des tableaux
c====
c 3.1. ==> Allongement
c
      if ( existe ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nhenfa//'.Codes', pcfaen, iaux, codre0 )
        codret = max( abs(codre0), codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        nbfold = iaux/nctfen
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbfold', nbfold
#endif
c
        call utfam1 ( typenh, nhenfa, pcfaen,
     >                nctfen, nbfold, nbfnew,
     >                ulsort, langue, codret)
c
        endif
c
c 3.2. ==> Creation
c
      else
c
        if ( codret.eq.0 ) then
c
        iaux = nctfen*nbfnew
        call gmaloj ( nhenfa//'.Codes', ' ', iaux, pcfaen, codre0 )
c
        codret = max( abs(codre0), codret )
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
