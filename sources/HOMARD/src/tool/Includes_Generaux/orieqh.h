c
c=======================================================================
c memorisation de la convention de l'orientation locale des quadrangles
c dans un hexaedre suivant le code des quadrangles
c-----------------------------------------------------------------------
c pour le quadrangle i de code c :
c            orcoqh(i,c) :  1, le quadrangle est sortant
c                          -1, le quadrangle est entrant
c-----------------------------------------------------------------------
      integer         orcoqh(6,8)
      common /orieqh/ orcoqh
