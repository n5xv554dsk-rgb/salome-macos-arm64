c
c=======================================================================
c memorisation de la convention de l'orientation locale des triangles
c dans un tetraedre suivant le code des triangles
c-----------------------------------------------------------------------
c pour le triangle i de code c :
c            orcott(i,c) :  1, le triangle est sortant
c                          -1, le triangle est entrant
c-----------------------------------------------------------------------
      integer         orcott(4,6)
      common /oriett/ orcott
