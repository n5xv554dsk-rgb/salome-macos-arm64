      subroutine deiuc0 ( nbval, ncmpin, usacmp,
     >                    ensupp, enindi,
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
c traitement des DEcisions - Initialisations - Usage des CoMposantes - 0
c                --          -                 -         -             -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbval  .  e  .    1   . nombres de valeurs                         .
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . ensupp .  e  . nbval  . support pour les entites                   .
c . enindi . es  . nbval  . valeurs reelles pour les entites           .
c .        .     .*ncmpin .                                            .
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
      parameter ( nompro = 'DEIUC0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbval, ncmpin
      integer usacmp
      integer ensupp(nbval)
c
      integer ulsort, langue, codret
c
      double precision enindi(nbval,ncmpin)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nrcomp
c
      double precision daux
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
      texte(1,4) =' (''. Saut entre '',a)'
c
      texte(2,4) = '(''. Jump between '',a)'
c
      codret = 0
c
c====
c 2. Traitement
c====
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> norme L2
c
      if ( usacmp.eq.0 ) then
c
        do 21 , iaux = 1 , nbval
c
          if ( ensupp(iaux).ne.0 ) then
c
            daux = 0.d0
            do 211 , nrcomp = 1 , ncmpin
              daux = daux + enindi(iaux,nrcomp)**2
  211       continue
            enindi(iaux,1) = sqrt(daux)
c
          endif
c
   21   continue
c
c 2.2. ==> norme infinie
c
      elseif ( usacmp.eq.1 ) then
c
        do 22 , iaux = 1 , nbval
c
          if ( ensupp(iaux).ne.0 ) then
c
            daux = 0.d0
            do 221 , nrcomp = 1 , ncmpin
              daux = max ( daux, abs(enindi(iaux,nrcomp)) )
  221       continue
            enindi(iaux,1) = daux
c
          endif
c
   22   continue
c
c 2.3. ==> probleme
c
      else
c
        codret = 23
c
      endif
c
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
