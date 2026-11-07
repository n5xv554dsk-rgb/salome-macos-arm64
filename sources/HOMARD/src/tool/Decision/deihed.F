      subroutine deihed ( nivmin,
     >                    decare, decfac,
     >                    arequa, nivqua,
     >                    quahex, hethex, filhex,
     >                    hesupp, heindi,
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
c                          - cas des HExaedres - Deraffinement
c                                    --          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nivmin . e   .   1    . niveau min a ne pas depasser en deraffinemt.
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
c . heindi . e   . nbheto . valeurs entieres pour les hexaedres        .
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
      parameter ( nompro = 'DEIHED' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nivmin
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer arequa(nbquto,4), nivqua(nbquto)
      integer quahex(nbhecf,6), hethex(nbheto), filhex(nbheto)
      integer hesupp(nbheto), heindi(nbheto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer areloc, facloc, etat
      integer lequad, lehexa
      integer fils1
      integer iaux, jaux
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
c 2. traitement des indicateurs portant sur les hexaedres
c    pour le filtrage sur les niveaux, on tient compte du fait que
c    le niveau d'un hexaedre est identifie a celui de n'importe lequel
c    de ses quadrangles.
c====
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,4)) mess14(langue,3,6)
#endif
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,6))
#endif
c
      iaux = 0
c
      do 21 , lehexa = 1, nbheto
c
        etat = mod(hethex(lehexa),1000)
        if ( etat.eq.8 ) then
          fils1 = filhex(lehexa)
          if ( hesupp(fils1)   .ne. 0 .and.
     >         hesupp(fils1+1) .ne. 0 .and.
     >         hesupp(fils1+2) .ne. 0 .and.
     >         hesupp(fils1+3) .ne. 0 .and.
     >         hesupp(fils1+4) .ne. 0 .and.
     >         hesupp(fils1+5) .ne. 0 .and.
     >         hesupp(fils1+6) .ne. 0 .and.
     >         hesupp(fils1+7) .ne. 0 ) then
            if ( heindi(fils1)   .eq. -1 .and.
     >           heindi(fils1+1) .eq. -1 .and.
     >           heindi(fils1+2) .eq. -1 .and.
     >           heindi(fils1+3) .eq. -1 .and.
     >           heindi(fils1+4) .eq. -1 .and.
     >           heindi(fils1+5) .eq. -1 .and.
     >           heindi(fils1+6) .eq. -1 .and.
     >           heindi(fils1+7) .eq. -1 ) then
              jaux = quahex(lehexa,1)
              if ( nivqua(jaux).lt.nivmin ) then
                iaux = iaux + 8
              else
                do 22 , facloc = 1, 6
                  lequad = quahex(lehexa,facloc)
                  decfac(-lequad) = -1
                  do 23 , areloc = 1, 4
                    decare(arequa(lequad,areloc)) = -1
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
        write(ulsort,texte(langue,4)) mess14(langue,3,6)
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
