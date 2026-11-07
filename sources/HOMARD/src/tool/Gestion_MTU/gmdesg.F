      subroutine gmdesg ( nomtab, nbplac,   type1, detlg0,
     >                    ntroug, nballg, ptroug, ltroug,
     >                    ptallg, lgallg,   adug, nomalg )
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
c . creation octobre 93 gn
c ......................................................................
c
c le programme libere nbplac mots de memoire a partir de la fin
c pour le tableau nomtab                     ==================
c
c ......................................................................
c .
c .  - fonction :
c .   programme generique de desallocation d'un emplacement memoire
c . 'attention' le contenu du tableau est inchange
c .
c .  - realisation:
c .       recherche du premier trou memoire suivant
c .       mise a jour du tableau des trous (rallonge ou creation)
c .       mise a jour des tableaux des variables allouees (stats)
c .
c .  - arguments:
c . donnees nomtab  --> nom du tableau concerne
c .         nbplac  --> nombre de mots liberes a partir de la fin
c .         type1   --> type du tableau :r,i,s,d, ou c
c .         detlg0  --> vrai/faux pour la destruction du tableau s'il
c .                     devient de longueur nulle
c .modifies ntroug <--> valeur entiere . nombre de trous presents
c .         nballg <--> nombre de tableaux deja alloues
c .         ptroug <--> tableau entier contenant les pointeurs
c .                     repertoriant la position des trous
c .         ltroug <--> tableau entier contenant la longueur des trous
c .         ptallg <--> tableau entier contenant les pointeurs
c .                     repertoriant la position des tableaux
c .         adug   <--> adresses utiles des tableaux
c .                     telles que retournees par gbcara
c .         lgallg <--> tableau entier contenant la longueur des
c .                     tableaux
c .         nomalg <--> tableau de chaines de caracteres contenant
c .                     le nom associe a chaque tableau deja alloue
c .  - restriction d' usage
c .      le spg n'accepte de desallouer la zone prescrite que si celle
c .      ci est integralement contenue dans un tableau effectivement
c .      alloue precedemment. cela autorise une desallocation partielle.
c .      il ne desalloue jamais un tableau de longueur nulle. en effet
c .      meme si pointe coincide avec l'adresse d'un tableau de longueur
c .      nulle il n'est pas possible de savoir si l'on a voulu
c .      desallouer la fin du tableau precedent mais il se trouve que
c .      nbplac est nul ou le tableau de longueur nulle qui se trouve a
c .      l'adresse pointe
c .
c ......................................................................
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
      parameter ( nompro = 'GMDESG' )
c
#include "genbla.h"
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmtail.h"
#include "gmtyge.h"
c
#include "gmindi.h"
#include "gminds.h"
c
#include "gmtrrl.h"
#include "gmtren.h"
#include "gmtrst.h"
c
#include "gmimpr.h"
#include "envex1.h"
#include "gmlang.h"
#include "gmcoer.h"
c
c 0.3. ==> arguments
c
      character*1 type1
      character*8 nomtab, nomalg(maxtab)
c
      integer nbplac, ntroug, nballg
      integer ptroug(maxtrs) , ltroug(maxtrs)
      integer ptallg(maxtab) , lgallg(maxtab)
      integer adug(maxtab)
c
      logical detlg0
c
c 0.4. ==> variables locales
c
      integer adut
c
      integer ltype
c     decal : decalage / au debut de la zone
c             uniquement en mode statique ou semi-dynamique
c
      integer decal
c
c     adabs : adressr absolue
c
      integer adabs, ad0
c
      character*8 typobs
c
      integer iaux, jaux, nrotab, nrotro
c
      character*6 nompra
c
      logical jointb, jointh
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
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
c  1. preliminaires
c====
c
      coergm = 0
c
      if ( type1.eq.'i' .or. type1.eq.'I' ) then
        nompra = 'GMDESI'
        ltype = tentie
        ad0 = adcom(1)
      elseif ( type1.eq.'r' .or. type1.eq.'R' ) then
        nompra = 'GMDESR'
        ltype = treel
        ad0 = adcom(2)
      elseif ( type1.eq.'s' .or. type1.eq.'S' ) then
        nompra = 'GMDESS'
        ltype = tchain
        ad0 = adcom(3)
      else
        write(ulsort,10000) type1
        coergm = 1
      endif
