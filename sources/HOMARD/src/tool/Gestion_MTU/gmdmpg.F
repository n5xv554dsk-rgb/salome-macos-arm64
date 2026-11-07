      subroutine gmdmpg ( minmeg, ntroug, nballg, ptroug, ltroug,
     >      ptallg, lgallg, adug, nommxg, nomalg, jgen, typtab,
     >      gmimp )
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
c .  - interet:
c .       impression detaillee du contenu d'un tableau de travail
c .          ( caracteristiques des trous et des zones allouees)
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . minmeg . e   .        . valeur entiere memorisant la plus petite   .
c .        .     .        . dimension du dernier trou afin de connaitre.
c .        .     .        . le passage le plus delicat rencontre au    .
c .        .     .        . cours de l'allocation. cette valeur est    .
c .        .     .        . calculee apres compression                 .
c . ntroug . e   .        . valeur entiere . nombre de trous present   .
c . nballg . e   .        . nombre de tableaux deja alloues            .
c . ptroug . e   .        . tableau entier contenant les pointeurs     .
c .        .     .        . repertoriant la position des trous         .
c . ltroug . e   .        . tableau entier contenant la long. des trous.
c . ptallg . e   .        . tableau entier contenant les pointeurs     .
c .        .     .        . repertoriant la position des tableaux      .
c . lgallg . e   .        . tableau entier contenant la longueur des   .
c .        .     .        . tableaux                                   .
c . nommxg . e   .        . chaine de caractere(*8) contenant le nom du.
c .        .     .        . plus grand tableau associe a minmeg        .
c . nomalg . e   .        . tableau de chaines de caracteres contenant .
c .        . e   .        . le nom associe a chaque tableau deja alloue.
c . jgen   . e   .        . dimension reservee au depart
c . typtab . e   .        . type du tableau :r,i,s,d,c                 .
c . gmimp  . e   .    1   . 0 => pas d'impression                      .
c .        .     .        . <=2 => impression simple                   .
c .        .     .        . >2 => impression etendue                   .
c ______________________________________________________________________
c
c ......................................................................
c .    creation gn octobre 1993 a partir des versions specifiques
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
      parameter ( nompro = 'GMDMPG' )
c
#include "genbla.h"
#include "gmmaxt.h"
#include "gmptrd.h"
c
c 0.2. ==> communs
c
#include "gmtail.h"
#include "gmtyge.h"
c
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character*1 typtab
      character*8 nommxg, nomalg(maxtab)
      integer adug(maxtab)
c
      integer minmeg, ntroug, nballg, jgen
      integer ptroug(maxtrs) , ltroug(maxtrs)
      integer ptallg(maxtab) , lgallg(maxtab)
      integer gmimp
c
c 0.4. ==> variables locales
c
      integer maxg , mtot , ilgmax , maxiut, numtyp
      integer iaux , jaux , kaux , kaux1
      integer nbrreg , iall , ideb , ifin
      integer tabaux(0:maxtab)
c
      character*14 saux14
      character*17 blabla(nblang,3)
      character*50 texte1
c
      integer nbmess
      parameter ( nbmess = 21 )
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
      texte(1,4) =
     > '(/18(''=''),'' Etat de la memoire en '',a17,17(''=''))'
      texte(1,5) =
     > '(/,''Nombre d''''objets alloues . . . . . . . :'',i12)'
      texte(1,6) = '(''Longueur totale en mots . . . . . . . :'',i12)'
      texte(1,7) = '(''Longueur totale en octets . . . . . . :'',i12)'
      texte(1,8) = '(''Maximum reserve a la compilation  . . :'',i12)'
      texte(1,9) = '(''Maximum reserve . . . . . . . . . . . :'',i12)'
      texte(1,10) ='(''Plus grand trou disponible. . . . . . :'',i12)'
      texte(1,11) ='(''Nombre de trous . . . . . . . . . . . :'',i12)'
      texte(1,12) =
     > '(''Maximum disponible actuel (cumul) . . :'',i12)'
      texte1 = '(''Plus grande zone deja allouee . : apres '',a8,'', '
c               12 34567890123456789012345678901234567890123 45678 90
      texte(1,13) = texte1//'de taille '',i12)'
      texte(1,14) =
     > '(''- Trou no'',i5,'' adresse :'',i12,'', longueur :'',i12)'
      texte1 = '(/,''Region occupee no'',i5,/,''. Adresse :'',i12'
c               1234 567890123456789012 3456789 012345678901234567 890
      texte(1,15) = texte1//''' . Longueur :'',i12)'
      texte1 = '(11(''=''),'' Fin de la gestion de la memoire en '',  '
