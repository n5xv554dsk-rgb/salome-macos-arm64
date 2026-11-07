      subroutine deiarr ( nivmax,
     >                    decare,
     >                    hetare,
     >                    posifa, facare,
     >                    nivtri,
     >                    nivqua,
     >                    arsupp, arindi,
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
c traitement des DEcisions - Initialisation de l'indicateur entier
c                --          -
c                          - cas des ARetes - Raffinement
c                                    --       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nivmax . e   .   1    . niveau max a ne pas depasser en raffinement.
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . arsupp . e   . nbarto . support pour les aretes                    .
c . arindi . e   . nbarto . valeurs entieres pour les aretes           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme dans le traitement            .
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
      parameter ( nompro = 'DEIARR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nivmax
      integer decare(0:nbarto)
      integer hetare(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer nivtri(nbtrto)
      integer nivqua(nbquto)
      integer arsupp(nbarto), arindi(nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer etat
      integer larete
      integer iaux, jaux, kaux, ideb, ifin
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
c 1.1. ==> Les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr05.h"
c
      codret = 0
c
c====
c 2. traitement des indicateurs portant sur les aretes
c    pour le filtrage sur les niveaux, on tient compte du fait que
c    le niveau d'une arete est identifie a celui de l'une quelconque de
c    ses faces voisines quand elle en a. Sinon, on ne filtre pas.
c====
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,4)) mess14(langue,3,1)
#endif
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,5))
#endif
c
      iaux = 0
c
      do 21 , larete = 1, nbarto
c
        if ( arsupp(larete).ne.0 ) then
          etat = mod(hetare(larete),10)
          if ( etat.eq.0 ) then
            if ( arindi(larete).eq.1 ) then
              ideb = posifa(larete-1)+1
              ifin = posifa(larete)
              jaux = 0
              if ( ifin.ge.ideb .and. nivmax.ge.0 ) then
                if ( facare(ideb).gt.0 ) then
                  kaux = nivtri(facare(ideb))
                else
                  kaux = nivqua(-facare(ideb))
                endif
                if ( kaux.ge.nivmax ) then
                  jaux = 1
                endif
              endif
              if ( jaux.eq.0 ) then
                decare(larete) = 2
cgn          write(ulsort,*) 'mise a 2 de decare pour arete', larete
              else
                iaux = iaux + 1
              endif
            endif
          endif
        endif
c
   21 continue
c
      if ( iaux.ne.0 ) then
        write(ulsort,texte(langue,10))
        write(ulsort,texte(langue,4)) mess14(langue,3,1)
        write(ulsort,texte(langue,7)) nivmax
        write(ulsort,texte(langue,9)) iaux
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
