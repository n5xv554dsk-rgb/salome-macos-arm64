c
c alphnu contient les principaux caracteres alphanumeriques
c
c     de  0 a  9 : les chiffres de 0 a 9
c     de 10 a 35 : les minuscules de 'a' a 'z'
c     de 36 a 61 : les majuscules de 'A' a 'Z'
c             62 : +
c
      integer lgalnu
      parameter ( lgalnu = 62 )
c
      integer lgaln2
      parameter ( lgaln2 = lgalnu*lgalnu )
c
      integer lgaln3
      parameter ( lgaln3 = lgalnu*lgalnu*lgalnu )
c
      integer lgaln4
      parameter ( lgaln4 = lgalnu*lgalnu*lgalnu*lgalnu )
c
      character*1 alphnu(0:lgalnu)
c
      data alphnu / '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
     >              'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
     >              'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
     >              'u', 'v', 'w', 'x', 'y', 'z',
     >              'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
     >              'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
     >              'U', 'V', 'W', 'X', 'Y', 'Z',
     >              '+' /
