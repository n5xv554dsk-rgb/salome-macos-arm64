      subroutine hoapes ( lgopti, taopti, lgopts, taopts,
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
c       HOMARD : interface APres adaptation : Ecriture de la Solution
c       --                 --                 -              -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'HOAPES' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nrosec
      integer nretap, nrsset
      integer iaux, jaux
      integer lnomfi
c
      character*6 saux
      character*8 typobs
      character*200 nomfic
c
      integer nbmess
      parameter ( nbmess = 120 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
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
c 1.1. ==> le debut des mesures de temps
c
      nrosec = taetco(4)
      call gtdems (nrosec)
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
      texte(1,4) = '(/,a6,'' ECRITURE DES SOLUTIONS'')'
      texte(1,5) = '(29(''=''),/)'
      texte(1,6) = '(''Solution : '',a)'
c
      texte(2,4) = '(/,a6,'' WRITINGS OF SOLUTIONS'')'
      texte(2,5) = '(28(''=''),/)'
      texte(2,6) = '(''Solution: '',a)'
c
c 1.3. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.4. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
#include "esimpr.h"
c
#include "impr03.h"
c
c====
c 2. ecriture de la solution interpolee
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. solution interpolee ; codret', codret
      write (ulsort,90002) 'taopti(28)', taopti(28)
#endif
c
      if ( taopti(28).eq.1 ) then
c
c 2.1. ==> nom du fichier qui contiendra la solution
c
        if ( codret.eq.0 ) then
c
        typobs = mccsop
        iaux = 0
        jaux = 1
        call utfino ( typobs, iaux, nomfic, lnomfi,
     >                jaux,
     >                ulsort, langue, codret )
        if ( codret.ne.0 ) then
          write (ulsort,texte(langue,8)) 'solution interpolee en sortie'
          codret = 21
        endif
c
        endif
c
c 2.2. ==> ecriture
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) taopts(10)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESESMD_sol_interpolee', nompro
#endif
c
        call esesmd ( taopts(10), nomfic, lnomfi,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c====
c 3. ecriture d'une solution construite
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. solution construite ; codret', codret
      write (ulsort,90002) 'taopti(12)', taopti(12)
#endif
c
      if ( taopti(12).gt.1 ) then
c
c 3.1. ==> nom du fichier qui contiendra la solution : celui du maillage
c
        if ( codret.eq.0 ) then
c
        typobs = mccmap
        iaux = 0
        jaux = 1
        call utfino ( typobs, iaux, nomfic, lnomfi,
     >                jaux,
     >                ulsort, langue, codret )
        if ( codret.ne.0 ) then
          write (ulsort,texte(langue,8)) 'solution construite en sortie'
          codret = 31
        endif
c
        endif
c
c 3.2. ==> ecriture
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) taopts(31)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESESMD_sol_construite', nompro
#endif
c
        call esesmd ( taopts(31), nomfic, lnomfi,
     >                ulsort, langue, codret)
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
      call gtfims (nrosec)
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
