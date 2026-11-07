c
c=======================================================================
c nombres propres aux aretes
c-----------------------------------------------------------------------
c nbarac : nombre d'aretes actives
c nbarde : nombre d'aretes crees pour le decoupage standard du maillage,
c          soit au decoupage des faces en 4, soit en interne aux
c          tetraedres, hexaedres, pentaedres coupes en 8
c nbart2 : nombre d'aretes internes des triangles decoupes en 2
c nbarq2 : nombre d'aretes internes des quadrangles decoupes en 2
c nbarq3 : nombre d'aretes internes des quadrangles decoupes en 3 tria
c nbarq5 : nombre d'aretes internes des quadrangles decoupes en 3 quad
c nbarin : nombre d'aretes internes aux volumes coupees par conformite
c nbarma : nombre d'aretes du macro-maillage
c nbarpe : nombre d'aretes permanentes du maillage (nbarma+nbarde)
c nbarto : nombre total d'aretes du maillage
c          = nbarpe + nbart2 + nbarq2 + nbarq3 + nbarq5 + nbarin
c nbfaar : nombre cumule des faces autour des aretes
c nbpaho : nombre de paires d'aretes homologues
c-----------------------------------------------------------------------
      integer         nbarac, nbarde, nbart2,
     >                nbarq2, nbarq3, nbarq5,
     >                nbarin,
     >                nbarma, nbarpe, nbarto, nbfaar, nbpaho
      common /nombar/ nbarac, nbarde, nbart2,
     >                nbarq2, nbarq3, nbarq5,
     >                nbarin,
     >                nbarma, nbarpe, nbarto, nbfaar, nbpaho
