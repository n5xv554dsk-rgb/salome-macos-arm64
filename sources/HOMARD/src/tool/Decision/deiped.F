      subroutine deiped ( nivmin,
     >                    decare, decfac,
     >                    aretri, nivtri,
     >                    arequa,
     >                    facpen, hetpen, filpen,
     >                    pesupp, peindi,
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
c                          - cas des PEntaedres - Deraffinement
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
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . pesupp . e   . nbpeto . support pour les pentaedres                .
c . peindi . e   . nbpeto . valeurs entieres pour les pentaedres       .
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
      parameter ( nompro = 'DEIPED' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nivmin
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer aretri(nbtrto,3), nivtri(nbtrto)
      integer arequa(nbquto,4)
      integer facpen(nbpecf,5), hetpen(nbpeto), filpen(nbpeto)
      integer pesupp(nbpeto), peindi(nbpeto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer areloc, facloc, etat
      integer lepent
      integer iaux, jaux
      integer letria, lequad, fils1
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
c 2. traitement des indicateurs portant sur les pentaedres
c    pour le filtrage sur les niveaux, on tient compte du fait que
c    le niveau d'un pentaedre est identifie a celui de n'importe lequel
c    de ses faces.
c====
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,4)) mess14(langue,3,7)
#endif
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,6))
#endif
c
      iaux = 0
c
      do 21 , lepent = 1, nbpeto
c
        etat = mod( hetpen(lepent) , 100 )
        if ( etat.eq.80 ) then
          fils1 = filpen(lepent)
          if ( pesupp(fils1)   .ne. 0 .and.
     >         pesupp(fils1+1) .ne. 0 .and.
     >         pesupp(fils1+2) .ne. 0 .and.
     >         pesupp(fils1+3) .ne. 0 .and.
     >         pesupp(fils1+4) .ne. 0 .and.
     >         pesupp(fils1+5) .ne. 0 .and.
     >         pesupp(fils1+6) .ne. 0 .and.
     >         pesupp(fils1+7) .ne. 0 ) then
            if ( peindi(fils1)   .eq. -1 .and.
     >           peindi(fils1+1) .eq. -1 .and.
     >           peindi(fils1+2) .eq. -1 .and.
     >           peindi(fils1+3) .eq. -1 .and.
     >           peindi(fils1+4) .eq. -1 .and.
     >           peindi(fils1+5) .eq. -1 .and.
     >           peindi(fils1+6) .eq. -1 .and.
     >           peindi(fils1+7) .eq. -1 ) then
              jaux = facpen(lepent,1)
              if ( nivtri(jaux).lt.nivmin ) then
                iaux = iaux + 8
              else
                do 22 , facloc = 1, 2
                  letria = facpen(lepent,facloc)
                  decfac(letria) = -1
                  do 23 , areloc = 1, 3
                    decare(aretri(letria,areloc)) = -1
cgn       write(ulsort,*) 'reactivation de arete', aretri(letria,areloc)
   23             continue
   22           continue
                do 24 , facloc = 3, 5
                  lequad = facpen(lepent,facloc)
                  decfac(-lequad) = -1
                  do 25 , areloc = 1, 4
                    decare(arequa(lequad,areloc)) = -1
cgn       write(ulsort,*) 'reactivation de arete', arequa(lequad,areloc)
   25             continue
   24           continue
              endif
            endif
          endif
        endif
   21 continue
c
      if ( iaux.ne.0 ) then
        write(ulsort,texte(langue,10))
        write(ulsort,texte(langue,4)) mess14(langue,3,7)
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
