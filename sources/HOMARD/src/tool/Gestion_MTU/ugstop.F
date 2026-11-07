      subroutine ugstop ( appela, messul, guimp, gmimp, raison )
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
c but : arreter une execution apres avoir arrete les gestionnaires
c       - gestionnaire de memoire
c       - gestionnaire des mesures de temps de calcul
c       - gestionnaire d'unites logiques
c       - execution elle-meme
c
c       ATTENTION : dans certains cas tordus d'arret de GM ou GU, il y a
c                   bouclage sur l'appel a ugstop. On empeche cela
c                   en ne faisant les impressions qu'au premier appel
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . appela . e   .    1   . nom du programme appelant                  .
c . messul . e   .    1   . unite logique pour les messages            .
c . guimp  . e   .    1   . pilotage des impressions gu                .
c . gmimp  . e   .    1   . pilotage des impressions gm                .
c . raison . e   .    1   . raison de l'appel :                        .
c .        .     .        . 0 : arret normal, sans core                .
c .        .     .        . >0 : call abort -> core                    .
c .        .     .        . <0 : arret des gestionnaires, puis sortie  .
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
      parameter ( nompro = 'UGSTOP' )
c
#include "genbla.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer messul, raison, guimp, gmimp
c
      character *(*) appela
c
c 0.4. ==> variables locales
c
      integer lgtage
      parameter ( lgtage = 4 )
c
      integer code
      integer langue
      integer tabges(lgtage)
c
      integer nropas, enstul, sostul, ulsort
      integer iaux, jaux
c
      character*06 saux06
      character*38 appelo
      character*38 saux38
c
      logical afaire
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
      data nropas / 0 /
c
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
      if ( messul.le.0 ) then
        call dmunit ( enstul, sostul )
        ulsort = sostul
      else
        ulsort = messul
      endif
c
#include "impr01.h"
c
      texte(1,4) = ':  A la demande du programme '
c                   12345678901234567890123456789012345678
      texte(1,5) = ':           ARRET NORMAL             :'
      texte(1,6) = ':   ARRET pour cause de probleme     :'
      texte(1,7) = ':   ARRET sur bouclage dans '
c
      texte(2,4) = ':    Requested by subroutine '
      texte(2,5) = ':            NORMAL STOP             :'
      texte(2,6) = ':      STOP because of problem       :'
      texte(2,7) = ':   STOP because of loop in '
c
10000 format (
     >   15x,'......................................')
10001 format (
     >   15x,':                                    :',
     > /,15x,a38,
     > /,15x,':....................................:')
10002 format (
     >   15x,':                                    :',
     > /,15x,a38,
     > /,15x,a38,
     > /,15x,':....................................:')
c
c====
c 2. recuperation de l'etat des differents gestionnaires
c
c     (1): unites logiques (1 : initialise, 0 : non)
c     (2): mesures de temps de calcul (1 : initialise, 0 : non)
c     (3): memoire (1 : initialise, 0 : non)
c     (4): langue (1: francais, 2:anglais)
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(1,3)) 'UGTABL', nompro
#endif
      code = 1
      call ugtabl ( code, tabges, ulsort )
c
      langue = tabges(4)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      if ( langue.le.0 .or. langue.gt.nblang ) then
        langue = 1
      endif
c
c====
c 3. entete
c====
c
      nropas = nropas + 1
c
c recopie prudente du nom de l'appelant, appela dans appelo :
c
      iaux = len(appela)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DMCPCH', nompro
#endif
      call dmcpch( appela, iaux, appelo, jaux )
c
      if ( jaux.eq.0 ) then
        appelo = '? ? ? '
        jaux = 6
      endif
c
#ifdef _DEBUG_HOMARD_
      afaire = .true.
#else
      if ( raison.le.0 ) then
        afaire = .false.
      else
        afaire = .true.
      endif
#endif
c
      if ( raison.ne.0 ) then
        write (ulsort,10000)
      endif
      if ( raison.le.0 ) then
        write (ulsort,10001) texte(langue,5)
      endif
c
      if ( afaire ) then
c
      if ( jaux.le.6 ) then
        saux06(1:iaux) = appelo(1:jaux)
        do 311 , iaux = jaux+1 , 6
          saux06(iaux:iaux) = ' '
  311   continue
        write (ulsort,10001) texte(langue,4)(1:29)//saux06//'  :'
      else
        saux38(1:2) = ': '
        saux38(3:iaux+2) = appelo(1:jaux)
        do 312 , iaux = jaux+3 , 38
          saux38(iaux:iaux) = ' '
  312   continue
        saux38(38:38) = ':'
        write (ulsort,10002) texte(langue,4)(1:29)//'        :',
     >                       saux38//'  :'
      endif
c
      if ( raison.gt.0 ) then
        if ( nropas.eq.1 ) then
          write (ulsort,10001) texte(langue,6)
        else
          write (ulsort,10001) texte(langue,7)(1:29)//nompro//'  :'
        endif
      endif
c
      endif
c
      call dmflsh(iaux)
c
c====
c 4. arret de la gestion de la memoire, le cas echeant
c====
c
      if ( tabges(3).ne.0 .and. nropas.eq.1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GMSTOP', nompro
#endif
        call gmstop ( gmimp )
        call dmflsh(iaux)
      endif
c
c====
c 5. arret de la gestion des mesures de temps de calcul, le cas echeant
c====
c
      if ( tabges(2).ne.0 .and. nropas.eq.1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GTBILA', nompro
#endif
        call gtbila
        call dmflsh(iaux)
      endif
c
c====
c 6. arret de la gestion unites logiques, le cas echeant
c    . en mode debug, on respecte la decision d'impression.
c    . en mode optim, on n'imprime jamais.
c====
c
      if ( tabges(1).ne.0 .and. nropas.eq.1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GUBILA', nompro
#endif
#ifdef _DEBUG_HOMARD_
        iaux = guimp
#else
        iaux = 0
#endif
        call gubila ( iaux )
        call dmflsh(iaux)
      endif
c
c====
c 7. arret general de l'execution :
c      0 : normal
c     >0 : plantage
c     <0 : arret des gestionnaires, mais le programme continue
c====
c
      if ( raison.eq.0 ) then
        stop
      elseif ( raison.gt.0 ) then
        call dmabor
      else
        nropas = 0
      endif
c
      end
