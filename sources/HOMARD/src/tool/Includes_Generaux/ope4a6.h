C
c diverses operations sur les entiers 4, 5, 6
c=======================================================================
c per4a6 : entier pour la permutation circulaire (4,5,6)
c          per4a6(-1,i) = entier avant i
c          per4a6( 0,i) = i
c          per4a6( 1,i) = entier apres i
c          per4a6( 2,i) = entier 2 places apres i = per4a6(-1,i)
c per4a6(-1,4) = 6, per4a6(-1,5) = 4, per4a6(-1,6) = 5
c per4a6( 0,4) = 4, per4a6( 0,5) = 5, per4a6( 0,6) = 6
c per4a6( 1,4) = 5, per4a6( 1,5) = 6, per4a6( 1,6) = 4
c per4a6( 2,4) = 6, per4a6( 2,5) = 4, per4a6( 2,6) = 5
c-----------------------------------------------------------------------
      integer         per4a6(-1:2,4:6)
      common /ope4a6/ per4a6
