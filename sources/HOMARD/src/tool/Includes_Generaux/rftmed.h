c
c=======================================================================
c description des types d'entites a partir du format MED
c-----------------------------------------------------------------------
c medtrf : donne le type de reference en fonction du code MED
c         -1 : noeud
c          0 : maille-point
c          1 : poutre lineaire
c          2 : poutre quadratique
c          3 : triangle lineaire
c          4 : triangle quadratique
c          5 : tetraedre lineaire
c          6 : tetraedre quadratique
c          7 : quadrangle lineaire
c          8 : quadrangle quadratique
c          9 : pyramide lineaire
c         10 : pyramide quadratique
c         11 : hexaedre lineaire
c         12 : hexaedre quadratique
c         13 : pentaedre lineaire
c         14 : pentaedre quadratique
c medt12 : donne le code med de la maille apres echange du degre
c mednnm : donne le nombre de noeuds de la maille med
c-----------------------------------------------------------------------
c
      integer nbtmed
      parameter ( nbtmed = 400 )
c
      integer         mednnm(0:nbtmed)
      integer         medtrf(0:nbtmed)
      integer         medt12(0:nbtmed)
      common /rftmed/ mednnm, medtrf, medt12
c
