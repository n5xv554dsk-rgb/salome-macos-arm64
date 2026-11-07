      subroutine deelig ( nomail,
     >                    lgopts, taopts,
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
c traitement des DEcisions - ELements IGnores
c                --          --       --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : il existe encore des non conformites   .
c .        .     .        . 2 : probleme de memoire                    .
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
      parameter ( nompro = 'DEELIG' )
c
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
      character*8 nomail
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer phetar, pdecar
      integer adars2, nbelig
c
      integer codre0, codre1, codre2, codre3
c
      character*8 ntrav1
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
      texte(1,4) = '(''Code retour de '',a6,'' ='',i4,/)'
c
      texte(2,4) = '(''Error code from '',a6,'' ='',i4,/)'
c
#include "impr03.h"
c
c====
c 2. recuperation des pointeurs, initialisations
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
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
c 2.2. ==> tableaux
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhelig, 1, nbelig, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbelig', nbelig
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbelig.ne.0 ) then
c
      call gmadoj ( nharet//'.HistEtat', phetar, iaux, codre1 )
      ntrav1 = taopts(11)
      call gmadoj ( ntrav1, pdecar, iaux, codre2 )
      call gmadoj ( nharet//'.InfoSup2', adars2, iaux, codre3 )
c
      codre0 = min ( codre1, codre2, codre3)
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3)
c
      endif
c
      endif
c
c====
c 3. bilan des decisions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. bilan des decisions ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbelig.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEELI1', nompro
#endif
        call deeli1
     >        ( imem(adars2), imem(pdecar),imem(phetar),
     >          ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) 'DEELI1', codret
#endif
c
      endif
c
      else
c
        codret = 2
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
cgn      print *,nompro,nbelig,codret
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
