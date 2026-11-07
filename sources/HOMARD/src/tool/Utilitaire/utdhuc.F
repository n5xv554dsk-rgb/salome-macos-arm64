      subroutine utdhuc ( datheu, numann,
     >                    dateus, heurus,
     >                    codret )
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
c convertit la date et l'heure d'une forme US en une forme compacte
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . datheu .  s  .   1    . nombre de secondes depuis le debut de l'an .
c . numann .  s  .   1    . numero de l'annee (complet: exemple 1996)  .
c . dateus . e   .  ch9   . date au format americain 'dd-mon-yy'       .
c . heurus . e   .  ch8   . heure au format americain 'hh:mm:ss'       .
c . codret .  s  .   1    . code de retour                             .
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
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer datheu, numann
      integer codret
c
      character*9 dateus
      character*8 heurus
c
c 0.4. ==> variables locales
c
      integer nummoi, numjou, numheu, nummin, numsec
      integer iaux
c
      character*3 tabmon (12)
c
c====
c 1. les constantes
c====
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
c 2. determination des differents numeros
c    remarque : on suppose que l'on ne prendra pas des maillages
c               anterieurs a 1970 et qu'apres 2070, on aura recode ...
c====
c
c  2.1 la date :
c
      if ( index('0123456789',dateus(8:8)).gt.0 .and.
     >     index('0123456789',dateus(9:9)).gt.0       ) then
c
        read ( dateus (8:9),'(i2)' ) numann
        if ( numann.lt.70 ) then
           numann = 2000 + numann
        else
           numann = 1900 + numann
        endif
c
        codret = 0
c
      else
c
        numann = 1970
        codret = 1
c
      endif
c
      do 21 iaux  = 1 , 12
         if ( dateus (4:6).eq.tabmon(iaux) ) then
            nummoi = iaux
            goto 22
         endif
   21 continue
      nummoi = 1
      codret = 1
c
   22 continue
c
      if ( index(' 0123',dateus(1:1)).gt.0 .and.
     >     index('0123456789',dateus(2:2)).gt.0       ) then
c
        read ( dateus (1:2),'(i2)' ) numjou
c
        if ( numjou.le.0 .or. numjou.gt.31 ) then
          numjou = 1
          codret = 1
        endif
c
      else if ( dateus(2:2).eq.' ' .and.
     >     index('123456789',dateus(1:1)).gt.0       ) then
c
        read ( dateus (1:1),'(i1)' ) numjou
c
      else
c
        numjou = 1
        codret = 1
c
      endif
c
c ----------------------
c
c   2.2 l'heure :
c
      if ( index(' 012',heurus(1:1)).gt.0        .and.
     >     index('0123456789',heurus(2:2)).gt.0       ) then
c
        read ( heurus (1:2),'(i2)' ) numheu
c
        if (numheu.gt.23) then
          numheu = 0
          codret = 1
        endif
c
      else if ( heurus(2:2).eq.' '        .and.
     >     index('0123456789',heurus(1:1)).gt.0       ) then
c
        read ( heurus (1:1),'(i1)' ) numheu
c
      else
c
        numheu = 0
        codret = 1
c
      endif
c
      if ( index(' 012345',heurus(4:4)).gt.0 .and.
     >     index('0123456789',heurus(5:5)).gt.0       ) then
c
        read ( heurus (4:5),'(i2)' ) nummin
c
        if (nummin.gt.59) then
          nummin = 0
          codret = 1
        endif
c
      else if ( heurus(5:5).eq.' ' .and.
     >     index('0123456789',heurus(4:4)).gt.0       ) then
c
        read ( heurus (4:4),'(i1)' ) nummin
c
      else
c
        nummin = 0
        codret = 1
c
      endif
c
      if ( index(' 012345',heurus(7:7)).gt.0 .and.
     >     index('0123456789',heurus(8:8)).gt.0       ) then
c
        read ( heurus (7:8),'(i2)' ) numsec
c
        if (numsec.gt.59) then
          numsec = 0
          codret = 1
        endif
c
      else if ( heurus(8:8).eq.' ' .and.
     >     index('0123456789',heurus(7:7)).gt.0       ) then
c
        read ( heurus (7:7),'(i1)' ) numsec
c
      else
c
        numsec = 0
        codret = 1
c
      endif
c
c====
c 3. appel du programme generique
c====
c
      if ( codret.eq.0 ) then
c
         call utdhlc ( datheu, numann,
     >                 nummoi, numjou, numheu, nummin, numsec,
     >                 codret )
c
      else
c
        datheu = 0
c
      endif
c
      end
