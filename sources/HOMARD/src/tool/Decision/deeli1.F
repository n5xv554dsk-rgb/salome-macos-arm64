      subroutine deeli1 ( insoar, decare, hetare,
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
c traitement des DEcisions - ELements Ignores - 1
c                --          --       -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . insoar . e   . nbarma . information sur les sommets des aretes     .
c .        .     .        .  0 : ses deux sommets appartiennent        .
c .        .     .        .      exclusivement a un element soumis a   .
c .        .     .        .      l'adaptation                          .
c .        .     .        . -1 : son 1er sommet appartient a un element.
c .        .     .        .      ignore                                .
c .        .     .        .      le 2nd sommet appartient exclusivement.
c .        .     .        .      a un element soumis a l'adaptation    .
c .        .     .        . -2 : son 2nd sommet appartient a un element.
c .        .     .        .      ignore                                .
c .        .     .        .      le 1er sommet appartient exclusivement.
c .        .     .        .      a un element soumis a l'adaptation
c .        .     .        .  2 : ses deux sommets appartiennent a un   .
c .        .     .        .      element ignore                        .
c . decare . e   . nbarto . decisions des aretes                       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : il existe encore des non conformites   .
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
      parameter ( nompro = 'DEELI1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer decare(0:nbarto)
      integer hetare(nbarto)
      integer insoar(nbarma)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer larete, etatar
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
      texte(1,9) = '(''Le raffinement atteint la zone interdite'')'
      texte(1,10) = '(''Nombre d''''aretes touchees :'',i6)'
c
      texte(2,9) ='(''Refinement reached the forbidden zone'')'
      texte(2,10) ='(''Number of reached edges :'',i6)'
c
#include "impr03.h"
c
c====
c 2. on explore toutes les aretes actives du macro-maillage : il ne
c    sert a rien de controle des aretes filles car elles ne peuvent pas
c    avoir ete creees !
c    on verifie qu'il n'y a pas de situation pour laquelle
c    l'arete d'un element ignore a ete decoupee
c====
c
      codret = 0
c
      do 20 , larete = 1 , nbarma
c
        etatar = mod( hetare(larete) , 10 )
c
        if ( etatar.eq.0 ) then
c
          if ( decare(larete).eq.2 ) then
c
            if ( insoar(larete).eq.2 ) then
c
              codret = codret + 1
c
            endif
c
          endif
c
        endif
c
   20 continue
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,9))
      write (ulsort,texte(langue,10)) codret
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
