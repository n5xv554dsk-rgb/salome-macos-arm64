      subroutine gmalog ( nomtab,   adut, nbplac,   type1,
     >                    minmeg, ntroug, nballg, totalg,
     >                    ptroug, ltroug, ptallg, lgallg, adug,
     >                    nommxg, nomalg )
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
c  memoire dynamique :
c
c  adut est toujours une adresse utile :
c           elle peut etre utilisee sous la forme :
c           ...mem(adut)=...
c
c
c  que contient ptall :
c
c   En modgm 0 ( statique ) :
c       decalage par rapport au debut de la zone : decal
c       ptallg = decal
c       adug = (ad1-ad0)/ltype+decal
c       entre deux tableaux : adug1 - adug2 = ptallg1 - ptallg2
c
c   En modgm 1 ( semi-dynamique ) :
c       decalage par rapport au debut de la zone : decal
c       ptallg = decal
c       adug = (ad1-ad0)/ltype+decal+1
c       entre deux tableaux : adug1 - adug2 = ptallg1 - ptallg2
c
c   En modgm 2 ( dynamique ) :
c       retour de gbalme c.a.d. adresse absolue adabs
c       ptallg = adabs
c       adug = (adabs-ad0)/ltype+2
c       entre deux tableaux : adug1 - adug2 = (ptallg1 - ptallg2)/ltype
c
c       cf. commentaires dans le source pour plus de details sur
c       le calcul de adresses "utiles"
c       (= indices dans les tableaux ...mem) en dynamique.
c
c ......................................................................
c .
c .       programme generique d'allocation d'un tableau
c .       affectation du debut du premier trou memoire suffisant
c .       mise a jour du tableau des trous
c .       mise a jour des tableaux des variables allouees (stats)
c .
c .  - arguments:
c . donnees nomtab  --> nom du tableau a allouer (8 caracteres au plus)
c .         nbplac  --> nombre de places demandees
c .         type1   --> type du tableau :r,i,s
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
c .         adug  <-->  tableau entier contenant les adresses utiles
c .                     des tableaux
c .         lgallg <--> tableau entier contenant la longueur des
c .                     tableaux
c .         nommxg <--> chaine de caractere(*8) contenant le nom du
c .                     plus grand (?) tableau associe a minmeg
c .         nomalg <--> tableau de chaines de caracteres contenant
c .                     le nom associe a chaque tableau deja alloue
c .resultat adut   <--  pointeur associe
c .                     la valeur renvoyee est indefinie en cas de
c .                     probleme
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
      character*6 nompro
      parameter ( nompro = 'GMALOG' )
c
#include "gmmaxt.h"
#include "gmptrd.h"
c
#include "genbla.h"
#include "gmcain.h"
c
c 0.2. ==> communs
c
#include "gmtyge.h"
#include "gmtail.h"
#include "gmindi.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "envex1.h"
#include "gmcoer.h"
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      character*(*) nomtab
      character*1 type1
      character*8 nommxg, nomalg(maxtab)
      integer adug(maxtab)
c
      integer adut , nbplac
      integer minmeg, ntroug, nballg, totalg
      integer ptroug(maxtrs) , ltroug(maxtrs)
      integer ptallg(maxtab) , lgallg(maxtab)
c
c 0.4. ==> variables locales
c
      character*16 blabla
      character*8 nomvar
c
      integer i, iaux, maxo, mtoto
      integer pointe
      integer ltype, ad0, ad1, nrotab, nrotro
      integer nbcain, nfois, nentg
c
      character*6 nompra
c
      character*1 carint(1)
c
      logical dertro
c
      integer nbmess
      parameter ( nbmess = 10 )
c
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data nfois / 0 /
c
c ______________________________________________________________________
c
c====
c  1. preliminaires
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,''La gestion de la memoire est statique.'')'
      texte(1,5) ='(/,''La gestion de la memoire est semi-dynamique.'')'
      texte(1,6) = '(/,''La gestion de la memoire est dynamique.'')'