c               12345 67 890 1234567890123456789012345678901234567 890
      texte(1,19) = texte1//'a17,11(''='')/)'
      texte(1,20) =
     >'(''Type '''',a1,'''' inconnu. Il faut r, i, d, s ou c.'')'
      texte(1,21) = '(''La memoire est geree dynamiquement.'')'
c
      texte(2,4) =
     > '(/18(''=''),'' Status of memory in '',a17,17(''=''))'
      texte(2,5) =
     > '(/,''Number of allocated objects . . . . . :'',i12)'
      texte(2,6) = '(''Total length in words . . . . . . . . :'',i12)'
      texte(2,7) = '(''Total length in bits  . . . . . . . . :'',i12)'
      texte(2,8) = '(''Maximum reserved in compilation . . . :'',i12)'
      texte(2,9) = '(''Maximum reserved  . . . . . . . . . . :'',i12)'
      texte(2,10) ='(''Greatest available hole . . . . . . . :'',i12)'
      texte(2,11) ='(''Number of holes . . . . . . . . . . . :'',i12)'
      texte(2,12) =
     > '(''Current available maximum (total) . . :'',i12)'
      texte1 = '(''Greatest zone already allocated : after '',a8,  '
c               12 345678901234567890123456789012345678901234567890
      texte(2,13) = texte1//''', of size '',i12)'
      texte1 ='(''- Hole #'',i5,'' adress :'',i12,'', length :'''
c              12 345678901 23456 7890123456789012 34567 89012345678 90
      texte(2,14) = texte1//',i12)'
      texte1 = '(/,''Occupied region #'',i5,/,''. Adress:'',i12,'
c               1234 567890123456789012 3456789 01234567890123456 7890
      texte(2,15) = texte1//''' . Length:'',i12)'
      texte(2,17) = '(65(''-''))'
      texte1 = '(14(''=''),'' End of the memory gestion in '','
c               12 34567890123456789012 3456789 012345678901234567890
      texte(2,19) = texte1//'a17,13(''='')/)'
      texte(2,20) =
     >'(''Type '''',a1,'''' unknown. Only r, i, d, s or c.'')'
      texte(2,21) = '(''Memory is used dynamically.'')'
c
      blabla(1,1) = 'reel ============'
      blabla(1,2) = 'entier =========='
      blabla(1,3) = 'caractere ======='
c
      blabla(2,1) = 'real ============'
      blabla(2,2) = 'integer ========='
      blabla(2,3) = 'character ======='
c
 1001 format (74('-'))
 1002 format ('! Tableau  !    Taille',a,'Adresse  ',
     >a,'Adresse utile !')
 1003 format ('! ',a8,' !',i14,' !',i21,' !',i21,' !')
      saux14 = '     !        '
c
c     Pour eviter un message de ftnchek :
      tabaux(0) = 0
c
c====
c  2. preliminaires
c====
c
      if ( typtab.eq.'r' .or. typtab.eq.'R' ) then
         numtyp  = 1
      elseif ( typtab.eq.'i' .or. typtab.eq.'I' ) then
         numtyp  = 2
      elseif ( typtab.eq.'s' .or. typtab.eq.'S' ) then
         numtyp  = 3
      else
        write (ulsort,texte(langue,1)) 'Sortie', nompro
         write (ulsort,texte(langue,20)) typtab
         call ugstop( nompro,ulsort,1,0,1)
      endif
c
c====
c 3. bilan de l'etat de la memoire
c====
c
c 3.1. ==> generalites
c
      write (ulsort,texte(langue,4)) blabla(langue,numtyp)
      write (ulsort,texte(langue,5)) nballg
c
      iaux = 0
      do 31 , kaux = 1 , nballg
        iaux = iaux + lgallg(kaux)
   31 continue
      write (ulsort,texte(langue,6)) iaux
c
      if ( typtab.eq.'i'.or.typtab.eq.'I') then
        kaux = tentie
      elseif ( typtab.eq.'s'.or.typtab.eq.'S') then
        kaux = tchain
      elseif ( typtab.eq.'r'.or.typtab.eq.'R') then
        kaux = treel
      endif
      iaux = kaux*iaux
      write (ulsort,texte(langue,7)) iaux
