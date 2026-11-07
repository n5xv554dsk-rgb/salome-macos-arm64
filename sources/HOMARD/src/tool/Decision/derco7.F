      subroutine derco7 ( niveau,
     >                    decare, decfac,
     >                    hetare,
     >                    hettri, aretri, nivtri,
     >                    voltri,
     >                    hetqua, arequa, nivqua,
     >                    volqua,
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
c traitement des DEcisions - Raffinement : COntamination - option 7
c                --          -             --                     -
c Complement sur la regle des ecarts de niveau pour du non-conforme
c a 1 noeud pendant par arete
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . niveau . e   .    1   . niveau en cours d'examen                   .
c . decare . es  . nbarto . decisions des aretes                       .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   . nbtrto . numeros des 3 aretes des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   . nbquto . numeros des 4 aretes des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
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
      parameter ( nompro = 'DERCO7' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer niveau
      integer decare(0:nbarto)
      integer decfac(-nbquto:nbtrto)
      integer hetare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3), nivtri(nbtrto)
      integer voltri(2,nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), nivqua(nbquto)
      integer volqua(2,nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer laface
      integer etatar
      integer iaux
      integer iarelo, iarete
      integer etatfa
      integer nbaret, liaret(4)
c
      logical loaret, loface
c
      integer nbmess
      parameter ( nbmess = 30 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
#include "impr03.h"
#endif
c
#include "derco1.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) niveau
#endif
c
      codret = 0
c
c====
c 2. Complements sur la regle des ecarts de niveau
c    on s'interesse aux faces :
c      . du niveau courant
c      . qui sont a decouper : leurs aretes qui seraient a faire
c        reapparaitre sont declarees "a garder"
c      . qui sont a garder : si toutes leurs aretes sont a couper,
c        on coupera la face aussi
c      . qui sont bidimensionnelles
c====
c
      do 2 , laface = -nbquto , nbtrto
cgn          write (ulsort,90001) 'decision face', laface,decfac(laface)
c
c 2.1. ==> examen des faces
c
        loaret = .false.
        loface = .false.
c
        nbaret = 0
c
        if ( laface.gt.0 ) then
c
          if ( nivtri(laface).eq.niveau ) then
            if ( decfac(laface).eq.0 ) then
              etatfa = mod( hettri(laface) , 10 )
              if ( etatfa.eq.0 ) then
                loface = .true.
              endif
            elseif ( decfac(laface).eq.4 ) then
              loaret = .true.
            endif
            if ( loface ) then
              if ( nbteto.gt.0 ) then
                if ( voltri(1,laface).gt.0 ) then
                  loface = .false.
                endif
              endif
            endif
            if ( loaret .or. loface ) then
              nbaret = 3
              do 211 , iarelo = 1 , nbaret
                liaret(iarelo) = aretri(laface,iarelo)
  211         continue
            endif
          endif
c
        elseif ( laface.lt.0 ) then
c
          iaux = -laface
          if ( nivqua(iaux).eq.niveau ) then
            if ( decfac(laface).eq.0 ) then
              etatfa = mod( hetqua(iaux) , 100 )
              if ( etatfa.eq.0 ) then
                loface = .true.
              endif
            elseif ( decfac(laface).eq.4 ) then
              loaret = .true.
            endif
            if ( loface ) then
              if ( nbheto.gt.0 ) then
                if ( volqua(1,iaux).gt.0 ) then
                  loface = .false.
                endif
              endif
            endif
            if ( loaret .or. loface ) then
              nbaret = 4
              do 212 , iarelo = 1 , nbaret
                liaret(iarelo) = arequa(iaux,iarelo)
  212         continue
            endif
          endif
c
        endif
c
c 2.2. ==> les aretes sont a garder
c
        if ( loaret ) then
c
          do 22 , iarelo = 1 , nbaret
            iarete = liaret(iarelo)
            if ( decare(iarete).eq.-1 ) then
              decare(iarete) = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decare',iarete,decare(iarete),' '
#endif
            endif
   22     continue
c
        endif
c
c 2.3. ==> la face est eventuellement a couper
c
        if ( loface ) then
c
          iaux = 0
          do 23 , iarelo = 1 , nbaret
            iarete = liaret(iarelo)
            etatar = mod( hetare(iarete) , 10 )
            if ( decare(iarete).eq.2 .or. etatar.eq.2 ) then
              iaux = iaux + 1
            endif
   23     continue
c
          if ( iaux.eq.nbaret ) then
            decfac(laface) = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))' decfac',laface,decfac(laface),' '
#endif
          endif
c
        endif
c
    2 continue
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'sortie de ',nompro
        do 1106 , iaux = 1 , nbquto
          write (ulsort,90001) 'decision quadrangle', iaux,decfac(-iaux)
cgn          write (ulsort,90001) 'quadrangle', iaux,
cgn     >    arequa(iaux,1), arequa(iaux,2),
cgn     >    arequa(iaux,3), arequa(iaux,4)
 1106   continue
      if ( nbquto.gt.0 ) then
         iaux = min(nbquto,5)
          write (ulsort,90001) 'quadrangle', iaux,
     >    decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >    decare(arequa(iaux,3)), decare(arequa(iaux,4))
         iaux = min(nbquto,8)
          write (ulsort,90001) 'quadrangle', iaux,
     >    decare(arequa(iaux,1)), decare(arequa(iaux,2)),
     >    decare(arequa(iaux,3)), decare(arequa(iaux,4))
      endif
#endif
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
