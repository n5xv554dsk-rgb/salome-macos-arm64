      subroutine dehomo ( nomail,
     >                    lgopti, taopti, lgopts, taopts,
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
c traitement des DEcisions - HOMOlogues
c                --          ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
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
c .        .     .        . sinon : erreur                             .
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
      parameter ( nompro = 'DEHOMO' )
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
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
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
      integer nretap, nrsset
      integer iaux
      integer jaux
c
      integer phetar, psomar
      integer phettr, paretr
      integer phetqu, parequ
c
      integer pdecar, pdecfa
      integer adhoar, adhotr, adhoqu
c
      integer codre0
      integer codre1, codre2
c
      character*6 saux
      character*8 ntrav1, ntrav2
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
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.0. ==> structure generale
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
c=======================================================================
      if ( homolo.ge.2 ) then
c=======================================================================
c
c 1.3. ==> les messages
c
      texte(1,4) = '(/,a6,'' PRISE EN COMPTE DES HOMOLOGUES'')'
      texte(1,5) = '(37(''=''),/)'
c
      texte(2,4) = '(/,a6,'' HOMOLOGOUS INFLUENCE'')'
      texte(2,5) = '(28(''=''),/)'
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
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,3)) 'DELIST en entree de ', nompro
      iaux = 1
      call delist ( nomail, nompro, iaux,
     >              lgopts, taopts,
     >              ulsort, langue, codret )
c
      endif
#endif
c
c====
c 2. recuperation des pointeurs
c====
c
      if ( codret.eq.0 ) then
c
      iaux = 2
      if ( homolo.ge.2 ) then
        iaux = iaux*29
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_ar', nompro
#endif
      call utad02 ( iaux, nharet,
     >              phetar, psomar,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux, adhoar,   jaux,
     >              ulsort, langue, codret )
c
      if ( nbtrto.ne.0 ) then
c
        iaux = 2
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
        call utad02 ( iaux, nhtria,
     >                phettr, paretr,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, adhotr,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      if ( nbquto.ne.0 ) then
c
        iaux = 2
        if ( homolo.ge.3 ) then
          iaux = iaux*29
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
        call utad02 ( iaux, nhquad,
     >                phetqu, parequ,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux,   jaux,   jaux,
     >                  jaux, adhoqu,   jaux,
     >                ulsort, langue, codret )
c
      endif
c
      ntrav1 = taopts(11)
      call gmadoj ( ntrav1, pdecar, iaux, codre1 )
      ntrav2 = taopts(12)
      call gmadoj ( ntrav2, pdecfa, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 3. influence des homologues
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEHOM1', nompro
#endif
      call dehom1 ( taopti(31), taopti(32),
     >              imem(phetar),
     >              imem(phettr), imem(paretr),
     >              imem(phetqu), imem(parequ),
     >              imem(adhoar), imem(adhotr), imem(adhoqu),
     >              imem(pdecar), imem(pdecfa),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. verification
c====
c
c 4.1. ==> sur les aretes
c
      if ( homolo.ge.2 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEHOVA', nompro
#endif
      call dehova ( imem(adhoar), imem(pdecar),
     >              nompro, 1,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c 4.2. ==> sur les triangles
c
      if ( homolo.ge.3 .and. nbtrto.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEHOVF', nompro
#endif
      iaux = 2
      call dehovf ( iaux,
     >              nbtrto, imem(adhotr), imem(pdecfa),
     >              nompro, 1,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c 4.3. ==> sur les quadrangles
c
      if ( homolo.ge.3 .and. nbquto.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEHOVF', nompro
#endif
      iaux = 4
      call dehovf ( iaux,
     >              nbquto, imem(adhoqu), imem(pdecfa),
     >              nompro, 1,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. la fin
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
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,3)) 'DELIST', nompro
      iaux = 2
      call delist ( nomail, nompro, iaux,
     >              lgopts, taopts,
     >              ulsort, langue, codret )
c
      endif
#endif
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
c=======================================================================
      endif
c=======================================================================
c
      end
