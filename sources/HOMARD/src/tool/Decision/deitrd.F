      subroutine deitrd ( nivmin,
     >                    decare, decfac,
     >                    aretri, hettri, filtri, nivtri,
     >                    trsupp, trindi,
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
c                          - cas des TRiangles - Deraffinement
c                                    --          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nivmin . e   .   1    . niveau min a ne pas depasser en deraffinemt.
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . trsupp . e   . nbtrto . support pour les triangles                 .
c . trindi . e   . nbtrto . valeurs entieres pour les triangles        .
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
      parameter ( nompro = 'DEITRD' )
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
      integer nivmin
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer aretri(nbtrto,3), hettri(nbtrto), filtri(nbtrto)
      integer nivtri(nbtrto)
      integer trsupp(nbtrto), trindi(nbtrto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer areloc, etat
      integer letria
      integer fille1
      integer iaux
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
c 2. traitement des indicateurs portant sur les triangles
c====
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,4)) mess14(langue,3,2)
#endif
cgn      write(ulsort,*)'trindi :'
cgn      write(ulsort,1789)(letria, trindi(letria),letria = 1, nbtrto)
cgn 1789   format(5(i3,' : ',i4,', '))
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,6))
#endif
c
      iaux = 0
c
      do 21 , letria = 1, nbtrto
c
        etat = mod(hettri(letria),10)
        if ( etat.eq.4 .or.
     >       etat.eq.6 .or. etat.eq.7 .or. etat.eq.8 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'tria ',letria,', etat = ',etat
#endif
          fille1 = filtri(letria)
          if ( trsupp(fille1)  .ne.0 .and.
     >         trsupp(fille1+1).ne.0 .and.
     >         trsupp(fille1+2).ne.0 .and.
     >         trsupp(fille1+3).ne.0 ) then
            if ( trindi(fille1)  .eq.-1  .and.
     >           trindi(fille1+1).eq.-1 .and.
     >           trindi(fille1+2).eq.-1 .and.
     >           trindi(fille1+3).eq.-1 ) then
              if ( nivtri(letria).lt.nivmin ) then
                iaux = iaux + 4
              else
                decfac(letria) = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac',
     >letria,decfac(letria),' '
#endif
                do 22 , areloc = 1, 3
                  decare(aretri(letria,areloc)) = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare',aretri(letria,areloc),
     >  decare(aretri(letria,areloc)),' (une de ses aretes)'
#endif
   22           continue
              endif
            endif
          endif
        endif
c
   21 continue
c
cgn      write(ulsort,*)'a la fin de 3.1'
cgn      write(ulsort,*)'decfac :'
cgn      write(ulsort,1789)(letria, decfac(letria),letria = 1, nbtrto)
c
      if ( iaux.ne.0 ) then
        write(ulsort,texte(langue,10))
        write(ulsort,texte(langue,4)) mess14(langue,3,2)
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
