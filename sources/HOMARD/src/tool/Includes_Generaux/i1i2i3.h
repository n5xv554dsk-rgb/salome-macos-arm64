c
c=======================================================================
c correspondance entre le code d'une face dans un tetraedre et les
c numeros locaux des aretes de cette face
c-----------------------------------------------------------------------
c i1(c) : numero local de la premiere  arete d'une face de code c
c i2(c) : numero local de la deuxieme  arete d'une face de code c
c i3(c) : numero local de la troisieme arete d'une face de code c
c-----------------------------------------------------------------------
      integer         i1(6), i2(6), i3(6)
      common /i1i2i3/ i1, i2, i3
