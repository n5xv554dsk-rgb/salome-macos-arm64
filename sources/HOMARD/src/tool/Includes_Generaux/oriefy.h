c
c=======================================================================
c memorisation de la convention de l'orientation locale des faces
c dans une pyramide suivant le code des faces
c-----------------------------------------------------------------------
c pour la face i de code c :
c            orcofy(i,c) :  1, la face est sortante
c                          -1, la face est entrante
c-----------------------------------------------------------------------
      integer         orcofy(5,8)
      common /oriefy/ orcofy
