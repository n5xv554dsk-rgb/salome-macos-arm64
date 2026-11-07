C
c diverses operations sur les entiers 1, 2, 3
c=======================================================================
c per1a3 : entier pour la permutation circulaire (1,2,3)
c          per1a3(-1,i) = entier avant i
c          per1a3( 0,i) = i
c          per1a3( 1,i) = entier apres i
c          per1a3( 2,i) = entier 2 places apres i = per1a3(-1,i)
c per1a3(-1,1) = 3, per1a3(-1,2) = 1, per1a3(-1,3) = 2
c per1a3( 0,1) = 1, per1a3( 0,2) = 2, per1a3( 0,3) = 3
c per1a3( 1,1) = 2, per1a3( 1,2) = 3, per1a3( 1,3) = 1
c per1a3( 2,1) = 3, per1a3( 2,2) = 1, per1a3( 2,3) = 2
c-----------------------------------------------------------------------
      integer         per1a3(-1:2,3)
      common /ope1a3/ per1a3
