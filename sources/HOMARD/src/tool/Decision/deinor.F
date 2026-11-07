      subroutine deinor ( nivmax,
     >                    decare,
     >                    somare, hetare,
     >                    np2are, posifa, facare,
     >                    nivtri,
     >                    nivqua,
     >                    nosupp, noindi,
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
c                          - cas des NOeuds - Raffinement
c                                    --       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nivmax . e   .   1    . niveau max a ne pas depasser en raffinement.
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . nosupp . e   . nbnoto . support pour les noeuds                    .
c . noindi . e   . nbnoto . valeurs entieres pour les noeuds           .
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
      parameter ( nompro = 'DEINOR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nivmax
      integer decare(0:nbarto)
      integer somare(2,nbarto), hetare(nbarto)
      integer nivtri(nbtrto)
      integer nivqua(nbquto)
      integer np2are(nbarto), posifa(0:nbarto), facare(nbfaar)
      integer nosupp(nbnoto), noindi(nbnoto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
#include "impr05.h"
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'degre', degre
#endif
c
      codret = 0
cgn      print *,'decare :'
cgn      print 91011,decare
cgn      do 1999 , iaux = 1, nbnoto
cgn        if ( nosupp(iaux).ne.0 ) then
cgn          write (ulsort,90112) 'noindi',iaux,noindi(iaux)
cgn        endif
cgn 1999 continue
c
c====
c 3. traitement des indicateurs portant sur les noeuds
c====
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,4)) mess14(langue,3,-1)
#endif
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,5))
#endif
c
        iaux = 0
c
        if ( degre.eq.1 ) then
c
          do 321 , larete = 1, nbarto
            if ( mod( hetare(larete) , 10 ).eq.0 ) then
              if ( nosupp(somare(1,larete)).ne.0 .and.
     >             nosupp(somare(2,larete)).ne.0 ) then
                if ( noindi(somare(1,larete)).eq.1 .and.
     >               noindi(somare(2,larete)).eq.1 ) then
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
cgn        write(ulsort,90002) 'Raffinement de l''''arete', larete
                    decare(larete) = 2
                  else
                    iaux = iaux + 1
                  endif
                endif
              endif
            endif
  321     continue
c
        else
c
          do 322 , larete = 1, nbarto
            if ( mod( hetare(larete) , 10 ).eq.0 ) then
              if ( nosupp(somare(1,larete)).ne.0 .and.
     >             nosupp(somare(2,larete)).ne.0 .and.
     >             nosupp(np2are(larete)).ne.0 ) then
                if ( noindi(somare(1,larete)).eq.1 .and.
     >               noindi(somare(2,larete)).eq.1 .and.
     >               noindi(np2are(larete))  .eq.1 ) then
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
cgn        write(ulsort,90002) 'Raffinement de l''''arete', larete
                    decare(larete) = 2
                  else
                    iaux = iaux + 1
                  endif
                endif
              endif
            endif
  322     continue
c
        if ( iaux.ne.0 ) then
          write(ulsort,texte(langue,10))
          write(ulsort,texte(langue,4)) mess14(langue,3,-1)
          write(ulsort,texte(langue,7)) nivmax
          write(ulsort,texte(langue,9)) iaux
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
