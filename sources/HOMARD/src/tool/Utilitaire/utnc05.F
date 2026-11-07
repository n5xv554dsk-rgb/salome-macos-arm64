      subroutine utnc05 ( option, nbanci, numfin,
     >                    arreca, arrecb,
     >                    somare,
     >                    ngenar, ngenno, nounoe,
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
c    UTilitaire - Non Conformite - phase 05
c    --           -   -                  --
c    On change les numeros des noeuds concernees par les non-conformites
c    Le noeud correspondant au noeud commun a 2 aretes recouvertes
c    doit etre superieur a leurs 2 autres extremites. On le met donc
c    a la fin.
c    Attention a bien prendre en compte les noeuds isoles : il y en a
c    toujours un avec du saturne ou de neptune pseudo-2D (cf vcms21)
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .    1   . option de l'operation de renumerotation    .
c .        .     .        . -1 : creation des generations de noeuds    .
c .        .     .        . 2 : on met aux (2*nbanci+nbnois) premieres .
c .        .     .        .     places les sommets simples des aretes  .
c .        .     .        .     recouvrantes                           .
c . nbanci . e   .    1   . nombre d'aretes de non conformite initiale .
c .        .     .        . egal au nombre d'aretes recouvrant 2 autres.
c . numfin . es  .    1   . numero d'ordre maximal pour le classement  .
c . arreca . e   .2*nbanci. liste des aretes recouvrant une autre      .
c . arrecb . e   .2*nbanci. liste des aretes recouvertes par une autre .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . ngenar . e   . nbarto . nombre de generations au-dessus des aretes .
c . ngenno .  s  . nbnoto . nombre de generations au-dessus des noeuds .
c . nounoe .  s  . nbnoto . nouveau numero des noeuds                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'UTNC05' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "impr02.h"
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbanci, numfin
      integer arreca(2*nbanci), arrecb(2*nbanci)
      integer somare(2,nbarto)
      integer ngenar(nbarto), ngenno(nbnoto), nounoe(0:nbnoto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer numgen, ifin
      integer laret1, laretg
      integer lesomm
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
      texte(1,5) = '(''Traitement numero'',i3))'
      texte(1,6) = '(''Elaboration des generations de '',a)'
      texte(1,7) = '(''Decalage des '',a,'' de generation'',i3)'
      texte(1,9) = '(''Classement avant'',i10)'
      texte(1,10) = '(''.. couvert par le '',a,i10)'
      texte(1,11) = '(''  du '',a,i10,'' au '',a,i10)'
      texte(1,12) =
     >'(''Impossible de trouver un sommet commun a ces : '',a)'
      texte(1,13) = '(''Incoherence de generation'',)'
      texte(1,14) = '(''. Generation du '',a,i10,'' :'',i10)'
      texte(1,15) = '(''Examen du '',a,i10)'
      texte(1,20) = '(i10,1x,a,''dans la generation'',i10)'
c
      texte(2,5) = '(''Treatment #'',i3)'
      texte(2,6) = '(''Creation of generations of '',a)'
      texte(2,7) = '(''Renumbering of '',a,'' in generation'',i3)'
      texte(2,9) = '(''Sort before'',i10)'
      texte(2,10) = '(''.. covered by '',a,i10)'
      texte(2,11) = '(''  from '',a,i10,'' to '',a,i10)'
      texte(2,12) =
     >'(''A common node cannot be found for these '',a)'
      texte(2,13) = '(''Generations are not coherent.'')'
      texte(2,14) = '(''. Generation of '',a,i10,'' :'',i10)'
      texte(2,15) = '(''Examination of '',a,i10)'
      texte(2,20) = '(i10,1x,a,'' in generation'',i10)'
c
c 1.2. ==> initialisation
c
      codret = 0
c
      if ( option.gt.0 ) then
        numgen = option
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) option
      if ( option.eq.-1 ) then
        write (ulsort,texte(langue,6)) mess14(langue,3,-1)
      elseif ( option.gt.0 ) then
        write (ulsort,texte(langue,7)) mess14(langue,3,-1), numgen
        write (ulsort,texte(langue,9)) numfin
      endif
#endif
c
c 1.2. ==> Aucune renumerotation au depart
c
      do 12 , iaux = 0 , nbnoto
        nounoe(iaux) = iaux
   12 continue
c
c====
c 2. option numero -1 : elaboration des generations des noeuds
c====
c
      if ( option.eq.-1 ) then
c
      do 21 , iaux = 1 , nbnoto
c
        ngenno(iaux) = 0
c
   21 continue
c
      ifin = 2*nbanci
      do 22 , iaux = 1 , ifin
c
        if ( codret.eq.0 ) then
c
        laret1 = arrecb(iaux)
        laretg = arreca(iaux)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,15)) mess14(langue,1,1), laret1
        write (ulsort,texte(langue,11))
     >     mess14(langue,1,-1), somare(1,laret1),
     >     mess14(langue,1,-1), somare(2,laret1)
        write (ulsort,texte(langue,10)) mess14(langue,1,1), laretg
        write (ulsort,texte(langue,11))
     >     mess14(langue,1,-1), somare(1,laretg),
     >     mess14(langue,1,-1), somare(2,laretg)
