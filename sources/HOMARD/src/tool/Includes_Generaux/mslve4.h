      texte(1,6) = '(''Mauvais code de calcul :'',i5)'
c
      texte(2,6) = '(''Bad related code :'',i5)'
c
      if ( typcca.eq.6 ) then
        write(ulsort,texte(langue,7)) 'MED               '
      elseif ( typcca.eq.16 ) then
        write(ulsort,texte(langue,7)) 'ATHENA            '
      elseif ( typcca.eq.26 ) then
        write(ulsort,texte(langue,7)) 'SATURNE 2D        '
      elseif ( typcca.eq.36 ) then
        write(ulsort,texte(langue,7)) 'SATURNE           '
      elseif ( typcca.eq.46 ) then
        write(ulsort,texte(langue,7)) 'NEPTUNE 2D        '
      elseif ( typcca.eq.56 ) then
        write(ulsort,texte(langue,7)) 'NEPTUNE           '
      elseif ( typcca.eq.66 ) then
        write(ulsort,texte(langue,7)) 'CARMEL 2D         '
      elseif ( typcca.eq.76 ) then
        write(ulsort,texte(langue,7)) 'CARMEL            '
      elseif ( typcca.eq.106 ) then
        write(ulsort,texte(langue,7)) 'NON-CONFORME      '
      else
        write(ulsort,texte(langue,6)) typcca
        codret = 5
      endif
