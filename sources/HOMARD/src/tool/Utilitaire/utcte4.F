      subroutine utcte4 ( option, nborig, tborig,
     >                    tbconv,
     >                    tbaux1, classt,
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
c    UTilitaire - Conversion de Tableau Entier - action 4
c    --           -             -       -               -
c
c   On retourne un tableau entier qui contient :
c   . soit 0 si le critere n'est pas satisfait,
c   . soit le rang correspondant si le critere est satisfait
c    . si option = 1 : on retient les valeurs non nulles
c    . si option = 2 : on retient les valeurs strictement positives
c    . si option = 3 : on retient les valeurs strictement negatives
c
c Exemples : tableau d'origine : (  0, 13,  0, -1,  4, -3,  0,  1 )
c
c  option  1 : ordonne les valeurs non nulles
c            tableau converti  : (  0,  5,  0,  2,  4,  1,  0,  3)
c  option  2 : ordonne les valeurs > 0
c            tableau converti  : (  0,  3,  0,  0,  2,  0,  0,  1)
c  option  3 : ordonne les valeurs < 0
c            tableau converti  : (  0,  0,  0,  2,  0,  1,  0,  0)
c
c remarque : l'action elle-meme est faite ici
c            on peut enrober ce traitement par utcte2, pour gerer
c            des allocations de tableau
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . option de la conversion                    .
c .        .     .        . option = 1 : les valeurs non nulles   .
c .        .     .        . option = 2 : les valeurs > 0          .
c .        .     .        . option = 3 : les valeurs < 0          .
c .        .     .        . option > 0 : rang dans le tableau initial  .
c .        .     .        . option < 0 : numero d'apparition           .
c . nborig . e   .    1   . nombre de valeurs dasn le tableau original .
c . tborig . e   . nborig . tableau original a convertir               .
c . tbconv .   s . nborig . tableau converti                           .
c . tbaux1 . aux . nborig . tableau auxiliaire 1                       .
c . classt . aux . nborig . tableau auxiliaire 2                       .
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
      parameter ( nompro = 'UTCTE4' )
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
      integer nborig
      integer tborig(nborig), tbconv(nborig)
      integer tbaux1(nborig), classt(nborig)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer vmin, vmax
      integer nbvalm, nbvalp
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
      texte(1,6) =
     >'(''Tableau '',a,'', de'',i13,'' a'',i13,'' : '',5i13,/,50x,5i13)'
      texte(1,7) = '(''Nombre de valeurs '',a,'' : '',i13)'
      texte(1,8) = '(''Valeur '',a,'' : '',i13)'
c
      texte(2,4) = '(''Option :'',i4)'
      texte(2,5) = '(''Bad request for the option :'',i8)'
      texte(2,6) =
     >'(''Array '',a,'', from'',i13,'' to'',i13,'' :'',5i13,/,49x,5i13)'
      texte(2,7) = '(''Number of values '',a,'' : '',i13)'
      texte(2,8) = '(''Value '',a,'' : '',i13)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) option
#endif
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      iaux = min(nborig,10)
      write (ulsort,texte(langue,6)) 'initial', 1, iaux,
     >            (tborig(jaux),jaux=1,iaux)
      if ( nborig.gt.10 ) then
        write (ulsort,texte(langue,6)) 'initial', nborig-iaux+1,nborig,
     >              (tborig(iaux),iaux=nborig-iaux+1,nborig)
      endif
#endif
c
c====
c 2. creation du tableau epure
c====
c
      nbvalm = 0
      nbvalp = 0
c
c 2.0. ==> mise a zero par defaut
c
      do 20 , iaux = 1 , nborig
        tbaux1(iaux) = 0
   20 continue
c
c 2.1. ==> on considere toutes les valeurs non nulles
c
      if ( option.eq.1 ) then
c
        do 21 , iaux = 1 , nborig
c
          if ( tborig(iaux).lt.0 ) then
            nbvalm = nbvalm + 1
            tbaux1(iaux) = tborig(iaux)
          elseif ( tborig(iaux).gt.0 ) then
            nbvalp = nbvalp + 1
            tbaux1(iaux) = tborig(iaux)
          endif
c
   21   continue
c
c 2.2. ==> on considere toutes les valeurs non nulles et positives
c
      elseif ( option.eq.2 ) then
c
        do 22 , iaux = 1 , nborig
c
          if ( tborig(iaux).gt.0 ) then
            nbvalp = nbvalp + 1
            tbaux1(iaux) = tborig(iaux)
          endif
c
   22   continue
c
c 2.3. ==> on considere toutes les valeurs non nulles et positives
c
      elseif ( option.eq.3 ) then
c
        do 23 , iaux = 1 , nborig
c
          if ( tborig(iaux).lt.0 ) then
            nbvalm = nbvalm + 1
            tbaux1(iaux) = tborig(iaux)
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
      if ( option.eq.1 .or. option.eq.3 ) then
      write (ulsort,texte(langue,7)) '< 0', nbvalm
      endif
      if ( option.eq.1 .or. option.eq.2 ) then
      write (ulsort,texte(langue,7)) '> 0', nbvalp
      endif
      iaux = min(nborig,10)
      write (ulsort,texte(langue,6)) 'filtre ', 1, iaux,
     >            (tbaux1(jaux),jaux=1,iaux)
      if ( nborig.gt.10 ) then
        write (ulsort,texte(langue,6)) 'filtre ',
     >               nborig-iaux+1, nborig,
     >              (tbaux1(iaux),iaux=nborig-iaux+1,nborig)
      endif
#endif
c
c====
c 3. tri du tableau epure
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTTRII', nompro
#endif
      call uttrii ( classt, vmin, vmax,
     >              nborig, tbaux1,
     >              ulsort, langue, codret)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) 'mini', vmin
      write (ulsort,texte(langue,8)) 'maxi', vmax
      iaux = min(nborig,10)
      write (ulsort,texte(langue,6)) 'classt ', 1, iaux,
     >            (classt(jaux),jaux=1,iaux)
      if ( nborig.gt.10 ) then
        write (ulsort,texte(langue,6)) 'classt ', nborig-iaux+1,nborig,
     >              (classt(jaux),jaux=nborig-iaux+1,nborig)
      endif
#endif
c
      endif
c
c====
c 4. rangement final
c====
c
      if ( codret.eq.0 ) then
c
      do 40 , iaux = 1 , nborig
        tbconv(iaux) = 0
   40 continue
c
      do 41 , iaux = 1 , nbvalm
        tbconv(classt(iaux)) = iaux
   41 continue
c
      jaux = nborig - nbvalp + 1
      kaux = nbvalm + 1 - jaux
      do 42 , iaux = jaux , nborig
        tbconv(classt(iaux)) = iaux + kaux
   42 continue
c
#ifdef _DEBUG_HOMARD_
      iaux = min(nborig,10)
      write (ulsort,texte(langue,6)) 'tbconv ', 1, iaux,
     >            (tbconv(jaux),jaux=1,iaux)
      if ( nborig.gt.10 ) then
        write (ulsort,texte(langue,6)) 'tbconv ', nborig-iaux+1,nborig,
     >              (tbconv(jaux),jaux=nborig-iaux+1,nborig)
      endif
#endif
c
      endif
c
c====
c 5. la fin
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
