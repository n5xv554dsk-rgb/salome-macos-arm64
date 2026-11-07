c
c     nomalt contient la liste des noms d'objets temporaires
c     qui sont alloues.
c     ces noms sont etablis independamment de la categorie (structure
c     ou entier, ou reel, ...)
c     le nombre d'objets temporaires est contenu dans le commun gmtenb
c     (plus precisement, un tableau de flags numete,
c      dimensionne lui aussi avec une marge, a maxtbt > 3*maxtab+nobjx).
c
      character*8     nomalt
      common /gmteno/ nomalt(maxtbt)
