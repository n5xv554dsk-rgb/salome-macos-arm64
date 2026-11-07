c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpacm', taopti(43)
      write (ulsort,90002) 'nbnoci', taopti(44)
      write (ulsort,90002) 'nbmaci', taopti(45)
#endif
c
      if ( taopti(44).gt.0 .or. taopti(45).gt.0 ) then
c
        if ( taopti(31).ne.1 .and. taopti(31).ne. 2 ) then
          write(ulsort,texte(langue,120))
          write(ulsort,texte(langue,121))
          nbrepb = nbrepb + 1
        endif
c
        if ( taopti(32).ne.0 ) then
          write(ulsort,texte(langue,120))
          write(ulsort,texte(langue,122))
          nbrepb = nbrepb + 1
        endif
c
        taopti(6) = 5
c
      endif
