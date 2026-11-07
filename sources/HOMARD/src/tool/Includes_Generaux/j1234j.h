c
c=======================================================================
c correspondance entre le code d'une face dans un hexaaedre ou un
c pentaedre et les numeros locaux des aretes de cette face
c Pour une face de code c :
c    j1(c) : numero local de l'arete I1
c    j2(c) : numero local de l'arete I2
c    j3(c) : numero local de l'arete I3
c    j4(c) : numero local de l'arete I4
c-----------------------------------------------------------------------
      integer         j1(8), j2(8), j3(8), j4(8)
      common /j1234j/ j1, j2, j3, j4
