      if ( taopti(10).gt.0 ) then
c
        if ( taopti(31).eq.-1 .and. taopti(32).ne.0 ) then
          write(ulsort,texte(langue,53))
          nbrepb = nbrepb + 1
        endif
c
        if ( taopti(31).ne.0 .and. taopti(32).eq.-1 ) then
          write(ulsort,texte(langue,54))
          nbrepb = nbrepb + 1
        endif
c
      endif
