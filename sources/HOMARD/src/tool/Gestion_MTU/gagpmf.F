      subroutine gagpmf (objet, chemin, lgchem, nbchem,
     >                   ix, jx, nbrobj, nbrcha,
     >                   nomob, typob, adrch, nomco,
     >                   nballi, nomali,
     >                   nballr, nomalr,
     >                   nballs, nomals,
     >                   impopt, codret)
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
c     construction du graphe d'un objet structure en memoire
c     centrale ou sur fichier
c
c    de maniere generale, on a :
c
c      nbchem           = nombre de chemins pour l'objet
c      lgchem(i)        = longueur du i-eme chemin
c      chemin(i,2n-1)   = nom du n-eme champ du i-eme chemin
c      chemin(i,2n)     = nom de l'objet associe a ce n-eme champ
c      chemin(i,lgchem) = symbole pour le dernier champ :
c                          * pour simple alloue
c                          > pour structure alloue
c                          = pour simple non alloue
c                          + pour structure non alloue
c                          - pour simple non defini
c                          < pour structure non defini
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . objet  . e   .  ch8   . nom de l'objet dont on doit construire le  .
c .        .     .        . graphe                                     .
c . chemin .  s  .(ix,jx) . tableau des chemins du graphe de l'objet   .
c . lgchem .  s  .  ix    . longueur des chemins                       .
c . nbchem .  s  .   1    . nombre de chemins                          .
c . ix,jx  . e   .   1    . dimension du tableau chemin(.,.)           .
c . nbrobj . e   .   1    . nombre d'objet enregistres                 .
c . nbrcha . e   .   1    . nombre de champs                           .
c . impopt . e   .   1    . 1 : on imprime le graphe ; 0 : non         .
c . codret .  s  .   1    . code de retour :                           .
c .        .     .        .  0    : OK                                 .
c .        .     .        . -1    : dimensionnement insuffisant        .
c .        .     .        . -2    : objet non structure                .
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
      character*6 nompro
      parameter ( nompro = 'GAGPMF' )
c
c
#include "genbla.h"
c
#include "gmmatc.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtors.h"
c
#include "gminds.h"
#include "gmimpr.h"
#include "gmlang.h"
c
c 0.3. ==> arguments
c
      integer ix, jx, nbrobj, nbrcha, impopt, codret
      integer nballi, nballr, nballs
      integer nbchem, lgchem(ix)
c
      integer typob(nbrobj), adrch(nbrobj)
c
      character*(*) objet
      character*8 chemin(ix,jx)
      character*8 nomob(nbrobj), nomco(nbrcha)
      character*8 nomali(nballi)
      character*8 nomalr(nballr)
      character*8 nomals(nballs)
c
c 0.4. ==> variables locales
c
      character*8 nomo
c
      integer iaux,jaux,kaux,typo,nbch,icha,typc
      integer jn,noderc,n,k
      integer nroobj, posich
c
      logical existc, encore, trouvc
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '('' * : objet simple alloue'')'
      texte(1,5) = '('' = : objet simple defini mais non alloue'')'
      texte(1,6) = '('' + : objet structure defini mais non alloue'')'
      texte(1,7) = '('' - : objet simple non defini'')'
      texte(1,8) = '('' < : objet structure non defini'')'
      texte(1,9) = '('' '')'
c
      texte(2,4) = '('' * : allocated simple object'')'
      texte(2,5) = '('' = : defined but not allocated simple object'')'
      texte(2,6) =
     > '('' + : defined but not allocated structured object'')'
      texte(2,7) = '('' - : undefined simple object'')'
      texte(2,8) = '('' < : undefined structured object'')'
      texte(2,9) = '('' '')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90000)
        write (ulsort,texte(langue,1)) 'Sortie', nompro
90000 format (70('='))
#endif
c
c====
c 2. initialisations
c====
c
      do 21 , iaux = 1,nbrobj
        if (nomob(iaux).eq.objet) then
          nroobj = iaux
          codret = 0
          goto 31
        endif
   21 continue
c
      codret = -2
