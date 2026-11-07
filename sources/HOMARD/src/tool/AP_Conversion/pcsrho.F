      subroutine pcsrho ( nbfop1, nbfop2, numnp1, numnp2,
     >                    deraff, option,
     >                    hetnoe, ancnoe,
     >                    nnoeho, nnoeca,
     >                    nbvapr, listpr, prfcan, profho,
     >                    vap1ec, vap2ec,
     >                    vap1ho, vap2ho,
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
c    aPres adaptation - Conversion de Solution - Renumerotation vers
c     -                 -             -          -
c                                                HOMARD
c ______________________________________________________________________
c                                                --
c    Remarque : on suppose qu'il y a une valeur de solution aussi
c               sur les eventuels noeuds isoles.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop1 . e   .    1   . nombre de fonctions P1                     .
c . nbfop2 . e   .    1   . nombre de fonctions P2                     .
c . numnp1 . e   .    1   . nombre de noeuds de la fonction si P1      .
c . numnp2 . e   .    1   . nombre de noeuds de la fonction si P2      .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
c . option . e   .    1   . option du traitement                       .
c .        .     .        . -1 : Pas de changement dans le maillage    .
c .        .     .        .  0 : Adaptation complete                   .
c .        .     .        .  1 : Modification de degre                 .
c . hetnoe . e   . nbnoto . historique de l'etat des noeuds            .
c . ancnoe . e   . nbnoto . ancien numero de noeud si deraffinement    .
c . nnoeho . e   . renoac . numero des noeuds en entre pour homard     .
c . nnoeca . e   . renoto . numero des noeuds du code de calcul        .
c . nbvapr . e   .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil                       .
c . listpr . e   .   *    . liste des numeros de noeuds ou la fonction .
c .        .     .        . est definie.                               .
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . profho . es  . nbnoto . pour chaque noeud en numerotation homard : .
c .        .     .        . 0 : le noeud est absent du profil          .
c .        .     .        . 1 : le noeud est present dans le profil    .
c . vap1ec . e   . nbfop1*. variables p1 en entree pour le calcul      .
c .        .     . numnp1 .                                            .
c . vap2ec . e   . nbfop2*. variables p2 en entree pour le calcul      .
c .        .     . numnp2 .                                            .
c . vap1ho .  s  . nbfop1*. variables p1 numerotation homard           .
c .        .     . nbnoto .                                            .
c . vap2ho .  s  . nbfop2*. variables p2 numerotation homard           .
c .        .     . nbnoto .                                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'PCSRHO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nomber.h"
#include "nombsr.h"
#include "nombno.h"
c
c 0.3. ==> arguments
c
      integer nbfop1, nbfop2
      integer numnp1, numnp2
      integer option
c
      integer nbvapr, listpr(*)
c
      integer hetnoe(nbnoto), ancnoe(nbnoto)
      integer prfcan(*), profho(rsnoto)
      integer nnoeho(renoac), nnoeca(renoto)
c
      double precision vap1ec(nbfop1,renoto), vap2ec(nbfop2,renoto)
      double precision vap1ho(nbfop1,*), vap2ho(nbfop2,*)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nuv, lenoeu
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 120 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Situation impossible ?'')'
c
      texte(2,4) = '(''Impossible situation ?'')'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'option', option
      write (ulsort,90002) 'numnp1', numnp1
      write (ulsort,90002) 'numnp2', numnp2
      write (ulsort,90002) 'nbnoto', nbnoto
      write (ulsort,90002) 'nbfop1', nbfop1
      write (ulsort,90002) 'nbfop2', nbfop2
      write (ulsort,90002) 'nbvapr', nbvapr
      write (ulsort,90002) 'reno1i', reno1i
      write (ulsort,90002) 'renoto', renoto
      write (ulsort,90002) 'etats',(hetnoe(iaux),iaux=1,4)
#endif
c
c====
c 2. Cas :
c    - d'adaptation complete
c    - maillage inchange ou uniquement du raffinement
c    Dans ce cas, chaque noeud en entree de HOMARD est encore un noeud
c    en sortie. Le numero d'un noeud dans HOMARD reste inchange.
c    Il suffit de translater les numeros :
c     Numero dans le calcul en entree  <--->  Numero HOMARD
c                lenoeu                <--->  nnoeho(lenoeu)
c====
c
      if ( .not.deraff .and. option.le.0 ) then
cgn        write (ulsort,90002) 'sans deraffinement'
c
c 2.1. ==> valeurs p1
c
        do 21, nuv = 1, nbfop1
c
c 2.1.1. ==> sans profil : on a des valeurs sur tous les noeuds
c
          if ( nbvapr.le.0 ) then
