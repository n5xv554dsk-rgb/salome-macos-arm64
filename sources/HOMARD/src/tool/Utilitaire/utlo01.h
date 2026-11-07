c
c 2.3. ==> messages d'erreur eventuels
c
      if ( codre0.eq.3 ) then
        write (ulsort,texte(langue,5)) motcle
        write (ulsort,texte(langue,11))
        write (ulsort,texte(langue,12)) nbrmin, nbrmax
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        codret = 6
c
      elseif ( codre0.eq.6 ) then
        write (ulsort,texte(langue,5)) motcle
        write (ulsort,texte(langue,7))
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        codret = 6
c
      elseif ( codre0.eq.5 ) then
        write (ulsort,texte(langue,1)) 'Entree', nompro
        write (ulsort,texte(langue,5)) motcle
        write (ulsort,*) noptio(1:loptio)
        write (ulsort,texte(langue,6)) option
#ifdef _DEBUG_HOMARD_
      elseif ( codre0.eq.0 ) then
        write (ulsort,texte(langue,10)) option
#endif
c
      endif
