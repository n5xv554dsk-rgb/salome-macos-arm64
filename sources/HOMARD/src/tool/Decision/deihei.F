      subroutine deihei ( decare, decfac,
     >                    arequa, perqua,
     >                    quahex,
     >                    hesupp,
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
c                          - cas des HExaedres - Initialisation
c                                    --          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hesupp . e   . nbheto . support pour les hexaedres                 .
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
      parameter ( nompro = 'DEIHEI' )
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
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer arequa(nbquto,4), perqua(nbquto)
      integer quahex(nbhecf,6)
      integer hesupp(nbheto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer areloc, facloc
      integer lequad, lehexa, lepere
      integer iaux
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
c 3. traitement des indicateurs portant sur les hexaedres
c====
c
#ifdef _DEBUG_HOMARD_
        write(ulsort,texte(langue,4)) mess14(langue,3,6)
#endif
c
      do 21 , lehexa = 1, nbheto
c
        if ( hesupp(lehexa).ne.0 ) then
c
          do 22 , facloc = 1, 6
c
            lequad = quahex(lehexa,facloc)
c
c 2.1. ==> Inhibition du raffinement par defaut : on garde la face
c          designee
c
            decfac(-lequad) = 0
            do 221 , areloc = 1, 4
              decare(arequa(lequad,areloc)) = 0
  221       continue
cgn      write(ulsort,*) 'decision finale',decfac(-lequad)
c
c 2.2. ==> Inhibition du deraffinement par defaut : on garde la mere
c          de la face designee s'il existe
c
            lepere = perqua(lequad)
c
            if ( lepere.gt.0 ) then
c
              decfac(-lepere) = 0
              do 222 , areloc = 1, 4
                decare(arequa(lepere,areloc)) = 0
  222         continue
c
            endif
c
   22     continue
c
        endif
c
   21 continue
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
