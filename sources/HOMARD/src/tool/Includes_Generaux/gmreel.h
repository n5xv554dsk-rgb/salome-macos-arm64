c on passe a une longueur de 1000 pour Calibre 9 ?????
c
c=======================================================================
c place memoire pour les reels
c-----------------------------------------------------------------------
c rmem  : tableau general en reel
c-----------------------------------------------------------------------
c
      integer lgcomr
      parameter ( lgcomr = 1000 )
c
      double precision    rmem (lgcomr)
      common /gmreel/ rmem
