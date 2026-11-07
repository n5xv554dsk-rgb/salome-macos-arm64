      subroutine gmmodi ( nomtab, typmod, lgold, lgnew,
     >                    point, d1old, d1new, d2old, d2new )
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
c ......................................................................
c .           auteur : gn 09/93
c ......................................................................
c .
c . si les tailles sont toutes positives :
c          on passe de tab(d1old,d2old) a tab(d1new,d2new)
c . si les tailles d1x sont negatives et les tailles d2x positives :
c          on passe de tab(d1old:d2old) a tab(d1new:d2new)
c . sinon : probleme ...
c .
c .  - realisation:
c .       tentative d'extension a l'extremite du tableau.
c .       sinon reallocation recopie des donnees,
c .       suppression de l'original, reaffectation du nom original
c .
c .  - arguments:
c . donnees nomtab  --> nom du tableau a etendre (8 caracteres au plus)
c .         typmod  --> A. tableau de type tab(d1,1), d1>=0
c .           11 : d1 : allongement,          d2 : constant a 1
c .           12 : d1 : raccourcissemement,   d2 : constant a 1
c .                     B. tableau de type tab(1,d2), d2>=0
c .           21 : d1 : constant a 1,         d2 : allongement
c .           22 : d1 : constant a 1,         d2 : raccourcissemement
c .                     C. tableau de type tab(d1,d2) avec d1>0 et d2>=0
c .            1 : d1 : pas de particularite, d2 : de 0 a >=0
c .            2 : d1 : pas de particularite, d2 : de >=0 a 0
c .            5 : pas de particularites
c .                     D. tableau de type tab(d1,d2) avec d1>0 et d2>0
c .            3 : d1 : de 0 a >=0, d2 : pas de particularite
c .            4 : d1 : de >=0 a 0, d2 : pas de particularite
c .            5 : pas de particularites
c .                     E. tableau de type tab(0:d2)
c .           31 : d1 : constant a 0,         d2 : allongement
c .           32 : d1 : constant a 0,         d2 : raccourcissemement
c .                     F. tableau de type tab(d1:d2) d1<=0 et d2>=0
c .           -1 : d1 : allongement,          d2 : constante
c .           -2 : d1 : constante,            d2 : allongement
c .           -3 : d1 : raccourcissemement,   d2 : constante
c .           -4 : d1 : constante,            d2 : raccourcissemement
c .           -5 : pas de particularites
c .                     G. tableau de longueur nulle passant au
c .                        type tab(1:d2) ou tab(d1:1)
c .           41 : tab(1:d2)
c .           51 : tab(d1:1)
c .                     H. tableau devenant de longueur nulle
c .           61 :
c .         lgold   --> longueur avant
c .         lgnew   --> longueur apres
c .         d1old   --> premiere dimension avant
c .         d1new   --> premiere dimension apres
c .         d2old   --> seconde dimension avant
c .         d2new   --> seconde dimension apres
c .resultat  point  <--  pointeur associe
c ......................................................................
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
      parameter ( nompro = 'GMMODI' )
c
#include "genbla.h"
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmadui.h"
#include "gmtren.h"
#include "gmalen.h"
#include "gmindi.h"
#include "gmindf.h"
c
#include "envex1.h"
#include "gmcoer.h"
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character *(*) nomtab
c
      integer typmod, lgold, lgnew
      integer d1old, d1new, d2old, d2new
      integer point
c
c 0.4. ==> variables locales
c
      integer iaux
      integer i, ideb, ifin, j, d1min, d2min
      integer kdeb, kfin, k, kaux
      integer iptold
      integer lgallo
c
      character*8 nomvar, tablte
      character*1 type1
c
      logical detlg0
      logical satien
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'typmod =', typmod
      write (ulsort,*) 'lgold =', lgold
      write (ulsort,*) 'lgnew=', lgnew
#endif
c
      coergm = 0
c
c====
c 2. verifications initiales
c====
c
      call gmcata ( nomtab, lgallo,
     >              nballi, nomali, lgalli )
