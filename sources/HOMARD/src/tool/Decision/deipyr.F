      subroutine deipyr ( nivmax,
     >                    decare, decfac,
     >                    hetare,
     >                    aretri, hettri, nivtri,
     >                    arequa, hetqua,
     >                    facpyr,
     >                    pysupp, pyindi,
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
c                          - cas des PYramides - Raffinement
c                                    --          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nivmax . e   .   1    . niveau max a ne pas depasser en raffinement.
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . pysupp . e   . nbpyto . support pour les pyramides                 .
c . pyindi . e   . nbpyto . valeurs entieres pour les pyramides        .
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
      parameter ( nompro = 'DEIPYR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombpy.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nivmax
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer hetare(nbarto)
      integer aretri(nbtrto,3), hettri(nbtrto), nivtri(nbtrto)
      integer arequa(nbquto,4), hetqua(nbquto)
      integer facpyr(nbpycf,5)
      integer pysupp(nbpyto), pyindi(nbpyto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer areloc, facloc
      integer laface, lapyra
      integer iaux, jaux, kaux
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
c 2. traitement des indicateurs portant sur les pyramides
c    pour le filtrage sur les niveaux, on tient compte du fait que
c    le niveau d'une pyramide est identifie a celui de n'importe lequel
c    de ses faces.
c====
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,4)) mess14(langue,3,5)
#endif
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,5))
#endif
c
      iaux = 0
c
      do 21 , lapyra = 1, nbpyto
c
cgn        print *,lapyra,pysupp(lapyra),pyindi(lapyra)
        if ( pysupp(lapyra).ne.0 ) then
          if ( pyindi(lapyra).eq.1 ) then
            jaux = facpyr(lapyra,1)
            if ( nivmax.ge.0 .and. nivtri(jaux).ge.nivmax ) then
              iaux = iaux + 1
            else
              do 22 , facloc = 1, 5
                laface = facpyr(lapyra,facloc)
                if ( facloc.le.4 ) then
                  if ( mod(hettri(laface),10).eq.0 ) then
                    decfac(laface) = 4
                  endif
                  if ( laface.le.nbtrpe ) then
                    do 23 , areloc = 1, 3
                      kaux = aretri(laface,areloc)
                      if ( mod(hetare(kaux),10).eq.0 ) then
                        decare(kaux) = 2
                      elseif ( mod(hetare(kaux),10).eq.2 ) then
                        decare(kaux) = 0
                      endif
   23               continue
                  endif
                else
                  if ( mod(hetqua(laface),100).eq.0 ) then
                    decfac(-laface) = 4
                  endif
                  if ( laface.le.nbqupe ) then
                    do 24 , areloc = 1, 4
                      kaux = arequa(laface,areloc)
                      if ( mod(hetare(kaux),10).eq.0 ) then
                        decare(kaux) = 2
                      elseif ( mod(hetare(kaux),10).eq.2 ) then
                        decare(kaux) = 0
                      endif
   24               continue
                  endif
                endif
   22         continue
            endif
          endif
        endif
c
   21 continue
c
      if ( iaux.ne.0 ) then
        write(ulsort,texte(langue,10))
        write(ulsort,texte(langue,4)) mess14(langue,3,5)
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
