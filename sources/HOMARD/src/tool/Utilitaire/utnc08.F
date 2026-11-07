      subroutine utnc08 ( nharet, nhtria, nhquad, nhvois,
     >                    numead,
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
c    UTilitaire - Non Conformite - phase 08
c    --           -   -                  --
c    On repere chaque face du macro maillage qui est bordee par une
c    arete de non conformite initiale. On declare que cette face a une
c    mere, dont le numero est un numero fictif, ne correspondant a
c    aucune face possible.
c    Ce programme est la surcouche de utnc09 qui fait le travail
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nharet . e   . char8  . nom de l'objet decrivant les aretes        .
c . nhtria . e   . char8  . nom de l'objet decrivant les triangles     .
c . nhquad . e   . char8  . nom de l'objet decrivant les quadrangles   .
c . nhvois . e   . char8  . nom de la branche Voisins                  .
c . numead .  s  .   1    . numero de la mere adoptive                 .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c ______________________________________________________________________
c
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
      parameter ( nompro = 'UTNC08' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      character*8 nharet, nhtria, nhquad
      character*8 nhvois
      integer numead
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer codre0
      integer pposif, pfacar
      integer ppertr
      integer pperqu
      integer nbanci
      integer adarrb
      integer numea0
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
      texte(1,4) = '(''Parentes adoptive pour les faces'')'
      texte(1,5) = '(''Nombre de non-conformites :'',i10))'
      texte(1,6) = '(''Ancien numero de la mere adoptive :'',i10))'
      texte(1,7) = '(''. Nouveau numero de la mere adoptive :'',i10))'
c
      texte(2,4) = '(''Adoptive fatherhood for faces'')'
      texte(2,5) = '(''Number of non-conformal situations :'',i10))'
      texte(2,6) = '(''Old number for adoptive mother :'',i10))'
      texte(2,7) = '(''. New number for adoptive mother :'',i10))'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. recuperation des pointeurs
c====
c
c 2.1. ==> Combien de non-conformites initiales ?
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD03', nompro
#endif
      iaux = 22
      call utad03 ( iaux, nharet,
     >              nbanci, jaux, jaux,
     >              jaux, adarrb,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nbanci
#endif
c
c 2.2. ==> Adresses des peres
c
      if ( nbanci.gt.0 ) then
c
        if ( nbtrto.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02', nompro
#endif
          iaux = 5
          call utad02 (   iaux, nhtria,
     >                    jaux,   jaux,   jaux, ppertr,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD03', nompro
#endif
          iaux = 5
          call utad03 ( iaux, nhtria,
     >                  jaux, jaux, numea0,
     >                  jaux, jaux,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
        if ( nbquto.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02', nompro
#endif
          iaux = 5
          call utad02 (   iaux, nhquad,
     >                    jaux,   jaux,   jaux, pperqu,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD03', nompro
#endif
          iaux = 5
          call utad03 ( iaux, nhquad,
     >                  jaux, jaux, numea0,
     >                  jaux, jaux,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
c
c 2.3. ==> Voisinages des aretes
c
      if ( nbanci.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
        iaux = 3
        call utad04 (   iaux, nhvois,
     >                  jaux,   jaux, pposif, pfacar,
     >                  jaux,   jaux,
     >                  jaux,   jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 3. Traitement des non conformites
c====
c
      if ( nbanci.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) numea0
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNC09', nompro
#endif
c
        call utnc09 ( nbanci, imem(adarrb), numea0,
     >                imem(ppertr), imem(pperqu), numead,
     >                imem(pposif), imem(pfacar),
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7)) numead
#endif
c
        if ( nbtrto.gt.0 ) then
c
        call gmecat ( nhtria//'.Recollem', 3, numead, codre0 )
        codret = max ( abs(codre0), codret )
c
        endif
c
        if ( nbquto.gt.0 ) then
c
        call gmecat ( nhquad//'.Recollem', 3, numead, codre0 )
        codret = max ( abs(codre0), codret )
c
        endif
c
cgn        call gmprsx (nompro,nhtria//'.Recollem')
cgn        call gmprsx (nompro,nhquad//'.Recollem')
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
      end