c
      texte(2,4) = '(/,''A static memory management is used.'')'
      texte(2,5) = '(/,''A semi-dynamic memory management is used.'')'
      texte(2,6) = '(/,''A dynamic memory management is used.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,modgm+4))
#endif
c
      coergm = 0
c
      adut = iindef
c
      blabla = '                '
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'type1 = ', type1
#endif
      if ( type1.eq.'i' .or. type1.eq.'I' ) then
         nompra = 'GMALOI'
         blabla = 'entier          '
         ltype = tentie
         ad0 = adcom(1)
         ad1 = admem(1)
      else if ( type1.eq.'r' .or. type1.eq.'R' ) then
         nompra = 'GMALOR'
         blabla = 'reel            '
         ltype = treel
         ad0 = adcom(2)
         ad1 = admem(2)
      else if ( type1.eq.'s' .or. type1.eq.'S' ) then
         nompra = 'GMALOS'
         blabla = 'caractere       '
         ltype = tchain
         ad0 = adcom(3)
         ad1 = admem(3)
      else
         write(ulsort,10000) type1
         coergm = 1
cgn         call ugstop( nompro, ulsort, 1, 1, 1 )
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'ltype = ', ltype
      write (ulsort,*) 'ad0 = ', ad0, ', ad1 = ', ad1
#endif
10000 format (//2x,' ******  spg GMALOG   *****',
     >        /2x,'Le type ',a1,' est inconnu.',
     >        /2x,'Il faut r, i ou s',
     >        /2x,'    ===>  arret dans le gestionnaire de memoire')
c
c====
c  2. verifications
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. verifications ; coergm = ', coergm
#endif
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
         write(ulsort,21100) nompra
         coergm = 21
cgn         call ugstop( nompro, ulsort, 1, 1, 1 )
      endif
c
21100 format ( 2x,'Probleme a l''appel au spg GMALOG via ',a6,
     >          /,4x,'    ===>  arret dans le gestionnaire de memoire')
c
      endif
c
c 2.2. ==> verification du nombre de tableaux deja alloues
c          . pour un tableau "ordinaire", on s'arrete un peu avant
c          le maximum pour se garder une marge dans les impressions
c          d'arret du programme
c          . si c'est un tableau de nom temporaire, on controle
c          sur le vrai nombre maximum de tableaux car il se peut
c          que ce soit dans les impressions de deboggage, donc il ne
c          faudrait pas boucler en controlant trop juste.
c
      if ( coergm.eq.0 ) then
c
      if ( nomvar(1:1).eq.caint1 ) then
c
        iaux = 0
c
      else
        iaux = 10
        if ( nballg.gt.maxtab-iaux .and. nfois.eq.0 ) then
          nfois = 1
          if ( type1.eq.'r' .or. type1.eq.'R' ) then
            call gmdmpr ( iaux )
          else if ( type1.eq.'i' .or. type1.eq.'I' ) then
            call gmdmpi ( iaux )
          else if ( type1.eq.'s' .or. type1.eq.'S' ) then
            call gmdmps ( iaux )
          endif
          write(ulsort,21100) nompra
          write(ulsort,22000) nomvar, nballg, maxtab
          coergm = 221
cgn           call ugstop( nompro, ulsort, 1, 1, 1 )
        endif
c
      endif
c
      endif
c
      if ( coergm.eq.0 ) then
c
      if ( nballg.eq.maxtab-iaux .and. nfois.eq.0 ) then
        nfois = 1
        if ( type1.eq.'r' .or. type1.eq.'R' ) then
          call gmdmpr ( iaux )
        else if ( type1.eq.'i' .or. type1.eq.'I' ) then
          call gmdmpi ( iaux )
        else if ( type1.eq.'s' .or. type1.eq.'S' ) then
          call gmdmps ( iaux )
        endif
        write(ulsort,21100) nompra
        write(ulsort,22000) nomvar, maxtab-iaux, maxtab
        coergm = 222