c
10000 format(/2x,'Le type ',a1,' est inconnu.',
     >       /2x,'Il faut r, i ou s')
c
c====
c  2. verifications
c====
c
      if ( coergm.eq.0 ) then
c
        if ( nbplac .lt. 0 ) then
          write(ulsort,20001) nbplac
          coergm = 1
        endif
c
      endif
c
20001 format(/2x,'On demande a liberer ',i8,' places.')
c
c====
c 3. recherche du tableau
c====
c
      if ( coergm.eq.0 ) then
c
c 3.1.1. ==> recherche du numero du tableau concerne
c
        call gbcara ( nomtab , nrotab, adut , iaux , typobs )
c
c 3.1.2. ==> il ne faut pas enlever plus de places qu'il n'y en a deja
c
        if ( coergm.eq.0 ) then
          if ( nbplac.gt.lgallg(nrotab) ) then
            write(ulsort,20001) nbplac
            write(ulsort,30001) lgallg(nrotab)
            coergm = 1
          endif
        endif
c
30001  format(2x,'Or le tableau est alloue avec ',i8,' places.')
c
c 3.1.3. ==> si c'est bon, on repere les adresses de la zone a liberer
c            si aucun tableau trouve --> messages d'erreur et arret
c
        if ( coergm.eq.0 ) then
          if ( modgm.le.1 ) then
            decal = ptallg(nrotab) + lgallg(nrotab) - nbplac
          else
            adabs = ptallg(nrotab)
          endif
        endif
c
      endif
c
c====
c 4. en mode statique ou semi-dynamique, il faut gerer les trous
c    quand on desalloue un nombre non nul de places
c====
c
      if ( coergm.eq.0 .and. modgm.le.1 .and. nbplac.ne.0 ) then
c
c 4.1. ==> localisation de l'adresse donnee par rapport aux trous
c
        nrotro = 0
        do 41 iaux = 1, ntroug
          if ( ptroug(iaux).gt.decal ) then
            nrotro = iaux
            go to 42
          endif
   41   continue
c
c 4.2. ==> gestion du nouveau trou
c
   42   continue
c
        if ( nrotro.eq.0 ) then
c
c 4.2.1. ==> la zone liberee se situe apres tous les trous existants
c              --> cela constitue un nouveau trou en fin de tableau
c
          ntroug         = ntroug + 1
          ptroug(ntroug) = decal
          ltroug(ntroug) = nbplac
c
        else
c
c 4.2.2. ==> on a trouve un trou qui est place apres la zone a liberer
c            Si ce n'est pas le premier, y en a-t-il un autre avant ?
c
          if ( nrotro.eq.1 ) then
            jointb = .false.
          else
            jointb = ((ptroug(nrotro-1)+ltroug(nrotro-1)).ge.decal)
          endif
c
          jointh = ( (decal+nbplac).ge.ptroug(nrotro) )
c
c             ---> action suivant les 4 cas possibles
c
          if (jointb.and.jointh) then
