c
      numsec (40) = 40
      numsec (41) = 41
      numsec (42) = 42
      numsec (43) = 43
      numsec (44) = 44
      numsec (45) = 45
      numsec (46) = 46
      numsec (47) = 47
      numsec (48) = 48
c
      numsec (50) = 50
c
c 2.1. ==> en francais
c
c                    123456789012345678901234
      titsec (40) = 'Informations            '
      titsec (41) = '. dont analyse          '
      titsec (42) = '...... interpenetration '
      titsec (43) = '...... qualite          '
      titsec (44) = '...... connexite        '
      titsec (45) = '...... tailles          '
      titsec (46) = '...... caracteristiques '
      titsec (47) = '...... diametres        '
      titsec (48) = '. dont fichiers         '
c
      titsec (50) = 'Questions/reponses      '
c
      do 221 , iaux = 1 , nbsect
        if ( numsec (iaux) .gt. 0 ) then
          call gtnoms ( numsec(iaux), 1 , titsec(iaux) )
        endif
  221 continue
c
c 2.2. ==> en anglais
c
c                    123456789012345678901234
      titsec (40) = 'Information             '
      titsec (41) = '. analysis              '
      titsec (42) = '...... interpenetration '
      titsec (43) = '...... quality          '
      titsec (44) = '...... connexity        '
      titsec (45) = '...... sizes            '
      titsec (46) = '...... characteristics  '
      titsec (47) = '...... diametres        '
      titsec (48) = '. files                 '
c
      titsec (50) = 'Questions/answers       '
c
      do 222 , iaux = 1 , nbsect
        if ( numsec (iaux) .gt. 0 ) then
          call gtnoms ( numsec(iaux), 2 , titsec(iaux) )
        endif
  222 continue