cgn          call ugstop( nompro, ulsort, 1, 1, 1 )
      endif
c
      endif
c
22000 format ( 2x,'GMALOG : Allocation de ',a8,
     >       /,4x,'C''est le tableau numero ',i8 ,
     >       /,4x,'Le nombre maxi de tableaux allouables vaut ',i8 ,
     >       /,4x,'Il faut changer maxtab dans le gestionnaire',
     >         1x,'(fichier a inclure gmmaxt.h)',
     >       /,4x,'    ===>  arret du au gestionnaire memoire gm')
c
c 2.3. ==> impossible d'avoir un nombre de places < 0
c
      if ( coergm.eq.0 ) then
c
      if (nbplac.lt.0)  then
        write(ulsort,21100) nompra
        write(ulsort,23000) nompra, nomvar, nbplac
        coergm = 23
cgn        call ugstop( nompro, ulsort, 1, 1, 1 )
      endif
c
      endif
c
23000 format ( 2x,'Mauvais appel au spg GMALOG via ',a6,
     >       /,4x,' pour le tableau ',a8,
     >       /,4x,'Nombre de valeurs requises negatif ( ',i15,')' ,
     >       /,4x,'    ===>  arret dans le gestionnaire de memoire')
c
c 2.4. ==> verif que le nom n'est pas deja utilise
c
      if ( coergm.eq.0 ) then
c
      do 24 i = 1 , nballg
        if ( nomalg(i).eq.nomvar ) then
          write(ulsort,24000) nompra, nomvar
          coergm = 24
          goto 241
cgn          call ugstop( nompro, ulsort, 1, 1, 1 )
        endif
   24 continue
c
  241 continue
c
      endif
c
24000 format ( 2x,'Probleme a l''appel au spg GMALOG via ',a6,
     >       /,4x,'Nom du tableau (',a8,') deja utilise' ,
     >       /,4x,'    ===>  arret dans le gestionnaire de memoire')
c
c====
c 3. Allocation
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. allocations ; coergm = ', coergm
#endif
c
c 3.1. ==> en mode statique ou semi-dynamique
c
      if ( modgm.le.1 ) then
#ifdef _DEBUG_HOMARD_
cgn      if ( nomtab.eq.'MaEn002f' ) then
      write (ulsort,*) 'nomtab = ', nomtab
      write (ulsort,*) '3.1. Mode stat ou semi/dyna ; coergm = ', coergm
      write (ulsort,*) 'nbplac = ', nbplac
cgn      endif
#endif
c
c 3.1.1. ==> si on a demande d'allouer un tableau de longueur nulle,
c            on le place en premiere position.
c            l'inconvenient est que cela oblige a remanier la liste
c            complete des tableaux a la fin de ce programme
c            mais le gros avantage est qu'en cas de desallocation
c            on ne risque pas de trouver un tableau de longueur
c            nulle encadre par deux trous ; les trous sont ainsi
c            toujours regroupes de maniere compacte
c
        if ( nbplac.eq.0 ) then
c
          if ( coergm.eq.0 ) then
c
          nrotab = 1
          pointe = ptrdeb
c
          endif
c
        else
c
c 3.1.2. ==> allocation d'un tableau de longueur non nulle
c
c 3.1.2.1. recherche du premier trou suffisamment grand
c          si aucun trou n'est disponible, impression d'un message,
c          puis arret de l'execution
c
          if ( coergm.eq.0 ) then
c
          do 311 iaux = 1 , ntroug
            if ( ltroug(iaux).ge.nbplac ) then
              nrotro = iaux
              go to 312
            endif
  311     continue
c
          call gmmaxi ( maxo , mtoto , ntroug , ltroug )