c
c       fusion par le bas et le haut (elimination d'un trou)
c
            ltroug(nrotro-1) = ltroug(nrotro) +
     >                         ptroug(nrotro)-ptroug(nrotro-1)
            ntroug = ntroug-1
            do 43 iaux = nrotro, ntroug
              ptroug(iaux) = ptroug(iaux+1)
              ltroug(iaux) = ltroug(iaux+1)
   43       continue
            ptroug(ntroug+1) = iindef
            ltroug(ntroug+1) = iindef
c
          else if (jointb) then
c
c       fusion par le bas
            ltroug(nrotro-1) = decal + nbplac - ptroug(nrotro-1)
c
          else if (jointh) then
c
c       fusion par le haut
            ltroug(nrotro) = ptroug(nrotro) + ltroug(nrotro) - decal
            ptroug(nrotro) = decal
c
          else
c
c       creation d'un nouveau trou au milieu
            ntroug = ntroug + 1
            jaux = ntroug
            do 44 iaux = nrotro+1, ntroug
              ptroug(jaux) = ptroug(jaux-1)
              ltroug(jaux) = ltroug(jaux-1)
              jaux=jaux-1
   44       continue
            ptroug(nrotro) = decal
            ltroug(nrotro) = nbplac
c
          endif
c
        endif
c
      endif
c
c====
c 5. raccourcissement effectif
c====
c
      if ( coergm.eq.0 ) then
c
c 5.1. ==> si tout est bon, on raccourcit
c
        lgallg(nrotab) = lgallg(nrotab) - nbplac
c
c 5.2. ==> si la longueur finale est nulle et que l'on ne garde
c          pas un tableau de longueur nulle, on desalloue totalement
c
        if ( detlg0 .and. lgallg(nrotab).eq.0 ) then
c
c 5.2.1. ==>  on supprime le tableau des tables
c
           nballg = nballg - 1
c
           do 52 iaux = nrotab, nballg
             nomalg(iaux) = nomalg(iaux+1)
             ptallg(iaux) = ptallg(iaux+1)
             lgallg(iaux) = lgallg(iaux+1)
             adug(iaux)   = adug(iaux+1)
   52      continue
c
           nomalg(nballg+1) = sindef
           ptallg(nballg+1) = iindef
           lgallg(nballg+1) = iindef
           adug(nballg+1)   = iindef
c
c 5.2.2. ==>  en mode dynamique, on libere la memoire
c
           if ( modgm.eq.2 ) then
c
             call gblibe( type1, nbplac, adabs, coergm )
c
             if ( coergm.ne.0 ) then
                write(ulsort,*) nompro, ' modgm 2 erreur au free'
             endif
c
           endif
c
         else if ( modgm.eq.2 .and. nbplac.gt.0 ) then
c
c Raccourcissement "partiel" en mode dynamique:
c
c (noter que ce raccourcissement partiel, ou re-allocation,
c  n'est pas vital au fonctionnement de gm)
c
cgn           write(ulsort,*) 'appel de gbralo'
           call gbralo( type1, lgallg(nrotab)+1,
     >                  ptallg(nrotab), coergm )
cgn           write(ulsort,*) 'retour de gbralo'
c
           if ( coergm.ne.0 ) then
c
             write(ulsort,*) nompro, ' modgm 2 erreur au realloc'
             ptallg(nrotab) = adabs
c
           else if ( ptallg(nrotab).ne.adabs ) then
c
c cas ou l'adresse memoire du tableau a ete changee :
c on recalcule l'adresse "utile" adug(nrotab)
c
            adabs = (ptallg(nrotab)-ad0)/ltype
c
            if ( adabs*ltype .ge. ptallg(nrotab)-ad0 ) then
              adug(nrotab) = adabs + 1
            else
              adug(nrotab) = adabs + 2
            endif
           endif
c
         endif
c
         if (coergm.eq.0 .and. modgm.eq.2 .and. nbplac.gt.0) then
c
c  gestion des grandeurs permettant d'obtenir des statistiques globales
c  (meme en mode dynamique) :
c
              if ( type1.eq.'r' .or. type1.eq.'R' ) then
                minmer = minmer + nbplac
              else if ( type1.eq.'i' .or. type1.eq.'I' ) then
                minmei = minmei + nbplac
              else if ( type1.eq.'s' .or. type1.eq.'S' ) then
                minmes = minmes + nbplac
              endif
c
         endif
c
      endif
c
c====
c 5. arret si erreur
c====
c
      if ( coergm.ne.0 ) then
c
        write(ulsort,50000) nompro, nompra, nomtab
c
        if ( type1.eq.'r' .or. type1.eq.'R' ) then
          call gmdmpr ( iaux )
        elseif ( type1.eq.'i' .or. type1.eq.'I' ) then
          call gmdmpi ( iaux )
        elseif ( type1.eq.'s' .or. type1.eq.'S' ) then
          call gmdmps ( iaux )
        endif
c
        call ugstop ( nompro, ulsort, 0, 1, 1 )
c
      endif
c
50000 format(/2x,' ******  spg ',a,' via ',a6,' *****',
     >      /2x,' probleme pour le tableau ',a8,
     >      /2x,' ===>  arret a cause du gestionnaire de memoire',
     >      /2x ,'Verifier votre appel a l''aide des infos suivantes')
c
c====
c 3. Fin
c====
c
      if ( coergm.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
      end
