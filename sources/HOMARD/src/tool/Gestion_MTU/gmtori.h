c
c  gmtori : les Tableaux pour les Objets de Reference en Integer
c
c nbcham : nombre de champs associes a chaque type declare dans le
c          fichier de configuration de GM
c
c nbattr : nombre d'attributs associes a chaque type declare dans le
c          fichier de configuration de GM
c
c adrdst : reperage des champs associes a chaque type declare dans le
c          fichier de configuration de GM. cela sert d'indexage pour
c          les tableaux typcha et nomcha, ainsi :
c          les infos relatives aux champs du type i sont placees entre
c          les indices adrdst(i) et adrdst(i)+nbcham(i)-1 inclus
c
c typcha : type des champs associes a chaque type declare dans le
c          fichier de configuration de GM. l'indexage se fait par
c          le pointeur adrdst.
c
c Rappel : ntypx = nombre maximum de types declarables dans
c                  la configuration de GM
c          nchpx = nombre maximum de champs declarables dans
c                  la configuration de GM
c          nbrtyp = nombre de type effectivement declares
c
      integer nbcham,nbratt,adrdst,typcha,
     >        nbrtyp, ntyb
c
      common /gmtori/ nbcham(ntypx), nbratt(ntypx), adrdst(ntypx),
     >                typcha(nchpx),
     >                nbrtyp, ntyb
