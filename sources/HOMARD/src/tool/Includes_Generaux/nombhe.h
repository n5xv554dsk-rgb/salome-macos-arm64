c
c=======================================================================
c nombres propres aux hexaedres
c-----------------------------------------------------------------------
c nbheac : nombre d'hexaedres actifs
c nbheco : nombre d'hexaedres decoupes par conformite en pyramides
c          et/ou tetraedres
c nbhede : nombre d'hexaedres issus d'un decoupage en 8 d'un
c          hexaedres
c nbhedh : issus d'un decoupage de conformite d'un hexaedre
c nbhema : nombre d'hexaedres du macro-maillage.
c nbhepe : nombre d'hexaedres permanents du maillage (nbhema+nbhede).
c nbheto : nombre total d'hexaedres du maillage (nbhecf+nbheca)
c nbhecf : nombre d'hexaedres en connectivite par faces (=nbhepe)
c nbheca : nombre d'hexaedres en connectivite par aretes (=nbhedh)
c-----------------------------------------------------------------------
      integer         nbheac, nbheco, nbhede, nbhedh, nbhema,
     >                nbhepe, nbheto, nbhecf, nbheca
      common /nombhe/ nbheac, nbheco, nbhede, nbhedh, nbhema,
     >                nbhepe, nbheto, nbhecf, nbheca
