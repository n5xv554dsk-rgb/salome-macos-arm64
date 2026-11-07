c
c=======================================================================
c nombres propres aux noeuds
c-----------------------------------------------------------------------
c nbnois : nombre de noeuds isoles
c nbnoei : nombre de noeuds d'elements ignores
c nbnoma : nombre de noeuds du macro-maillage
c nbnomp : nombre de noeuds support de maille-point uniquement
c nbnop1 : nombre de sommets du maillage (noeuds p1)
c nbnop2 : nombre de noeuds milieux d'aretes du maillage (noeuds p2)
c nbnoim : nombre de noeuds internes aux mailles
c nbnoto : nombre total de noeuds du maillage (nbnop1+nbnop2+nbnoim)
c nbpnho : nombre de paires de noeuds homologues
c numip1 : numero minimum pour un sommet du maillage (noeud p1)
c numap1 : numero maximum pour un sommet du maillage (noeud p1)
c nbnoin : nombre de noeuds internes aux volumes coupees par conformite
c-----------------------------------------------------------------------
      integer         nbnois, nbnoei, nbnoma, nbnomp,
     >                nbnop1, nbnop2, nbnoim, nbnoto,
     >                nbpnho, numip1, numap1, nbnoin
      common /nombno/ nbnois, nbnoei, nbnoma, nbnomp,
     >                nbnop1, nbnop2, nbnoim, nbnoto,
     >                nbpnho, numip1, numap1, nbnoin
