c
c=======================================================================
c dimensionnement des caracteristiques de familles d'entites
c-----------------------------------------------------------------------
c ncffno : nombre fige de caracteristiques de familles de noeuds
c ncffmp : nombre fige de caracteristiques de familles de mailles-points
c ncffar : nombre fige de caracteristiques de familles d'aretes
c ncfftr : nombre fige de caracteristiques de familles de triangles
c ncffqu : nombre fige de caracteristiques de familles de quadrangles
c ncffte : nombre fige de caracteristiques de familles de tetraedres
c ncffhe : nombre fige de caracteristiques de familles d'hexaedres
c ncffpy : nombre fige de caracteristiques de familles de pyramides
c ncffpe : nombre fige de caracteristiques de familles de pentaedres
c
c ncxfno : nombre de caract. d'extrusion dans les familles de noeuds
c ncxfar : nombre de caract. d'extrusion dans les familles d'aretes
c ncxftr : nombre de caract. d'extrusion dans les familles de tria.
c ncxfqu : nombre de caract. d'extrusion dans les familles de quad.
c
c ncefno : nombre de caract. d'equivalence dans les familles de noeuds
c ncefmp : nombre de caract. d'equivalence dans les familles de m.points
c ncefar : nombre de caract. d'equivalence dans les familles d'aretes
c nceftr : nombre de caract. d'equivalence dans les familles de tria.
c ncefqu : nombre de caract. d'equivalence dans les familles de quad.
c
c nctfno : nombre total de caracteristiques de familles de noeuds
c nctfmp : nombre total de caracteristiques de familles de noeuds
c nctfar : nombre total de caracteristiques de familles d'aretes
c nctftr : nombre total de caracteristiques de familles de triangles
c nctfqu : nombre total de caracteristiques de familles de quadrangles
c nctfte : nombre total de caracteristiques de familles de tetraedres
c nctfhe : nombre total de caracteristiques de familles d'hexaedres
c nctfpy : nombre total de caracteristiques de familles de pyramides
c nctfpe : nombre total de caracteristiques de familles de pentaedres
c-----------------------------------------------------------------------
      integer         ncffno, ncxfno, ncefno, nctfno,
     >                ncffmp,         ncefmp, nctfmp,
     >                ncffar, ncxfar, ncefar, nctfar,
     >                ncfftr, ncxftr, nceftr, nctftr,
     >                ncffqu, ncxfqu, ncefqu, nctfqu,
     >                ncffte,                 nctfte,
     >                ncffhe,                 nctfhe,
     >                ncffpy,                 nctfpy,
     >                ncffpe,                 nctfpe
      common /dicfen/ ncffno, ncxfno, ncefno, nctfno,
     >                ncffmp,         ncefmp, nctfmp,
     >                ncffar, ncxfar, ncefar, nctfar,
     >                ncfftr, ncxftr, nceftr, nctftr,
     >                ncffqu, ncxfqu, ncefqu, nctfqu,
     >                ncffte,                 nctfte,
     >                ncffhe,                 nctfhe,
     >                ncffpy,                 nctfpy,
     >                ncffpe,                 nctfpe
