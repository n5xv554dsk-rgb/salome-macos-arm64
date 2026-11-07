c
c 2.0. ==> les numeros de sections
c
      numsec (10) = 10
c
      numsec (20) = 20
      numsec (21) = 21
      numsec (22) = 22
      numsec (23) = 23
c
      numsec (30) = 30
      numsec (31) = 31
      numsec (32) = 32
      numsec (33) = 33
      numsec (34) = 34
      numsec (35) = 35
      numsec (36) = 36
c
      numsec (40) = 40
      numsec (41) = 41
      numsec (42) = 42
c
      numsec (50) = 50
      numsec (51) = 51
      numsec (52) = 52
      numsec (53) = 53
      numsec (54) = 54
      numsec (55) = 55
      numsec (56) = 56
      numsec (57) = 57
      numsec (58) = 58
c
      numsec (60) = 60
      numsec (61) = 61
      numsec (62) = 62
      numsec (63) = 63
      numsec (64) = 64
      numsec (65) = 65
      numsec (66) = 66
      numsec (67) = 67
c
      numsec (70) = 70
      numsec (71) = 71
      numsec (72) = 72
c
      numsec (80) = 80
      numsec (81) = 81
      numsec (82) = 82
      numsec (83) = 83
      numsec (84) = 84
      numsec (85) = 85
      numsec (86) = 86
      numsec (87) = 87
      numsec (88) = 88
c
      numsec (90) = 90
      numsec (91) = 91
      numsec (92) = 92
      numsec (93) = 93
      numsec (94) = 94
      numsec (95) = 95
c
      numsec(100) = 100
      numsec(101) = 101
      numsec(102) = 102
      numsec(103) = 103
c
      numsec(110) = 110
      numsec(111) = 111
      numsec(112) = 112
      numsec(113) = 113
c
c 2.1. ==> en francais
c
c                    123456789012345678901234
      titsec (10) = 'Initialisation          '
c
      titsec (20) = 'Lectures                '
      titsec (21) = '. dont options          '
      titsec (22) = '. dont maillage         '
      titsec (23) = '. dont frontiere        '
c
      titsec (30) = 'Conversions avant adapt.'
      titsec (31) = '. dont maillage         '
      titsec (32) = '. dont frontieres       '
      titsec (33) = '. dont analyse          '
      titsec (34) = '. dont filtrage groupes '
      titsec (35) = '. dont lecture indic.   '
      titsec (36) = '. dont indicateur       '
c
      titsec (40) = 'Ecritures iteration n   '
      titsec (41) = '. dont maillage HOMARD  '
      titsec (42) = '. dont indicateur       '
c
      titsec (50) = 'Prise de decisions      '
      titsec (51) = '. dont calcul des sauts '
      titsec (52) = '. dont composantes      '
      titsec (53) = '. dont conformite       '
      titsec (54) = '. dont historiques      '
      titsec (55) = '. dont initialisation   '
      titsec (56) = '. dont periodicite      '
      titsec (57) = '. dont raffinement      '
      titsec (58) = '. dont deraffinement    '
c
      titsec (60) = 'Creation du maillage    '
      titsec (61) = '. dont deraffinement    '
      titsec (62) = '. dont compactage       '
      titsec (63) = '. dont raffinement      '
      titsec (64) = '. dont conformite       '
      titsec (65) = '. dont noeuds supplemen.'
      titsec (66) = '. dont mise a jour      '
      titsec (67) = '. dont analyse          '
c
      titsec (70) = 'Suivi de la frontiere   '
      titsec (71) = '. dont conversion       '
      titsec (72) = '. dont traitement       '
c
      titsec (80) = 'Conversions apres adapt.'
      titsec (81) = '. dont maillage         '
      titsec (82) = '. dont lecture solution '
      titsec (83) = '. dont solution         '
      titsec (84) = '. dont analyse          '
c
      titsec (90) = 'Complements             '
      titsec (91) = '. dont niveau           '
      titsec (92) = '. dont qualite          '
      titsec (93) = '. dont diametre         '
      titsec (94) = '. dont parents          '
      titsec (95) = '. dont voisins recollem.'
c
      titsec(100) = 'Ecritures iteration n+1 '
      titsec(101) = '. dont maillage HOMARD  '
      titsec(102) = '. dont maillage calcul  '
      titsec(103) = '. dont solution         '
c
      titsec(110) = 'Creation du mail. annexe'
      titsec(111) = '. dont changement degre '
      titsec(112) = '. dont conversion       '
      titsec(113) = '. dont ecriture         '
c
      do 21 , iaux = 1 , nbsect
        if ( numsec(iaux).gt.0 ) then
          call gtnoms ( numsec(iaux), 1 , titsec(iaux) )
        endif
   21 continue
c
c 2.2. ==> en anglais
c
c                    123456789012345678901234
      titsec (10) = 'Initialisation          '
c
      titsec (20) = 'Readings                '
      titsec (21) = '. options               '
      titsec (22) = '. mesh                  '
      titsec (23) = '. boundary              '
c
      titsec (30) = 'Conversions before adap.'
      titsec (31) = '. mesh                  '
      titsec (32) = '. boundary              '
      titsec (33) = '. analysis              '
      titsec (34) = '. groupe filtering      '
      titsec (35) = '. indicator readings    '
      titsec (36) = '. indicator             '
c
      titsec (40) = 'Writings iteration # n  '
      titsec (41) = '. HOMARD mesh           '
      titsec (42) = '. indicator             '
c
      titsec (50) = 'Decisions               '
      titsec (51) = '. jumps                 '
      titsec (52) = '. components            '
      titsec (53) = '. conformity            '
      titsec (54) = '. history               '
      titsec (55) = '. initialisation        '
      titsec (56) = '. periodicity           '
      titsec (57) = '. refinement            '
      titsec (58) = '. unrefinement          '
c
      titsec (60) = 'Mesh creation           '
      titsec (61) = '. unrefinement          '
      titsec (62) = '. compactification      '
      titsec (63) = '. refinement            '
      titsec (64) = '. conformity            '
      titsec (65) = '. additional nodes creat'
      titsec (66) = '. up-dating             '
      titsec (67) = '. analysis              '
c
      titsec (70) = 'Boundary following      '
      titsec (71) = '. conversion            '
      titsec (72) = '. treatment             '
c
      titsec (80) = 'Conversions after adapt.'
      titsec (81) = '. mesh                  '
      titsec (82) = '. solution readings     '
      titsec (83) = '. solution              '
      titsec (84) = '. analysis              '
c
      titsec (90) = 'Additional information  '
      titsec (91) = '. level                 '
      titsec (92) = '. quality               '
      titsec (93) = '. diametre              '
      titsec (94) = '. parents               '
      titsec (95) = '. neighbours            '
c
      titsec(100) = 'Writings iteration # n+1'
      titsec(101) = '. HOMARD mesh           '
      titsec(102) = '. calculation mesh      '
      titsec(103) = '. solution              '
c
      titsec(110) = 'Creation of new mesh    '
      titsec(111) = '. degree modification   '
      titsec(112) = '. conversion            '
      titsec(113) = '. writings              '
c
      do 22 , iaux = 1 , nbsect
        if ( numsec(iaux).gt.0 ) then
          call gtnoms ( numsec(iaux), 2 , titsec(iaux) )
        endif
   22 continue
