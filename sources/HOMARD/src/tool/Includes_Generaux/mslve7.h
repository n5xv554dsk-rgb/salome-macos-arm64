      if ( taopti(10).gt.0 ) then
c
        if ( taopti(37).eq.0 ) then
c
          write(ulsort,texte(langue,41))
c
          if ( taopti(32).ge.-1 .and.taopti(32).le.1 ) then
            write(ulsort,texte(langue,43+taopti(32)))
c
          else
            write(ulsort,texte(langue,11)) taopti(32)
            nbrepb = nbrepb + 1
c
          endif
c
        endif
c
      endif
