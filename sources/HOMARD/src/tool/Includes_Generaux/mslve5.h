      write(ulsort,texte(langue,30))
c
#ifdef _DEBUG_HOMARD_
      if ( taopti(49).eq.1 ) then
        write(ulsort,texte(langue,31))
      endif
#endif
c
      if ( taopti(31).ge.-1 .and.taopti(31).le.2 ) then
c
        if ( taopti(37).eq.0 ) then
c
          write(ulsort,texte(langue,33+taopti(31)))
c
          if ( taopti(31).eq.2 ) then
            write(ulsort,texte(langue,34))
          endif
c
        endif
c
      else
        write(ulsort,texte(langue,11)) taopti(31)
        nbrepb = nbrepb + 1
c
      endif
c
      if ( mod(taopti(36),2).eq.0 ) then
        write(ulsort,texte(langue,39))
      endif
c
      if ( mod(taopti(36),3).eq.0 ) then
        write(ulsort,texte(langue,40))
      endif