cgn        write (ulsort,90002) 'sans profil'
c
            do 211 , lenoeu = 1 , numnp1
cgn        write (ulsort,90002) 'lenoeu', lenoeu, nnoeho(lenoeu)
cgn        write(*,90004) 'vap1ec(nuv,lenoeu)', vap1ec(nuv,lenoeu)
              vap1ho(nuv,nnoeho(lenoeu)) = vap1ec(nuv,lenoeu)
              profho(lenoeu) = 1
  211       continue
c
          else
c
c 2.1.2. ==> avec profil : on a des valeurs sur les noeuds de listpr
c
cgn        write (ulsort,90002) 'profil, nbvapr', nbvapr
            do 212 , iaux = 1 , nbvapr
cgn          print 1789,nuv,' --- ',iaux,vap1ec(nuv,iaux),listpr(iaux),
cgn     <nnoeho(listpr(iaux))
              vap1ho(nuv,nnoeho(listpr(iaux))) = vap1ec(nuv,iaux)
              profho(nnoeho(listpr(iaux))) = 1
  212       continue
c
          endif
c
   21   continue
c
c 2.2. ==> valeurs p2
c
        do 22, nuv = 1, nbfop2
c
c 2.2.1. ==> sans profil : on a des valeurs sur tous les noeuds
c
          if ( nbvapr.le.0 ) then
cgn        write (ulsort,90002) 'sans profil'
c
            do 221 , lenoeu = 1 , numnp2
              vap2ho(nuv,nnoeho(lenoeu)) = vap2ec(nuv,lenoeu)
              profho(lenoeu) = 1
  221       continue
c
          else
c
c 2.2.2. ==> avec profil : on a des valeurs sur les noeuds de listpr
c
cgn        write (ulsort,90002) 'profil, nbvapr', nbvapr
            do 222 , iaux = 1 , nbvapr
cgn          print 1789,nuv,' --- ',iaux,vap2ec(nuv,iaux),listpr(iaux),
cgn     <nnoeho(listpr(iaux))
              vap2ho(nuv,nnoeho(listpr(iaux))) = vap2ec(nuv,iaux)
              profho(nnoeho(listpr(iaux))) = 1
  222       continue
c
          endif
c
   22   continue
c
c====
c 3. Cas :
c    - d'adaptation complete
c    - avec du deraffinement
c    Dans ce cas, il ne faut reporter les valeurs que pour les noeuds
c    qui existent encore. La translation est alors :
c
c         Numero dans le   <--->   Numero HOMARD <---> Numero HOMARD
c        calcul en entree           en entree            en sortie
c   nnoeca(ancnoe(lenoeu)) <--->  ancnoe(lenoeu) <--->    lenoeu
c
c====
c
      elseif ( option.le.0 ) then
cgn        write (ulsort,90002) 'avec deraffinement'
c
c 3.1. ==> valeurs p1
c          - un noeud isole a pour etat 0, invariable.
c          - un noeud d'une maille ignoree a pour etat 7, invariable.
c          - un noeud support de maille-point a pour etat 3 ou 33.
c          - un noeud P1 a pour etat 1.
c            s'il existait avant, son etat valait :
c                   . 1, il n'a pas change ;
c                   . 2, il etait P2 et a change suite a deraffinement,
c                        mais une fonction P1 n'avait pas de valeur ici.
c Sont donc concernes les noeuds d'historique 0, 3, 7, 11 ou 33
c
c 3.1.1. ==> sans profil : on a des valeurs sur tous les noeuds
c
        if ( nbvapr.le.0 ) then
cgn        write (ulsort,90002) 'sans profil'
c
          do 311, nuv = 1, nbfop1
            do 3111, lenoeu = 1, nbnoto
cgn        write (ulsort,90002) 'lenoeu', lenoeu, hetnoe(lenoeu)
              if ( hetnoe(lenoeu).eq.0  .or.
     >             hetnoe(lenoeu).eq.3  .or.
     >             hetnoe(lenoeu).eq.11 .or.
     >             hetnoe(lenoeu).eq.33 .or.
     >             hetnoe(lenoeu).eq.7  .or.
     >             hetnoe(lenoeu).eq.77 ) then
cgn      write(*,90004) 'vap1ec(nuv,nnoeca(ancnoe(lenoeu)))',
cgn     >                vap1ec(nuv,nnoeca(ancnoe(lenoeu)))
                vap1ho(nuv,lenoeu) = vap1ec(nuv,nnoeca(ancnoe(lenoeu)))
                profho(lenoeu) = 1
              endif
 3111       continue
  311     continue
c
        else
