      subroutine utdhlg ( ladate, langue )
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
c  donne la date et l'heure sous forme longue
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ladate .  s  .   1    . date et heure sous forme longue            .
c . langue .  s  .   1    . langue retenue                             .
c .        .     .        . 1 : francais, 2 : anglais                  .
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
#include "nblang.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer langue
c
      character*48 ladate
c
c 0.4. ==> variables locales
c
      integer numann, nummoi, numjou, numjos
      integer numheu, nummin, numsec
c
      integer ideb, ifin
      integer langlo
c
c 0.5. ==> initialisations
c
#include "utjomo.h"
c
c_______________________________________________________________________c
c====
c 1.  acquisition de la date
c====
c
      call dmjohe ( numann, nummoi, numjou, numjos,
     >              numheu, nummin, numsec )
c
c====
c 2. mise en forme
c====
c
c 2.1. ==> initialisation
c
c               123456789012345678901234567890123456789012345678
      ladate = '                                                '
c
      if ( langue.ge.1 .and. langue.le.nblang ) then
        langlo = langue
      else
        langlo = 1
      endif
c
c 2.2. ==> nom et numero du jour
c
      if ( numjos.le.0 ) then
        ifin = -1
      else
        ifin = lgnomj(langlo,numjos)
        ladate (1:ifin) = nomjou(langlo,numjos)
      endif
c
      ideb = ifin+2
      if ( numjou.le.9 ) then
        ifin = ideb
        write ( ladate (ideb:ifin),'(i1)' ) numjou
      else
        ifin = ideb + 1
        write ( ladate (ideb:ifin),'(i2)' ) numjou
      endif
c
c 2.3. ==> nom du mois
c
      if (nummoi.gt.0) then
        ideb = ifin + 2
        ifin = ideb + lgnomm(langlo,mod(nummoi-1,12)+1) - 1
        ladate (ideb:ifin) = nommoi(langlo,mod(nummoi-1,12)+1)
      endif
c
c 2.4. ==> numero de l'annee
c
      ideb = ifin + 2
      ifin = ideb + 3
      write ( ladate (ideb:ifin),'(i4)' ) numann
c
c 2.5. ==> heure
c
      ideb = ifin + 2
      if ( langlo.eq.1 ) then
        ifin = ideb + 1
        ladate (ideb:ifin) = 'a '
      else
        ifin = ideb + 2
        ladate (ideb:ifin) = 'at '
      endif
c
      ideb = ifin + 1
      if ( numheu.le.9 ) then
        ifin = ideb
        write ( ladate (ideb:ifin),'(i1)' ) numheu
      else
        ifin = ideb + 1
        write ( ladate (ideb:ifin),'(i2)' ) numheu
      endif
c
      ideb = ifin + 1
      ifin = ideb + 2
      ladate (ideb:ifin) = ' h '
c
      ideb = ifin + 1
      if ( nummin.le.9 ) then
        ifin = ideb
        write ( ladate (ideb:ifin),'(i1)' ) nummin
      else
        ifin = ideb + 1
        write ( ladate (ideb:ifin),'(i2)' ) nummin
      endif
c
      ideb = ifin + 1
      ifin = ideb + 3
      ladate (ideb:ifin) = ' mn '
c
      ideb = ifin + 1
      if ( numsec.le.9 ) then
        ifin = ideb
        write ( ladate (ideb:ifin),'(i1)' ) numsec
      else
        ifin = ideb + 1
        write ( ladate (ideb:ifin),'(i2)' ) numsec
      endif
c
      ideb = ifin + 1
      ifin = ideb + 1
      ladate (ideb:ifin) = ' s'
c
      end
