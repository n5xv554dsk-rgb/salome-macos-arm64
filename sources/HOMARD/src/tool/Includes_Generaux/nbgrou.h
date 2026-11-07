c
c=======================================================================
c nombres de groupes dans chaque categorie
c-----------------------------------------------------------------------
c nbgrno : nombre de groupes de noeuds
c nbgrel : nombre de groupes d'elements, tous types confondus
c nbgrmp : nombre de groupes de mailles-points
c nbgrar : nombre de groupes d'aretes
c nbgrtr : nombre de groupes de triangles
c nbgrqu : nombre de groupes de quadrangles
c nbgrte : nombre de groupes de tetraedres
c nbgrhe : nombre de groupes d'hexaedres
c nbgrpy : nombre de groupes de pyramides
c nbgrpe : nombre de groupes de pentaedres
c-----------------------------------------------------------------------
      integer         nbgrno, nbgrel,
     >                nbgrmp, nbgrar,
     >                nbgrtr, nbgrqu,
     >                nbgrte, nbgrhe, nbgrpy, nbgrpe
      common /nbgrou/ nbgrno, nbgrel,
     >                nbgrmp, nbgrar,
     >                nbgrtr, nbgrqu,
     >                nbgrte, nbgrhe, nbgrpy, nbgrpe
