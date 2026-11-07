      if ( taopti(31).gt.0 ) then
c
        if ( taopti(37).eq.0 ) then
c
          if ( taopti(6).eq.1 ) then
            write(ulsort,texte(langue,81)) taoptr(1)
          elseif ( taopti(6).eq.2 ) then
            write(ulsort,texte(langue,82)) taoptr(1)
            if ( taoptr(1).lt.0.d0 .or. taoptr(1).gt.100.d0 ) then
              write(ulsort,texte(langue,87))
              nbrepb = nbrepb + 1
            endif
          elseif ( taopti(6).eq.3 ) then
            write(ulsort,texte(langue,83)) taoptr(1)
            if ( taoptr(1).lt.0.d0 .or. taoptr(1).gt.100.d0 ) then
              write(ulsort,texte(langue,87))
              nbrepb = nbrepb + 1
            endif
          elseif ( taopti(6).eq.4 ) then
            write(ulsort,texte(langue,88)) '+', taoptr(1)
          elseif ( taopti(6).eq.5 ) then
            if ( taopti(44).gt.0 ) then
              write(ulsort,texte(langue,123)) taopti(44)
            endif
            if ( taopti(43).gt.0 ) then
              write(ulsort,texte(langue,124)) taopti(43)
            endif
          else
            write(ulsort,texte(langue,80))
            nbrepb = nbrepb + 1
          endif
c
        else
c
          write(ulsort,texte(langue,94))
c
        endif
c
      endif
c
      if ( taopti(31).ne.0 .and. taopti(33).ge.0 ) then
        write(ulsort,texte(langue,51)) taopti(33)
      endif
