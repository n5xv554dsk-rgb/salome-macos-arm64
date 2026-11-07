c
c=======================================================================
c description des mailles de reference pour une connectivite a la med
c-----------------------------------------------------------------------
c nofmed : numero des faces dans les descriptions des mailles volumiques
c          1er champ : type HOMARD de la maille de reference
c          2eme champ : numero local de la face envisagee
c          3eme champ : 1 pour MED vers HOMARD, 2 pour HOMARD vers MED
c          exemple pour un tetraedre :
c          nofmed(3,2,1) : numero dans la description HOMARD de la 2eme
c                          face dans la description descendante MED
c-----------------------------------------------------------------------
c
      integer         nofmed(0:7,6,3)
      common /fhomed/ nofmed
