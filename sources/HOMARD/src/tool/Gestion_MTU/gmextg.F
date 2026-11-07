      subroutine gmextg( nomtab, adunew,  lgnew, aduold,  lgold, typtab,
     >                   minmeg, ntroug, nballg, totalg,
     >                   ptroug, ltroug, ptallg, lgallg, adug,
     >                   nommxg, nomalg, satien, tablte )
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
c .  - interet:
c .      programme generique d'extension d'un tableau
c .
c .  - realisation:
c .       tentative d'extension a l'extremite du tableau.
c .       sinon reallocation recopie des donnees,
c .       suppression de l'original, reaffectation du nom original
c .
c .  - arguments:
c . donnees nomtab  --> nom du tableau a etendre (8 caracteres au plus)
c .         lgnew   --> nombre de valeurs demandees
c .         typtab  --> type du tableau :r,i,s,d, ou c
c .modifies minmeg <--> valeur entiere memorisant la plus petite
c .                     dimension du dernier trou afin de connaitre
c .                     le passage le plus delicat rencontre au cours
c .                     de l'allocation. cette valeur est calculee
c .                     apres compression (pour statistiques)
c .         ntroug <--> valeur entiere . nombre de trous presents
c .         nballg <--> nombre de tableaux deja alloues
c .         totalg <--> valeur entiere cumulant les demandes
c .                     successives de memoire
c .         ptroug <--> tableau entier contenant les pointeurs
c .                     repertoriant la position des trous
c .         ltroug <--> tableau entier contenant la longueur des trous
c .         ptallg <--> tableau entier contenant les pointeurs
c .                     repertoriant la position des tableaux
c .         adug   <--> adresse utile des tableaux ( telles que
c .                         revenant de gbcara )
c .         lgallg <--> tableau entier contenant la longueur des
c .                     tableaux
c .         nommxg <--> chaine de caractere(*8) contenant le nom du
c .                     plus grand tableau associe a minmeg
c .         nomalg <--> tableau de chaines de caracteres contenant
c .                     le nom associe a chaque tableau deja alloue
c .resultat adunew <--  pointeur associe apres extension
c .         aduold <--  pointeur avant extension
c .         lgold  <--  nombre de valeurs avant extension
c .         satien <--  vrai si le complement tient apres le tableau,
c .                     faux s'il a fallu le recreer plus loin
c .         tablte  --> nom du tableau temporaire si creation
c .
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
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmtyge.h"
c
#include "gmimpr.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*8 nomtab
      character*1 typtab
      character*8 nommxg, nomalg(maxtab)
      integer adug(maxtab)
c
      integer adunew, lgnew, aduold, lgold
      integer minmeg, ntroug, nballg, totalg
      integer ptroug(maxtrs) , ltroug(maxtrs)
      integer ptallg(maxtab) , lgallg(maxtab)
c
      logical satien
c
      character*8 tablte
c
c 0.4. ==> variables locales
c
      character*8 nomvar
      character*8 tycara
c
      integer i
      integer icptg, iold, indtrg, iptold
      integer lcara
      integer nrotab
      integer nbcain
c
      character*6 nompra
      character*6 nompro
      parameter ( nompro = 'GMEXTG' )
c
      character*1 carint(1)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c ----
c  2. preliminaires
c----
c
      if ( typtab.eq.'r' .or. typtab.eq.'R' ) then
         nompra = 'GMMODR'
      elseif ( typtab.eq.'i' .or. typtab.eq.'I' ) then
         nompra = 'GMMODI'
c
c ATTENTION : 'd' ou 'D' veut dire simple precision
c
      elseif ( typtab.eq.'d' .or. typtab.eq.'D' ) then
         nompra = 'GMMODD'
      elseif ( typtab.eq.'s' .or. typtab.eq.'S' ) then
         nompra = 'GMMODS'
      elseif ( typtab.eq.'c' .or. typtab.eq.'C' ) then
         nompra = 'GMMODC'
      else
         write(ulsort,20000) typtab
         call ugstop( nompro,ulsort,1,1,1)
      endif
c
20000 format (//2x,' ******  spg GMEXTG  *****',
     >        /2x,'Le type ',a1,' est inconnu.',
     >        /2x,'Il faut r, i, d, s ou c',
     >        /2x,'    ===>  arret dans le gestionnaire de memoire')
c
c====
c  3. verifications
c====
c
c 3.1. ==> nature du nom
c          aucun caractere n'est interdit, mais on met un blanc
c          dans le tableau pour ne plus avoir de messages ftnchek
c
      nbcain = 0
      carint(1) = ' '
      call gmntve ( nomtab, nomvar, nbcain, carint, coergm )
c
      if ( coergm.ne.0 ) then
         write(ulsort,30001) nompra
30001    format ( 2x,'Probleme a l''appel au spg GMEXTG via ',a6,
     >          /,4x,'    ===>  arret dans le gestionnaire de memoire')
        call ugstop( nompro,ulsort,0,1,1)
      endif
c
c--- impossible d'avoir une longueur < 0
c
      if (lgnew.lt.0)  then
         write(ulsort,30002) nompra, nomvar, lgnew
30002    format ( 2x,'Mauvais appel au spg GMEXTG via ',a6,
     >          /,4x,' pour le tableau ',a8,
     >          /,4x,'Nombre de valeurs requises negatif ( ',i10,')' ,
     >          /,4x,'    ===>  arret dans le gestionnaire de memoire')
        call ugstop( nompro,ulsort,1,1,1)
      endif
