c
c=======================================================================
c memorisation de la convention de l'orientation locale des faces
c dans un pentaedre suivant le code des faces
c-----------------------------------------------------------------------
c pour la face i de code c :
c            orcofp(i,c) :  1, la face est sortante
c                          -1, la face est entrante
c-----------------------------------------------------------------------
      integer         orcofp(5,8)
      common /oriefp/ orcofp
