      subroutine deisv1 ( ncmpin, usacmp, nbvoto, typenh,
     >                    vosupp, voindi,
     >                    hettri, filtri, pertri,
     >                    hetqua, filqua, perqua,
     >                    hetvol, facvol,
     >                    voltri, volqua,
     >                    tabent, voinin,
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
c    traitement des DEcisions - Initialisations - par Saut - Volumes - 1
c                   --          -                     -      -         -
c
c    On traite ici uniquement les sauts entre volumes pour les cas ou
c    il n'y a que des tetraedres ou que des hexaedres concernes par
c    un indicateur d'erreur.
c    Quand l'indicateur est reparti sur des entites de nature
c    differente, on gerera le saut dans deisv2.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ncmpin .  e  .   1    . nombre de composantes de l'indicateur      .
c . usacmp . e   .   1    . usage des composantes de l'indicateur      .
c .        .     .        . 0 : norme L2                               .
c .        .     .        . 1 : norme infinie -max des valeurs absolues.
c .        .     .        . 2 : valeur relative si une seule composante.
c . nbvoto . e   .   1    . nombre de volumes total                    .
c . typenh . e   .   1    . 3 : tetraedres                             .
c .        .     .        . 6 : hexaedres                              .
c . vosupp . e   . nbvoto . support pour les volumes                   .
c . voindi .  s  . nbvoto . valeurs reelles pour les volumes           .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . pertri . e   . nbtrto . pere des triangles                         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . fils des quadrangles                       .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . hetvol . e   . nbvoto . historique de l'etat des volumes           .
c . facvol . e   .nbvoto*n. numeros des n faces des volumes            .
c . voltri . es  .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . tabent . aux .   *    . tableau auxiliaire entier                  .
c . voinin . aux .   *    . sauvegarde des valeurs des indicateurs     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : mauvais typenh                         .
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
      parameter ( nompro = 'DEISV1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "infini.h"
#include "impr02.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer ncmpin
      integer usacmp
      integer nbvoto, typenh
c
      integer vosupp(nbvoto)
      integer hettri(nbtrto), filtri(nbtrto), pertri(nbtrto)
      integer hetqua(nbquto), filqua(nbquto), perqua(nbquto)
      integer voltri(2,nbtrto)
      integer volqua(2,nbquto)
      integer hetvol(nbvoto), facvol(nbvoto,*)
      integer tabent(2,*)
c
      integer ulsort, langue, codret
c
      double precision voindi(nbvoto,ncmpin)
      double precision voinin(nbvoto,ncmpin)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer lgpile, nupile
      integer levolu
      integer lafavo, laface, tyface, typfac
      integer etat
      integer merefa
      integer nbfavo
      integer nrcomp
cgn      integer glop
c
      double precision daux1, daux2
      integer lgdaux
      parameter( lgdaux = 100 )
      double precision daux(lgdaux), vect(lgdaux)
c
      logical calcul
c
      integer nbmess
      parameter (nbmess = 11 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Saut a la traversee des '',a)'
      texte(1,5) =
     > '(''On veut'',i6,'' composantes, mais taille de daux ='',i6)'
      texte(1,6) = ' (''Type d''''entite incorrect :'',i10)'
      texte(1,9) = '(''. Norme L2 des composantes.'')'
      texte(1,10) = '(''. Norme infinie des composantes.'')'
      texte(1,11) = '(''. Valeur relative de la composante.'')'
c
      texte(2,4) = '(''. Jump through the '',a)'
      texte(2,5) =
     > '(i6,''components are requested, but size of daux equals'',i6)'
      texte(2,6) = ' (''Uncorrect type of entity: :'',i10)'
      texte(2,9) = '(''. L2 norm of components.'')'
      texte(2,10) = '(''. Infinite norm of components.'')'
      texte(2,11) = '(''. Relative value for the component.'')'
c
#include "impr03.h"
c
      codret = 0
c
c 1.2. ==> controle
c
      if ( ncmpin.gt.lgdaux ) then
        write (ulsort,texte(langue,5)) ncmpin, lgdaux
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9+usacmp))
#endif
c
c 1.3. ==> Les types de faces : triangle (2) ou quadrangle (4)
c
      if ( codret.eq.0 ) then
c
      if ( typenh.eq.3 ) then
        nbfavo = 4
        typfac = 2
      elseif ( typenh.eq.6 ) then
        nbfavo = 6
        typfac = 4
      else
        codret = 1
        write (ulsort,texte(langue,6)) typenh
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typfac)
#endif
c
      endif
c
c====
c 2. On parcourt tous les volumes.
c    On calcule l'ecart entre la valeur de l'indicateur sur le volume
c    courant et sur les voisins.
c    On garde le max au sens de la norme voulue
c    levolu = numero local dans la categorie
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. parcours des volumes ; codret', codret
#endif
c
      do 2 , levolu = 1 , nbvoto
c
        if ( codret.eq.0 ) then
c
        if ( vosupp(levolu).ne.0 ) then
c
c 2.1. ==> Exploration de toutes les faces du volume
c
          daux1 = vinfne
c
          do 21 , iaux = 1 , nbfavo
c
c 2.1.1. ==> pour chaque face du volume, on stocke les numeros
c            des faces voisines, en descendant les parentes.
c            Au final, on stocke la premiere face mere active
c
            lafavo = facvol(levolu,iaux)
            tyface = typfac
cgn            if ( glop.eq.1) then
cgn              write(ulsort,90002) '. face de rang',iaux
cgn            endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'DEISV3', nompro
#endif
            call deisv3 ( lafavo, tyface,
     >                    hettri, filtri,
     >                    hetqua, filqua,
     >                    lgpile, tabent,
     >                    ulsort, langue, codret )
c
c 2.1.2. ==> pour chaque face de la pile : si elle est active, on
c            cherche le max de l'ecart entre la valeur de l'indicateur
c            sur le volume voisin et celle sur le volume courant
c            on sait que les faces sont toutes de meme type
c
            do 212 , nupile = 1 , lgpile
c
              laface = tabent(1,nupile)
c
c 2.1.2.1. ==> reperage selon la face
c
              if ( typfac.eq.2 ) then
                etat = mod(hettri(laface),10)
              else
                etat = mod(hetqua(laface),100)
              endif
c
c 2.1.2.2. ==> traitement
c
              if ( etat.eq.0 ) then
cgn        if ( glop.eq.1) then
cgn       write(ulsort,90002)'.. Voisinage par le '//
cgn     >            mess14(langue,1,typfac),laface
cgn        endif
                do 2122 , jaux = 1 , 2
c
                  calcul = .false.
c
                  if ( typfac.eq.2 ) then
                    kaux = voltri(jaux,laface)
                  else
                    kaux = volqua(jaux,laface)
                  endif
c
                  if ( kaux.gt.0 ) then
c
                    if ( vosupp(kaux).ne.0 ) then
c
                      if ( kaux.ne.levolu ) then
                        calcul = .true.
                        do 21221 , nrcomp = 1 , ncmpin
                          daux(nrcomp) = voinin(kaux,nrcomp)
     >                                 - voinin(levolu,nrcomp)
21221                   continue
cgn        if ( glop.eq.1) then
cgn        write(ulsort,90054)'...... ==> ecart avec  ', kaux,' : ',
cgn     >          (daux(nrcomp),nrcomp=1,ncmpin)
cgn        endif
c
                      endif
c
                    endif
c
                  elseif ( kaux.lt.0 ) then
cgn        if ( glop.eq.1) then
cgn       write(ulsort,*)'.... Autre type de volume voisin.'
cgn        endif
                    codret = codret + 1
                  endif
c
c                 calcul de la norme de l'ecart
c                 si on a passe le max, on stocke
c
                  if ( calcul ) then
c
                    if ( usacmp.eq.0 ) then
                      daux2 = daux(1)**2
                      do 21222 , nrcomp = 2 , ncmpin
                        daux2 = daux2 + daux(nrcomp)**2
21222                 continue
                    elseif ( usacmp.eq.1 ) then
                      daux2 = abs(daux(1))
                      do 21223 , nrcomp = 2 , ncmpin
                        daux2 = max(daux2,abs(daux(nrcomp)))
21223                 continue
                    else
                      daux2 = daux(1)
                    endif
                    if ( daux2.gt.daux1 ) then
                      daux1 = daux2
                      do 21224 , nrcomp = 1 , ncmpin
                        vect(nrcomp) = daux(nrcomp)
21224                 continue
                    endif
c
                  endif
c
 2122           continue
c
              endif
c
  212       continue
c
c 2.3. ==> on remonte la parente pour pieger les non-conformites
c
            laface = lafavo
c
  231       continue
c
cgn        if ( glop.eq.1) then
cgn          write(ulsort,90002)'.... Parente du '//
cgn     >            mess14(langue,1,typfac),laface
cgn        endif
            if ( typfac.eq.2 ) then
              merefa = pertri(laface)
            else
              merefa = perqua(laface)
            endif
c
            if ( merefa.gt.0 ) then
cgn        if ( glop.eq.1) then
cgn          write(ulsort,90006)'.... le '//
cgn     >       mess14(langue,1,typfac), laface,' a une mere : ',merefa
cgn        endif
c
              if ( typfac.eq.2 ) then
                kaux = voltri(2,merefa)
              else
                kaux = volqua(2,merefa)
              endif
c
              calcul = .false.
              if ( kaux.eq.0 ) then
                laface = merefa
                goto 231
              elseif ( kaux.gt.0 ) then
                do 232 , jaux = 1 , 2
                  if ( typfac.eq.2 ) then
                    kaux = voltri(jaux,merefa)
                  else
                    kaux = volqua(jaux,merefa)
                  endif
                  if ( kaux.gt.0 ) then
                    if ( mod(hetvol(kaux),100).eq.0 ) then
                      calcul = .true.
                      do 2311 , nrcomp = 1 , ncmpin
                        daux(nrcomp) = voinin(kaux,nrcomp)
     >                               - voinin(levolu,nrcomp)
 2311                 continue
cgn        if ( glop.eq.1) then
cgn        write(ulsort,90054)'...... ==> ecart avec ', kaux,' : ',
cgn     >          (daux(nrcomp),nrcomp=1,ncmpin)
cgn        endif
                    endif
                  elseif ( kaux.lt.0 ) then
                    codret = codret + 1
                  endif
  232           continue
              elseif ( kaux.lt.0 ) then
                codret = codret + 1
              endif
              if ( calcul ) then
                if ( usacmp.eq.0 ) then
                  daux2 = daux(1)**2
                  do 23111 , nrcomp = 2 , ncmpin
                    daux2 = daux2 + daux(nrcomp)**2
23111             continue
                elseif ( usacmp.eq.1 ) then
                  daux2 = abs(daux(1))
                  do 23112 , nrcomp = 2 , ncmpin
                    daux2 = max(daux2,abs(daux(nrcomp)))
23112             continue
                else
                  daux2 = daux(1)
                endif
                if ( daux2.gt.daux1 ) then
                  daux1 = daux2
                  do 2312 , nrcomp = 1 , ncmpin
                    vect(nrcomp) = daux(nrcomp)
 2312             continue
                endif
              endif
c
            endif
c
   21     continue
c
c 2.4. ==> stockage
c
cgn        if ( glop.eq.1 ) then
cgn       write(ulsort,90054) 'Final    '//
cgn     > mess14(langue,1,typenh), levolu, ' : ',
cgn     > (vect(nrcomp),nrcomp=1,ncmpin)
cgn        endif
c
          do 241 , nrcomp = 1 , ncmpin
            voindi(levolu,nrcomp) = vect(nrcomp)
  241     continue
c
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
      if ( codret.ne.1 ) then
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