c
c====
c 3. recherche de l'objet initial et de ses champs
c====
c
   31 continue
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> initialisation du chemin : a priori, il est indefini
c          remarque : la boucle sur ix doit etre interne pour la
c          vectorisation car ix >> jx
c
        do 312 , jaux = 1,jx
          do 311 , iaux = 1,ix
            chemin(iaux,jaux) = sindef
  311     continue
  312   continue
c
c 3.2. ==> reperage des noms et type des champs de l'objet
c
        typo = typob(nroobj)
        nbch = nbcham(typo)
c
        do 32 , iaux = 1,nbch
c
          icha = adrdst(typo)+iaux-1
          chemin(iaux,1) = nomcha(icha)
c
          kaux = adrch(nroobj)+iaux-1
          chemin(iaux,2) = nomco(kaux)
c
          typc = typcha(icha)
c
          if (typc.lt.0) then
            chemin(iaux,3) = '*       '
          else
            chemin(iaux,3) = '>       '
          endif
c
          lgchem(iaux) = 3
c
   32    continue
c
      endif
c
c====
c 4.  construction du graphe
c====
c
      if ( codret.eq.0 ) then
c
c 4.1. ==> construction de l'arborescence
c
        do 41 , jn = 1,jx
c
c 4.1.1. ==> recherche du numero du dernier champ defini : noderc
c
          do 411 , iaux = 1,ix
            if (chemin(iaux,1).eq.sindef) then
              noderc = iaux-1
              goto 412
            endif
  411     continue
          write (ulsort,*) 'apres 411 continue'
          codret = -1
c
  412     continue
c
          if ( codret.eq.0 ) then
c
c 4.1.2. ==> nbchem est le nombre total de chemins a decrire :
c            au depart, c'est le nombre de champs de l'objet demande.
c            par ailleurs on signale que tout est fait
c
            nbchem = noderc
            encore = .false.
c
c 4.1.3. ==> on explore chacun des champs de l'objet de depart, jusqu'a
c          ce qu'il n'y ait plus que des champs simples
c
            do 413 , iaux = 1,noderc
c
c 4.1.3.1. ==> recherche d'un champ de type structure dans le chemin
c            s'il en existe un :
c              . on repere sa position par posich
c              . on signale qu'il faudra recommencer pour lui
c
              do 431 , jaux = 3 , jx , 2
                if (chemin(iaux,jaux)(1:1).eq.'>') then
                  posich = jaux
                  encore = .true.
                  existc = .true.
                  goto 432
                endif
                if (chemin(iaux,jaux)(1:1).eq.'*') then
                  existc = .false.
                  goto 432
                endif
  431         continue
c
c 4.1.3.2. ==> on est sur un champ de type structure
c
  432         continue
c
              if ( existc ) then
c
c 4.1.3.2.1. ==> quel est le nom de ce champ ?
c              . s'il n'est pas defini, on le symbolise par '<       '
c              . s'il est defini on cherche son numero dans
c                la liste des champs ; si on ne l'y trouve pas, on
c                le symbolise par '+       '
c
                nomo = chemin(iaux,posich-1)
c
                if (nomo.eq.sindef) then
c
                  chemin(iaux,posich) = '<       '
                  trouvc = .false.
c
                else
c
                  do 433 , kaux = 1,nbrobj
                     if (nomob(kaux).eq.nomo) then
                        nroobj = kaux
                        trouvc = .true.
                        goto 434
                     endif
  433             continue
c
                  chemin(iaux,posich) = '+       '
                  trouvc = .false.
c
                endif
c
  434           continue
c
c 4.1.3.2.2. ==> le champ est defini : il faut ecrire sa descendance
c              en fait, on fait comme a l'etape 2 pour l'objet de depart
c                . pour le premier champ, on etend le chemin existant
c                . pour les eventuels champs suivants, on cree autant
c                  de nouveaux chemins en recopiant le debut
c
                if ( trouvc ) then
c
                  if ( posich+2.gt.jx ) then
            write (ulsort,*) 'objet  = ',objet
            write (ulsort,*) 'dans 4.1.3.2.2, posich+2 = ',posich+2
            write (ulsort,*) 'dans 4.1.3.2.2, jx = ',jx
        do 1789 , n = 1,nbch
          write (ulsort,*)(chemin(n,k),k=1,jx)
 1789 continue
                     codret = -1
                     goto 42
                  endif
