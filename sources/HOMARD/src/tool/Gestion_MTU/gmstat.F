      subroutine gmstat ( gmimp )
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
c       fonction impression des statistiques du gestionnaire de memoire
c_______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . gmimp  . e   .    1   . Pour le mode dynamique :                   .
c .        .     .        . 0 => pas d'impression                      .
c .        .     .        . 1 => impression                            .
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
      parameter ( nompro = 'GMSTAT' )
c
#include "genbla.h"
c
#include "gmmatc.h"
c
#include "gmmaxt.h"
c
c 0.2. ==> communs
c
#include "gmtori.h"
#include "gmtoai.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "gmtrrl.h"
#include "gmtren.h"
#include "gmtrst.h"
c
#include "gmimpr.h"
#include "gmlang.h"
#include "gmopim.h"
#include "gmtail.h"
#include "gmtyge.h"
c
c 0.3. ==> arguments
c
      integer gmimp
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer ltypei, ltyper, ltypes
      integer ecrire
c
      character*2 saux02
      character*16 typtab(nblang,4)
c
      double precision daux
c
      integer nbmess
      parameter ( nbmess = 15 )
      character*80 texte(nblang,nbmess)
c
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
cgn         print *,'dans gmstat, gmimp = ', gmimp
c
c====
c 1. Niveau d'impression
c====
c
#ifdef _DEBUG_HOMARD_
      ecrire = 1
#else
      if ( modgm.eq.2 ) then
        if ( mod(imprgm,5).eq.0 ) then
          ecrire = 1
        else
          ecrire = 0
        endif
      else
        ecrire = 1
      endif
#endif
c
      if ( ecrire.ge.1 ) then
      write (ulsort,10000)
      endif
