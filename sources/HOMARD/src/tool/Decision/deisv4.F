      subroutine deisv4 ( ncmpin, usacmp, vasmax,
     >                    lamail, nbvolu, lesvol,
     >                    nbenti, enindi, eninin,
     >                    nbenvo, vosupp, voinin,
     >                    valaux,
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
c    traitement des DEcisions - Initialisations - par Saut - Volumes - 4
c                   --          -                     -      -         -
c   Exploration de la pile des voisins d'une maille
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ncmpin . e   .   1    . nombre de composantes de l'indicateur      .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . vasmax . es  .   1    . valeur max du saut de l'indicateur         .
c . lamail . e   .   1    . la maille en cours d'examen                .
c . nbvolu . e   .    1   . nombre de volumes a examiner               .
c . lesvol . e   . nbvolu . les volumes a examiner                     .
c . nbenti . e   .   1    . nombre d'entites courantes                 .
c . eninin . e   . ncmpin . valeur brute de l'indicateur sur la maille .
c . enindi . es  . ncmpin . valeur du saut de l'indicateur             .
c . nbenvo . e   .   1    . nombre d'entites du type des voisines      .
c . vosupp . e   . nbenvo . support pour les entites voisines          .
c . voinin . e   . nbenvo . valeurs initiales pour les entites voisines.
c . valaux . a   . ncmpin . tableau auxiliaire                         .
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
      parameter ( nompro = 'DEISV4' )
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
      integer ncmpin
      integer usacmp
      integer lamail
      integer nbvolu, lesvol(nbvolu)
      integer nbenti
      integer nbenvo, vosupp(nbenvo)
c
      integer ulsort, langue, codret
c
      double precision vasmax
      double precision eninin(nbenti,ncmpin), enindi(nbenti,ncmpin)
      double precision voinin(nbenvo,ncmpin)
      double precision valaux(ncmpin)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nuvolu, levolu
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Norme L2 des composantes.'')'
      texte(1,5) = '(''. Norme infinie des composantes.'')'
      texte(1,6) = '(''. Valeur relative de la composante.'')'
      texte(1,7) = '(''. Saut avec '',i10,'' mailles'')'
c
      texte(2,4) = '(''. L2 norm of components.'')'
      texte(2,5) = '(''. Infinite norm of components.'')'
      texte(2,6) = '(''. Relative value for the component.'')'
      texte(2,7) = '(''. Jump with the '',i10,'' meshes'')'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4+usacmp))
      write (ulsort,texte(langue,7)) nbvolu
#endif
c
c====
c 2. On parcourt tous les volumes de la pile :
c    on cherche le max de l'ecart entre la valeur de l'indicateur
c    sur ce volume voisin et celle sur le volume courant
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. parcours volumes pile ; codret = ', codret
#endif
c
      do 2 , nuvolu = 1 , nbvolu
c
        levolu = lesvol(nuvolu)
c
        if ( vosupp(levolu).ne.0 ) then
c
c 2.1. ==> Calcul de l'ecart entre la valeur sur la maille en cours
c          de test et le volume a examiner
c
          do 21 , iaux = 1 , ncmpin
            valaux(iaux) = voinin(levolu,iaux) - eninin(lamail,iaux)
   21     continue
c
c 2.2. ==> Calcul de la norme ; si on a passe le max, on stocke
c 2.2.1. ==> Calcul de la norme
c
          if ( usacmp.eq.0 ) then
c
            daux = valaux(1)**2
            do 2211 , iaux = 2 , ncmpin
              daux = daux + valaux(iaux)**2
 2211       continue
c
          elseif ( usacmp.eq.1 ) then
c
            daux = abs(valaux(1))
            do 2212 , iaux = 2 , ncmpin
              daux = max(daux,abs(valaux(iaux)))
 2212       continue
c
          else
c
            daux = valaux(1)
c
          endif
c
c 2.2.2. ==> On a passe le max : on stocke
c
          if ( daux.gt.vasmax ) then
            vasmax = daux
            do 222 , iaux = 1 , ncmpin
              enindi(lamail,iaux) = valaux(iaux)
  222       continue
          endif
c
        endif
c
    2 continue
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