c
c                 on commence par ecrire les trois informations
c                 de la fin du chemin en cours :
c                 nom du champ, nom de l'objet associe, symbole
c
                  typo = typob(nroobj)
                  nbch = nbcham(typo)
c
                  icha = adrdst(typo)
                  chemin(iaux,posich) = nomcha(icha)
c
                  kaux = adrch(nroobj)
                  chemin(iaux,posich+1) = nomco(kaux)
c
                  typc = typcha(icha)
                  if (typc.lt.0) then
                     chemin(iaux,posich+2) = '*       '
                  else
                     chemin(iaux,posich+2) = '>       '
                  endif
c
                  lgchem(iaux) = posich+2
c
c               ensuite, on cree les chemins associes aux eventuels
c               champs suivants :
c                 . on commence par mettre le debut
c                 . puis on complete par les caracteristiques propres
c                   au champ en cours
c
                  do 435 , n = 1,nbch-1
c
                     nbchem = nbchem+1
c
                     do 436 , k = 1,posich-1
                        chemin(nbchem,k) = chemin(iaux,k)
  436                continue
c
                     icha = adrdst(typo)+n
                     chemin(nbchem,posich) = nomcha(icha)
c
                     kaux = kaux + 1
                     chemin(nbchem,posich+1) = nomco(kaux)
c
                     typc = typcha(icha)
                     if (typc.lt.0) then
                        chemin(nbchem,posich+2) = '*       '
                     else
                        chemin(nbchem,posich+2) = '>       '
                     endif
c
                     lgchem(nbchem) = posich+2
c
  435             continue
c
                endif
c
              endif
c
  413       continue
c
c 4.1.3. ==> on a fini d'explorer une branche. on sort si c'est fini
c
            if ( .not.encore ) then
              goto 42
            endif
c
          endif
c
   41    continue
c
c 4.2. ==> on controle les extremites des champs : celles qui
c          correspondent a des objets simples definis mais non alloues
c          sont signalees
c
   42    continue
c
         do 421 , iaux = 1 , nbchem
c
            if ( chemin(iaux,lgchem(iaux))(1:1).eq.'*' ) then
c
               nomo = chemin(iaux,lgchem(iaux)-1)
c
               if ( nomo.eq.sindef ) then
c
                  chemin(iaux,lgchem(iaux)) = '-       '
c
               else
c
                  trouvc = .false.
c
                  do 422 , jaux = 1 , nballi
                     if (nomali(jaux).eq.nomo) then
                        trouvc = .true.
                        goto 429
                     endif
  422             continue
c
                  do 423 , jaux = 1 , nballr
                     if (nomalr(jaux).eq.nomo) then
                        trouvc = .true.
                        goto 429
                     endif
  423             continue
c
                  do 424 , jaux = 1 , nballs
                     if (nomals(jaux).eq.nomo) then
                        trouvc = .true.
                        goto 429
                     endif
  424             continue
c
  429             continue
                  if ( .not.trouvc ) then
                     chemin(iaux,lgchem(iaux)) = '=       '
                  endif
c
               endif
c
            endif
c
  421    continue
c
      endif
c
c====
c 5. impressions
c====
c
      if (impopt.eq.1) then
c
      do 51 , iaux = 4, 9
        write (ulsort,texte(langue,iaux))
   51 continue
c
      write (ulsort,*) ' '
      do 52 , iaux = 1 , nbchem
        kaux = min ( 10 , lgchem(iaux) )
        write (ulsort,5000) iaux,(chemin(iaux,jaux),jaux=1,kaux)
        if ( lgchem(iaux).gt.kaux ) then
          write (ulsort,5001)
     >    (chemin(iaux,jaux),jaux=kaux+1,lgchem(iaux))
        endif
        write (ulsort,*) ' '
   52 continue
c
      write (ulsort,*) ' '
c
 5000 format(i3,'-> ',10(1x,a8))
 5001 format(7x,10(1x,a8))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90000)
#endif
c
      end
