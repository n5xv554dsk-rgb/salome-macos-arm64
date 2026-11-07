      subroutine ugdhco ( numann, datheu )
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
c  donne la date et l'heure sous forme courte
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numann .  s  .   1    . numero de l'annee                          .
c . datheu .  s  .   1    . nombre de secondes depuis le debut de l'an .
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
      integer numann, datheu
c
c 0.4. ==> variables locales
c
      integer nummoi, numjou, numjos
      integer numheu, nummin, numsec
      integer nbjour
      integer iaux, naux
c
      integer lonmoi (12)
c
c====
c 1.  initialisation
c====
c
      lonmoi (1) = 31
      lonmoi (2) = 28
      lonmoi (3) = 31
      lonmoi (4) = 30
      lonmoi (5) = 31
      lonmoi (6) = 30
      lonmoi (7) = 31
      lonmoi (8) = 31
      lonmoi (9) = 30
      lonmoi (10) = 31
      lonmoi (11) = 30
      lonmoi (12) = 31
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
c 3.2. ==> cumul du nombre de jours pleins passes depuis le debut
c          de l'annee
c
      nbjour = 0
c
      naux = nummoi - 1
      do 32 , iaux = 1 , naux
         nbjour = nbjour + lonmoi(mod(iaux-1,12)+1)
   32 continue
c
      if ( mod(numann,4).eq.0 .and. nummoi.gt.2 ) then
         nbjour = nbjour + 1
      endif
c
c 3.3. ==> cumul du nombre de jours pleins passes depuis le debut
c          du mois
c
      nbjour = nbjour + numjou - 1
c
c 3.4. ==> calcul du nombre de secondes depuis le debut de l'annee
c
      datheu = numsec +
     >         nummin*60 +
     >         numheu*3600 +
     >         nbjour*86400
c
      end
