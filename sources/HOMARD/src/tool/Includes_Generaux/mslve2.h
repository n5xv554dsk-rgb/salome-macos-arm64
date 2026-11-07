      write(ulsort,texte(langue,110))
c
      if ( taopti(30).ge.-2 .and.taopti(30).le.3 ) then
        write(ulsort,texte(langue,113+taopti(30)))
c
      else
        write(ulsort,texte(langue,11)) taopti(30)
        nbrepb = nbrepb + 1
c
      endif
