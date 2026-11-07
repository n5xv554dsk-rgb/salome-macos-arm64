      subroutine eslmno ( idfmed, nomamd,
     >                    option,
     >                    nbnoto, sdim, coonno, fameno,
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
c  Entree-Sortie - Lecture d'un Maillage au format MED - NOeuds
c  -      -        -            -                        --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage de sortie                         .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . option . e   .    1   . option de lecture du maillage              .
c .        .     .        . 1 : lecture integrale                      .
c .        .     .        . 2 : uniquement les coordonnees des noeuds  .
c . nbnoto . e   .   1    . nombre de noeuds                           .
c . sdim   . e   .   1    . dimension                                  .
c . coonno . e   . nbnoto . coordonnees des noeuds dans le calcul      .
c .        .     . *sdim  .                                            .
c . fameno . e   . nbnoto . famille des noeuds                         .
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
      parameter ( nompro = 'ESLMNO' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer option
c
      integer*8 idfmed
      integer nbnoto, sdim
      integer fameno(nbnoto)
c
      character*64 nomamd
c
      double precision coonno(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
      integer typnoe
      integer numdt, numit
      integer datype, chgt, tsf
      integer nbfami
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "esimpr.h"
c
      texte(1,61) = '(''Coordonnees des'',i10,'' noeuds.'')'
      texte(1,62) = '(''Familles des'',i10,'' noeuds.'')'
      texte(1,63) = '(''Toutes les familles sont nulles.'')'
c
      texte(2,61) = '(''Coordinates of the'',i10,'' nodes.'')'
      texte(2,62) = '(''Families of the'',i10,'' nodes.'')'
      texte(2,63) = '(''All the families are 0.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
#endif
c
      codret = 0
c
      numdt = ednodt
      numit = ednoit
c
c====
c 2. les coordonnees des noeuds
c    . les unites
c    . les coordonnees
c    . les numeros des familles
c    le tableau coonno est declare ainsi : coonno(nbnoto,sdim).
c    En fortran, cela correspond au stockage memoire suivant :
c    coonno(1,1), coonno(2,1), coonno(3,1), ..., coonno(nbnoto,1),
c    coonno(1,2), coonno(2,2), coonno(3,2), ..., coonno(nbnoto,2),
c    ...
c    coonno(1,sdim), coonno(2,sdim), ..., coonno(nbnoto,sdim)
c    on a ainsi toutes les abscisses, puis toutes les ordonnees, etc.
c    C'est ce que MED appelle le mode non entrelace.
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHCOR', nompro
#endif
      call mmhcor ( idfmed, nomamd, numdt, numit,
     >              ednoin, coonno, codret )
c
      endif
c
c====
c 3. Les familles de noeuds
c    Par convention, si le tableau est absent, les familles sont
c    toutes nulles.
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. familles de noeuds ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
c 3.1. ==> Longueur du tableau des familles
c
      if ( codret.eq.0 ) then
c
      typnoe = 0
      datype = edda04
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHNME', nompro
#endif
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              ednoeu, typnoe, datype, ednoda, chgt, tsf,
     >              nbfami, codret )
c
      endif
c
c 3.2. ==> Remplissage du tableau
c 3.2.1. ==> 0 par defaut
c
      if ( nbfami.eq.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,63))
#endif
c
        do 32 , iaux = 1 , nbnoto
          fameno(iaux) = 0
   32   continue
c
        endif
c
      else
c
c 3.2.2. ==> lecture
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHFNR', nompro
#endif
        call mmhfnr ( idfmed, nomamd, numdt, numit,
     >                ednoeu, typnoe,
     >                fameno, codret )
c
        endif
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
      if ( codret.ge.61 .and. codret.le.62 ) then
        write (ulsort,texte(langue,codret)) nbnoto
      endif
      write (ulsort,texte(langue,80))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
