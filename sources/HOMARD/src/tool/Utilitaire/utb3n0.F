      subroutine utb3n0 ( coonoe,
     >                    numcoi, coinpt, coinnn,
     >                    nbbomx, lglibo, ptnubo, listbo,
     >                    nbpbco, mess54,
     >                    ulbila, ulsort, langue, codret )
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
c    UTilitaire - Bilan - option 3 - phase N0
c    --           -              -         --
c ______________________________________________________________________
c
c but : controle la non coincidence des noeuds.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . numcoi .  s  . nbnoto . numero de la coincidence du noeud          .
c . coinpt .  s  .   *    . pointeur de la i-eme coincidence dans coinn.
c . coinnn .  s  .   *    . liste des noeuds coincidents               .
c . nbbomx . e   .    1   . nombre total de boites                     .
c . lglibo . e   .   1    . longueur de listbo                         .
c . ptnubo . e   .0:nbbomx. pointeur dans listbo                       .
c . listbo . e   . lglibo . numero des noeuds dans chaque boite        .
c . nbpbco . es  .  -1:7  . nombre de problemes de coincidences        .
c . mess54 . e   .nblang,*. messages                                   .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB3N0' )
c
      integer typenh
      parameter ( typenh = -1 )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "envca1.h"
#include "precis.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer numcoi(nbnoto), coinpt(*), coinnn(*)
      integer nbpbco(-1:7)
      integer nbbomx, lglibo
      integer ptnubo(0:nbbomx), listbo(lglibo)
