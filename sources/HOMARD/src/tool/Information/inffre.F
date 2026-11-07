      subroutine inffre ( option, fotrva, foquva, titre0,
     >                    nocham, nrocmp, nrotab,
     >                    nbtrvi, nbquvi,
     >                    nntrvi, nnquvi,
     >                    nnoeca, ntreca, nqueca,
     >                    nnoeho, ntreho, nqueho,
     >                    lgnoin, lgtrin, lgquin,
     >                    nnoein, ntrein, nquein,
     >                    decanu,
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
c   INformation : Fichier - Fonction - REcuperation
c   --            -         -          --
c ______________________________________________________________________
c
c prise en compte de la fonction
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . 1 : la sortie est exprimee sur des elements.
c .        .     .        .     Si le champ est aux noeuds, on prend   .
c .        .     .        .     la moyenne des valeurs sur tous ses    .
c .        .     .        .     noeuds                                 .
c .        .     .        .     Si le champ est aux noeuds par element .
c .        .     .        .     ou aux points de Gauss, on prend la    .
c .        .     .        .     moyenne des valeurs sur l'element      .
c .        .     .        . 2 : la sortie est exprimee sur des noeuds  .
c .        .     .        .     Si le champ est aux elements, on prend .
c .        .     .        .     la moyenne des valeurs sur tous les    .
c .        .     .        .     elements voisins du noeud              .
c . fotrva .  s  . nbtrvi . fonctions triangles : valeur               .
c .        .     .        . ou fonctions par noeud                     .
c . foquva .  s  . nbquvi . fonctions quadrangles : valeur             .
c . titre0 .  s  . char * . titre auxiliaire                           .
c . nocham . e   . char8  . nom de l'objet champ                       .
c . nrocmp . e   .   1    . 0 : le module (non operationnel)           .
c .        .     .        . numero de la composante retenue            .
c . nrotab . e   .   1    . numero du tableau associe au pas de temps  .
c . nbtrvi . e   .   1    . nombre triangles visualisables             .
c . nbquvi . e   .   1    . nombre de quadrangles visualisables        .
c . nntrvi . e   .10nbtrvi. 1 : niveau du triangle a afficher          .
c .        .     .        . 2 : numero HOMARD du triangle              .
c .        .     .        . 3, 4, 5 : numeros des noeuds p1            .
c .        .     .        . 6 : famille du triangle                    .
c .        .     .        . 7, 8, 9 : numeros des noeuds p2            .
c .        .     .        . 10 : numero du noeud interne               .
c . nnquvi . e   .12nbquvi. 1 : niveau du quadrangle a afficher        .
c .        .     .        . 2 : numero HOMARD du quadrangle            .
c .        .     .        . 3, 4, 5, 6 : numeros des noeuds p1         .
c .        .     .        . 7 : famille du quadrangle                  .
c .        .     .        . 8, 9, 10, 11 : numeros des noeuds p2       .
c .        .     .        . 12 : numero du noeud interne               .
c . nnoeca . e   . renoto . noeuds en entree dans le calcul            .
c . ntreca . e   . retrto . nro des triangles dans le calcul en entree .
c . nqueca . e   . requto . nro des quads dans le calcul en entree     .
c . nnoeho . e   . renoto . nro des noeuds dans HOMARD en entree       .
c . ntreho . e   . retrto . nro des triangles dans HOMARD en entree    .
c . nqueho . e   . requto . nro des quads dans HOMARD en entree        .
c . decanu . e   .  -1:7  . decalage des numerotations selon le type   .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'INFFRE' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
#include "fractb.h"
#include "fractc.h"
#include "fracte.h"
#include "fractf.h"
#include "esutil.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "nomber.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nrocmp, nrotab
      integer nbtrvi, nbquvi
      integer nntrvi(10,nbtrvi)
      integer nnquvi(12,nbquvi)
      integer nnoeca(renoto), ntreca(retrto), nqueca(requto)
      integer nnoeho(*), ntreho(*), nqueho(*)
      integer lgnoin, lgtrin, lgquin
      integer nnoein(*), ntrein(*), nquein(*)
      integer decanu(-1:7)
c
      double precision fotrva(*), foquva(*)
c
      character*8 nocham
      character*(*) titre0
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbcomp, nbtvch, typcha
      integer adnocp, adcaen, adcare, adcaca
      integer nrtvch
      integer typgeo, ngauss, nbenmx, nbvapr, nbtyas
      integer carsup, nbtafo, typint
      integer advale, advalr, adobch, adprpg, adtyas
      integer nbenti, adpcan, adlipr
      integer numdt
c
      integer iaux1, iaux2, iaux3
      integer iaux, jaux, kaux
      integer adtra1
c
      logical prem
c
      double precision daux1, daux2
c
      character*8 ntrav1
      character*8 obpcan
      character*8 saux08
      character*64 noprof
      character*64 nomcha
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c_______________________________________________________________________
c
c====
c 1. initialisation
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Objet champ a examiner : '',a)'
      texte(1,5) = '(''Nom du champ : '',a)'
      texte(1,6) = '(a,'' :'',i5)'
      texte(1,7) = '(''Impossible de projeter sur les noeuds'')'