c
      if ( lgallo.ne.lgold ) then
        write(ulsort,20000) nompro, nomtab, lgallo, lgold
20000   format ( 2x,'Probleme dans ',a6,' pour le tableau ',a,
     >         /,4x,'. Longueur d''allocation : ',i10 ,
     >         /,4x,'. Longueur ''ancienne''   : ',i10 ,
     >         /,4x,'    ===>  arret dans le gestionnaire de memoire')
        coergm = 4
      endif
c
c====
c 3. appel aux programmes generiques
c====
c
      if ( coergm.eq.0 ) then
c
      type1 = 'i'
c
c 3.1. ==> allongement d'un tableau conceptuellement 1D
c          .  1     : tableau tab(d1,0) passant a tab(d1,d2)
c          .  3     : tableau tab(0,d2) passant a tab(d1,d2)
c          . 11, 21 : tableau tab(d1,d2), dont l'une des dimensions
c                     vaut toujours 1 et dont l'autre augmente
c          . 31     : tableau tab(0:d2) dont d2 augmente
c          . 41     : tableau tab(0,0) passant a tab(1:d2) et d2>=0
c          . 51     : tableau tab(0,0) passant a tab(d1:1) et d1>=0
c
cgn        if (typmod.eq.32 .or. typmod.eq.31 ) then
cgn      if ( nomtab.eq.'MaEn002f' ) then
cgn          write (ulsort,*) 'nomtab = ', nomtab
cgn         write(ulsort,*) 'typmod = ',typmod
cgn         write(ulsort,*) 'lgold, lgnew = ',lgold, lgnew
cgn         write(ulsort,*) 'd1old, d1new = ',d1old, d1new
cgn         write(ulsort,*) 'd2old, d2new = ',d2old, d2new
cgn      endif
cgn        endif
      if ( typmod.eq.1 .or. typmod.eq.3 .or.
     >     typmod.eq.11 .or. typmod.eq.21 .or. typmod.eq.31 .or.
     >     typmod.eq.41 .or. typmod.eq.51 ) then
c
         call gmextg
     >  ( nomtab,   point,  lgnew, iptold, lgold,   type1,
     >    minmei, ntroui, nballi, totali,
     >    ptroui, ltroui, ptalli, lgalli, adui,
     >    nommxi, nomali, satien, tablte )
c
c 3.2. ==> raccourcissement d'un tableau conceptuellement 1D
c          . 12, 22 : tableau tab(d1,d2), dont l'une des dimensions
c                     vaut toujours 1 et dont l'autre diminue
c          . 32     : tableau tab(0:d2) dont d2 diminue
c          attention : il ne faut pas traiter ici des diminutions
c                      qui conduisent a un tableau de taille nulle
c                      sinon on risque de creer une zone complete de
c                      taille nulle, ce qui pose des problemes a la
c                      compression. on passera donc par le cas general
c                      ce qui permettra de regrouper ces tableaux de
c                      taille nulle en tete de memoire.
c
      elseif ( typmod.eq.12 .or. typmod.eq.22 .or. typmod.eq.32 ) then
c
         detlg0 = .false.
c
         call gmdesi ( nomtab, lgold-lgnew  , detlg0 )
         satien = .true.
c
c rafraichissement eventuel du pointeur point
c (dont la valeur a pu changer, en mode gm "dynamique")
c
         nomvar = '        '
         if ( len(nomtab).gt.0 ) then
           nomvar(1:min(8,len(nomtab))) = nomtab(1:min(8,len(nomtab)))
         endif
         do 321 , i = 1, nballi
            if ( nomali(i).eq.nomvar ) then
               point = adui(i)
               goto 322
            endif
  321    continue
c
         write(ulsort,30000) nompro, nomvar
         coergm = 7
c
30000 format( 2x,'Anomalie dans le sp ',a6,
     >       /4x,'Le tableau a modifier ',a8,' n''a pas ete retrouve',
     >       /4x,'    ===>  arret dans le gestionnaire de memoire')
c
  322    continue
