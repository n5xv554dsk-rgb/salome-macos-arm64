      subroutine pcsolu ( lgopti, taopti, lgopts, taopts,
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
c    aPres adaptation - Conversion de SOLUtion
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
      parameter ( nompro = 'PCSOLU' )
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
      integer option
c
      character*6 saux
      character*8 typobs
      character*8 nosvmn, nohmap, norenn, norenp
      character*8 nocson, nocsop
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,a6,'' CONVERSION DE LA SOLUTION'')'
      texte(1,5) = '(32(''=''),/)'
      texte(1,6) = '(''... '',a,'' : '',i6)'
c
      texte(2,4) = '(/,a6,'' SOLUTION CONVERSION'')'
      texte(2,5) = '(26(''=''),/)'
      texte(2,6) = '(''... '',a,'' : '',i6)'
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
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. les structures de base
c====
c
c 2.1. ==> le maillage homard a l'iteration n+1
c
      typobs = mchmap
      iaux = 0
      call utosno ( typobs, nohmap, iaux, ulsort, langue, codret )
c
c 2.2. ==> la solution a l'iteration n
c
      nocson = taopts(9)
c
c 2.3. ==> les sauvegardes du maillage a l'iteration n
c
      nosvmn = taopts(14)
c
c====
c 3. les renumerotations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. les renumerotations ; codret', codret
#endif
c
c 3.1. ==> la renumerotation a l'iteration n
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nosvmn//'.RenuMail', norenn, codret )
c
      endif
c
c 3.2. ==> la renumerotation a l'iteration n+1
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nohmap//'.RenuMail', norenp, codret )
c
      endif
c
c====
c 4. conversions
c====
c 4.1. ==> Option :
c          0 : Adaptation complete
c          1 : Modification de degre
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1. option ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Mode de fonctionnement HOMARD', taopti(4)
      write (ulsort,90002) 'Modification de degre', taopti(41)
#endif
c
      if ( taopti(4).eq.1 .or. taopti(4).eq.4 ) then
        option = 0
      elseif ( taopti(4).eq.3 .and. taopti(41).eq.1 ) then
        option = 1
      elseif ( taopti(4).eq.3 .and. taopti(41).eq.0 ) then
        option = -1
      else
        codret = 41
      endif
c
      endif
c
c 4.2. ==> Conversion effective
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. conversion effective ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSOVR', nompro
      call dmflsh (iaux)
#endif
      call pcsovr ( nocson, nocsop,
     >              nohmap, norenn, nosvmn,
     >              option,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
        taopts(10) = nocsop
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
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
c=======================================================================
      endif
c=======================================================================
c
      end
