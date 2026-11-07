      subroutine gtbila
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
c    'Gestion du Temps : BILAn de la mesure'
c     -          -       ----
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
      parameter ( nompro = 'GTBILA' )
c
#include "genbla.h"
#include "gtnbse.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
c 0.4. ==> variables locales
c
#include "gtdita.h"
c
      integer code
c
      double precision tuser, tsyst
c
      integer numan1, numan2
      integer nbsec1, nbsec2, nbseco, nbjour
      integer iheure, iminut, iseco
      integer iaux, ideb, ifin
      integer jaux
      integer ulsort, langue, imprgt
c
      double precision temps(3), tpmoy, tptota
      double precision xheure, xminut
      double precision daux
c
      character*7 blabla
      character*8 saux08(nblang,2)
c
      logical afaire, afair1
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. dernier appel du temps
c====
c
      call dmtemp ( tuser, tsyst )
c
c====
c 2. messages
c====
c
#include "impr01.h"
c
      texte(1,4) = '       Identification de la section      '
      texte(1,5) = '      Temps d''execution    '
      texte(1,6) = '           Nom            '
      texte(1,7) = ' Nro : Nombre '
      texte(1,8) = '    Total    :    Moyen    '
      texte(1,9) = '     : Appels '
      texte(1,10) = ' (secondes)  '
      texte(1,12) = 'Temps systeme total           '
      texte(1,13) = 'Temps de calcul total         '
      texte(1,14) = 'Temps total en machine        '
c
      texte(2,4) = '      Identification of the section      '
      texte(2,5) = '     Computational time    '
      texte(2,6) = '           Name           '
      texte(2,7) = '  #  : Number '
      texte(2,8) = '    Total    :   Average   '
      texte(2,9) = '     : Calls  '
      texte(2,10) = '  (seconds)  '
      texte(2,12) = 'Total system time             '
      texte(2,13) = 'Total calculation time        '
      texte(2,14) = 'Total time in computer        '
c
      saux08(1,1) = 'secondes'
      saux08(2,1) = 'seconds '
      saux08(1,2) = 'seconde '
      saux08(2,2) = 'second  '
c
c====
c 3. recuperation de l'information
c====
c
      code = 1
      iaux = nbsep1
      call gttabl ( code, iaux, nbrapp, ouvert, titsec, tpscpu )
c
      imprgt = nbrapp(-4)
      langue = nbrapp(-3)
      ulsort = nbrapp(0)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 4. fin des mesures
c    on ferme ce qui aurait pu rester ouvert.
c    dans une situation de fin normale, seule la section
c    globale, de numero nbsep1, est encore ouverte. toutes
c    les autres auraient du etre fermees au prealable.
c    cependant, en cas d'arret anticipe, des sections peuvent
c    ne pas avoir ete fermees. il vaut mieux le faire ici pour
c    avoir un affichage des temps qui soit realiste.
c====
c
      do 4 , iaux = 1 , nbsep1
        if ( ouvert (iaux) ) then
          tpscpu (iaux) = tpscpu (iaux) + tuser
          ouvert (iaux) = .false.
        endif
    4 continue
c
      tpscpu(0) = tpscpu(0) + tsyst
c
c====
c 5. impression eventuelle des temps de chaque section
c====
c
#ifdef _DEBUG_HOMARD_
      afaire = .true.
#else
      if ( mod(imprgt,2).eq.0 ) then
        afaire = .true.
      else
        afaire = .false.
      endif
#endif
c
      if ( afaire ) then
c
        do 5 , jaux = 1, 2
c
        write (ulsort,50000 )
c
        write (ulsort,50010) texte(langue,4)(1:41),
     >                       texte(langue,5)(1:27),
     >                       texte(langue,6)(1:26),
     >                       texte(langue,7)(1:14),
     >                       texte(langue,8)(1:27),
     >                       texte(langue,9)(1:14),
     >                       texte(langue,10)(1:13),
     >                       texte(langue,10)(1:13)
c
        do 51 , iaux = 1 , nbsect
