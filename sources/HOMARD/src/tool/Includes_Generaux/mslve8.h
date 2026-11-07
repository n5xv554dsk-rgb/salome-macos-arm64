      if ( taopti(10).gt.0 ) then
c
        if ( taopti(32).gt.0 ) then
c
          if ( taopti(37).eq.0 ) then
c
            if ( taopti(7).eq.1 ) then
              write(ulsort,texte(langue,84)) taoptr(2)
            elseif ( taopti(7).eq.2 ) then
              write(ulsort,texte(langue,85)) taoptr(2)
              if ( taoptr(2).lt.0.d0 .or. taoptr(2).gt.100.d0 ) then
                write(ulsort,texte(langue,88))
                nbrepb = nbrepb + 1
              endif
            elseif ( taopti(7).eq.3 ) then
              write(ulsort,texte(langue,86)) taoptr(2)
              if ( taoptr(2).lt.0.d0 .or. taoptr(2).gt.100.d0 ) then
                write(ulsort,texte(langue,88))
                nbrepb = nbrepb + 1
              endif
            elseif ( taopti(7).eq.4 ) then
              write(ulsort,texte(langue,88)) '-', taoptr(2)
            else
              write(ulsort,texte(langue,80))
              nbrepb = nbrepb + 1
            endif
c
          endif
c
        endif
c
        if ( taopti(32).ne.0 .and. taopti(34).gt.0 ) then
          write(ulsort,texte(langue,52)) taopti(34)
        endif
c
      endif
