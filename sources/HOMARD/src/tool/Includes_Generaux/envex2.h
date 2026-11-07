c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DMFLSH', nompro
#endif
      call dmflsh (iaux)
c
c                     123456
      if ( spropb.eq.'      ' ) then
        spropb = nompro
        write (ulsort,*) '===== HOMARD ===== STOP ====='
      endif
