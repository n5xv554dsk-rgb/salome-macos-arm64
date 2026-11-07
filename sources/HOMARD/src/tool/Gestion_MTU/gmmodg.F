      subroutine gmmodg ( nomtab, lgold, lgnew,
     >                    d1old,  d1new,   d2old,  d2new,
     >                    adunew,  aduold,  type8,
     >                    minmeg, ntroug, nballg, totalg,
     >                    ptroug, ltroug, ptallg, lgallg, adug,
     >                    nommxg, nomalg, tablte )
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
c  . si les tailles sont toutes positives :
c          on passe de tab(d1old,d2old) a tab(d1new,d2new)
c  . si les tailles d1x sont negatives et les tailles d2x positives :
c          on passe de tab(d1old:d2old) a tab(d1new:d2new)
c  . sinon : probleme ...
c .   remarque : on peut aussi bien etendre que raccourcir
c .   remarque : ceci marche meme si une des dimensions reste egale
c .              a 1 mais ce n'est pas optimal ; il vaut mieux utiliser
c .              le programme prevu pour les monodimensionnels, gmextg
c .
c .  - realisation:
c .       reallocation, recopie des donnees,
c .       suppression de l'original, reaffectation du nom original
c .
c .  - arguments:
c . donnees nomtab  --> nom du tableau concerne (8 caracteres maxi)
c .         lgold   --> longueur avant
c .         lgnew   --> longueur apres
c .         d1old   --> premiere dimension avant
c .         d1new   --> premiere dimension apres
c .         d2old   --> seconde dimension avant
c .         d2new   --> seconde dimension apres
c .         type8   --> type du tableau :r,i,s,d
c .modifies minmeg <--> valeur entiere memorisant la plus petite
c .                     dimension du dernier trou afin de connaitre
c .                     le passage le plus delicat rencontre au cours
c .                     de l'allocation. cette valeur est calculee
c .                     apres compression
c .         ntroug <--> valeur entiere . nombre de trous present
c .         nballg <--> nombre de tableaux deja alloues
c .         totalg <--> valeur entiere cumulant les demandes
c .                     successives de memoire
c .         ptroug <--> tableau entier contenant les pointeurs
c .                     repertoriant la position des trous
c .         ltroug <--> tableau entier contenant la longueur des trous
c .         ptallg <--> tableau entier contenant les pointeurs
c .                     repertoriant la position des tableaux
c .         adug   <--> adresses utiles des tableaux (retour de gbcara)
c .         lgallg <--> tableau entier contenant la longueur des
c .                     tableaux
c .         nommxg <--> chaine de caractere(*8) contenant le nom du
c .                     plus grand tableau associe a minmeg
c .         nomalg <--> tableau de chaines de caracteres contenant
c .                     le nom associe a chaque tableau deja alloue
c .resultat adunew <--  pointeur associe apres extension
c .         aduold <--  pointeur avant extension
c .         tablte <--  nom du tableau temporaire
c .
c ......................................................................
c .
c .
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
      parameter ( nompro = 'GMMODG' )
c
#include "genbla.h"
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmtail.h"
#include "gmtyge.h"
c
#include "gmimpr.h"
#include "envex1.h"
#include "gmlang.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      integer lgold, lgnew
      integer d1old, d1new, d2old, d2new
      integer adug(maxtab)
c
      integer adunew, aduold
      integer minmeg, ntroug, nballg, totalg
      integer ptroug(maxtrs) , ltroug(maxtrs)
      integer ptallg(maxtab) , lgallg(maxtab)
c
      character*(*) nomtab
      character*1 type8
      character*8 nommxg, nomalg(maxtab)
      character*8 tablte
c
c 0.4. ==> variables locales
c
      character*8 nomvar
c
      integer iaux
      integer i, icptg, iold
      integer iptold
      integer ltype, ad0, ad1
      integer nbcain
c
      character*6 nompra
c
      character*1 carint(1)
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)

c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 1. preliminaires
c====
c
      coergm = 0
c
      if ( type8.eq.'i' .or. type8.eq.'I' ) then
         ltype = tentie
         ad0 = adcom(1)
         ad1 = admem(1)
         nompra = 'GMMODI'
      elseif ( type8.eq.'r' .or. type8.eq.'R' ) then
         nompra = 'GMMODR'
         ltype = treel
         ad0 = adcom(2)
         ad1 = admem(2)
      elseif ( type8.eq.'s' .or. type8.eq.'S' ) then
         ltype = tchain
         ad0 = adcom(3)
         ad1 = admem(3)
         nompra = 'GMMODS'
      else
         write(ulsort,20000) nompro, type8
         coergm = 5
      endif
c
20000 format (//2x,' ******  spg ',a6,'  *****',
     >        /2x,'Le type ',a1,' est inconnu.',
     >        /2x,'Il faut r, i ou s',
     >        /2x,'    ===>  arret dans le gestionnaire de memoire')
c
c====
c  2. verifications
c====
c
c 2.1. ==> nature du nom
c          aucun caractere n'est interdit, mais on met un blanc
c          dans le tableau pour ne plus avoir de messages ftnchek
c
      if ( coergm.eq.0 ) then