c
c 3.3. ==> .  2     : tableau tab(d1,d2) passant a tab(d1,0)
c          .  4     : tableau tab(d1,d2) passant a tab(0,d2)
c          .  5     : pas de particularites
c          . negatif : tableau de type tab(d1:d2) d1<=0 et d2>=0
c
      else
c
        satien = .false.
c
cgn      if ( nomtab.eq.'MaCo002n' ) then
cgn         write(ulsort,*) 'appel de gmmodg'
cgn      endif
         call gmmodg
     >  ( nomtab, lgold, lgnew,
     >    d1old,  d1new,  d2old,  d2new,
     >    point, iptold,   type1,
     >    minmei, ntroui, nballi, totali,
     >    ptroui, ltroui, ptalli, lgalli, adui,
     >    nommxi, nomali, tablte )
c
cgn      if ( nomtab.eq.'MaCo002n' ) then
cgn         write(ulsort,*) 'retour de gmmodg'
cgn      endif
      endif
c
      endif
c
c====
c 4. remplissage correct du tableau
c====
c
      if ( coergm.eq.0 ) then
c
c 4.1. ==> si le tableau a pu etre etendu sur sa fin, il faut
c          initialiser a la valeur indefinie le complement
c
      if ( satien ) then
c
         if ( lindef.eq.0 ) then
            ideb = point+lgold
            ifin = point+lgnew-1
            do 41 , i= ideb ,ifin
              imem(i) = iindef
   41       continue
         endif
c
c 4.2. ==> si le tableau a du etre recree ailleurs, il faut recopier
c
      else
c
c 4.2.1. ==> on commence eventuellement a mettre une valeur par defaut
c            partout
c
        if ( lindef.eq.0 ) then
          ideb = point
          ifin = point+lgnew-1
          do 42 , i= ideb ,ifin
            imem(i) = iindef
   42     continue
        endif
c
c 4.2.2. ==> copie des valeurs
c 4.2.2.1. ==> tableau 1D :
c avant  indice :  1   2   3   4
c        valeur :  6   1   0   5
c Il y a 2 cas de figure :
c . allongement :
c indice : 1   2   3   4   5   6
c valeur : 6   1   0   5   x   x
c . raccourcissement :
c indice : 1   2
c valeur : 6   1
c
c    il suffit de recopier les premieres valeurs aux premieres places.
c    le nombre de valeurs a copier est le min entre le nombre qui etait
c    present et le nombre qu'on veut
c
        if ( typmod.ge.11 .and. typmod.le.32 ) then
c
          kdeb = iptold
          kfin = kdeb + min(lgold,lgnew) - 1
          kaux = point - kdeb
          do 431 , k = kdeb , kfin
            imem(kaux+k) = imem(k)
  431     continue
c
c 4.2.2.2. ==> tableau tab(d1,d2) :
c    il faut recopier les anciennes valeurs a leurs places :
c    ex. a(1,1)=1    a(1,2)=2    a(1,3)=3
c        a(2,1)=4    a(2,2)=5    a(2,3)=6
c    le tableau a(2x3) est range ainsi : 1 4 2 5 3 6
c    s'il devient un tableau a(3x3), les anciennes valeurs seront
c    mises ainsi : 1 4 x 2 5 x 3 6 x
c                         new(i,j) = old(i,j)
c <==>         new (d1new*(j-1)+i) = old (d1old*(j-1)+i)
c <==>  mem (point-1+d1new*(j-1)+i) = mem (iptold-1+d1old*(j-1)+i)
c
c    remarque : rien n'est a faire pour les cas 1 et 2 car l'un des
c               deux tableaux (avant ou apres) est de longueur nulle.
c
        elseif ( typmod.eq.5 ) then
c
          d2min = min(d2old,d2new)
          d1min = min(d1old,d1new)
cgn      if ( nomtab.eq.'MaCo002n' ) then
cgn         write(ulsort,*) 'd1min, d2min = ', d1min, d2min
cgn      endif
          do 432 , j = 1 , d2min
            kdeb = iptold + d1old*(j-1)
            kfin = kdeb + d1min - 1
            kaux = point - iptold + (d1new-d1old)*(j-1)
            do 4321 , k = kdeb , kfin
              imem(kaux+k) = imem(k)
 4321       continue
  432     continue
