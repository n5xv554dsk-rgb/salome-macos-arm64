c
c=======================================================================
c permutations des codes des faces dans les tetraedres
c-----------------------------------------------------------------------
c perm1 : permutation laissant la premiere fonction, i1, invariante
c perm2 : permutation laissant la deuxieme fonction, i2, invariante
c perm3 : permutation laissant la troisieme fonction, i3, invariante
c-----------------------------------------------------------------------
      integer         perm1(6), perm2(6), perm3(6)
      common /permut/ perm1, perm2, perm3
