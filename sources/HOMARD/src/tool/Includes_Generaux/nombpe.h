c
c=======================================================================
c nombres propres aux pentaedres
c-----------------------------------------------------------------------
c nbpeac : nombre de pentaedres actifs
c nbpeco : nombre de pentaedres decoupes par conformite
c nbpede : nombre de pentaedres issus d'un decoupage en 8 des
c          pentaedres
c nbpedp : issus d'un decoupage de conformite d'un pentaedre
c nbpema : nombre de pentaedres du macro-maillage.
c nbpepe : nombre de pentaedres permanents du maillage (nbpema+nbpede).
c nbpeto : nombre total de pentaedres du maillage
c nbpecf : nombre de pentaedres en connectivite par faces
c nbpeca : nombre de pentas en connectivite par aretes
c-----------------------------------------------------------------------
      integer         nbpeac, nbpeco, nbpede, nbpedp, nbpema,
     >                nbpepe, nbpeto, nbpecf, nbpeca
      common /nombpe/ nbpeac, nbpeco, nbpede, nbpedp, nbpema,
     >                nbpepe, nbpeto, nbpecf, nbpeca
