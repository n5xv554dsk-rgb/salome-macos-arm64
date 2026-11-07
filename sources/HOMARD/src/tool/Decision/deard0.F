      subroutine deard0 ( nomail, ntrav1, ntrav2, ntrav3,
     >                    phetar, psomar, pfilar, pmerar,
     >                    phettr, paretr, pfiltr, ppertr, pnivtr,
     >                    phetqu, parequ, pfilqu, pperqu, pnivqu,
     >                    phette, ptrite,
     >                    phethe, pquahe, pcoquh,
     >                    phetpy, pfacpy, pcofay,
     >                    phetpe, pfacpe, pcofap,
     >                    pposif, pfacar,
     >                    advotr, advoqu, adpptr, adppqu,
     >                    pdecfa, pdecar,
     >                    adhoar, adhotr, adhoqu,
     >                    ptrav3,
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
c traitement des DEcisions - Adresses pour le Raffinement
c                --          -                -
c                            et le Deraffinement - phase 0
c                                  -                     -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
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
      parameter ( nompro = 'DEARD0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      character*8 nomail, ntrav1, ntrav2, ntrav3
c
      integer phetar, psomar, pfilar, pmerar
      integer phettr, paretr, pfiltr, ppertr, pnivtr
      integer phetqu, parequ, pfilqu, pperqu, pnivqu
      integer phette, ptrite
      integer phethe, pquahe, pcoquh
      integer phetpy, pfacpy, pcofay
      integer phetpe, pfacpe, pcofap
      integer pposif, pfacar
      integer advotr, advoqu, adpptr, adppqu
      integer pdecfa, pdecar
      integer adhoar, adhotr, adhoqu
      integer ptrav3
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer codre0
      integer codre1, codre2
c
      integer adnmtr
      integer adnmqu
c
      character*8 nharet, nhtria, nhquad
      character*8 nhvois
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
c====
c 2. structure generale
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD99', nompro
#endif
      call utad99 ( nomail,
     >              phetar, psomar, pfilar, pmerar, adhoar,
     >              phettr, paretr, pfiltr, ppertr, pnivtr,
     >              adnmtr, adhotr,
     >              phetqu, parequ, pfilqu, pperqu, pnivqu,
     >              adnmqu, adhoqu,
     >              phette, ptrite,
     >              phethe, pquahe, pcoquh,
     >              phetpy, pfacpy, pcofay,
     >              phetpe, pfacpe, pcofap,
     >              nhvois, nharet, nhtria, nhquad,
     >              ulsort, langue, codret )
c
c====
c 3. les voisinages
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. les voisinages ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 3
      if ( nbteto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*5
      endif
      if ( nbheto.ne.0 .or. nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*7
      endif
      if ( nbpyto.ne.0 .or. nbpeto.ne.0 ) then
        iaux = iaux*13*17
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD04', nompro
#endif
      call utad04 ( iaux, nhvois,
     >                jaux,   jaux, pposif, pfacar,
     >              advotr, advoqu,
     >                jaux,   jaux, adpptr, adppqu,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >                jaux,   jaux,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. les decisions et les homologues
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. decisions/homologues ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ntrav1, pdecar, iaux, codre1 )
      call gmadoj ( ntrav2, pdecfa, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 5. allocations supplementaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. alloc supplementaires ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = nbtrac + nbquac
      call gmalot ( ntrav3, 'entier  ', iaux, ptrav3, codret )
c
      endif
c
c====
c 6. la fin
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