c
c--- verif que le nom n'est utilise qu'une fois est une seule
c
      icptg = 0
      do 33 i = 1 , nballg
         if ( nomalg(i).eq.nomvar ) then
           iold = i
           icptg = icptg + 1
         endif
   33 continue
c
      if (icptg.eq.0) then
        write(ulsort,30003) nompra, nomvar
30003   format ( 2x,'Probleme a l''appel au spg GMEXTG via ',a6,
     >         /,4x,'Le tableau (',a8,') n''a pas ete alloue',
     >         /,4x,'    ===>  arret dans le gestionnaire de memoire')
        call ugstop( nompro,ulsort,1,1,1)
      else if (icptg.gt.1) then
        write(ulsort,30013) nompra, nomvar
30013   format ( 2x,'Probleme a l''appel au spg GMEXTG via ',a6,
     >         /,4x,'Le tableau (',a8,') a ete alloue plusieurs fois' ,
     >         /,4x,'    ===>  arret dans le gestionnaire de memoire')
        call ugstop( nompro,ulsort,1,1,1)
      endif
c
c---- verif que la nouvelle taille est superieure a l'ancienne
c     mais si la nouvelle taille est egale a l'ancienne on renvoie
c     le pointeur
c
      iptold = ptallg(iold)
      lgold = lgallg(iold)
c
      call gbcara(nomtab, nrotab,aduold, lcara , tycara )
      if ( coergm.ne.0 ) then
        goto 999
      endif
c
      if (lgnew.lt.lgold) then
        write(ulsort,30004) nompra, lgnew,lgold
30004   format ( 2x,'Probleme a l''appel au spg GMEXTG via ',a6,
     >         /,4x,'La taille demandee ',i10,
     >         /,4x,'est inferieure a l''ancienne ',i10,
     >         /,4x,'    ===>  arret dans le gestionnaire de memoire')
        call ugstop( nompro,ulsort,1,1,1)
      else if (lgnew.eq.lgold) then
        adunew = aduold
        satien = .true.
        goto 999
      endif
      if ( modgm.eq.2 ) then
       satien = .false.
       call gbntcr ( tablte )
       call gmalog ( tablte, adunew,  lgnew,   typtab,
     >               minmeg, ntroug, nballg, totalg,
     >               ptroug, ltroug, ptallg, lgallg, adug,
     >               nommxg, nomalg )
       goto 999
      endif
c
c---- s'il n'y a plus de trou : erreur
c
      if (ntroug.le.0) then
        write(ulsort,30005) nompra
30005   format ( 2x,'Probleme a l''appel au spg GMEXTG via ',a6,
     >         /,4x,'Il n''y a plus de place')
        call ugstop( nompro,ulsort,1,1,1)
      endif
c
c----
c 4. extension proprement dite
c----
c
c---- on recherche le premier trou qui suit le tableau actuel
c
      do 41 i = 1 , ntroug
        if ( iptold+lgold .le. ptroug(i) ) then
           indtrg = i
           goto 42
        endif
   41 continue
c
      indtrg = 0
c
   42 continue
c
c---- une fois le trou suivant connu, deux cas sont a envisager :
c     . soit ce trou suivant commence juste apres le tableau actuel ;
c     il faut alors savoir si le complement au tableau peut tenir
c     dans ce trou.
c     . soit ce trou commence plus loin.
c
      if ( indtrg.ne.0 .and. iptold+lgold.eq.ptroug(indtrg) ) then
         if ( ltroug(indtrg).gt.lgnew-lgold ) then
            satien = .true.
         else
            satien = .false.
         endif
      else
         satien = .false.
      endif
c
c---- si le trou peut contenir le complement au tableau, il y a deux cas
c     . soit le tableau ne le remplit pas completement ;
c                                                 le trou est raccourci.
c     . soit il le remplit exactement ; dans ce cas, il faut faire
c       disparaitre ce trou vide (= de longueur nulle).
c
      if ( satien ) then
c
        adunew = aduold
        lgallg(iold) = lgnew
c
        if (ltroug(indtrg).gt.lgnew-lgold) then
c
          ptroug(indtrg) = iptold + lgnew
          ltroug(indtrg) = ltroug(indtrg) - (lgnew-lgold)
c
c   si c'est ajoute dans le dernier trou, il faut modifier les stats:
c
          if ( indtrg.eq.ntroug .and. minmeg.gt.ltroug(ntroug) ) then
            nommxg = nomvar
            minmeg = ltroug(ntroug)
          endif
c
        else
c
          if ( indtrg.eq.ntroug ) then
            if ( minmeg.gt.0 ) then
              nommxg = nomvar
            endif
            minmeg = 0
          endif
c
          ntroug = ntroug - 1
          do 43 i = indtrg, ntroug
            ptroug(i) = ptroug(i+1)
            ltroug(i) = ltroug(i+1)
   43     continue
c
        endif
c
        totalg = totalg + (lgnew-lgold)
c
      else
c
c le trou ne peut pas contenir le tableau,
c ou bien le tableau n'est pas suivi d'un trou.
c on alloue un nouveau tableau avec un nom barbare provisoire
c
        call gbntcr ( tablte )
c
        call gmalog ( tablte, adunew,  lgnew,   typtab,
     >                minmeg, ntroug, nballg, totalg,
     >                ptroug, ltroug, ptallg, lgallg, adug,
     >                nommxg, nomalg )
c
      endif
c
  999 continue
c
      end
