c on passe a une longueur de 1000 pour Calibre 9 ?????
c
c=======================================================================
c place memoire pour les caracteres
c-----------------------------------------------------------------------
c smem  : tableau general en character*8
c-----------------------------------------------------------------------
c
      integer lgcoms
      parameter ( lgcoms = 1000 )
c
      character*8     smem (lgcoms)
      common /gmstri/ smem
