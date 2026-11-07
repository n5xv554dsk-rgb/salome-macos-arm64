      subroutine esemno ( idfmed, nomamd,
     >                    nbnoto, sdim, coonno, fameno,
     >                    numdt, numit, instan,
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
c  Entree-Sortie - Ecriture d'un Maillage au format MED - NOeuds
c  -      -        -             -                        --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage de sortie                         .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . nbnoto . e   .   1    . nombre de noeuds                           .
c . sdim   . e   .   1    . dimension                                  .
c . coonno . e   . nbnoto . coordonnees des noeuds dans le calcul      .
c .        .     . *sdim  .                                            .
c . fameno . e   . nbnoto . famille des noeuds                         .
c . numdt  . e   .   1    . numero du pas de temps                     .
c . numit  . e   .   1    . numero d'iteration                         .
c . instan . e   .   1    . pas de temps                               .
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
      parameter ( nompro = 'ESEMNO' )
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
      integer*8 idfmed
      integer nbnoto, sdim
      integer fameno(nbnoto)
      integer numdt, numit
c
      character*64 nomamd
c
      double precision coonno(nbnoto,sdim)
      double precision instan
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer typnoe
      integer iaux
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
c
      texte(2,61) = '(''Coordinates of the'',i10,'' nodes.'')'
      texte(2,62) = '(''Families of the'',i10,'' nodes.'')'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. les noeuds
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,24)) nbnoto
#endif
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) 'nomamd = ', nomamd
      write(ulsort,90002) 'idfmed', idfmed
      write(ulsort,90002) 'sdim', sdim
      write(ulsort,90002) 'ednoin', ednoin
      write(ulsort,90002) 'nbnoto', nbnoto
      write(ulsort,90002) 'numdt', numdt
      write(ulsort,90002) 'numit', numit
      write(ulsort,90004) 'dt   ', instan
cgn        print *,'coonno = ',coonno
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHCOW', nompro
#endif
      call mmhcow ( idfmed, nomamd, numdt, numit, instan, ednoin,
     >              nbnoto, coonno, codret )
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,78)) 'mmhcow', codret
        codret = 61
      endif
c
      endif
c
      if ( codret.eq.0 ) then
cgn        print *,'fameno = ',fameno
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHFNW', nompro
#endif
      call mmhfnw ( idfmed, nomamd, numdt, numit,
     >              ednoeu, typnoe,
     >              nbnoto, fameno, codret )
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,62))
        write(ulsort,texte(langue,78)) 'mmhfnw', codret
        codret = 62
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
