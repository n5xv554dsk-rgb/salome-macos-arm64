      subroutine sfprep ( nomail, nocdfr,
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
c   Suivi de Frontiere : PREParation
c   --                   ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard iter. n+1   .
c . nocdfr . e   . char8  . nom de l'objet description de la frontiere .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . en entree = celui du module d'avant        .
c .        .     .        . en sortie = celui du module en cours       .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 2x : probleme dans les memoires            .
c .        .     .        . 3x : probleme dans les fichiers            .
c .        .     .        . 5 : mauvaises options                      .
c .        .     .        . 6 : problemes dans les noms d'objet        .
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
      parameter ( nompro = 'SFPREP' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*8 nomail, nocdfr
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer pcoono
      integer psomar, phetar, pnp2ar
      integer pcfaar, pfamar
      integer psegli, pnumli
c
      integer codre0, codre1, codre2
c
#ifdef _DEBUG_HOMARD_
      character*8 action
      parameter ( action = 'sufr    ' )
#endif
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
c
#ifdef _DEBUG_HOMARD_
      character*6 nompra
#endif
c
      integer nbmess
      parameter ( nbmess = 20 )
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      iaux = 0
      call utveri ( action, nomail, nompro, iaux,
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 2. recuperation des pointeurs
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
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
c 2.2.==> tableaux
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD01', nompro
#endif
      iaux = 3
      call utad01 ( iaux, nhnoeu,
     >                jaux,
     >                jaux,   jaux,   jaux,
     >              pcoono,   jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      iaux = 518
      if ( degre.eq.2 ) then
        iaux = iaux*13
      endif
      call utad02 ( iaux, nharet,
     >              phetar, psomar, jaux, jaux,
     >              pfamar, pcfaar,   jaux,
     >                jaux, pnp2ar,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. Particularites de la frontiere discrete
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. frontiere discrete ; codret', codret
#endif
c
c 3.1.==> Description de la frontiere discrete
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( nocdfr//'.PtrSomLi', psegli, iaux, codre1 )
      call gmadoj ( nocdfr//'.NumeLign', pnumli, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 3.2. ==> Compactage des numeros de ligne
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2 compactage nros ligne ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFNULI', nompro
#endif
      call sfnuli ( imem(pcfaar), imem(pnumli), iaux,
     >              lgetco, taetco,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      nompra = 'sfnuli'
      iaux = 2
      call utveri ( action, nomail, nompra, iaux,
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 4. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      iaux = 2
      call utveri ( action, nomail, nompro, iaux,
     >              ulsort, langue, codret )
c
      endif
#endif
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
