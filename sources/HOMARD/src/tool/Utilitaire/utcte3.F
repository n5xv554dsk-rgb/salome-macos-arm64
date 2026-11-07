      subroutine utcte3 ( option, nborig, tborig,
     >                    nbconv, tbconv,
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
c    UTilitaire - Conversion de Tableau Entier - action 3
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
c remarque : l'action elle-meme est faite ici
c            on peut enrober ce traitement par utcte1, pour gerer
c            des allocations de tableau
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . option de la conversion                    .
c .        .     .        . abs(option) = 1 : les valeurs non nulles   .
c .        .     .        . abs(option) = 2 : les valeurs > 0          .
c .        .     .        . abs(option) = 3 : les valeurs < 0          .
c .        .     .        . option > 0 : rang dans le tableau initial  .
c .        .     .        . option < 0 : numero d'apparition           .
c . nborig . e   .    1   . nombre de valeurs dasn le tableau original .
c . tborig . e   . nborig . tableau original a convertir               .
c . tbconv .   s . nborig . tableau converti                           .
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
      parameter ( nompro = 'UTCTE3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nborig, nbconv
      integer tborig(nborig), tbconv(nborig)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
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
      texte(1,4) = '(''Option :'',i4)'
      texte(1,5) = '(''Mauvaise demande d''''option :'',i8)'
      texte(1,6) = '(''Tableau '',a,'', de'',i8,'' a'',i8,'' : '',10i8)'
      texte(1,7) = '(''Nombre de valeurs filtrees : '',i8)'
c
      texte(2,4) = '(''Option :'',i4)'
      texte(2,5) = '(''Bad request for the option :'',i8)'
      texte(2,6) = '(a,'' array, '',a,'' : '',10i8)'
      texte(2,7) = '(''Number of filtered values : '',i8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) option
#endif
c
      codret = 0
c
c====
c 2. conversion
c====
c
#ifdef _DEBUG_HOMARD_
      iaux = min(nborig,10)
      write (ulsort,texte(langue,6)) 'initial', 1, iaux,
     >            (tborig(jaux),jaux=1,iaux)
      if ( nborig.gt.10 ) then
        write (ulsort,texte(langue,6)) 'initial', nborig-iaux+2,nborig,
     >              (tborig(iaux),iaux=nborig-iaux+2,nborig)
      endif
#endif
c
      nbconv = 0
c
c 2.0. ==> mise a zero par defaut
c
      do 20 , iaux = 1 , nborig
        tbconv(iaux) = 0
   20 continue
c
c 2.1. ==> on considere toutes les valeurs non nulles
c
      if ( abs(option).eq.1 ) then
c
        do 21 , iaux = 1 , nborig
c
          if ( tborig(iaux).ne.0 ) then
            nbconv = nbconv + 1
            if ( option.gt.0 ) then
              tbconv(nbconv) = iaux
            else
              tbconv(iaux) = nbconv
            endif
          endif
c
   21   continue
c
c 2.2. ==> on considere toutes les valeurs non nulles et positives
c
      elseif ( abs(option).eq.2 ) then
c
        do 22 , iaux = 1 , nborig
c
          if ( tborig(iaux).gt.0 ) then
            nbconv = nbconv + 1
            if ( option.gt.0 ) then
              tbconv(nbconv) = iaux
            else
              tbconv(iaux) = nbconv
            endif
          endif
c
   22   continue
c
c 2.3. ==> on considere toutes les valeurs non nulles et positives
c
      elseif ( abs(option).eq.3 ) then
c
        do 23 , iaux = 1 , nborig
c
          if ( tborig(iaux).lt.0 ) then
            nbconv = nbconv + 1
            if ( option.gt.0 ) then
              tbconv(nbconv) = iaux
            else
              tbconv(iaux) = nbconv
            endif
          endif
c
   23   continue
c
c 2.4. ==> erreur
c
      else
c
        codret = -2
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nbconv
      iaux = min(nborig,10)
      write (ulsort,texte(langue,6)) 'final  ', 1, iaux,
     >            (tbconv(jaux),jaux=1,iaux)
      if ( nborig.gt.10 ) then
        write (ulsort,texte(langue,6)) 'final  ', nborig-iaux+2,nborig,
     >              (tbconv(iaux),iaux=nborig-iaux+2,nborig)
      endif
#endif
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
      write (ulsort,texte(langue,5)) option
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
