c
c=======================================================================
c nombres d'entites du maillage initial avec la conformite
c-----------------------------------------------------------------------
c nancno : nombre de noeuds du maillage adapte
c nancar : nombre d'aretes du maillage adapte
c nanctr : nombre de triangles du maillage adapte
c nancqu : nombre de quadrangles du maillage adapte
c nancte : nombre de tetraedres du maillage adapte
c nanctf : nombre de tetraedres du maillage adapte decrits par faces
c nancta : nombre de tetraedres du maillage adapte decrits par aretes
c nancpy : nombre de pyramides du maillage adapte
c nancyf : nombre de pyramides du maillage adapte decrites par faces
c nancya : nombre de pyramides du maillage adapte decrites par aretes
c nanche : nombre d'hexaedres du maillage adapte
c nanchf : nombre d'hexaedres du maillage adapte decrits par faces
c nancha : nombre d'hexaedres du maillage adapte decrits par aretes
c nancpe : nombre de pentaedres du maillage adapte
c nancpf : nombre de pentaedres du maillage adapte decrits par faces
c nancpa : nombre de pentaedres du maillage adapte decrits par aretes
c-----------------------------------------------------------------------
      integer         nancno, nancar, nanctr, nancqu,
     >                nancte, nanctf, nancta, nancpy, nancyf, nancya,
     >                nanche, nanchf, nancha, nancpe, nancpf, nancpa
      common /nancnb/ nancno, nancar, nanctr, nancqu,
     >                nancte, nanctf, nancta, nancpy, nancyf, nancya,
     >                nanche, nanchf, nancha, nancpe, nancpf, nancpa
