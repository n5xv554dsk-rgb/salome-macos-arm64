c
c=======================================================================
c nombres propres aux tetraedres
c-----------------------------------------------------------------------
c nbteac : actifs
c nbtea2 : issus d'un decoupage en 2 d'un tetraedre
c nbtea4 : issus d'un decoupage en 4 (par 2 aretes) d'un tetraedre
c nbtede : issus du decoupage standard du maillage
c nbtef4 : issus d'un decoupage en 4 (par 1 face) d'un tetraedre
c Pour un raffinement selon des boites :
c  nbteh1 : issus d'un decoupage d'un hexaedre a partir d'une face
c  nbteh2 : issus d'un decoupage d'un hexaedre a partir de 3 aretes
c  nbteh3 : issus d'un decoupage d'un hexaedre a partir de 2 aretes
c  nbteh4 : issus d'un decoupage d'un hexaedre a partir d'1 arete
c  nbtep0 : issus d'un decoupage d'un pentaedre a partir d'1 ar tr
c  nbtep1 : issus d'un decoupage d'un pentaedre a partir d'1 ar qu
c  nbtep2 : issus d'un decoupage d'un pentaedre a partir de 2 ar tr/qu
c  nbtep3 : issus d'un decoupage d'un pentaedre a partir de 2 ar qu/qu
c  nbtep4 : issus d'un decoupage d'un pentaedre a partir d'1 face qu
c  nbtep5 : issus d'un decoupage d'un pentaedre a partir d'1 face tr
c Sinon :
c  nbtedh : issus d'un decoupage d'un hexaedre
c  nbtedp : issus d'un decoupage d'un pentaedre
c nbtema : du macro-maillage
c nbtepe : permanents du maillage (nbtema+nbtede)
c nbteto : nombre total de tetraedres (nbtecf+nbteca)
c nbtecf : nombre de tetraedres en connectivite par faces
c nbteca : nombre de tetras en connectivite par aretes (nbtedh+nbtedp)
c-----------------------------------------------------------------------
      integer         nbteac, nbtea2, nbtea4, nbtede, nbtef4,
     >                nbteh1, nbteh2, nbteh3, nbteh4,
     >                nbtep0, nbtep1, nbtep2, nbtep3, nbtep4, nbtep5,
     >                nbtedh, nbtedp,
     >                nbtema, nbtepe, nbteto, nbtecf, nbteca
      common /nombte/ nbteac, nbtea2, nbtea4, nbtede, nbtef4,
     >                nbteh1, nbteh2, nbteh3, nbteh4,
     >                nbtep0, nbtep1, nbtep2, nbtep3, nbtep4, nbtep5,
     >                nbtedh, nbtedp,
     >                nbtema, nbtepe, nbteto, nbtecf, nbteca
