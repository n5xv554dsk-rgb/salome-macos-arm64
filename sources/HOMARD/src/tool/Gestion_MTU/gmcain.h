c
c  Ceci est la liste des caracteres interdits comme premiere
c  lettre pour le nom d'un objet GM defini par l'utilisateur
c
c     ncainx : nombre de caracteres interdits
c
      integer ncainx
      parameter ( ncainx = 4 )
c
      character*1 caint1, caint2, caint3, caint4
c
      parameter ( caint1 = '%' )
      parameter ( caint2 = '$' )
      parameter ( caint3 = '&' )
      parameter ( caint4 = ' ' )
