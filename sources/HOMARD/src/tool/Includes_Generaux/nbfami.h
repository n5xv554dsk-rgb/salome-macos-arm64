c
c=======================================================================
c nombres de familles d'entites
c-----------------------------------------------------------------------
c nbfnoe : nombre total de familles de noeuds
c nbfmpo : nombre total de familles de mailles-points
c nbfare : nombre total de familles d'aretes
c nbftri : nombre total de familles de triangles
c nbfqua : nombre total de familles de quadrangles
c nbftet : nombre total de familles de tetraedres
c nbfhex : nombre total de familles d'hexaedres
c nbfpyr : nombre total de familles de pyramides
c nbfpen : nombre total de familles de pentaedres
c-----------------------------------------------------------------------
      integer         nbfnoe, nbfmpo,
     >                nbfare,
     >                nbftri, nbfqua,
     >                nbftet, nbfhex, nbfpyr, nbfpen
      common /nbfami/ nbfnoe, nbfmpo,
     >                nbfare,
     >                nbftri, nbfqua,
     >                nbftet, nbfhex, nbfpyr, nbfpen
