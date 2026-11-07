      if ( taopti(10).gt.0 ) then
c
        if ( taopti(37).eq.0 ) then
c
          if ( taopti(31).gt.0 .and. taopti(32).gt.0 ) then
c
            if ( ( taopti(6).eq.1 .and. taopti(7).eq.1 ) .or.
     >           ( taopti(6).eq.2 .and. taopti(7).eq.2 ) ) then
              if ( taoptr(2).gt.taoptr(1) ) then
                write(ulsort,texte(langue,93))
                nbrepb = nbrepb + 1
              endif
            elseif ( taopti(6).eq.3 .and. taopti(7).eq.3 ) then
              if ( taoptr(1)+taoptr(2).gt.100.d0 ) then
                write(ulsort,texte(langue,93))
                nbrepb = nbrepb + 1
              endif
            endif
c
          endif
c
        endif
c
      endif
