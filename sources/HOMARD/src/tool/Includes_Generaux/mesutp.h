c
c     dimensionnement des tableaux des mesures de temps de calcul
c nbsect = nombre de section de mseures (<= 200)
c numsec(i) = numero de la i-eme section
c titsec(i) = nom de la i-eme section
c
      integer nbsect
      parameter ( nbsect = 200 )
c
      integer numsec (nbsect)
c
      character*24 titsec (nbsect)
