      subroutine eslmmn ( idfmed, nomamd, lnomam,
     >                    nbnoto,
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
c  Entree-Sortie - Lecture du Maillage au format MED - nombre de Noeuds
c  -      -        -          -                  -               -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage d'entree                          .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . lnomam . e   .   1    . longueur du nom du maillage voulu          .
c . nbnoto .  s  .   1    . nombre de noeuds du maillage               .
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
      parameter ( nompro = 'ESLMMN' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer lnomam
      integer nbnoto
c
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer typnoe
c
      integer iaux
      integer numdt, numit
      integer datype, chgt, tsf
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de noeuds :'',i10)'
c
      texte(2,4) = '(''Number of nodes:'',i10)'
c
#include "esimpr.h"
c
      nbnoto = 0
c
      typnoe = 0
c
      numdt = ednodt
      numit = ednoit
c
c====
c 2. recherche du nombre de noeuds
c====
c
      if ( codret.eq.0 ) then
c
      datype = edda00
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHNME - noeuds', nompro
#endif
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              ednoeu, typnoe, datype, ednoda, chgt, tsf,
     >              nbnoto, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbnoto
#endif
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
