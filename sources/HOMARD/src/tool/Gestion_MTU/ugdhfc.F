      subroutine ugdhfc ( datheu, numann,
     >                    datefr, heurfr,
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
c     convertit la date et l'heure
c     de la forme Francaise en une forme compacte
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . datheu .  s  .   1    . nombre de seconde depuis le debut de l'an  .
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
cgn      write(*,*) 'Dans UGDHFC, datefr = ', datefr
cgn      write(*,*) 'Dans UGDHFC, heurfr = ', heurfr
      read ( datefr (1:2),'(i2)' ) numjou
      read ( datefr (4:5),'(i2)' ) nummoi
      read ( datefr (7:8),'(i2)' ) numann
      if ( numann.lt.70 ) then
         numann = 2000 + numann
      else
         numann = 1900 + numann
      endif
c
      read ( heurfr (1:2),'(i2)' ) numheu
      read ( heurfr (4:5),'(i2)' ) nummin
      read ( heurfr (7:8),'(i2)' ) numsec
c
c====
c 2. appel du programme generique
c====
c
      if ( codret.eq.0 ) then
c
         call ugdhlc ( datheu, numann,
     >                 nummoi, numjou, numheu, nummin, numsec,
     >                 codret )
c
      endif
c
      end
