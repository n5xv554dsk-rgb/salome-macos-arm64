      subroutine deited ( nivmin,
     >                    decare, decfac,
     >                    aretri, nivtri,
     >                    tritet, hettet, filtet,
     >                    tesupp, teindi,
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
c                          - cas des TEtraedres - Deraffinement
c                                    --           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nivmin . e   .   1    . niveau min a ne pas depasser en deraffinemt.
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . tesupp . e   . nbteto . support pour les tetraedres                .
c . teindi . e   . nbteto . valeurs entieres pour les tetraedres       .
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
      parameter ( nompro = 'DEITED' )
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
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nivmin
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer aretri(nbtrto,3), nivtri(nbtrto)
      integer tritet(nbtecf,4), hettet(nbteto), filtet(nbteto)
      integer tesupp(nbteto), teindi(nbteto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer areloc, facloc, etat
      integer letria, letetr
      integer fils1
      integer iaux, jaux
c
      integer nbmess
      parameter (nbmess = 30 )
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
#include "derco1.h"
c
      codret = 0
c
c====
c 2. traitement des indicateurs portant sur les tetraedres
c    pour le filtrage sur les niveaux, on tient compte du fait que
c    le niveau d'un tetraedre est identifie a celui de l'une quelconque
c    de ses triangles.
c====
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,4)) mess14(langue,3,3)
#endif
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,6))
#endif
c
      iaux = 0
c
      do 21 , letetr = 1, nbteto
c
        etat = mod( hettet(letetr) , 100 )
        if ( etat.ge.85 .and. etat.le.87 ) then
          fils1 = filtet(letetr)
          if ( tesupp(fils1)   .ne. 0 .and.
     >         tesupp(fils1+1) .ne. 0 .and.
     >         tesupp(fils1+2) .ne. 0 .and.
     >         tesupp(fils1+3) .ne. 0 .and.
     >         tesupp(fils1+4) .ne. 0 .and.
     >         tesupp(fils1+5) .ne. 0 .and.
     >         tesupp(fils1+6) .ne. 0 .and.
     >         tesupp(fils1+7) .ne. 0 ) then
            if ( teindi(fils1)   .eq. -1 .and.
     >           teindi(fils1+1) .eq. -1 .and.
     >           teindi(fils1+2) .eq. -1 .and.
     >           teindi(fils1+3) .eq. -1 .and.
     >           teindi(fils1+4) .eq. -1 .and.
     >           teindi(fils1+5) .eq. -1 .and.
     >           teindi(fils1+6) .eq. -1 .and.
     >           teindi(fils1+7) .eq. -1 ) then
              jaux = tritet(letetr,1)
              if ( nivtri(jaux).lt.nivmin ) then
                iaux = iaux + 8
              else
                do 22 , facloc = 1, 4
                  letria = tritet(letetr,facloc)
                  decfac(letria) = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac',
     >letria,decfac(letria),' '
#endif
                  do 23 , areloc = 1, 3
                    decare(aretri(letria,areloc)) = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare',aretri(letria,areloc),
     >  decare(aretri(letria,areloc)),' (une de ses aretes)'
#endif
   23             continue
   22           continue
              endif
            endif
          endif
        endif
c
   21 continue
c
      if ( iaux.ne.0 ) then
        write(ulsort,texte(langue,10))
        write(ulsort,texte(langue,4)) mess14(langue,3,3)
        write(ulsort,texte(langue,8)) nivmin
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
