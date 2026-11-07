c
c  15 : -2, aucun numero de pas de temps n'a ete fourni
c       1, un numero de pas de temps est fourni
c       2, on prend le dernier pas de temps
c  16 : -2, aucun numero d'ordre n'a ete fourni
c       1, un numero est fourni
c  17 : -2, aucune valeur d'instant n'a ete fournie
c       1, une valeur d'instant est fournie
c       2, on prend le dernier instant
c
c
c       rien n'a ete demande, on met le pas de temps par defaut
c
        if ( taopti(15).eq.-2 .and.
     >       taopti(16).eq.-2 .and.
     >       taopti(17).eq.-2 ) then
c
          taopti(15) = 0
          taopti(16) = 0
          taopti(17) = 0
c
        else
c
c         on ne peut pas demander le dernier sur une des rubriques
c         et autre chose sur une autre
c
          do 35 , iaux = 1 , 3
c
            if ( taopti(14+iaux).eq.2 ) then
c
              do 351, jaux = 1 , 2
                if ( taopti(14+per1a3(jaux,iaux)).eq.-2 ) then
                  goto 351
                elseif ( taopti(14+per1a3(jaux,iaux)).ne.2 ) then
                  nbrepb = nbrepb + 1
                  write(ulsort,texte(langue,101))
                  write(ulsort,texte(langue,102))
                endif
  351         continue
c
            endif
c
   35     continue
c
c         on ne peut pas demander une valeur d'instant et une valeur
c         de numero de pas de temps
c
          if ( taopti(15).eq.0 .or. taopti(15).eq.1 ) then
            if ( taopti(17).eq.0 .or. taopti(17).eq.1 ) then
              nbrepb = nbrepb + 1
              write(ulsort,texte(langue,101))
              write(ulsort,texte(langue,103))
            endif
          endif
c
        endif