c
          afair1 = .false.
          if ( nbrapp(iaux).gt.0 ) then
            if ( jaux.eq.1 ) then
              afair1 = .true.
            else
              if ( mod(iaux,10).eq.0 ) then
                afair1 = .true.
              endif
            endif
          endif
          if ( afair1 ) then
            daux = dble ( nbrapp (iaux) )
            tpmoy = tpscpu (iaux) / daux
            daux = 100.d0 * tpscpu (iaux) / tpscpu (nbsep1)
            write (ulsort,50020 ) titsec (langue,iaux), iaux,
     >                            nbrapp (iaux), tpscpu (iaux),
     >                            tpmoy, daux
          endif
c
   51   continue
c
        write (ulsort,50021 ) titsec (langue,nbsep1), tpscpu (nbsep1)
c
        write (ulsort,50030 )
c
    5   continue
c
      endif
c
50000 format(//)
50010 format( 79('.'),
     >/':',a41,        ':',4x,a27,4x,':',
     >/':',77('.'),':',
     >/':',a26,':',a14,':',a27,        ':   %   :',
     >/':',26x,':',a14,':',a13,':',a13,':',7x,':',
     >/':',77('.'),':')
50020 format(
     > ':',26x,':',5x,':',8x,':',13x,':',13x,':',7x,':',
     >/': ',a24,                 ' :',i4,' :',i7,' :'
     >   ,g12.5,' :',g12.5,' :',f6.1,' :')
50021 format(
     > ':',26x,':',5x,':',8x,':',13x,':',13x,':',7x,':',
     >/': ',a24,                 ' :',4x,' :',7x,' :'
     >   ,g12.5,' :',12x  ,' :',6x,' :')
50030 format(':',77('.'),':')
50040 format(79('.'))
c
c====
c 6. calcul du temps total :
c====
c
      if ( afaire ) then
c
c 6.1. ==> acquisition de la date actuelle et de depart
c
      call ugdhco ( numan2, nbsec2 )
c
      numan1 = nbrapp (-2)
      nbsec1 = nbrapp (-1)
c
c 6.2. ==> difference ; si l'on a change d'annee, on rajoute le nombre
c          de secondes de l'annee de depart.
c
      nbseco = nbsec2 - nbsec1
c
      if ( numan1.ne.numan2 ) then
        if ( mod(numan1,4) .eq. 0 ) then
          nbjour = 366
        else
          nbjour = 365
        endif
        nbseco = nbseco + 86400*nbjour
      endif
c
c le temps total en machine n'est, au mieux, evalue qu'a 1 seconde pres.
c
      tptota = dble ( max(0,nbseco) )
c
      endif
c
c====
c 7. archivage des temps de calcul, systeme, d'attente et total
c    si le temps systeme n'etait pas accessible sur la machine utilisee,
c    le contenu de tpscpu(0) est negatif. on l'ignore donc dans les
c    impressions recapitulatives.
c====
c
      if ( afaire ) then
c
      if ( tpscpu(0).ge.0.0d0 ) then
        temps (1) = tpscpu(0)
        ideb = 1
      else
        temps (1) = 0.0d0
        ideb = 2
      endif
      temps (2) = max(0.0d0, tpscpu (nbsep1) )
c
c petite correction du temps total en machine, pour les cas ou le
c temps total n'a pas pu etre evalue, et surtout les cas ou le temps
c total en machine est plus petit que 1 seconde ...
c ( meme remarque que ci-dessus, concernant le parallelisme et
c la comparaison de tptota avec temps(1)+temps(2) ).
c
      if ( tptota.le.0.0d0 ) then
        iseco = max(0, int(temps(1)+temps(2)) )
        if ( temps(1)+temps(2).ge.60.0d0 ) then
          tptota = dble(iseco)
        else if ( temps(1)+temps(2).gt.0.0d0 ) then
          tptota = temps(1)+temps(2)
        endif
        if ( temps(1)+temps(2)-tptota.gt.0.5d0 ) then
          tptota = tptota + 1.0d0
        endif
      endif
c
      temps (3) = tptota
c
c attention : en environnement multiprocesseur, tptota ne devrait pas
c etre compare directement a temps(1)+temps(2) (qui represente la
c somme des temps CPU consommes par les differents processeurs
c mobilises ==> attention aux eventuelles taches executees en
c parallele).
c
      endif
c
c====
c 8. conversion en heures, minutes et secondes des differents
c    temps globaux et impressions recapitulatives.
c====
c
      if ( afaire ) then
c
      if ( tptota.le.1.0d0 ) then
        ifin = 2
      else
        ifin = 3
      endif
c
      do 80 , iaux = ideb , ifin
c
        if ( iaux.eq.3 ) then
          write (ulsort,50040 )
        endif
        write (ulsort,80000 )
c
        if ( temps(iaux).ge.3600.d0 ) then
c
          xheure = temps(iaux) / 3600.d0
          iheure = max(1, int ( xheure ) )
          xheure = dble ( iheure )
          temps(iaux) = max(0.0d0, temps(iaux) - 3600.d0*xheure )
c
          xminut = temps(iaux) / 60.d0
          iminut = int ( xminut )
          xminut = dble ( iminut )
          temps(iaux) = max(0.0d0, temps(iaux) - 60.d0*xminut )
          iseco = int ( temps(iaux) )
          if ( temps(iaux)-dble(iseco).gt.0.5d0 ) then
            iseco = iseco + 1
          endif
          if ( iseco.ge.60 ) then
            iseco = iseco - 60
            iminut = iminut + 1
          endif
          if ( iminut.ge.60 ) then
            iminut = iminut - 60
            iheure = iheure + 1
          endif
c
          if ( iheure.le.1 ) then
            if (langue.ne.2) then
              blabla = ' heure '
            else
              blabla = ' hour  '
            endif
          else
            if (langue.ne.2) then
              blabla = ' heures'
            else
              blabla = ' hours '
            endif
          endif
c
          if (iminut.gt.1) then
          write (ulsort,81010) texte(langue,11+iaux)(1:30),
     >                         iheure , blabla , iminut , iseco
          else
          write (ulsort,81011) texte(langue,11+iaux)(1:30),
     >                         iheure , blabla , iminut , iseco
          endif
c
        else
c
          if ( temps(iaux).ge.60.d0 ) then
c
            xminut = temps(iaux) / 60.d0
            iminut = max(1, int ( xminut ) )
            xminut = dble ( iminut )
            temps(iaux) = max(0.0d0, temps(iaux) - 60.d0*xminut )
            iseco = int ( temps(iaux) )
            if ( temps(iaux)-dble(iseco).gt.0.5d0 ) then
              iseco = iseco + 1
            endif
            if ( iseco.ge.60 ) then
              iseco = iseco - 60
              iminut = iminut + 1
            endif
c
            if ( iminut.le.1 ) then
              blabla = 'minute '
            else
              blabla = 'minutes'
            endif
c
            if ( iseco.gt.1 ) then
              write (ulsort,81020) texte(langue,11+iaux)(1:30), iminut,
     >                             blabla, iseco, saux08(langue,1)
            else
              write (ulsort,81020) texte(langue,11+iaux)(1:30), iminut,
     >                             blabla, iseco, saux08(langue,2)
            endif
c
          else
c
            if ( iaux.le.2 ) then
              write (ulsort,81030) texte(langue,11+iaux)(1:30),
     >                             temps(iaux), saux08(langue,1)
            elseif ( nbseco.gt.1 ) then
              write (ulsort,81031) texte(langue,11+iaux)(1:30),
     >                             nbseco, saux08(langue,1)
            else
              write (ulsort,81031) texte(langue,11+iaux)(1:30),
     >                             max(nbseco,1), saux08(langue,2)
            endif
c
          endif
c
        endif
c
        write (ulsort,80010 )
c
   80 continue
c
      endif
c
80000 format(':',41x,':',35x,':')
80010 format(':',41x,':',35x,':',
     >     /,':',77('.'),':')
c
81010 format (
     >        ': ',a30,10x,':',i3,a7,i3,' minutes',i3,' s         :')
81011 format (
     >        ': ',a30,10x,':',i3,a7,i3,' minute ',i3,' s         :')
c
81020 format (
     >        ': ',a30,10x,': ',i3,' ',a7,i3,' ',a8,11x,':')
c
81030 format( ': ',a30,10x,':   ',g12.5,' ',a8,11x,':')
81031 format( ': ',a30,10x,':',12x,i3,' ',a8,11x,':')
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
