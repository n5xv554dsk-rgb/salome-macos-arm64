c
c  Message du suivi de frontiere
c  On l'interdit pour du maillage SATURNE/NEPTUNE 3D
c  Pour du MED, on ne sait pas car il faudrait savoir si 2D ou 3D.
c
      write(ulsort,texte(langue,27))
c
      if ( taopti(11).eq.36 .or.
     >     taopti(11).eq.56 ) then
        if ( taopti(29).ne.1 ) then
          write(ulsort,texte(langue,27))
          write(ulsort,texte(langue,28))
          write(ulsort,texte(langue,11)) taopti(29)
          nbrepb = nbrepb + 1
        else
          write(ulsort,texte(langue,14))
        endif
c
      else
        if ( taopti(29).eq.1 ) then
          write(ulsort,texte(langue,14))
        elseif ( ( mod(taopti(29),2).eq.0 .or.
     >             mod(taopti(29),3).eq.0 ) .and.
     >           mod(taopti(29),5).eq.0 ) then
          write(ulsort,texte(langue,11)) taopti(29)
          nbrepb = nbrepb + 1
        elseif ( mod(taopti(29),2).eq.0 .or.
     >           mod(taopti(29),3).eq.0 .or.
     >           mod(taopti(29),5).eq.0 ) then
          write(ulsort,texte(langue,15))
        else
          write(ulsort,texte(langue,11)) taopti(29)
          nbrepb = nbrepb + 1
        endif
      endif