c
          write(ulsort, 30100 ) nbplac, blabla, nomvar
          write(ulsort, 30200 ) maxo, ntroug, mtoto
          iaux = 10
          if ( type1.eq.'r' .or. type1.eq.'R' ) then
            call gmdmpr ( iaux )
          else if ( type1.eq.'i' .or. type1.eq.'I' ) then
            call gmdmpi ( iaux )
          else if ( type1.eq.'s' .or. type1.eq.'S' ) then
            call gmdmps ( iaux )
          endif
c
          coergm = 312
cgn          call ugstop( nompro, ulsort, 1, 2, 1 )
c
          endif
c
c 3.1.2.2. ==> une place ayant ete trouvee, on met le tableau au debut
c              de ce trou
c              on memorise si c'etait le dernier trou ou non
c
  312     continue
c
          if ( coergm.eq.0 ) then
c
          pointe = ptroug(nrotro)
c
          if ( nrotro.eq.ntroug ) then
            dertro = .true.
          else
            dertro = .false.
          endif
c
          endif
c
c 3.1.2.3. ==> gestion des trous
c              . si le trou a la meme taille que le tableau a allouer,
c                il doit disparaitre. il faut alors decaler d'un cran
c                les eventuels trous qui suivent.
c              . si le trou est plus grand que le tableau a allouer,
c                il est simplement decale et raccourci.
c
          if ( coergm.eq.0 ) then
c
          if ( ltroug(nrotro).eq.nbplac ) then
c
             ntroug = ntroug - 1
             do 313 iaux = nrotro , ntroug
                ptroug(iaux) = ptroug(iaux+1)
                ltroug(iaux) = ltroug(iaux+1)
  313        continue
             ptroug(ntroug+1) = iindef
             ltroug(ntroug+1) = iindef
c
             if ( dertro ) then
               if ( minmeg.gt.0 ) then
                 nommxg = nomvar
               endif
               minmeg = 0
             endif
c
          else
c
            ptroug(nrotro) = ptroug(nrotro) + nbplac
            ltroug(nrotro) = ltroug(nrotro) - nbplac
c
          endif
c
          endif
c
c 3.1.2.4. ==> on met a jour la longueur minimale du dernier trou.
c
          if ( coergm.eq.0 ) then
c
          if ( ntroug.le.0 ) then
            minmeg = 0
          else if ( minmeg.gt.ltroug(ntroug) ) then
            nommxg = nomvar
            minmeg = ltroug(ntroug)
          endif
c
          endif
c
c 3.1.2.5. ==> . si le tableau est place au debut du dernier trou,
c                il vient a la suite du dernier tableau enregistre.
c              . si le tableau est place dans un trou qui est au milieu
c                des tableaux, il faut l'inserer entre des tableaux
c                deja alloues. on recherche le premier tableau dont
c                l'adresse est plus grande que l'adresse du-dit trou.
c
          if ( coergm.eq.0 ) then
c
          if ( dertro ) then
c
            nrotab = nballg + 1
c
          else
c
            do 314 i = 1, nballg
              if (ptallg(i).gt.pointe) then
                nrotab = i
                goto 315
              endif
  314       continue
c
c NB: si on passe ici, c'est bizarre
c     (mauvaise gestion des trous?)
c
            nrotab = nballg + 1
c
  315       continue
c
          endif
c
          endif
c
        endif
c
c 3.1.3. ==> calcul de l'adresse utile
c
        if ( coergm.eq.0 ) then
c
        adut = ((ad1-ad0)/ltype) + pointe
        if ( modgm.eq.1 ) then
          adut = adut + 1
        endif
c
        endif
c
c 3.1.4. ==> mise a jour des listes par decalage des informations
c            relatives aux tableaux qui viennent apres le tableau
c            en cours d'allocation
c
        if ( coergm.eq.0 ) then
c
        do 316 iaux = nballg , nrotab , -1
          nomalg(iaux+1) = nomalg(iaux)
          ptallg(iaux+1) = ptallg(iaux)
          lgallg(iaux+1) = lgallg(iaux)
          adug(iaux+1)   = adug(iaux)
  316   continue
