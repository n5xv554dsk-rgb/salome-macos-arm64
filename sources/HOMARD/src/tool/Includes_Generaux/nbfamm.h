c
c=======================================================================
c nombres maximum de familles d'entites
c-----------------------------------------------------------------------
c nbfnom : nombre maximum de familles de noeuds
c nbfmpm : nombre maximum de familles de mailles-points
c nbfarm : nombre maximum de familles d'aretes
c nbftrm : nombre maximum de familles de triangles
c nbfqum : nombre maximum de familles de quadrangles
c nbftem : nombre maximum de familles de tetraedres
c nbfhem : nombre maximum de familles d'hexaedres
c nbfpym : nombre maximum de familles de pyramides
c nbfpem : nombre maximum de familles de pentaedres
c-----------------------------------------------------------------------
      integer         nbfnom, nbfmpm,
     >                nbfarm,
     >                nbftrm, nbfqum,
     >                nbftem, nbfhem, nbfpym, nbfpem
      common /nbfamm/ nbfnom, nbfmpm,
     >                nbfarm,
     >                nbftrm, nbfqum,
     >                nbftem, nbfhem, nbfpym, nbfpem
