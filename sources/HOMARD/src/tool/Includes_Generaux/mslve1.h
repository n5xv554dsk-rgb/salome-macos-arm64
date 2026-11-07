      elseif ( taopti(11).eq.6 ) then
        write(ulsort,texte(langue,26)) 'MED               '
      elseif ( taopti(11).eq.16 ) then
        write(ulsort,texte(langue,26)) 'ATHENA            '
      elseif ( taopti(11).eq.26 ) then
        write(ulsort,texte(langue,26)) 'SATURNE 2D        '
      elseif ( taopti(11).eq.36 ) then
        write(ulsort,texte(langue,26)) 'SATURNE           '
      elseif ( taopti(11).eq.46 ) then
        write(ulsort,texte(langue,26)) 'NEPTUNE 2D        '
      elseif ( taopti(11).eq.56 ) then
        write(ulsort,texte(langue,26)) 'NEPTUNE           '
      elseif ( taopti(11).eq.66 ) then
        write(ulsort,texte(langue,26)) 'CARMEL 2D         '
      elseif ( taopti(11).eq.76 ) then
        write(ulsort,texte(langue,26)) 'CARMEL            '
      elseif ( taopti(11).eq.106 ) then
        write(ulsort,texte(langue,26)) 'NON-CONFORME      '
      else
        write(ulsort,texte(langue,26)) '             '
        write(ulsort,texte(langue,11)) taopti(11)
        nbrepb = nbrepb + 1
      endif