c
        endif
c
c 3.2. ==> cas du mode dynamique
c          le tableau alloue est toujours le dernier
c
      else
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '3.2. Mode dynamique ; coergm = ', coergm
#endif
c
        if ( coergm.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'appel de gbalme par gmalog, avec :'
        write (ulsort,*) '... type1    : ', type1
        write (ulsort,*) '... nbplac+1 : ', nbplac+1
#endif
        call gbalme ( type1, nbplac+1, pointe )
c
        endif
c
        if ( coergm.ne.0 ) then
c
          write(ulsort,30100) nbplac+1, blabla, nomvar
cgn          call ugstop( nompro, ulsort, 1, 2, 1 )
c
        else
c
          nrotab = nballg + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'pointe = ', pointe
      write (ulsort,*) 'pointe-ad0 = ', pointe-ad0
#endif
          adut = (pointe-ad0)/ltype
c
c En particulier pour les "gros types"
c on n'a pas vraiment de garantie que la division precedente
c "tombe juste". Le fait d'avoir en fait alloue nbplac+1 au lieu de
c nbplac (cf. appel a gbalme ci-dessus) permet de se mettre a l'abri
c de ce genre de probleme (en plus d'eviter de demander au systeme
c un malloc avec taille nulle, ce qui ne se passe pas toujours bien).
c
c Cette maniere d'evaluer l'adresse utile adut permet aussi de se
c premunir du cas ( extremement rare apparemment ) ou pointe-ad0
c serait negatif (habituellement, les communs -donc ad0- sont charges
c en memoire a des adresses inferieures au "heap" -donc pointe-).
c
          if ( adut*ltype .ge. pointe-ad0 ) then
            adut = adut + 1
          else
            adut = adut + 2
          endif
c
c  gestion des grandeurs permettant d'obtenir des statistiques globales
c  (meme en mode dynamique) :
c
          if ( minmeg.ge.nbplac ) then
            minmeg = minmeg - nbplac
            if ( minmeg.eq.0 .and. nbplac.gt.0 ) then
              nommxg = nomvar
            endif
          else
            if ( type1.eq.'r' .or. type1.eq.'R' ) then
              rmem(1) = rmem(1) + dble(nbplac - max( 0, minmeg ))
            else if ( type1.eq.'i' .or. type1.eq.'I' ) then
              imem(1) = imem(1) + nbplac - max( 0, minmeg )
            else if ( type1.eq.'s' .or. type1.eq.'S' ) then
              if (index(smem(1),'*').le.0) then
                read(smem(1),'(i8)') nentg
                nentg = nentg + nbplac - max( 0, minmeg )
                write(smem(1),'(i8)') nentg
              endif
            endif
            if ( nbplac.gt.0 .or. minmeg.lt.0 ) then
              nommxg = nomvar
            endif
            minmeg = 0
          endif
c
        endif
c
      endif
c
c 3.3. ==> memorisation des caracteristiques du nouveau tableau
c          et statistiques globales
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3.3. Memorisation ; coergm = ', coergm
#endif
c
      if ( coergm.eq.0 ) then
c
      nballg = nballg + 1
c
      nomalg(nrotab) = nomvar
      ptallg(nrotab) = pointe
      lgallg(nrotab) = nbplac
      adug(nrotab) = adut
c
      totalg = totalg + nbplac
c
      endif
c
c 3.5 ==> messages
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3.5. messages ; coergm = ', coergm
#endif
30100 format(
     >/,78('='),
     >/,'Impossible d''allouer',i15,' places en ',a16,
     > ' pour ''',a8,'''',
     >/,78('='),/)
30200 format(
     >/,10x,'Le maximum disponible est de',i15,' places ;',
     >/,10x,'Il y a',i5,' trous totalisant',i15,' places.'/)
c
c====
c 4. Fin
c====
c
      if ( coergm.ne.0 ) then
c
#include "envex2.h"
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
