      subroutine utdhco ( numann, datheu )
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
c  donne la date et l'heure sous forme courte
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . numann .  s  .   1    . numero de l'annee                          .
c . datheu .  s  .   1    . nombre de seconde depuis le debut de l'an  .
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
      integer codret
c
c====
c 1. acquisition de la date
c====
c
      call dmjohe ( numann, nummoi, numjou, numjos,
     >              numheu, nummin, numsec )
c
c====
c 2. mise en forme courte
c====
c
      call utdhlc ( datheu, numann,
     >              nummoi, numjou, numheu, nummin, numsec,
     >              codret )
c
      end