c
      character*54 mess54(nblang,*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer lenoeu
      integer nucoin, nucoix, ptcoin, ptcode, ptcofi
      integer numboi, ptldeb, ptlfin
c
      integer nbmess
      parameter (nbmess = 10 )
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(/,3x,''... Coincidence des noeuds'',/,3x,26(''-''),/)'
      texte(1,5) =
     > '(5x,''Deux noeuds sont dits coincidents si l''''ecart absolu'')'
      texte(1,6) =
     > '(5x,''entre leurs coordonnees est inferieur a :'',g9.2)'
c
      texte(2,4) = '(/,3x,''... Coincident nodes'',/,3x,20(''-''),/)'
      texte(2,5) = '(5x,''Nodes are declared coincident if their'')'
      texte(2,6) =
     > '(5x,''absolute coordinate difference is lower than '',g9.2)'
c
#include "utb301.h"
c
c 1.2. ==> constantes
c
      codret = 0
c
      do 12 , lenoeu = 1 , nbnoto
        numcoi(lenoeu) = 0
   12 continue
      coinpt(1) = 0
      nucoin = 0
      ptcoin = 0
c
c 1.3. ==> divers
c
#ifdef _DEBUG_HOMARD_
      do 13 , iaux = 1 , 2
c
        if ( iaux.eq.1 ) then
          jaux = ulbila
        else
          if ( ulbila.eq.ulsort ) then
            goto 13
          else
            jaux = ulsort
          endif
        endif
c
        write (jaux,texte(langue,4))
        write (jaux,texte(langue,5))
        write (jaux,texte(langue,6)) epsima
c
   13 continue
#endif
c
c====
c 2. controle de la coincidence des noeuds, boite par boite
c    remarques :
c    1. La verification est sujette a caution car le test sur la
c    coincidence est un test sur une egalite de reels ...
c====
c
cgn      call gtdems (113)
cgn           print *,'nbnoto =', nbnoto
cgn           print *,'nbbomx =', nbbomx
c
      ptlfin = ptnubo(0)
c
      do 20 , numboi = 1 , nbbomx
c
        ptldeb = ptlfin + 1
        ptlfin = ptnubo(numboi)
cgn           print *,numboi, ' : ',ptldeb,ptlfin
c
c 2.1. ==> En 1D
c
      if ( sdim.eq.1 ) then
c
          do 21 , iaux = ptldeb, ptlfin
c
            lenoeu = listbo(iaux)
c
            if ( numcoi(lenoeu).eq.0 ) then
c
              do 211 , jaux = iaux+1 , ptlfin
c
                kaux = listbo(jaux)
c
                if (
     >             abs(coonoe(kaux,1)-coonoe(lenoeu,1)).le.epsima ) then
c
                  if ( numcoi(lenoeu).eq.0 ) then
                    nucoin = nucoin + 1
                    numcoi(lenoeu) = nucoin
                    ptcoin = ptcoin + 1
                    coinnn(ptcoin) = lenoeu
                  endif
                  numcoi(kaux) = nucoin
                  ptcoin = ptcoin + 1
                  coinpt(nucoin+1) = ptcoin
                  coinnn(ptcoin) = kaux
c
                endif
c
  211         continue
c
            endif
c
   21     continue
c
c 2.2. ==> En 2D
c
      elseif ( sdim.eq.2 ) then
c
          do 22 , iaux = ptldeb, ptlfin
c
            lenoeu = listbo(iaux)
c
            if ( numcoi(lenoeu).eq.0 ) then
c
              do 221 , jaux = iaux+1 , ptlfin
c
                kaux = listbo(jaux)
c
                if (
     >             abs(coonoe(kaux,1)-coonoe(lenoeu,1)).le.epsima ) then
c
                  if (
     >             abs(coonoe(kaux,2)-coonoe(lenoeu,2)).le.epsima ) then
c
                    if ( numcoi(lenoeu).eq.0 ) then
                      nucoin = nucoin + 1
                      numcoi(lenoeu) = nucoin
                      ptcoin = ptcoin + 1
                      coinnn(ptcoin) = lenoeu
                    endif
                    numcoi(kaux) = nucoin
                    ptcoin = ptcoin + 1
                    coinpt(nucoin+1) = ptcoin
                    coinnn(ptcoin) = kaux
c
                  endif
c
                endif
c
  221         continue
c
            endif
c
   22     continue
c
c 2.3. ==> En 3D
c
        else
c
          do 23 , iaux = ptldeb, ptlfin
c
            lenoeu = listbo(iaux)
cgn              print *,'. Noeud ', lenoeu
c
            if ( numcoi(lenoeu).eq.0 ) then
c
              do 231 , jaux = iaux+1 , ptlfin
c
                kaux = listbo(jaux)
c
                if (
     >             abs(coonoe(kaux,1)-coonoe(lenoeu,1)).le.epsima ) then
c
                  if (
     >             abs(coonoe(kaux,2)-coonoe(lenoeu,2)).le.epsima ) then
c
                    if (
     >              abs(coonoe(kaux,3)-coonoe(lenoeu,3)).le.epsima )then
c
                      if ( numcoi(lenoeu).eq.0 ) then
                        nucoin = nucoin + 1
                        numcoi(lenoeu) = nucoin
                        ptcoin = ptcoin + 1
                        coinnn(ptcoin) = lenoeu
                      endif
                      numcoi(kaux) = nucoin
                      ptcoin = ptcoin + 1
                      coinpt(nucoin+1) = ptcoin
                      coinnn(ptcoin) = kaux
c
                    endif
c
                  endif
c
                endif
c
  231         continue
c
            endif
c
   23     continue
c
        endif
c
   20 continue
c
      nbpbco(typenh) = nucoin
cgn      call gtfims (113)
c
c====
c 3. Impression
c    nucoix = numero de la derniere coincidence imprimee
c    Attention : il faut imprimer boite par boite sinon on en oublie ...
c====
cgn      call gtdems (114)
c
      nucoix = 0
c
      ptlfin = ptnubo(0)
c
      do 31 , numboi = 1 , nbbomx
c
        ptldeb = ptlfin + 1
        ptlfin = ptnubo(numboi)
c
        do 311 , iaux = ptldeb, ptlfin
c
          lenoeu = listbo(iaux)
c
          nucoin = numcoi(lenoeu)
c
          if ( nucoin.ne.0 .and. nucoin.gt.nucoix ) then
c
            write (ulbila,10100)
            write (ulbila,11100) mess54(langue,4)
            ptcode = coinpt(nucoin)+1
            ptcofi = coinpt(nucoin+1)
            write (ulbila,12100) (coinnn(jaux),jaux = ptcode, ptcofi)
            if ( sdim.eq.1 ) then
              write (ulbila,14101) coonoe(lenoeu,1)
            elseif ( sdim.eq.2 ) then
              write (ulbila,14102) coonoe(lenoeu,1), coonoe(lenoeu,2)
            else
              write (ulbila,14103) coonoe(lenoeu,1), coonoe(lenoeu,2),
     >                             coonoe(lenoeu,3)
            endif
            write (ulbila,10200)
c
            nucoix = nucoin
c
          endif
c
  311   continue
c
   31 continue
cgn      call gtfims (114)
c
      end