cgn      if ( nomtab.eq.'MaCo002n' ) then
cgn         write(ulsort,*) 'fin de 432'
cgn      endif
c
c 4.2.2.3. ==> tableau tab(d1:d2) :
c    il faut recopier les anciennes valeurs a leurs places :
c avant  indice :  -6  -5  -4  -3  -2  -1   0   1   2   3   4
c        valeur :   3   2   8   2   7   9   6   1   0   5   3
c Il y a 4 cas de figure :
c . allongement des deux cotes :
c   (d1old,d2old) = (-6,-8)  et (d2old,d2new) = (3,6)
c indice : -8  -7  -6  -5  -4  -3  -2  -1   0   1   2   3   4   5   6
c valeur :  x   x   3   2   8   2   7   9   6   1   0   5   3   x   x
c . raccourcissement des deux cotes :
c   (d1old,d2old) = (-6,-4)  et (d2old,d2new) = (3,2)
c indice :                 -4  -3  -2  -1   0   1   2
c valeur :                  8   2   7   9   6   1   0
c . allongement vers les negatifs, raccourcissement vers les positifs :
c   (d1old,d2old) = (-6,-8)  et (d2old,d2new) = (3,2)
c indice : -8  -7  -6  -5  -4  -3  -2  -1   0   1   2
c valeur :  x   x   3   2   8   2   7   9   6   1   0
c . raccourcissement vers les negatifs, allongement vers les positifs :
c   (d1old,d2old) = (-6,-4)  et (d2old,d2new) = (3,6)
c indice :                 -4  -3  -2  -1   0   1   2   3   4   5   6
c valeur :                  8   2   7   9   6   1   0   5   3   x   x
c
c   On doit donc transferer la partie correspondant a l'intervalle
c   commun autour du point central. Ce point central correspond a ce
c   qui est vu de l'exterieur comme tab(0).
c   Son adresse memoire est :
c   . dans l'ancien tableau : iptold - d1old
c   . dans le nouveau tableau : point - d1new
c   On doit transferer :
c   . min(-d1old,-d1new) cases avant ce point central
c   . min(d2old,d2new) cases apres ce point central
c
        elseif ( typmod.le.0 ) then
c
          kdeb = iptold - d1old - min(-d1old,-d1new)
          kfin = iptold - d1old + min(d2old,d2new)
          kaux = point - d1new - iptold + d1old
          do 4331 , k = kdeb , kfin
            imem(kaux+k) = imem(k)
 4331     continue
c
        endif
c
c 4.2.3. ==> renommage du tableau
c
         nomvar = '        '
         if ( len(nomtab).gt.0 ) then
           nomvar(1:min(8,len(nomtab))) = nomtab(1:min(8,len(nomtab)))
         endif
c
         call gmdesa (nomvar)
         if ( coergm.ne.0 ) then
            write(ulsort,40001) nompro, nomvar
            call ugstop(nompro,ulsort,1,1,1)
         endif
c
         do 4231 , i=1,nballi
            if ( nomali(i).eq.tablte ) then
               nomali(i) = nomvar
               goto 4232
            endif
 4231    continue
c
         write(ulsort,40000) nompro, tablte
         call ugstop(nompro,ulsort,1,1,1)
c
 4232    continue
         if ( nommxi.eq.tablte ) then
            nommxi = nomvar
         endif
c
         call gbntde ( tablte, coergm )
c
      endif
c
40000 format( 2x,'Anomalie dans le sp ',a6,
     >       /4x,'Le tableau temporaire ',a8,' n''a pas ete retrouve',
     >       /4x,'    ===>  arret dans le gestionnaire de memoire')
c
40001 format( 2x,'Anomalie dans le sp ',a6,
     >       /4x,'Desallocation temporaire du ',
     >       /4x,'tableau a modifier ',a8,' impossible',
     >       /4x,'    ===>  arret dans le gestionnaire de memoire')
c
      endif
c
      if ( coergm.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
      end
