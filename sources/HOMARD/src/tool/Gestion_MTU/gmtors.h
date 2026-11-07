c
c  gmtors : les Tableaux pour les Objets de Reference en String
c
c nomtyp : nom des types d'objet structure declares dans le
c          fichier de configuration de GM
c nomcha : nom des champs declares dans la definition des types
c          d'objets du fichier de configuration de GM. l'indexage se
c          fait par le pointeur adrdst.
c nomtyb : nom des types simples de base (entier, reel, ...)
c
      character*8 nomtyp, nomcha,
     >            nomtyb
c
      common /gmtors/ nomtyp(ntypx),  nomcha(nchpx),
     >                nomtyb(ntybma)