c
      texte(2,4) = '(''Field object : '',a)'
      texte(2,5) = '(''Field name : '',a)'
      texte(2,6) = '(a,'' :'',i5)'
      texte(2,7) = '(''Node projection cannot be done'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nocham
      call gmprsx (nompro,nocham)
      call gmprsx (nompro,nocham//'.Nom_Comp')
      call gmprsx (nompro,nocham//'.Cham_Car')
#endif
c
c====
c 2. Decodage du champ retenu
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCACH', nompro
#endif
      call utcach ( nocham,
     >              nomcha,
     >              nbcomp, nbtvch, typcha,
     >              adnocp, adcaen, adcare, adcaca,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) nomcha
      write (ulsort,texte(langue,6)) 'nbcomp', nbcomp
      write (ulsort,texte(langue,6)) 'nbtvch', nbtvch
#endif
c
c====
c 3. parcours des differents tableaux stockant les valeurs de ce champ
c====
c
      prem = .true.
c
      if ( codret.eq.0 ) then
c
      do 30 , nrtvch = 1 , nbtvch
c
c 3.1. ==> reperage du bon pas de temps
c          . on retient le premier tableau correspondant a celui cherche
c          . ensuite on retient tous ceux qui correspondent au meme
c            numero de pas de temps. cela correspond au cas ou le champ
c            est present sur plusieurs supports differents (tria+quad
c            par exemple)
c
        if ( codret.eq.0 ) then
c
c 3.1.1. ==> pour le premier tableau du bon pas de temps
c
        if ( nrtvch.eq.nrotab) then
c
          numdt  = imem(adcaen+nbinec*(nrtvch-1)+1)
          prem = .false.
          jaux = len(titre0)
          if ( numdt.ne.ednodt ) then
c                          123456
            titre0(1:6) = '( t = '
            daux1 = rmem(adcare+nrtvch-1)
            call utrech ( daux1, 'G', iaux, titre0(7:jaux),
     >                    ulsort, langue, codret )
            if ( codret.eq.0 ) then
              titre0(iaux+1:iaux+2) = ' )'
            endif
          endif
          if ( codret.ne.0 .or. numdt.eq.ednodt ) then
            codret = 0
            do 31 , iaux = 1 , jaux
              titre0(iaux:iaux) = ' '
   31       continue
          endif
c
        else
c
c 3.1.2. ==> pour un autre tableau
c
          if ( prem ) then
            goto 30
          else
            if ( imem(adcaen+nbinec*(nrtvch-1)+1).ne.numdt ) then
              goto 30
            endif
          endif
c
        endif
        iaux1 = imem(adcaen+nbinec*(nrtvch-1)+8)
c
c
        endif
c
c 3.2. ==> reperage de la fonction
c
        saux08 = smem(adcaca+nbincc*(nrtvch-1))
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, saux08 )
cgn        call gmprsx (nompro, saux08//'.ValeursR' )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
        call utcafo ( saux08,
     >                typcha,
     >                typgeo, ngauss, nbenmx, nbvapr, nbtyas,
     >                carsup, nbtafo, typint,
     >                advale, advalr, adobch, adprpg, adtyas,
     >                ulsort, langue, codret )
c
        endif
c
        kaux = nbtafo*ngauss
c
cgn 1789   format(i4,12f15.7)
cgn      print *, 'ngauss = ',ngauss
cgn      print *, 'nbenmx = ',nbenmx
cgn      print *, 'nrocmp = ',nrocmp
cgn      print *, 'nbtafo = ',nbtafo
cgn      print *, 'nbvapr = ',nbvapr
cgn        if ( typgeo.eq.0 ) then
cgn        do 310,jaux=1,nbenmx
cgn         print 1789, jaux,
cgn     >    (rmem(advalr+kaux*(jaux-1)+iaux-1),
cgn     >     iaux=iaux1,iaux1+nbcomp-1)
cgn 310   continue
cgn        do 311,jaux=1,nbenmx*kaux
cgn         print 1789, jaux,
cgn     >    rmem(advalr+1*(jaux-1))
cgn 311   continue
cgn       endif
c
c 3.3. ==> changements de numerotation
c
c 3.3.1. ==> profil eventuel
c
        if ( nbvapr.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPR', nompro
#endif
          call utcapr ( smem(adprpg),
     >                  iaux, noprof, adlipr,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
c 3.3.2. ==> allocation du tableau de renumerotation
c
        if ( codret.eq.0 ) then
c
        if ( typgeo.eq.0 ) then
          nbenti = renoac
        elseif ( typgeo.eq.edtri3 .or. typgeo.eq.edtri6 ) then
          nbenti = retrac
        elseif ( typgeo.eq.edqua4 .or. typgeo.eq.edqua8 ) then
          nbenti = requac
        else
          nbenti = 0
        endif
c
        call gmalot ( obpcan, 'entier  ', nbenti, adpcan, codret )
c
        endif
c
c 3.3.3. ==> renumerotation
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) 'typgeo', typgeo
      write (ulsort,texte(langue,6)) 'nbenti', nbenti
      write (ulsort,texte(langue,6)) 'nbvapr', nbvapr
#endif
c
        if ( codret.eq.0 ) then
c
        call gmalot ( ntrav1, 'entier  ', nbenti, adtra1, codret )
c
        endif
c
        if ( typgeo.eq.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTTBRC-no', nompro
#endif
          call uttbrc ( iaux,
     >                  lgnoin, nnoein, nbenti, imem(adtra1),
     >                  ulsort, langue, codret)
c
          endif
c
          if ( codret.eq.0 ) then
c
          iaux = 1
          jaux = decanu(-1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR02-no', nompro
#endif
          call utpr02 ( iaux,
     >                  nbenti, nbvapr, imem(adlipr),
     >                  nnoeho, nnoeca, jaux,
     >                  lgnoin, nnoein, imem(adtra1),
     >                  imem(adpcan),
     >                  ulsort, langue, codret )
c
          endif
c
        elseif ( typgeo.eq.edtri3 .or. typgeo.eq.edtri6 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTTBRC-tr', nompro
#endif
          call uttbrc ( iaux,
     >                  lgtrin, ntrein, nbenti, imem(adtra1),
     >                  ulsort, langue, codret)
c
          endif
c
          if ( codret.eq.0 ) then
c
          iaux = 1
          jaux = decanu(2)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR02-tr', nompro
#endif
          call utpr02 ( iaux,
     >                  nbenti, nbvapr, imem(adlipr),
     >                  ntreho, ntreca, jaux,
     >                  lgtrin, ntrein, imem(adtra1),
     >                  imem(adpcan),
     >                  ulsort, langue, codret )
c
          endif
c
        elseif ( typgeo.eq.edqua4 .or. typgeo.eq.edqua8 ) then
c
          if ( codret.eq.0 ) then
cgn      write (ulsort,*) 'nquein'
cgn      write (ulsort,91020) (nquein(iaux), iaux = 1 , lgquin)
c
          iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTTBRC-qu', nompro
#endif
          call uttbrc ( iaux,
     >                  lgquin, nquein, nbenti, imem(adtra1),
     >                  ulsort, langue, codret)
c
          endif
c
          if ( codret.eq.0 ) then
c
          iaux = 1
          jaux = decanu(4)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPR02-qu', nompro
#endif
          call utpr02 ( iaux,
     >                  nbenti, nbvapr, imem(adlipr),
     >                  nqueho, nqueca, jaux,
     >                  lgquin, nquein, imem(adtra1),
     >                  imem(adpcan),
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmlboj ( ntrav1 , codret )
c
        endif
c
c 3.4. ==> transfert en fonction du support
c
        if ( codret.eq.0 ) then
c
        jaux = advalr - 2 + iaux1 + nrocmp - kaux
c
c 3.4.1. ==> sur les noeuds
c
cgn 1792 format(3i10,g15.7)
        if ( typgeo.eq.0 ) then
c
          if ( option.eq.1 .and. degre.eq.1 ) then
c
            do 3411 , iaux = 1 , nbtrvi
cgn          print *,'                      ',iaux
cgn          print 1792,nntrvi(3,iaux),nnoeca(nntrvi(3,iaux)),
cgn     >        imem( adpcan + nnoeca(nntrvi(3,iaux))-1),
cgn     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(3,iaux))-1))
cgn          print *,kaux*imem(adpcan+nnoeca(nntrvi(3,iaux))-1)
cgn          print 1792,nntrvi(4,iaux),nnoeca(nntrvi(4,iaux)),
cgn     >        imem( adpcan + nnoeca(nntrvi(4,iaux))-1),
cgn     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(4,iaux))-1))
cgn          print 1792,nntrvi(5,iaux),nnoeca(nntrvi(5,iaux)),
cgn     >        imem( adpcan + nnoeca(nntrvi(5,iaux))-1),
cgn     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(5,iaux))-1))
              fotrva(iaux) = unstr * (
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(3,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(4,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(5,iaux))-1)) )
cgn          print 1789,iaux,fotrva(iaux)
 3411       continue
