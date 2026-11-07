c
c     maxtab = nombre maximum de tableaux elementaires geres
c              dans chaque categorie
c     maxtrs = nombre maximum de trous.
c
c     le nombre de trous ne peut pas depasser le nombre de tableaux + 1.
c     l'initialiser a maxtab + 2 assure, dans les sous-programmes de
c     desallocation, que l'on peut toujours calculer
c     ntrou (r,i,d,s ou c) + 1
c
      integer maxtab , maxtrs
      parameter (maxtab=1000,maxtrs=maxtab+2)
