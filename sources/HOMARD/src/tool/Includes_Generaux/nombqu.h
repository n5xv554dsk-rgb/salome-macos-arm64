c
c=======================================================================
c nombres propres aux quadrangles
c-----------------------------------------------------------------------
c nbquac : nombre de quadrangles actifs
c nbqude : nombre de quadrangles issus d'un decoupage en 4 des
c          quadrangles
c nbquq2 : nombre de quadrangles issus d'un decoupage en 2 des
c          quadrangles
c nbquq5 : nombre de quadrangles issus d'un decoupage en 3 des
c          quadrangles
c nbquma : nombre de quadrangles du macro-maillage.
c nbqupe : nombre de quadrangles permanents du maillage (nbquma+nbqude).
c nbquto : nombre total de quadrangles du maillage
c          = nbqupe + nbquq2 + nbquq3
c nbpqho : nombre de paires de quadrangles homologues.
c nbquri : nombre de quadrangles recolles dans le maillage initial
c-----------------------------------------------------------------------
      integer         nbquac, nbqude, nbquma,
     >                nbquq2, nbquq5,
     >                nbqupe, nbquto, nbpqho, nbquri
      common /nombqu/ nbquac, nbqude, nbquma,
     >                nbquq2, nbquq5,
     >                nbqupe, nbquto, nbpqho, nbquri