c
      call gmmaxi( maxg , mtot , ntroug, ltroug )
c
      ilgmax = jgen
      maxiut = ilgmax - minmeg
c
      if ( modgm.le.1 ) then
        if ( modgm.eq.0 ) then
          write (ulsort,texte(langue,8)) ilgmax
        else
          write (ulsort,texte(langue,9)) ilgmax
        endif
        write (ulsort,texte(langue,10)) maxg
        write (ulsort,texte(langue,11)) ntroug
        write (ulsort,texte(langue,12)) mtot
        if ( maxiut.ne.1 ) then
           write (ulsort,texte(langue,13)) nommxg, maxiut
        endif
        if (ntroug.ne.0) then
          write (ulsort,texte(langue,14))
     >                    (iaux,ptroug(iaux),ltroug(iaux),iaux=1,ntroug)
        endif
      else
        write (ulsort,texte(langue,21))
      endif
c
c 3.2. ==>  chaque region precedant un trou, sauf la derniere
c           remarque : en dynamique, la notion de region n'existe pas.
c                      Il n'y a pas de trou.
c
c            ideb = position de la fin du trou precedent
c                 = position du debut de la region
c            ifin = position du debut du trou
c                 = position de la fin de la region
c            iall = numero du premier tableau de la region
c            kaux1 = numero du premier tableau de la region suivante
c
      if ( gmimp.gt.2 ) then
c
      nbrreg = 1
      ideb = ptrdeb
      iall = 1
c
      do 32 , iaux = 1 , ntroug
c
        ifin = ptroug(iaux)
c
c 3.2.1. ==> recherche du numero du premier tableau de la region
c              suivante, eventuellement fictif si on arrive au bout
c
        do 321, kaux = iall , nballg
          if ( ptallg(kaux).gt.ifin ) then
             kaux1 = kaux
             go to 322
          endif
  321   continue
c
        kaux1 = nballg + 1
c
  322   continue
c
c 3.2.2. ==> impression des caracteristiques de la region, si elle
c              n'est pas vide
c
        if ( kaux1-1.ge.iall ) then
c
          write (ulsort,texte(langue,15)) nbrreg, ideb, ifin-ideb
          write (ulsort,1001)
          write (ulsort,1002) saux14, saux14
          write (ulsort,1001)
          do 323, kaux = iall , kaux1-1
            write (ulsort,1003) nomalg(kaux), lgallg(kaux),
     >                        ptallg(kaux), adug(kaux)
  323     continue
          write (ulsort,1001)
          write (ulsort,*) ' '
c
        endif
c
c 3.2.3. ==> reactualisation des grandeurs pour la region suivante
c
        iall = kaux1
        ideb = ifin + ltroug(iaux)
        nbrreg = nbrreg + 1
c
   32 continue
c
c 3.3. ==> on imprime la fin
c          . l'integralite, s'il n'y a pas de trou
c          . ce qui suit le dernier trou, s'il y en a
c
      if ( iall.le.nballg ) then
c
c 3.3.1. ==> tri par valeur d'adresse croissante
c
        kaux = 0
        do 331 , iaux = iall , nballg
          do 3311 , jaux = 1 , kaux
            if ( adug(tabaux(jaux)).gt.adug(iaux) ) then
              kaux1 = jaux
              goto 3312
            endif
 3311     continue
          kaux1 = kaux + 1
 3312     continue
          do 3313 , jaux = kaux , kaux1 , -1
            tabaux(jaux+1) = tabaux(jaux)
 3313     continue
          tabaux(kaux1) = iaux
          kaux = kaux + 1
  331   continue
c
c 3.3.2. ==> affichage
c
        if ( modgm.le.1 ) then
          write (ulsort,texte(langue,15)) nbrreg, ideb,
     >                                    ilgmax+ptrdeb-ideb
        endif
        write (ulsort,1001)
        write (ulsort,1002) saux14, saux14
        write (ulsort,1001)
        do 33, kaux = 1, kaux
          kaux1 = tabaux(kaux)
          write (ulsort,1003) nomalg(kaux1), lgallg(kaux1),
     >                      ptallg(kaux1), adug(kaux1)
   33   continue
        write (ulsort,1001)
        write (ulsort,*) ' '
c
      endif
c
      endif
c
c 3.4. ==> fin
c
      write (ulsort,texte(langue,19)) blabla(langue,numtyp)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