c
10000 format (//)
c
cgn        print *,'dans gmstat, ecrire = ', ecrire
c
c====
c 2. statistiques concernant les objets structures
c====
c
      if ( ecrire.ge.1 ) then
c
      texte(1,4) = '(15x,'':       Gestion de la memoire        :'')'
      texte(1,5) = '(5x,''Nombre de types de structure        : '',i14)'
      texte(1,6) =
     > '(5x,''Nombre d''''objets structures presents : '',i14)'
c
      texte(2,4) = '(15x,'':           Memory management        :'')'
      texte(2,5) =
     >        '(5x,''Number of types of structures         : '',i14)'
      texte(2,6) =
     > '(5x,''Number of present structured objects  : '',i14)'
c
10001 format (/,
     > /,15x,'......................................',
     > /,15x,':                                    :')
10002 format (
     >   15x,':                                    :',
     > /,15x,':....................................:',//)
c
      write (ulsort,10001)
      write (ulsort,texte(langue,4))
      write (ulsort,10002)
      write (ulsort,texte(langue,5)) nbrtyp
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) iptobj-1
#endif
c
      endif
c
c====
c 2. statistiques concernant les tableaux dynamiques
c====
c
      texte(1,4) = '(/,''La gestion de la memoire est statique.'')'
      texte(1,5) ='(/,''La gestion de la memoire est semi-dynamique.'')'
      texte(1,6) = '(/,''La gestion de la memoire est dynamique.'')'
      texte(1,7) = '(/,''1 mot = '',i2,'' octets'')'
      texte(1,8) = '(/,''1 mot = 1 octet'')'
c
      texte(2,4) = '(/,''A static memory management is used.'')'
      texte(2,5) = '(/,''A semi-dynamic memory management is used.'')'
      texte(2,6) = '(/,''A dynamic memory management is used.'')'
      texte(2,7) = '(/,''1 word = '',i2,'' bytes'')'
      texte(2,8) = '(/,''1 word = 1 byte'')'
c
50010 format(
     >/,90('.'),
     >/': ',a16,14x,': ',a16,' : ',a16,' : ',a16,' :',
     >/':',88('.'),':')
50011 format(
     >/,71('.'),
     >/': ',a16,14x,': ',a16,' : ',a16,' :',
     >/':',69('.'),':')
50020 format(
     > ': ',a16,14x,': ',i16,' : ',i16,' : ',i16,' :')
50021 format(
     > ': ',a16,14x,': ',i16,' : ',i16,' :')
50030 format(
     >  90('.'),
     >/': ',2a16,36x,':',6x,f8.2,1x,a2,' :',
     >/':',88('.'),':')
50031 format(
     >  71('.'),
     >/': ',2a16,17x,':',6x,f8.2,1x,a2,' :',
     >/':',69('.'),':')
50040 format(
     >/,'1 entier = ',i2,' octets,',
     >/,'1 reel =',i2,' octets,',
     >/,'1 character*8 =',i2,' octets')
50041 format(
     >/,'1 integer = ',i2,' bytes,',
     >/,'1 real =',i2,' bytes,',
     >/,'1 character*8 =',i2,' bytes')
50090 format(90('.'))
50091 format(71('.'))
c
c 2.1. ==> Mode de gestion de la memoire
c
      if ( ecrire.ge.1 ) then
c
        write (ulsort,texte(langue,modgm+4))
c
      endif
c
c 2.2. ==> En-tete
c
      if ( ecrire.ge.1 ) then
c
c                      1234567890123456
        typtab(1,1) = 'Type de tableau '
        typtab(1,2) = 'Nombre demande  '
        typtab(1,3) = 'Nombre totalise '
        typtab(1,4) = 'Nombre utilise  '
        typtab(2,1) = ' Type of array  '
        typtab(2,2) = '  Asked number  '
        typtab(2,3) = '  Total number  '
        typtab(2,4) = '  Used number   '
c
        if ( modgm.le.1 ) then
          write (ulsort,50010) (typtab(langue,iaux),iaux=1,4)
        else
          write (ulsort,50011) (typtab(langue,iaux),iaux=1,3)
        endif
c
      endif
c
c 2.3. ==> Par type
c
c                    1234567890123456
      typtab(1,1) = 'Entier          '
      typtab(1,2) = 'Reel            '
      typtab(1,3) = 'Caracteres*8    '
      typtab(2,1) = 'Integer         '
      typtab(2,2) = 'Real            '
      typtab(2,3) = 'Character*8     '
c
      if ( modgm.le.1 ) then
c
        minlei = min(minmei,minlei)
        minler = min(minmer,minler)
        minles = min(minmes,minles)
c
      else
c
c en mode dynamique (modgm=2), les quantites minmex memorisent a tout
c instant l'ecart entre la taille max allouee precedemment (dans le type
c x concerne) et la taille couramment allouee. Typiquement,
c a la fin d'une execution ou tout a ete proprement desalloue,
c on doit avoir imem(1) = minmei ...
c
        minlei = max(minmei,0)
        minler = max(minmer,0)
        minles = max(minmes,0)
c
      endif
c
      kaux = 0
c
#ifdef _DEBUG_HOMARD_
      jaux = -1
#else
      jaux = 0
#endif
c
      iaux = imem(1)
      ltypei = tentie
      if ( iaux.gt.jaux ) then
        if ( modgm.le.1 ) then
          kaux = kaux + (iaux-minlei)*ltypei
        else
          kaux = kaux + iaux*ltypei
        endif
        if ( ecrire.ge.1 ) then
          if ( modgm.le.1 ) then
            write (ulsort,50020) typtab(langue,1), iaux, totali,
     >                           iaux-minlei
          else
            write (ulsort,50021) typtab(langue,1), iaux, totali
          endif
        endif
      endif
c
      iaux = int(rmem(1))
      ltyper = treel
      if ( iaux.gt.jaux ) then
        if ( modgm.le.1 ) then
          kaux = kaux + (iaux-minler)*ltyper
        else
          kaux = kaux + iaux*ltyper
        endif
        if ( ecrire.ge.1 ) then
          if ( modgm.le.1 ) then
            write (ulsort,50020) typtab(langue,2), iaux, totalr,
     >                           iaux-minler
          else
            write (ulsort,50021) typtab(langue,2), iaux, totalr
          endif
        endif
      endif
c
      if (index(smem(1),'*').le.0) then
        read(smem(1),'(i8)') iaux
      else
        iaux = 99999999 + minles
      endif
      ltypes = tchain
      if ( iaux.gt.jaux ) then
        if ( modgm.le.1 ) then
          kaux = kaux + (iaux-minles)*ltypes
        else
          kaux = kaux + iaux*ltypes
        endif
        if ( ecrire.ge.1 ) then
          if ( modgm.le.1 ) then
            write (ulsort,50020) typtab(langue,3), iaux, totals,
     >                           iaux-minles
          else
            write (ulsort,50021) typtab(langue,3), iaux, totals
          endif
        endif
      endif
c
      if ( ecrire.ge.11 ) then
c
        if ( modgm.le.1 ) then
          write (ulsort,50090)
        else
          write (ulsort,50091)
        endif
c
      endif
c
c 2.3. ==> Bilan
c
      if ( ecrire.ge.1 ) then
c
c                    1234567890123456
      typtab(1,1) = 'Memoire totale u'
      typtab(1,2) = 'tilisee         '
c
      typtab(2,1) = 'Total used memor'
      typtab(2,2) = 'y               '
c
      if ( kaux.ge.1000000000 ) then
        daux = dble(kaux) / 1000000000.d0
        saux02 = 'Go'
      elseif ( kaux.ge.1000000 ) then
        daux = dble(kaux) / 1000000.d0
        saux02 = 'Mo'
      elseif ( kaux.ge.1000 ) then
        daux = dble(kaux) / 1000.d0
        saux02 = 'ko'
      else
        daux = dble(kaux)
        saux02 = 'o '
      endif
      if ( modgm.le.1 ) then
        write (ulsort,50030) typtab(langue,1), typtab(langue,2),
     >                       daux, saux02
      else
        write (ulsort,50031) typtab(langue,1), typtab(langue,2),
     >                       daux, saux02
      endif
c
#ifdef _DEBUG_HOMARD_
c
        write (ulsort,texte(langue,8))
c
        if ( langue.eq.1 ) then
c
          write (ulsort,50040) ltypei, ltyper, ltypes
c
        else
c
          write (ulsort,50041) ltypei, ltyper, ltypes
c
        endif
#endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
