c
c=======================================================================
c nombres propres aux triangles
c-----------------------------------------------------------------------
c nbtrac : nombre de triangles actifs
c nbtrde : nombre de triangles issus d'un decoupage en 4 des triangles
c          ou internes a un tetraedre ou pentaedre coupe en 8.
c nbtrt2 : nombre de triangles issus d'un decoupage en 2 des triangles.
c nbtrq3 : nombre de triangles issus d'un decoupage en 3 des quadrangles
c nbtrhc : nombre de triangles internes aux hexa coupes par conformite
c nbtrpc : nombre de triangles internes aux penta coupes par conformite
c nbtrtc : nombre de triangles internes aux tetra coupes par conformite
c nbtrma : nombre de triangles du macro-maillage.
c nbtrpe : nombre de triangles permanents du maillage (nbtrma+nbtrde).
c nbtrto : nombre total de triangles du maillage
c          = nbtrpe + nbtrt2 + nbtrhc + nbtrpc + nbtrtc + nbtrq3
c nbptho : nombre de paires de triangles homologues.
c nbtrri : nombre de triangles recolles dans le maillage initial
c-----------------------------------------------------------------------
      integer         nbtrac, nbtrde, nbtrt2, nbtrq3,
     >                nbtrhc, nbtrpc, nbtrtc,
     >                nbtrma, nbtrpe, nbtrto, nbptho, nbtrri
      common /nombtr/ nbtrac, nbtrde, nbtrt2, nbtrq3,
     >                nbtrhc, nbtrpc, nbtrtc,
     >                nbtrma, nbtrpe, nbtrto, nbptho, nbtrri
