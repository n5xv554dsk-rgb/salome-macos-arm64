      subroutine dmtemp ( tuser, tsyst )
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
c   Dependance Machine : TEMPs de calcul
c   -          -         ----
c ______________________________________________________________________
c
c
c  retourne les temps user et systeme ecoules depuis le dernier appel
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tuser  .  s  .   1    . temps user depuis le dernier appel         .
c . tsyst  .  s  .   1    . temps systeme ....................         .
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
      double precision tuser, tsyst
c
c 0.4. ==> variables locales
c
      logical prem
c
      double precision tuser0, tsyst0
      double precision tuser1, tsyst1
c
c 0.5. ==> initialisations
c
      data prem / .true. /
c
c===
c 1. appel de la fonction C equivalente
c===
c
      call dmtemc ( tuser, tsyst )
c
c 1.1 ==> Archivage du depart
c
      if ( prem ) then
c
        tuser0 = tuser
        tsyst0 = tsyst
c
        tuser = 0.d0
        tsyst = 0.0d0
c
        prem = .false.
c
      else
c
c 1.2. ==> Difference
c
        tuser1 = tuser
        tsyst1 = tsyst
c
        tuser = tuser - tuser0
        tsyst = tsyst - tsyst0
c
        tuser0 = tuser1
        tsyst0 = tsyst1
c
      endif
c
      end
