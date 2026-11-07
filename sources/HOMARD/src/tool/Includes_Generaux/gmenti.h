c on passe a une longueur de 1000 pour Calibre 9 ?????
c
c=======================================================================
c place memoire pour les entiers
c-----------------------------------------------------------------------
c imem  : tableau general en entier
c-----------------------------------------------------------------------
c
      integer lgcomi
      parameter ( lgcomi = 1000 )
c
      integer         imem (lgcomi)
      common /gmenti/ imem
