      subroutine dmjohe ( numann, nummoi, numjou, numjos,
     >                    numheu, nummin, numsec )
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
c   Dependance Machine : JOur et HEure
c   -          -         --      --
c ______________________________________________________________________
c
c
c  retourne la date et l'heure
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numann .  s  .   1    . numero de l'annee                          .
c . nummoi .  s  .   1    . numero du mois                             .
c . numjou .  s  .   1    . numero du jour (1-->31)                    .
c . numjos .  s  .   1    . numero du jour symbolique (0-->7)          .
c .        .     .        . 0 : rien n'est fourni par la machine       .
c .        .     .        . 1-->7 : numero du jour dans la semaine     .
c . numheu .  s  .   1    . numero de l'heure                          .
c . nummin .  s  .   1    . numero des minutes                         .
c . numsec .  s  .   1    . numero des secondes                        .
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
cgn      character*6 nompro
cgn      parameter ( nompro = 'DMJOHE' )
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer numann, nummoi, numjou, numjos
      integer numheu, nummin, numsec
c
c 0.4. ==> variables locales
c
      integer iaux
c
      character*24 tampon
      character*8 chjour, heurus
      character*4 nomann
      character*3 tabday (7)
      character*3 tabmon (12)
      character*3 nomjou, nommoi
c
c====
c 1. les constantes
c====
c 1.1. ==> nom des jours
c
      tabday (1) = 'Mon'
      tabday (2) = 'Tue'
      tabday (3) = 'Wed'
      tabday (4) = 'Thu'
      tabday (5) = 'Fri'
      tabday (6) = 'Sat'
      tabday (7) = 'Sun'
c
c 1.2. ==> nom des mois
c
      tabmon (1) = 'Jan'
      tabmon (2) = 'Feb'
      tabmon (3) = 'Mar'
      tabmon (4) = 'Apr'
      tabmon (5) = 'May'
      tabmon (6) = 'Jun'
      tabmon (7) = 'Jul'
      tabmon (8) = 'Aug'
      tabmon (9) = 'Sep'
      tabmon (10) = 'Oct'
      tabmon (11) = 'Nov'
      tabmon (12) = 'Dec'
c
c====
c 2.  determination de la date et de l'heure de passage du calcul
c====
c
      chjour = '07/19/94'
      heurus = '09:42:23'
      tampon = 'Thu Jul 19  9:42:23 1994'
      nomann = '1994'
c
c sur machine UNIX ou WINDOWS de base
c       1234567890123456789012345678
c      'day mon dd hh:mm:ss yyyy'
c ex : 'Thu Jul 19  9:42:23 1994'
c====
c
c 2.1. ==> appel a la fonction machine
c
      call dmdate ( tampon )
c
c 2.2. ==> archivage sous forme standard
c
      nomann = tampon(21:24)
      nommoi = tampon(5:7)
      nomjou = tampon(1:3)
      chjour(4:5) = tampon(9:10)
c
      heurus = tampon(12:19)
c
c====
c 3. decodage commun a toutes les machines
c====
c
      if ( index('0123456789',nomann(3:3)).gt.0 .and.
     >     index('0123456789',nomann(4:4)).gt.0       ) then
c
        read ( nomann(3:4) , fmt='(i2)' ) numann
c
        if (nomann(1:2).eq.'19') then
          numann = numann + 1900
        else
          numann = numann + 2000
        endif
      else
        numann = 1970
      endif
c
      if ( chjour(4:4).eq.' ' ) then
        chjour(4:4) = '0'
      endif
      if ( index('0123',chjour(4:4)).gt.0 .and.
     >     index('0123456789',chjour(5:5)).gt.0       ) then
c
        read ( chjour(4:5) , fmt='(i2)' ) numjou
c
        if ( numjou.le.0 .or. numjou.gt.31 ) then
          numjou = 1
        endif
      else if ( chjour(5:5).eq.' ' .and.
     >      index('123456789',chjour(4:4)).gt.0       ) then
c
        read ( chjour(4:4) , fmt='(i1)' ) numjou
c
      else
        numjou = 1
      endif
c
c apres la date, on s'occupe maintenant de l'heure :
c
      if ( heurus(1:1).eq.' ' ) then
        heurus(1:1) = '0'
      endif
      if ( index('012',heurus(1:1)).gt.0        .and.
     >     index('0123456789',heurus(2:2)).gt.0       ) then
c
        read ( heurus(1:2),fmt='(i2)' ) numheu
c
        if (numheu.gt.23) then
          numheu = 0
        endif
c
      else if ( heurus(2:2).eq.' '        .and.
     >     index('0123456789',heurus(1:1)).gt.0       ) then
c
        read ( heurus(1:1),fmt='(i1)' ) numheu
c
      else
c
        numheu = 0
c
      endif
c
      if ( index(' 012345',heurus(4:4)).gt.0 .and.
     >     index('0123456789',heurus(5:5)).gt.0       ) then
c
        read ( heurus(4:5),fmt='(i2)' ) nummin
c
        if (nummin.gt.59) then
          nummin = 0
        endif
c
      else if ( heurus(5:5).eq.' ' .and.
     >     index('0123456789',heurus(4:4)).gt.0       ) then
c
        read ( heurus(4:4),fmt='(i1)' ) nummin
c
      else
c
        nummin = 0
c
      endif
c
      if ( index(' 012345',heurus(7:7)).gt.0 .and.
     >     index('0123456789',heurus(8:8)).gt.0       ) then
c
        read ( heurus(7:8),fmt='(i2)' ) numsec
c
        if (numsec.gt.59) then
          numsec = 0
        endif
c
      else if ( heurus(8:8).eq.' ' .and.
     >     index('0123456789',heurus(7:7)).gt.0       ) then
c
        read ( heurus(7:7),fmt='(i1)' ) numsec
c
      else
c
        numsec = 0
c
      endif
c
c====
c 4. decodages specifiques
c    . nummoi = numero du mois
c    . numjos = numero du jour dans la semaine
c====
c
      nummoi = 0
      do 41 , iaux = 1 , 12
        if ( nommoi .eq. tabmon(iaux) ) then
          nummoi = iaux
        endif
   41 continue
c
      numjos = 0
      do 42 , iaux = 1 , 7
        if ( nomjou .eq. tabday(iaux) ) then
          numjos = iaux
        endif
   42 continue
c
      if (numjou.gt.28 .and. nummoi.gt.1) then
        if (nummoi.eq.2 .and. mod(numann,4).ne.0) then
          nummoi = 0
        else if (nummoi.eq.2 .and. mod(numann,4).eq.0) then
          if (numjou.gt.29) then
            nummoi = 0
          endif
        else if (nummoi.eq.4 .or. nummoi.eq.6) then
          if (numjou.gt.30) then
            nummoi = 0
          endif
        else if (nummoi.eq.9 .or. nummoi.eq.11) then
          if (numjou.gt.30) then
            nummoi = 0
          endif
        endif
      endif
c
      end
