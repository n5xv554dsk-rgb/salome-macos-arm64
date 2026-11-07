      subroutine utcte1 ( ntorig, typnom, option,
     >                    ntconv, adconv, nbconv,
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
c    UTilitaire - Conversion de Tableau Entier - action 1
c    --           -             -       -               -
c
c   On retourne un tableau entier qui contient :
c   . soit 0 si le critere n'est pas satisfait,
c   . soit le rang correspondant si le critere est satisfait
c    . si abs(option) = 1 : on retient les valeurs non nulles
c    . si abs(option) = 2 : on retient les valeurs strictement positives
c    . si abs(option) = 3 : on retient les valeurs strictement negatives
c    . si option > 0 : ce rang est celui dans le tableau initial
c    . si option < 0 : ce rang est le numero d'apparition de la valeur
c
c Exemples : tableau d'origine : (  0, 13,  0, -1,  4, -3,  0,  1 )
c
c  option  1 : filtre les valeurs non nulles, selon le rangement initial
c            tableau converti  : (  2,  4,  5,  6,  8,  0,  0,  0)
c  option -1 : filtre les valeurs non nulles, selon l'ordre d'apparition
c            tableau converti  : (  0,  1,  0,  2,  3,  4,  0,  5)
c  option  2 : filtre les valeurs > 0, selon le rangement initial
c            tableau converti  : (  2,  5,  8,  0,  0,  0,  0,  0)
c  option -2 : filtre les valeurs > 0, selon l'ordre d'apparition
c            tableau converti  : (  0,  1,  0,  0,  2,  0,  0,  3)
c  option  3 : filtre les valeurs < 0, selon le rangement initial
c            tableau converti  : (  4,  6,  0,  0,  0,  0,  0,  0)
c  option -3 : filtre les valeurs < 0, selon l'ordre d'apparition
c            tableau converti  : (  0,  0,  0,  1,  0,  2,  0,  0)
c
c remarque : l'action elle-meme est faite dans utcte3
c            ici, on traite les allocations de tableau
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ntorig . e   .   *    . objet contenant le tableau a convertir     .
c . typnom . e   .    1   . 0 : le nom du tableau converti est a creer .
c .        .     .        .     automatiquement                        .
c .        .     .        . 1 : le nom est impose a l'appel            .
c . option . e   .    1   . option de la conversion                    .
c .        .     .        . abs(option) = 1 : les valeurs non nulles   .
c .        .     .        . abs(option) = 2 : les valeurs > 0          .
c .        .     .        . abs(option) = 3 : les valeurs < 0          .
c .        .     .        . option > 0 : rang dans le tableau initial  .
c .        .     .        . option < 0 : numero d'apparition           .
c . ntconv . es  .   *    . objet contenant le tableau converti        .
c . adconv .   s .   1    . adresse du tableau converti                .
c . nbconv .   s .   1    . nombre de valeurs filtrees                 .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . -1 : mauvaise demande pour le type de nom  .
c .        .     .        . -2 : mauvaise demande pour l'option        .
c .        .     .        . -3 : probleme sur le tableau a convertir   .
c .        .     .        . autre : probleme dans l'allocation         .
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
      parameter ( nompro = 'UTCTE1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      character*(*) ntorig, ntconv
c
      integer typnom, option
      integer adconv
      integer nbconv
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer adorig, nborig
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) = '(''Conversion du tableau entier : '',a)'
      texte(1,4) = '(''Option :'',i4)'
      texte(1,5) = '(''Mauvaise demande de type de nom :'',i8)'
      texte(1,6) = '(''Mauvaise demande d''''option :'',i8)'
      texte(1,7) = '(''Probleme sur le tableau original.'')'
      texte(1,8) = '(''Probleme pour allouer le tableau converti.'')'
c
      texte(2,10) = '(''Conversion of integer array : '',a)'
      texte(2,4) = '(''Option :'',i4)'
      texte(2,5) = '(''Bad request for the name :'',i8)'
      texte(2,6) = '(''Bad request for the option :'',i8)'
      texte(2,7) = '(''Problem with the origin array.'')'
      texte(2,8) = '(''Problem while allocating object '')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) ntorig
      write (ulsort,texte(langue,4)) option
#endif
c
c====
c 2. prealables
c====
c
c 2.1. ==> caracteristiques du tableau a convertir
c
      call gmadoj ( ntorig, adorig, nborig, codret )
c
      if ( codret.ne.0 ) then
        codret = -3
      endif
c
c 2.2. ==> allocation du tableau converti
c
      if ( codret.eq.0 ) then
c
      if ( typnom.eq.0 ) then
c
        call gmalot ( ntconv, 'entier  ', nborig, adconv, codret )
        codret = abs(codret)
c
      elseif ( typnom.eq.1 ) then
c
        call gmaloj ( ntconv, 'entier  ', nborig, adconv, codret )
        codret = abs(codret)
c
      else
c
        codret = -1
c
      endif
c
      endif
c
c====
c 3. conversion
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      iaux = min(nborig,15)
      call gmprot (nompro, ntorig, 1, 15 )
      if ( nborig.gt.15 ) then
        call gmprot (nompro, ntorig, nborig-iaux+2, nborig )
      endif
#endif
c
      call utcte3 ( option, nborig, imem(adorig),
     >              nbconv, imem(adconv),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      iaux = min(nborig,15)
      call gmprot (nompro, ntconv, 1, 15 )
      if ( nborig.gt.15 ) then
        call gmprot (nompro, ntconv, nborig-iaux+2, nborig )
      endif
#endif
c
      endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,10)) ntorig
      if ( codret.eq.-1 ) then
        write (ulsort,texte(langue,5)) typnom
      elseif ( codret.eq.-2 ) then
        write (ulsort,texte(langue,6)) option
      elseif ( codret.eq.-3 ) then
        write (ulsort,texte(langue,7))
      else
        write (ulsort,texte(langue,8))
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      endif
c
      end
