c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,typenh)
      if ( (nbcoqu+nbcoar).eq.0 ) then
        write (ulsort,texte(langue,7))
      else
        if ( nbcoqu.gt.0 ) then
          write (ulsort,texte(langue,6)) mess14(langue,3,4), nbcoqu
        endif
        if ( nbcoar.gt.0 ) then
          write (ulsort,texte(langue,6)) mess14(langue,3,1), nbcoar
        endif
      endif
#endif
