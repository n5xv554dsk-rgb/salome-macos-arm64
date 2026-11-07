c
c=======================================================================
c environnement d'adaptation
c-----------------------------------------------------------------------
c nbiter : numero de l'adaptation,
c          0 : on en est au macro-maillage
c          k : k adaptations ont ete faites
c nivinf : niveau inferieur present dans le maillage courant actif, en
c          tenant compte seulement des decoupages standard
c nivsup : niveau superieur present dans le maillage courant, en
c          tenant compte seulement des decoupages standard
c niincf : 10 fois le niveau inferieur present dans le maillage courant,
c          en tenant compte des raccords de conformite.
c nisucf : 10 fois le niveau superieur present dans le maillage courant,
c          en tenant compte des raccords de conformite.
c-----------------------------------------------------------------------
      integer         nbiter, nivinf, nivsup, niincf, nisucf
      common /envada/ nbiter, nivinf, nivsup, niincf, nisucf
