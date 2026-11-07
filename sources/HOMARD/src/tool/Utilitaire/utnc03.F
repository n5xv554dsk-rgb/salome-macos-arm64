      subroutine utnc03 ( option, nbanci, numfin,
     >                    arreca, arrecb,
     >                    somare, filare, merare,
     >                    ngenar, nouare, tabaux,
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
c    UTilitaire - Non Conformite - phase 03
c    --           -   -                  --
c    On change les numeros des aretes concernees par les non-conformites
c    On les regroupe par generations, en commencant par celle sans mere
c    puis celle avec mere, puis celle avec une mere et une grand-mere,
c    et ainsi de suite.
c    On regroupe ensuite les fratries.
c    Enfin, on etablit la bonne convention de numerotation des aretes
c    dans une fratrie
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . option de l'operation de renumerotation    .
c .        .     .        .  0 : dans chaque fratrie, on classe les    .
c .        .     .        .      aretes                                .
c .        .     .        . -n : decalage des aretes ayant une         .
c .        .     .        .      ascendance de n generations           .
c .        .     .        .  n : on regroupe par fratries les aretes   .
c .        .     .        .      ayant une  ascendance de n generations.
c . nbanci . e   .    1   . nombre d'aretes de non conformite initiale .
c .        .     .        . egal au nombre d'aretes recouvrant 2 autres.
c . numfin . es  .    1   . numero d'ordre maximal pour le classement  .
c . arreca . e   .2*nbanci. liste des aretes recouvrant une autre      .
c . arrecb . e   .2*nbanci. liste des aretes recouvertes par une autre .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . merare . e   . nbarto . mere des aretes                            .
c . ngenar . e   . nbarto . nombre de generations au-dessus des aretes .
c . nouare .  s  .0:nbarto. nouveau numero des aretes                  .
c . tabaux . a   .3*nbanci. tableau auxiliaire                         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . -1 : mauvaise option                       .
c .        .     .        . >0 : erreur dans le traitement de l'option .
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
      parameter ( nompro = 'UTNC03' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "impr02.h"
#include "envex1.h"
c
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbanci
      integer numfin
      integer arreca(2*nbanci), arrecb(2*nbanci)
      integer somare(2,nbarto)
      integer filare(nbarto), merare(nbarto)
      integer ngenar(nbarto), nouare(0:nbarto)
      integer tabaux(3,nbanci)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer numgen, ifin
      integer laret1, laret2, laretg
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de non-conformites :'',i10))'
      texte(1,5) = '(''Traitement numero'',i3))'
      texte(1,6) =
     > '(''Mise en coherence des '',a,''dans les fratries de '',a)'
      texte(1,7) = '(''Decalage des '',a,'' de generation'',i3)'
      texte(1,8) = '(''Regroupement des '',a,'' de generation'',i3)'
      texte(1,9) = '(''Classement avant'',i10)'
      texte(1,10) = '(i10,1x,a,''dans la generation'',i10)'
      texte(1,11) = '(''Nouveau numero du '',a,i10,'' : '',i10)'
      texte(1,12) = '(''Il devrait etre '',a,i10)'
      texte(1,18) = '(''Generation du '',a,i10,'' :'',i4)'
      texte(1,19) = '(''Examen du '',a,i10)'
      texte(1,20) = '(''.. couvert par le '',a,i10)'
c
      texte(2,4) = '(''Number of non-conformal situations :'',i10))'
      texte(2,5) = '(''Treatment #'',i3)'
      texte(2,6) =
     > '(''Coherence of '',a,''in brotherhood of '',a)'
      texte(2,7) = '(''Renumbering of '',a,'' in generation'',i3)'
      texte(2,8) = '(''Gathering of '',a,'' in generation'',i3)'
      texte(2,9) = '(''Sort before'',i10)'
      texte(2,10) = '(i10,1x,a,''in generation'',i10)'
      texte(2,11) = '(''New # for '',a,i10,'' : '',i10)'
      texte(2,12) = '(''It should be '',a,i10)'
      texte(2,18) = '(''Generation of '',a,i10,'' :'',i4)'
      texte(2,19) = '(''Examination of '',a,'' #'',i10)'
      texte(2,20) = '(''.. covered by '',a,'' #'',i10)'