c
            do 3412 , iaux = 1 , nbquvi
cgn          if ( ( nnquvi(2,iaux).ge.27713 .and.
cgn     >           nnquvi(2,iaux).le.27716 ) .or.
cgn     >         ( nnquvi(2,iaux).ge.27725 .and.
cgn     >           nnquvi(2,iaux).le.27728 ) .or.
cgn     >           nnquvi(2,iaux).eq.17127 .or.
cgn     >           nnquvi(2,iaux).eq.17198) ) then
cgn          print *,'                   ',iaux,' (',nnquvi(2,iaux),')'
cgn          print 1792,nnquvi(3,iaux),nnoeca(nnquvi(3,iaux)),
cgn     >        imem(adpcan+nnoeca(nnquvi(3,iaux))-1),
cgn     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(3,iaux))-1))
cgn          print 1792,nnquvi(4,iaux),nnoeca(nnquvi(4,iaux)),
cgn        >       imem(adpcan+nnoeca(nnquvi(4,iaux))-1),
cgn        >       rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(4,iaux))-1))
cgn             print 1792,nnquvi(5,iaux),nnoeca(nnquvi(5,iaux)),
cgn        >       imem(adpcan+nnoeca(nnquvi(5,iaux))-1),
cgn        >       rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(5,iaux))-1))
cgn              print 1792,nnquvi(6,iaux),nnoeca(nnquvi(6,iaux)),
cgn        >       imem(adpcan+nnoeca(nnquvi(6,iaux))-1),
cgn        >       rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(6,iaux))-1))
cgn             endif
             foquva(iaux) = unsqu * (
     >       rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(3,iaux))-1)) +
     >       rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(4,iaux))-1)) +
     >       rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(5,iaux))-1)) +
     >       rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(6,iaux))-1)) )
