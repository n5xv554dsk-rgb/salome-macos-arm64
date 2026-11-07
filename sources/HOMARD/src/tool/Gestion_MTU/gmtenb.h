c
c     numete(i) vaut : 1 si le numero i a ete utilise pour nommer
c                      un tableau temporaire
c                      0 si le numero n'a jamais servi
c     la liste des noms nomalt est contenue dans le commun gmteno.
c
c     mxtbtp : numero maximum (entre 0 et 3*maxtab+nobjx) de tableau
c              temporaire alloue.
c
c     Rappel : il y a 3 types possibles d'objets simples, et au maximum
c              maxtab objets dans chaque type.
c              nobjx est le nombre maximum d'objets structures
c              un objet temporaire peut etre simple ou structure.
c
c     on se donne une marge au dela de 3*maxtab+nobjx pour que quelques
c     allocations d'objets temporaires puissent etre faites par
c     ugstop (appele lorsque le nombre d'objets simples alloues avoisine
c     maxtab). De toutes facons, numete et nomalt doivent au moins
c     etre de taille 3*maxtab+1 car le test de depassement du nombre max
c     d'objets gm alloues est fait apres l'appel a gbntcr.
c
      integer maxtbt
      parameter ( maxtbt = (3*maxtab)+nobjx+10 )
c
      integer         mxtbtp, numete(maxtbt)
      common /gmtenb/ mxtbtp, numete
