c
c=======================================================================
c front0 : reperage des frontieres pour la sortie
c-----------------------------------------------------------------------
c nrofro : numero global de la frontiere
c nrofrd : numero global pour chaque frontiere discrete
c nrofra : numero global pour chaque frontiere analytique
c-----------------------------------------------------------------------
      integer         nrofro, nrofrd(100), nrofra(100)
      common /front0/ nrofro, nrofrd     , nrofra
