      subroutine ugdhlc ( datheu, numann,
     >                    nummoi, numjou, numheu, nummin, numsec,
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
c convertit la date et l'heure d'une forme longue en une forme compacte
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . datheu .  s  .   1    . nombre de seconde depuis le debut de l'an  .
c . numann . e   .   1    . numero de l'annee                          .
c . numjou . e   .   1    . numero du jour                             .
c . numheu . e   .   1    . numero de l'heure                          .
c . nummin . e   .   1    . numero de la minute                        .
c . numsec . e   .   1    . numero de la seconde                       .
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
      integer iaux, naux
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
c 2. mise en forme
c====
c
c 2.2. ==> cumul du nombre de jours pleins passes depuis le debut
c          de l'annee
c
      nbjour = 0
c
      naux = nummoi - 1
      do 22 , iaux = 1 , naux
         nbjour = nbjour + lonmoi(iaux)
   22 continue
c
      if ( mod(numann,4).eq.0 .and. nummoi.gt.2 ) then
         nbjour = nbjour + 1
      endif
c
c 2.3. ==> cumul du nombre de jours pleins passes depuis le debut
c          du mois
c
      nbjour = nbjour + numjou - 1
c
cc    if ( numheu.lt.24 ) then
cc        nbjour = nbjour - 1
cc    endif
c
c 2.4. ==> calcul du nombre de secondes depuis le debut de l'annee
c
      datheu = numsec +
     >         nummin*60 +
     >         numheu*3600 +
     >         nbjour*86400
c
      end