c
c 3.1.2. ==> avec profil : on a des valeurs sur les noeuds de listpr
c
cgn        write (ulsort,90002) 'profil, nbvapr', nbvapr
          do 312, nuv = 1, nbfop1
            do 3121, lenoeu = 1, nbnoto
              if ( hetnoe(lenoeu).eq.0  .or.
     >             hetnoe(lenoeu).eq.3  .or.
     >             hetnoe(lenoeu).eq.11 .or.
     >             hetnoe(lenoeu).eq.33 .or.
     >             hetnoe(lenoeu).eq.7  .or.
     >             hetnoe(lenoeu).eq.77 ) then
                iaux = prfcan(nnoeca(ancnoe(lenoeu)))
                if ( iaux.gt.0 ) then
                  vap1ho(nuv,lenoeu) = vap1ec(nuv,iaux)
                  profho(lenoeu) = 1
                endif
              endif
 3121       continue
  312     continue
c
        endif
c
c 3.2. ==> valeurs p2
c          - un noeud isole a pour etat 0, invariable.
c          - un noeud d'une maille ignoree a pour etat 7, invariable.
c          - un noeud support de maille-point a pour etat 3 ou 33.
c          - un noeud P1 ou P2 a pour etat 1. ou 2
c            s'il existait avant, son etat valait :
c                   . 1, il etait P1 ;
c                   . 2, il etait P2.
c Sont donc concernes les noeuds d'historique 0, 3, 11, 12, 21, 2 ou 33.
c
c 3.2.1. ==> sans profil : on a des valeurs sur tous les noeuds
c
        if ( nbvapr.le.0 ) then
cgn        write (ulsort,90002) 'sans profil'
c
          do 321, nuv = 1, nbfop2
            do 3211, lenoeu = 1, nbnoto
              if ( hetnoe(lenoeu).eq.0  .or.
     >             hetnoe(lenoeu).eq.3  .or.
     >             hetnoe(lenoeu).eq.11 .or.
     >             hetnoe(lenoeu).eq.12 .or.
     >             hetnoe(lenoeu).eq.21 .or.
     >             hetnoe(lenoeu).eq.22 .or.
     >             hetnoe(lenoeu).eq.33 .or.
     >             hetnoe(lenoeu).eq.7  .or.
     >             hetnoe(lenoeu).eq.77 ) then
                vap2ho(nuv,lenoeu) = vap2ec(nuv,nnoeca(ancnoe(lenoeu)))
                profho(lenoeu) = 1
              endif
 3211       continue
  321     continue
c
        else
c
c 3.2.2. ==> avec profil : on a des valeurs sur les noeuds de listpr
c
cgn        write (ulsort,90002) 'profil, nbvapr', nbvapr
          do 322, nuv = 1, nbfop2
            do 3221, lenoeu = 1, nbnoto
              if ( hetnoe(lenoeu).eq.0  .or.
     >             hetnoe(lenoeu).eq.3  .or.
     >             hetnoe(lenoeu).eq.11 .or.
     >             hetnoe(lenoeu).eq.12 .or.
     >             hetnoe(lenoeu).eq.21 .or.
     >             hetnoe(lenoeu).eq.22 .or.
     >             hetnoe(lenoeu).eq.33 .or.
     >             hetnoe(lenoeu).eq.7  .or.
     >             hetnoe(lenoeu).eq.77 ) then
                iaux = prfcan(nnoeca(ancnoe(lenoeu)))
                if ( iaux.gt.0 ) then
                  vap2ho(nuv,lenoeu) = vap2ec(nuv,iaux)
                  profho(lenoeu) = 1
                endif
              endif
 3221       continue
  322     continue
c
        endif
c
c====
c 4. Cas :
c    - modification de degre
c      En fait c'est seulement du passage de P2 a P1
c    Dans ce cas, il ne faut reporter les valeurs que pour les noeuds
c    qui existent encore. La translation est alors :
c
c         Numero dans le   <--->   Numero HOMARD <---> Numero HOMARD
c        calcul en entree           en entree            en sortie
c   nnoeca(ancnoe(lenoeu)) <--->  ancnoe(lenoeu) <--->    lenoeu
c
c====
c
      elseif ( option.eq.1 ) then
cgn        write (ulsort,90002) 'modification de degre'
c
c 4.1. ==> passage de degre 2 a degre 1
c
        if ( nbfop1.ne.0 ) then
c
c          - un noeud isole a pour etat 0, invariable.
c          - un noeud support de maille-point a pour etat 3.
c          - un noeud d'une maille ignoree a pour etat 7, invariable.
c          - un noeud P1 a pour etat 1.
c Sont donc concernes les noeuds d'historique 0, 1, 3
c
c 4.1.1. ==> sans profil : on a des valeurs sur tous les noeuds
c
          if ( nbvapr.le.0 ) then
