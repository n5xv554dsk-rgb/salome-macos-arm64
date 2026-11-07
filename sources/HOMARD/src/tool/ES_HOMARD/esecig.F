      subroutine esecig ( idfmed,
     >                    nhelig,
     >                    tbiaux,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : ECriture des elements IGnores
c  -      -        --                    --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nhelig . e   . char8  . nom de l'objet decrivant les ignores       .
c . tbiaux .     .    *   . tableau tampon entier                      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'ESECIG' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "envca1.h"
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer tbiaux(0:*)
c
      character*8 nhelig
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer nbelig
      integer nbnoel
      integer hfmdel, hnoeel
c
      character*64 noprof
c
      integer codre1, codre2, codre3
      integer codre0
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Ecriture des elements ignores.'')'
c
      texte(2,4) = '(''. Writings of additional information.'')'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
      codret = 0
c
cgn      call gmprsx (nompro, nhelig )
cgn      call gmprsx (nompro, nhelig//'.ConnNoeu' )
cgn      call gmprsx (nompro, nhelig//'.FamilMED' )
c
c====
c 2. Recuperation des adresses
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. adresses ; codret = ', codret
#endif
c
      call gmliat ( nhelig, 1, nbelig, codre1 )
      call gmadoj ( nhelig//'.ConnNoeu', hnoeel, iaux, codre2 )
      call gmadoj ( nhelig//'.FamilMED', hfmdel, iaux, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0),
     >               codre1, codre2, codre3 )
c
c====
c 3. Ecriture vraie
c====
c
      if ( codret.eq.0 ) then
c
      if ( degre.eq.1 ) then
        nbnoel = 5
      else
        nbnoel = 13
      endif
c
      tbiaux(0) = nbelig
      do 211 , iaux = 1 , nbelig
        tbiaux(iaux) = imem(hfmdel+iaux-1)
  211 continue
      jaux = nbelig*nbnoel
      do 212 , iaux = 1 , jaux
        tbiaux(nbelig+iaux) = imem(hnoeel+iaux-1)
  212 continue
c
      noprof = blan64
c                     1234567890123456
      noprof(1:16) = 'Elements_Ignores'
c
      iaux = nbelig*(nbnoel+1) + 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
      write (ulsort,texte(langue,62)) iaux
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW', nompro
#endif
      call mpfprw ( idfmed, noprof, iaux, tbiaux, codret )
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
