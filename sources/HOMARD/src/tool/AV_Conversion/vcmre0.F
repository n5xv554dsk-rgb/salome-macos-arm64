      subroutine vcmre0 ( nbenti, rsenac, rsento, nbento,
     >                    nensho, nensca, nensic,
     >                    nuenex, decala,
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
c    aVant adaptation - Conversion de Maillage - RENumerotation
c     -                 -             -          ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbenti . e   .   1    . nombre d'entites dans le calcul            .
c . rsenac . e   .   1    . nombre d'entites utiles au calcul et       .
c .        .     .        . contenant des entites                      .
c . rsento . e   .   1    . nombre d'entites total en sortie           .
c . nbento . e   .   1    . nombre d'entites total                     .
c . nensho . es  . rsenac . numero des entites dans HOMARD             .
c . nensca . es  . rsento . numero des entites du calcul               .
c . nensic . es  . rsento . numero des entites du calcul (initial)     .
c . nuenex . e   . nbenti . numerotation des entites en exterieur      .
c . decala . e   .   1    . decalage des numerotations selon le type   .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 3 : anglais                  .
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
      parameter ( nompro = 'VCMRE0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbenti, rsenac, rsento, nbento
c
      integer nensho(rsenac), nensca(rsento), nensic(rsento)
      integer nuenex(nbenti), decala
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nuelca
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
      write (ulsort,90002) 'nbenti, rsenac, rsento, nbento',
     >                      nbenti, rsenac, rsento, nbento
      write (ulsort,90002) 'decala', decala
#endif
c
      codret = 0
c
c====
c 2. renumerotation des entites le cas echeant
c====
c
      if ( rsenac.ne.0 ) then
cgn      write (ulsort,*) 'nensca en entree'
cgn      write (ulsort,91020) ( nensca(iaux), iaux = 1 , nbento)
cgn      write (ulsort,*) 'nuenex'
cgn      write (ulsort,91020) ( nuenex(iaux), iaux = 1 , rsenac)
c
c 2.1. ==> archivage de la renumerotation entre HOMARD et la
c          numerotation compactee pour l'entite
c
      do 21 , iaux = 1 , nbento
        nensic(iaux) = nensca(iaux) - decala
   21 continue
cgn      write (ulsort,*) 'nensic'
cgn      write (ulsort,91020) ( nensic(iaux), iaux = 1 , nbento)
c
c 2.2. ==> initialisation des changements de numerotation
c
      do 221 , iaux = 1 , rsenac
        nensho(iaux) = 0
  221 continue
c
      do 222 , iaux = 1 , nbento
        nensca(iaux) = 0
  222 continue
c
c 2.3. ==> prise en compte des deux changements de numerotation
c
      do 23 , iaux = 1 , nbento
        if ( nensic(iaux).ne.-decala ) then
          nuelca = nuenex(nensic(iaux)+decala)
cgn      write (ulsort,90002) 'iaux,nensic(iaux),nuelca',
cgn     >iaux,nensic(iaux),nuelca
          nensca(iaux) = nuelca
          nensho(nuelca) = iaux
        endif
   23 continue
cgn      write (ulsort,*) 'nensca en sortie'
cgn      write (ulsort,91020) ( nensca(iaux), iaux = 1 , nbento)
cgn      write (ulsort,*) 'nensho en sortie'
cgn      write (ulsort,91020) ( nensho(iaux), iaux = 1 , rsenac)
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
