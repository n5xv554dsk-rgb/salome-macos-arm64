      saux = '      '
c
      if ( taopti(39).eq.1 ) then
        saux(1:1) = 'X'
      elseif ( taopti(39).eq.2 ) then
        saux(1:1) = 'Y'
      elseif ( taopti(39).eq.3 ) then
        saux(1:1) = 'Z'
c
      elseif ( taopti(39).ne.0 ) then
        write(ulsort,texte(langue,11)) taopti(39)
        nbrepb = nbrepb + 1
c
      endif
c
      if ( saux.ne.'      ' ) then
        write(ulsort,texte(langue,119)) saux(1:1)
      endif