c
c 1.2. ==> initialisation
c
      codret = 0
c
      if ( option.lt.0 ) then
        numgen = -option
      elseif ( option.gt.0 ) then
        numgen = option
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbanci
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) option
      if ( option.eq.0 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,-1),
     >                                 mess14(langue,3,1)
      else
        if ( option.lt.0 ) then
          write (ulsort,texte(langue,7)) mess14(langue,3,1), numgen
          write (ulsort,texte(langue,9)) numfin
        else
          write (ulsort,texte(langue,8)) mess14(langue,3,1), numgen
        endif
      endif
#endif
c
c 1.3. ==> Aucune renumerotation au depart
c
      do 12 , iaux = 0 , nbarto
        nouare(iaux) = iaux
   12 continue
c
c====
c 2. option < 0 : on rassemble les aretes de meme generation
c    on les deplace vers la fin, en prenant soin de ne pas ecraser
c    les generations plus jeunes (d'ou le demarrage a ifin)
c====
c
      if ( option.lt.0 ) then
c
        ifin = numfin
c
        do 21 , iaux = 1 , nbarto
c
          if ( codret.eq.0 ) then
c
          if ( ngenar(iaux).eq.numgen .and. iaux.le.ifin ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,19)) mess14(langue,1,1), iaux
#endif
            do 211 , jaux = ifin, 1, -1
              if ( jaux.eq.iaux ) then
                goto 212
              elseif ( ngenar(jaux).lt.numgen ) then
                nouare(jaux) = iaux
                nouare(iaux) = jaux
                ifin = jaux - 1
#ifdef _DEBUG_HOMARD_
                write (ulsort,texte(langue,19)) mess14(langue,1,1),iaux
                write (ulsort,*) iaux,' devient', jaux
#endif
                goto 212
              endif
  211       continue
c
            codret = option
c
  212       continue
c
            ifin = jaux - 1
            goto 21
c
          endif
c
          endif
c
   21   continue
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) numfin-ifin,
     >                                  mess14(langue,3,1), numgen
#endif
c
        numfin = ifin
c
c====
c 3. option > 0 : au sein d'une generation, les aretes sont regroupees
c                 par fratries
c====
c
      elseif ( option.gt.0 ) then
c
c 3.1. ==> Regroupement des triplets de filles adoptives et de mere
c 3.1.1. ==> Aucun regroupement au depart
c
        do 31 , iaux = 1 , nbanci
c
          tabaux(1,iaux) = 0
          tabaux(2,iaux) = 0
          tabaux(3,iaux) = 0
c
   31   continue
c
c 3.2. ==> On regroupe les triplets de filles adoptives et de mere
c          pour la generation de fille numgen
c
        if ( codret.eq.0 ) then
c
        kaux = 0
        ifin = 2*nbanci
        do 32 , iaux = 1 , ifin
c
          if ( codret.eq.0 ) then
c
          laret1 = arrecb(iaux)
c
          if ( ngenar(laret1).eq.numgen ) then
c
            laretg = arreca(iaux)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,19)) mess14(langue,1,1), laret1
          write (ulsort,texte(langue,20)) mess14(langue,1,1), laretg
#endif
c
c       on cherche si on a deja place l'arete jumelle de laret1
c       . si oui, on place l'arete courante en position 2
c       . si non, on place l'arete courante en position 1 et on
c         enregistre la mere adoptive
c
            do 321 ,  jaux = 1, kaux
c
              if ( tabaux(3,jaux).eq.laretg ) then
                if ( ngenar(tabaux(1,jaux)).ne.numgen ) then
          write (ulsort,texte(langue,18)) mess14(langue,1,1),
     >                                    laret1, numgen
          write (ulsort,texte(langue,18)) mess14(langue,1,1),
     >                     tabaux(1,jaux), ngenar(tabaux(1,jaux))
          write (ulsort,texte(langue,20)) mess14(langue,1,1), laretg
                  codret = option
                endif
                tabaux(2,jaux) = laret1
                goto 32
              endif