#endif
c
        if ( somare(1,laret1).eq.somare(1,laretg) ) then
          lesomm = somare(2,laret1)
c
        elseif ( somare(1,laret1).eq.somare(2,laretg) ) then
          lesomm = somare(2,laret1)
c
        elseif ( somare(2,laret1).eq.somare(1,laretg) ) then
          lesomm = somare(1,laret1)
c
        elseif ( somare(2,laret1).eq.somare(2,laretg) ) then
          lesomm = somare(1,laret1)
c
        else
c
          write (ulsort,texte(langue,12)) mess14(langue,3,1)
          write (ulsort,texte(langue,15)) mess14(langue,1,1), laret1
          write (ulsort,texte(langue,11))
     >      mess14(langue,1,-1), somare(1,laret1),
     >      mess14(langue,1,-1), somare(2,laret1)
          write (ulsort,texte(langue,10)) mess14(langue,1,1), laretg
          write (ulsort,texte(langue,11))
     >      mess14(langue,1,-1), somare(1,laretg),
     >      mess14(langue,1,-1), somare(2,laretg)
          codret = 1
c
        endif
c
        endif
c
        if ( codret.eq.0 ) then
c
          if ( ngenno(lesomm).eq.0 ) then
c
            ngenno(lesomm) = ngenar(laret1)
c
          elseif ( ngenno(lesomm).ne.ngenar(laret1) ) then
c
            write (ulsort,texte(langue,13))
            write (ulsort,texte(langue,14)) mess14(langue,1,1),
     >        laret1, ngenar(laret1)
            write (ulsort,texte(langue,14)) mess14(langue,1,-1),
     >        lesomm, ngenno(lesomm)
            codret = 2
c
          endif
c
        endif
c
   22 continue
c
#ifdef _DEBUG_HOMARD_
c
c 2.3. ==> impression du nombre de noeuds par generation
c
        numgen = 0
c
  230 continue
c
        if ( codret.eq.0 ) then
c
        ifin = 0
        do 23 , iaux = 1 , nbnoto
c
          if ( ngenno(iaux).eq.numgen ) then
            ifin = ifin + 1
          endif
c
   23 continue
c
        if ( ifin.ne.0 ) then
          write (ulsort,texte(langue,20)) ifin,
     >                                    mess14(langue,3,-1), numgen
          numgen = numgen + 1
          goto 230
        endif
c
        endif
#endif
c
c
c====
c 3. option > 0 : on rassemble les noeuds de meme generation
c    on les deplace vers la fin, en prenant soin de ne pas ecraser
c    les generations plus jeunes (d'ou le demarrage a ifin)
c====
c
      elseif ( option.gt.0 ) then
c
        ifin = numfin
c
        do 31 , iaux = 1 , nbnoto
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,15)) mess14(langue,1,-1), iaux
#endif
cgn            write (ulsort,*) 'ngenno=',ngenno(iaux),'ifin = ',ifin
          if ( ngenno(iaux).eq.numgen .and. iaux.le.ifin ) then
c
            do 311 , jaux = ifin, 1, -1
              if ( jaux.eq.iaux ) then
                goto 312
              elseif ( ngenno(jaux).lt.numgen ) then
                nounoe(jaux) = iaux
                nounoe(iaux) = jaux
#ifdef _DEBUG_HOMARD_
                write (ulsort,texte(langue,15)) mess14(langue,1,-1),iaux
                write (ulsort,*) iaux,' devient', jaux
#endif
                goto 312
              endif
  311       continue
c
            codret = option
c
  312       continue
c
            ifin = jaux - 1
            goto 31
c
          endif
c
          endif
c
   31   continue
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,20)) numfin-ifin,
     >                                  mess14(langue,3,-1), numgen
#endif
c
        numfin = ifin
c
c====
c 4. option autre : impossible
c====
c
      elseif ( option.eq.3 ) then
c
        codret = -1
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