cgn          if ( ( nnquvi(2,iaux).ge.27713 .and.
cgn     >           nnquvi(2,iaux).le.27716 ) .or.
cgn     >         ( nnquvi(2,iaux).ge.27725 .and.
cgn     >           nnquvi(2,iaux).le.27728 ) .or.
cgn     >           nnquvi(2,iaux).eq.17127 .or.
cgn     >           nnquvi(2,iaux).eq.17198) ) then
cgn            print 1789,iaux,foquva(iaux)
cgn           endif
3412       continue
c
          elseif ( option.eq.1 .and. degre.eq.2 ) then
c
            do 3413 , iaux = 1 , nbtrvi
              fotrva(iaux) = unssix * (
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(4,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(4,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(5,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(7,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(8,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nntrvi(9,iaux))-1)) )
 3413       continue
c
            do 3414 , iaux = 1 , nbquvi
              foquva(iaux) = unshu * (
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(3,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(4,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(5,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(6,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(8,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(9,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(10,iaux))-1)) +
     >        rmem(jaux+kaux*imem(adpcan+nnoeca(nnquvi(11,iaux))-1)) )
 3414       continue
c
          else
c
            do 3415 , iaux = 1 , nbenti
              fotrva(iaux) = rmem(jaux+kaux*imem(adpcan+nnoeca(iaux)-1))
 3415       continue
c
          endif
c
c 3.4.2. ==> fonction exprimee sur les triangles
c
        elseif ( typgeo.eq.edtri3 .or. typgeo.eq.edtri6 ) then
c
          if ( option.eq.1 ) then
c
c 3.4.2.1. ==> une valeur constante par element
c
            if ( ngauss.eq.1 ) then
c
              do 3421 , iaux = 1 , nbtrvi
cgn          print *,iaux,nntrvi(2,iaux),ntreca(nntrvi(2,iaux)),
cgn     > imem(adpcan+ntreca(nntrvi(2,iaux))-1)
                fotrva(iaux) = rmem( jaux +
     >                      kaux*imem(adpcan+ntreca(nntrvi(2,iaux))-1) )
cgn          print 1789,iaux,fotrva(iaux)
 3421         continue
c
            else
c
c 3.4.2.2. ==> plusieurs valeurs par element (points de Gauss)
c
              daux1 = 1.d0/dble(ngauss)
c
              iaux2 = jaux - nbtafo
              do 3422 , iaux = 1 , nbtrvi
                daux2 = 0.d0
                iaux3 = iaux2
     >                + kaux*imem(adpcan+ntreca(nntrvi(2,iaux))-1)
                do 34221 , iaux1 = 1 , ngauss
                  daux2 = daux2 + rmem(iaux3+iaux1*nbtafo )
34221           continue
                fotrva(iaux) = daux1*daux2
 3422         continue
c
            endif
c
          else
c
            write (ulsort,texte(langue,7))
c
          endif
c
c 3.4.3. ==> fonction exprimee sur les quadrangles
c
        elseif ( typgeo.eq.edqua4 .or. typgeo.eq.edqua8 ) then
c
          if ( option.eq.1 ) then
c
c 3.4.3.1. ==> une valeur constante par element
c
            if ( ngauss.eq.1 ) then
c
              do 3431 , iaux = 1 , nbquvi
cgn            write (ulsort,90015) 'foquva(', iaux,')',nnquvi(2,iaux),nqueca(nnquvi(2,iaux)),
cgn     > imem(adpcan+nqueca(nnquvi(2,iaux))-1)
                foquva(iaux) = rmem( jaux +
     >                      kaux*imem(adpcan+nqueca(nnquvi(2,iaux))-1) )
cgn          print 1789,iaux,foquva(iaux)
 3431         continue
c
            else
c
c 3.4.3.2. ==> plusieurs valeurs par element (points de Gauss)
c
              daux1 = 1.d0/dble(ngauss)
c
              iaux2 = jaux - nbtafo
              do 3432 , iaux = 1 , nbquvi
                daux2 = 0.d0
                iaux3 = iaux2
     >                + kaux*imem(adpcan+nqueca(nnquvi(2,iaux))-1)
                do 34321 , iaux1 = 1 , ngauss
                  daux2 = daux2 + rmem(iaux3+iaux1*nbtafo )
34321           continue
                foquva(iaux) = daux1*daux2
 3432         continue
c
            endif
c
          else
c
            write (ulsort,texte(langue,7))
c
          endif
c
        endif
c
        endif
c
c 3.5. ==> menage
c
        if ( codret.eq.0 ) then
c
        call gmlboj ( obpcan, codret )
c
        endif
c
   30 continue
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