c
      nbcain = 0
      carint(1) = ' '
      call gmntve ( nomtab, nomvar, nbcain, carint, coergm )
c
      if ( coergm.ne.0 ) then
         write(ulsort,21100) nompro, nompra
21100    format ( 2x,'Probleme a l''appel au spg ',a6,' via ',a6,
     >          /,4x,'    ===>  arret dans le gestionnaire de memoire')
        coergm = 6
      endif
c
      endif
c
      if ( coergm.eq.0 ) then
c
c--- verif que le nom n'est utilise qu'une fois et une seule
c
      icptg = 0
      do 22  i = 1 , nballg
        if ( nomalg(i).eq.nomvar ) then
          iold = i
          icptg = icptg + 1
        endif
   22 continue
c
      if ( icptg.eq.0 ) then
        write(ulsort,20003) nompro, nompra, nomvar
20003   format ( 2x,'Probleme a l''appel au spg ',a6,' via ',a6,
     >         /,4x,'Le tableau (',a8,') n''a pas ete alloue',
     >         /,4x,'    ===>  arret dans le gestionnaire de memoire')
        call ugstop( nompro,ulsort,0,1,1)
      elseif (icptg.gt.1) then
        write(ulsort,20013) nompro, nompra, nomvar
20013   format ( 2x,'Probleme a l''appel au spg ',a6,' via ',a6,
     >         /,4x,'Le tableau (',a8,') a ete alloue plusieurs fois' ,
     >         /,4x,'    ===>  arret dans le gestionnaire de memoire')
        call ugstop( nompro,ulsort,0,1,1)
      endif
c
      endif
c
c====
c  3. traitement
c====
c
      if ( coergm.eq.0 ) then
c
c---- verif que l'ancienne taille correspond bien aux dimensions
c     annoncees
c
      if ( lgallg(iold).ne.lgold ) then
        write(ulsort,30001) nompro, nompra, nomvar
        if ( d1old.gt.0 ) then
          write(ulsort,30002) d1old, d2old, lgold
        else
          write(ulsort,30003) -d1old, d2old, lgold
        endif
        write(ulsort,30004) lgallg(iold), d1old, d2old, d1new, d2new
30001   format ( 2x,'Probleme a l''appel au spg ',a6,' via ',a6,
     >         /,4x,' pour le tableau ',a)
30002   format (
     > 4x,'L''ancienne taille annoncee ',i10,' x ',i10,' = ',i10)
30003   format (
     > 4x,'L''ancienne taille annoncee ',i10,' + ',i10,' = ',i10)
30004   format ( 4x,'ne correspond pas a la longueur en memoire ',i10,
     >         /,4x,'Pour memoire, on veut passer de ',
     >         /,4x,'(',i10,' ,',i10,' ) a (',i10,' ,',i10,' )',
     >         /,4x,'    ===>  arret dans le gestionnaire de memoire')
        call ugstop( nompro,ulsort,0,1,1)
      endif
c
      iptold = ptallg(iold)
c
      if ( modgm.eq.2 ) then
c
c mode dynamique :
c
        aduold = (iptold-ad0)/ltype
c
c en particulier pour les "gros types",
c on n'a pas vraiment de garantie que la division precedente
c "tombe juste". Le fait d'avoir en fait alloue un peu plus grand
c (cf. appel a gbalme dans gmalog) permet de se mettre a l'abris
c de ce genre de probleme (entre autres).
c
        if ( aduold*ltype .ge. iptold-ad0 ) then
          aduold = aduold + 1
        else
          aduold = aduold + 2
        endif
c
      else if ( modgm.eq.1 ) then
        aduold = ((ad1-ad0)/ltype) + iptold + 1
      else
        aduold = ((ad1-ad0)/ltype) + iptold
      endif
c
c---- en mode non dynamique, s'il n'y a plus de trou : erreur
c
      if ( modgm.ne.2 ) then
c
        if (ntroug.eq.0) then
          write(ulsort,30005) nompro, nompra, nomvar
30005     format ( 2x,'Probleme a l''appel au spg ',a6,' via ',a6,
     >           /,4x,' pour le tableau ',a8,
     >           /,4x,'Il n''y a plus de place')
          call ugstop( nompro,ulsort,0,1,1)
        endif
c
      endif
c
      endif
c
c----
c 4. contrairement au cas monodimensionnel,
c    on est oblige de creer un tableau different
c    ailleurs car le rangement est tel que les memes valeurs ne sont
c    plus a la meme place
c    ex a(1,1)=1    a(1,2)=2    a(1,3)=3
c       a(2,1)=4    a(2,2)=5    a(2,3)=6
c    le tableau a(2x3) est range ainsi : 1 4 2 5 3 6
c    s'il devient un tableau a(3x3), les anciennes valeurs seront
c    mises ainsi : 1 4 x 2 5 x 3 6 x
c----
c
      if ( coergm.eq.0 ) then
c
      call gbntcr ( tablte )
      call gmalog ( tablte, adunew,  lgnew, type8,
     >         minmeg, ntroug, nballg, totalg,
     >         ptroug, ltroug, ptallg, lgallg,adug,
     >         nommxg, nomalg )
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
