      subroutine deiqud ( nivmin,
     >                    decare, decfac,
     >                    arequa, hetqua, filqua, nivqua,
     >                    qusupp, quindi,
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
c                          - cas des QUadrangles - Deraffinement
c                                    --            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nivmin . e   .   1    . niveau min a ne pas depasser en deraffinemt.
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . qusupp . e   . nbquto . support pour les quadrangles               .
c . quindi . e   . nbquto . valeurs entieres pour les quadrangles      .
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
      parameter ( nompro = 'DEIQUD' )
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
      integer arequa(nbquto,4), hetqua(nbquto), filqua(nbquto)
      integer nivqua(nbquto)
      integer qusupp(nbquto), quindi(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer areloc, etat
      integer lequad
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
c 2. traitement des indicateurs portant sur les quadrangles
c====
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,4)) mess14(langue,3,4)
cgn      write (ulsort,*) 'quadrangle 7'
cgn      write (ulsort,*) 'decfac(q7) =',decfac(-7)
cgn      write (ulsort,*) arequa(7,1),arequa(7,2),
cgn     >arequa(7,3),arequa(7,4)
cgn      write (ulsort,*) decare(arequa(7,1)),decare(arequa(7,2)),
cgn     >decare(arequa(7,3)),decare(arequa(7,4))
cgn      write (ulsort,*) hetare(arequa(7,1)),hetare(arequa(7,2)),
cgn     >hetare(arequa(7,3)),hetare(arequa(7,4))
cgn      write (ulsort,*) ' '
#endif
cgn      write(ulsort,*)'quindi :'
cgn      write(ulsort,1789)(lequad, quindi(lequad),lequad = 1, nbquto)
cgn 1789 format(5(i3,' : ',i4,', '))
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,6))
#endif
c
      iaux = 0
c
      do 21 , lequad = 1, nbquto
        etat = mod(hetqua(lequad),100)
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'quad ',lequad,', etat = ',etat
#endif
        if ( etat.eq.4  ) then
          fille1 = filqua(lequad)
          if ( qusupp(fille1)   .ne. 0 .and.
     >         qusupp(fille1+1) .ne. 0 .and.
     >         qusupp(fille1+2) .ne. 0 .and.
     >         qusupp(fille1+3) .ne. 0 ) then
            if ( quindi(fille1)   .eq. -1  .and.
     >           quindi(fille1+1) .eq. -1 .and.
     >           quindi(fille1+2) .eq. -1 .and.
     >           quindi(fille1+3) .eq. -1 ) then
              if ( nivqua(lequad).lt.nivmin ) then
                iaux = iaux + 4
              else
                decfac(-lequad) = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decfac',
     >-lequad,decfac(-lequad),' '
#endif
                do 22 , areloc = 1, 4
                  decare(arequa(lequad,areloc)) = -1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,30))'decare',arequa(lequad,areloc),
     >  decare(arequa(lequad,areloc)),' (une de ses aretes)'
#endif
   22           continue
              endif
            endif
          endif
        endif
   21 continue
cgn      write (ulsort,*) 'apres 312'
cgn      write (ulsort,*) 'quadrangle 7'
cgn      write (ulsort,*) 'decfac(q7) =',decfac(-7)
cgn      write (ulsort,*) arequa(7,1),arequa(7,2),
cgn     >arequa(7,3),arequa(7,4)
cgn      write (ulsort,*) decare(arequa(7,1)),decare(arequa(7,2)),
cgn     >decare(arequa(7,3)),decare(arequa(7,4))
cgn      write (ulsort,*) hetare(arequa(7,1)),hetare(arequa(7,2)),
cgn     >hetare(arequa(7,3)),hetare(arequa(7,4))
cgn      write (ulsort,*) ' '
cgn        print 1789,(lequad, decfac(lequad),lequad = -nbquto,0)
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
