c
c  gmtoai : les Tableaux pour les Objets Alloues en Integer
c
c typobj : numero du type de chaque objet alloue.
c
c adrdso : reperage des champs associes a chaque objet alloue.
c          cela sert d'indexage pour le tableau nomobc, ainsi :
c          les champs relatifs a l'objet i sont stockes entre
c          les indices adrdso(i) et adrdso(i)+nbcham(typobj(i))-1 inclus
c
c adrdsa : reperage des attributs associes a chaque objet alloue.
c          cela sert d'indexage pour le tableau valatt, ainsi :
c          les attributs relatifs a l'objet i sont stockes entre
c          les indices adrdsa(i) et adrdsa(i)+nbattr(typobj(i))-1 inclus
c
c valatt : valeurs des attributs pour l'ensemble des objets alloues.
c          l'indexage se fait par le pointeur adrdsa.
c
c Rappel : nobjx = nombre d'objets alloues
c          nobcx = nombre cumule d'attributs pour les objets alloues
c          iptobj = numero du prochain objet a allouer
c          iptchp = 1er indice disponible dans le tableau nomobc
c          iptatt = 1er indice disponible dans le tableau valatt
c
      integer typobj,adrdso,adrdsa,valatt,
     >        iptobj,iptchp,iptatt
c
      common /gmtoai/ typobj(nobjx), adrdso(nobjx), adrdsa(nobjx),
     >                valatt(nobcx),
     >                iptobj, iptchp, iptatt
