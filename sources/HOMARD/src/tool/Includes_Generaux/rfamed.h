c
c=======================================================================
c description des mailles de reference pour une connectivite a la med
c-----------------------------------------------------------------------
c arsmed : donne le numero local de l'arete reliee a un sommet
c          1er champ : type HOMARD de la maille de reference
c          2eme champ : numero local du sommet concerne
c          3eme champ : rang de l'arete envisagee
c deamed : description des aretes par les numeros locaux des noeuds
c          sans se preoccuper d'orientation
c          1er champ : type HOMARD de la maille de reference
c          2eme champ : numero local de l'arete envisagee
c          3eme champ : 1 et 2 pour chaque extremite, 3 pour le milieu
c-----------------------------------------------------------------------
c
      integer         arsmed(0:tehmax,10,4)
      integer         deamed(0:tehmax,12,3)
      common /rfamed/ arsmed, deamed