cgn          write (ulsort,90002) 'sans profil'
c
            do 411, nuv = 1, nbfop1
              do 4111, lenoeu = 1, nbnoto
cgn          write (ulsort,90002) 'lenoeu', lenoeu, hetnoe(lenoeu),
cgn     >                  ancnoe(lenoeu), nnoeca(ancnoe(lenoeu))
                if ( hetnoe(lenoeu).eq.0 .or.
     >               hetnoe(lenoeu).eq.1 .or.
     >               hetnoe(lenoeu).eq.3 .or.
     >               hetnoe(lenoeu).eq.7 ) then
cgn        write (ulsort,90002) 'lenoeu', lenoeu, ancnoe(lenoeu)
cgn      write(*,90004) 'vap1ec(nuv,nnoeca(ancnoe(lenoeu)))',
cgn     >                vap1ec(nuv,nnoeca(ancnoe(lenoeu)))
                  vap1ho(nuv,lenoeu)=vap1ec(nuv,nnoeca(ancnoe(lenoeu)))
                  profho(lenoeu) = 1
                endif
 4111         continue
  411       continue
c
          else
c
c 4.1.2. ==> avec profil : on a des valeurs sur les noeuds de listpr
c
cgn        write (ulsort,90002) 'profil, nbvapr', nbvapr
            do 412, nuv = 1, nbfop1
              do 4121, lenoeu = 1, nbnoto
                if ( hetnoe(lenoeu).eq.0 .or.
     >               hetnoe(lenoeu).eq.1 .or.
     >               hetnoe(lenoeu).eq.3 .or.
     >               hetnoe(lenoeu).eq.7 ) then
                  iaux = prfcan(nnoeca(ancnoe(lenoeu)))
                  if ( iaux.gt.0 ) then
                    vap1ho(nuv,lenoeu) = vap1ec(nuv,iaux)
                    profho(lenoeu) = 1
                  endif
                endif
 4121         continue
  412       continue
c
          endif
c
c 4.2. ==> passage de degre 1 a degre 2
c
        elseif ( nbfop2.ne.0 ) then
c
c          - un noeud isole a pour etat 0, invariable.
c          - un noeud support de maille-point a pour etat 3.
c          - un noeud d'une maille ignoree a pour etat 7, invariable.
c          - un noeud P1 a pour etat 1.
c          - un noeud P2 a pour etat 2.
c Sont donc concernes les noeuds d'historique 0, 1, 3
c
c 4.2.1. ==> sans profil : on a des valeurs sur tous les noeuds
c
          if ( nbvapr.le.0 ) then
cgn          write (ulsort,90002) 'sans profil'
c
            do 421, nuv = 1, nbfop2
              do 4211, lenoeu = 1, nbnoto
cgn          write (ulsort,90002) 'lenoeu', lenoeu, hetnoe(lenoeu)
                if ( hetnoe(lenoeu).eq.0 .or.
     >               hetnoe(lenoeu).eq.1 .or.
     >               hetnoe(lenoeu).eq.3 .or.
     >               hetnoe(lenoeu).eq.7 ) then
cgn        write (ulsort,90002) 'lenoeu', lenoeu, nnoeca(lenoeu)
cgn      write(*,90004) 'vap2ec(nuv,nnoeca(lenoeu))',
cgn     >                vap2ec(nuv,nnoeca(lenoeu))
                  vap2ho(nuv,lenoeu)=vap2ec(nuv,nnoeca(lenoeu))
                  profho(lenoeu) = 1
                endif
 4211         continue
  421       continue
c
          else
c
c 4.2.2. ==> avec profil : on a des valeurs sur les noeuds de listpr
c
cgn        write (ulsort,90002) 'profil, nbvapr', nbvapr
            do 422, nuv = 1, nbfop2
              do 4221, lenoeu = 1, nbnoto
                if ( hetnoe(lenoeu).eq.0 .or.
     >               hetnoe(lenoeu).eq.1 .or.
     >               hetnoe(lenoeu).eq.3 ) then
                  iaux = prfcan(nnoeca(ancnoe(lenoeu)))
                  if ( iaux.gt.0 ) then
                    vap2ho(nuv,lenoeu) = vap2ec(nuv,iaux)
                    profho(lenoeu) = 1
                  endif
                endif
 4221         continue
  422       continue
c
          endif
c
c 4.3. ==> erreur
c
        else
c
          codret = 43
c
        endif
c
c====
c 5. Cas inconnu
c====
c
      else
c
        codret = 5
c
      endif
c
c====
c 6. la fin
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
