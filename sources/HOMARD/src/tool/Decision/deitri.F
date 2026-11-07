      subroutine deitri ( decare, decfac,
     >                    aretri, pertri,
     >                    trsupp,
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
c                          - cas des TRiangles - Initialisation
c                                    --          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . decare .  s  .0:nbarto. decisions des aretes                       .
c . decfac .  s  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . pertri . e   . nbtrto . pere des triangles                         .
c . trsupp . e   . nbtrto . support pour les triangles                 .
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
      parameter ( nompro = 'DEITRI' )
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
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer aretri(nbtrto,3), pertri(nbtrto)
      integer trsupp(nbtrto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer areloc
      integer letria, lepere
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
c
      do 21 , letria = 1, nbtrto
c
        if ( trsupp(letria).ne.0 ) then
c
c 2.1. ==> Inhibition du raffinement par defaut : on garde la face
c          designee
c
          decfac(letria) = 0
          do 211 , areloc = 1, 3
            decare(aretri(letria,areloc)) = 0
  211     continue
c
c 2.2. ==> Inhibition du deraffinement par defaut : on garde le pere
c          de la face designee s'il existe
c
          lepere = pertri(letria)
c
          if ( lepere.gt.0 ) then
c
            decfac(lepere) = 0
            do 212 , areloc = 1, 3
              decare(aretri(lepere,areloc)) = 0
  212       continue
c
          endif
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
