c
      numsec (50) = 50
      numsec (51) = 51
      numsec (52) = 52
c
      do 320 , iaux = 60, 79
        numsec (iaux) = iaux
  320 continue
c
c 2.1. ==> en francais
c
c                    123456789012345678901234
      titsec (50) = 'Modification            '
      titsec (51) = '. dont degre            '
      titsec (52) = '. creation des joints   '
      titsec (60) = '.. conversion degre 1   '
      titsec (61) = '.. 4. Decompte (mmagr0) '
      titsec (62) = '.. 4. Decompte (mmag11) '
      titsec (63) = '.. 4. Decompte (mmag12) '
      titsec (64) = '.. Reallocation         '
      titsec (65) = '.. 6. Creation (mmag31) '
      titsec (66) = '.. 6. Creation (mmag32) '
      titsec (67) = '.. 6. Creation (mmag33) '
      titsec (68) = '.. 6. Creation (mmag34) '
      titsec (76) = '.. 7.2. Grains (mmagr4) '
      titsec (77) = '.. 7.3. connecti (mmagr5'
      titsec (78) = '.. 8. Suppression       '
      titsec (79) = '.. conversion degre 2   '
c
      do 321 , iaux = 1 , nbsect
        if ( numsec (iaux) .gt. 0 ) then
          call gtnoms ( numsec(iaux), 1 , titsec(iaux) )
        endif
  321 continue
c
c 2.2. ==> en anglais
c
c                    123456789012345678901234
      titsec (50) = 'Modification            '
      titsec (51) = '. degree                '
      titsec (52) = '. creation of the joints'
c
      do 322 , iaux = 1 , nbsect
        if ( numsec (iaux) .gt. 0 ) then
          call gtnoms ( numsec(iaux), 2 , titsec(iaux) )
        endif
  322 continue
