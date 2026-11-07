c
c  modgm : decrit le mode de gestion de la memoire
c          0 --> statique, la place est reserve par le dimensionnement
c                des communs xmem(*) a la creation de l'executable
c                et ensuite les tableaux et les trous sont pris dans
c                ces communs
c          1 --> semi-dynamique, pour chaque type une zone memoire est
c                alloue dynamiquement avec une taille fournie en donnee
c                et ensuite les tableaux et les trous sont pris dans
c                cette zone.
c          2 --> dynamique, chaque tableau est alloue dynamiquement et
c                il n'y a pas de gestion des trous
c
c  adcom : adresse vraie en memoire du debut de chaque commun
c  admem : adresse en memoire du debut de chaque zone par rapport a quoi
c          sont places rellement les tableaux
c          . en statique, c'est la meme valeur que adcom
c          . en semi-dynamique, c'est l'adresse vraie de la zone alloue
c          . en dynamique, c'est 0
c
      integer modgm,adcom,admem
      common /gmtyge/ modgm,adcom(8),admem(8)
