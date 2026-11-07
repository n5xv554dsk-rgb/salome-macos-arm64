      subroutine utdhfc ( datheu, numann,
     >                    datefr, heurfr,
     >                    codret )
c
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
c     convertit la date et l'heure
c     de la forme Francaise en une forme compacte
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . datheu .  s  .   1    . nombre de secondeS depuis le debut de l'an .
c . numann .  s  .   1    . numero de l'annee (complet)                .
c . datefr . e   .  ch8   . date au format francais 'jj/mm/aa'         .
c . heurfr . e   .  ch8   . heure au format francais 'hh:mm:ss'        .
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
      character*8 datefr
      character*8 heurfr
c
c 0.4. ==> variables locales
c
      integer nummoi, numjou, numheu, nummin, numsec
c
c====
c 1. determination des differents numeros
c    remarque : on suppose que l'on ne prendra pas des objets
c               anterieurs a 1970 et qu'apres 2070, on aura recode ...
c====
c
      if ( index('123',datefr(1:1)).gt.0 .and.
     >     index('0123456789',datefr(2:2)).gt.0       ) then
c
        read ( datefr (1:2),'(i2)' ) numjou
c
        if ( numjou.gt.31 ) then
          numjou = 1
          codret = 1
        endif
c
      else if ( index(' 0',datefr(1:1)).gt.0 .and.
     >          index('123456789',datefr(2:2)).gt.0       ) then
c
        read ( datefr (2:2),'(i1)' ) numjou
c
      else if ( datefr(2:2).eq.' ' .and.
     >          index('123456789',datefr(1:1)).gt.0       ) then
c
        read ( datefr (1:1),'(i1)' ) numjou
c
      else
        numjou = 1
        codret = 1
      endif
c
      if ( index(' 01',datefr(4:4)).gt.0 .and.
     >     index('0123456789',datefr(5:5)).gt.0       ) then
c
        read ( datefr (4:5),'(i2)' ) nummoi
c
        if ( nummoi.le.0 .or. nummoi.gt.12 ) then
          nummoi = 1
          codret = 1
        endif
c
      else if ( datefr(5:5).eq.' ' .and.
     >     index('123456789',datefr(4:4)).gt.0       ) then
c
        read ( datefr (4:4),'(i1)' ) nummoi
c
      else
        nummoi = 1
        codret = 1
      endif
c
      if ( index('0123456789',datefr(7:7)).gt.0 .and.
     >     index('0123456789',datefr(8:8)).gt.0       ) then
c
        read ( datefr (7:8),'(i2)' ) numann
        if ( numann.lt.70 ) then
           numann = 2000 + numann
        else
           numann = 1900 + numann
        endif
c
      else
        numann = 1970
        codret = 1
      endif
c
c apres la date, on s'occupe maintenant de l'heure :
c
      if ( index(' 012',heurfr(1:1)).gt.0        .and.
     >     index('0123456789',heurfr(2:2)).gt.0       ) then
c
        read ( heurfr (1:2),'(i2)' ) numheu
c
        if (numheu.gt.23) then
          numheu = 0
          codret = 1
        endif
c
      else if ( heurfr(2:2).eq.' '        .and.
     >     index('0123456789',heurfr(1:1)).gt.0       ) then
c
        read ( heurfr (1:1),'(i1)' ) numheu
c
      else
c
        numheu = 0
        codret = 1
c
      endif
c
      if ( index(' 012345',heurfr(4:4)).gt.0 .and.
     >     index('0123456789',heurfr(5:5)).gt.0       ) then
c
        read ( heurfr (4:5),'(i2)' ) nummin
c
        if (nummin.gt.59) then
          nummin = 0
          codret = 1
        endif
c
      else if ( heurfr(5:5).eq.' ' .and.
     >     index('0123456789',heurfr(4:4)).gt.0       ) then
c
        read ( heurfr (4:4),'(i1)' ) nummin
c
      else
c
        nummin = 0
        codret = 1
c
      endif
c
      if ( index(' 012345',heurfr(7:7)).gt.0 .and.
     >     index('0123456789',heurfr(8:8)).gt.0       ) then
c
        read ( heurfr (7:8),'(i2)' ) numsec
c
        if (numsec.gt.59) then
          numsec = 0
          codret = 1
        endif
c
      else if ( heurfr(8:8).eq.' ' .and.
     >     index('0123456789',heurfr(7:7)).gt.0       ) then
c
        read ( heurfr (7:7),'(i1)' ) numsec
c
        if (numsec.gt.59) then
          numsec = 0
          codret = 1
        endif
c
      else
c
        numsec = 0
        codret = 1
c
      endif
c
c====
c 2. appel du programme generique
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
