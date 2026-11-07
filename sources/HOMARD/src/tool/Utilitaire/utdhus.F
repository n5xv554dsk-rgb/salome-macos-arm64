      subroutine utdhus ( dateus, heurus )
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
c  donne la date et l'heure sous forme americaine
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . dateus .  s  .  ch9   . date au format americain 'dd-mon-yy'       .
c . heurus .  s  .  ch8   . heure au format americain 'hh:mm:ss'       .
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
      character*9 dateus
      character*8 heurus
c
c 0.4. ==> variables locales
c
      integer numann, nummoi, numjou, numjos
      integer numheu, nummin, numsec
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
c 2.  acquisition de la date
c====
c
      call dmjohe ( numann, nummoi, numjou, numjos,
     >              numheu, nummin, numsec )
c
c====
c 3. mise en forme
c====
c
c 3.1. ==> initialisation
c
      dateus = '0d-Mon-0y'
      heurus = '0h:0m:0s'
c
c 3.2. ==> date
c
      if ( numjou.le.9 ) then
         write ( dateus (2:2),'(i1)' ) numjou
      else
         write ( dateus (1:2),'(i2)' ) numjou
      endif
c
      dateus (4:6) = tabmon(abs(mod(nummoi-1,12))+1)
c
      numann = mod ( numann , 100 )
      if ( numann.le.9 ) then
         write ( dateus (9:9),'(i1)' ) numann
      else
         write ( dateus (8:9),'(i2)' ) numann
      endif
c
c 3.3. ==> heure
c
      if ( numheu.le.9 ) then
         write ( heurus (2:2),'(i1)' ) numheu
      else
         write ( heurus (1:2),'(i2)' ) numheu
      endif
c
      if ( nummin.le.9 ) then
         write ( heurus (5:5),'(i1)' ) nummin
      else
         write ( heurus (4:5),'(i2)' ) nummin
      endif
c
      if ( numsec.le.9 ) then
         write ( heurus (8:8),'(i1)' ) numsec
      else
         write ( heurus (7:8),'(i2)' ) numsec
      endif
c
      end
