C
c diverses operations sur les entiers 1, 2, 3, 4
c=======================================================================
c per1a4 : entiers pour la permutation circulaire (1,.,4)
c          . Pour i de 1 a 4 :
c            per1a4(-5,i) = 1 devient 2, puis sens inverse
c            per1a4(-4,i) = 1 devient 3, puis sens inverse
c            per1a4(-3,i) = 1 devient 4, puis sens inverse
c            per1a4(-2,i) = 1 idem, puis sens inverse
c            per1a4(-1,i) = entier avant i (= per1a4(3,i))
c            per1a4( 0,i) = i
c            per1a4( 1,i) = entier apres i
c            per1a4( 2,i) = entier 2 cases apres i
c            per1a4( 3,i) = entier 3 cases apres i (= per1a4(-1,i))
c per1a4(-5,1) = 2, per1a4(-5,2) = 1, per1a4(-5,3) = 4, per1a4(-5,4) = 3
c per1a4(-4,1) = 3, per1a4(-4,2) = 2, per1a4(-4,3) = 1, per1a4(-4,4) = 4
c per1a4(-3,1) = 4, per1a4(-3,2) = 3, per1a4(-3,3) = 2, per1a4(-3,4) = 1
c per1a4(-2,1) = 1, per1a4(-2,2) = 4, per1a4(-2,3) = 3, per1a4(-2,4) = 2
c per1a4(-1,1) = 4, per1a4(-1,2) = 1, per1a4(-1,3) = 2, per1a4(-1,4) = 3
c per1a4( 0,1) = 1, per1a4( 0,2) = 2, per1a4( 0,3) = 3, per1a4( 0,4) = 4
c per1a4( 1,1) = 2, per1a4( 1,2) = 3, per1a4( 1,3) = 4, per1a4( 1,4) = 1
c per1a4( 2,1) = 3, per1a4( 2,2) = 4, per1a4( 2,3) = 1, per1a4( 2,4) = 2
c per1a4( 3,1) = 4, per1a4( 3,2) = 1, per1a4( 3,3) = 2, per1a4( 3,4) = 3
c
c          . Pour i =5 :
c            per1a4(j,5) = le reciproque de per1a4(j,*)
c Les reciproques :
c Eux-memes pour j = 0, -2, -3, -4, -5, 2 : per1a4(j,per1a4(j,i)) = i
c -1/1, 3/1 : per1a4(-1,per1a4(1,i)) = per1a4(1,per1a4(-1,i)) = i
c-----------------------------------------------------------------------
      integer         per1a4(-5:3,5)
      common /ope1a4/ per1a4