c
  321       continue
c
            kaux = kaux + 1
            tabaux(1,kaux) = laret1
            tabaux(3,kaux) = laretg
c
          endif
c
          endif
c
   32   continue
c
        endif
c
cgn        if ( codret.eq.0 ) then
cgn        call utvars ( 1, 2, kaux, tabaux,
cgn     >                somare,
cgn     >                ulsort, langue, codret )
cgn        write (ulsort,*) 'dans ',nompro,' ',1, 2,codret
cgn        endif
c
cgn        if ( codret.eq.0 ) then
cgn        call utvars ( 2, 3, kaux, tabaux,
cgn     >                somare,
cgn     >                ulsort, langue, codret )
cgn        write (ulsort,*) 'dans ',nompro,' ',2,3,codret
cgn        endif
cc
cgn        if ( codret.eq.0 ) then
cgn        call utvars ( 3, 1, kaux, tabaux,
cgn     >                somare,
cgn     >                ulsort, langue, codret )
cgn        write (ulsort,*) 'dans ',nompro,' ',3,1,codret
cgn        endif

c 3.3. ==> Les places 1 et 2 de tabaux contiennent les 2 numeros actuels
c          de 2 aretes soeurs, dans la generation numgen. Il y a kaux
c          couples de ce genre.
c          Ces aretes ont leurs numeros inferieurs a numfin.
c          On va les placer 2 par 2 a partir de numfin, en descendant.
c
        if ( codret.eq.0 ) then
c
        ifin = numfin
c
        do 33 , iaux = 1 , kaux
c
          if ( codret.eq.0 ) then
c
          laret1 = tabaux(1,iaux)
          laret2 = tabaux(2,iaux)
c
#ifdef _DEBUG_HOMARD_
cgn      if (laret1.eq.15935)then
      write (ulsort,texte(langue,19)) mess14(langue,1,1), laret1
      write (ulsort,texte(langue,19)) mess14(langue,1,1), laret2
      write (ulsort,texte(langue,20)) mess14(langue,1,1), tabaux(3,iaux)
cgn      endif
#endif
c
          nouare(laret1) = ifin
          nouare(laret2) = ifin - 1
c
          ifin = ifin - 2
c
          endif
c
   33   continue
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,10)) numfin-ifin,
     >                                  mess14(langue,3,1), numgen
#endif
c
        numfin = ifin
cgn        write (ulsort,9999) (iaux, nouare(iaux),iaux=1,nbarto)
cgn 9999 format('nouare(',i10,') = ',i10)
c
        endif
c
c====
c 5. option numero 0 : dans une fratrie, les soeurs sont rangees selon
c    les numeros des sommets de l'arete mere (cf. cmrda1)
c====
c
      elseif ( option.eq.0 ) then
c
        do 50 , iaux = 1 , nbarto
c
cgn      write (ulsort,*) 'arete ',iaux,' de fille ',filare(iaux)
          if ( filare(iaux).gt.0 ) then
c
            laret1 = filare(iaux)
            laret2 = filare(iaux) + 1
cgn      write (ulsort,*) '.. ',laret1, ' de ', somare(1,laret1),
cgn     >' a ',somare(2,laret1),' de mere ',merare(laret1)
cgn      write (ulsort,*) '.. ',laret2, ' de ', somare(1,laret2),
cgn     >' a ',somare(2,laret2),' de mere ',merare(laret2)
c
            if ( merare(laret2).eq.iaux ) then
c
            if ( somare(1,laret1).gt.somare(1,laret2) ) then
cgn      write (ulsort,*) 'echange des aretes ',laret1, ' et ', laret2
              nouare(laret1) = laret2
              nouare(laret2) = laret1
            endif
c
            endif
c
          endif
c
   50   continue
c
c
c====
c 6. option autre : impossible
c====
c
      else
c
        codret = -1
c
      endif
c
c====
c 7. la fin
c====
c
cgn      write (ulsort,*) 'nouare :'
cgn      write (ulsort,5555) (nouare(iaux),iaux=1,nbarto)
cgn 5555 format(10i8)
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
