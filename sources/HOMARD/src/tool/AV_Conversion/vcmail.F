      subroutine vcmail ( lgopti, taopti, lgopts, taopts,
     >                    lgetco, taetco,
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
c    aVant adaptation - Conversion de MAILlage
c     -                 -             ----
c ______________________________________________________________________
c .        .     .        .                                            .
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
      parameter ( nompro = 'VCMAIL' )
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
      integer nretap, nrsset
      integer iaux
      integer typnom
c
      character*6 saux
      character*8 action
      character*8 typobs, nocman, nohman
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
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
      texte(1,4) = '(/,a6,'' CONVERSION DU MAILLAGE'')'
      texte(1,5) = '(29(''=''),/)'
      texte(1,6) = '(''Le nom du maillage HOMARD est inconnu.'')'
c
      texte(2,4) = '(/,a6,'' MESH CONVERSION'')'
      texte(2,5) = '(22(''=''),/)'
      texte(2,6) = '(''The name of the HOMARD mesh is unknown.'')'
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5 ==> le titre
c
      if ( taopti(4).ne.2 ) then
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
      endif
c
#include "impr03.h"
c
c====
c 2. les structures de base
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> le maillage homard
c          . en mode information et si l'entree n'est pas au format
c            HOMARD et si on ne souhaite pas archiver le maillage,
c            le nom du maillage HOMARD est cree automatiquement.
c          . dans tous les autres modes, on doit l'avoir fourni.
c
      if ( taopti(4).eq.2 .and.
     >     taopti(11).ne.1 .and.
     >     taopti(5).eq.1 ) then
c
        typnom = 0
c
      else
c
        typnom = 1
c
        typobs = mchman
        iaux = 0
        call utosno ( typobs, nohman, iaux, ulsort, langue, codret )
        if ( codret.ne.0 ) then
        write (ulsort,texte(langue,6))
        endif
c
      endif
c
c 2.2. ==> le maillage de calcul
c
      nocman = taopts(1)
c
      endif
c
c====
c 3. conversion du maillage
c====
c 3.1. ==> les connectivites
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. connectivites ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMACO', nompro
#endif
c
      call vcmaco ( taopti(4), taopti(11), taopti(49),
     >              taopti(30), taopti(39),
     >              nocman, nohman, typnom,
     >              ulsort, langue, codret )
c
      if ( codret.eq.0 ) then
c
      taopts(3) = nohman
c
      endif
c
      endif
c
c 3.2. ==> les familles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. familles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMAFA', nompro
#endif
c
      call vcmafa ( taopti(4), taopti(31), taopti(30), taopti(29),
     >              nocman, nohman,
     >              taopts(17), taopts(25), taopts(23), taopts(24),
     >              ulsort, langue, codret )
c
      endif
c
c 3.3. ==> verifications sauf pour une information car c'est fait apres
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. verifications ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      action = taopts(30)
c
#ifdef _DEBUG_HOMARD_
c
#else
      if ( action.ne.'info_av ' ) then
#endif
c
        if ( action.eq.'homa    ' ) then
          action = 'avad'
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMVER', nompro
#endif
        call vcmver ( taopti(4), nohman, action,
     >               ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
c
#else
      endif
#endif
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
