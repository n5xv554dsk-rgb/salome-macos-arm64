      subroutine utdhcl ( nummoi, numjou, numheu, nummin, numsec,
     >                    numann, datheu,
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
c convertit la date et l'heure d'une forme compacte en une forme longue
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numjou .  s  .   1    . numero du jour                             .
c . numheu .  s  .   1    . numero de l'heure                          .
c . nummin .  s  .   1    . numero de la minute                        .
c . numsec .  s  .   1    . numero de la seconde                       .
c . numann . e   .   1    . numero de l'annee                          .
c . datheu . e   .   1    . nombre de secondes depuis le debut de l'an .
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
      integer datheu
      integer numann
      integer nummoi, numjou, numheu, nummin, numsec
      integer codret
c
c 0.4. ==> variables locales
c
      integer nbjour
      integer iaux, jaux, naux
c
      integer lonmoi (12)
c
c====
c 1.  initialisation
c====
c
      codret = 0
c
      lonmoi (1) = 31
      if ( mod(numann,4).eq.0 ) then
         lonmoi (2) = 29
      else
         lonmoi (2) = 28
      endif
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
c 2. mise en forme
c====
c
c 2.1. ==> cumul du nombre de jours pleins passes depuis le debut
c          de l'annee, puis du nombre d'heures pleines depuis
c          le debut du jour, etc
c
      iaux = mod(datheu,86400)
      nbjour = (datheu-iaux)/86400 + 1
c
      if ( iaux.ne.0 ) then
c
         jaux = iaux
         iaux = mod(jaux,3600)
         numheu = (jaux-iaux)/3600
c
         jaux = iaux
         iaux = mod(jaux,60)
         nummin = (jaux-iaux)/60
c
         numsec = iaux
c
      else
c
         numheu = 0
         nummin = 0
         numsec = 0
c
      endif
c
c 2.2. ==> decodage du numero du jour
c
      nummoi = 1
      numjou = 1
c
      naux = 0
      do 22 iaux = 1 , 12
         naux = naux + lonmoi(iaux)
         if ( naux.ge.nbjour ) then
            nummoi = iaux
            numjou = nbjour - naux + lonmoi(iaux)
            goto 23
         endif
   22 continue
c
      if ( numheu .eq. 0 ) then
         numann = numann + 1
      else
         codret = 1
      endif
c
   23 continue
c
      end
