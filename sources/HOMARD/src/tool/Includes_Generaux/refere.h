c
c=======================================================================
c description des elements de reference
c-----------------------------------------------------------------------
c tyeref : precise le type d'element en fonction du type de reference
c          0 si compatible avec le mode d'utilisation de HOMARD
c          1 sinon
c nbnref : donne le nombre de noeuds en fonction du type de reference ;
c          1er champ : type HOMARD de l'element de reference
c          2eme champ : 1 : sommets
c                       2 : sommets + milieux d'aretes
c                       3 : total (sommets+milieux+internes)
c nbaref : donne le nombre d'aretes en fonction du type de reference
c nasref : donne le nombre d'aretes reliees a chaque sommet, sans
c          se preoccuper d'orientation, en fonction du type
c nfaref : donne le nombre de faces qui s'appuient sur chaque arete
c          sans se preoccuper d'orientation
c nafref : donne le nombre d'aretes de chaque face de l'element
c          1er champ : type HOMARD de l'element de reference
c          2eme champ : numero local de la face envisagee
c defref : pour chaque arete de chaque face, donne le numero local
c          de l'arete dans la description de reference de l'element
c          ce qui correspond aux tableaux de definitions de I1 I2 I3 I4
c          dans la doc.
c          1er champ : type HOMARD de l'element de reference
c          2eme champ : numero local de la face envisagee
c          3eme champ : 1, 2, 3 et 4 pour chaque arete
c faaref : donne le numero local de la face s'appuyant sur une arete
c          1er champ : type HOMARD de l'element de reference
c          2eme champ : numero local de l'arete concernee
c          3eme champ : rang de la face envisagee
c-----------------------------------------------------------------------
c
      integer tyeref(0:tehmax), nbnref(0:tehmax,3), nbaref(0:tehmax)
      integer nasref(0:tehmax), nfaref(0:tehmax)
      integer nafref(0:tehmax,6), defref(0:tehmax,6,4)
      integer faaref(0:tehmax,12,2)
      common /refere/ tyeref, nbnref, nbaref,
     >                nasref, nfaref,
     >                nafref, defref, faaref
