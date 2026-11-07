c
      texte(1,11) =
     >'(/,''. Prealable sur le deraffinement'',/,32(''=''),/)'
      texte(1,12) = '(/,''. Niveau courant :'',i3,/,21(''=''),/)'
      texte(1,13) =
     >'(/,''. Ecart entre les niveaux'',i3,'' et'',i3,/,34(''=''),/)'
      texte(1,15) = '(''. . rien a faire'')'
      texte(1,21) = '(''. Pile de longueur'',i6,'' :'')'
      texte(1,22) = '(''. . nbaret, nbare2 = '',3i2)'
      texte(1,23) =
     >'(''. . arete'',i10,'', de decision'',i3,'', de mere'',i10)'
      texte(1,29) =
     > '(''. '',a,i10,'', niveau'',i3,'', etat'',i5,'', decision'',i3)'
      texte(1,30) = '(''. . ==> nouveau '',a,''('',i10,'') = '',i2,a)'
c
      texte(2,11) =
     >'(/,''. First operation for unrefinement'',/,34(''=''),/)'
      texte(2,12) = '(/,''. Current level :'',i3,/,21(''=''),/)'
      texte(2,13) =
     >'(/,''. Shift between levels'',i3,'' and'',i3,/,32(''=''),/)'
      texte(2,15) = '(''. . nothing to do'')'
      texte(2,21) = '(''. Pile of length'',i6,'' :'')'
      texte(2,22) = '(''. . nbaret, nbare2 = '',3i2)'
      texte(2,23) =
     > '(''. . edge #'',i10,'', decision'',i3,'', with mother #'',i10)'
      texte(2,29) =
     > '(''. '',a,i10,'', level'',i3,'', status'',i5,'', decision'',i3)'
      texte(2,30) = '(''. . ==> new '',a,''('',i10,'') = '',i2,a)'
